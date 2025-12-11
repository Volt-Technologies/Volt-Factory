<#
.SYNOPSIS
    Verifies BC app installation in a Docker container

.DESCRIPTION
    Checks if specified app is installed, verifies dependencies,
    and optionally queries database for objects.

.PARAMETER AppName
    Name of the app to verify (default: checks all apps)

.PARAMETER ContainerName
    Name of the BC container (default: from CURRENT_FEATURE_CONTAINER in .env)

.PARAMETER CheckCodeunitRange
    Optional codeunit ID range to verify in database (e.g., "70200..70249")

.EXAMPLE
    .\bc-verify-app.ps1

.EXAMPLE
    .\bc-verify-app.ps1 -AppName "BC Test" -CheckCodeunitRange "70200..70249"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName,

    [Parameter(Mandatory=$false)]
    [string]$ContainerName,

    [Parameter(Mandatory=$false)]
    [string]$CheckCodeunitRange
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== BC App Verification ===" -ForegroundColor Cyan
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

Write-Host "Container: $ContainerName" -ForegroundColor White
Write-Host ""

# Import BCContainerHelper
Import-Module BcContainerHelper -DisableNameChecking

# 1. Check installed apps
Write-Host "1. Checking installed apps..." -ForegroundColor Yellow

$allApps = Get-BcContainerAppInfo -containerName $ContainerName

if ($AppName) {
    $targetApp = $allApps | Where-Object { $_.Name -eq $AppName }
    if ($targetApp) {
        Write-Host "   $AppName is installed:" -ForegroundColor Green
        Write-Host "   - Version: $($targetApp.Version)" -ForegroundColor Gray
        Write-Host "   - Publisher: $($targetApp.Publisher)" -ForegroundColor Gray
        Write-Host "   - AppId: $($targetApp.AppId)" -ForegroundColor Gray
    } else {
        Write-Host "   $AppName is NOT installed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   Installed apps:" -ForegroundColor Green
    $allApps | Where-Object { $_.IsInstalled -eq $true } | Format-Table Name, Version, Publisher -AutoSize
}

# 2. Check test framework dependencies
Write-Host "2. Checking test framework dependencies..." -ForegroundColor Yellow

$testApps = @('Test Runner', 'Library Assert', 'Any')
$missingDeps = @()

foreach ($testAppName in $testApps) {
    $app = $allApps | Where-Object { $_.Name -eq $testAppName }
    if ($app) {
        Write-Host "   $testAppName - Installed (v$($app.Version))" -ForegroundColor Green
    } else {
        Write-Host "   $testAppName - MISSING!" -ForegroundColor Red
        $missingDeps += $testAppName
    }
}

# 3. Check codeunit range in database (optional)
if ($CheckCodeunitRange) {
    Write-Host ""
    Write-Host "3. Checking codeunits in database..." -ForegroundColor Yellow

    $rangeParts = $CheckCodeunitRange -split '\.\.'
    if ($rangeParts.Count -eq 2) {
        $startId = [int]$rangeParts[0]
        $endId = [int]$rangeParts[1]

        $sqlQuery = @"
SELECT [ID] as CodeunitID, [Name] as CodeunitName
FROM [dbo].[Object]
WHERE [Type] = 5 AND [Company Name] = '' AND [ID] BETWEEN $startId AND $endId
ORDER BY [ID]
"@

        try {
            $objects = Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
                param($query)
                $connection = New-Object System.Data.SqlClient.SqlConnection
                $connection.ConnectionString = "Server=localhost\SQLEXPRESS;Database=CRONUS;Integrated Security=True;"
                $connection.Open()
                $command = $connection.CreateCommand()
                $command.CommandText = $query
                $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
                $dataset = New-Object System.Data.DataSet
                $adapter.Fill($dataset) | Out-Null
                $connection.Close()
                return $dataset.Tables[0]
            } -argumentList $sqlQuery

            if ($objects -and $objects.Count -gt 0) {
                Write-Host "   Found $($objects.Count) codeunit(s):" -ForegroundColor Green
                $objects | Format-Table -AutoSize
            } else {
                Write-Host "   No codeunits found in range $CheckCodeunitRange" -ForegroundColor Red
            }
        } catch {
            Write-Host "   Error querying database: $_" -ForegroundColor Red
        }
    }
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan

if ($AppName) {
    $targetApp = $allApps | Where-Object { $_.Name -eq $AppName }
    if ($targetApp) {
        Write-Host "App Installation: PASS" -ForegroundColor Green
    } else {
        Write-Host "App Installation: FAIL" -ForegroundColor Red
    }
}

if ($missingDeps.Count -eq 0) {
    Write-Host "Test Dependencies: PASS" -ForegroundColor Green
} else {
    Write-Host "Test Dependencies: FAIL - Missing: $($missingDeps -join ', ')" -ForegroundColor Red
}

Write-Host ""
