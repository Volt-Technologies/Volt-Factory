Import-Module BcContainerHelper

Write-Host "Checking BC Test app status in bc-product-attributes container..." -ForegroundColor Cyan

$apps = Get-BcContainerAppInfo -containerName "bc-product-attributes" | Where-Object { $_.Name -eq "BC Test" }

if ($apps) {
    Write-Host "BC Test app found:" -ForegroundColor Green
    $apps | Format-Table Name, Version, Publisher, IsInstalled, IsPublished

    Write-Host "`nUnpublishing all BC Test app versions..." -ForegroundColor Yellow
    foreach ($app in $apps) {
        try {
            UnPublish-BcContainerApp -containerName "bc-product-attributes" -name "BC Test" -version $app.Version -unInstall -force
            Write-Host "Unpublished BC Test version $($app.Version)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to unpublish version $($app.Version): $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No BC Test app found in container" -ForegroundColor Yellow
}

Write-Host "`nContainer is ready for fresh BC Test app installation" -ForegroundColor Green
