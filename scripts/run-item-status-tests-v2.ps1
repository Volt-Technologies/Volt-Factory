# Run Item Status Tests
param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "CRONUS International Ltd.",
    [int]$TestCodeunitId = 70241
)

Import-Module BcContainerHelper -DisableNameChecking -WarningAction SilentlyContinue

Write-Host "Running Item Status Tests (Codeunit $TestCodeunitId)..." -ForegroundColor Yellow
Write-Host "Container: $ContainerName" -ForegroundColor Cyan
Write-Host "Company: $CompanyName" -ForegroundColor Cyan
Write-Host ""

$password = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$cred = New-Object PSCredential('admin', $password)

$resultsFile = "C:\ProgramData\BcContainerHelper\test-results\ItemStatusTests_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"

try {
    $testResults = Run-TestsInBcContainer `
        -containerName $ContainerName `
        -companyName $CompanyName `
        -credential $cred `
        -testCodeunit $TestCodeunitId `
        -detailed `
        -XUnitResultFileName $resultsFile

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "TEST EXECUTION COMPLETE" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Results saved to: $resultsFile" -ForegroundColor Cyan

    # Parse and display results
    if (Test-Path $resultsFile) {
        [xml]$xml = Get-Content $resultsFile
        $assemblies = $xml.assemblies.assembly

        foreach ($assembly in $assemblies) {
            $total = [int]$assembly.total
            $passed = [int]$assembly.passed
            $failed = [int]$assembly.failed
            $skipped = [int]$assembly.skipped

            Write-Host ""
            Write-Host "Test Summary:" -ForegroundColor Yellow
            Write-Host "  Total:   $total" -ForegroundColor White
            Write-Host "  Passed:  $passed" -ForegroundColor Green
            Write-Host "  Failed:  $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "White" })
            Write-Host "  Skipped: $skipped" -ForegroundColor $(if ($skipped -gt 0) { "Yellow" } else { "White" })

            # Show failed tests
            if ($failed -gt 0) {
                Write-Host ""
                Write-Host "FAILED TESTS:" -ForegroundColor Red
                $failedTests = $assembly.collection.test | Where-Object { $_.result -eq 'Fail' }
                foreach ($test in $failedTests) {
                    Write-Host "  - $($test.method)" -ForegroundColor Red
                    if ($test.failure.message) {
                        Write-Host "    Error: $($test.failure.message)" -ForegroundColor DarkRed
                    }
                }
            }
        }
    }

} catch {
    Write-Host "Error running tests: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
