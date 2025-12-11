Import-Module BCContainerHelper -WarningAction SilentlyContinue

Write-Host "`n=== Running All Product Attribute Tests ===" -ForegroundColor Cyan

$testCodeunits = @(
    "VOL Product Attribute Test",
    "VOL Item Attr Config Test",
    "VOL Attr Validation Test",
    "VOL Variant Attribute Test",
    "VOL Item Attribute Test"
)

$results = @()

foreach ($codeunitName in $testCodeunits) {
    Write-Host "`n--- Testing: $codeunitName ---" -ForegroundColor Yellow
    try {
        Run-TestsInBcContainer `
            -containerName 'bc-product-attributes' `
            -companyName 'CRONUS International Ltd.' `
            -testCodeunit $codeunitName `
            -detailed `
            -returnTrueIfAllPassed `
            -testResultsFile "C:\ProgramData\BcContainerHelper\test-results\${codeunitName}_results.xml"

        $results += [PSCustomObject]@{
            Codeunit = $codeunitName
            Result = "PASSED"
        }
    } catch {
        Write-Host "ERROR in $codeunitName : $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Codeunit = $codeunitName
            Result = "FAILED: $($_.Exception.Message)"
        }
    }
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize
