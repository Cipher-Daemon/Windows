<#
.SYNOPSIS
    Creates a self-contained Windows system report by embedding collected data in HTML.

.DESCRIPTION
    PowerShell 5.1 compatible. Keep this script beside report-template.html.
    Add new collectors in the COLLECTORS area, then register them in
    $sectionDefinitions. The HTML automatically displays generic table/text
    sections; only special visualizations such as ProcessTree need custom JS.

.PARAMETER HtmlTemplatePath
    HTML template path. Defaults to report-template.html beside this script.

.PARAMETER OutputHtmlPath
    Generated HTML path. Defaults to Output\Windows-System-Report.html.

.PARAMETER ExportJson
    Also writes a standalone JSON export beside the HTML report.

.PARAMETER NoOpen
    Do not automatically open the generated report.
#>
[CmdletBinding()]
param(
    [string]$HtmlTemplatePath = (Join-Path -Path $PSScriptRoot -ChildPath 'report-template.html'),
    [string]$OutputHtmlPath = (Join-Path -Path $PSScriptRoot -ChildPath 'Output\Windows-System-Report.html'),
    [switch]$ExportJson,
    [switch]$NoOpen
)

$ErrorActionPreference = 'Stop'
$placeholder = '__REPORT_DATA_BASE64__'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# =============================================================================
# COLLECTORS
# Add one function for each new data source. A collector should return data;
# it should not write HTML or modify the report object.
# =============================================================================

function Get-ProcessTreeData {
    [CmdletBinding()]
    param()

    $processes = Get-CimInstance -ClassName Win32_Process -ErrorAction Stop
    $processMap = @{}
    $rootProcesses = New-Object 'System.Collections.Generic.List[object]'

    foreach ($process in $processes) {
        $owner = 'SYSTEM/UNKNOWN'
        try {
            $ownerInfo = Invoke-CimMethod -InputObject $process -MethodName GetOwner -ErrorAction Stop
            if ($null -ne $ownerInfo -and $ownerInfo.ReturnValue -eq 0 -and $ownerInfo.User) {
                if ($ownerInfo.Domain) {
                    $owner = '{0}\{1}' -f $ownerInfo.Domain, $ownerInfo.User
                }
                else {
                    $owner = $ownerInfo.User
                }
            }
        }
        catch {
            # Protected processes or permission restrictions may block owner lookup.
        }

        $processMap[$process.ProcessId] = [pscustomobject]@{
            Id          = $process.ProcessId
            ParentId    = $process.ParentProcessId
            Name        = $process.Name
            Path        = $process.ExecutablePath
            CommandLine = $process.CommandLine
            Owner       = $owner
            Children    = [System.Collections.Generic.List[object]]::new()
        }
    }

    foreach ($process in $processMap.Values) {
        if ($process.ParentId -and $processMap.ContainsKey($process.ParentId)) {
            $processMap[$process.ParentId].Children.Add($process)
        }
        else {
            $rootProcesses.Add($process)
        }
    }

    return $rootProcesses.ToArray()
}

function Get-NetstatData {
    [CmdletBinding()]
    param()

    $netstatExe = Join-Path -Path $env:SystemRoot -ChildPath 'System32\netstat.exe'
    if (-not (Test-Path -LiteralPath $netstatExe -PathType Leaf)) {
        throw "Unable to find netstat.exe at: $netstatExe"
    }

    $lines = @(& $netstatExe -ano 2>&1)
    if ($lines.Count -eq 0) {
        return '(netstat returned no output)'
    }

    $stringLines = @($lines | ForEach-Object { [string]$_ })
    return [string]::Join([Environment]::NewLine, [string[]]$stringLines)
}

function Get-ServiceData {
    [CmdletBinding()]
    param()

    Get-CimInstance -ClassName Win32_Service -ErrorAction Stop |
        Select-Object Name, DisplayName, State, StartMode, ProcessId
}

# Example collector. It is disabled in $sectionDefinitions by default.
function Get-NetworkAdapterData {
    [CmdletBinding()]
    param()

    Get-NetAdapter -ErrorAction Stop |
        Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed
}

# Example collector. It is disabled in $sectionDefinitions by default.
function Get-ScheduledTaskData {
    [CmdletBinding()]
    param()

    if (-not (Get-Command -Name Get-ScheduledTask -ErrorAction SilentlyContinue)) {
        throw 'Get-ScheduledTask is not available on this computer.'
    }

    Get-ScheduledTask -ErrorAction Stop |
        Select-Object TaskPath, TaskName, State
}

# =============================================================================
# SECTION REGISTRY
# This is the main place to enable, disable, or add report sections.
#
# Type options:
#   processTree = special expandable process hierarchy
#   text        = searchable preformatted text (good for command output)
#   table       = automatically generated searchable HTML table
#
# To add a standard section:
#   1. Create a Get-YourData function above.
#   2. Add a definition below with Key, Title, Description, Type, Enabled,
#      Collector, and (for tables) Columns.
#   3. Set Enabled = $true.
# No HTML changes are required for Type 'table' or 'text'.
# =============================================================================

$sectionDefinitions = @(
    [pscustomobject]@{
        Key = 'ProcessTree'
        Title = 'Process Tree'
        Description = 'Expandable process hierarchy with PID, parent PID, path, owner, and command line.'
        Type = 'processTree'
        Enabled = $true
        Collector = { Get-ProcessTreeData }
        Columns = @()
    },
    [pscustomobject]@{
        Key = 'Netstat'
        Title = 'Network Connections (netstat -ano)'
        Description = 'TCP/UDP endpoints, listening ports, numeric addresses, and owning process IDs.'
        Type = 'text'
        Enabled = $true
        Collector = { Get-NetstatData }
        Columns = @()
    },
    [pscustomobject]@{
        Key = 'Services'
        Title = 'Windows Services'
        Description = 'Service name, display name, state, startup mode, and associated process ID.'
        Type = 'table'
        Enabled = $true
        Collector = { Get-ServiceData }
        Columns = @(
            [pscustomobject]@{ Key = 'Name'; Label = 'Service Name' },
            [pscustomobject]@{ Key = 'DisplayName'; Label = 'Display Name' },
            [pscustomobject]@{ Key = 'State'; Label = 'State' },
            [pscustomobject]@{ Key = 'StartMode'; Label = 'Start Mode' },
            [pscustomobject]@{ Key = 'ProcessId'; Label = 'PID' }
        )
    },
    [pscustomobject]@{
        Key = 'NetworkAdapters'
        Title = 'Network Adapters'
        Description = 'Example section. Enable it to collect adapter status and link information.'
        Type = 'table'
        Enabled = $false
        Collector = { Get-NetworkAdapterData }
        Columns = @(
            [pscustomobject]@{ Key = 'Name'; Label = 'Name' },
            [pscustomobject]@{ Key = 'InterfaceDescription'; Label = 'Interface' },
            [pscustomobject]@{ Key = 'Status'; Label = 'Status' },
            [pscustomobject]@{ Key = 'MacAddress'; Label = 'MAC Address' },
            [pscustomobject]@{ Key = 'LinkSpeed'; Label = 'Link Speed' }
        )
    },
    [pscustomobject]@{
        Key = 'ScheduledTasks'
        Title = 'Scheduled Tasks'
        Description = 'Example section. Enable it to list registered scheduled tasks.'
        Type = 'table'
        Enabled = $false
        Collector = { Get-ScheduledTaskData }
        Columns = @(
            [pscustomobject]@{ Key = 'TaskPath'; Label = 'Task Path' },
            [pscustomobject]@{ Key = 'TaskName'; Label = 'Task Name' },
            [pscustomobject]@{ Key = 'State'; Label = 'State' }
        )
    }
)

# Validate the template before spending time collecting system information.
if (-not (Test-Path -LiteralPath $HtmlTemplatePath -PathType Leaf)) {
    throw "HTML template not found: $HtmlTemplatePath"
}
$htmlTemplate = [System.IO.File]::ReadAllText($HtmlTemplatePath)
$placeholderCount = [regex]::Matches($htmlTemplate, [regex]::Escape($placeholder)).Count
if ($placeholderCount -ne 1) {
    throw "HTML template must contain exactly one data placeholder ($placeholder). Found: $placeholderCount"
}

Write-Host 'Building Windows system report...' -ForegroundColor Cyan
$sections = [ordered]@{}

foreach ($definition in $sectionDefinitions) {
    if (-not $definition.Enabled) { continue }

    Write-Host ("  Collecting: {0}" -f $definition.Title) -ForegroundColor Cyan

    try {
        $collector = $definition.Collector
        if ($definition.Type -eq 'table' -or $definition.Type -eq 'processTree') {
            $collectedData = @(& $collector)
        }
        else {
            $collectedData = & $collector
        }

        $section = [ordered]@{
            Title       = $definition.Title
            Description = $definition.Description
            Type        = $definition.Type
            Status      = 'Success'
            Data        = $collectedData
        }
        if ($definition.Columns -and $definition.Columns.Count -gt 0) {
            $section.Columns = @($definition.Columns)
        }
    }
    catch {
        $section = [ordered]@{
            Title       = $definition.Title
            Description = $definition.Description
            Type        = 'error'
            Status      = 'Error'
            Error       = $_.Exception.Message
            Data        = $null
        }
        Write-Warning ("  Section '{0}' failed: {1}" -f $definition.Key, $_.Exception.Message)
    }

    $sections[$definition.Key] = $section
}

$reportData = [ordered]@{
    SchemaVersion = 2
    Metadata      = [ordered]@{
        ComputerName = $env:COMPUTERNAME
        GeneratedAt  = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
        GeneratedBy  = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    }
    Sections      = $sections
}

$jsonOutput = ConvertTo-Json -InputObject $reportData -Depth 100
$jsonBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jsonOutput))

# Replace only the first occurrence: the template has one actual data slot.
$placeholderIndex = $htmlTemplate.IndexOf($placeholder, [System.StringComparison]::Ordinal)
if ($placeholderIndex -lt 0) {
    throw "HTML template data slot not found: $placeholder"
}
$htmlOutput = $htmlTemplate.Substring(0, $placeholderIndex) +
    $jsonBase64 +
    $htmlTemplate.Substring($placeholderIndex + $placeholder.Length)

$fullOutputPath = [System.IO.Path]::GetFullPath($OutputHtmlPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($fullOutputPath)
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
}
[System.IO.File]::WriteAllText($fullOutputPath, $htmlOutput, $utf8NoBom)

# Verify that the embedded payload can be decoded and parsed as JSON.
$writtenHtml = [System.IO.File]::ReadAllText($fullOutputPath)
$embeddedMatch = [regex]::Match(
    $writtenHtml,
    '<script\s+id=["'']embeddedData["''][^>]*>(.*?)</script>',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if (-not $embeddedMatch.Success) {
    throw 'Verification failed: embeddedData script element was not found.'
}
$writtenPayload = $embeddedMatch.Groups[1].Value.Trim()
if ([string]::IsNullOrWhiteSpace($writtenPayload) -or $writtenPayload -eq $placeholder) {
    throw 'Verification failed: embedded data slot is empty or was not replaced.'
}
$verifiedJson = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($writtenPayload))
$null = ConvertFrom-Json -InputObject $verifiedJson -ErrorAction Stop

Write-Host ''
Write-Host 'HTML report created and verified:' -ForegroundColor Green
Write-Host "  $fullOutputPath" -ForegroundColor White
Write-Host ("  Sections included: {0}" -f $sections.Count) -ForegroundColor Gray
foreach ($key in $sections.Keys) {
    $state = $sections[$key].Status
    Write-Host ("    {0}: {1}" -f $key, $state) -ForegroundColor Gray
}
Write-Host ("  Embedded payload: {0:N0} Base64 characters" -f $jsonBase64.Length) -ForegroundColor Gray

if ($ExportJson) {
    $jsonPath = [System.IO.Path]::ChangeExtension($fullOutputPath, '.json')
    [System.IO.File]::WriteAllText($jsonPath, $jsonOutput, $utf8NoBom)
    Write-Host "JSON export created: $jsonPath" -ForegroundColor Green
}

if (-not $NoOpen) {
    Write-Host 'Opening the generated report...' -ForegroundColor Cyan
    Start-Process -FilePath $fullOutputPath
}
else {
    Write-Host 'Automatic browser opening skipped (-NoOpen was specified).' -ForegroundColor Cyan
}
