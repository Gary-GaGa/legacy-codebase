param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\docs\build-tasks\phase-v-api-selfverify-harness-v1.json'),
    [string]$BaseUrl,
    [switch]$SkipDb,
    [switch]$ValidateOnly,
    [string]$OutFile,
    [string]$ResponseDumpDir = (Join-Path $PSScriptRoot '..\docs\verification\phase-v-api-selfverify-responses')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-EnvOrDefault {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [object]$Default = $null,
        [bool]$HasDefault = $false
    )

    $value = [Environment]::GetEnvironmentVariable($Name)
    if (![string]::IsNullOrEmpty($value)) {
        return $value
    }
    if ($HasDefault) {
        return $Default
    }
    throw "Required environment variable is missing: $Name"
}

function ConvertTo-CaseSensitiveJsonObject {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [System.Collections.IDictionary]) {
        $dict = New-Object System.Collections.Specialized.OrderedDictionary -ArgumentList ([System.StringComparer]::Ordinal)
        foreach ($key in $Value.Keys) {
            $dict[[string]$key] = ConvertTo-CaseSensitiveJsonObject -Value $Value[$key]
        }
        return $dict
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $items = @()
        foreach ($item in $Value) {
            $items += ConvertTo-CaseSensitiveJsonObject -Value $item
        }
        return $items
    }

    return $Value
}

function ConvertFrom-JsonCompat {
    param([AllowNull()][string]$Json)

    if ([string]::IsNullOrWhiteSpace($Json)) {
        return $null
    }

    try {
        return $Json | ConvertFrom-Json
    } catch {
        if ($_.Exception.Message -notmatch 'duplicat') {
            throw
        }

        Add-Type -AssemblyName System.Web.Extensions
        $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $serializer.MaxJsonLength = [int]::MaxValue
        return ConvertTo-CaseSensitiveJsonObject -Value ($serializer.DeserializeObject($Json))
    }
}

function ConvertFrom-JwtPayload {
    param([Parameter(Mandatory = $true)][string]$Jwt)

    $parts = $Jwt.Split('.')
    if ($parts.Count -lt 2) {
        throw 'PHASE_V_JWT is not a JWT-shaped token.'
    }

    $payload = $parts[1].Replace('-', '+').Replace('_', '/')
    switch ($payload.Length % 4) {
        2 { $payload += '==' }
        3 { $payload += '=' }
        1 { throw 'JWT payload has invalid base64url length.' }
    }

    $json = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
    return ConvertFrom-JsonCompat -Json $json
}

function Get-OptionalEnv {
    param([Parameter(Mandatory = $true)][string]$Name)
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }
    return $value
}

function Get-RoleEnvSuffix {
    param([Parameter(Mandatory = $true)][string]$Role)
    return ([regex]::Replace($Role, '[^A-Za-z0-9]', '_')).ToUpperInvariant()
}

function New-ValidationJwtClaims {
    return [pscustomobject]@{
        roleId = 'placeholder'
        empId = 'placeholder'
        deptCode = 'placeholder'
    }
}

function New-HarnessFailure {
    param(
        [ValidateSet('infra', 'auth', 'assertion')]
        [string]$Category,
        [string]$Status,
        [string]$Detail
    )

    throw ("{0}:{1}:{2}" -f $Status, $Category, $Detail)
}

function ConvertTo-ResultStatus {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $message = [string]$ErrorRecord.Exception.Message
    if ($message -match '^(ENV_NOT_READY|AUTH_FAILED|FAIL):(infra|auth|assertion):(.*)$') {
        return [pscustomobject]@{
            status = $Matches[1]
            category = $Matches[2]
            detail = $Matches[3]
        }
    }

    if ($message -match 'HTTP (401|403)\b' -or $message -match '"code"\s*:\s*"E40[1-9]"' -or $message -match '"code"\s*:\s*"E49[78]"') {
        return [pscustomobject]@{ status = 'AUTH_FAILED'; category = 'auth'; detail = $message }
    }
    if ($message -match '(Failed to connect|Could not resolve|Connection refused|timed out|No connection|ORA-01017|ORA-12154|ORA-125|TNS:|SQL\*Plus)') {
        return [pscustomobject]@{ status = 'ENV_NOT_READY'; category = 'infra'; detail = $message }
    }

    return [pscustomobject]@{ status = 'FAIL'; category = 'assertion'; detail = $message }
}

function Test-AuthErrorEnvelope {
    param([AllowNull()][object]$Body)

    $code = Get-JsonPathValue -Object $Body -Path 'code'
    if ($null -eq $code) {
        return $false
    }
    return ([string]$code -match '^E40[1-9]$|^E49[78]$')
}

function Test-InfraErrorEnvelope {
    param([AllowNull()][object]$Body)

    $code = Get-JsonPathValue -Object $Body -Path 'code'
    return ($null -ne $code -and [string]$code -eq 'E998')
}

function Resolve-TokenValue {
    param(
        [AllowNull()][object]$Value,
        [hashtable]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string] -and $Value -isnot [pscustomobject]) {
        $items = @()
        foreach ($item in $Value) {
            $items += Resolve-TokenValue -Value $item -Context $Context
        }
        return $items
    }

    if ($Value -is [pscustomobject]) {
        $result = [ordered]@{}
        foreach ($prop in $Value.PSObject.Properties) {
            $result[$prop.Name] = Resolve-TokenValue -Value $prop.Value -Context $Context
        }
        return [pscustomobject]$result
    }

    if ($Value -isnot [string]) {
        return $Value
    }

    if ($Value -eq '${langType}') {
        return $Context.langType
    }

    if ($Value -match '^\$\{jwt:([^}]+)\}$') {
        $name = $Matches[1]
        $prop = $Context.jwt.PSObject.Properties[$name]
        if ($null -eq $prop) {
            throw "JWT payload is missing claim: $name"
        }
        return $prop.Value
    }

    if ($Value -match '^\$\{env:([^}|]+)(?:\|(.+))?\}$') {
        $name = $Matches[1]
        $hasDefault = $Matches.Count -ge 3 -and $null -ne $Matches[2]
        $default = $null
        if ($hasDefault) {
            $defaultRaw = $Matches[2]
            if ($defaultRaw -eq 'null') {
                $default = $null
            } else {
                $default = Resolve-TokenValue -Value $defaultRaw -Context $Context
            }
        }
        return Get-EnvOrDefault -Name $name -Default $default -HasDefault:$hasDefault
    }

    return $Value
}

function Get-JsonPathValue {
    param(
        [AllowNull()][object]$Object,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Object
    }

    $current = $Object
    foreach ($part in $Path.Split('.')) {
        if ($null -eq $current) {
            return $null
        }
        if ($current -is [System.Collections.IDictionary]) {
            $current = $current[$part]
            continue
        }
        $prop = $current.PSObject.Properties[$part]
        if ($null -eq $prop) {
            return $null
        }
        $current = $prop.Value
    }
    return $current
}

function Test-JsonPathExists {
    param(
        [AllowNull()][object]$Object,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $true
    }

    $current = $Object
    foreach ($part in $Path.Split('.')) {
        if ($null -eq $current) {
            return $false
        }
        if ($current -is [System.Collections.IDictionary]) {
            if (-not $current.Contains($part)) {
                return $false
            }
            $current = $current[$part]
            continue
        }
        if ($current -is [System.Collections.IList] -and $part -match '^\d+$') {
            $index = [int]$part
            if ($index -lt 0 -or $index -ge $current.Count) {
                return $false
            }
            $current = $current[$index]
            continue
        }
        $prop = $current.PSObject.Properties[$part]
        if ($null -eq $prop) {
            return $false
        }
        $current = $prop.Value
    }
    return $true
}

function Get-CollectionCount {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return $null
    }
    if ($Value -is [array]) {
        return $Value.Count
    }
    if ($Value -is [System.Collections.ICollection]) {
        return $Value.Count
    }
    return 1
}

function Get-ResponseCount {
    param(
        [object]$Body,
        [object]$ResponseSpec
    )

    $listValue = Get-JsonPathValue -Object $Body -Path $ResponseSpec.listPath
    $listCount = Get-CollectionCount -Value $listValue
    if ($null -ne $listCount) {
        return [int]$listCount
    }

    $totalValue = Get-JsonPathValue -Object $Body -Path $ResponseSpec.totalCountPath
    if ($null -ne $totalValue -and "$totalValue" -match '^-?\d+$') {
        return [int]$totalValue
    }

    throw "Cannot determine response count. listPath=$($ResponseSpec.listPath), totalCountPath=$($ResponseSpec.totalCountPath)"
}

function ConvertTo-QueryString {
    param([object]$Query)

    $pairs = @()
    foreach ($prop in $Query.PSObject.Properties) {
        if ($null -eq $prop.Value) {
            continue
        }
        $pairs += '{0}={1}' -f [uri]::EscapeDataString($prop.Name), [uri]::EscapeDataString([string]$prop.Value)
    }
    return ($pairs -join '&')
}

function Get-CaseRequiredRole {
    param([object]$Case)

    if ($null -ne $Case.auth -and $null -ne $Case.auth.PSObject.Properties['requiredRole']) {
        return [string]$Case.auth.requiredRole
    }
    if ($null -ne $Case.PSObject.Properties['requiredRole']) {
        return [string]$Case.requiredRole
    }
    return $null
}

function Invoke-RoleLogin {
    param(
        [string]$BaseUrl,
        [string]$Role,
        [string]$EmpId,
        [object]$Manifest
    )

    $endpoint = '/epl-ut-login'
    if ($null -ne $Manifest.auth -and $null -ne $Manifest.auth.PSObject.Properties['loginEndpoint']) {
        $endpoint = [string]$Manifest.auth.loginEndpoint
    }
    $tokenPath = 'data.eproToken'
    if ($null -ne $Manifest.auth -and $null -ne $Manifest.auth.PSObject.Properties['tokenPath']) {
        $tokenPath = [string]$Manifest.auth.tokenPath
    }

    $url = $BaseUrl.TrimEnd('/') + '/' + $endpoint.TrimStart('/')
    $bodyFile = New-TemporaryFile
    $outFile = New-TemporaryFile
    try {
        $body = @{ empId = $EmpId } | ConvertTo-Json -Compress
        [System.IO.File]::WriteAllText($bodyFile.FullName, $body, [System.Text.UTF8Encoding]::new($false))
        $statusRaw = & curl.exe -sS -o $outFile.FullName -w '%{http_code}' -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' --data-binary "@$($bodyFile.FullName)" $url 2>&1
        $curlExitCode = $LASTEXITCODE
        $raw = Get-Content -Path $outFile.FullName -Raw -Encoding UTF8
        if ($curlExitCode -ne 0) {
            New-HarnessFailure -Category infra -Status ENV_NOT_READY -Detail "login curl failed for role $Role with exit $curlExitCode"
        }

        $status = [int]([string]$statusRaw).Trim()
        $json = $null
        if (![string]::IsNullOrWhiteSpace($raw)) {
            $json = ConvertFrom-JsonCompat -Json $raw
        }

        if ($status -eq 401 -or $status -eq 403 -or (Test-AuthErrorEnvelope -Body $json)) {
            New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail "login failed for role $Role with HTTP $status"
        }
        if ($status -lt 200 -or $status -ge 300 -or (Test-InfraErrorEnvelope -Body $json)) {
            New-HarnessFailure -Category infra -Status ENV_NOT_READY -Detail "login endpoint not serviceable for role $Role; HTTP $status"
        }

        $jwt = Get-JsonPathValue -Object $json -Path $tokenPath
        if ([string]::IsNullOrWhiteSpace($jwt)) {
            New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail "login response missing token at $tokenPath for role $Role"
        }

        $claims = ConvertFrom-JwtPayload -Jwt $jwt
        if ([string]$claims.roleId -ne $Role) {
            New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail "login token role mismatch for role $Role"
        }

        return $jwt
    } finally {
        Remove-Item -LiteralPath $bodyFile.FullName -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $outFile.FullName -Force -ErrorAction SilentlyContinue
    }
}

function Get-RoleJwt {
    param(
        [AllowNull()][string]$Role,
        [string]$BaseUrl,
        [object]$Manifest,
        [hashtable]$TokenCache
    )

    if ([string]::IsNullOrWhiteSpace($Role)) {
        $fallbackJwt = Get-OptionalEnv -Name 'PHASE_V_JWT'
        if ($null -ne $fallbackJwt) {
            return $fallbackJwt
        }
        New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail 'case has no required role and PHASE_V_JWT is not set'
    }

    if ($TokenCache.ContainsKey($Role)) {
        return $TokenCache[$Role]
    }

    $suffix = Get-RoleEnvSuffix -Role $Role
    foreach ($name in @("PHASE_V_JWT_ROLE_$suffix", "PHASE_V_ROLE_${suffix}_JWT")) {
        $jwt = Get-OptionalEnv -Name $name
        if ($null -ne $jwt) {
            $claims = ConvertFrom-JwtPayload -Jwt $jwt
            if ([string]$claims.roleId -ne $Role) {
                New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail "env token $name role mismatch for role $Role"
            }
            $TokenCache[$Role] = $jwt
            return $jwt
        }
    }

    foreach ($name in @("PHASE_V_ROLE_${suffix}_EMP_ID", "PHASE_V_EMP_ID_ROLE_$suffix")) {
        $empId = Get-OptionalEnv -Name $name
        if ($null -ne $empId) {
            $jwt = Invoke-RoleLogin -BaseUrl $BaseUrl -Role $Role -EmpId $empId -Manifest $Manifest
            $TokenCache[$Role] = $jwt
            return $jwt
        }
    }

    New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail "missing JWT or empId env for role $Role"
}

function Get-CaseContext {
    param(
        [object]$Case,
        [object]$Manifest,
        [string]$BaseUrl,
        [hashtable]$TokenCache
    )

    $role = Get-CaseRequiredRole -Case $Case
    $jwt = Get-RoleJwt -Role $role -BaseUrl $BaseUrl -Manifest $Manifest -TokenCache $TokenCache
    return [ordered]@{
        role = $role
        jwt = (ConvertFrom-JwtPayload -Jwt $jwt)
        jwtValue = $jwt
    }
}

function Get-CaseFixtureSummary {
    param(
        [object]$Case,
        [hashtable]$Context
    )

    try {
        if ($Case.PSObject.Properties['fixtureLabel'] -and -not [string]::IsNullOrWhiteSpace([string]$Case.fixtureLabel)) {
            return [string]$Case.fixtureLabel
        }
        $resolvedParams = Resolve-TokenValue -Value $Case.params -Context $Context
        $applicationNo = $null
        if ($resolvedParams.contentType -eq 'query') {
            $applicationNo = Get-JsonPathValue -Object $resolvedParams -Path 'query.applicationNo'
        } elseif ($resolvedParams.contentType -eq 'json') {
            $applicationNo = Get-JsonPathValue -Object $resolvedParams -Path 'body.applicationNo'
        }
        if ($null -eq $applicationNo -or [string]::IsNullOrWhiteSpace([string]$applicationNo)) {
            return '-'
        }
        return [string]$applicationNo
    } catch {
        return '-'
    }
}

function Write-ResponseDump {
    param(
        [object]$Case,
        [AllowNull()][string]$Raw,
        [AllowNull()][string]$DumpDir
    )

    if ([string]::IsNullOrWhiteSpace($DumpDir) -or [string]::IsNullOrWhiteSpace($Raw)) {
        return $null
    }

    if (-not (Test-Path -LiteralPath $DumpDir)) {
        New-Item -ItemType Directory -Force -Path $DumpDir | Out-Null
    }

    $safeId = ([regex]::Replace([string]$Case.id, '[^A-Za-z0-9_.-]', '_'))
    $path = Join-Path $DumpDir ("{0}-response.json" -f $safeId)
    $fullPath = [System.IO.Path]::GetFullPath($path)
    [System.IO.File]::WriteAllText($fullPath, $Raw, [System.Text.UTF8Encoding]::new($false))

    $repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\', '/')
    if ($fullPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($repoRoot.Length).TrimStart('\', '/')
    }
    return $fullPath
}

function Invoke-ApiCase {
    param(
        [object]$Case,
        [string]$BaseUrl,
        [string]$Jwt,
        [hashtable]$Context
    )

    $resolvedParams = Resolve-TokenValue -Value $Case.params -Context $Context
    $method = ([string]$Case.method).ToUpperInvariant()
    $url = $BaseUrl.TrimEnd('/') + '/' + ([string]$Case.endpoint).TrimStart('/')
    $bodyFile = $null
    $outFile = New-TemporaryFile
    $args = @(
        '-sS',
        '-o', $outFile.FullName,
        '-w', '%{http_code}',
        '-X', $method,
        '-H', "Authorization: Bearer $Jwt",
        '-H', 'Accept: application/json'
    )

    try {
        if ($resolvedParams.contentType -eq 'query') {
            $queryString = ConvertTo-QueryString -Query $resolvedParams.query
            if (![string]::IsNullOrWhiteSpace($queryString)) {
                $url = "$url`?$queryString"
            }
        } elseif ($resolvedParams.contentType -eq 'json') {
            $bodyFile = New-TemporaryFile
            $jsonBody = $resolvedParams.body | ConvertTo-Json -Depth 20 -Compress
            [System.IO.File]::WriteAllText($bodyFile.FullName, $jsonBody, [System.Text.UTF8Encoding]::new($false))
            $args += @('-H', 'Content-Type: application/json', '--data-binary', "@$($bodyFile.FullName)")
        } else {
            throw "Unsupported contentType: $($resolvedParams.contentType)"
        }

        $statusRaw = & curl.exe @args $url 2>&1
        $curlExitCode = $LASTEXITCODE
        if ($curlExitCode -ne 0) {
            New-HarnessFailure -Category infra -Status ENV_NOT_READY -Detail "curl failed with exit $curlExitCode for $($Case.endpoint)"
        }
        $status = [int]([string]$statusRaw).Trim()
        $raw = Get-Content -Path $outFile.FullName -Raw -Encoding UTF8
        $json = $null
        if (![string]::IsNullOrWhiteSpace($raw)) {
            $json = ConvertFrom-JsonCompat -Json $raw
        }

        if ($status -eq 401 -or $status -eq 403 -or (Test-AuthErrorEnvelope -Body $json)) {
            $snippet = ($raw -replace '\s+', ' ')
            if ($snippet.Length -gt 240) {
                $snippet = $snippet.Substring(0, 240)
            }
            New-HarnessFailure -Category auth -Status AUTH_FAILED -Detail "HTTP $status from $($Case.endpoint): $snippet"
        }

        if (Test-InfraErrorEnvelope -Body $json) {
            New-HarnessFailure -Category infra -Status ENV_NOT_READY -Detail "$($Case.endpoint) returned E998"
        }

        if ($status -lt 200 -or $status -ge 300) {
            $snippet = ($raw -replace '\s+', ' ')
            if ($snippet.Length -gt 240) {
                $snippet = $snippet.Substring(0, 240)
            }
            New-HarnessFailure -Category assertion -Status FAIL -Detail "HTTP $status from $($Case.endpoint): $snippet"
        }

        return [pscustomobject]@{
            Status = $status
            Body = $json
            Raw = $raw
        }
    } finally {
        Remove-Item -LiteralPath $outFile.FullName -Force -ErrorAction SilentlyContinue
        if ($null -ne $bodyFile) {
            Remove-Item -LiteralPath $bodyFile.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-SqlText {
    param([object]$SqlSpec)

    if ($SqlSpec -is [array]) {
        return ($SqlSpec -join "`n")
    }
    return [string]$SqlSpec
}

function ConvertTo-SqlLiteral {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return 'NULL'
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $items = @()
        foreach ($item in $Value) {
            $items += ConvertTo-SqlLiteral -Value $item
        }
        return ($items -join ', ')
    }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [decimal] -or $Value -is [double]) {
        return [string]$Value
    }

    $escaped = ([string]$Value).Replace("'", "''")
    return "'$escaped'"
}

function Expand-SqlParams {
    param(
        [string]$Sql,
        [object]$Params
    )

    $expanded = $Sql
    foreach ($prop in $Params.PSObject.Properties) {
        $name = [regex]::Escape($prop.Name)
        $literal = ConvertTo-SqlLiteral -Value $prop.Value
        $expanded = [regex]::Replace($expanded, "(?<![A-Za-z0-9_]):$name(?![A-Za-z0-9_])", [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $literal })
    }
    return $expanded
}

function Assert-ReadOnlySql {
    param([string]$Sql)

    $withoutStrings = [regex]::Replace($Sql, "'([^']|'')*'", "''")
    $forbidden = '\b(INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE|GRANT|REVOKE|COMMIT|ROLLBACK|EXEC|EXECUTE|CALL)\b'
    if ($withoutStrings -match $forbidden) {
        throw "SQL contains a forbidden non-read-only keyword: $($Matches[1])"
    }
    if ($withoutStrings -notmatch '^\s*(SELECT|WITH)\b') {
        throw 'SQL must start with SELECT or WITH.'
    }
}

function Invoke-DbSql {
    param(
        [string]$Sql,
        [string]$DbRunner
    )

    Assert-ReadOnlySql -Sql $Sql

    $sqlFile = New-TemporaryFile
    $content = @"
set heading off
set feedback off
set verify off
set echo off
set pagesize 0
set linesize 32767
set trimspool on
set long 1000000
set longchunksize 1000000
whenever sqlerror exit sql.sqlcode
$Sql
;
exit
"@

    try {
        [System.IO.File]::WriteAllText($sqlFile.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        $output = & $DbRunner "@$($sqlFile.FullName)" 2>&1
        $exitCode = $LASTEXITCODE
        $text = ($output | ForEach-Object { [string]$_ } | Where-Object { $_.Trim() -ne '' }) -join "`n"
        if ($exitCode -ne 0) {
            throw "DB runner failed with exit code $exitCode. $text"
        }
        return $text.Trim()
    } finally {
        Remove-Item -LiteralPath $sqlFile.FullName -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-DbScalar {
    param(
        [object]$SqlSpec,
        [object]$ParamsSpec,
        [hashtable]$Context,
        [string]$DbRunner
    )

    $params = Resolve-TokenValue -Value $ParamsSpec -Context $Context
    $sql = Expand-SqlParams -Sql (Get-SqlText -SqlSpec $SqlSpec) -Params $params
    $raw = Invoke-DbSql -Sql $sql -DbRunner $DbRunner
    $line = ($raw -split "`r?`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1).Trim()
    if ($line -notmatch '^-?\d+$') {
        throw "DB scalar result is not numeric: $line"
    }
    return [int]$line
}

function Invoke-DbJsonRow {
    param(
        [object]$SqlSpec,
        [object]$ParamsSpec,
        [hashtable]$Context,
        [string]$DbRunner
    )

    $params = Resolve-TokenValue -Value $ParamsSpec -Context $Context
    $sql = Expand-SqlParams -Sql (Get-SqlText -SqlSpec $SqlSpec) -Params $params
    $raw = Invoke-DbSql -Sql $sql -DbRunner $DbRunner
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw 'DB JSON row query returned no rows.'
    }
    return ConvertFrom-JsonCompat -Json $raw
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Rows,
        [string]$Id,
        [AllowNull()][string]$Role,
        [AllowNull()][string]$Fixture,
        [string]$Endpoint,
        [string]$Zh,
        [string]$En,
        [string]$Db,
        [string]$Category,
        [string]$Status,
        [string]$Detail,
        [AllowNull()][string]$DumpFile
    )

    $Rows.Add([pscustomobject]@{
        id = $Id
        role = if ([string]::IsNullOrWhiteSpace($Role)) { '-' } else { $Role }
        fixture = if ([string]::IsNullOrWhiteSpace($Fixture)) { '-' } else { $Fixture }
        endpoint = $Endpoint
        zh_TW = $Zh
        en_US = $En
        db = $Db
        category = $Category
        status = $Status
        detail = $Detail
        dump = if ([string]::IsNullOrWhiteSpace($DumpFile)) { '-' } else { $DumpFile }
    }) | Out-Null
}

function Test-LangTypeCase {
    param(
        [object]$Case,
        [object]$Manifest,
        [string]$BaseUrl,
        [object]$AuthContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    $baseContext = @{
        jwt = $AuthContext.jwt
        langType = $null
    }
    $fixture = Get-CaseFixtureSummary -Case $Case -Context $baseContext

    try {
        $counts = @{}
        foreach ($langType in $Manifest.langTypes) {
            $context = $baseContext.Clone()
            $context.langType = [string]$langType
            $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $AuthContext.jwtValue -Context $context
            $counts[[string]$langType] = Get-ResponseCount -Body $api.Body -ResponseSpec $Case.response
        }

        $zh = [int]$counts['zh_TW']
        $en = [int]$counts['en_US']
        $dbText = 'SKIP'
        $status = 'PASS'
        $details = @()

        if ($zh -ne $en) {
            $status = 'FAIL'
            $details += "langType count mismatch zh_TW=$zh en_US=$en"
        }

        if (!$SkipDb) {
            $context = $baseContext.Clone()
            $dbCount = Invoke-DbScalar -SqlSpec $Case.equiv_sql.sql -ParamsSpec $Case.equiv_sql.params -Context $context -DbRunner $DbRunner
            $dbText = [string]$dbCount
            if ($zh -ne $dbCount -or $en -ne $dbCount) {
                $status = 'FAIL'
                $details += "API count does not match DB count $dbCount"
            }
        }

        if ($details.Count -eq 0) {
            $details += 'ok'
        }

        $category = if ($status -eq 'PASS') { '-' } else { 'assertion' }
        Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh $zh -En $en -Db $dbText -Category $category -Status $status -Detail ($details -join '; ') -DumpFile $null
    } catch {
        $result = ConvertTo-ResultStatus -ErrorRecord $_
        Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Category $result.category -Status $result.status -Detail $result.detail -DumpFile $null
    }
}

function Test-RowEqualsCase {
    param(
        [object]$Case,
        [string]$BaseUrl,
        [object]$AuthContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    $baseContext = @{
        jwt = $AuthContext.jwt
        langType = $null
    }
    $fixture = Get-CaseFixtureSummary -Case $Case -Context $baseContext
    $dumpFile = $null

    try {
        $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $AuthContext.jwtValue -Context $baseContext
        if ($Case.assert.PSObject.Properties['dumpResponse'] -and [bool]$Case.assert.dumpResponse) {
            $dumpFile = Write-ResponseDump -Case $Case -Raw $api.Raw -DumpDir $ResponseDumpDir
        }
        $apiData = Get-JsonPathValue -Object $api.Body -Path $Case.response.dataPath
        if ($null -eq $apiData) {
            throw "Response dataPath returned null: $($Case.response.dataPath)"
        }

        if ($SkipDb) {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db 'SKIP' -Category '-' -Status 'PASS' -Detail 'API 2xx; DB skipped' -DumpFile $dumpFile
            return
        }

        $dbRow = Invoke-DbJsonRow -SqlSpec $Case.equiv_sql.sql -ParamsSpec $Case.equiv_sql.params -Context $baseContext -DbRunner $DbRunner
        $diffs = @()
        foreach ($field in $Case.assert.fields) {
            $apiValue = Get-JsonPathValue -Object $apiData -Path $field
            $dbValue = Get-JsonPathValue -Object $dbRow -Path $field
            if ($null -eq $apiValue) { $apiValue = '' }
            if ($null -eq $dbValue) { $dbValue = '' }
            if ([string]$apiValue -ne [string]$dbValue) {
                $diffs += "$field(api='$apiValue',db='$dbValue')"
            }
        }

        if ($diffs.Count -gt 0) {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db 'row' -Category 'assertion' -Status 'FAIL' -Detail ($diffs -join '; ') -DumpFile $dumpFile
        } else {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db 'row' -Category '-' -Status 'PASS' -Detail 'API fields match DB row' -DumpFile $dumpFile
        }
    } catch {
        $result = ConvertTo-ResultStatus -ErrorRecord $_
        Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Category $result.category -Status $result.status -Detail $result.detail -DumpFile $dumpFile
    }
}

function Get-ObjectMemberCount {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) {
        return $null
    }
    if ($Value -is [array]) {
        return $Value.Count
    }
    if ($Value -is [System.Collections.IDictionary]) {
        return $Value.Count
    }
    if ($Value -is [pscustomobject]) {
        return @($Value.PSObject.Properties).Count
    }
    return 1
}

function Test-EmptyAndOptionsCase {
    param(
        [object]$Case,
        [string]$BaseUrl,
        [object]$AuthContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    $baseContext = @{
        jwt = $AuthContext.jwt
        langType = $null
    }
    $fixture = Get-CaseFixtureSummary -Case $Case -Context $baseContext
    $dumpFile = $null

    try {
        $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $AuthContext.jwtValue -Context $baseContext
        if ($Case.assert.PSObject.Properties['dumpResponse'] -and [bool]$Case.assert.dumpResponse) {
            $dumpFile = Write-ResponseDump -Case $Case -Raw $api.Raw -DumpDir $ResponseDumpDir
        }

        $bodyCode = Get-JsonPathValue -Object $api.Body -Path 'code'
        if ($null -ne $bodyCode -and [string]$bodyCode -ne '0000') {
            $bodyMessage = Get-JsonPathValue -Object $api.Body -Path 'message'
            if ([string]$bodyCode -eq 'E116' -or [string]$bodyMessage -match 'MSG_DATA_NOT_FOUND|Data not found') {
                Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Category 'assertion' -Status 'FAIL' -Detail "fixture returned data-not-found envelope; choose a valid case with no TB_REVISED_ITEM row" -DumpFile $dumpFile
                return
            }
        }

        $apiData = Get-JsonPathValue -Object $api.Body -Path $Case.response.dataPath
        if ($null -eq $apiData) {
            throw "Response dataPath returned null: $($Case.response.dataPath)"
        }

        $issues = @()
        foreach ($field in $Case.assert.emptyFields) {
            $value = Get-JsonPathValue -Object $apiData -Path $field
            if ($null -ne $value -and [string]$value -ne '') {
                $issues += "$field is not empty"
            }
        }

        $dbText = 'SKIP'
        if (!$SkipDb) {
            $rowCount = Invoke-DbScalar -SqlSpec $Case.equiv_sql.row_count_sql -ParamsSpec $Case.equiv_sql.params -Context $baseContext -DbRunner $DbRunner
            $optionCount = Invoke-DbScalar -SqlSpec $Case.equiv_sql.option_count_sql -ParamsSpec $Case.equiv_sql.params -Context $baseContext -DbRunner $DbRunner
            $dbText = "row=$rowCount options=$optionCount"
            if ($rowCount -ne 0) {
                $issues += "TB_REVISED_ITEM count is $rowCount, expected 0"
            }

            $optionValue = Get-JsonPathValue -Object $apiData -Path $Case.assert.optionPath
            $apiOptionCount = Get-ObjectMemberCount -Value $optionValue
            if ($null -eq $apiOptionCount) {
                $issues += "data envelope missing required $($Case.assert.optionPath) per EPROZ00800 QueryRevisedItemResponse"
            } elseif ($apiOptionCount -ne $optionCount) {
                $issues += "option count api=$apiOptionCount db=$optionCount"
            }

            $sizeValue = Get-JsonPathValue -Object $apiData -Path $Case.assert.optionSizePath
            if ($null -ne $sizeValue -and [int]$sizeValue -ne $optionCount) {
                $issues += "option size api=$sizeValue db=$optionCount"
            }
        }

        if ($issues.Count -gt 0) {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db $dbText -Category 'assertion' -Status 'FAIL' -Detail ($issues -join '; ') -DumpFile $dumpFile
        } else {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db $dbText -Category '-' -Status 'PASS' -Detail 'empty item fields and option count match' -DumpFile $dumpFile
        }
    } catch {
        $result = ConvertTo-ResultStatus -ErrorRecord $_
        Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Category $result.category -Status $result.status -Detail $result.detail -DumpFile $dumpFile
    }
}

function Format-CountMap {
    param([AllowNull()][object]$Map)

    if ($null -eq $Map -or $Map.Count -eq 0) {
        return '-'
    }

    $parts = @()
    foreach ($entry in $Map.GetEnumerator()) {
        $parts += ('{0}={1}' -f $entry.Key, $entry.Value)
    }
    return ($parts -join ';')
}

function Test-ResponseContractCase {
    param(
        [object]$Case,
        [object]$Manifest,
        [string]$BaseUrl,
        [object]$AuthContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    $baseContext = @{
        jwt = $AuthContext.jwt
        langType = $null
    }
    $fixture = Get-CaseFixtureSummary -Case $Case -Context $baseContext

    try {
        $langTypeParity = $false
        if ($Case.assert.PSObject.Properties['langTypeParity']) {
            $langTypeParity = [bool]$Case.assert.langTypeParity
        }

        $langTypes = @($null)
        if ($langTypeParity) {
            $langTypes = @($Manifest.langTypes)
        }

        $successCodePath = 'code'
        if ($Case.assert.PSObject.Properties['successCodePath']) {
            $successCodePath = [string]$Case.assert.successCodePath
        }

        $successCodes = @('0000')
        if ($Case.assert.PSObject.Properties['successCodes']) {
            $successCodes = @($Case.assert.successCodes | ForEach-Object { [string]$_ })
        }

        $requiredPaths = @()
        if ($Case.assert.PSObject.Properties['requiredPaths']) {
            $requiredPaths = @($Case.assert.requiredPaths)
        }

        $countChecks = @()
        if ($Case.assert.PSObject.Properties['countChecks']) {
            $countChecks = @($Case.assert.countChecks)
        }

        $issues = @()
        $responseCountsByLang = @{}
        $responseTextByLang = @{}

        foreach ($langType in $langTypes) {
            $context = $baseContext.Clone()
            $context.langType = $langType
            $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $AuthContext.jwtValue -Context $context

            $code = Get-JsonPathValue -Object $api.Body -Path $successCodePath
            if ($null -eq $code -or ($successCodes -notcontains [string]$code)) {
                $issues += "response code path $successCodePath expected $($successCodes -join ',') actual $code"
            }

            foreach ($path in $requiredPaths) {
                if (-not (Test-JsonPathExists -Object $api.Body -Path ([string]$path))) {
                    $issues += "missing required path $path"
                }
            }

            $countMap = [ordered]@{}
            foreach ($check in $countChecks) {
                $countName = [string]$check.name
                $responsePath = [string]$check.responsePath
                $pathExists = Test-JsonPathExists -Object $api.Body -Path $responsePath
                $value = Get-JsonPathValue -Object $api.Body -Path $responsePath
                $apiCount = if ($pathExists -and $null -eq $value) { 0 } else { Get-CollectionCount -Value $value }
                if ($null -eq $apiCount) {
                    $issues += "cannot count response path $responsePath"
                } else {
                    $countMap[$countName] = [int]$apiCount
                }
            }

            $langKey = '_single'
            if ($null -ne $langType) {
                $langKey = [string]$langType
            }
            $responseCountsByLang[$langKey] = $countMap
            $responseTextByLang[$langKey] = Format-CountMap -Map $countMap
        }

        $dbText = '-'
        if ($countChecks.Count -gt 0) {
            $dbText = 'SKIP'
        }

        if (!$SkipDb -and $countChecks.Count -gt 0) {
            $dbMap = [ordered]@{}
            foreach ($check in $countChecks) {
                $paramsSpec = [pscustomobject]@{}
                if ($check.PSObject.Properties['params']) {
                    $paramsSpec = $check.params
                } elseif ($null -ne $Case.equiv_sql -and $Case.equiv_sql.PSObject.Properties['params']) {
                    $paramsSpec = $Case.equiv_sql.params
                }

                $dbCount = Invoke-DbScalar -SqlSpec $check.sql -ParamsSpec $paramsSpec -Context $baseContext -DbRunner $DbRunner
                $dbMap[[string]$check.name] = $dbCount
            }
            $dbText = Format-CountMap -Map $dbMap

            foreach ($langKey in $responseCountsByLang.Keys) {
                $countMap = $responseCountsByLang[$langKey]
                foreach ($entry in $dbMap.GetEnumerator()) {
                    if ($countMap.Contains($entry.Key) -and [int]$countMap[$entry.Key] -ne [int]$entry.Value) {
                        $issues += "$langKey count mismatch $($entry.Key) api=$($countMap[$entry.Key]) db=$($entry.Value)"
                    }
                }
            }
        }

        if ($langTypeParity -and $countChecks.Count -gt 0 -and $responseCountsByLang.ContainsKey('zh_TW') -and $responseCountsByLang.ContainsKey('en_US')) {
            $zhMap = $responseCountsByLang['zh_TW']
            $enMap = $responseCountsByLang['en_US']
            foreach ($entry in $zhMap.GetEnumerator()) {
                if ($enMap.Contains($entry.Key) -and [int]$entry.Value -ne [int]$enMap[$entry.Key]) {
                    $issues += "langType count mismatch $($entry.Key) zh_TW=$($entry.Value) en_US=$($enMap[$entry.Key])"
                }
            }
        }

        $zh = '-'
        $en = '-'
        if ($langTypeParity) {
            if ($responseTextByLang.ContainsKey('zh_TW')) { $zh = $responseTextByLang['zh_TW'] }
            if ($responseTextByLang.ContainsKey('en_US')) { $en = $responseTextByLang['en_US'] }
        } elseif ($responseTextByLang.ContainsKey('_single')) {
            $zh = $responseTextByLang['_single']
        }

        if ($issues.Count -gt 0) {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh $zh -En $en -Db $dbText -Category 'assertion' -Status 'FAIL' -Detail ($issues -join '; ') -DumpFile $null
        } else {
            Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh $zh -En $en -Db $dbText -Category '-' -Status 'PASS' -Detail 'response contract and DB counts match' -DumpFile $null
        }
    } catch {
        $result = ConvertTo-ResultStatus -ErrorRecord $_
        Add-Result -Rows $Rows -Id $Case.id -Role $AuthContext.role -Fixture $fixture -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Category $result.category -Status $result.status -Detail $result.detail -DumpFile $null
    }
}

function ConvertTo-MarkdownTable {
    param([System.Collections.Generic.List[object]]$Rows)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('| id | role | fixture | endpoint | zh_TW | en_US | db | category | status | detail | dump |') | Out-Null
    $lines.Add('|---|---:|---|---|---:|---:|---:|---|---|---|---|') | Out-Null
    foreach ($row in $Rows) {
        $detail = ([string]$row.detail).Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
        $dump = ([string]$row.dump).Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
        $fixture = ([string]$row.fixture).Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
        $lines.Add("| $($row.id) | $($row.role) | $fixture | $($row.endpoint) | $($row.zh_TW) | $($row.en_US) | $($row.db) | $($row.category) | $($row.status) | $detail | $dump |") | Out-Null
    }
    return ($lines -join [Environment]::NewLine)
}

function Test-ManifestOnly {
    param(
        [object]$Manifest,
        [hashtable]$BaseContext
    )

    foreach ($case in $Manifest.cases) {
        if ($case.assert.kind -eq 'langtype_count' -or ($case.assert.kind -eq 'response_contract' -and $case.assert.PSObject.Properties['langTypeParity'] -and [bool]$case.assert.langTypeParity)) {
            foreach ($langType in $Manifest.langTypes) {
                $context = $BaseContext.Clone()
                $context.langType = [string]$langType
                $null = Resolve-TokenValue -Value $case.params -Context $context
            }
        } else {
            $null = Resolve-TokenValue -Value $case.params -Context $BaseContext
        }

        $sqlProp = $case.equiv_sql.PSObject.Properties['sql']
        $rowCountSqlProp = $case.equiv_sql.PSObject.Properties['row_count_sql']
        $optionCountSqlProp = $case.equiv_sql.PSObject.Properties['option_count_sql']

        if ($null -ne $sqlProp) {
            $params = Resolve-TokenValue -Value $case.equiv_sql.params -Context $BaseContext
            $sql = Expand-SqlParams -Sql (Get-SqlText -SqlSpec $sqlProp.Value) -Params $params
            Assert-ReadOnlySql -Sql $sql
        }
        if ($null -ne $rowCountSqlProp) {
            $params = Resolve-TokenValue -Value $case.equiv_sql.params -Context $BaseContext
            $sql = Expand-SqlParams -Sql (Get-SqlText -SqlSpec $rowCountSqlProp.Value) -Params $params
            Assert-ReadOnlySql -Sql $sql
        }
        if ($null -ne $optionCountSqlProp) {
            $params = Resolve-TokenValue -Value $case.equiv_sql.params -Context $BaseContext
            $sql = Expand-SqlParams -Sql (Get-SqlText -SqlSpec $optionCountSqlProp.Value) -Params $params
            Assert-ReadOnlySql -Sql $sql
        }
        if ($case.assert.kind -eq 'response_contract' -and $case.assert.PSObject.Properties['countChecks']) {
            foreach ($check in @($case.assert.countChecks)) {
                if (-not $check.PSObject.Properties['sql']) {
                    continue
                }
                $paramsSpec = [pscustomobject]@{}
                if ($check.PSObject.Properties['params']) {
                    $paramsSpec = $check.params
                } elseif ($case.equiv_sql.PSObject.Properties['params']) {
                    $paramsSpec = $case.equiv_sql.params
                }
                $params = Resolve-TokenValue -Value $paramsSpec -Context $BaseContext
                $sql = Expand-SqlParams -Sql (Get-SqlText -SqlSpec $check.sql) -Params $params
                Assert-ReadOnlySql -Sql $sql
            }
        }
    }

    "manifest validation ok: $($Manifest.cases.Count) cases"
}

$manifestPathFull = [System.IO.Path]::GetFullPath($ManifestPath)
$manifest = Get-Content -Path $manifestPathFull -Raw -Encoding UTF8 | ConvertFrom-Json
$validationContext = @{
    jwt = New-ValidationJwtClaims
    langType = $null
}
$baseUrl = if (![string]::IsNullOrWhiteSpace($BaseUrl)) { $BaseUrl } else { Resolve-TokenValue -Value $manifest.baseUrl -Context $validationContext }
$dbRunner = $null
if (!$SkipDb -and !$ValidateOnly) {
    $dbRunner = Resolve-TokenValue -Value $manifest.dbRunner -Context $validationContext
}

if ($ValidateOnly) {
    Test-ManifestOnly -Manifest $manifest -BaseContext $validationContext
    exit 0
}

$results = New-Object 'System.Collections.Generic.List[object]'
$tokenCache = @{}
foreach ($case in $manifest.cases) {
    $authContext = $null
    try {
        $authContext = Get-CaseContext -Case $case -Manifest $manifest -BaseUrl $baseUrl -TokenCache $tokenCache
    } catch {
        $result = ConvertTo-ResultStatus -ErrorRecord $_
        Add-Result -Rows $results -Id $case.id -Role (Get-CaseRequiredRole -Case $case) -Fixture '-' -Endpoint $case.endpoint -Zh '-' -En '-' -Db '-' -Category $result.category -Status $result.status -Detail $result.detail -DumpFile $null
        continue
    }

    switch ([string]$case.assert.kind) {
        'langtype_count' {
            Test-LangTypeCase -Case $case -Manifest $manifest -BaseUrl $baseUrl -AuthContext $authContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        'row_equals' {
            Test-RowEqualsCase -Case $case -BaseUrl $baseUrl -AuthContext $authContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        'empty_and_options' {
            Test-EmptyAndOptionsCase -Case $case -BaseUrl $baseUrl -AuthContext $authContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        'response_contract' {
            Test-ResponseContractCase -Case $case -Manifest $manifest -BaseUrl $baseUrl -AuthContext $authContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        default {
            Add-Result -Rows $results -Id $case.id -Role $authContext.role -Fixture '-' -Endpoint $case.endpoint -Zh '-' -En '-' -Db '-' -Category 'assertion' -Status 'FAIL' -Detail "Unsupported assert kind: $($case.assert.kind)" -DumpFile $null
        }
    }
}

$table = ConvertTo-MarkdownTable -Rows $results
if (![string]::IsNullOrWhiteSpace($OutFile)) {
    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($OutFile), $table + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
}
$table

if (@($results | Where-Object { $_.status -eq 'ENV_NOT_READY' }).Count -gt 0) {
    exit 3
}
if (@($results | Where-Object { $_.status -eq 'AUTH_FAILED' }).Count -gt 0) {
    exit 2
}
if (@($results | Where-Object { $_.status -eq 'FAIL' }).Count -gt 0) {
    exit 1
}
