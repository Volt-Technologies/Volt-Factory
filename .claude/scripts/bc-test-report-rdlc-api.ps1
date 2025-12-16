# Test Report Web Service API
$ErrorActionPreference = "Stop"

# Load config (from repo root)
$config = @{}
$envPath = Join-Path $PSScriptRoot "..\..\.env"
Get-Content $envPath | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$tenantId = $config["BC_TENANT_ID"]
$clientId = $config["BC_CLIENT_ID"]
$clientSecret = $config["BC_CLIENT_SECRET"]
$environmentName = $config["BC_ENVIRONMENT_NAME"]
$companyName = "CRONUS USA, Inc."

# Get token
Write-Host "Authenticating..." -ForegroundColor Yellow
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$tokenBody = @{
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = 'https://api.businesscentral.dynamics.com/.default'
    grant_type    = 'client_credentials'
}
$token = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $tokenBody -ContentType 'application/x-www-form-urlencoded'
$accessToken = $token.access_token
Write-Host "✓ Authenticated" -ForegroundColor Green

# Test report function
Write-Host "`nTesting Report Function..." -ForegroundColor Cyan
$encodedCompany = [uri]::EscapeDataString($companyName)
$baseUrl = "https://api.businesscentral.dynamics.com/v2.0/$tenantId/$environmentName/ODataV4"
$url = "$baseUrl/TestRunner_TestReportWithFirstRecord`?company=$encodedCompany"

$headers = @{
    Authorization = "Bearer $accessToken"
    'Content-Type' = 'application/json'
}

$body = @{
    reportId = 50000
    tableNo = 112
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body
    
    # OData returns JSON as string in value field
    if ($response.value -is [string]) {
        $result = $response.value | ConvertFrom-Json
    } else {
        $result = $response
    }
    
    Write-Host "`nResult:" -ForegroundColor Cyan
    Write-Host "Success: $($result.success)" -ForegroundColor $(if ($result.success) { "Green" } else { "Red" })
    Write-Host "Report ID: $($result.reportId)" -ForegroundColor Yellow
    Write-Host "Table No: $($result.tableNo)" -ForegroundColor Yellow
    Write-Host "Record SystemId: $($result.recordSystemId)" -ForegroundColor Yellow
    
    if ($result.success) {
        Write-Host "PDF Size: $($result.pdfSizeBytes) bytes" -ForegroundColor Green
        Write-Host "Has Content: $($result.hasPdfContent)" -ForegroundColor $(if ($result.hasPdfContent) { "Green" } else { "Red" })
        
        if ($result.hasPdfContent -and $result.pdfBase64) {
            Write-Host "✓ PDF generated successfully!" -ForegroundColor Green
            Write-Host "Base64 length: $($result.pdfBase64.Length) characters" -ForegroundColor Green
            
            # Save PDF to file (in repo root)
            $outputFolder = Join-Path $PSScriptRoot "..\..\pdfs"
            if (-not (Test-Path $outputFolder)) {
                New-Item -ItemType Directory -Path $outputFolder | Out-Null
                Write-Host "Created output folder: $outputFolder" -ForegroundColor Yellow
            }
            
            # Create filename from report ID, table number, and record ID
            $recordNo = if ($result.recordNo) { $result.recordNo -replace '[^\w\-]', '_' } else { "unknown" }
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $filename = "Report_$($result.reportId)_Table$($result.tableNo)_${recordNo}_${timestamp}.pdf"
            $filePath = Join-Path $outputFolder $filename
            
            try {
                # Decode Base64 and save to file
                $pdfBytes = [Convert]::FromBase64String($result.pdfBase64)
                [System.IO.File]::WriteAllBytes($filePath, $pdfBytes)
                Write-Host "✓ PDF saved to: $filePath" -ForegroundColor Green
            } catch {
                Write-Host "✗ Failed to save PDF: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "✗ PDF is empty or missing" -ForegroundColor Red
        }
    } else {
        Write-Host "Error: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails)" -ForegroundColor Red
    }
}

