Import-Module BCContainerHelper -WarningAction SilentlyContinue

# First, try to get and copy symbols from the container
Write-Host "Downloading symbol files from container..." -ForegroundColor Cyan
try {
    $symbolsPath = "C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC Test\.alpackages"
    Get-BcContainerAppInfo -containerName 'bc-product-attributes' | Where-Object { $_.Name -eq 'Volt Apparel' -and $_.Version -eq '1.0.0.17' } | ForEach-Object {
        Write-Host "Found Volt Apparel 1.0.0.17 in container"
    }
} catch {
    Write-Host "Note: Could not verify symbols" -ForegroundColor Yellow
}

# Try publishing without -skipVerification first to ensure proper compilation
Write-Host "Publishing BC Test app to container..." -ForegroundColor Cyan
try {
    Publish-BcContainerApp `
        -containerName 'bc-product-attributes' `
        -appFile 'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC Test\BC Test_1.0.0.16.app' `
        -sync `
        -install
    Write-Host "SUCCESS: BC Test app published!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to publish BC Test app" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    throw
}
