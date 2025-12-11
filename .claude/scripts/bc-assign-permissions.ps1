<#
.SYNOPSIS
    Assigns permission sets to BC users in a Docker container

.DESCRIPTION
    Uses BCContainerHelper to assign permission sets to users.
    Commonly used to assign SUPER permissions for testing.

.PARAMETER ContainerName
    Name of the BC container (default: from CURRENT_FEATURE_CONTAINER in .env)

.PARAMETER UserName
    BC username to assign permissions to (default: from BC_LOCAL_USERNAME in .env or "admin")

.PARAMETER PermissionSet
    Permission set to assign (default: SUPER)

.EXAMPLE
    .\bc-assign-permissions.ps1

.EXAMPLE
    .\bc-assign-permissions.ps1 -PermissionSet "D365 FULL ACCESS"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ContainerName,

    [Parameter(Mandatory=$false)]
    [string]$UserName,

    [Parameter(Mandatory=$false)]
    [string]$PermissionSet = "SUPER"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== BC Permission Assignment ===" -ForegroundColor Cyan
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

# Resolve parameters
if (-not $ContainerName) {
    $ContainerName = $env:CURRENT_FEATURE_CONTAINER
    if (-not $ContainerName) {
        Write-Host "ERROR: ContainerName not specified and CURRENT_FEATURE_CONTAINER not found in .env" -ForegroundColor Red
        exit 1
    }
}

if (-not $UserName) {
    $UserName = $env:BC_LOCAL_USERNAME
    if (-not $UserName) { $UserName = "admin" }
}

Write-Host "Container:      $ContainerName" -ForegroundColor White
Write-Host "User:           $UserName" -ForegroundColor White
Write-Host "Permission Set: $PermissionSet" -ForegroundColor White
Write-Host ""

# Import BCContainerHelper
Import-Module BcContainerHelper -DisableNameChecking

Write-Host "Assigning $PermissionSet to $UserName..." -ForegroundColor Yellow

try {
    Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        param($targetUser, $permSet)

        Import-Module 'C:\Program Files\Microsoft Dynamics NAV\*\Service\NavAdminTool.ps1' -DisableNameChecking
        $ServerInstance = 'BC'

        # Get user
        $users = Get-NAVServerUser -ServerInstance $ServerInstance -Tenant default
        $user = $users | Where-Object { $_.UserName -eq $targetUser }

        if (-not $user) {
            Write-Host "User '$targetUser' not found!" -ForegroundColor Red
            return
        }

        Write-Host "Found user: $($user.UserName)" -ForegroundColor Green

        # Check current permissions
        $currentPerms = Get-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant default -Sid $user.UserSecurityId
        $hasPermSet = $currentPerms | Where-Object { $_.PermissionSetID -eq $permSet }

        if ($hasPermSet) {
            Write-Host "$permSet already assigned" -ForegroundColor Green
        } else {
            Write-Host "Assigning $permSet..." -ForegroundColor Yellow
            New-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant default -Sid $user.UserSecurityId -PermissionSetId $permSet
            Write-Host "$permSet assigned successfully!" -ForegroundColor Green
        }

        # Show current permissions
        Write-Host ""
        Write-Host "Current permissions for $targetUser :" -ForegroundColor Cyan
        $currentPerms = Get-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant default -Sid $user.UserSecurityId
        $currentPerms | ForEach-Object { Write-Host "  - $($_.PermissionSetID)" }

    } -argumentList $UserName, $PermissionSet

    Write-Host ""
    Write-Host "Permission assignment complete!" -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
