# Run all tests in BC Test app using extensionId
param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "CRONUS International Ltd."
)

$extensionId = "fff9ead6-096d-4948-8662-199077bbaed3"  # BC Test app ID
$extensionName = "BC Test"

Write-Host "=== Business Central Test Execution ===" -ForegroundColor Cyan
Write-Host "Container:   $ContainerName" -ForegroundColor White
Write-Host "Company:     $CompanyName" -ForegroundColor White
Write-Host "Extension:   $extensionName" -ForegroundColor White
Write-Host "Extension ID: $extensionId" -ForegroundColor Gray
Write-Host ""

# Check BCContainerHelper
if (-not (Get-Module -ListAvailable -Name BCContainerHelper)) {
    Write-Host "Installing BCContainerHelper..." -ForegroundColor Yellow
    Install-Module BCContainerHelper -Force -Scope CurrentUser
}

Import-Module BCContainerHelper -DisableNameChecking

Write-Host "Executing all tests in $extensionName..." -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

try {
    # Create credential
    $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

    # Create output file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $resultFile = "C:\ProgramData\BcContainerHelper\test-results\TestResults_${extensionName}_${timestamp}.xml"

    # Ensure output directory exists
    $outputDir = Split-Path $resultFile -Parent
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    Write-Host "Results will be saved to: $resultFile" -ForegroundColor Gray
    Write-Host ""

    # Run tests using extensionId
    $testsPassed = Run-TestsInBcContainer `
        -containerName $ContainerName `
        -companyName $CompanyName `
        -credential $credential `
        -extensionId $extensionId `
        -XUnitResultFileName $resultFile `
        -detailed `
        -returnTrueIfAllPassed

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "Test execution complete!" -ForegroundColor Green
    Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host ""

    # Parse and display results
    if (Test-Path $resultFile) {
        [xml]$xmlResults = Get-Content $resultFile

        $totalTests = 0
        $passedTests = 0
        $failedTests = 0
        $skippedTests = 0
        $testsByCodeunit = @()

        foreach ($suite in $xmlResults.assemblies.assembly) {
            $suiteTotal = [int]$suite.total
            $suiteFailed = [int]$suite.failed
            $suiteSkipped = [int]$suite.skipped
            $suitePassed = $suiteTotal - $suiteFailed - $suiteSkipped

            $totalTests += $suiteTotal
            $passedTests += $suitePassed
            $failedTests += $suiteFailed
            $skippedTests += $suiteSkipped

            $testsByCodeunit += @{
                Name = $suite.name
                Total = $suiteTotal
                Passed = $suitePassed
                Failed = $suiteFailed
                Skipped = $suiteSkipped
                Tests = $suite.collection.test
            }
        }

        Write-Host "=== Test Results Summary ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Total Tests:   $totalTests" -ForegroundColor White
        Write-Host "Passed:        $passedTests" -ForegroundColor Green
        Write-Host "Failed:        $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "White" })
        if ($skippedTests -gt 0) {
            Write-Host "Skipped:       $skippedTests" -ForegroundColor Yellow
        }

        if ($totalTests -gt 0) {
            $passRate = ($passedTests / $totalTests) * 100
            Write-Host "Pass Rate:     $($passRate.ToString('F1'))%" -ForegroundColor $(if ($passRate -eq 100) { "Green" } else { "Yellow" })
        }
        Write-Host ""

        # Breakdown by codeunit
        Write-Host "=== Breakdown by Test Codeunit ===" -ForegroundColor Cyan
        Write-Host ""
        foreach ($codeunit in $testsByCodeunit | Sort-Object Name) {
            $status = if ($codeunit.Failed -gt 0) { "FAIL" } else { "PASS" }
            $color = if ($codeunit.Failed -gt 0) { "Red" } else { "Green" }
            $failInfo = if ($codeunit.Failed -gt 0) { " ($($codeunit.Failed) failed)" } else { "" }
            Write-Host "  [$status] $($codeunit.Name): $($codeunit.Passed)/$($codeunit.Total) passed$failInfo" -ForegroundColor $color
        }
        Write-Host ""

        # Show failures if any
        if ($failedTests -gt 0) {
            Write-Host "=== Failed Tests Details ===" -ForegroundColor Red
            Write-Host ""

            foreach ($codeunit in $testsByCodeunit | Where-Object { $_.Failed -gt 0 }) {
                Write-Host "Codeunit: $($codeunit.Name)" -ForegroundColor Yellow
                Write-Host ""

                foreach ($test in $codeunit.Tests | Where-Object { $_.result -eq "Fail" }) {
                    Write-Host "  X $($test.name)" -ForegroundColor Red
                    if ($test.failure) {
                        Write-Host ""
                        Write-Host "    Error Message:" -ForegroundColor Gray
                        $errorMessage = $test.failure.message
                        foreach ($line in $errorMessage -split "`n") {
                            Write-Host "    $line" -ForegroundColor Gray
                        }
                        Write-Host ""

                        if ($test.failure.'stack-trace') {
                            Write-Host "    Stack Trace:" -ForegroundColor DarkGray
                            $stackLines = $test.failure.'stack-trace' -split "`n" | Select-Object -First 5
                            foreach ($line in $stackLines) {
                                Write-Host "    $line" -ForegroundColor DarkGray
                            }
                            Write-Host ""
                        }
                    }
                }
            }
        }

        Write-Host "Results saved to: $resultFile" -ForegroundColor Gray
        Write-Host ""

        # Final result
        if ($failedTests -gt 0) {
            Write-Host "RESULT: FAILED - $failedTests of $totalTests test(s) failed" -ForegroundColor Red
            exit 1
        }
        else {
            Write-Host "RESULT: SUCCESS - All $totalTests tests passed!" -ForegroundColor Green
            exit 0
        }
    }
    else {
        Write-Host "ERROR: Results file not found: $resultFile" -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible causes:" -ForegroundColor Yellow
        Write-Host "  - No test codeunits found in extension" -ForegroundColor Yellow
        Write-Host "  - Extension not properly installed" -ForegroundColor Yellow
        Write-Host "  - Test framework not available" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "ERROR after $($duration.ToString('mm\:ss'))" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
