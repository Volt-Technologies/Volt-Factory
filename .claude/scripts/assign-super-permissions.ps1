# Assign SUPER permission set to admin user for testing
# This ensures all tests can run without permission issues

param(
    [string]$ContainerName = "bc-product-attributes"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "Assigning SUPER permissions to admin user in container $ContainerName..." -ForegroundColor Yellow

try {
    Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        Import-Module 'C:\Program Files\Microsoft Dynamics NAV\*\Service\NavAdminTool.ps1' -DisableNameChecking

        $ServerInstance = 'BC'

        # Get admin user SID
        $users = Get-NAVServerUser -ServerInstance $ServerInstance -Tenant default
        Write-Host "Found $($users.Count) users"

        foreach ($user in $users) {
            Write-Host "User: $($user.UserName), SID: $($user.UserSecurityId)"
        }

        # Try to assign SUPER to admin
        $adminUser = $users | Where-Object { $_.UserName -eq 'admin' }
        if ($adminUser) {
            Write-Host "Found admin user with SID: $($adminUser.UserSecurityId)"

            # Check current permissions
            $currentPermissions = Get-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant default -Sid $adminUser.UserSecurityId
            Write-Host "Current permissions for admin:"
            $currentPermissions | ForEach-Object { Write-Host "  - $($_.PermissionSetID)" }

            # Check if SUPER is assigned
            $hasSuper = $currentPermissions | Where-Object { $_.PermissionSetID -eq 'SUPER' }
            if (-not $hasSuper) {
                Write-Host "Assigning SUPER permission set..."
                New-NAVServerUserPermissionSet -ServerInstance $ServerInstance -Tenant default -Sid $adminUser.UserSecurityId -PermissionSetId 'SUPER'
                Write-Host "SUPER permission set assigned successfully!" -ForegroundColor Green
            } else {
                Write-Host "SUPER permission set already assigned" -ForegroundColor Green
            }
        } else {
            Write-Host "Admin user not found!" -ForegroundColor Red
        }
    }

    Write-Host "Permission assignment complete!" -ForegroundColor Green

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
