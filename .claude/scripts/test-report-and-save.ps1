<#
.SYNOPSIS
    Tests a BC report and saves the PDF output to the repo.

.DESCRIPTION
    This script calls the VOL Report Test Helper web service in Business Central,
    runs a report with specified record, and saves the PDF output for human verification.

.PARAMETER ReportId
    The ID of the report to test.

.PARAMETER TableNo
    The table number of the source record.

.PARAMETER RecordSystemId
    The SystemId (GUID) of the record to use.

.PARAMETER ReportName
    The name of the report (for filename).

.PARAMETER BCBaseUrl
    The base URL of the Business Central instance.

.PARAMETER CompanyName
    The company name in Business Central.

.PARAMETER Credential
    PSCredential object for authentication. If not provided, will prompt.

.EXAMPLE
    .\test-report-and-save.ps1 -ReportId 50100 -TableNo 18 -RecordSystemId "abc-123-..." -ReportName "CustomerList" -BCBaseUrl "http://localhost:7048/BC" -CompanyName "CRONUS"
#>

param(
    [Parameter(Mandatory=$true)]
    [int]$ReportId,

    [Parameter(Mandatory=$true)]
    [int]$TableNo,

    [Parameter(Mandatory=$true)]
    [string]$RecordSystemId,

    [Parameter(Mandatory=$true)]
    [string]$ReportName,

    [Parameter(Mandatory=$false)]
    [string]$BCBaseUrl = "http://localhost:7048/BC",

    [Parameter(Mandatory=$false)]
    [string]$CompanyName = "CRONUS USA, Inc.",

    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential
)

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Build the web service URL
$encodedCompany = [System.Web.HttpUtility]::UrlEncode($CompanyName)
$wsUrl = "$BCBaseUrl/ODataV4/Company('$encodedCompany')/VOLReportTestHelper_RunReportAsJson?ReportId=$ReportId&TableNo=$TableNo&RecordSystemId='$RecordSystemId'"

Write-Host "Testing report $ReportId..." -ForegroundColor Cyan
Write-Host "URL: $wsUrl" -ForegroundColor Gray

# Get credentials if not provided
if (-not $Credential) {
    $Credential = Get-Credential -Message "Enter BC credentials"
}

try {
    # Call the web service
    $response = Invoke-RestMethod -Uri $wsUrl -Method Get -Credential $Credential -ContentType "application/json"

    if ($response.success) {
        Write-Host "Report generated successfully!" -ForegroundColor Green
        Write-Host "Duration: $($response.durationMs) ms" -ForegroundColor Cyan
        Write-Host "PDF Size: $($response.pdfSizeBytes) bytes" -ForegroundColor Cyan

        # Save the PDF
        $savePdfScript = Join-Path $scriptDir "save-report-pdf.ps1"
        $savedPath = & $savePdfScript -Base64Pdf $response.pdfBase64 -ReportName $ReportName -ReportId $ReportId

        Write-Host "`nPDF saved for review: $savedPath" -ForegroundColor Green
        return @{
            Success = $true
            PdfPath = $savedPath
            Duration = $response.durationMs
            Size = $response.pdfSizeBytes
        }
    }
    else {
        Write-Host "Report generation failed!" -ForegroundColor Red
        Write-Host "Error: $($response.error)" -ForegroundColor Red
        return @{
            Success = $false
            Error = $response.error
        }
    }
}
catch {
    Write-Host "Error calling web service: $_" -ForegroundColor Red
    return @{
        Success = $false
        Error = $_.Exception.Message
    }
}
