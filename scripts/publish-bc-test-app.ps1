Import-Module BcContainerHelper

$containerName = "bc-product-attributes"
$appFile = "BC Test/BC Test_1.0.0.20.app"

Write-Host "Publishing BC Test app to $containerName..." -ForegroundColor Cyan

try {
    Publish-BcContainerApp -containerName $containerName `
                           -appFile $appFile `
                           -skipVerification `
                           -sync `
                           -install `
                           -syncMode ForceSync

    Write-Host "`n✓ BC Test app published and installed successfully!" -ForegroundColor Green

    # Verify installation
    $apps = Get-BcContainerAppInfo -containerName $containerName | Where-Object { $_.Name -eq "BC Test" }
    $apps | Format-Table Name, Version, IsInstalled, IsPublished

} catch {
    Write-Host "`n✗ Failed to publish BC Test app: $_" -ForegroundColor Red
    exit 1
}
