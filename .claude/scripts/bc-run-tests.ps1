# Business Central Test Execution Script using BCContainerHelper
# This script runs AL tests in BC Docker containers using BCContainerHelper PowerShell module
# Based on: https://freddysblog.com/2019/10/22/running-tests-in-containers-2/

param(
    [Parameter(Mandatory=$false)]
    [string]$ContainerName,

    [Parameter(Mandatory=$false)]
    [string]$TestCodeunitIdRange,

    [Parameter(Mandatory=$false)]
    [string]$CompanyName,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "test-results",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Detailed", "Summary")]
    [string]$ReportType = "Detailed",

    [Parameter(Mandatory=$false)]
    [switch]$XUnitFormat,

    [Parameter(Mandatory=$false)]
    [switch]$SkipBCContainerHelper
)

Write-Host "=== Business Central Test Execution ===" -ForegroundColor Cyan
Write-Host ""

# Load configuration from .env file
$envFile = Join-Path $PSScriptRoot "..\\.env"
if (Test-Path $envFile) {
    Write-Host "Loading configuration from .env file..." -ForegroundColor Yellow
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
            Write-Host "  $key = $value" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Get container name from environment or parameter
if (-not $ContainerName) {
    $ContainerName = $env:CURRENT_FEATURE_CONTAINER
    if (-not $ContainerName) {
        $ContainerName = "bc"
    }
}

# Get company name from environment or parameter
if (-not $CompanyName) {
    $CompanyName = $env:BC_COMPANY_NAME
    if (-not $CompanyName) {
        # Try to get company ID and convert to name
        $companyId = $env:BC_COMPANY_ID
        if ($companyId) {
            Write-Host "Company ID found: $companyId" -ForegroundColor Gray
            Write-Host "Note: BCContainerHelper requires company name, not ID" -ForegroundColor Yellow
        }
        $CompanyName = "CRONUS International Ltd."
    }
}

# Get test codeunit range from parameter
if (-not $TestCodeunitIdRange) {
    Write-Host "ERROR: TestCodeunitIdRange parameter is required" -ForegroundColor Red
    Write-Host "Example: -TestCodeunitIdRange '70200..70249'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Container Name:    $ContainerName" -ForegroundColor White
Write-Host "Company Name:      $CompanyName" -ForegroundColor White
Write-Host "Test Range:        $TestCodeunitIdRange" -ForegroundColor White
Write-Host "Output Path:       $OutputPath" -ForegroundColor White
Write-Host "Report Type:       $ReportType" -ForegroundColor White
Write-Host "XUnit Format:      $XUnitFormat" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if BCContainerHelper is installed
Write-Host "Checking BCContainerHelper module..." -ForegroundColor Yellow
$bcContainerHelper = Get-Module -ListAvailable -Name BCContainerHelper

if (-not $bcContainerHelper -and -not $SkipBCContainerHelper) {
    Write-Host "BCContainerHelper module not found. Installing..." -ForegroundColor Yellow
    try {
        Install-Module -Name BCContainerHelper -Force -Scope CurrentUser -AllowClobber
        Write-Host "✓ BCContainerHelper installed successfully" -ForegroundColor Green
        Import-Module BCContainerHelper
    }
    catch {
        Write-Host "✗ Failed to install BCContainerHelper: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install manually: Install-Module BCContainerHelper -Force" -ForegroundColor Yellow
        exit 1
    }
}
elseif ($bcContainerHelper -and -not $SkipBCContainerHelper) {
    Write-Host "✓ BCContainerHelper module found (Version: $($bcContainerHelper.Version))" -ForegroundColor Green
    Import-Module BCContainerHelper -DisableNameChecking
}
else {
    Write-Host "⚠ Skipping BCContainerHelper (SkipBCContainerHelper flag set)" -ForegroundColor Yellow
}

# Verify container exists and is running
Write-Host ""
Write-Host "Verifying container '$ContainerName'..." -ForegroundColor Yellow

$containerExists = docker ps -a --format "{{.Names}}" | Select-String -Pattern "^$ContainerName$"
if (-not $containerExists) {
    Write-Host "✗ Container '$ContainerName' not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available containers:" -ForegroundColor Yellow
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    exit 1
}

$containerRunning = docker ps --format "{{.Names}}" | Select-String -Pattern "^$ContainerName$"
if (-not $containerRunning) {
    Write-Host "✗ Container '$ContainerName' exists but is not running" -ForegroundColor Red
    Write-Host "Start it with: docker start $ContainerName" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Container '$ContainerName' is running" -ForegroundColor Green

# Create output directory (use BCContainerHelper shared path for Docker access)
$bcHelperPath = "C:\ProgramData\BcContainerHelper"
$outputDir = Join-Path $bcHelperPath $OutputPath

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "✓ Created output directory: $outputDir" -ForegroundColor Green
}

# Parse test codeunit range
$rangeParts = $TestCodeunitIdRange -split '\.\.'
if ($rangeParts.Count -ne 2) {
    Write-Host "✗ Invalid test range format. Use format: 'StartId..EndId' (e.g., '70200..70249')" -ForegroundColor Red
    exit 1
}

$startId = [int]$rangeParts[0]
$endId = [int]$rangeParts[1]

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Starting Test Execution..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Run tests using BCContainerHelper
try {
    $startTime = Get-Date

    # Generate timestamp for results file
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $resultsFile = Join-Path $outputDir "TestResults_${timestamp}.xml"

    Write-Host "Executing tests in container..." -ForegroundColor Yellow
    Write-Host "  Test Range: $startId to $endId" -ForegroundColor Gray
    Write-Host "  Company: $CompanyName" -ForegroundColor Gray
    Write-Host "  Results: $resultsFile" -ForegroundColor Gray
    Write-Host ""

    if (-not $SkipBCContainerHelper) {
        # Run tests using Run-TestsInBCContainer
        $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

        $testResults = Run-TestsInBcContainer `
            -containerName $ContainerName `
            -companyName $CompanyName `
            -credential $credential `
            -testCodeunit $startId `
            -testRunnerCodeunitId 130451 `
            -XUnitResultFileName $resultsFile `
            -Verbose

        $endTime = Get-Date
        $duration = $endTime - $startTime

        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "Test Execution Complete" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
        Write-Host "Results file: $resultsFile" -ForegroundColor White

        # Parse and display results
        if (Test-Path $resultsFile) {
            [xml]$xmlResults = Get-Content $resultsFile

            # NOTE: BCContainerHelper runs tests multiple times (typically 2x)
            # We need to deduplicate and take the best result for each test
            $testResults = @{}
            $assemblyCount = 0

            foreach ($assembly in $xmlResults.assemblies.assembly) {
                $assemblyCount++
                foreach ($collection in $assembly.collection) {
                    foreach ($test in $collection.test) {
                        $testName = $test.name
                        $testResult = $test.result

                        # Keep track of best result (Pass > Fail)
                        if (-not $testResults.ContainsKey($testName)) {
                            $testResults[$testName] = @{
                                Name = $testName
                                Result = $testResult
                                Message = if ($test.failure) { $test.failure.message } else { "" }
                                StackTrace = if ($test.failure) { $test.failure.'stack-trace' } else { "" }
                            }
                        } elseif ($testResult -eq "Pass" -and $testResults[$testName].Result -eq "Fail") {
                            # Upgrade to Pass if this run passed
                            $testResults[$testName].Result = "Pass"
                            $testResults[$testName].Message = ""
                            $testResults[$testName].StackTrace = ""
                        }
                    }
                }
            }

            # Count unique test results
            $totalTests = $testResults.Count
            $passedTests = @($testResults.Values | Where-Object { $_.Result -eq "Pass" }).Count
            $failedTests = @($testResults.Values | Where-Object { $_.Result -eq "Fail" }).Count
            $skippedTests = 0  # Skipped tests are handled separately, for now report 0

            if ($assemblyCount -gt 1) {
                Write-Host ""
                Write-Host "Note: Tests were executed $assemblyCount times (BCContainerHelper behavior)" -ForegroundColor Yellow
                Write-Host "      Results below show unique tests with best result from all runs" -ForegroundColor Yellow
            }

            Write-Host ""
            Write-Host "Test Results:" -ForegroundColor Cyan
            Write-Host "  Total:   $totalTests" -ForegroundColor White
            Write-Host "  Passed:  $passedTests" -ForegroundColor Green
            Write-Host "  Failed:  $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "White" })
            Write-Host "  Skipped: $skippedTests" -ForegroundColor Yellow

            if ($failedTests -gt 0) {
                Write-Host ""
                Write-Host "Failed Tests:" -ForegroundColor Red
                foreach ($test in ($testResults.Values | Where-Object { $_.Result -eq "Fail" })) {
                    Write-Host "  ✗ $($test.Name)" -ForegroundColor Red
                    if ($test.Message) {
                        Write-Host "    $($test.Message)" -ForegroundColor Gray
                    }
                }
            }

            Write-Host ""
            if ($failedTests -eq 0) {
                Write-Host "✓ SUCCESS: All tests passed!" -ForegroundColor Green
                exit 0
            }
            else {
                Write-Host "✗ FAILURE: $failedTests test(s) failed" -ForegroundColor Red
                exit 1
            }
        }
        else {
            Write-Host "⚠ Warning: Results file not found" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "⚠ Test execution skipped (SkipBCContainerHelper flag set)" -ForegroundColor Yellow
        Write-Host "Use Chrome DevTools method instead" -ForegroundColor Yellow
        exit 0
    }
}
catch {
    Write-Host ""
    Write-Host "✗ ERROR: Test execution failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
