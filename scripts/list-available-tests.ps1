param(
    [string]$ContainerName = "bc-product-attributes"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "=== Available Tests in Container: $ContainerName ===" -ForegroundColor Cyan

try {
    # Create credential
    $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

    Write-Host "`nQuerying test codeunits..." -ForegroundColor Yellow

    $tests = Get-TestsFromBcContainer `
        -containerName $ContainerName `
        -credential $credential `
        -testCodeunitRange "70200..70204"

    if ($tests) {
        Write-Host "Found $($tests.Count) tests:" -ForegroundColor Green
        $tests | Group-Object CodeunitId | ForEach-Object {
            Write-Host "`nCodeunit $($_.Name):" -ForegroundColor Cyan
            $_.Group | ForEach-Object {
                Write-Host "  - $($_.Name)" -ForegroundColor White
            }
        }
    } else {
        Write-Host "No tests found in range 70200..70204" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
