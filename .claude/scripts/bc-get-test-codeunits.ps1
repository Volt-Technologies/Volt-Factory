param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$Username = "admin",
    [string]$Password = "P@ssw0rd"
)

Import-Module BcContainerHelper -DisableNameChecking

# Create credential object
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

Write-Host "=== Querying Test Codeunits ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor Yellow
Write-Host ""

try {
    # Query for test codeunits using Invoke-ScriptInBcContainer
    $testCodeunits = Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        param($credential)

        # Load the NAV service tier assemblies
        $serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service").FullName
        Add-Type -Path (Join-Path $serviceTierFolder "Microsoft.Dynamics.Nav.Types.dll")
        Add-Type -Path (Join-Path $serviceTierFolder "Microsoft.Dynamics.Nav.Management.dll")

        # Connect to the service tier
        $serverInstance = "BC"
        $config = Get-NAVServerConfiguration -ServerInstance $serverInstance -AsXml
        $managementPort = ($config.configuration.appSettings.add | Where-Object { $_.key -eq "ManagementServicesPort" }).value

        if (!$managementPort) {
            $managementPort = 7045
        }

        # Query test codeunits
        $baseUrl = "http://localhost:80/BC/ODataV4/Company('CRONUS%20International%20Ltd.')"

        # Try to get codeunits from AL Test Tool page
        $headers = @{
            "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:P@ssw0rd"))
        }

        # Get all objects of type Codeunit with Subtype = Test
        $query = "$baseUrl/ALTestTool"

        try {
            $response = Invoke-RestMethod -Uri $query -Headers $headers -Method Get
            return $response
        } catch {
            Write-Host "REST query failed: $_" -ForegroundColor Yellow

            # Alternative: Query the Object table directly
            # This is a fallback approach
            return @{
                Message = "Could not query test codeunits via REST API"
                Error = $_.Exception.Message
            }
        }
    } -argumentList $credential

    Write-Host "Results:"
    $testCodeunits | ConvertTo-Json -Depth 5

} catch {
    Write-Host "Error querying test codeunits: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Alternative approach: Use SQL query
Write-Host ""
Write-Host "=== Alternative: Querying via SQL ===" -ForegroundColor Cyan

$sqlQuery = @"
SELECT
    [ID] as CodeunitID,
    [Name] as CodeunitName,
    [Subtype] as Subtype
FROM [dbo].[Object]
WHERE [Type] = 5
    AND [Company Name] = ''
    AND [Subtype] IN ('Test', 'TestRunner')
    AND [ID] >= 50000
ORDER BY [ID]
"@

try {
    $sqlResults = Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock {
        param($query)

        # Connect to SQL
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

    if ($sqlResults) {
        Write-Host ""
        Write-Host "=== Test Codeunits Found ===" -ForegroundColor Green
        $sqlResults | Format-Table -AutoSize

        Write-Host ""
        Write-Host "Total test codeunits: $($sqlResults.Count)" -ForegroundColor Cyan
    } else {
        Write-Host "No test codeunits found" -ForegroundColor Yellow
    }

} catch {
    Write-Host "SQL query failed: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
