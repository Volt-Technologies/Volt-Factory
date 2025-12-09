Import-Module BCContainerHelper -WarningAction SilentlyContinue

Write-Host "`n=== Reinstalling BC Test App ===" -ForegroundColor Cyan

# Sync and install the app
Write-Host "Syncing and installing BC Test app..." -ForegroundColor Yellow
try {
    Sync-BcContainerApp -containerName 'bc-product-attributes' -appName 'BC Test' -appVersion '1.0.0.16'
    Write-Host "✓ App synced" -ForegroundColor Green

    Install-BcContainerApp -containerName 'bc-product-attributes' -appName 'BC Test' -appVersion '1.0.0.16'
    Write-Host "✓ App installed" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify installation
Write-Host "`nVerifying installation..." -ForegroundColor Yellow
$bcTestApp = Get-BcContainerAppInfo -containerName 'bc-product-attributes' | Where-Object { $_.Name -eq 'BC Test' }
if ($bcTestApp.IsInstalled) {
    Write-Host "✓ BC Test app is now INSTALLED" -ForegroundColor Green
} else {
    Write-Host "✗ BC Test app installation failed" -ForegroundColor Red
}
