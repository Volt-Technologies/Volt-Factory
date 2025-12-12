<#
.SYNOPSIS
    Unified BC Test Executor for Online and Local environments

.DESCRIPTION
    Automatically detects the deployment type and executes tests using the best available method:

    For ONLINE (SaaS) deployments:
    - Uses OData web service API via bc-run-tests-odata.ps1
    - Calls VOL Test Runner WS codeunit (78000) exposed as TestRunner web service
    - Requires Azure AD app registration with proper permissions

    For LOCAL (Docker) deployments:
    - Uses BCContainerHelper PowerShell module via bc-run-tests.ps1
    - Connects directly to the container for test execution

    PREREQUISITES FOR ONLINE:
    1. BC Test app published with VOL Test Runner WS (Codeunit 78000)
    2. TestRunner web service registered in BC with OData V4 enabled
    3. Azure AD App Registration with BC API permissions
    4. User in BC with TestVolt permission set (60000) assigned
    5. .env file configured with BC_TENANT_ID, BC_CLIENT_ID, BC_CLIENT_SECRET, etc.

.PARAMETER TestCodeunitId
    Test codeunit ID to execute (e.g., 60000)

.PARAMETER ExtensionId
    Extension/App GUID to run all tests for

.PARAMETER Action
    Action to perform: RunCodeunit, RunExtension, List, Ping (default: RunCodeunit)

.PARAMETER OutputFormat
    Output format: Summary, Detailed, Json (default: Detailed)

.EXAMPLE
    .\bc-test-executor.ps1 -TestCodeunitId 60000
    Runs test codeunit 60000 using the appropriate method for the deployment type

.EXAMPLE
    .\bc-test-executor.ps1 -Action List
    Lists all available test codeunits

.EXAMPLE
    .\bc-test-executor.ps1 -Action Ping
    Health check to verify the test runner service is working
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$TestCodeunitId,

    [Parameter(Mandatory=$false)]
    [string]$ExtensionId,

    [Parameter(Mandatory=$false)]
    [ValidateSet("RunCodeunit", "RunExtension", "List", "Ping")]
    [string]$Action = "RunCodeunit",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Summary", "Detailed", "Json")]
    [string]$OutputFormat = "Detailed"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "Business Central Test Executor" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Load .env configuration
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
} else {
    Write-Host "ERROR: .env file not found at $envFile" -ForegroundColor Red
    Write-Host "Please copy .env.example to .env and configure it." -ForegroundColor Yellow
    exit 1
}

$deploymentType = $config["BC_DEPLOYMENT_TYPE"]
$environmentType = $config["BC_ENVIRONMENT_TYPE"]
$environmentName = $config["BC_ENVIRONMENT_NAME"]

Write-Host "Environment Configuration:" -ForegroundColor Yellow
Write-Host "  Deployment Type:  $deploymentType"
Write-Host "  Environment Type: $environmentType"
Write-Host "  Environment Name: $environmentName"
Write-Host ""

# Validate action-specific parameters
if ($Action -eq "RunCodeunit" -and -not $TestCodeunitId) {
    Write-Host "ERROR: -TestCodeunitId is required for RunCodeunit action" -ForegroundColor Red
    Write-Host "Example: .\bc-test-executor.ps1 -TestCodeunitId 60000" -ForegroundColor Yellow
    exit 1
}
if ($Action -eq "RunExtension" -and -not $ExtensionId) {
    Write-Host "ERROR: -ExtensionId is required for RunExtension action" -ForegroundColor Red
    Write-Host "Example: .\bc-test-executor.ps1 -Action RunExtension -ExtensionId '42879888-8631-446b-a34f-a858aaabc8b0'" -ForegroundColor Yellow
    exit 1
}

# Route to appropriate executor based on deployment type
if ($deploymentType -eq "online") {
    Write-Host "Using ONLINE (OData) test execution method" -ForegroundColor Cyan
    Write-Host ""

    $odataScript = Join-Path $ScriptPath "bc-run-tests-odata.ps1"
    if (-not (Test-Path $odataScript)) {
        Write-Host "ERROR: bc-run-tests-odata.ps1 not found at $odataScript" -ForegroundColor Red
        exit 1
    }

    # Build parameters for OData script
    $params = @{
        Action = $Action
        OutputFormat = $OutputFormat
    }

    if ($TestCodeunitId) { $params.TestCodeunitId = $TestCodeunitId }
    if ($ExtensionId) { $params.ExtensionId = $ExtensionId }

    & $odataScript @params
    exit $LASTEXITCODE

} elseif ($deploymentType -eq "local") {
    Write-Host "Using LOCAL (Docker/BCContainerHelper) test execution method" -ForegroundColor Cyan
    Write-Host ""

    # Check for BCContainerHelper
    $bcHelper = Get-Module -ListAvailable -Name BCContainerHelper
    if (-not $bcHelper) {
        Write-Host "ERROR: BCContainerHelper module not installed" -ForegroundColor Red
        Write-Host "Install with: Install-Module BCContainerHelper -Force" -ForegroundColor Yellow
        exit 1
    }

    $localScript = Join-Path $ScriptPath "bc-run-tests.ps1"
    if (-not (Test-Path $localScript)) {
        Write-Host "ERROR: bc-run-tests.ps1 not found at $localScript" -ForegroundColor Red
        exit 1
    }

    if ($Action -eq "RunCodeunit" -or $Action -eq "RunExtension") {
        $testRange = if ($TestCodeunitId) { "$TestCodeunitId..$TestCodeunitId" } else { "1..999999999" }
        & $localScript -TestCodeunitIdRange $testRange
        exit $LASTEXITCODE
    } elseif ($Action -eq "List" -or $Action -eq "Ping") {
        Write-Host "Action '$Action' is only supported for online deployments." -ForegroundColor Yellow
        Write-Host "For local containers, use the BC web client to view test codeunits." -ForegroundColor Yellow
        exit 0
    }

} else {
    Write-Host "ERROR: Unknown deployment type: $deploymentType" -ForegroundColor Red
    Write-Host "Set BC_DEPLOYMENT_TYPE to 'online' or 'local' in .env" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
