---
name: bc-test-runner
description: Execute automated tests for Business Central AL extensions. Use after apps are compiled and published to validate functionality. Supports OData API (online/SaaS), BCContainerHelper (local/Docker), and Chrome DevTools (fallback) test execution methods. Provides detailed test results with pass/fail counts and error messages.
license: MIT
compatibility: Requires @volt-technologies/bc-tools. OData method needs BC Test app with TestRunner web service. Local method needs BCContainerHelper PowerShell module.
metadata:
  author: volt-technologies
  version: "1.0.0"
allowed-tools: Bash(node:*) Bash(npx:*) Bash(volt-bc:*) Bash(pwsh:*) Bash(powershell:*) Read
---

# BC Test Runner Skill

Execute automated tests for Business Central AL extensions using `@volt-technologies/bc-tools`.

## Prerequisites

1. **Apps published**: BC and BC Test apps must be compiled and published
2. **Test Runner setup** (for OData method):
   - `VOL Test Runner WS` codeunit (78000) in BC Test app
   - `TestRunner` web service registered in BC
   - `TestVolt` permission set assigned to Azure AD app
3. **Configuration**: `.env` file with BC environment settings

## Quick Commands

### Run Tests by Codeunit ID
```bash
npx volt-bc dev test --codeunit 60000
```

### Run Tests by Range
```bash
npx volt-bc dev test --range "70200..70249"
```

### Run Tests by Extension
```bash
npx volt-bc dev test --extension "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

### List Available Test Codeunits
```bash
npx volt-bc dev test --list
```

## Test Execution Methods

The skill automatically selects the appropriate method based on `BC_DEPLOYMENT_TYPE`:

### Method 1: OData API (Online/SaaS) - Recommended

**When to use**: `BC_DEPLOYMENT_TYPE=online`

```bash
# Using the unified executor
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-test-executor.ps1" -TestCodeunitId 60000

# Or using the OData script directly
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-run-tests-odata.ps1" -TestCodeunitId 60000
```

**Available Actions**:
- `Ping` - Health check
- `List` - List test codeunits
- `RunTestCodeunit` - Run specific codeunit
- `RunExtension` - Run all tests for an extension

### Method 2: BCContainerHelper (Local/Docker)

**When to use**: `BC_DEPLOYMENT_TYPE=local`

```bash
pwsh -ExecutionPolicy Bypass -File ".claude/scripts/bc-run-tests.ps1" \
  -TestCodeunitIdRange "70200..70249" \
  -ContainerName "bc-feature" \
  -CompanyName "CRONUS International Ltd."
```

### Method 3: Chrome DevTools (Fallback)

**When to use**: OData or BCContainerHelper unavailable

Navigate to AL Test Tool URL:
```
https://businesscentral.dynamics.com/{TENANT_ID}/{ENVIRONMENT}?company={COMPANY}&page=130451
```

## Configuration

### Required `.env` Settings

```env
BC_DEPLOYMENT_TYPE=online    # or 'local'
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=Sandbox
BC_COMPANY_NAME=CRONUS USA, Inc.
```

### Online/SaaS Authentication
```env
BC_TENANT_ID=your-tenant-guid
BC_CLIENT_ID=your-app-client-id
BC_CLIENT_SECRET=your-app-client-secret
```

### Local/Docker Settings
```env
CURRENT_FEATURE_CONTAINER=bc-container-name
BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=your-password
```

## Test Results Format

### JSON Output (OData)

```json
{
  "suite": "SINGLE",
  "timestamp": "2025-12-12T00:08:25.584Z",
  "totalTests": 9,
  "passed": 9,
  "failed": 0,
  "success": true,
  "codeunits": [
    {
      "codeunitId": 60000,
      "codeunitName": "VOL Tests",
      "result": "Success",
      "tests": [
        {
          "method": "TestCreateRecord",
          "result": "Success"
        }
      ]
    }
  ]
}
```

### Result Values
- `Success` - Test passed
- `Failure` - Test failed with assertion or error
- `Skipped` - Test was skipped
- `NotExecuted` - Test was not run

## RDLC Report Testing

For testing RDLC reports, use the specialized scripts:

### Auto-Test with Posted Invoice
```powershell
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-test-report-rdlc-auto.ps1"
```

### Test Any Report
```powershell
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-test-report-rdlc-api.ps1"
```

See [references/RDLC_TESTING.md](references/RDLC_TESTING.md) for detailed RDLC testing guidance.

## Safety Protocols

**CRITICAL**: Never run tests in Production environments.

### Environment Verification
Before executing tests:
1. Verify environment name is NOT "Production", "Prod", "Live"
2. Check for "Test", "Sandbox", "Dev" in environment name
3. If uncertain, STOP and request confirmation

### Acceptable Environments
- Sandbox
- Development
- Testing
- UAT

## Troubleshooting

### OData Errors
- **403 Forbidden**: Assign `TestVolt` permission set to Azure AD app
- **404 Not Found**: Register `TestRunner` web service in BC
- **401 Unauthorized**: Check Azure AD credentials
- **500 Error**: Check BC event log, verify test codeunit exists

### BCContainerHelper Errors
- **Container not found**: Check `docker ps -a`
- **Module not loaded**: Run `Import-Module BCContainerHelper`

See [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) for more.

## Programmatic Usage

```typescript
import { TestRunner, EnvLoader } from '@volt-technologies/bc-tools';

const config = new EnvLoader().load();

const runner = new TestRunner({
  environment: config.deploymentType,
  containerName: config.containerName,
  tenantId: config.tenantId,
  clientId: config.clientId,
  clientSecret: config.clientSecret,
  environmentName: config.environmentName,
  companyName: config.companyName,
});

// List test codeunits
const codeunits = await runner.listTestCodeunits();

// Run specific codeunit
const result = await runner.run({
  testCodeunitId: 60000,
});

if (result.success) {
  console.log(`Passed: ${result.passedTests}/${result.totalTests}`);
} else {
  console.error(`Failed: ${result.failedTests} tests`);
  for (const r of result.results.filter(t => !t.success)) {
    console.error(`  ${r.codeunitName}::${r.methodName}: ${r.errorMessage}`);
  }
}
```

## Workflow Integration

After successful compilation and publishing (bc-compiler skill):

1. **Run tests**: `npx volt-bc dev test --codeunit <id>`
2. **Check results**: All tests must pass
3. **If failures**: Fix code, recompile, republish, retest
4. **If success**: Feature is validated
