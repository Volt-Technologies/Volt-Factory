Import-Module BCContainerHelper -WarningAction SilentlyContinue
Get-BcContainerAppInfo -containerName 'bc-product-attributes' | Where-Object { $_.Publisher -eq 'Volt Technologies' } | Select-Object Name, Publisher, Version, IsInstalled | Format-Table -AutoSize
