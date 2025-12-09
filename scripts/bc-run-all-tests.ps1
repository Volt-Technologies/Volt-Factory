param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "CRONUS International Ltd.",
    [string]$TestCodeunitIdRange = "50100..99999",
    [string]$Username = "admin",
    [string]$Password = "P@ssw0rd"
)

Import-Module BcContainerHelper -DisableNameChecking

# Create credential object
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

Write-Host "=== Business Central Test Execution ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor Yellow
Write-Host "Company: $CompanyName" -ForegroundColor Yellow
Write-Host "Test Range: $TestCodeunitIdRange" -ForegroundColor Yellow
Write-Host ""

# Create output directory
$outputDir = "C:\ProgramData\BcContainerHelper\test-results"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultFile = Join-Path $outputDir "test_results_$timestamp.xml"

Write-Host "=== Running Tests ===" -ForegroundColor Cyan
Write-Host "Output file: $resultFile" -ForegroundColor Gray
Write-Host ""

try {
    # Run tests and capture output
    $testResults = Run-TestsInBcContainer `
        -containerName $ContainerName `
        -companyName $CompanyName `
        -credential $credential `
        -testCodeunitRange $TestCodeunitIdRange `
        -XUnitResultFileName $resultFile `
        -detailed `
        -returnTrueIfAllPassed

    Write-Host ""
    Write-Host "=== Test Execution Complete ===" -ForegroundColor Green
    Write-Host "Results saved to: $resultFile" -ForegroundColor Yellow

    # Parse and display results
    if (Test-Path $resultFile) {
        Write-Host ""
        Write-Host "=== Parsing Results ===" -ForegroundColor Cyan

        [xml]$xmlResults = Get-Content $resultFile

        if ($xmlResults.assemblies) {
            $assembly = $xmlResults.assemblies.assembly
            $total = [int]$assembly.total
            $passed = [int]$assembly.passed
            $failed = [int]$assembly.failed
            $skipped = [int]$assembly.skipped

            Write-Host ""
            Write-Host "=== Summary ===" -ForegroundColor Cyan
            Write-Host "Total Tests: $total" -ForegroundColor White
            Write-Host "Passed: $passed" -ForegroundColor Green
            Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
            Write-Host "Skipped: $skipped" -ForegroundColor Yellow

            if ($failed -gt 0) {
                Write-Host ""
                Write-Host "=== Failed Tests ===" -ForegroundColor Red

                foreach ($collection in $assembly.collection) {
                    foreach ($test in $collection.test) {
                        if ($test.result -eq "Fail") {
                            Write-Host ""
                            Write-Host "Test: $($test.name)" -ForegroundColor Yellow
                            Write-Host "Method: $($test.method)" -ForegroundColor Gray

                            if ($test.failure) {
                                Write-Host "Error: $($test.failure.message)" -ForegroundColor Red
                                if ($test.failure.'stack-trace') {
                                    Write-Host "Stack Trace:" -ForegroundColor Gray
                                    Write-Host $test.failure.'stack-trace' -ForegroundColor DarkGray
                                }
                            }
                        }
                    }
                }
            }

            # List all test codeunits found
            Write-Host ""
            Write-Host "=== Test Codeunits Executed ===" -ForegroundColor Cyan
            $collections = $assembly.collection | Sort-Object -Property name -Unique
            foreach ($collection in $collections) {
                $collectionTotal = [int]$collection.total
                $collectionPassed = [int]$collection.passed
                $collectionFailed = [int]$collection.failed

                $status = if ($collectionFailed -gt 0) { "FAILED" } else { "PASSED" }
                $color = if ($collectionFailed -gt 0) { "Red" } else { "Green" }

                Write-Host "$($collection.name) - Tests: $collectionTotal, Passed: $collectionPassed, Failed: $collectionFailed [$status]" -ForegroundColor $color
            }
        }
    }

} catch {
    Write-Host "Error running tests: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
