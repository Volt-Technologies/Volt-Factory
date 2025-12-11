param(
    [string]$ContainerName = "bc-product-attributes"
)

Import-Module BcContainerHelper -DisableNameChecking

Write-Host "=== Verifying BC Test App Installation ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check if app is installed
Write-Host "1. Checking installed apps..." -ForegroundColor Yellow
$bcTestApp = Get-BcContainerAppInfo -containerName $ContainerName | Where-Object { $_.Name -eq 'BC Test' }

if ($bcTestApp) {
    Write-Host "   BC Test app is installed:" -ForegroundColor Green
    Write-Host "   - Name: $($bcTestApp.Name)" -ForegroundColor Gray
    Write-Host "   - Version: $($bcTestApp.Version)" -ForegroundColor Gray
    Write-Host "   - Publisher: $($bcTestApp.Publisher)" -ForegroundColor Gray
    Write-Host "   - AppId: $($bcTestApp.AppId)" -ForegroundColor Gray
} else {
    Write-Host "   BC Test app is NOT installed!" -ForegroundColor Red
    exit 1
}

# 2. Check test framework dependencies
Write-Host ""
Write-Host "2. Checking test framework dependencies..." -ForegroundColor Yellow

$requiredTestApps = @('Test Runner', 'Library Assert', 'Any')
$missingDeps = @()

foreach ($appName in $requiredTestApps) {
    $app = Get-BcContainerAppInfo -containerName $ContainerName | Where-Object { $_.Name -eq $appName }
    if ($app) {
        Write-Host "   $appName - Installed (v$($app.Version))" -ForegroundColor Green
    } else {
        Write-Host "   $appName - MISSING!" -ForegroundColor Red
        $missingDeps += $appName
    }
}

# 3. Try to query test codeunits via OData
Write-Host ""
Write-Host "3. Attempting to query test codeunits via OData..." -ForegroundColor Yellow

try {
    $result = Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        $baseUrl = "http://localhost:80/BC/ODataV4/Company('CRONUS%20International%20Ltd.')"

        # Query for codeunits in the test range
        $headers = @{
            "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:P@ssw0rd"))
            "Accept" = "application/json"
        }

        # Try to list available endpoints
        try {
            $metadataUrl = "http://localhost:80/BC/ODataV4/`$metadata"
            $response = Invoke-WebRequest -Uri $metadataUrl -Headers $headers -Method Get -UseBasicParsing

            # Check if there are any test-related endpoints
            $content = $response.Content
            $hasTestTool = $content -match "ALTestTool"

            return @{
                MetadataAvailable = $true
                HasTestTool = $hasTestTool
                ContentLength = $content.Length
            }
        } catch {
            return @{
                Error = $_.Exception.Message
                MetadataAvailable = $false
            }
        }
    }

    if ($result.MetadataAvailable) {
        Write-Host "   OData metadata is accessible" -ForegroundColor Green
        if ($result.HasTestTool) {
            Write-Host "   ALTestTool endpoint found in metadata" -ForegroundColor Green
        } else {
            Write-Host "   ALTestTool endpoint NOT found in metadata" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   Error accessing OData: $($result.Error)" -ForegroundColor Red
    }

} catch {
    Write-Host "   Error querying OData: $_" -ForegroundColor Red
}

# 4. Check object metadata in SQL
Write-Host ""
Write-Host "4. Querying object metadata from SQL..." -ForegroundColor Yellow

$sqlQuery = @"
SELECT
    [ID] as CodeunitID,
    [Name] as CodeunitName,
    [Modified] as LastModified
FROM [dbo].[Object]
WHERE [Type] = 5
    AND [Company Name] = ''
    AND [ID] BETWEEN 70200 AND 70249
ORDER BY [ID]
"@

try {
    $objects = Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        param($query)

        $serverInstance = "localhost\SQLEXPRESS"
        $database = "CRONUS"

        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=$serverInstance;Database=$database;Integrated Security=True;"
        $connection.Open()

        $command = $connection.CreateCommand()
        $command.CommandText = $query

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) | Out-Null

        $connection.Close()

        return $dataset.Tables[0]
    } -argumentList $sqlQuery

    if ($objects -and $objects.Count -gt 0) {
        Write-Host "   Found $($objects.Count) codeunit(s) in BC database:" -ForegroundColor Green
        $objects | Format-Table -AutoSize
    } else {
        Write-Host "   No test codeunits found in database (70200-70249 range)" -ForegroundColor Red
        Write-Host "   This indicates the BC Test app was NOT successfully published/installed" -ForegroundColor Red
    }

} catch {
    Write-Host "   Error querying SQL: $_" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan

if ($bcTestApp) {
    Write-Host "App Installation: PASS - BC Test app is registered" -ForegroundColor Green
} else {
    Write-Host "App Installation: FAIL" -ForegroundColor Red
}

if ($missingDeps.Count -eq 0) {
    Write-Host "Dependencies: PASS - All test framework dependencies are installed" -ForegroundColor Green
} else {
    Write-Host "Dependencies: FAIL - Missing: $($missingDeps -join ', ')" -ForegroundColor Red
}

if ($objects -and $objects.Count -gt 0) {
    Write-Host "Database Objects: PASS - Test codeunits are in database" -ForegroundColor Green
} else {
    Write-Host "Database Objects: FAIL - No test codeunits in database" -ForegroundColor Red
    Write-Host ""
    Write-Host "DIAGNOSIS: The BC Test app appears in the app list but the codeunits" -ForegroundColor Yellow
    Write-Host "           are not actually installed in the database. This indicates" -ForegroundColor Yellow
    Write-Host "           a publishing failure." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "RECOMMENDATION: Re-publish the BC Test app using:" -ForegroundColor Yellow
    Write-Host "                1. Unpublish-NavApp (if needed)" -ForegroundColor Gray
    Write-Host "                2. Publish-NavApp" -ForegroundColor Gray
    Write-Host "                3. Sync-NavApp" -ForegroundColor Gray
    Write-Host "                4. Install-NavApp" -ForegroundColor Gray
}
