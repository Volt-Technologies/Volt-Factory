Import-Module BCContainerHelper -WarningAction SilentlyContinue

$appFolder = "C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC Test"
$outputFile = Join-Path $appFolder "BC Test_1.0.0.17.app"

Write-Host "`n=== Compiling BC Test App in Container ===" -ForegroundColor Cyan
Write-Host "Source: $appFolder" -ForegroundColor White
Write-Host "Output: $outputFile" -ForegroundColor White

# Compile using the container (this ensures proper dependency resolution)
Compile-AppInBcContainer `
    -containerName 'bc-product-attributes' `
    -appProjectFolder $appFolder `
    -appOutputFile $outputFile `
    -credential (New-Object PSCredential -ArgumentList "admin", (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)) `
    -AzureDevOps

Write-Host "✓ BC Test app compiled!" -ForegroundColor Green

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
    -appFile $outputFile `
    -sync `
    -install `
    -skipVerification

Write-Host "✓ BC Test app published and installed!" -ForegroundColor Green

# Update app.json version
Write-Host "`nUpdating app.json version to 1.0.0.17..." -ForegroundColor Yellow
$appJson = Get-Content (Join-Path $appFolder "app.json") | ConvertFrom-Json
$appJson.version = "1.0.0.17"
$appJson | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $appFolder "app.json")
Write-Host "✓ app.json updated" -ForegroundColor Green
