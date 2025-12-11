<#
.SYNOPSIS
    Runs AL tests in BC Docker containers using BCContainerHelper

.DESCRIPTION
    This script executes BC tests using BCContainerHelper PowerShell module.
    It reads configuration from .env file and supports various parameters.

.PARAMETER ContainerName
    Name of the BC container (default: from CURRENT_FEATURE_CONTAINER in .env)

.PARAMETER TestCodeunitIdRange
    Test codeunit ID range (e.g., '70200..70249'). REQUIRED.

.PARAMETER CompanyName
    BC Company name (default: from BC_COMPANY_NAME in .env or "CRONUS International Ltd.")

.PARAMETER OutputPath
    Path for test results (default: test-results)

.PARAMETER Username
    BC admin username (default: from BC_LOCAL_USERNAME in .env or "admin")

.PARAMETER Password
    BC admin password (default: from BC_LOCAL_PASSWORD in .env)

.EXAMPLE
    .\bc-run-tests.ps1 -TestCodeunitIdRange "70200..70249"

.EXAMPLE
    .\bc-run-tests.ps1 -ContainerName "bc-my-feature" -TestCodeunitIdRange "70200..70206"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ContainerName,

    [Parameter(Mandatory=$true)]
    [string]$TestCodeunitIdRange,

    [Parameter(Mandatory=$false)]
    [string]$CompanyName,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "test-results",

    [Parameter(Mandatory=$false)]
    [string]$Username,

    [Parameter(Mandatory=$false)]
    [string]$Password
)

$ErrorActionPreference = "Stop"

Write-Host "=== Business Central Test Execution ===" -ForegroundColor Cyan
Write-Host ""

# Load configuration from .env file
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptPath
$envFile = Join-Path $RepoRoot ".env"

if (Test-Path $envFile) {
    Write-Host "Loading configuration from .env file..." -ForegroundColor Yellow
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
    Write-Host ""
}

# Resolve parameters from .env or defaults
if (-not $ContainerName) {
    $ContainerName = $env:CURRENT_FEATURE_CONTAINER
    if (-not $ContainerName) { $ContainerName = "bc" }
}

if (-not $CompanyName) {
    $CompanyName = $env:BC_COMPANY_NAME
    if (-not $CompanyName) { $CompanyName = "CRONUS International Ltd." }
}

if (-not $Username) {
    $Username = $env:BC_LOCAL_USERNAME
    if (-not $Username) { $Username = "admin" }
}

if (-not $Password) {
    $Password = $env:BC_LOCAL_PASSWORD
    if (-not $Password) {
        Write-Host "ERROR: Password not specified and BC_LOCAL_PASSWORD not found in .env" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Container:  $ContainerName" -ForegroundColor White
Write-Host "  Company:    $CompanyName" -ForegroundColor White
Write-Host "  Test Range: $TestCodeunitIdRange" -ForegroundColor White
Write-Host "  Username:   $Username" -ForegroundColor White
Write-Host ""

# Check BCContainerHelper module
Write-Host "Checking BCContainerHelper module..." -ForegroundColor Yellow
$bcContainerHelper = Get-Module -ListAvailable -Name BCContainerHelper

if (-not $bcContainerHelper) {
    Write-Host "BCContainerHelper module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name BCContainerHelper -Force -Scope CurrentUser -AllowClobber
}
Import-Module BCContainerHelper -DisableNameChecking
Write-Host "BCContainerHelper loaded" -ForegroundColor Green

# Verify container is running
Write-Host "Verifying container '$ContainerName'..." -ForegroundColor Yellow
$containerRunning = docker ps --format "{{.Names}}" | Select-String -Pattern "^$ContainerName$"
if (-not $containerRunning) {
    Write-Host "ERROR: Container '$ContainerName' is not running" -ForegroundColor Red
    exit 1
}
Write-Host "Container is running" -ForegroundColor Green

# Create output directory
$bcHelperPath = "C:\ProgramData\BcContainerHelper"
$outputDir = Join-Path $bcHelperPath $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Parse test range
$rangeParts = $TestCodeunitIdRange -split '\.\.'
if ($rangeParts.Count -ne 2) {
    Write-Host "ERROR: Invalid test range format. Use: 'StartId..EndId'" -ForegroundColor Red
    exit 1
}
$startId = [int]$rangeParts[0]

Write-Host ""
Write-Host "Starting Test Execution..." -ForegroundColor Cyan
Write-Host ""

try {
    $startTime = Get-Date
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $resultsFile = Join-Path $outputDir "TestResults_${timestamp}.xml"

    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)

    $testResults = Run-TestsInBcContainer `
        -containerName $ContainerName `
        -companyName $CompanyName `
        -credential $credential `
        -testCodeunit $startId `
        -testRunnerCodeunitId 130451 `
        -XUnitResultFileName $resultsFile `
        -Verbose

    $duration = (Get-Date) - $startTime

    Write-Host ""
    Write-Host "Test Execution Complete" -ForegroundColor Cyan
    Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White

    # Parse and display results
    if (Test-Path $resultsFile) {
        [xml]$xmlResults = Get-Content $resultsFile
        $testResults = @{}

        foreach ($assembly in $xmlResults.assemblies.assembly) {
            foreach ($collection in $assembly.collection) {
                foreach ($test in $collection.test) {
                    $testName = $test.name
                    $testResult = $test.result

                    if (-not $testResults.ContainsKey($testName)) {
                        $testResults[$testName] = @{
                            Name = $testName
                            Result = $testResult
                            Message = if ($test.failure) { $test.failure.message } else { "" }
                        }
                    } elseif ($testResult -eq "Pass" -and $testResults[$testName].Result -eq "Fail") {
                        $testResults[$testName].Result = "Pass"
                        $testResults[$testName].Message = ""
                    }
                }
            }
        }

        $totalTests = $testResults.Count
        $passedTests = @($testResults.Values | Where-Object { $_.Result -eq "Pass" }).Count
        $failedTests = @($testResults.Values | Where-Object { $_.Result -eq "Fail" }).Count

        Write-Host ""
        Write-Host "Results:" -ForegroundColor Cyan
        Write-Host "  Total:  $totalTests" -ForegroundColor White
        Write-Host "  Passed: $passedTests" -ForegroundColor Green
        Write-Host "  Failed: $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "White" })

        if ($failedTests -gt 0) {
            Write-Host ""
            Write-Host "Failed Tests:" -ForegroundColor Red
            foreach ($test in ($testResults.Values | Where-Object { $_.Result -eq "Fail" })) {
                Write-Host "  - $($test.Name)" -ForegroundColor Red
                if ($test.Message) { Write-Host "    $($test.Message)" -ForegroundColor Gray }
            }
            exit 1
        }

        Write-Host ""
        Write-Host "SUCCESS: All tests passed!" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "WARNING: Results file not found" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: Test execution failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
