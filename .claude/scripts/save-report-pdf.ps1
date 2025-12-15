<#
.SYNOPSIS
    Saves a Base64 encoded PDF to the test-outputs/reports folder.

.DESCRIPTION
    This script takes a Base64 encoded PDF string and saves it as a PDF file
    in the test-outputs/reports folder for human verification after report testing.

.PARAMETER Base64Pdf
    The Base64 encoded PDF content.

.PARAMETER ReportName
    The name of the report (used in filename).

.PARAMETER ReportId
    Optional. The report ID (used in filename).

.PARAMETER Timestamp
    Optional. If specified, adds timestamp to filename. Default is true.

.EXAMPLE
    .\save-report-pdf.ps1 -Base64Pdf $pdfContent -ReportName "CustomerList"

.EXAMPLE
    .\save-report-pdf.ps1 -Base64Pdf $pdfContent -ReportName "CustomerList" -ReportId 50100 -Timestamp $false
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Base64Pdf,

    [Parameter(Mandatory=$true)]
    [string]$ReportName,

    [Parameter(Mandatory=$false)]
    [int]$ReportId = 0,

    [Parameter(Mandatory=$false)]
    [bool]$Timestamp = $true
)

# Get the script directory and navigate to repo root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
$outputDir = Join-Path $repoRoot "test-outputs\reports"

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Build filename
$sanitizedName = $ReportName -replace '[^a-zA-Z0-9_-]', '_'

if ($Timestamp) {
    $dateStr = Get-Date -Format "yyyy-MM-dd_HHmmss"
    if ($ReportId -gt 0) {
        $filename = "${sanitizedName}_${ReportId}_${dateStr}.pdf"
    } else {
        $filename = "${sanitizedName}_${dateStr}.pdf"
    }
} else {
    if ($ReportId -gt 0) {
        $filename = "${sanitizedName}_${ReportId}.pdf"
    } else {
        $filename = "${sanitizedName}.pdf"
    }
}

$outputPath = Join-Path $outputDir $filename

# Decode Base64 and save
try {
    $bytes = [Convert]::FromBase64String($Base64Pdf)
    [IO.File]::WriteAllBytes($outputPath, $bytes)

    Write-Host "PDF saved successfully: $outputPath" -ForegroundColor Green
    Write-Host "File size: $([math]::Round($bytes.Length / 1024, 2)) KB" -ForegroundColor Cyan

    # Return the path for further processing
    return $outputPath
}
catch {
    Write-Host "Error saving PDF: $_" -ForegroundColor Red
    exit 1
}
