<#
.SYNOPSIS
    Runs AL tests in Business Central Online using OData Web Services

.DESCRIPTION
    This script executes BC tests using the TestRunner OData web service with OAuth authentication.
    It calls the VOL Test Runner WS codeunit (78000) which is published as an OData V4 web service.

    PREREQUISITES:
    1. BC Test app must be published with VOL Test Runner WS codeunit (78000)
    2. TestRunner web service must be registered in BC (Web Services page):
       - Object Type: Codeunit
       - Object ID: 78000
       - Service Name: TestRunner
       - Published: Yes
       - OData V4 URL must be enabled
    3. Azure AD App Registration must have:
       - API permissions for Business Central
       - User in BC with TestVolt permission set (60000) assigned
       - Permission set must include:
         * AL Test Framework tables (AL Test Suite, Test Method Line, etc.)
         * Tables/Pages being tested (e.g., VOL Furniture tabledata RIMD)

    AVAILABLE ODATA ENDPOINTS:
    - TestRunner_Ping: Health check, returns {"status":"ok",...}
    - TestRunner_ListTestCodeunits: List all test codeunits, returns [{id, name, appId},...]
    - TestRunner_ListTestSuites: List all test suites
    - TestRunner_RunTestCodeunit: Run specific codeunit by ID
    - TestRunner_RunTestsByExtension: Run all tests for an app by extension GUID
    - TestRunner_RunTestSuite: Run a named test suite
    - TestRunner_GetTestResults: Get results without running

    ODATA CALL FORMAT:
    URL: https://api.businesscentral.dynamics.com/v2.0/{tenantId}/{environment}/ODataV4/TestRunner_{Function}?company={companyName}
    Method: POST
    Headers: Authorization: Bearer {token}, Content-Type: application/json
    Body: JSON with parameters (e.g., {"codeunitId": 60000})

.PARAMETER TestCodeunitId
    Test codeunit ID to execute (e.g., 60000). Use this OR ExtensionId.

.PARAMETER ExtensionId
    Extension/App GUID to run all tests for (e.g., "42879888-8631-446b-a34f-a858aaabc8b0")

.PARAMETER TestSuiteName
    Name of an existing test suite to run (e.g., "DEFAULT")

.PARAMETER Action
    Action to perform: RunCodeunit, RunExtension, RunSuite, List, Ping (default: RunCodeunit)

.PARAMETER CompanyName
    BC Company name (default: from BC_COMPANY_NAME in .env)

.PARAMETER EnvironmentName
    BC Environment name (default: from BC_ENVIRONMENT_NAME in .env)

.PARAMETER OutputFormat
    Output format: Summary, Detailed, Json (default: Detailed)

.EXAMPLE
    .\bc-run-tests-odata.ps1 -TestCodeunitId 60000
    Runs test codeunit 60000 and displays detailed results

.EXAMPLE
    .\bc-run-tests-odata.ps1 -Action List
    Lists all available test codeunits

.EXAMPLE
    .\bc-run-tests-odata.ps1 -Action Ping
    Health check to verify the web service is working

.EXAMPLE
    .\bc-run-tests-odata.ps1 -ExtensionId "42879888-8631-446b-a34f-a858aaabc8b0"
    Runs all tests for the specified extension

.EXAMPLE
    .\bc-run-tests-odata.ps1 -TestCodeunitId 60000 -OutputFormat Json
    Runs tests and outputs raw JSON result
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$TestCodeunitId,

    [Parameter(Mandatory=$false)]
    [string]$ExtensionId,

    [Parameter(Mandatory=$false)]
    [string]$TestSuiteName,

    [Parameter(Mandatory=$false)]
    [ValidateSet("RunCodeunit", "RunExtension", "RunSuite", "List", "Ping")]
    [string]$Action = "RunCodeunit",

    [Parameter(Mandatory=$false)]
    [string]$CompanyName,

    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Summary", "Detailed", "Json")]
    [string]$OutputFormat = "Detailed"
)

$ErrorActionPreference = "Stop"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Load configuration from .env file
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptPath)
$envFile = Join-Path $RepoRoot ".env"

$config = @{}
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $config[$key] = $value
        }
    }
}

# Get configuration values
$tenantId = $config["BC_TENANT_ID"]
$clientId = $config["BC_CLIENT_ID"]
$clientSecret = $config["BC_CLIENT_SECRET"]
if (-not $EnvironmentName) { $EnvironmentName = $config["BC_ENVIRONMENT_NAME"] }
if (-not $CompanyName) { $CompanyName = $config["BC_COMPANY_NAME"] }
if (-not $CompanyName) { $CompanyName = "CRONUS USA, Inc." }

# Validate required configuration
$missingConfig = @()
if (-not $tenantId) { $missingConfig += "BC_TENANT_ID" }
if (-not $clientId) { $missingConfig += "BC_CLIENT_ID" }
if (-not $clientSecret) { $missingConfig += "BC_CLIENT_SECRET" }
if (-not $EnvironmentName) { $missingConfig += "BC_ENVIRONMENT_NAME" }

if ($missingConfig.Count -gt 0) {
    Write-Host "ERROR: Missing required configuration in .env:" -ForegroundColor Red
    $missingConfig | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

# Validate action-specific parameters
if ($Action -eq "RunCodeunit" -and -not $TestCodeunitId) {
    Write-Host "ERROR: -TestCodeunitId is required for RunCodeunit action" -ForegroundColor Red
    exit 1
}
if ($Action -eq "RunExtension" -and -not $ExtensionId) {
    Write-Host "ERROR: -ExtensionId is required for RunExtension action" -ForegroundColor Red
    exit 1
}
if ($Action -eq "RunSuite" -and -not $TestSuiteName) {
    Write-Host "ERROR: -TestSuiteName is required for RunSuite action" -ForegroundColor Red
    exit 1
}

# ============================================================================
# FUNCTIONS
# ============================================================================

function Get-OAuthToken {
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    $tokenBody = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = 'https://api.businesscentral.dynamics.com/.default'
        grant_type    = 'client_credentials'
    }

    $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $tokenBody -ContentType 'application/x-www-form-urlencoded'
    return $tokenResponse.access_token
}

function Invoke-TestRunnerApi {
    param(
        [string]$Function,
        [hashtable]$Body = @{},
        [string]$AccessToken,
        [string]$TenantId,
        [string]$EnvironmentName,
        [string]$CompanyName
    )

    $encodedCompany = [uri]::EscapeDataString($CompanyName)
    $baseUrl = "https://api.businesscentral.dynamics.com/v2.0/$TenantId/$EnvironmentName/ODataV4"
    $url = "$baseUrl/TestRunner_$Function`?company=$encodedCompany"

    $headers = @{
        'Authorization' = "Bearer $AccessToken"
        'Content-Type'  = 'application/json'
        'Accept'        = 'application/json'
    }

    $jsonBody = if ($Body.Count -gt 0) { $Body | ConvertTo-Json -Compress } else { '{}' }

    $response = Invoke-RestMethod -Uri $url -Method POST -Headers $headers -Body $jsonBody -TimeoutSec 600
    return $response
}

function Format-TestResults {
    param(
        [PSCustomObject]$Results,
        [string]$Format
    )

    if ($Format -eq "Json") {
        return $Results | ConvertTo-Json -Depth 10
    }

    $output = @()
    $output += ""
    $output += "=" * 60
    $output += "TEST RESULTS"
    $output += "=" * 60
    $output += ""
    $output += "Suite:       $($Results.suite)"
    $output += "Timestamp:   $($Results.timestamp)"
    $output += "Total Tests: $($Results.totalTests)"
    $output += ""

    $passedColor = "Green"
    $failedColor = if ($Results.failed -gt 0) { "Red" } else { "Green" }
    $skippedColor = if ($Results.skipped -gt 0) { "Yellow" } else { "White" }

    Write-Host ($output -join "`n")
    Write-Host "Passed:      $($Results.passed)" -ForegroundColor $passedColor
    Write-Host "Failed:      $($Results.failed)" -ForegroundColor $failedColor
    Write-Host "Skipped:     $($Results.skipped)" -ForegroundColor $skippedColor
    Write-Host "Success:     $($Results.success)" -ForegroundColor $(if ($Results.success) { "Green" } else { "Red" })

    if ($Format -eq "Detailed" -and $Results.codeunits) {
        Write-Host ""
        Write-Host ("-" * 60)
        Write-Host "DETAILED RESULTS"
        Write-Host ("-" * 60)

        foreach ($codeunit in $Results.codeunits) {
            Write-Host ""
            Write-Host "Codeunit: $($codeunit.codeunitName) (ID: $($codeunit.codeunitId))" -ForegroundColor Cyan

            foreach ($test in $codeunit.tests) {
                $icon = switch ($test.result) {
                    "Success" { "[PASS]" }
                    "Failure" { "[FAIL]" }
                    "Skipped" { "[SKIP]" }
                    default   { "[????]" }
                }
                $color = switch ($test.result) {
                    "Success" { "Green" }
                    "Failure" { "Red" }
                    "Skipped" { "Yellow" }
                    default   { "Gray" }
                }

                Write-Host "  $icon $($test.method)" -ForegroundColor $color

                if ($test.errorMessage) {
                    Write-Host "       Error: $($test.errorMessage)" -ForegroundColor Red
                }
            }
        }
    }

    Write-Host ""
    Write-Host ("=" * 60)

    return $null
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Business Central OData Test Runner" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Environment:  $EnvironmentName"
Write-Host "  Company:      $CompanyName"
Write-Host "  Action:       $Action"
if ($TestCodeunitId) { Write-Host "  Codeunit ID:  $TestCodeunitId" }
if ($ExtensionId) { Write-Host "  Extension ID: $ExtensionId" }
if ($TestSuiteName) { Write-Host "  Suite Name:   $TestSuiteName" }
Write-Host ""

# Get OAuth token
Write-Host "Authenticating..." -ForegroundColor Yellow
try {
    $accessToken = Get-OAuthToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret
    Write-Host "Authentication successful" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Authentication failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""

# Execute action
$startTime = Get-Date

try {
    switch ($Action) {
        "Ping" {
            Write-Host "Testing service health..." -ForegroundColor Yellow
            $response = Invoke-TestRunnerApi -Function "Ping" -AccessToken $accessToken -TenantId $tenantId -EnvironmentName $EnvironmentName -CompanyName $CompanyName
            $result = $response.value | ConvertFrom-Json
            Write-Host ""
            Write-Host "Service Status: $($result.status)" -ForegroundColor Green
            Write-Host "Service Name:   $($result.service)"
            Write-Host "Version:        $($result.version)"
            Write-Host "Timestamp:      $($result.timestamp)"
        }

        "List" {
            Write-Host "Listing test codeunits..." -ForegroundColor Yellow
            $response = Invoke-TestRunnerApi -Function "ListTestCodeunits" -AccessToken $accessToken -TenantId $tenantId -EnvironmentName $EnvironmentName -CompanyName $CompanyName
            $codeunits = $response.value | ConvertFrom-Json
            Write-Host ""
            Write-Host "Available Test Codeunits:" -ForegroundColor Cyan
            Write-Host ("-" * 60)
            foreach ($cu in $codeunits) {
                Write-Host "  [$($cu.id)] $($cu.name)" -ForegroundColor White
                Write-Host "       App ID: $($cu.appId)" -ForegroundColor Gray
            }
            Write-Host ""
            Write-Host "Total: $($codeunits.Count) test codeunit(s)" -ForegroundColor Green
        }

        "RunCodeunit" {
            Write-Host "Running test codeunit $TestCodeunitId..." -ForegroundColor Yellow
            $response = Invoke-TestRunnerApi -Function "RunTestCodeunit" -Body @{ codeunitId = $TestCodeunitId } -AccessToken $accessToken -TenantId $tenantId -EnvironmentName $EnvironmentName -CompanyName $CompanyName
            $results = $response.value | ConvertFrom-Json
            Format-TestResults -Results $results -Format $OutputFormat

            if (-not $results.success) {
                exit 1
            }
        }

        "RunExtension" {
            Write-Host "Running tests for extension $ExtensionId..." -ForegroundColor Yellow
            $response = Invoke-TestRunnerApi -Function "RunTestsByExtension" -Body @{ extensionId = $ExtensionId } -AccessToken $accessToken -TenantId $tenantId -EnvironmentName $EnvironmentName -CompanyName $CompanyName
            $results = $response.value | ConvertFrom-Json
            Format-TestResults -Results $results -Format $OutputFormat

            if (-not $results.success) {
                exit 1
            }
        }

        "RunSuite" {
            Write-Host "Running test suite '$TestSuiteName'..." -ForegroundColor Yellow
            $response = Invoke-TestRunnerApi -Function "RunTestSuite" -Body @{ suiteName = $TestSuiteName } -AccessToken $accessToken -TenantId $tenantId -EnvironmentName $EnvironmentName -CompanyName $CompanyName
            $results = $response.value | ConvertFrom-Json
            Format-TestResults -Results $results -Format $OutputFormat

            if (-not $results.success) {
                exit 1
            }
        }
    }

    $duration = (Get-Date) - $startTime
    Write-Host ""
    Write-Host "Completed in $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Gray

} catch {
    $statusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "N/A" }
    Write-Host ""
    Write-Host "ERROR: API call failed (HTTP $statusCode)" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    # Try to extract detailed error from response body
    try {
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
            if ($responseBody.error.message) {
                Write-Host ""
                Write-Host "BC Error: $($responseBody.error.message)" -ForegroundColor Red
            }
        }
    } catch {
        # Ignore parsing errors
    }

    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - 403 Forbidden: Check that TestVolt permission set is assigned to the API user"
    Write-Host "  - 404 Not Found: Verify TestRunner web service is registered in BC"
    Write-Host "  - 401 Unauthorized: Check Azure AD app credentials in .env"
    Write-Host ""

    exit 1
}

Write-Host ""
