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
$totalTests = 0
$passedTests = 0

foreach ($codeunitName in $testCodeunits) {
    Write-Host "`n--- Testing: $codeunitName ---" -ForegroundColor Yellow
    try {
        $result = Run-TestsInBcContainer `
            -containerName 'bc-product-attributes' `
            -companyName 'CRONUS International Ltd.' `
            -testCodeunit $codeunitName `
            -detailed `
            -returnTrueIfAllPassed `
            -XUnitResultFileName "C:\ProgramData\BcContainerHelper\test-results\${codeunitName}_results.xml"

        Write-Host "PASSED: $codeunitName" -ForegroundColor Green
        $results += [PSCustomObject]@{
            Codeunit = $codeunitName
            Result = "PASSED"
        }
    } catch {
        Write-Host "FAILED: $codeunitName - $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Codeunit = $codeunitName
            Result = "FAILED"
            Error = $_.Exception.Message
        }
    }
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Count tests from XML files
Write-Host "`n=== Test Counts ===" -ForegroundColor Cyan
Get-ChildItem "C:\ProgramData\BcContainerHelper\test-results" -Filter "*_results.xml" | ForEach-Object {
    [xml]$xmlContent = Get-Content $_.FullName
    if ($xmlContent.assemblies.assembly) {
        $tests = $xmlContent.assemblies.assembly.total
        $passed = $xmlContent.assemblies.assembly.passed
        $failed = $xmlContent.assemblies.assembly.failed
        Write-Host "$($_.Name): Total=$tests, Passed=$passed, Failed=$failed"
        $totalTests += [int]$tests
        $passedTests += [int]$passed
    }
}

Write-Host "`nOVERALL: $passedTests passed out of $totalTests tests" -ForegroundColor Cyan
