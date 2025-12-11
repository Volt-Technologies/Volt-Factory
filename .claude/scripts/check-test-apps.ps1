Import-Module BCContainerHelper -DisableNameChecking
Get-BcContainerAppInfo -containerName bc-product-attributes | Where-Object { $_.Name -like '*Test*' } | Select-Object Name, Version, IsInstalled | Format-Table -AutoSize
