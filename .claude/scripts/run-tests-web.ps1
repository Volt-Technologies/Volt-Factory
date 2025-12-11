# Run tests via Web Client
param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$TestCodeunitIdRange = "70200..70206"
)

Write-Host "=== Running Tests via Web Client ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor White
Write-Host "Test Range: $TestCodeunitIdRange" -ForegroundColor White
Write-Host ""

# Parse range
$rangeParts = $TestCodeunitIdRange -split '\.\.'
$startId = [int]$rangeParts[0]
$endId = [int]$rangeParts[1]

# Get container info
$containerInfo = docker inspect $ContainerName | ConvertFrom-Json
$webPort = ($containerInfo.NetworkSettings.Ports.'80/tcp'[0].HostPort)

if (-not $webPort) {
    Write-Host "ERROR: Could not determine web port" -ForegroundColor Red
    exit 1
}

$url = "http://localhost:$webPort/BC/?company=CRONUS%20International%20Ltd.&page=130455&testsuite=DEFAULT"
Write-Host "Test Tool URL: $url" -ForegroundColor Gray
Write-Host ""
Write-Host "Please open this URL in a browser and run tests manually for codeunit range: $startId..$endId" -ForegroundColor Yellow
Write-Host ""
Write-Host "Attempting to open browser..." -ForegroundColor Gray
Start-Process $url
