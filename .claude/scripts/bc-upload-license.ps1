<#
.SYNOPSIS
    Uploads a Business Central license to a Docker container and restarts the instance

.DESCRIPTION
    This script uses BCContainerHelper to:
    1. Upload a .bclicense file to the specified BC Docker container
    2. Restart the BC service instance to apply the license
    3. Read back the license information to confirm it was applied

.PARAMETER ContainerName
    Name of the BC Docker container (default: from CURRENT_FEATURE_CONTAINER in .env)

.PARAMETER LicenseFile
    Path to the .bclicense file (default: license.bclicense in repository root)

.EXAMPLE
    .\bc-upload-license.ps1
    # Uses defaults from .env file

.EXAMPLE
    .\bc-upload-license.ps1 -ContainerName "bc-my-feature" -LicenseFile "C:\licenses\my.bclicense"
    # Uses specified container and license file
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ContainerName = "",

    [Parameter(Mandatory=$false)]
    [string]$LicenseFile = ""
)

# Script settings
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Get script and repository root paths
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BC License Upload Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load .env file if container name or license file not specified
$envFile = Join-Path $RepoRoot ".env"
if (Test-Path $envFile) {
    Write-Host "[1/6] Loading configuration from .env file..." -ForegroundColor Yellow
    $envContent = Get-Content $envFile
    foreach ($line in $envContent) {
        if ($line -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Variable -Name "ENV_$key" -Value $value -Scope Script
        }
    }

    # Use container name from .env if not specified
    if ([string]::IsNullOrEmpty($ContainerName)) {
        $ContainerName = $ENV_CURRENT_FEATURE_CONTAINER
        if ([string]::IsNullOrEmpty($ContainerName)) {
            Write-Host "ERROR: No container name specified and CURRENT_FEATURE_CONTAINER not found in .env" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "  - Container name: $ContainerName" -ForegroundColor Green
} else {
    Write-Host "WARNING: .env file not found at $envFile" -ForegroundColor Yellow
    if ([string]::IsNullOrEmpty($ContainerName)) {
        Write-Host "ERROR: No container name specified and .env file not found" -ForegroundColor Red
        exit 1
    }
}

# Determine license file path
if ([string]::IsNullOrEmpty($LicenseFile)) {
    $LicenseFile = Join-Path $RepoRoot "license.bclicense"
}

Write-Host "  - License file: $LicenseFile" -ForegroundColor Green

# Verify license file exists
Write-Host "[2/6] Verifying license file exists..." -ForegroundColor Yellow
if (-not (Test-Path $LicenseFile)) {
    Write-Host "ERROR: License file not found at: $LicenseFile" -ForegroundColor Red
    exit 1
}
$licenseFileInfo = Get-Item $LicenseFile
Write-Host "  - License file found: $($licenseFileInfo.Name) ($([math]::Round($licenseFileInfo.Length / 1KB, 2)) KB)" -ForegroundColor Green

# Import BCContainerHelper
Write-Host "[3/6] Importing BCContainerHelper module..." -ForegroundColor Yellow
try {
    Import-Module BCContainerHelper -Force -ErrorAction Stop
    $bcHelperVersion = (Get-Module BCContainerHelper).Version
    Write-Host "  - BCContainerHelper version $bcHelperVersion loaded" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to import BCContainerHelper module" -ForegroundColor Red
    Write-Host "  Please install it with: Install-Module BCContainerHelper -Force" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Verify container is running
Write-Host "[4/6] Verifying container is running..." -ForegroundColor Yellow
$containerStatus = docker inspect --format='{{.State.Running}}' $ContainerName 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Container '$ContainerName' not found" -ForegroundColor Red
    exit 1
}
if ($containerStatus -ne "true") {
    Write-Host "ERROR: Container '$ContainerName' is not running" -ForegroundColor Red
    Write-Host "  Start it with: docker start $ContainerName" -ForegroundColor Yellow
    exit 1
}
Write-Host "  - Container '$ContainerName' is running" -ForegroundColor Green

# Upload the license
Write-Host "[5/6] Uploading license to container..." -ForegroundColor Yellow
Write-Host ""
try {
    Import-BcContainerLicense -containerName $ContainerName -licenseFile $LicenseFile -restart
    Write-Host ""
    Write-Host "  - License uploaded successfully" -ForegroundColor Green
    Write-Host "  - BC service instance restarted" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to upload license" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Wait for service to be ready after restart
Write-Host ""
Write-Host "  Waiting for BC service to be ready after restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verify the license was applied by reading it back
Write-Host "[6/6] Verifying license was applied..." -ForegroundColor Yellow
Write-Host ""
try {
    $licenseInfo = Get-BcContainerLicenseInformation -containerName $ContainerName

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "LICENSE INFORMATION" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    if ($licenseInfo) {
        # Display license information
        $licenseInfo | Format-List | Out-String | Write-Host
    } else {
        Write-Host "  License information retrieved (no detailed info available)" -ForegroundColor Yellow
    }

} catch {
    Write-Host "WARNING: Could not read license information back" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The license may still have been uploaded successfully." -ForegroundColor Yellow
    Write-Host "Please verify manually in the BC web client under License Information." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "License upload completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Container:    $ContainerName" -ForegroundColor White
Write-Host "License file: $($licenseFileInfo.Name)" -ForegroundColor White
Write-Host ""
