# Assign VOL Test Permissions to admin user in BC container
# This script ensures the test permission set is assigned to the user running tests

param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$UserName = "admin"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "Assigning VOL Test Permissions to user $UserName in container $ContainerName..." -ForegroundColor Yellow

# Create credential
$password = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$cred = New-Object PSCredential($UserName, $password)

# Invoke SQL command to assign permission set to user
$sql = @"
USE [CRONUS International Ltd.]

-- Check if permission set exists
IF EXISTS (SELECT 1 FROM [dbo].[Aggregate Permission Set] WHERE [Role ID] = 'VOL TEST PERMISSIONS')
BEGIN
    PRINT 'Permission set VOL TEST PERMISSIONS found'

    -- Check if user permission set exists
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Access Control]
                   WHERE [User Security ID] = (SELECT [User Security ID] FROM [dbo].[User] WHERE [User Name] = '$UserName')
                   AND [Role ID] = 'VOL TEST PERMISSIONS')
    BEGIN
        -- Assign permission set to user
        INSERT INTO [dbo].[Access Control]
        ([User Security ID], [Role ID], [Company Name], [App ID], [Scope])
        SELECT
            u.[User Security ID],
            'VOL TEST PERMISSIONS',
            '',
            aps.[App ID],
            aps.[Scope]
        FROM [dbo].[User] u
        CROSS JOIN [dbo].[Aggregate Permission Set] aps
        WHERE u.[User Name] = '$UserName'
        AND aps.[Role ID] = 'VOL TEST PERMISSIONS'

        PRINT 'Permission set VOL TEST PERMISSIONS assigned to user $UserName'
    END
    ELSE
    BEGIN
        PRINT 'Permission set VOL TEST PERMISSIONS already assigned to user $UserName'
    END
END
ELSE
BEGIN
    PRINT 'ERROR: Permission set VOL TEST PERMISSIONS not found'
END
"@

try {
    Invoke-BcContainerApi -containerName $ContainerName -credential $cred -APIPublisher 'microsoft' -APIGroup 'automation' -APIVersion 'v2.0' -Query 'companies' | Out-Null
    Write-Host "API connection successful" -ForegroundColor Green

    # Execute SQL directly in container
    $result = Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        param($sql)
        sqlcmd -S localhost\SQLEXPRESS -d "CRONUS International Ltd." -Q $sql
    } -argumentList $sql

    Write-Host $result -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Permission assignment completed. Please restart BC service or re-login to activate permissions." -ForegroundColor Green
}
catch {
    Write-Host "Error assigning permissions: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "MANUAL FIX REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Open Business Central Web Client" -ForegroundColor White
    Write-Host "2. Search for 'Users'" -ForegroundColor White
    Write-Host "3. Find user 'admin'" -ForegroundColor White
    Write-Host "4. Click 'User Permission Sets'" -ForegroundColor White
    Write-Host "5. Add permission set: VOL TEST PERMISSIONS" -ForegroundColor White
    Write-Host "6. Click OK and close" -ForegroundColor White
}
