<#
.SYNOPSIS
    Creates an isolated Business Central Docker container for development

.DESCRIPTION
    This script uses BCContainerHelper to provision a BC Docker container with specified configuration.
    Designed for parallel development workflows with isolated environments per feature.

.PARAMETER ContainerName
    Name of the container to create (e.g., bc-product-attribute-20251107)

.PARAMETER ImageName
    Docker image name to use or create (default: bcimage)

.PARAMETER ArtifactUrl
    BC artifact URL. If not specified, uses the latest BC sandbox artifact

.PARAMETER Username
    BC admin username (default: admin)

.PARAMETER Password
    BC admin password (default: P@ssw0rd)

.PARAMETER AcceptEula
    Accept the End User License Agreement (default: $true)

.PARAMETER UpdateHosts
    Update the hosts file with container hostname (default: $true)

.PARAMETER Auth
    Authentication type: NavUserPassword or Windows (default: NavUserPassword)

.PARAMETER EnableDevelopmentMode
    Enable development mode for faster publishing (default: $true)

.EXAMPLE
    .\create-bc-container.ps1 -ContainerName "bc-product-attribute-20251107"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,

    [Parameter(Mandatory=$false)]
    [string]$ImageName = "bcimage",

    [Parameter(Mandatory=$false)]
    [string]$ArtifactUrl = "",

    [Parameter(Mandatory=$false)]
    [string]$Username = "admin",

    [Parameter(Mandatory=$false)]
    [string]$Password = "P@ssw0rd",

    [Parameter(Mandatory=$false)]
    [bool]$AcceptEula = $true,

    [Parameter(Mandatory=$false)]
    [bool]$UpdateHosts = $true,

    [Parameter(Mandatory=$false)]
    [string]$Auth = "NavUserPassword",

    [Parameter(Mandatory=$false)]
    [bool]$EnableDevelopmentMode = $true,

    [Parameter(Mandatory=$false)]
    [string]$Isolation = "process"
)

# Script settings
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BC Container Creation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import BCContainerHelper
Write-Host "[1/7] Importing BCContainerHelper module..." -ForegroundColor Yellow
Import-Module BCContainerHelper -Force -ErrorAction Stop
$bcHelperVersion = (Get-Module BCContainerHelper).Version
Write-Host "  - BCContainerHelper version $bcHelperVersion loaded" -ForegroundColor Green

# Check if Docker is running
Write-Host "[2/7] Verifying Docker is running..." -ForegroundColor Yellow
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
    Write-Host "  - Docker is running" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop" -ForegroundColor Red
    exit 1
}

# Check if container already exists
Write-Host "[3/7] Checking for existing container..." -ForegroundColor Yellow
$existingContainer = docker ps -a --filter "name=^${ContainerName}$" --format "{{.Names}}" 2>$null
if ($existingContainer -eq $ContainerName) {
    Write-Host "  - WARNING: Container '$ContainerName' already exists" -ForegroundColor Red
    $response = Read-Host "Do you want to remove it and create a new one? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host "  - Removing existing container..." -ForegroundColor Yellow
        docker stop $ContainerName 2>$null | Out-Null
        docker rm $ContainerName 2>$null | Out-Null
        Write-Host "  - Existing container removed" -ForegroundColor Green
    } else {
        Write-Host "  - Aborting container creation" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  - No existing container found, proceeding..." -ForegroundColor Green
}

# Create credential object
Write-Host "[4/7] Preparing credentials..." -ForegroundColor Yellow
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)
Write-Host "  - Credentials prepared for user: $Username" -ForegroundColor Green

# Get artifact URL if not specified
if ([string]::IsNullOrEmpty($ArtifactUrl)) {
    Write-Host "[5/7] Determining BC artifact URL..." -ForegroundColor Yellow
    try {
        $ArtifactUrl = Get-BCArtifactUrl -type Sandbox -country "w1" -select Latest
        Write-Host "  - Using latest BC sandbox artifact" -ForegroundColor Green
        Write-Host "  - Artifact: $ArtifactUrl" -ForegroundColor Gray
    } catch {
        Write-Host "ERROR: Failed to get BC artifact URL" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[5/7] Using specified artifact URL..." -ForegroundColor Yellow
    Write-Host "  - Artifact: $ArtifactUrl" -ForegroundColor Gray
}

# Prepare container parameters
Write-Host "[6/7] Preparing container configuration..." -ForegroundColor Yellow
$containerParams = @{
    accept_eula = $AcceptEula
    containerName = $ContainerName
    credential = $credential
    auth = $Auth
    artifactUrl = $ArtifactUrl
    imageName = $ImageName
    updateHosts = $UpdateHosts
    memoryLimit = "8G"
    isolation = "process"
    includeTestToolkit = $true
    includeTestLibrariesOnly = $false
    includeTestFrameworkOnly = $false
}

if ($EnableDevelopmentMode) {
    Write-Host "  - Development mode: ENABLED (faster publishing)" -ForegroundColor Green
} else {
    Write-Host "  - Development mode: DISABLED (PTE mode)" -ForegroundColor Yellow
}

Write-Host "  - Container name: $ContainerName" -ForegroundColor Gray
Write-Host "  - Image name: $ImageName" -ForegroundColor Gray
Write-Host "  - Authentication: $Auth" -ForegroundColor Gray
Write-Host "  - Memory limit: 8G" -ForegroundColor Gray
Write-Host "  - Isolation: process" -ForegroundColor Gray

# Create the container
Write-Host "[7/7] Creating BC container (this may take several minutes)..." -ForegroundColor Yellow
Write-Host ""
try {
    New-BcContainer @containerParams
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Container created successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR: Container creation failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Get container information
Write-Host ""
Write-Host "Retrieving container information..." -ForegroundColor Yellow
try {
    $containerInfo = docker inspect $ContainerName | ConvertFrom-Json
    $containerIP = $containerInfo[0].NetworkSettings.Networks.nat.IPAddress

    # Get BC Web Client URL
    $webClientPort = 80
    $webClientUrl = "http://${ContainerName}:$webClientPort/BC"

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "CONTAINER DETAILS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Container Name:   $ContainerName" -ForegroundColor White
    Write-Host "Image:            $ImageName" -ForegroundColor White
    Write-Host "Status:           Running" -ForegroundColor Green
    Write-Host "IP Address:       $containerIP" -ForegroundColor White
    Write-Host ""
    Write-Host "Web Client URL:   $webClientUrl" -ForegroundColor White
    Write-Host "Username:         $Username" -ForegroundColor White
    Write-Host "Password:         $Password" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "NEXT STEPS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Access BC Web Client: $webClientUrl" -ForegroundColor White
    Write-Host "2. The container is ready for development" -ForegroundColor White
    Write-Host "3. Deploy extensions using container name: $ContainerName" -ForegroundColor White
    if ($EnableDevelopmentMode) {
        Write-Host "4. Development mode is enabled for faster publishing" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Management Commands:" -ForegroundColor Yellow
    Write-Host "  - View logs:     docker logs $ContainerName" -ForegroundColor Gray
    Write-Host "  - Stop:          docker stop $ContainerName" -ForegroundColor Gray
    Write-Host "  - Start:         docker start $ContainerName" -ForegroundColor Gray
    Write-Host "  - Remove:        docker stop $ContainerName; docker rm $ContainerName" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "WARNING: Could not retrieve detailed container information" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

Write-Host "Container creation completed successfully!" -ForegroundColor Green
Write-Host ""
