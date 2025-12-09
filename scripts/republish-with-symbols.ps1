Import-Module BCContainerHelper -WarningAction SilentlyContinue

Write-Host "`n=== Step 1: Unpublish and republish Volt Apparel with symbols ===" -ForegroundColor Cyan

# Unpublish existing Volt Apparel
Write-Host "Unpublishing Volt Apparel 1.0.0.17..." -ForegroundColor Yellow
try {
    Unpublish-BcContainerApp `
        -containerName 'bc-product-attributes' `
        -name 'Volt Apparel' `
        -version '1.0.0.17' `
        -unInstall `
        -doNotSaveData
    Write-Host "✓ Volt Apparel unpublished" -ForegroundColor Green
} catch {
    Write-Host "Note: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Republish with includeSourceInSymbolFile
Write-Host "`nRepublishing Volt Apparel with full symbols..." -ForegroundColor Yellow
Publish-BcContainerApp `
    -containerName 'bc-product-attributes' `
    -appFile 'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC\Volt Apparel_1.0.0.17.app' `
    -sync `
    -install `
    -skipVerification

Write-Host "✓ Volt Apparel published with symbols" -ForegroundColor Green

Write-Host "`n=== Step 2: Publish BC Test app ===" -ForegroundColor Cyan
Publish-BcContainerApp `
    -containerName 'bc-product-attributes' `
    -appFile 'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC Test\BC Test_1.0.0.16.app' `
    -sync `
    -install `
    -skipVerification

Write-Host "✓ BC Test app published successfully!" -ForegroundColor Green
