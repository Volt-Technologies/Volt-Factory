# PDF Screenshot Comparison using Browser Automation
# Opens PDFs in browser and captures screenshots for visual comparison

param(
    [string]$ExamplePdf = "example.pdf",
    [string]$GeneratedPdf = "pdfs\Report_50000_PS-INV103001_20251215_211208.pdf",
    [string]$OutputDir = "pdfs\comparison"
)

$ErrorActionPreference = "Stop"

Write-Host "=== PDF Screenshot Comparison Tool ===" -ForegroundColor Cyan
Write-Host ""

# Check if PDFs exist
if (-not (Test-Path $ExamplePdf)) {
    Write-Host "ERROR: Example PDF not found: $ExamplePdf" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $GeneratedPdf)) {
    Write-Host "ERROR: Generated PDF not found: $GeneratedPdf" -ForegroundColor Red
    exit 1
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Get absolute paths
$examplePath = (Resolve-Path $ExamplePdf).Path
$generatedPath = (Resolve-Path $GeneratedPdf).Path

# Convert to file:// URLs
$exampleUrl = "file:///$($examplePath -replace '\\', '/')"
$generatedUrl = "file:///$($generatedPath -replace '\\', '/')"

Write-Host "Example PDF: $examplePath" -ForegroundColor Yellow
Write-Host "Generated PDF: $generatedPath" -ForegroundColor Yellow
Write-Host ""

# Try to use Selenium WebDriver or Chrome DevTools Protocol
Write-Host "Attempting to capture screenshots..." -ForegroundColor Yellow

# Method 1: Try using Chrome/Edge with --headless
$chromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
)

$browserPath = $null
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        $browserPath = $path
        break
    }
}

if ($browserPath) {
    Write-Host "Found browser: $browserPath" -ForegroundColor Green
    
    # Create a simple HTML file to display both PDFs side by side
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>PDF Comparison</title>
    <style>
        body { margin: 0; padding: 20px; background: #f0f0f0; }
        .container { display: flex; gap: 20px; justify-content: center; }
        .pdf-viewer { flex: 1; background: white; padding: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .pdf-viewer h2 { margin-top: 0; color: #0066CC; }
        iframe { width: 100%; height: 1200px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <div class="container">
        <div class="pdf-viewer">
            <h2>Example PDF</h2>
            <iframe src="$exampleUrl"></iframe>
        </div>
        <div class="pdf-viewer">
            <h2>Generated PDF</h2>
            <iframe src="$generatedUrl"></iframe>
        </div>
    </div>
</body>
</html>
"@
    
    $htmlPath = Join-Path $OutputDir "comparison.html"
    $htmlContent | Out-File -FilePath $htmlPath -Encoding UTF8
    
    Write-Host "Created comparison HTML: $htmlPath" -ForegroundColor Green
    Write-Host "Opening in browser for visual comparison..." -ForegroundColor Yellow
    
    Start-Process $browserPath -ArgumentList $htmlPath
    Start-Sleep -Seconds 2
    
    Write-Host "`n=== Instructions ===" -ForegroundColor Cyan
    Write-Host "1. The browser should now show both PDFs side-by-side" -ForegroundColor White
    Write-Host "2. Visually compare: colors, fonts, layout, spacing, columns" -ForegroundColor White
    Write-Host "3. Note differences and we'll update the RDLC accordingly" -ForegroundColor White
    Write-Host "`nComparison HTML saved to: $htmlPath" -ForegroundColor Green
    
} else {
    Write-Host "No browser found. Opening PDFs directly..." -ForegroundColor Yellow
    Start-Process $examplePath
    Start-Sleep -Seconds 1
    Start-Process $generatedPath
    
    Write-Host "`nBoth PDFs opened. Please compare them visually." -ForegroundColor Yellow
    Write-Host "Note the differences in:" -ForegroundColor Cyan
    Write-Host "  - Header layout and colors" -ForegroundColor White
    Write-Host "  - Font sizes and weights" -ForegroundColor White
    Write-Host "  - Element positions and spacing" -ForegroundColor White
    Write-Host "  - Column widths and alignment" -ForegroundColor White
    Write-Host "  - Colors (#0066CC blue, #FF6600 orange)" -ForegroundColor White
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "After comparing, provide feedback on differences found," -ForegroundColor White
Write-Host "and I'll update the RDLC file accordingly." -ForegroundColor White

