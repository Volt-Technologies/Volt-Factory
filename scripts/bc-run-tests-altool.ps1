# Run BC Tests using AL Test Tool (Page 130409)
param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "CRONUS International Ltd.",
    [string]$TestCodeunitIdRange = "70200..70206"
)

Write-Host "=== Business Central Test Execution (AL Test Tool) ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor White
Write-Host "Company: $CompanyName" -ForegroundColor White
Write-Host "Test Range: $TestCodeunitIdRange" -ForegroundColor White
Write-Host ""

# Check BCContainerHelper
if (-not (Get-Module -ListAvailable -Name BCContainerHelper)) {
    Write-Host "Installing BCContainerHelper..." -ForegroundColor Yellow
    Install-Module BCContainerHelper -Force -Scope CurrentUser
}

Import-Module BCContainerHelper -DisableNameChecking

# Parse range
$rangeParts = $TestCodeunitIdRange -split '\.\.'
$startId = [int]$rangeParts[0]
$endId = [int]$rangeParts[1]

Write-Host "Running tests for codeunit range: $startId..$endId" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

try {
    # Create credential
    $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

    # Create output file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $resultFile = "C:\ProgramData\BcContainerHelper\test-results\TestResults_${timestamp}.xml"

    Write-Host "Executing tests..." -ForegroundColor Yellow

    # Run tests using Get-TestsFromBCContainer and Run-TestsInBCContainer with extensionId
    $testResults = Run-TestsInBcContainer `
        -containerName $ContainerName `
        -companyName $CompanyName `
        -credential $credential `
        -testCodeunitIdRange "$startId..$endId" `
        -XUnitResultFileName $resultFile `
        -detailed `
        -returnTrueIfAllPassed

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "Test execution complete!" -ForegroundColor Green
    Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host ""

    # Parse results
    if (Test-Path $resultFile) {
        [xml]$xmlResults = Get-Content $resultFile

        $totalTests = 0
        $passedTests = 0
        $failedTests = 0
        $testsByCodeunit = @{}

        foreach ($suite in $xmlResults.assemblies.assembly) {
            $suiteTotal = [int]$suite.total
            $suiteFailed = [int]$suite.failed
            $suitePassed = $suiteTotal - $suiteFailed

            $totalTests += $suiteTotal
            $passedTests += $suitePassed
            $failedTests += $suiteFailed

            $testsByCodeunit[$suite.name] = @{
                Total = $suiteTotal
                Passed = $suitePassed
                Failed = $suiteFailed
            }
        }

        Write-Host "=== Test Results Summary ===" -ForegroundColor Cyan
        Write-Host "Total Tests:   $totalTests" -ForegroundColor White
        Write-Host "Passed:        $passedTests" -ForegroundColor Green
        Write-Host "Failed:        $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "White" })

        if ($totalTests -gt 0) {
            $passRate = ($passedTests / $totalTests) * 100
            Write-Host "Pass Rate:     $($passRate.ToString('F1'))%" -ForegroundColor White
        }
        Write-Host ""

        # Breakdown by codeunit
        Write-Host "Breakdown by Test Codeunit:" -ForegroundColor Cyan
        foreach ($codeunit in $testsByCodeunit.Keys | Sort-Object) {
            $result = $testsByCodeunit[$codeunit]
            $status = if ($result.Failed -gt 0) { "FAIL" } else { "PASS" }
            $color = if ($result.Failed -gt 0) { "Red" } else { "Green" }
            Write-Host "  [$status] $codeunit : $($result.Passed)/$($result.Total) passed" -ForegroundColor $color
        }
        Write-Host ""

        # Show failures
        if ($failedTests -gt 0) {
            Write-Host "Failed Tests Details:" -ForegroundColor Red
            Write-Host ""

            foreach ($suite in $xmlResults.assemblies.assembly) {
                $hasFailed = $false
                foreach ($test in $suite.collection.test | Where-Object { $_.result -eq "Fail" }) {
                    if (-not $hasFailed) {
                        Write-Host "  Codeunit: $($suite.name)" -ForegroundColor Yellow
                        $hasFailed = $true
                    }
                    Write-Host "    X $($test.name)" -ForegroundColor Red
                    if ($test.failure) {
                        Write-Host "      Error: $($test.failure.message)" -ForegroundColor Gray
                        if ($test.failure.'stack-trace') {
                            $stackLines = $test.failure.'stack-trace' -split "`n" | Select-Object -First 3
                            foreach ($line in $stackLines) {
                                Write-Host "      $line" -ForegroundColor DarkGray
                            }
                        }
                    }
                    Write-Host ""
                }
            }
        }

        Write-Host "Results file: $resultFile" -ForegroundColor Gray
        Write-Host ""

        if ($failedTests -gt 0) {
            Write-Host "RESULT: FAILED - $failedTests test(s) failed" -ForegroundColor Red
            exit 1
        }
        else {
            Write-Host "RESULT: SUCCESS - All $totalTests tests passed!" -ForegroundColor Green
            exit 0
        }
    }
    else {
        Write-Host "ERROR: Results file not found: $resultFile" -ForegroundColor Red
        Write-Host "This may indicate that no test codeunits were found in the specified range." -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
