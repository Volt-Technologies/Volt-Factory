param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "My Company"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "=== Running BC Tests Directly ===" -ForegroundColor Cyan

# Run tests for each codeunit
$codeunits = 70200..70203

foreach ($codeunit in $codeunits) {
    Write-Host "`nRunning tests in codeunit $codeunit..." -ForegroundColor Yellow

    try {
        $results = Run-TestsInBcContainer `
            -containerName $ContainerName `
            -companyName $CompanyName `
            -testCodeunit $codeunit `
            -detailed

        if ($results) {
            Write-Host "Found $($results.Count) tests" -ForegroundColor Green
            $results | ForEach-Object {
                $status = if ($_.Result -eq "Success") { "PASS" } else { "FAIL" }
                $color = if ($_.Result -eq "Success") { "Green" } else { "Red" }
                Write-Host "  [$status] $($_.Name)" -ForegroundColor $color
                if ($_.Result -ne "Success") {
                    Write-Host "    Error: $($_.FirstError)" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "No tests found in codeunit $codeunit" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error running codeunit $codeunit : $_" -ForegroundColor Red
    }
}
