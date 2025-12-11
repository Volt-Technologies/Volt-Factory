# Assign VOL Test Permissions using BC API
param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$UserName = "admin"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "Assigning VOL Test Permissions to user $UserName..." -ForegroundColor Yellow

$password = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$cred = New-Object PSCredential($UserName, $password)

try {
    # Get the user's Security ID
    Write-Host "Getting user information..." -ForegroundColor Cyan
    $users = Invoke-BcContainerApi `
        -containerName $ContainerName `
        -credential $cred `
        -APIPublisher 'microsoft' `
        -APIGroup 'automation' `
        -APIVersion 'v2.0' `
        -Query 'users'

    $adminUser = $users.value | Where-Object { $_.userSecurityId -ne $null }

    if (-not $adminUser) {
        Write-Host "Could not find user. Trying alternative method..." -ForegroundColor Yellow

        # Alternative: Use Invoke-ScriptInBcContainer to assign via PowerShell
        Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
            param($userName, $permissionSetId)

            Import-Module 'C:\Program Files\Microsoft Dynamics NAV\*\Service\NavAdminTool.ps1' -DisableNameChecking

            $ServerInstance = 'BC'

            # Get existing permission sets for user
            $existingPermissions = Get-NAVServerUserPermissionSet -ServerInstance $ServerInstance -WindowsAccount $userName -ErrorAction SilentlyContinue

            # Check if permission set already assigned
            $hasPermission = $existingPermissions | Where-Object { $_.RoleId -eq $permissionSetId }

            if (-not $hasPermission) {
                Write-Host "Assigning permission set $permissionSetId to user $userName"
                # Note: This may require the permission set to be in System scope
                # If this fails, manual assignment via UI is required
                Write-Host "Permission set assignment requires manual action via BC Web Client"
            } else {
                Write-Host "Permission set $permissionSetId already assigned to user $userName"
            }
        } -argumentList $UserName, 'VOL TEST PERMISSIONS'

    } else {
        Write-Host "User found. Please assign permission set manually via BC Web Client." -ForegroundColor Yellow
    }

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "MANUAL PERMISSION ASSIGNMENT REQUIRED" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "To fix the permission error, follow these steps:" -ForegroundColor White
Write-Host ""
Write-Host "1. Open Business Central in browser:" -ForegroundColor Cyan
Write-Host "   http://localhost/BC" -ForegroundColor White
Write-Host ""
Write-Host "2. Login with:" -ForegroundColor Cyan
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: P@ssw0rd" -ForegroundColor White
Write-Host ""
Write-Host "3. Search for 'Users' (use search icon or Alt+Q)" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Open the 'admin' user" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Click 'User Permission Sets' action" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Click '+ New' to add a permission set" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. In the Permission Set field, select:" -ForegroundColor Cyan
Write-Host "   VOL TEST PERMISSIONS" -ForegroundColor White
Write-Host ""
Write-Host "8. Click OK to save" -ForegroundColor Cyan
Write-Host ""
Write-Host "9. Re-run the tests" -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
