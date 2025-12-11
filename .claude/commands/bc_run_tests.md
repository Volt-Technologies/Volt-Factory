# Business Central Test Execution Command

Execute AL tests in Business Central using BCContainerHelper PowerShell module (for Docker) or Chrome DevTools (for SaaS).

## Usage

```bash
# Run tests in default container with test range
/bc_run_tests 70200..70249

# Run tests in specific container
/bc_run_tests 70200..70249 bc-product-attributes

# Run tests with specific company name
/bc_run_tests 70200..70249 bc-product-attributes "CRONUS International Ltd."
```

## Parameters

1. **Test Range** (required): Format `StartId..EndId` (e.g., `70200..70249`)
2. **Container Name** (optional): Defaults to `CURRENT_FEATURE_CONTAINER` from .env
3. **Company Name** (optional): Defaults to `BC_COMPANY_NAME` from .env or "CRONUS International Ltd."

## What This Command Does

### For Docker/Local Deployments (Primary Method)
1. Uses **PowerShell Core (pwsh)** - required for BCContainerHelper compatibility
2. Checks if BCContainerHelper PowerShell module is installed
3. Installs BCContainerHelper if not present
4. Verifies the BC container is running
5. Executes tests using `Run-TestsInBcContainer`
6. Generates XUnit format test results in BCContainerHelper shared directory
7. Displays summary: Total, Passed, Failed, Skipped
8. Shows detailed failure information if any tests fail

**Note**: This command requires PowerShell Core 7+. Results are stored in `C:\ProgramData\BcContainerHelper\test-results\`

### Test Isolation and Multiple Runs

**Important**: BCContainerHelper runs each test codeunit **multiple times** (typically 2x). This is BCContainerHelper's default behavior and cannot be disabled.

**Impact**:
- Tests execute 2-3 times in sequence
- Test isolation mode is set to `130451` (Test Runner - Isol. Disabled)
- Data may persist between runs depending on test cleanup logic
- Results are automatically **deduplicated** - only unique tests are counted
- **Best result wins**: If a test passes in any run, it's reported as passed

**Why This Happens**:
BCContainerHelper's `Run-TestsInBcContainer` cmdlet internally runs tests multiple times for reliability. This is standard behavior in BC test automation.

**How We Handle It**:
1. The script parses all test runs from the XML results
2. Deduplicates tests by name
3. Takes the best result (Pass > Fail) for each unique test
4. Reports only unique test counts in the summary
5. Shows a note when multiple runs are detected

### For SaaS/Online Deployments (Fallback Method)
If BCContainerHelper fails or is unavailable:
1. Uses Chrome DevTools MCP to navigate to BC
2. Opens AL Test Tool page
3. Loads test codeunits by range
4. Executes tests via UI automation
5. Captures results with screenshots

## Output

- **Test Results**: `test-results/TestResults_[timestamp].xml` (XUnit format)
- **Exit Code**: 0 if all tests pass, 1 if any fail

## Examples

### Example 1: Run Product Attributes Tests
```bash
/bc_run_tests 70200..70249
```

Output:
```
Test Results:
  Total:   22
  Passed:  22
  Failed:  0
  Skipped: 0

✓ SUCCESS: All tests passed!
```

### Example 2: Run Tests in Custom Container
```bash
/bc_run_tests 70200..70249 my-bc-container
```

### Example 3: Run Tests with Custom Company
```bash
/bc_run_tests 70200..70249 bc-product-attributes "My Custom Company"
```

## Requirements

- **PowerShell Core 7+** (pwsh) - REQUIRED for BCContainerHelper
- **For Docker**: BCContainerHelper PowerShell module (auto-installed if missing)
- **For SaaS**: Chrome browser and DevTools MCP
- BC container must be running
- Test codeunits must be published to the environment

### Installing PowerShell Core
If `pwsh` is not available, install PowerShell Core:
```bash
winget install Microsoft.PowerShell
# or download from: https://aka.ms/powershell-release?tag=stable
```

## Configuration

The command reads from `.env` file:
- `CURRENT_FEATURE_CONTAINER`: Default container name
- `BC_COMPANY_NAME`: Default company name
- `BC_COMPANY_ID`: Company ID (converted to name if needed)
- `BC_DEPLOYMENT_TYPE`: "local" or "online"

## Troubleshooting

### Error: Container not found
```bash
# List available containers
docker ps -a

# Start the container
docker start <container-name>
```

### Error: BCContainerHelper not installed
The script will auto-install, or manually:
```powershell
Install-Module BCContainerHelper -Force
```

### Error: Test codeunits not found
Ensure test app is published:
```bash
/bc_publish_sandbox --app-path "BC Test/BC Test_1.0.0.1.app"
```

## Advanced Usage

Call the PowerShell script directly for more options:

```powershell
# Generate detailed report
powershell .claude/scripts/bc-run-tests.ps1 -TestCodeunitIdRange "70200..70249" -ReportType Detailed

# Custom output path
powershell .claude/scripts/bc-run-tests.ps1 -TestCodeunitIdRange "70200..70249" -OutputPath "my-test-results"

# Skip BCContainerHelper (use Chrome DevTools instead)
powershell .claude/scripts/bc-run-tests.ps1 -TestCodeunitIdRange "70200..70249" -SkipBCContainerHelper
```

## Benefits Over Chrome DevTools

- **Faster**: No UI rendering or browser overhead
- **Reliable**: No UI timing issues or element selection problems
- **CI/CD Ready**: Easy integration into automated pipelines
- **Structured Output**: XUnit format for test reporting tools
- **Detailed Logs**: Complete test execution logs
- **Batch Execution**: Run multiple test codeunits efficiently

## When to Use Chrome DevTools

- Testing in SaaS/Online BC environments
- BCContainerHelper installation issues
- Visual verification needed
- Interactive debugging required
- Container not accessible via PowerShell

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed or execution error

## Related Commands

- `/bc_compile` - Compile BC apps
- `/bc_publish_sandbox` - Publish to sandbox
- `/workflow_05_testing` - Full testing workflow

## Learn More

- [BCContainerHelper Documentation](https://freddysblog.com/2019/10/22/running-tests-in-containers-2/)
- [AL Test Framework](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-testing-application)
