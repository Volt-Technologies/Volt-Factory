param(
    [string]$ContainerName = "bc-product-attributes"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "=== Installed Test Apps ===" -ForegroundColor Cyan
$testApps = Get-BcContainerAppInfo -containerName $ContainerName | Where-Object { $_.Name -like '*Test*' }
$testApps | Select-Object Name, Publisher, Version, AppId | Format-Table -AutoSize

Write-Host "`n=== All Installed Apps ===" -ForegroundColor Cyan
Get-BcContainerAppInfo -containerName $ContainerName | Select-Object Name, Publisher, Version | Format-Table -AutoSize
