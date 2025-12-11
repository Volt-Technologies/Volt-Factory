Import-Module BCContainerHelper -WarningAction SilentlyContinue

$appFolder = "C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC Test"

Write-Host "`n=== Compiling BC Test App in Container ===" -ForegroundColor Cyan
Write-Host "Source: $appFolder" -ForegroundColor White

# Compile using the container (this ensures proper dependency resolution)
$app = Compile-AppInBcContainer `
    -containerName 'bc-product-attributes' `
    -appProjectFolder $appFolder `
    -credential (New-Object PSCredential -ArgumentList "admin", (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)) `
    -AzureDevOps `
    -updateSymbols

Write-Host "✓ BC Test app compiled: $app" -ForegroundColor Green

if (Test-Path $app) {
    # Unpublish old version
    Write-Host "`nUnpublishing old BC Test app..." -ForegroundColor Yellow
    try {
        Unpublish-BcContainerApp -containerName 'bc-product-attributes' -name 'BC Test' -unInstall -doNotSaveData
        Write-Host "✓ Old version unpublished" -ForegroundColor Green
    } catch {
        Write-Host "Note: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # Publish new version
    Write-Host "`nPublishing newly compiled BC Test app..." -ForegroundColor Yellow
    Publish-BcContainerApp `
        -containerName 'bc-product-attributes' `
        -appFile $app `
        -sync `
        -install `
        -skipVerification

    Write-Host "✓ BC Test app published and installed!" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR: Compiled app file not found!" -ForegroundColor Red
    exit 1
}
