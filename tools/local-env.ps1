param(
    [ValidateSet("up", "down", "status")]
    [string] $Action = "status",

    [string] $Profile = "epro",

    [switch] $SkipBuild,

    [switch] $Force
)

$ErrorActionPreference = "Stop"

$Script:SchemaVersion = 1
$Script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$Script:RunRoot = Join-Path $Script:RepoRoot ".local-env"
$Script:ProfileRunRoot = Join-Path $Script:RunRoot $Profile
$Script:LogRoot = Join-Path $Script:ProfileRunRoot "logs"
$Script:WrapperRoot = Join-Path $Script:ProfileRunRoot "wrappers"
$Script:DescriptorPath = Join-Path $Script:ProfileRunRoot "descriptor.json"
$Script:PidfilePath = Join-Path $Script:ProfileRunRoot "pids.json"
$Script:OwnershipPath = Join-Path $Script:ProfileRunRoot "ownership.json"
$Script:ManagerLog = Join-Path $Script:LogRoot "manager.log"

function Ensure-Directory {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Get-RepoRelativePath {
    param([string] $Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $root = $Script:RepoRoot.TrimEnd("\", "/")
    if ($fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($root.Length).TrimStart("\", "/")
    }
    return $fullPath
}

function Write-ManagerLog {
    param([string] $Message)
    Ensure-Directory $Script:LogRoot
    $line = "{0} {1}" -f (Get-Date).ToString("o"), $Message
    Add-Content -Path $Script:ManagerLog -Encoding UTF8 -Value $line
}

function Write-Info {
    param([string] $Message)
    Write-Host $Message
    Write-ManagerLog $Message
}

function Write-JsonOutput {
    param([object] $Value)
    [Console]::Out.WriteLine(($Value | ConvertTo-Json -Depth 20))
}

function Mask-SensitiveText {
    param([AllowNull()][string] $Text)
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $Text
    }
    $masked = $Text
    $masked = $masked -replace '(?i)(password|passwd|pwd|secret|token|authorization)(\s*[:=]\s*)("[^"]*"|''[^'']*''|[^\s;,]+)', '$1$2***'
    $masked = $masked -replace '(?i)(Bearer\s+)[A-Za-z0-9._~+/-]+=*', '$1***'
    return $masked
}

function ConvertTo-PsSingleQuoted {
    param([AllowNull()][string] $Value)
    if ($null -eq $Value) {
        return "''"
    }
    return "'" + ($Value -replace "'", "''") + "'"
}

function ConvertTo-StringArrayLiteral {
    param([string[]] $Items)
    if ($null -eq $Items -or $Items.Count -eq 0) {
        return "@()"
    }
    $quoted = @()
    foreach ($item in $Items) {
        $quoted += (ConvertTo-PsSingleQuoted $item)
    }
    return "@(" + ($quoted -join ", ") + ")"
}

function Get-Node16Root {
    $candidates = @()

    foreach ($envName in @("NODE16_ROOT", "NODE_ROOT")) {
        $value = [Environment]::GetEnvironmentVariable($envName, "Process")
        if (![string]::IsNullOrWhiteSpace($value)) {
            $candidates += $value
        }
    }

    $override = Get-ProfileOverride
    if ($null -ne $override) {
        if (Has-Property $override "node16Root") {
            $candidates += [string] $override.node16Root
        }
        if ((Has-Property $override "tools") -and (Has-Property $override.tools "node16Root")) {
            $candidates += [string] $override.tools.node16Root
        }
    }

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        $nodeExe = Join-Path $candidate "node.exe"
        if (Test-Path -LiteralPath $nodeExe) {
            return ([System.IO.Path]::GetFullPath($candidate))
        }
    }

    $pathNode = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($pathNode -and (Test-Path -LiteralPath $pathNode.Source)) {
        return (Split-Path -Parent $pathNode.Source)
    }
    return $null
}

function Get-NormalizedPath {
    param([string[]] $Prepend)

    $raw = [Environment]::GetEnvironmentVariable("Path", "Process")
    if ([string]::IsNullOrWhiteSpace($raw)) {
        $raw = [Environment]::GetEnvironmentVariable("PATH", "Process")
    }

    $seen = @{}
    $parts = @()
    foreach ($entry in @($Prepend) + ($raw -split ";")) {
        if ([string]::IsNullOrWhiteSpace($entry)) {
            continue
        }
        $trimmed = $entry.Trim()
        $key = $trimmed.ToLowerInvariant()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $parts += $trimmed
        }
    }
    return ($parts -join ";")
}

function Set-NormalizedProcessPath {
    param([string[]] $Prepend)
    $pathValue = Get-NormalizedPath -Prepend $Prepend
    [Environment]::SetEnvironmentVariable("Path", $pathValue, "Process")
    [Environment]::SetEnvironmentVariable("PATH", $pathValue, "Process")
    $env:Path = $pathValue
}

function New-EproConfig {
    $mvnCommand = Get-Command mvn.cmd -ErrorAction SilentlyContinue
    $mvnExe = if ($mvnCommand) { $mvnCommand.Source } else { "mvn.cmd" }
    $nodeRoot = Get-Node16Root
    $nodeExe = if ($nodeRoot) { Join-Path $nodeRoot "node.exe" } else { "node.exe" }
    $ngJs = Join-Path $Script:RepoRoot "frontend\node_modules\@angular\cli\bin\ng.js"
    $fePrepend = @()
    if ($nodeRoot) {
        $fePrepend += $nodeRoot
        $fePrepend += (Join-Path $nodeRoot "node_modules\corepack\shims")
    }
    $fePrepend += (Join-Path $Script:RepoRoot "frontend\node_modules\.bin")

    return [ordered]@{
        schemaVersion = $Script:SchemaVersion
        profile = $Profile
        services = [ordered]@{
            be = [ordered]@{
                name = "be"
                root = (Join-Path $Script:RepoRoot "backend")
                port = 5500
                url = "http://localhost:5500"
                healthUrl = "http://localhost:5500/actuator/info"
                readyKind = "springHealth"
                readyTimeoutSec = 180
                buildTimeoutSec = 900
                buildSteps = @(
                    [ordered]@{
                        name = "be-build"
                        file = $mvnExe
                        args = @("clean", "package", "-Dmaven.test.skip=true")
                        log = (Join-Path $Script:LogRoot "be-build.log")
                        timeoutSec = 900
                    }
                )
                start = [ordered]@{
                    file = $mvnExe
                    args = @(
                        "-Dlocal.env.repoRoot=$Script:RepoRoot",
                        "spring-boot:run",
                        "-Dspring-boot.run.arguments=--management.endpoints.web.exposure.include=health,info --management.endpoint.health.show-details=never --management.info.env.enabled=true --info.status=UP"
                    )
                }
                env = [ordered]@{}
                prependPath = @()
                log = (Join-Path $Script:LogRoot "be.log")
            }
            fe = [ordered]@{
                name = "fe"
                root = (Join-Path $Script:RepoRoot "frontend")
                port = 4200
                url = "http://localhost:4200"
                healthUrl = "http://localhost:4200"
                readyKind = "angularLog"
                readyTimeoutSec = 300
                buildTimeoutSec = 900
                buildSteps = @(
                    [ordered]@{
                        name = "fe-build"
                        file = $nodeExe
                        args = @($ngJs, "build")
                        log = (Join-Path $Script:LogRoot "fe-build.log")
                        timeoutSec = 900
                    }
                )
                start = [ordered]@{
                    file = $nodeExe
                    args = @($ngJs, "serve", "--host", "0.0.0.0", "--port", "4200")
                }
                env = [ordered]@{}
                prependPath = $fePrepend
                log = (Join-Path $Script:LogRoot "fe.log")
            }
        }
    }
}

function Has-Property {
    param([object] $Object, [string] $Name)
    return ($null -ne $Object -and ($Object.PSObject.Properties.Name -contains $Name))
}

function Copy-JsonPropertiesToMap {
    param([object] $Source, [System.Collections.IDictionary] $Target)
    if ($null -eq $Source) {
        return
    }
    foreach ($property in $Source.PSObject.Properties) {
        $Target[$property.Name] = [string] $property.Value
    }
}

function Apply-ServiceOverride {
    param([System.Collections.IDictionary] $Service, [object] $Override)
    if ($null -eq $Override) {
        return
    }
    if (Has-Property $Override "readyTimeoutSec") {
        $Service.readyTimeoutSec = [int] $Override.readyTimeoutSec
    }
    if (Has-Property $Override "buildTimeoutSec") {
        $Service.buildTimeoutSec = [int] $Override.buildTimeoutSec
        foreach ($step in $Service.buildSteps) {
            $step.timeoutSec = [int] $Override.buildTimeoutSec
        }
    }
    if (Has-Property $Override "env") {
        Copy-JsonPropertiesToMap -Source $Override.env -Target $Service.env
    }
    if (Has-Property $Override "db") {
        $db = $Override.db
        if (Has-Property $db "url") {
            $Service.env["SPRING_DATASOURCE_URL"] = [string] $db.url
        }
        if (Has-Property $db "username") {
            $Service.env["SPRING_DATASOURCE_USERNAME"] = [string] $db.username
        }
        if (Has-Property $db "password") {
            $Service.env["SPRING_DATASOURCE_PASSWORD"] = [string] $db.password
        }
    }
}

function Get-ProfileOverride {
    $profileFile = Join-Path $PSScriptRoot ("local-env.{0}.local.json" -f $Profile)
    if (Test-Path -LiteralPath $profileFile) {
        return (Get-Content -Raw -Encoding UTF8 -Path $profileFile | ConvertFrom-Json)
    }

    $profilesFile = Join-Path $PSScriptRoot "local-env.profiles.local.json"
    if (Test-Path -LiteralPath $profilesFile) {
        $allProfiles = Get-Content -Raw -Encoding UTF8 -Path $profilesFile | ConvertFrom-Json
        if (Has-Property $allProfiles "profiles") {
            $profileObject = $allProfiles.profiles.PSObject.Properties[$Profile]
            if ($null -ne $profileObject) {
                return $profileObject.Value
            }
        }
    }

    return $null
}

function Get-Config {
    $config = New-EproConfig
    $override = Get-ProfileOverride
    if ($Profile -ne "epro" -and $null -eq $override) {
        throw "Profile '$Profile' is not built in and no local profile override was found."
    }
    if ($null -ne $override) {
        if (Has-Property $override "env") {
            foreach ($serviceName in $config.services.Keys) {
                Copy-JsonPropertiesToMap -Source $override.env -Target $config.services[$serviceName].env
            }
        }
        if (Has-Property $override "services") {
            foreach ($serviceName in @("be", "fe")) {
                if (Has-Property $override.services $serviceName) {
                    Apply-ServiceOverride -Service $config.services[$serviceName] -Override $override.services.$serviceName
                }
            }
        }
    }
    return $config
}

function Read-JsonFile {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    return (Get-Content -Raw -Encoding UTF8 -Path $Path | ConvertFrom-Json)
}

function Write-JsonFile {
    param([string] $Path, [object] $Value)
    Ensure-Directory (Split-Path -Parent $Path)
    $json = $Value | ConvertTo-Json -Depth 20
    Set-Content -Path $Path -Encoding UTF8 -Value $json
}

function Remove-FileIfExists {
    param([string] $Path)
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        if (-not (Test-Path -LiteralPath $Path)) {
            return $true
        }
        try {
            Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
        } catch {
            Write-ManagerLog "remove failed attempt $attempt for ${Path}: $($_.Exception.Message)"
            Start-Sleep -Milliseconds 300
        }
    }
    return (-not (Test-Path -LiteralPath $Path))
}

function Get-Listeners {
    param([int] $Port)
    return @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

function Get-ProcessCommandLine {
    param([int] $ProcessId)
    try {
        $process = Get-CimInstance Win32_Process -Filter "ProcessId=$ProcessId" -ErrorAction Stop
        return [string] $process.CommandLine
    } catch {
        try {
            $process = Get-WmiObject Win32_Process -Filter "ProcessId=$ProcessId" -ErrorAction Stop
            return [string] $process.CommandLine
        } catch {
            return "<unavailable: $($_.Exception.Message)>"
        }
    }
}

function ConvertTo-ProcessTimeText {
    param([AllowNull()][object] $Value)
    if ($null -eq $Value) {
        return $null
    }
    try {
        if ($Value -is [datetime]) {
            return $Value.ToUniversalTime().ToString("o")
        }
        return ([System.Management.ManagementDateTimeConverter]::ToDateTime([string] $Value)).ToUniversalTime().ToString("o")
    } catch {
        return [string] $Value
    }
}

function Get-ProcessCreationTimeText {
    param([int] $ProcessId)
    try {
        $process = Get-CimInstance Win32_Process -Filter "ProcessId=$ProcessId" -ErrorAction Stop
        return (ConvertTo-ProcessTimeText $process.CreationDate)
    } catch {
        try {
            $process = Get-WmiObject Win32_Process -Filter "ProcessId=$ProcessId" -ErrorAction Stop
            return (ConvertTo-ProcessTimeText $process.CreationDate)
        } catch {
            return $null
        }
    }
}

function Get-KnownServicePids {
    param([string] $ServiceName)
    $known = @()
    $pidState = Read-JsonFile $Script:PidfilePath
    if ($null -ne $pidState -and (Has-Property $pidState "services") -and (Has-Property $pidState.services $ServiceName)) {
        $state = $pidState.services.$ServiceName
        if (Has-Property $state "wrapperPid" -and $null -ne $state.wrapperPid) {
            $known += [int] $state.wrapperPid
        }
        if (Has-Property $state "listenerPid" -and $null -ne $state.listenerPid) {
            $known += [int] $state.listenerPid
        }
    }
    $descriptor = Read-JsonFile $Script:DescriptorPath
    if ($null -ne $descriptor -and (Has-Property $descriptor "services") -and (Has-Property $descriptor.services $ServiceName)) {
        $service = $descriptor.services.$ServiceName
        if (Has-Property $service "pid" -and $null -ne $service.pid) {
            $known += [int] $service.pid
        }
    }
    return @($known | Select-Object -Unique)
}

function Get-OwnershipState {
    return (Read-JsonFile $Script:OwnershipPath)
}

function Get-MarkerServiceState {
    param([System.Collections.IDictionary] $Service)
    $state = Get-OwnershipState
    if ($null -eq $state -or -not (Has-Property $state "services")) {
        return $null
    }
    if ((Has-Property $state "profile") -and [string] $state.profile -ne $Profile) {
        return $null
    }
    if (-not (Has-Property $state.services $Service.name)) {
        return $null
    }
    $serviceState = $state.services.$($Service.name)
    if ((Has-Property $serviceState "port") -and [int] $serviceState.port -ne [int] $Service.port) {
        return $null
    }
    return $serviceState
}

function Test-MarkerListenerMatch {
    param([System.Collections.IDictionary] $Service, [int] $ProcessId)

    $serviceState = Get-MarkerServiceState -Service $Service
    if ($null -eq $serviceState -or -not (Has-Property $serviceState "listenerPid") -or $null -eq $serviceState.listenerPid) {
        return $false
    }
    if ([int] $serviceState.listenerPid -ne $ProcessId) {
        return $false
    }
    if (Has-Property $serviceState "listenerStartedAt" -and -not [string]::IsNullOrWhiteSpace([string] $serviceState.listenerStartedAt)) {
        $actualStartedAt = Get-ProcessCreationTimeText -ProcessId $ProcessId
        if ([string]::IsNullOrWhiteSpace($actualStartedAt) -or [string] $serviceState.listenerStartedAt -ne $actualStartedAt) {
            return $false
        }
    }
    return $true
}

function Get-ListenerOwnership {
    param([System.Collections.IDictionary] $Service, [int] $ProcessId)

    $known = Get-KnownServicePids -ServiceName $Service.name
    if ($known -contains $ProcessId) {
        return [ordered]@{ owned = $true; source = "pidfile/descriptor" }
    }

    if (Test-MarkerListenerMatch -Service $Service -ProcessId $ProcessId) {
        return [ordered]@{ owned = $true; source = "marker" }
    }

    return [ordered]@{ owned = $false; source = "none" }
}

function Wait-ProcessExit {
    param([int] $ProcessId, [int] $TimeoutSec = 10)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if ($null -eq $process) {
            return $true
        }
        Start-Sleep -Milliseconds 250
    }
    return ($null -eq (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue))
}

function Stop-Pid {
    param([int] $ProcessId, [string] $Reason)
    $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if ($null -eq $process) {
        Write-ManagerLog "pid $ProcessId already exited ($Reason)"
        return
    }
    Write-Info "stopping pid $ProcessId ($Reason)"
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
    [void] (Wait-ProcessExit -ProcessId $ProcessId -TimeoutSec 10)
}

function Stop-WrapperTree {
    param([int] $ProcessId, [string] $Reason)
    $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if ($null -eq $process) {
        Write-ManagerLog "wrapper pid $ProcessId already exited ($Reason)"
        return
    }
    Write-Info "tree-killing wrapper pid $ProcessId ($Reason)"
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & taskkill.exe /PID $ProcessId /T /F 2>&1
        $taskkillExitCode = $LASTEXITCODE
    } catch {
        $output = @($_.Exception.Message)
        $taskkillExitCode = 1
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    foreach ($line in @($output)) {
        Write-ManagerLog "taskkill ${ProcessId}: $line"
    }
    if ($taskkillExitCode -ne 0) {
        Write-ManagerLog "taskkill ${ProcessId} exited $taskkillExitCode ($Reason)"
    }
}

function Wait-PortClear {
    param([int] $Port, [int] $TimeoutSec = 15)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if (@(Get-Listeners -Port $Port).Count -eq 0) {
            return $true
        }
        Start-Sleep -Milliseconds 500
    }
    return (@(Get-Listeners -Port $Port).Count -eq 0)
}

function Clear-RecognizedPort {
    param([System.Collections.IDictionary] $Service, [switch] $AllowForce)
    $listeners = Get-Listeners -Port $Service.port
    foreach ($listener in $listeners) {
        $processId = [int] $listener.OwningProcess
        $commandLine = Get-ProcessCommandLine -ProcessId $processId
        $maskedCommandLine = Mask-SensitiveText $commandLine
        $ownership = Get-ListenerOwnership -Service $Service -ProcessId $processId

        if (-not $ownership.owned -and -not $AllowForce) {
            $message = "Port $($Service.port) is occupied by unrecognized PID $processId. CommandLine: $maskedCommandLine. Re-run with -Force to stop it."
            Write-ManagerLog $message
            throw $message
        }

        if ($ownership.owned) {
            Write-Info "pre-flight clearing recognized $($Service.name) listener pid $processId on port $($Service.port) via $($ownership.source)"
        } else {
            Write-Info "pre-flight clearing unrecognized listener pid $processId on port $($Service.port) because -Force was supplied"
        }
        Stop-Pid -ProcessId $processId -Reason "pre-flight port $($Service.port)"
    }

    if (-not (Wait-PortClear -Port $Service.port -TimeoutSec 15)) {
        throw "Port $($Service.port) did not clear during pre-flight."
    }
}

function Clear-OldWrappers {
    $wrapperPids = @()
    $pidState = Read-JsonFile $Script:PidfilePath
    if ($null -ne $pidState -and (Has-Property $pidState "services")) {
        foreach ($serviceProperty in $pidState.services.PSObject.Properties) {
            $state = $serviceProperty.Value
            if (Has-Property $state "wrapperPid" -and $null -ne $state.wrapperPid) {
                $wrapperPids += [int] $state.wrapperPid
            }
        }
    }

    $ownershipState = Get-OwnershipState
    if ($null -ne $ownershipState -and (Has-Property $ownershipState "services")) {
        foreach ($serviceProperty in $ownershipState.services.PSObject.Properties) {
            $state = $serviceProperty.Value
            if (Has-Property $state "wrapperPid" -and $null -ne $state.wrapperPid) {
                $wrapperPids += [int] $state.wrapperPid
            }
        }
    }

    foreach ($wrapperPid in @($wrapperPids | Select-Object -Unique)) {
        Stop-WrapperTree -ProcessId $wrapperPid -Reason "old local-env state"
    }
}

function Invoke-Preflight {
    param([System.Collections.IDictionary] $Config)
    Write-Info "pre-flight started for profile '$Profile'"
    foreach ($serviceName in $Config.services.Keys) {
        Clear-RecognizedPort -Service $Config.services[$serviceName] -AllowForce:$Force
    }
    Clear-OldWrappers
    Remove-Item -LiteralPath $Script:DescriptorPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $Script:PidfilePath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $Script:OwnershipPath -Force -ErrorAction SilentlyContinue
    Write-Info "pre-flight completed"
}

function Copy-StringMap {
    param([System.Collections.IDictionary] $Source)
    $target = [ordered]@{}
    if ($null -eq $Source) {
        return $target
    }
    foreach ($key in $Source.Keys) {
        $target[$key] = [string] $Source[$key]
    }
    return $target
}

function New-ServiceStartEnv {
    param([System.Collections.IDictionary] $Service, [string] $RunId)
    $env = Copy-StringMap -Source $Service.env
    $env["LOCAL_ENV_OWNED"] = $RunId
    $env["LOCAL_ENV_PROFILE"] = $Profile
    $env["LOCAL_ENV_SERVICE"] = [string] $Service.name
    $env["LOCAL_ENV_MARKER_PATH"] = $Script:OwnershipPath
    return $env
}

function New-RunnerScript {
    param(
        [string] $Path,
        [string] $WorkDir,
        [string] $File,
        [string[]] $Arguments,
        [string] $LogPath,
        [System.Collections.IDictionary] $Env,
        [string[]] $PrependPath
    )

    Ensure-Directory (Split-Path -Parent $Path)
    Ensure-Directory (Split-Path -Parent $LogPath)

    $pathValue = Get-NormalizedPath -Prepend $PrependPath
    $envLines = @()
    foreach ($key in $Env.Keys) {
        $envLines += ('$env:{0} = {1}' -f $key, (ConvertTo-PsSingleQuoted ([string] $Env[$key])))
    }

    $script = @"
`$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
Set-Location -LiteralPath $(ConvertTo-PsSingleQuoted $WorkDir)
`$env:Path = $(ConvertTo-PsSingleQuoted $pathValue)
`$env:PATH = `$env:Path
$($envLines -join "`r`n")
function ConvertTo-CmdArgument {
    param([string] `$Item)
    if (`$null -eq `$Item) {
        return '""'
    }
    `$escaped = `$Item -replace '"', '\"'
    return '"' + `$escaped + '"'
}
`$logPath = $(ConvertTo-PsSingleQuoted $LogPath)
"started at $((Get-Date).ToString("o"))" | Out-File -FilePath `$logPath -Encoding UTF8 -Append
try {
    `$argumentLine = (($(ConvertTo-StringArrayLiteral $Arguments)) | ForEach-Object { ConvertTo-CmdArgument `$_ }) -join ' '
    `$commandLine = 'call ' + (ConvertTo-CmdArgument $(ConvertTo-PsSingleQuoted $File)) + ' ' + `$argumentLine + ' >> ' + (ConvertTo-CmdArgument `$logPath) + ' 2>>&1'
    `$process = Start-Process -FilePath `$env:ComSpec -ArgumentList @('/d', '/c', `$commandLine) -WindowStyle Hidden -Wait -PassThru
    "process exited with code `$(`$process.ExitCode)" | Out-File -FilePath `$logPath -Encoding UTF8 -Append
    exit `$process.ExitCode
} catch {
    (`$_ | Out-String) | Out-File -FilePath `$logPath -Encoding UTF8 -Append
    exit 1
}
"@

    Set-Content -Path $Path -Encoding UTF8 -Value $script
}

function Invoke-StepWithTimeout {
    param(
        [string] $Name,
        [string] $WorkDir,
        [string] $File,
        [string[]] $Arguments,
        [string] $LogPath,
        [int] $TimeoutSec,
        [System.Collections.IDictionary] $Env,
        [string[]] $PrependPath
    )

    $wrapperPath = Join-Path $Script:WrapperRoot ("{0}.ps1" -f $Name)
    Remove-Item -LiteralPath $LogPath -Force -ErrorAction SilentlyContinue
    New-RunnerScript -Path $wrapperPath -WorkDir $WorkDir -File $File -Arguments $Arguments -LogPath $LogPath -Env $Env -PrependPath $PrependPath
    Set-NormalizedProcessPath -Prepend $PrependPath
    Write-Info "running $Name with timeout ${TimeoutSec}s"
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $wrapperPath) -WindowStyle Hidden -PassThru
    if (-not $process.WaitForExit($TimeoutSec * 1000)) {
        Stop-WrapperTree -ProcessId $process.Id -Reason "$Name timeout"
        throw "$Name timed out after ${TimeoutSec}s. Log: $LogPath"
    }
    if ($process.ExitCode -ne 0) {
        throw "$Name failed with exit code $($process.ExitCode). Log: $LogPath"
    }
    Write-Info "$Name completed"
}

function Start-ServiceDetached {
    param([System.Collections.IDictionary] $Service, [string] $RunId)

    $wrapperPath = Join-Path $Script:WrapperRoot ("{0}-start.ps1" -f $Service.name)
    Remove-Item -LiteralPath $Service.log -Force -ErrorAction SilentlyContinue
    $startEnv = New-ServiceStartEnv -Service $Service -RunId $RunId
    New-RunnerScript -Path $wrapperPath -WorkDir $Service.root -File $Service.start.file -Arguments $Service.start.args -LogPath $Service.log -Env $startEnv -PrependPath $Service.prependPath
    Set-NormalizedProcessPath -Prepend $Service.prependPath
    Write-Info "starting $($Service.name) detached"
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $wrapperPath) -WindowStyle Hidden -PassThru
    return $process.Id
}

function Invoke-Build {
    param([System.Collections.IDictionary] $Config)
    foreach ($serviceName in $Config.services.Keys) {
        $service = $Config.services[$serviceName]
        foreach ($step in $service.buildSteps) {
            Invoke-StepWithTimeout -Name $step.name -WorkDir $service.root -File $step.file -Arguments $step.args -LogPath $step.log -TimeoutSec ([int] $step.timeoutSec) -Env $service.env -PrependPath $service.prependPath
        }
    }
}

function Test-BeReady {
    param([System.Collections.IDictionary] $Service)
    try {
        $response = Invoke-WebRequest -Uri $Service.healthUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -ne 200) {
            return [ordered]@{ ready = $false; health = "http-$($response.StatusCode)" }
        }
        $content = $response.Content
        if ($content -is [byte[]]) {
            $content = [System.Text.Encoding]::UTF8.GetString($content)
        }
        $body = $content | ConvertFrom-Json
        if ((Has-Property $body "status") -and $body.status -eq "UP") {
            return [ordered]@{ ready = $true; health = "UP" }
        }
        return [ordered]@{ ready = $false; health = "body-status-not-up" }
    } catch {
        return [ordered]@{ ready = $false; health = "unavailable" }
    }
}

function Test-FeReady {
    param([System.Collections.IDictionary] $Service)
    if (-not (Test-Path -LiteralPath $Service.log)) {
        return [ordered]@{ ready = $false; health = "log-missing" }
    }
    $compiled = Select-String -Path $Service.log -Pattern "Compiled successfully" -Quiet -ErrorAction SilentlyContinue
    if ($compiled) {
        return [ordered]@{ ready = $true; health = "compiled" }
    }
    return [ordered]@{ ready = $false; health = "not-compiled" }
}

function Test-ServiceReady {
    param([System.Collections.IDictionary] $Service)
    if ($Service.readyKind -eq "springHealth") {
        return Test-BeReady -Service $Service
    }
    if ($Service.readyKind -eq "angularLog") {
        return Test-FeReady -Service $Service
    }
    throw "Unknown ready kind '$($Service.readyKind)' for service '$($Service.name)'."
}

function Get-ListenerPid {
    param([System.Collections.IDictionary] $Service)
    $listeners = @(Get-Listeners -Port $Service.port)
    if ($listeners.Count -eq 0) {
        return $null
    }
    return [int] $listeners[0].OwningProcess
}

function Write-PidState {
    param([System.Collections.IDictionary] $Config, [hashtable] $WrapperPids, [hashtable] $ListenerPids, [AllowNull()][string] $RunId)
    $services = [ordered]@{}
    foreach ($serviceName in $Config.services.Keys) {
        $listenerPid = if ($ListenerPids.ContainsKey($serviceName)) { $ListenerPids[$serviceName] } else { $null }
        $services[$serviceName] = [ordered]@{
            wrapperPid = if ($WrapperPids.ContainsKey($serviceName)) { $WrapperPids[$serviceName] } else { $null }
            listenerPid = $listenerPid
            listenerStartedAt = if ($null -ne $listenerPid) { Get-ProcessCreationTimeText -ProcessId ([int] $listenerPid) } else { $null }
            port = $Config.services[$serviceName].port
        }
    }
    Write-JsonFile -Path $Script:PidfilePath -Value ([ordered]@{
        schemaVersion = $Script:SchemaVersion
        profile = $Profile
        runId = $RunId
        updatedAt = (Get-Date).ToString("o")
        services = $services
    })
}

function Write-OwnershipState {
    param([System.Collections.IDictionary] $Config, [string] $RunId, [hashtable] $WrapperPids, [hashtable] $ListenerPids)
    $services = [ordered]@{}
    foreach ($serviceName in $Config.services.Keys) {
        $listenerPid = if ($ListenerPids.ContainsKey($serviceName)) { $ListenerPids[$serviceName] } else { $null }
        $services[$serviceName] = [ordered]@{
            port = $Config.services[$serviceName].port
            wrapperPid = if ($WrapperPids.ContainsKey($serviceName)) { $WrapperPids[$serviceName] } else { $null }
            listenerPid = $listenerPid
            listenerStartedAt = if ($null -ne $listenerPid) { Get-ProcessCreationTimeText -ProcessId ([int] $listenerPid) } else { $null }
            env = [ordered]@{
                LOCAL_ENV_OWNED = $RunId
                LOCAL_ENV_PROFILE = $Profile
                LOCAL_ENV_SERVICE = $serviceName
            }
        }
    }

    Write-JsonFile -Path $Script:OwnershipPath -Value ([ordered]@{
        schemaVersion = $Script:SchemaVersion
        profile = $Profile
        runId = $RunId
        marker = "LOCAL_ENV_OWNED"
        updatedAt = (Get-Date).ToString("o")
        services = $services
    })
}

function Tail-ServiceLogs {
    param([System.Collections.IDictionary] $Config, [int] $Lines = 80)
    foreach ($serviceName in $Config.services.Keys) {
        $service = $Config.services[$serviceName]
        if (Test-Path -LiteralPath $service.log) {
            Write-Host "---- tail $($service.name) log: $($service.log) ----"
            foreach ($line in (Get-Content -Path $service.log -Tail $Lines -ErrorAction SilentlyContinue)) {
                Write-Host (Mask-SensitiveText $line)
            }
        }
    }
}

function Wait-AllReady {
    param([System.Collections.IDictionary] $Config, [hashtable] $WrapperPids, [datetime] $StartedAt)

    $ready = @{}
    $health = @{}
    $readySeconds = @{}
    $deadlines = @{}

    foreach ($serviceName in $Config.services.Keys) {
        $ready[$serviceName] = $false
        $health[$serviceName] = "starting"
        $readySeconds[$serviceName] = $null
        $deadlines[$serviceName] = $StartedAt.AddSeconds([int] $Config.services[$serviceName].readyTimeoutSec)
    }

    while ($true) {
        $allReady = $true
        foreach ($serviceName in $Config.services.Keys) {
            if ($ready[$serviceName]) {
                continue
            }

            $allReady = $false
            $service = $Config.services[$serviceName]
            $wrapperPid = [int] $WrapperPids[$serviceName]
            $wrapperProcess = Get-Process -Id $wrapperPid -ErrorAction SilentlyContinue
            $listenerPid = Get-ListenerPid -Service $service
            if ($null -eq $wrapperProcess -and $null -eq $listenerPid) {
                throw "$serviceName wrapper exited before readiness. Log: $($service.log)"
            }

            $result = Test-ServiceReady -Service $service
            $health[$serviceName] = $result.health
            if ($result.ready) {
                $ready[$serviceName] = $true
                $readySeconds[$serviceName] = [math]::Round(((Get-Date) - $StartedAt).TotalSeconds, 1)
                Write-Info "$serviceName ready in $($readySeconds[$serviceName])s"
                continue
            }

            if ((Get-Date) -gt $deadlines[$serviceName]) {
                throw "$serviceName readiness timed out after $($service.readyTimeoutSec)s. Last health: $($health[$serviceName]). Log: $($service.log)"
            }
        }

        if ($allReady) {
            return [ordered]@{
                health = $health
                readySeconds = $readySeconds
            }
        }

        Start-Sleep -Seconds 2
    }
}

function Write-Descriptor {
    param(
        [System.Collections.IDictionary] $Config,
        [hashtable] $ListenerPids,
        [hashtable] $Health,
        [hashtable] $ReadySeconds,
        [datetime] $StartedAt,
        [datetime] $ReadyAt
    )

    $services = [ordered]@{}
    foreach ($serviceName in $Config.services.Keys) {
        $service = $Config.services[$serviceName]
        $services[$serviceName] = [ordered]@{
            url = $service.url
            pid = [int] $ListenerPids[$serviceName]
            health = [string] $Health[$serviceName]
            log = (Get-RepoRelativePath $service.log)
            readySeconds = $ReadySeconds[$serviceName]
        }
    }

    $descriptor = [ordered]@{
        schemaVersion = $Script:SchemaVersion
        status = "ready"
        profile = $Profile
        startedAt = $StartedAt.ToString("o")
        readyAt = $ReadyAt.ToString("o")
        services = $services
    }
    Write-JsonFile -Path $Script:DescriptorPath -Value $descriptor
    return $descriptor
}

function Get-ExistingReadyDescriptor {
    param([System.Collections.IDictionary] $Config)
    $descriptor = Read-JsonFile $Script:DescriptorPath
    $listenerPids = @{}
    $health = @{}
    $readySeconds = @{}
    $ownershipSources = @()

    foreach ($serviceName in $Config.services.Keys) {
        $service = $Config.services[$serviceName]
        $listenerPid = Get-ListenerPid -Service $service
        if ($null -eq $listenerPid) {
            return $null
        }

        $ownership = Get-ListenerOwnership -Service $service -ProcessId ([int] $listenerPid)
        if (-not $ownership.owned) {
            return $null
        }

        $ready = Test-ServiceReady -Service $service
        if (-not $ready.ready) {
            return $null
        }

        $listenerPids[$serviceName] = [int] $listenerPid
        $health[$serviceName] = $ready.health
        $readySeconds[$serviceName] = $null
        $ownershipSources += ("{0}:{1}" -f $serviceName, $ownership.source)
    }

    if ($null -ne $descriptor -and (Has-Property $descriptor "services") -and (Has-Property $descriptor "status") -and [string] $descriptor.status -eq "ready") {
        $descriptorMatches = $true
        foreach ($serviceName in $Config.services.Keys) {
            if ((-not (Has-Property $descriptor.services $serviceName)) -or (-not (Has-Property $descriptor.services.$serviceName "pid")) -or [int] $descriptor.services.$serviceName.pid -ne [int] $listenerPids[$serviceName]) {
                $descriptorMatches = $false
                break
            }
        }
        if ($descriptorMatches) {
            return $descriptor
        }
    }

    Write-ManagerLog ("reconstructing ready descriptor from ownership state: {0}" -f ($ownershipSources -join ", "))
    $now = Get-Date
    return (Write-Descriptor -Config $Config -ListenerPids $listenerPids -Health $health -ReadySeconds $readySeconds -StartedAt $now -ReadyAt $now)
}

function Invoke-Up {
    param([System.Collections.IDictionary] $Config)

    $existing = Get-ExistingReadyDescriptor -Config $Config
    if ($null -ne $existing) {
        Write-Info "profile '$Profile' is already ready; reusing existing services"
        Write-JsonOutput $existing
        return 0
    }

    Invoke-Preflight -Config $Config

    if (-not $SkipBuild) {
        Invoke-Build -Config $Config
    } else {
        Write-Info "build skipped by -SkipBuild"
    }

    $startedAt = Get-Date
    $runId = [guid]::NewGuid().ToString("n")
    $wrapperPids = @{}
    $listenerPids = @{}

    try {
        foreach ($serviceName in $Config.services.Keys) {
            $wrapperPids[$serviceName] = Start-ServiceDetached -Service $Config.services[$serviceName] -RunId $runId
        }
        Write-PidState -Config $Config -WrapperPids $wrapperPids -ListenerPids $listenerPids -RunId $runId
        Write-OwnershipState -Config $Config -RunId $runId -WrapperPids $wrapperPids -ListenerPids $listenerPids

        $readyInfo = Wait-AllReady -Config $Config -WrapperPids $wrapperPids -StartedAt $startedAt

        foreach ($serviceName in $Config.services.Keys) {
            $listenerPid = Get-ListenerPid -Service $Config.services[$serviceName]
            if ($null -eq $listenerPid) {
                throw "$serviceName is ready but no listener owns port $($Config.services[$serviceName].port)."
            }
            $listenerPids[$serviceName] = [int] $listenerPid
        }
        Write-PidState -Config $Config -WrapperPids $wrapperPids -ListenerPids $listenerPids -RunId $runId
        Write-OwnershipState -Config $Config -RunId $runId -WrapperPids $wrapperPids -ListenerPids $listenerPids

        $descriptor = Write-Descriptor -Config $Config -ListenerPids $listenerPids -Health $readyInfo.health -ReadySeconds $readyInfo.readySeconds -StartedAt $startedAt -ReadyAt (Get-Date)
        Write-JsonOutput $descriptor
        return 0
    } catch {
        Write-Host $_.Exception.Message
        Write-ManagerLog "up failed: $($_.Exception.Message)"
        Tail-ServiceLogs -Config $Config
        [void] (Invoke-Down -Config $Config -Quiet)
        return 1
    }
}

function Invoke-Down {
    param([System.Collections.IDictionary] $Config, [switch] $Quiet)

    if (-not $Quiet) {
        Write-Info "down started for profile '$Profile'"
    } else {
        Write-ManagerLog "down started for profile '$Profile'"
    }

    $pidState = Read-JsonFile $Script:PidfilePath

    foreach ($serviceName in $Config.services.Keys) {
        $service = $Config.services[$serviceName]
        $listeners = Get-Listeners -Port $service.port
        foreach ($listener in $listeners) {
            Stop-Pid -ProcessId ([int] $listener.OwningProcess) -Reason "down kill-by-port $($service.port)"
        }
    }

    if ($null -ne $pidState -and (Has-Property $pidState "services")) {
        foreach ($serviceProperty in $pidState.services.PSObject.Properties) {
            $state = $serviceProperty.Value
            if (Has-Property $state "wrapperPid" -and $null -ne $state.wrapperPid) {
                Stop-WrapperTree -ProcessId ([int] $state.wrapperPid) -Reason "down wrapper tree"
            }
        }
    }

    $allClear = $true
    foreach ($serviceName in $Config.services.Keys) {
        $port = [int] $Config.services[$serviceName].port
        if (-not (Wait-PortClear -Port $port -TimeoutSec 15)) {
            $allClear = $false
            $listeners = Get-Listeners -Port $port
            foreach ($listener in $listeners) {
                Write-Host "port $port still has listener pid $($listener.OwningProcess)"
                Write-ManagerLog "port $port still has listener pid $($listener.OwningProcess)"
            }
        }
    }

    if ($allClear) {
        $descriptorRemoved = Remove-FileIfExists -Path $Script:DescriptorPath
        $pidfileRemoved = Remove-FileIfExists -Path $Script:PidfilePath
        $ownershipRemoved = Remove-FileIfExists -Path $Script:OwnershipPath
        if ($descriptorRemoved -and $pidfileRemoved -and $ownershipRemoved) {
            Write-ManagerLog "down completed"
            if (-not $Quiet) {
                Write-Host "down completed"
            }
            return 0
        }
        Write-ManagerLog "down failed: runtime files remain"
        return 1
    }

    Write-ManagerLog "down failed: listeners remain"
    return 1
}

function Invoke-Status {
    param([System.Collections.IDictionary] $Config)

    $descriptor = Read-JsonFile $Script:DescriptorPath
    $services = [ordered]@{}
    $allReady = $true

    foreach ($serviceName in $Config.services.Keys) {
        $service = $Config.services[$serviceName]
        $listenerPid = Get-ListenerPid -Service $service
        $ready = Test-ServiceReady -Service $service
        $descriptorPid = $null
        if ($null -ne $descriptor -and (Has-Property $descriptor "services") -and (Has-Property $descriptor.services $serviceName) -and (Has-Property $descriptor.services.$serviceName "pid")) {
            $descriptorPid = $descriptor.services.$serviceName.pid
        }

        $serviceReady = ($null -ne $listenerPid -and $ready.ready)
        if (-not $serviceReady) {
            $allReady = $false
        }
        $services[$serviceName] = [ordered]@{
            url = $service.url
            port = $service.port
            listenerPid = $listenerPid
            descriptorPid = $descriptorPid
            health = $ready.health
            ready = $serviceReady
            log = (Get-RepoRelativePath $service.log)
        }
    }

    $summary = [ordered]@{
        schemaVersion = $Script:SchemaVersion
        profile = $Profile
        status = if ($allReady) { "ready" } else { "down" }
        descriptor = if (Test-Path -LiteralPath $Script:DescriptorPath) { Get-RepoRelativePath $Script:DescriptorPath } else { $null }
        pidfile = if (Test-Path -LiteralPath $Script:PidfilePath) { Get-RepoRelativePath $Script:PidfilePath } else { $null }
        services = $services
    }
    Write-JsonOutput $summary
    if ($allReady) {
        return 0
    }
    return 1
}

Ensure-Directory $Script:LogRoot
Ensure-Directory $Script:WrapperRoot

try {
    $config = Get-Config
    $exitCode = 1
    if ($Action -eq "up") {
        $exitCode = Invoke-Up -Config $config
        exit $exitCode
    }
    if ($Action -eq "down") {
        $exitCode = Invoke-Down -Config $config
        exit $exitCode
    }
    if ($Action -eq "status") {
        $exitCode = Invoke-Status -Config $config
        exit $exitCode
    }
} catch {
    $message = $_.Exception.Message
    Write-Host $message
    Write-ManagerLog "fatal: $message"
    exit 1
}
