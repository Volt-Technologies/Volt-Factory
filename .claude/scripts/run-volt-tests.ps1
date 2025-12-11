param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "My Company",
    [string]$TestCodeunitRange = "70200..70204"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "=== Business Central Test Execution ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor White
Write-Host "Company: $CompanyName" -ForegroundColor White
Write-Host "Test Range: $TestCodeunitRange" -ForegroundColor White
Write-Host ""

$bcHelperPath = "C:\ProgramData\BcContainerHelper"
$outputDir = Join-Path $bcHelperPath "test-results"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$resultsFile = Join-Path $outputDir "TestResults_Volt_${timestamp}.xml"

Write-Host "Results file: $resultsFile" -ForegroundColor Gray
Write-Host ""

try {
    # Create credential
    $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

    Write-Host "Running all tests in range $TestCodeunitRange..." -ForegroundColor Yellow
    Write-Host ""

    $startTime = Get-Date

    # Run ALL tests in the range at once
    $results = Run-TestsInBcContainer `
        -containerName $ContainerName `
        -companyName $CompanyName `
        -credential $credential `
        -testCodeunitRange $TestCodeunitRange `
        -XUnitResultFileName $resultsFile `
        -detailed

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "Test execution complete!" -ForegroundColor Green
    Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host ""

    # Parse XUnit results (assemblies format)
    if (Test-Path $resultsFile) {
        [xml]$xmlResults = Get-Content $resultsFile

        $totalTests = 0
        $passedTests = 0
        $failedTests = 0
        $skippedTests = 0

        # Parse assemblies format
        foreach ($assembly in $xmlResults.assemblies.assembly) {
            $totalTests += [int]$assembly.total
            $passedTests += [int]$assembly.passed
            $failedTests += [int]$assembly.failed
            $skippedTests += [int]$assembly.skipped
        }

        Write-Host "=== Test Results ===" -ForegroundColor Cyan
        Write-Host "Total Tests:   $totalTests" -ForegroundColor White
        Write-Host "Passed:        $passedTests" -ForegroundColor Green
        Write-Host "Failed:        $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
        Write-Host "Skipped:       $skippedTests" -ForegroundColor Yellow
        Write-Host ""

        if ($failedTests -gt 0) {
            Write-Host "=== Failed Tests ===" -ForegroundColor Red
            Write-Host ""

            foreach ($assembly in $xmlResults.assemblies.assembly) {
                foreach ($collection in $assembly.collection) {
                    foreach ($test in $collection.test | Where-Object { $_.result -eq "Fail" }) {
                        Write-Host "FAILED: $($test.name)" -ForegroundColor Red
                        if ($test.failure) {
                            Write-Host "  Message: $($test.failure.message)" -ForegroundColor Gray
                            if ($test.failure.'stack-trace') {
                                Write-Host "  Stack Trace:" -ForegroundColor Gray
                                $test.failure.'stack-trace' -split "`n" | ForEach-Object {
                                    Write-Host "    $_" -ForegroundColor DarkGray
                                }
                            }
                        }
                        Write-Host ""
                    }
                }
            }

            Write-Host "RESULT: $failedTests test(s) FAILED" -ForegroundColor Red
            exit 1
        }
        else {
            Write-Host "RESULT: All tests PASSED!" -ForegroundColor Green
            exit 0
        }
    }
    else {
        Write-Host "WARNING: Results file not found: $resultsFile" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
