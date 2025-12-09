Import-Module BCContainerHelper -WarningAction SilentlyContinue

Write-Host "`n=== BC Test App Verification ===" -ForegroundColor Cyan

# Check app is installed
$bcTestApp = Get-BcContainerAppInfo -containerName 'bc-product-attributes' | Where-Object { $_.Name -eq 'BC Test' }
if ($bcTestApp) {
    Write-Host "✓ BC Test app found:" -ForegroundColor Green
    Write-Host "  Name: $($bcTestApp.Name)" -ForegroundColor White
    Write-Host "  Version: $($bcTestApp.Version)" -ForegroundColor White
    Write-Host "  Publisher: $($bcTestApp.Publisher)" -ForegroundColor White
    Write-Host "  IsInstalled: $($bcTestApp.IsInstalled)" -ForegroundColor White
    Write-Host "  IsPublished: $($bcTestApp.IsPublished)" -ForegroundColor White
} else {
    Write-Host "✗ BC Test app NOT FOUND!" -ForegroundColor Red
    exit 1
}

# Try to run a specific test from BC Test app
Write-Host "`n=== Attempting to run Phase 2 test (codeunit 70206) ===" -ForegroundColor Cyan
$securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

try {
    Run-TestsInBcContainer `
        -containerName 'bc-product-attributes' `
        -companyName 'CRONUS International Ltd.' `
        -credential $credential `
        -testCodeunit 70206 `
        -detailed `
        -XUnitResultFileName "C:\ProgramData\BcContainerHelper\test-results\Test70206.xml"

    Write-Host "✓ Test codeunit 70206 executed!" -ForegroundColor Green

    # Check results
    if (Test-Path "C:\ProgramData\BcContainerHelper\test-results\Test70206.xml") {
        [xml]$results = Get-Content "C:\ProgramData\BcContainerHelper\test-results\Test70206.xml"
        Write-Host "`nResults:" -ForegroundColor Cyan
        $results.testsuites.testsuite | ForEach-Object {
            Write-Host "  Name: $($_.name)" -ForegroundColor White
            Write-Host "  Tests: $($_.tests)" -ForegroundColor White
            Write-Host "  Failures: $($_.failures)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Attempting to run Phase 3 test (codeunit 70205) ===" -ForegroundColor Cyan
try {
    Run-TestsInBcContainer `
        -containerName 'bc-product-attributes' `
        -companyName 'CRONUS International Ltd.' `
        -credential $credential `
        -testCodeunit 70205 `
        -detailed `
        -XUnitResultFileName "C:\ProgramData\BcContainerHelper\test-results\Test70205.xml"

    Write-Host "✓ Test codeunit 70205 executed!" -ForegroundColor Green

    # Check results
    if (Test-Path "C:\ProgramData\BcContainerHelper\test-results\Test70205.xml") {
        [xml]$results = Get-Content "C:\ProgramData\BcContainerHelper\test-results\Test70205.xml"
        Write-Host "`nResults:" -ForegroundColor Cyan
        $results.testsuites.testsuite | ForEach-Object {
            Write-Host "  Name: $($_.name)" -ForegroundColor White
            Write-Host "  Tests: $($_.tests)" -ForegroundColor White
            Write-Host "  Failures: $($_.failures)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
