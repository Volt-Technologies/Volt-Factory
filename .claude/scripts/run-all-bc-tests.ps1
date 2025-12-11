# Run All Tests in BC Test App
Import-Module BCContainerHelper -WarningAction SilentlyContinue

$containerName = "bc-product-attributes"
$companyName = "CRONUS International Ltd."
$extensionId = "fff9ead6-096d-4948-8662-199077bbaed3"  # BC Test app ID

# Create credential
$securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

# Output file
$resultsFile = "C:\ProgramData\BcContainerHelper\test-results\TestResults-AllTests-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').xml"

Write-Host "=== Running All Tests in BC Test App ===" -ForegroundColor Cyan
Write-Host "Container: $containerName" -ForegroundColor White
Write-Host "Company: $companyName" -ForegroundColor White
Write-Host "Extension ID: $extensionId" -ForegroundColor White
Write-Host "Results: $resultsFile" -ForegroundColor White
Write-Host ""

$startTime = Get-Date

# Run all tests in the extension
Run-TestsInBcContainer `
    -containerName $containerName `
    -companyName $companyName `
    -credential $credential `
    -extensionId $extensionId `
    -XUnitResultFileName $resultsFile `
    -detailed

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "Test execution complete!" -ForegroundColor Green
Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host ""

# Parse and display results
if (Test-Path $resultsFile) {
    [xml]$xmlResults = Get-Content $resultsFile

    $totalTests = 0
    $passedTests = 0
    $failedTests = 0
    $skippedTests = 0

    foreach ($assembly in $xmlResults.assemblies.assembly) {
        $totalTests += [int]$assembly.total
        $passedTests += [int]$assembly.passed
        $failedTests += [int]$assembly.failed
        $skippedTests += [int]$assembly.skipped
    }

    Write-Host "=== Test Results ===" -ForegroundColor Cyan
    Write-Host "Total:   $totalTests" -ForegroundColor White
    Write-Host "Passed:  $passedTests" -ForegroundColor Green
    Write-Host "Failed:  $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "White" })
    Write-Host "Skipped: $skippedTests" -ForegroundColor Yellow
    Write-Host ""

    if ($failedTests -gt 0) {
        Write-Host "=== Failed Tests ===" -ForegroundColor Red
        foreach ($assembly in $xmlResults.assemblies.assembly) {
            foreach ($collection in $assembly.collection) {
                foreach ($test in $collection.test | Where-Object { $_.result -eq "Fail" }) {
                    Write-Host ""
                    Write-Host "Test: $($test.name)" -ForegroundColor Red
                    if ($test.failure) {
                        Write-Host "Error: $($test.failure.message)" -ForegroundColor Gray
                        if ($test.failure.'stack-trace') {
                            Write-Host "Stack Trace:" -ForegroundColor Gray
                            Write-Host $test.failure.'stack-trace' -ForegroundColor DarkGray
                        }
                    }
                }
            }
        }
        Write-Host ""
        exit 1
    } else {
        if ($totalTests -eq 0) {
            Write-Host "WARNING: No tests were executed!" -ForegroundColor Yellow
            exit 1
        } else {
            Write-Host "SUCCESS: All tests passed!" -ForegroundColor Green
            exit 0
        }
    }
} else {
    Write-Host "ERROR: Results file not found at $resultsFile" -ForegroundColor Red
    exit 1
}
