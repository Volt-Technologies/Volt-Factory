param(
    [string]$ContainerName = "bc-product-attributes"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "=== Installed BC Apps in Container: $ContainerName ===" -ForegroundColor Cyan

$apps = Get-BcContainerAppInfo -containerName $ContainerName
$voltApps = $apps | Where-Object { $_.Publisher -eq "Volt Technologies" }

Write-Host "`nVolt Technologies Apps:" -ForegroundColor Yellow
$voltApps | Select-Object Name, Version, AppId | Format-Table -AutoSize

Write-Host "`nTest-related Apps:" -ForegroundColor Yellow
$testApps = $apps | Where-Object { $_.Name -like "*Test*" }
$testApps | Select-Object Name, Publisher, Version | Format-Table -AutoSize
