Import-Module BCContainerHelper -WarningAction SilentlyContinue

# Publish BC Test app with proper dependency resolution
Publish-BcContainerApp `
    -containerName 'bc-product-attributes' `
    -appFile 'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel - 1\BC Test\BC Test_1.0.0.16.app' `
    -sync `
    -install `
    -skipVerification `
    -useDevEndpoint
