Import-Module BcContainerHelper

$containerName = "bc-product-attributes"
$appFolder = "BC Test"

Write-Host "Compiling BC Test app..." -ForegroundColor Cyan

try {
    # Compile the app
    Compile-AppInBcContainer -containerName $containerName `
                             -appProjectFolder $appFolder `
                             -appOutputFolder "BC Test" `
                             -appSymbolsFolder "BC Test/.alpackages" `
                             -EnableCodeCop:$false `
                             -EnableAppSourceCop:$false `
                             -EnableUICop:$false `
                             -EnablePerTenantExtensionCop:$false

    Write-Host "`n✓ BC Test app compiled successfully!" -ForegroundColor Green

    # Find the compiled app file
    $appFile = Get-ChildItem -Path $appFolder -Filter "*.app" | Where-Object { $_.Name -like "BC Test_1.0.0.22.app" } | Select-Object -First 1 -ExpandProperty FullName

    if (-not $appFile) {
        throw "Compiled app file not found"
    }

    Write-Host "Found compiled app: $appFile" -ForegroundColor Cyan

    # Publish the app
    Write-Host "`nPublishing BC Test app to $containerName..." -ForegroundColor Cyan

    Publish-BcContainerApp -containerName $containerName `
                           -appFile $appFile `
                           -skipVerification `
                           -sync `
                           -install `
                           -syncMode ForceSync

    Write-Host "`n✓ BC Test app published and installed successfully!`n" -ForegroundColor Green

    # Verify installation
    $apps = Get-BcContainerAppInfo -containerName $containerName | Where-Object { $_.Name -eq "BC Test" }
    $apps | Format-Table Name, Version, IsInstalled, IsPublished

} catch {
    Write-Host "`n✗ Failed: $_" -ForegroundColor Red
    exit 1
}
