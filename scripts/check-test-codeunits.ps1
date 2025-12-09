Import-Module BCContainerHelper -WarningAction SilentlyContinue

Write-Host "`n=== Checking Test Codeunits in Container ===" -ForegroundColor Cyan
Invoke-ScriptInBcContainer -containerName 'bc-product-attributes' -scriptblock {
    $codeunits = @(70200, 70201, 70202, 70203, 70204, 70205, 70206)
    foreach ($id in $codeunits) {
        try {
            $result = Get-NAVServerObject -ServerInstance BC -ObjectType Codeunit -ObjectId $id -ErrorAction SilentlyContinue
            if ($result) {
                Write-Host "$id : $($result.Name) - EXISTS" -ForegroundColor Green
            } else {
                Write-Host "$id : NOT FOUND" -ForegroundColor Red
            }
        } catch {
            Write-Host "$id : NOT FOUND (error: $($_.Exception.Message))" -ForegroundColor Red
        }
    }
}
