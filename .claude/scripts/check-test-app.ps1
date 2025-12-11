Import-Module BCContainerHelper -WarningAction SilentlyContinue

Write-Host "`n=== Checking BC Test App Status ===" -ForegroundColor Cyan
Get-BcContainerAppInfo -containerName 'bc-product-attributes' | Where-Object { $_.Name -like '*Test*' } | Select-Object Name, Publisher, Version, IsInstalled, IsPublished | Format-Table -AutoSize

Write-Host "`n=== Checking Test Codeunits ===" -ForegroundColor Cyan
Invoke-ScriptInBcContainer -containerName 'bc-product-attributes' -scriptblock {
    Get-NAVAppInfo -ServerInstance BC -Name "*Test*" | Select-Object Name, Version, IsInstalled
}
