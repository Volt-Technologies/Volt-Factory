<#
.SYNOPSIS
    Publishes a BC app to a Docker container

.DESCRIPTION
    Uses BCContainerHelper to publish, sync, and install a BC app.
    Reads configuration from .env file.

.PARAMETER AppFile
    Path to the .app file to publish. REQUIRED.

.PARAMETER ContainerName
    Name of the BC container (default: from CURRENT_FEATURE_CONTAINER in .env)

.PARAMETER SkipVerification
    Skip app signature verification (default: true for development)

.PARAMETER SyncMode
    Sync mode: Add, Clean, Development, ForceSync (default: ForceSync)

.EXAMPLE
    .\bc-publish-app.ps1 -AppFile "BC\MyApp.app"

.EXAMPLE
    .\bc-publish-app.ps1 -AppFile "BC Test\BC Test_1.0.0.1.app" -ContainerName "bc-my-feature"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AppFile,

    [Parameter(Mandatory=$false)]
    [string]$ContainerName,

    [Parameter(Mandatory=$false)]
    [bool]$SkipVerification = $true,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Add", "Clean", "Development", "ForceSync")]
    [string]$SyncMode = "ForceSync"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== BC App Publisher ===" -ForegroundColor Cyan
Write-Host ""

# Load configuration from .env file
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptPath
$envFile = Join-Path $RepoRoot ".env"

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

# Resolve container name
if (-not $ContainerName) {
    $ContainerName = $env:CURRENT_FEATURE_CONTAINER
    if (-not $ContainerName) {
        Write-Host "ERROR: ContainerName not specified and CURRENT_FEATURE_CONTAINER not found in .env" -ForegroundColor Red
        exit 1
    }
}

# Resolve app file path
if (-not [System.IO.Path]::IsPathRooted($AppFile)) {
    $AppFile = Join-Path $RepoRoot $AppFile
}

if (-not (Test-Path $AppFile)) {
    Write-Host "ERROR: App file not found: $AppFile" -ForegroundColor Red
    exit 1
}

$appFileName = Split-Path -Leaf $AppFile

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Container: $ContainerName" -ForegroundColor White
Write-Host "  App File:  $appFileName" -ForegroundColor White
Write-Host "  Sync Mode: $SyncMode" -ForegroundColor White
Write-Host ""

# Import BCContainerHelper
Import-Module BcContainerHelper -DisableNameChecking

# Verify container is running
$containerRunning = docker ps --format "{{.Names}}" | Select-String -Pattern "^$ContainerName$"
if (-not $containerRunning) {
    Write-Host "ERROR: Container '$ContainerName' is not running" -ForegroundColor Red
    exit 1
}

Write-Host "Publishing app to $ContainerName..." -ForegroundColor Yellow

try {
    $publishParams = @{
        containerName = $ContainerName
        appFile = $AppFile
        sync = $true
        install = $true
        syncMode = $SyncMode
    }

    if ($SkipVerification) {
        $publishParams.skipVerification = $true
    }

    Publish-BcContainerApp @publishParams

    Write-Host ""
    Write-Host "App published and installed successfully!" -ForegroundColor Green

    # Verify installation
    Write-Host ""
    Write-Host "Installed apps:" -ForegroundColor Yellow
    $apps = Get-BcContainerAppInfo -containerName $ContainerName | Where-Object { $_.IsInstalled -eq $true }
    $apps | Format-Table Name, Version, Publisher -AutoSize

} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to publish app" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
