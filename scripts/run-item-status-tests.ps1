$cred = New-Object PSCredential('admin', (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force))
Import-Module BCContainerHelper -WarningAction SilentlyContinue
Run-TestsInBcContainer -containerName 'bc-product-attributes' -companyName 'CRONUS International Ltd.' -credential $cred -extensionId 'fff9ead6-096d-4948-8662-199077bbaed3' -detailed -XUnitResultFileName 'C:\ProgramData\BcContainerHelper\test-results\ItemStatusTests_Final.xml'
