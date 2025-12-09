Import-Module BCContainerHelper -DisableNameChecking

$app = Get-BcContainerAppInfo -containerName 'bc-product-attributes' | Where-Object { $_.Name -eq 'BC Test' }

if ($app) {
    if ($app.IsInstalled) {
        Write-Host "BC Test is INSTALLED" -ForegroundColor Green
    } else {
        Write-Host "BC Test is published but NOT INSTALLED" -ForegroundColor Yellow
        Write-Host "Installing BC Test..." -ForegroundColor Cyan
        Install-BcContainerApp -containerName 'bc-product-attributes' -appName 'BC Test' -appVersion '1.0.0.13'
        Write-Host "Installation complete" -ForegroundColor Green
    }
} else {
    Write-Host "BC Test app not found" -ForegroundColor Red
}
