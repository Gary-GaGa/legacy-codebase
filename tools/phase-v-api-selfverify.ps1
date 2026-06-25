param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\docs\build-tasks\phase-v-api-selfverify-manifest-v1.json'),
    [switch]$SkipDb,
    [switch]$ValidateOnly,
    [string]$OutFile
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
    return $json | ConvertFrom-Json
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
            Set-Content -Path $bodyFile.FullName -Value $jsonBody -Encoding UTF8
            $args += @('-H', 'Content-Type: application/json', '--data-binary', "@$($bodyFile.FullName)")
        } else {
            throw "Unsupported contentType: $($resolvedParams.contentType)"
        }

        $statusRaw = & curl.exe @args $url
        $status = [int]([string]$statusRaw).Trim()
        $raw = Get-Content -Path $outFile.FullName -Raw -Encoding UTF8
        $json = $null
        if (![string]::IsNullOrWhiteSpace($raw)) {
            $json = $raw | ConvertFrom-Json
        }

        if ($status -lt 200 -or $status -ge 300) {
            $snippet = ($raw -replace '\s+', ' ')
            if ($snippet.Length -gt 240) {
                $snippet = $snippet.Substring(0, 240)
            }
            throw "HTTP $status from $($Case.endpoint): $snippet"
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
        Set-Content -Path $sqlFile.FullName -Value $content -Encoding UTF8
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
    return $raw | ConvertFrom-Json
}

function Add-Result {
    param(
        [System.Collections.Generic.List[object]]$Rows,
        [string]$Id,
        [string]$Endpoint,
        [string]$Zh,
        [string]$En,
        [string]$Db,
        [string]$Status,
        [string]$Detail
    )

    $Rows.Add([pscustomobject]@{
        id = $Id
        endpoint = $Endpoint
        zh_TW = $Zh
        en_US = $En
        db = $Db
        status = $Status
        detail = $Detail
    }) | Out-Null
}

function Test-LangTypeCase {
    param(
        [object]$Case,
        [object]$Manifest,
        [string]$BaseUrl,
        [string]$Jwt,
        [hashtable]$BaseContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    try {
        $counts = @{}
        foreach ($langType in $Manifest.langTypes) {
            $context = $BaseContext.Clone()
            $context.langType = [string]$langType
            $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $Jwt -Context $context
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
            $context = $BaseContext.Clone()
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

        Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh $zh -En $en -Db $dbText -Status $status -Detail ($details -join '; ')
    } catch {
        Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Status 'FAIL' -Detail $_.Exception.Message
    }
}

function Test-RowEqualsCase {
    param(
        [object]$Case,
        [string]$BaseUrl,
        [string]$Jwt,
        [hashtable]$BaseContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    try {
        $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $Jwt -Context $BaseContext
        $apiData = Get-JsonPathValue -Object $api.Body -Path $Case.response.dataPath
        if ($null -eq $apiData) {
            throw "Response dataPath returned null: $($Case.response.dataPath)"
        }

        if ($SkipDb) {
            Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db 'SKIP' -Status 'PASS' -Detail 'API 2xx; DB skipped'
            return
        }

        $dbRow = Invoke-DbJsonRow -SqlSpec $Case.equiv_sql.sql -ParamsSpec $Case.equiv_sql.params -Context $BaseContext -DbRunner $DbRunner
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
            Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db 'row' -Status 'FAIL' -Detail ($diffs -join '; ')
        } else {
            Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db 'row' -Status 'PASS' -Detail 'API fields match DB row'
        }
    } catch {
        Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Status 'FAIL' -Detail $_.Exception.Message
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
        return $Value.PSObject.Properties.Count
    }
    return 1
}

function Test-EmptyAndOptionsCase {
    param(
        [object]$Case,
        [string]$BaseUrl,
        [string]$Jwt,
        [hashtable]$BaseContext,
        [string]$DbRunner,
        [switch]$SkipDb,
        [System.Collections.Generic.List[object]]$Rows
    )

    try {
        $api = Invoke-ApiCase -Case $Case -BaseUrl $BaseUrl -Jwt $Jwt -Context $BaseContext
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
            $rowCount = Invoke-DbScalar -SqlSpec $Case.equiv_sql.row_count_sql -ParamsSpec $Case.equiv_sql.params -Context $BaseContext -DbRunner $DbRunner
            $optionCount = Invoke-DbScalar -SqlSpec $Case.equiv_sql.option_count_sql -ParamsSpec $Case.equiv_sql.params -Context $BaseContext -DbRunner $DbRunner
            $dbText = "row=$rowCount options=$optionCount"
            if ($rowCount -ne 0) {
                $issues += "TB_REVISED_ITEM count is $rowCount, expected 0"
            }

            $optionValue = Get-JsonPathValue -Object $apiData -Path $Case.assert.optionPath
            $apiOptionCount = Get-ObjectMemberCount -Value $optionValue
            if ($null -eq $apiOptionCount) {
                $issues += "response missing $($Case.assert.optionPath)"
            } elseif ($apiOptionCount -ne $optionCount) {
                $issues += "option count api=$apiOptionCount db=$optionCount"
            }

            $sizeValue = Get-JsonPathValue -Object $apiData -Path $Case.assert.optionSizePath
            if ($null -ne $sizeValue -and [int]$sizeValue -ne $optionCount) {
                $issues += "option size api=$sizeValue db=$optionCount"
            }
        }

        if ($issues.Count -gt 0) {
            Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db $dbText -Status 'FAIL' -Detail ($issues -join '; ')
        } else {
            Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db $dbText -Status 'PASS' -Detail 'empty item fields and option count match'
        }
    } catch {
        Add-Result -Rows $Rows -Id $Case.id -Endpoint $Case.endpoint -Zh '-' -En '-' -Db '-' -Status 'FAIL' -Detail $_.Exception.Message
    }
}

function ConvertTo-MarkdownTable {
    param([System.Collections.Generic.List[object]]$Rows)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('| id | endpoint | zh_TW | en_US | db | status | detail |') | Out-Null
    $lines.Add('|---|---|---:|---:|---:|---|---|') | Out-Null
    foreach ($row in $Rows) {
        $detail = ([string]$row.detail).Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
        $lines.Add("| $($row.id) | $($row.endpoint) | $($row.zh_TW) | $($row.en_US) | $($row.db) | $($row.status) | $detail |") | Out-Null
    }
    return ($lines -join [Environment]::NewLine)
}

function Test-ManifestOnly {
    param(
        [object]$Manifest,
        [hashtable]$BaseContext
    )

    foreach ($case in $Manifest.cases) {
        if ($case.assert.kind -eq 'langtype_count') {
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
    }

    "manifest validation ok: $($Manifest.cases.Count) cases"
}

$manifest = Get-Content -Path $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$jwt = Resolve-TokenValue -Value $manifest.jwt -Context @{ jwt = $null; langType = $null }
$jwtClaims = ConvertFrom-JwtPayload -Jwt $jwt
$baseContext = @{
    jwt = $jwtClaims
    langType = $null
}
$baseUrl = Resolve-TokenValue -Value $manifest.baseUrl -Context $baseContext
$dbRunner = $null
if (!$SkipDb -and !$ValidateOnly) {
    $dbRunner = Resolve-TokenValue -Value $manifest.dbRunner -Context $baseContext
}

if ($ValidateOnly) {
    Test-ManifestOnly -Manifest $manifest -BaseContext $baseContext
    exit 0
}

$results = New-Object 'System.Collections.Generic.List[object]'
foreach ($case in $manifest.cases) {
    switch ([string]$case.assert.kind) {
        'langtype_count' {
            Test-LangTypeCase -Case $case -Manifest $manifest -BaseUrl $baseUrl -Jwt $jwt -BaseContext $baseContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        'row_equals' {
            Test-RowEqualsCase -Case $case -BaseUrl $baseUrl -Jwt $jwt -BaseContext $baseContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        'empty_and_options' {
            Test-EmptyAndOptionsCase -Case $case -BaseUrl $baseUrl -Jwt $jwt -BaseContext $baseContext -DbRunner $dbRunner -SkipDb:$SkipDb -Rows $results
        }
        default {
            Add-Result -Rows $results -Id $case.id -Endpoint $case.endpoint -Zh '-' -En '-' -Db '-' -Status 'FAIL' -Detail "Unsupported assert kind: $($case.assert.kind)"
        }
    }
}

$table = ConvertTo-MarkdownTable -Rows $results
if (![string]::IsNullOrWhiteSpace($OutFile)) {
    Set-Content -Path $OutFile -Value $table -Encoding UTF8
}
$table

if (@($results | Where-Object { $_.status -eq 'FAIL' }).Count -gt 0) {
    exit 1
}
