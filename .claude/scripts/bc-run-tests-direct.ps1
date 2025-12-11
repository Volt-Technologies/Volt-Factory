# Run BC Tests Directly in Container
param(
    [string]$ContainerName = "bc-product-attributes",
    [string]$CompanyName = "CRONUS International Ltd.",
    [string]$TestCodeunitIdRange = "70200..70206"
)

Write-Host "=== Business Central Test Execution (Direct Method) ===" -ForegroundColor Cyan
Write-Host "Container: $ContainerName" -ForegroundColor White
Write-Host "Company: $CompanyName" -ForegroundColor White
Write-Host "Test Range: $TestCodeunitIdRange" -ForegroundColor White
Write-Host ""

# Check BCContainerHelper
if (-not (Get-Module -ListAvailable -Name BCContainerHelper)) {
    Write-Host "Installing BCContainerHelper..." -ForegroundColor Yellow
    Install-Module BCContainerHelper -Force -Scope CurrentUser
}

Import-Module BCContainerHelper -DisableNameChecking

# Parse range
$rangeParts = $TestCodeunitIdRange -split '\.\.'
$startId = [int]$rangeParts[0]
$endId = [int]$rangeParts[1]

# Create credential
$securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("admin", $securePassword)

# Results storage
$allResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    CodeunitResults = @()
}

Write-Host "Executing tests..." -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

# Test each codeunit
for ($codeunitId = $startId; $codeunitId -le $endId; $codeunitId++) {
    Write-Host "Testing codeunit $codeunitId..." -ForegroundColor Cyan

    try {
        # Create unique result file for this codeunit
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $resultFile = "C:\ProgramData\BcContainerHelper\test-results\Test_${codeunitId}_${timestamp}.xml"

        # Run test
        $testOutput = Run-TestsInBcContainer `
            -containerName $ContainerName `
            -companyName $CompanyName `
            -credential $credential `
            -testCodeunit $codeunitId `
            -XUnitResultFileName $resultFile `
            -detailed `
            -returnTrueIfAllPassed

        # Parse results if file exists
        if (Test-Path $resultFile) {
            [xml]$xmlResults = Get-Content $resultFile

            foreach ($suite in $xmlResults.assemblies.assembly) {
                $codeunitTotal = [int]$suite.total
                $codeunitFailed = [int]$suite.failed
                $codeunitPassed = $codeunitTotal - $codeunitFailed

                $allResults.TotalTests += $codeunitTotal
                $allResults.PassedTests += $codeunitPassed
                $allResults.FailedTests += $codeunitFailed

                $allResults.CodeunitResults += @{
                    CodeunitId = $codeunitId
                    CodeunitName = $suite.name
                    Total = $codeunitTotal
                    Passed = $codeunitPassed
                    Failed = $codeunitFailed
                    ResultFile = $resultFile
                }

                Write-Host "  ✓ Codeunit $codeunitId : $codeunitPassed/$codeunitTotal passed" -ForegroundColor $(if ($codeunitFailed -gt 0) { "Yellow" } else { "Green" })
            }
        }
        else {
            Write-Host "  - Codeunit $codeunitId : No tests found or not a test codeunit" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  X Codeunit $codeunitId : Error - $($_.Exception.Message)" -ForegroundColor Red
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "=== Test Execution Complete ===" -ForegroundColor Cyan
Write-Host "Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host ""
Write-Host "Results Summary:" -ForegroundColor Cyan
Write-Host "  Total Tests:   $($allResults.TotalTests)" -ForegroundColor White
Write-Host "  Passed:        $($allResults.PassedTests)" -ForegroundColor Green
Write-Host "  Failed:        $($allResults.FailedTests)" -ForegroundColor $(if ($allResults.FailedTests -gt 0) { "Red" } else { "White" })
Write-Host "  Pass Rate:     $('{0:P0}' -f ($allResults.PassedTests / $allResults.TotalTests))" -ForegroundColor White
Write-Host ""

# Show breakdown by codeunit
if ($allResults.CodeunitResults.Count -gt 0) {
    Write-Host "Breakdown by Test Codeunit:" -ForegroundColor Cyan
    foreach ($result in $allResults.CodeunitResults) {
        $status = if ($result.Failed -gt 0) { "FAIL" } else { "PASS" }
        $color = if ($result.Failed -gt 0) { "Red" } else { "Green" }
        Write-Host "  [$status] $($result.CodeunitName): $($result.Passed)/$($result.Total) passed" -ForegroundColor $color
    }
    Write-Host ""
}

# Show failures if any
if ($allResults.FailedTests -gt 0) {
    Write-Host "Failed Tests Details:" -ForegroundColor Red
    Write-Host ""

    foreach ($result in $allResults.CodeunitResults | Where-Object { $_.Failed -gt 0 }) {
        Write-Host "  Codeunit: $($result.CodeunitName)" -ForegroundColor Yellow

        if (Test-Path $result.ResultFile) {
            [xml]$xmlResults = Get-Content $result.ResultFile

            foreach ($suite in $xmlResults.assemblies.assembly) {
                foreach ($test in $suite.collection.test | Where-Object { $_.result -eq "Fail" }) {
                    Write-Host "    X $($test.name)" -ForegroundColor Red
                    if ($test.failure) {
                        Write-Host "      Error: $($test.failure.message)" -ForegroundColor Gray
                    }
                }
            }
        }
        Write-Host ""
    }
}

if ($allResults.FailedTests -gt 0) {
    Write-Host "RESULT: FAILED - $($allResults.FailedTests) test(s) failed" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "RESULT: SUCCESS - All tests passed!" -ForegroundColor Green
    exit 0
}
