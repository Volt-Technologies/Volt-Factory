# Business Central Test Execution Script using BCContainerHelper
# Simplified version for reliable execution

param(
    [Parameter(Mandatory=$true)]
    [string]$TestCodeunitIdRange,

    [Parameter(Mandatory=$false)]
    [string]$ContainerName = "bc-product-attributes",

    [Parameter(Mandatory=$false)]
    [string]$CompanyName = "CRONUS International Ltd."
)

Write-Host "=== Business Central Test Execution ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor White
Write-Host "Company: $CompanyName" -ForegroundColor White
Write-Host "Test Range: $TestCodeunitIdRange" -ForegroundColor White
Write-Host ""

# Parse test range
$rangeParts = $TestCodeunitIdRange -split '\.\.'
if ($rangeParts.Count -ne 2) {
    Write-Host "ERROR: Invalid range format. Use: StartId..EndId" -ForegroundColor Red
    exit 1
}

$startId = [int]$rangeParts[0]
$endId = [int]$rangeParts[1]

# Check BCContainerHelper
Write-Host "Checking BCContainerHelper..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name BCContainerHelper)) {
    Write-Host "Installing BCContainerHelper..." -ForegroundColor Yellow
    Install-Module BCContainerHelper -Force -Scope CurrentUser
}

Import-Module BCContainerHelper -DisableNameChecking
Write-Host "BCContainerHelper loaded" -ForegroundColor Green
Write-Host ""

# Verify container
Write-Host "Verifying container..." -ForegroundColor Yellow
$containerRunning = docker ps --format "{{.Names}}" | Select-String -Pattern "^$ContainerName$"
if (-not $containerRunning) {
    Write-Host "ERROR: Container '$ContainerName' not running" -ForegroundColor Red
    exit 1
}
Write-Host "Container is running" -ForegroundColor Green
Write-Host ""

# Create output directory (use BCContainerHelper shared path)
$bcHelperPath = "C:\ProgramData\BcContainerHelper"
$outputDir = Join-Path $bcHelperPath "test-results"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Generate results file
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$resultsFile = Join-Path $outputDir "TestResults_${timestamp}.xml"

Write-Host "Executing tests..." -ForegroundColor Yellow
Write-Host "Results: $resultsFile" -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

try {
    # Create credential
    $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

    # Run tests for each codeunit in range
    for ($codeunitId = $startId; $codeunitId -le $endId; $codeunitId++) {
        Write-Host "Running codeunit $codeunitId..." -ForegroundColor Cyan

        $result = Run-TestsInBcContainer `
            -containerName $ContainerName `
            -companyName $CompanyName `
            -credential $credential `
            -testCodeunit $codeunitId `
            -XUnitResultFileName $resultsFile `
            -detailed

        Write-Host "Completed codeunit $codeunitId" -ForegroundColor Green
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "Test execution complete!" -ForegroundColor Green
    Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host ""

    # Parse results
    if (Test-Path $resultsFile) {
        [xml]$xmlResults = Get-Content $resultsFile

        $totalTests = 0
        $passedTests = 0
        $failedTests = 0

        foreach ($suite in $xmlResults.testsuites.testsuite) {
            $totalTests += [int]$suite.tests
            $failedTests += [int]$suite.failures + [int]$suite.errors
        }
        $passedTests = $totalTests - $failedTests

        Write-Host "Results:" -ForegroundColor Cyan
        Write-Host "  Total:   $totalTests" -ForegroundColor White
        Write-Host "  Passed:  $passedTests" -ForegroundColor Green
        Write-Host "  Failed:  $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "White" })
        Write-Host ""

        if ($failedTests -gt 0) {
            Write-Host "Failed tests:" -ForegroundColor Red
            foreach ($suite in $xmlResults.testsuites.testsuite) {
                foreach ($test in $suite.testcase | Where-Object { $_.failure -or $_.error }) {
                    Write-Host "  X $($test.name)" -ForegroundColor Red
                    if ($test.failure) {
                        Write-Host "    $($test.failure.message)" -ForegroundColor Gray
                    }
                }
            }
            Write-Host ""
            Write-Host "FAILURE: $failedTests test(s) failed" -ForegroundColor Red
            exit 1
        }
        else {
            Write-Host "SUCCESS: All tests passed!" -ForegroundColor Green
            exit 0
        }
    }
    else {
        Write-Host "WARNING: Results file not found" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
