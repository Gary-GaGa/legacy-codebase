param(
    [string]$Profile = "epro",
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\docs\build-tasks\phase-v-api-selfverify-harness-v1.json"),
    [string]$OutFile = (Join-Path $PSScriptRoot "..\docs\verification\phase-v-api-selfverify-report.md"),
    [string]$ResponseDumpDir = (Join-Path $PSScriptRoot "..\docs\verification\phase-v-api-selfverify-responses"),
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-JsonPathValue {
    param(
        [AllowNull()][object]$Object,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Object
    }

    $current = $Object
    foreach ($part in $Path.Split(".")) {
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

function ConvertFrom-JwtPayload {
    param([Parameter(Mandatory = $true)][string]$Jwt)

    $parts = $Jwt.Split(".")
    if ($parts.Count -lt 2) {
        throw "AUTH_FAILED:auth:token is not JWT-shaped"
    }

    $payload = $parts[1].Replace("-", "+").Replace("_", "/")
    switch ($payload.Length % 4) {
        2 { $payload += "==" }
        3 { $payload += "=" }
        1 { throw "AUTH_FAILED:auth:JWT payload has invalid base64url length" }
    }

    $json = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
    return $json | ConvertFrom-Json
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
    return ([regex]::Replace($Role, "[^A-Za-z0-9]", "_")).ToUpperInvariant()
}

function Get-RequiredRoles {
    param([object]$Manifest)

    $roles = @()
    foreach ($case in $Manifest.cases) {
        if ($null -ne $case.auth -and $null -ne $case.auth.PSObject.Properties["requiredRole"]) {
            $roles += [string]$case.auth.requiredRole
        }
    }
    return @($roles | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
}

function Invoke-RoleLogin {
    param(
        [string]$BaseUrl,
        [string]$Role,
        [string]$EmpId,
        [object]$Manifest
    )

    $endpoint = "/epl-ut-login"
    if ($null -ne $Manifest.auth -and $null -ne $Manifest.auth.PSObject.Properties["loginEndpoint"]) {
        $endpoint = [string]$Manifest.auth.loginEndpoint
    }
    $tokenPath = "data.eproToken"
    if ($null -ne $Manifest.auth -and $null -ne $Manifest.auth.PSObject.Properties["tokenPath"]) {
        $tokenPath = [string]$Manifest.auth.tokenPath
    }

    $url = $BaseUrl.TrimEnd("/") + "/" + $endpoint.TrimStart("/")
    $bodyFile = New-TemporaryFile
    $outFile = New-TemporaryFile
    try {
        $body = @{ empId = $EmpId } | ConvertTo-Json -Compress
        [System.IO.File]::WriteAllText($bodyFile.FullName, $body, [System.Text.UTF8Encoding]::new($false))
        $statusRaw = & curl.exe -sS -o $outFile.FullName -w "%{http_code}" -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data-binary "@$($bodyFile.FullName)" $url 2>&1
        $curlExitCode = $LASTEXITCODE
        if ($curlExitCode -ne 0) {
            throw "ENV_NOT_READY:infra:login curl failed for role $Role with exit $curlExitCode"
        }

        $status = [int]([string]$statusRaw).Trim()
        $raw = Get-Content -Path $outFile.FullName -Raw -Encoding UTF8
        $json = if ([string]::IsNullOrWhiteSpace($raw)) { $null } else { $raw | ConvertFrom-Json }
        $code = Get-JsonPathValue -Object $json -Path "code"
        if ($status -eq 401 -or $status -eq 403 -or ([string]$code -match "^E40[1-9]$|^E49[78]$")) {
            throw "AUTH_FAILED:auth:login failed for role $Role with HTTP $status"
        }
        if ($status -lt 200 -or $status -ge 300 -or [string]$code -ne "0000") {
            throw "ENV_NOT_READY:infra:login endpoint not serviceable for role $Role; HTTP $status code=$code"
        }

        $jwt = Get-JsonPathValue -Object $json -Path $tokenPath
        if ([string]::IsNullOrWhiteSpace($jwt)) {
            throw "AUTH_FAILED:auth:login response missing token for role $Role"
        }
        $claims = ConvertFrom-JwtPayload -Jwt $jwt
        if ([string]$claims.roleId -ne $Role) {
            throw "AUTH_FAILED:auth:login token role mismatch for role $Role"
        }
        return $jwt
    } finally {
        Remove-Item -LiteralPath $bodyFile.FullName -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $outFile.FullName -Force -ErrorAction SilentlyContinue
    }
}

function Resolve-RoleJwt {
    param(
        [string]$Role,
        [string]$BaseUrl,
        [object]$Manifest
    )

    $suffix = Get-RoleEnvSuffix -Role $Role
    foreach ($name in @("PHASE_V_JWT_ROLE_$suffix", "PHASE_V_ROLE_${suffix}_JWT")) {
        $jwt = Get-OptionalEnv -Name $name
        if ($null -ne $jwt) {
            $claims = ConvertFrom-JwtPayload -Jwt $jwt
            if ([string]$claims.roleId -ne $Role) {
                throw "AUTH_FAILED:auth:env token $name role mismatch for role $Role"
            }
            return $jwt
        }
    }

    foreach ($name in @("PHASE_V_ROLE_${suffix}_EMP_ID", "PHASE_V_EMP_ID_ROLE_$suffix")) {
        $empId = Get-OptionalEnv -Name $name
        if ($null -ne $empId) {
            return Invoke-RoleLogin -BaseUrl $BaseUrl -Role $Role -EmpId $empId -Manifest $Manifest
        }
    }

    throw "AUTH_FAILED:auth:missing JWT or empId env for role $Role"
}

function Export-RoleJwtToEnv {
    param(
        [string]$Role,
        [string]$Jwt
    )

    $suffix = Get-RoleEnvSuffix -Role $Role
    [Environment]::SetEnvironmentVariable("PHASE_V_JWT_ROLE_$suffix", $Jwt, "Process")
}

function Invoke-ServiceabilitySmoke {
    param(
        [string]$BaseUrl,
        [string]$Jwt
    )

    $url = $BaseUrl.TrimEnd("/") + "/epl-list-casedistribution"
    $bodyFile = New-TemporaryFile
    $outFile = New-TemporaryFile
    try {
        $body = @{
            page = 1
            size = 1
            applicationNo = $null
            langType = "zh_TW"
        } | ConvertTo-Json -Compress
        [System.IO.File]::WriteAllText($bodyFile.FullName, $body, [System.Text.UTF8Encoding]::new($false))
        $statusRaw = & curl.exe -sS -o $outFile.FullName -w "%{http_code}" -X POST -H "Authorization: Bearer $Jwt" -H "Accept: application/json" -H "Content-Type: application/json" --data-binary "@$($bodyFile.FullName)" $url 2>&1
        $curlExitCode = $LASTEXITCODE
        if ($curlExitCode -ne 0) {
            throw "ENV_NOT_READY:infra:serviceability smoke curl failed with exit $curlExitCode"
        }

        $status = [int]([string]$statusRaw).Trim()
        $raw = Get-Content -Path $outFile.FullName -Raw -Encoding UTF8
        $json = if ([string]::IsNullOrWhiteSpace($raw)) { $null } else { $raw | ConvertFrom-Json }
        $code = Get-JsonPathValue -Object $json -Path "code"
        if ($status -eq 401 -or $status -eq 403) {
            throw "AUTH_FAILED:auth:serviceability smoke returned HTTP $status"
        }
        if ($status -ne 200 -or [string]$code -ne "0000") {
            throw "ENV_NOT_READY:infra:serviceability smoke returned HTTP $status code=$code"
        }
        return "PASS HTTP 200 code=0000 endpoint=/epl-list-casedistribution"
    } finally {
        Remove-Item -LiteralPath $bodyFile.FullName -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $outFile.FullName -Force -ErrorAction SilentlyContinue
    }
}

function Get-ListenerCount {
    param([int[]]$Ports)
    $count = 0
    foreach ($port in $Ports) {
        $count += @(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue).Count
    }
    return $count
}

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$localEnv = Join-Path $PSScriptRoot "local-env.ps1"
$harness = Join-Path $PSScriptRoot "phase-v-api-selfverify.ps1"
$descriptorPath = Join-Path $repoRoot (".local-env\{0}\descriptor.json" -f $Profile)
$manifestFullPath = [System.IO.Path]::GetFullPath($ManifestPath)
$outFullPath = [System.IO.Path]::GetFullPath($OutFile)
$dumpFullPath = [System.IO.Path]::GetFullPath($ResponseDumpDir)
$exitCode = 3
$downFailed = $false

try {
    & $localEnv -Action up -Profile $Profile -SkipBuild:$SkipBuild | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "ENV_NOT_READY:infra:local-env up failed with exit $LASTEXITCODE"
    }

    if (-not (Test-Path -LiteralPath $descriptorPath)) {
        throw "ENV_NOT_READY:infra:local-env descriptor missing"
    }
    $descriptor = Get-Content -Path $descriptorPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([int]$descriptor.schemaVersion -ne 1 -or [string]$descriptor.status -ne "ready") {
        throw "ENV_NOT_READY:infra:descriptor is not ready"
    }
    $baseUrl = [string]$descriptor.services.be.url
    if ([string]::IsNullOrWhiteSpace($baseUrl)) {
        throw "ENV_NOT_READY:infra:descriptor missing services.be.url"
    }

    [Environment]::SetEnvironmentVariable("PHASE_V_BASE_URL", $baseUrl, "Process")

    $manifest = Get-Content -Path $manifestFullPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $roleTokens = @{}
    foreach ($role in (Get-RequiredRoles -Manifest $manifest)) {
        $jwt = Resolve-RoleJwt -Role $role -BaseUrl $baseUrl -Manifest $manifest
        $roleTokens[$role] = $jwt
        Export-RoleJwtToEnv -Role $role -Jwt $jwt
    }

    if (-not $roleTokens.ContainsKey("405")) {
        throw "AUTH_FAILED:auth:serviceability smoke requires role 405 token"
    }
    $smoke = Invoke-ServiceabilitySmoke -BaseUrl $baseUrl -Jwt $roleTokens["405"]
    Write-Host "serviceability smoke: $smoke"

    & $harness -BaseUrl $baseUrl -ManifestPath $manifestFullPath -OutFile $outFullPath -ResponseDumpDir $dumpFullPath
    $exitCode = $LASTEXITCODE
} catch {
    $message = [string]$_.Exception.Message
    Write-Host $message
    if ($message -match "^AUTH_FAILED:") {
        $exitCode = 2
    } else {
        $exitCode = 3
    }
} finally {
    try {
        & $localEnv -Action down -Profile $Profile | Out-Host
        if ($LASTEXITCODE -ne 0) {
            $downFailed = $true
        }
    } catch {
        $downFailed = $true
        Write-Host ("local-env down threw: {0}" -f $_.Exception.Message)
    }

    if ((Get-ListenerCount -Ports @(5500, 4200)) -ne 0) {
        $downFailed = $true
        Write-Host "ENV_NOT_READY:infra:ports 5500/4200 still have listeners after down"
    }
}

if ($downFailed) {
    exit 3
}
exit $exitCode
