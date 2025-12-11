# Run single test codeunit
param([int]$CodeunitId)

Import-Module BCContainerHelper -DisableNameChecking

$securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

$outputDir = "C:\ProgramData\BcContainerHelper\test-results"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$resultsFile = Join-Path $outputDir "TestResults_Single_${timestamp}.xml"

Write-Host "Running test codeunit $CodeunitId..." -ForegroundColor Cyan
Write-Host "Results will be saved to: $resultsFile"

try {
    Run-TestsInBcContainer `
        -containerName "bc-product-attributes" `
        -companyName "CRONUS International Ltd." `
        -credential $credential `
        -testCodeunit $CodeunitId `
        -XUnitResultFileName $resultsFile `
        -detailed

    Write-Host "Test execution completed" -ForegroundColor Green

    if (Test-Path $resultsFile) {
        Write-Host "`nTest Results:" -ForegroundColor Cyan
        Get-Content $resultsFile
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
