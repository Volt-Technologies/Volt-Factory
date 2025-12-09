$containerName = 'featurename'
$password = 'P@ssw0rd'
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'us' -select 'Latest'
New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -imageName 'bc-product-attributes' `
    -includeTestToolkit `
    -includeTestFrameworkOnly `
    -assignPremiumPlan `
    -isolation 'process' `
    -vsixFile (Get-LatestAlLanguageExtensionUrl) `
    -updateHosts