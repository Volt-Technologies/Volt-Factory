# Test Runner Web Service API

This document describes how to execute automated tests in Business Central using the TestRunner OData web service.

## Overview

The `VOL Test Runner WS` codeunit (ID 78000) is published as an OData V4 web service named `TestRunner`. It provides full test execution capabilities via HTTP API calls.

## Prerequisites

### 1. BC Test App Published
The BC Test app must be published to the environment with:
- VOL Test Runner WS codeunit (78000)
- VOL Furniture Tests codeunit (60000) or other test codeunits

### 2. Web Service Registration
In Business Central, register the web service:
1. Go to **Web Services** page (search for "Web Services")
2. Add a new entry:
   - **Object Type**: Codeunit
   - **Object ID**: 78000
   - **Service Name**: TestRunner
   - **Published**: Yes
3. Ensure **OData V4 URL** is enabled (check the ODataV4 URL column has a value)

Or import the `WS.xml` file:
```xml
<?xml version="1.0" encoding="utf-8"?>
<ExportedData>
    <TenantWebServiceCollection>
        <TenantWebService>
            <ObjectType>CodeUnit</ObjectType>
            <ObjectID>78000</ObjectID>
            <ServiceName>TestRunner</ServiceName>
            <Published>true</Published>
        </TenantWebService>
    </TenantWebServiceCollection>
</ExportedData>
```

### 3. Azure AD App Registration
For OAuth2 authentication:
1. Register an Azure AD application
2. Grant API permissions: `Dynamics 365 Business Central` → `API.ReadWrite.All`
3. Create a client secret
4. Add the values to `.env`:
   ```
   BC_TENANT_ID=your-tenant-id
   BC_CLIENT_ID=your-client-id
   BC_CLIENT_SECRET=your-client-secret
   ```

### 4. User Permissions
The Azure AD app must have a corresponding user in BC with the **TestVolt** permission set (ID 60000) assigned. This permission set includes:
- AL Test Framework tables (AL Test Suite, Test Method Line, etc.)
- Test execution codeunits (Test Runner - Mgt, etc.)
- Tables/pages being tested (e.g., VOL Furniture tabledata RIMD)

To assign permissions:
1. Go to **Users** page in BC
2. Find the Azure AD app user
3. Add permission set: **TestVolt** (ID 60000)

## OData API Reference

### Base URL Format
```
https://api.businesscentral.dynamics.com/v2.0/{tenantId}/{environment}/ODataV4/TestRunner_{Function}?company={companyName}
```

### Authentication
All requests require OAuth2 Bearer token:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Available Endpoints

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `Ping` | Health check | None | Status JSON |
| `ListTestCodeunits` | List all test codeunits | None | Array of codeunits |
| `ListTestSuites` | List all test suites | None | Array of suites |
| `RunTestCodeunit` | Run specific codeunit | `codeunitId` (integer) | Test results JSON |
| `RunTestsByExtension` | Run all tests for an app | `extensionId` (GUID) | Test results JSON |
| `RunTestSuite` | Run a named test suite | `suiteName` (string) | Test results JSON |
| `GetTestResults` | Get results without running | `suiteName` (string) | Test results JSON |

## PowerShell Examples

### Configuration
```powershell
# Load from .env or set directly
$tenantId = "your-tenant-id"
$clientId = "your-client-id"
$clientSecret = "your-client-secret"
$environmentName = "v27"          # or "Production", "Sandbox", etc.
$companyName = "CRONUS USA, Inc."
```

### Get OAuth Token
```powershell
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$tokenBody = @{
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = 'https://api.businesscentral.dynamics.com/.default'
    grant_type    = 'client_credentials'
}

$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $tokenBody -ContentType 'application/x-www-form-urlencoded'
$accessToken = $tokenResponse.access_token
```

### Standard Headers
```powershell
$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type'  = 'application/json'
    'Accept'        = 'application/json'
}

$encodedCompany = [uri]::EscapeDataString($companyName)
$baseUrl = "https://api.businesscentral.dynamics.com/v2.0/$tenantId/$environmentName/ODataV4"
```

### 1. Ping - Health Check
```powershell
$pingUrl = "$baseUrl/TestRunner_Ping?company=$encodedCompany"
$response = Invoke-RestMethod -Uri $pingUrl -Method POST -Headers $headers -Body '{}'
$result = $response.value | ConvertFrom-Json

# Response:
# {
#     "status": "ok",
#     "service": "VOL Test Runner WS",
#     "timestamp": "2025-12-12T00:05:21.99Z",
#     "version": "1.0.0"
# }
```

### 2. List Test Codeunits
```powershell
$listUrl = "$baseUrl/TestRunner_ListTestCodeunits?company=$encodedCompany"
$response = Invoke-RestMethod -Uri $listUrl -Method POST -Headers $headers -Body '{}'
$codeunits = $response.value | ConvertFrom-Json

# Response:
# [
#     {
#         "id": 60000,
#         "name": "VOL Furniture Tests",
#         "appId": "{42879888-8631-446B-A34F-A858AAABC8B0}"
#     }
# ]
```

### 3. Run Test Codeunit
```powershell
$runUrl = "$baseUrl/TestRunner_RunTestCodeunit?company=$encodedCompany"
$body = '{"codeunitId": 60000}'
$response = Invoke-RestMethod -Uri $runUrl -Method POST -Headers $headers -Body $body -TimeoutSec 600
$results = $response.value | ConvertFrom-Json

# Display results
Write-Host "Total: $($results.totalTests), Passed: $($results.passed), Failed: $($results.failed)"
```

### 4. Run Tests by Extension
```powershell
$runUrl = "$baseUrl/TestRunner_RunTestsByExtension?company=$encodedCompany"
$body = '{"extensionId": "42879888-8631-446b-a34f-a858aaabc8b0"}'
$response = Invoke-RestMethod -Uri $runUrl -Method POST -Headers $headers -Body $body -TimeoutSec 600
$results = $response.value | ConvertFrom-Json
```

## Response JSON Format

### Test Results Structure
```json
{
    "suite": "SINGLE",
    "timestamp": "2025-12-12T00:08:25.584Z",
    "totalTests": 9,
    "passed": 9,
    "failed": 0,
    "skipped": 0,
    "notExecuted": 0,
    "success": true,
    "codeunits": [
        {
            "codeunitId": 60000,
            "codeunitName": "VOL Furniture Tests",
            "result": "Success",
            "startTime": "2025-12-12T00:08:24.237Z",
            "finishTime": "2025-12-12T00:08:25.507Z",
            "tests": [
                {
                    "method": "TestCreateFurnitureRecord",
                    "name": "TestCreateFurnitureRecord",
                    "result": "Success",
                    "startTime": "2025-12-12T00:08:24.3Z",
                    "finishTime": "2025-12-12T00:08:24.797Z"
                },
                {
                    "method": "TestUpdateFurnitureRecord",
                    "name": "TestUpdateFurnitureRecord",
                    "result": "Failure",
                    "startTime": "2025-12-12T00:08:24.86Z",
                    "finishTime": "2025-12-12T00:08:24.907Z",
                    "errorMessage": "Assertion failed: ...",
                    "errorCallStack": "..."
                }
            ]
        }
    ]
}
```

### Result Values
- `Success`: Test passed
- `Failure`: Test failed with assertion or error
- `Skipped`: Test was skipped
- `NotExecuted`: Test was not run

## Using the PowerShell Scripts

### Quick Test Execution
```powershell
# Run a specific test codeunit
.\bc-run-tests-odata.ps1 -TestCodeunitId 60000

# List available test codeunits
.\bc-run-tests-odata.ps1 -Action List

# Health check
.\bc-run-tests-odata.ps1 -Action Ping

# Run all tests for an extension
.\bc-run-tests-odata.ps1 -Action RunExtension -ExtensionId "42879888-8631-446b-a34f-a858aaabc8b0"

# Get JSON output
.\bc-run-tests-odata.ps1 -TestCodeunitId 60000 -OutputFormat Json
```

### Unified Executor (Auto-detects deployment type)
```powershell
# Automatically uses OData for online or BCContainerHelper for local
.\bc-test-executor.ps1 -TestCodeunitId 60000
```

## Troubleshooting

### Common Errors

#### 403 Forbidden
**Error**: `Sorry, the current permissions prevented the action. (TableData 130451 AL Test Suite Read: BC Test)`

**Solution**: Assign the **TestVolt** permission set to the Azure AD app user in BC.

#### 403 Forbidden (TableData VOL Furniture)
**Error**: `Sorry, the current permissions prevented the action. (TableData 50000 VOL Furniture Insert: BC Test)`

**Solution**: The TestVolt permission set must include `tabledata "VOL Furniture" = RIMD` for the tables being tested.

#### 404 Not Found
**Error**: Service endpoint not found

**Solution**: Verify the TestRunner web service is registered and published in BC with OData V4 enabled.

#### 401 Unauthorized
**Error**: Authentication failed

**Solution**:
1. Check Azure AD credentials in `.env`
2. Verify the client secret hasn't expired
3. Ensure API permissions are granted

#### 500 Internal Server Error
**Error**: Server-side error during test execution

**Solution**:
1. Check BC event log for detailed error
2. Verify test codeunit exists and is marked with `Subtype = Test`
3. Check for runtime errors in test code

### Debugging Tips

1. **Test Ping first**: Always start with `TestRunner_Ping` to verify connectivity
2. **List codeunits**: Use `TestRunner_ListTestCodeunits` to verify test codeunits are visible
3. **Check company name**: Ensure the company name exactly matches (case-sensitive, URL-encoded)
4. **Timeout**: Test execution may take several minutes - use adequate timeout (300-600 seconds)

## Files Reference

| File | Description |
|------|-------------|
| `BC Test/src/VOLTestRunnerWS.Codeunit.al` | Test runner web service codeunit |
| `BC Test/src/VOLFurnitureTests.Codeunit.al` | Furniture module test codeunit |
| `BC Test/src/TestVolt.permissionset.al` | Permission set for test execution |
| `BC Test/WS.xml` | Web service export file |
| `.claude/scripts/bc-run-tests-odata.ps1` | OData test runner script |
| `.claude/scripts/bc-test-executor.ps1` | Unified test executor |
| `.claude/scripts/bc-run-tests.ps1` | Local/Docker test runner |
