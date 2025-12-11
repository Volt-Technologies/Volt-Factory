<#
.SYNOPSIS
    Creates an isolated Business Central Docker container for development

.DESCRIPTION
    Uses BCContainerHelper to provision a BC Docker container.
    Reads configuration from .env file and supports various parameters.

.PARAMETER ContainerName
    Name of the container to create. REQUIRED.

.PARAMETER ImageName
    Docker image name (default: bcimage)

.PARAMETER ArtifactUrl
    BC artifact URL (default: latest BC sandbox)

.PARAMETER Username
    BC admin username (default: from BC_LOCAL_USERNAME in .env or "admin")

.PARAMETER Password
    BC admin password (default: from BC_LOCAL_PASSWORD in .env)

.PARAMETER MemoryLimit
    Container memory limit (default: 8G)

.PARAMETER IncludeTestToolkit
    Include test toolkit for running tests (default: true)

.EXAMPLE
    .\bc-create-container.ps1 -ContainerName "bc-my-feature"

.EXAMPLE
    .\bc-create-container.ps1 -ContainerName "bc-test" -MemoryLimit "12G"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,

    [Parameter(Mandatory=$false)]
    [string]$ImageName = "bcimage",

    [Parameter(Mandatory=$false)]
    [string]$ArtifactUrl = "",

    [Parameter(Mandatory=$false)]
    [string]$Username,

    [Parameter(Mandatory=$false)]
    [string]$Password,

    [Parameter(Mandatory=$false)]
    [string]$MemoryLimit = "8G",

    [Parameter(Mandatory=$false)]
    [bool]$IncludeTestToolkit = $true,

    [Parameter(Mandatory=$false)]
    [bool]$UpdateHosts = $true
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BC Container Creation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration from .env file
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptPath
$envFile = Join-Path $RepoRoot ".env"

if (Test-Path $envFile) {
    Write-Host "[1/7] Loading configuration from .env file..." -ForegroundColor Yellow
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

# Resolve parameters from .env or defaults
if (-not $Username) {
    $Username = $env:BC_LOCAL_USERNAME
    if (-not $Username) { $Username = "admin" }
}

if (-not $Password) {
    $Password = $env:BC_LOCAL_PASSWORD
    if (-not $Password) { $Password = "P@ssw0rd" }
}

Write-Host "  - Container: $ContainerName" -ForegroundColor Green
Write-Host "  - Username: $Username" -ForegroundColor Green

# Import BCContainerHelper
Write-Host "[2/7] Importing BCContainerHelper module..." -ForegroundColor Yellow
Import-Module BCContainerHelper -Force -ErrorAction Stop
$bcHelperVersion = (Get-Module BCContainerHelper).Version
Write-Host "  - BCContainerHelper version $bcHelperVersion loaded" -ForegroundColor Green

# Check if Docker is running
Write-Host "[3/7] Verifying Docker is running..." -ForegroundColor Yellow
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker is not running" }
    Write-Host "  - Docker is running" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop" -ForegroundColor Red
    exit 1
}

# Check if container already exists
Write-Host "[4/7] Checking for existing container..." -ForegroundColor Yellow
$existingContainer = docker ps -a --filter "name=^${ContainerName}$" --format "{{.Names}}" 2>$null
if ($existingContainer -eq $ContainerName) {
    Write-Host "  - WARNING: Container '$ContainerName' already exists" -ForegroundColor Red
    $response = Read-Host "Remove and recreate? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        docker stop $ContainerName 2>$null | Out-Null
        docker rm $ContainerName 2>$null | Out-Null
        Write-Host "  - Existing container removed" -ForegroundColor Green
    } else {
        Write-Host "  - Aborting" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  - No existing container found" -ForegroundColor Green
}

# Create credential
Write-Host "[5/7] Preparing credentials..." -ForegroundColor Yellow
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)
Write-Host "  - Credentials prepared for user: $Username" -ForegroundColor Green

# Get artifact URL
if ([string]::IsNullOrEmpty($ArtifactUrl)) {
    Write-Host "[6/7] Getting latest BC artifact URL..." -ForegroundColor Yellow
    $ArtifactUrl = Get-BCArtifactUrl -type Sandbox -country "w1" -select Latest
    Write-Host "  - Using: $ArtifactUrl" -ForegroundColor Gray
} else {
    Write-Host "[6/7] Using specified artifact URL..." -ForegroundColor Yellow
}

# Create container
Write-Host "[7/7] Creating BC container (this may take several minutes)..." -ForegroundColor Yellow
Write-Host ""

$containerParams = @{
    accept_eula = $true
    containerName = $ContainerName
    credential = $credential
    auth = "NavUserPassword"
    artifactUrl = $ArtifactUrl
    imageName = $ImageName
    updateHosts = $UpdateHosts
    memoryLimit = $MemoryLimit
    isolation = "process"
    includeTestToolkit = $IncludeTestToolkit
    includeTestLibrariesOnly = $false
    includeTestFrameworkOnly = $false
}

try {
    New-BcContainer @containerParams
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Container created successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Container creation failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Get container info
Write-Host ""
Write-Host "Retrieving container information..." -ForegroundColor Yellow
try {
    $containerInfo = docker inspect $ContainerName | ConvertFrom-Json
    $containerIP = $containerInfo[0].NetworkSettings.Networks.nat.IPAddress
    $webClientUrl = "http://${ContainerName}/BC"

    Write-Host ""
    Write-Host "CONTAINER DETAILS" -ForegroundColor Cyan
    Write-Host "  Container:   $ContainerName" -ForegroundColor White
    Write-Host "  IP Address:  $containerIP" -ForegroundColor White
    Write-Host "  Web Client:  $webClientUrl" -ForegroundColor White
    Write-Host "  Username:    $Username" -ForegroundColor White
    Write-Host "  Password:    $Password" -ForegroundColor White
    Write-Host ""
    Write-Host "Management Commands:" -ForegroundColor Yellow
    Write-Host "  docker logs $ContainerName" -ForegroundColor Gray
    Write-Host "  docker stop $ContainerName" -ForegroundColor Gray
    Write-Host "  docker start $ContainerName" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "WARNING: Could not retrieve container info" -ForegroundColor Yellow
}

Write-Host "Container creation completed!" -ForegroundColor Green
