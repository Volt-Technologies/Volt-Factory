---
allowed-tools: Bash(*)
description: Publish BC app to sandbox using PTE mode
---

# Business Central Sandbox PTE Publishing Command

## Purpose
This command publishes Business Central apps to a sandbox environment using PTE (Per-Tenant Extension) mode via the Automation API. This allows you to test the production deployment process in a safe sandbox environment.

## PTE Mode vs Dev Mode

### PTE (Per-Tenant Extension) Mode
- Uses Automation API for installation
- Multi-step process: upload → install
- Mirrors production deployment workflow
- Good for testing deployment procedures
- Requires company ID for full functionality
- More formal with validation steps

### Dev Mode (Comparison)
- Uses `/dev/apps` endpoint
- Single-step publish and sync
- Faster for rapid iteration
- Same as VS Code F5 debugging
- See `bc_publish_sandbox` for dev mode

## When to Use PTE Mode in Sandbox

Use this command when you want to:
- Test the production deployment process
- Validate PTE installation procedures
- Test extension upgrade scenarios
- Practice pre-production workflows
- Verify Automation API permissions

For regular development iteration, use `bc_publish_sandbox` (dev mode) instead.

## Prerequisites

1. **Compiled App**: Run `bc_compile` first if needed
2. **Authentication configured** in `.env`:
   - **For online/SaaS**: BC_TENANT_ID, BC_CLIENT_ID, BC_CLIENT_SECRET
   - **For local/Docker**: BC_LOCAL_USERNAME, BC_LOCAL_PASSWORD, BC_LOCAL_SERVER_URL
3. **Company ID**: Set BC_COMPANY_ID in `.env` (recommended for PTE)
4. **API Permissions** (online only):
   - Azure AD app needs `Automation.ReadWrite.All` permission
   - Admin consent must be granted

## Execution Steps

The PTE publishing workflow is a **complete 4-step automated process** that handles upload, installation, and monitoring:

### Step 1: Create extensionUpload Resource
- Creates or reuses existing extensionUpload resource in BC
- **Auto-fetches company ID** from BC API if not configured in `.env`
- Updates resource with deployment settings (schedule, schema sync mode)
- Smart resource reuse prevents duplicate records

### Step 2: Upload Extension Content
- Uploads .app file as binary stream to `/extensionContent` property
- Uses proper HTTP multipart/form-data with CRLF line endings
- Validates successful upload before proceeding
- Handles binary file upload with `application/octet-stream`

### Step 3: Trigger Installation
- Calls `Microsoft.NAV.upload` bound action
- Queues extension for asynchronous installation
- Returns immediately (installation happens in background)
- Proper Content-Length header for OData compliance

### Step 4: Monitor Deployment Status ⭐ NEW
- **Automatic real-time monitoring** via extensionDeploymentStatus API
- Polls every 10 seconds for up to 5 minutes (30 attempts)
- Detects installation status: `InProgress`, `Completed`, `Failed`, `Scheduled`
- Shows progress updates during installation
- Provides detailed failure information if installation fails
- Confirms successful installation before completing

### Complete Workflow Execution

Simply run:
```bash
bash scripts/bc-publish-sandbox-pte.sh
```

The script automatically:
1. ✓ Validates prerequisites and configuration
2. ✓ Auto-fetches company ID if not in `.env`
3. ✓ Executes all 4 steps sequentially
4. ✓ Monitors installation until complete
5. ✓ Reports final status with full details

### Expected Output

**Successful Installation:**
```
=== Business Central Sandbox PTE Publishing ===

Step 1: Getting or creating extensionUpload resource...
✓ Auto-fetched Company ID: xxx (CompanyName)
✓ Created extensionUpload resource

Step 2: Uploading extension content...
✓ Extension content uploaded successfully

Step 3: Triggering installation...
✓ Upload triggered successfully

Step 4: Monitoring installation status...
Polling deployment status (checking every 10 seconds)...
[1] Status: InProgress
[2] Status: InProgress
...
[12] Status: Completed

✓ SUCCESS: Extension installed successfully (PTE mode)
App:          BC
Version:      1.0.0.0
Environment:  Apparel
Status:       Installed and Ready

The extension is now available in Business Central!
```

**Failed Installation:**
```
Step 4: Monitoring installation status...
[1] Status: Failed

✗ FAILED: Extension installation failed
App:         BC
Version:     1.0.0.0
Status:      Failed

Deployment Status Response:
[Full API response with error details]

Common Issues:
  - App dependencies not met
  - Schema sync errors
  - App conflicts with existing extensions
  - Check BC Event Log for detailed error messages
```

**Timeout (Rare):**
```
⚠ TIMEOUT: Installation status check timed out
Last known status: InProgress

Next steps:
  - Check installation manually in BC Admin Center
  - Run bc_verify to check current installation status
  - Check BC Event Log for any errors
```

## Configuration

### Online/SaaS Deployment
Ensure `.env` has:
```bash
BC_DEPLOYMENT_TYPE=online
BC_ENVIRONMENT_TYPE=sandbox
BC_TENANT_ID=<your-tenant-id>
BC_CLIENT_ID=<your-client-id>
BC_CLIENT_SECRET=<your-client-secret>
BC_ENVIRONMENT_NAME=<your-sandbox-name>
BC_COMPANY_ID=<your-company-id>  # Required for PTE
```

### Azure AD App Permissions
Your Azure AD app registration needs:
1. Go to Azure Portal → App Registrations → Your App
2. API Permissions → Add Permission
3. Select "Dynamics 365 Business Central"
4. Choose "Application permissions"
5. Add `Automation.ReadWrite.All`
6. Click "Grant admin consent"

### Local/Docker Deployment
Ensure `.env` has:
```bash
BC_DEPLOYMENT_TYPE=local
BC_ENVIRONMENT_TYPE=sandbox
BC_LOCAL_USERNAME=<your-username>
BC_LOCAL_PASSWORD=<your-password>
BC_LOCAL_SERVER_URL=http://localhost:7048
BC_ENVIRONMENT_NAME=<your-instance-name>
BC_COMPANY_ID=<your-company-id>
```

## Common Scenarios

### Scenario 1: Test PTE Deployment Process
User: "Test PTE deployment in sandbox"
1. Ensure app is compiled
2. Verify BC_COMPANY_ID is set in .env
3. Run `bash scripts/bc-publish-sandbox-pte.sh`
4. Monitor installation progress
5. Verify with `bc_verify` command

### Scenario 2: PTE with Specific Company
User: "Deploy to specific company as PTE"
1. Get company ID from BC (Companies → API Setup)
2. Run `bash scripts/bc-publish-sandbox-pte.sh --company-id "GUID"`
3. Monitor installation

### Scenario 3: Test Extension Upgrade
User: "Test upgrading extension"
1. Publish initial version with PTE mode
2. Update app.json version
3. Recompile: `bc_compile`
4. Publish new version: `bash scripts/bc-publish-sandbox-pte.sh`
5. Verify upgrade process

## Advanced Options

The publishing script supports flags:
- `--app-path PATH`: Specify which .app file to publish
- `--environment NAME`: Override environment name from .env
- `--company-id GUID`: Specify company ID for installation
- `--no-install-dependencies`: Skip automatic dependency installation

## Error Handling

### API Permission Errors
- Verify Azure AD app has `Automation.ReadWrite.All` permission
- Ensure admin consent is granted
- Check app registration is not expired

### Company ID Errors
- Company ID required for most PTE operations
- Get from BC: Search "Companies" → open company → API Setup
- Set BC_COMPANY_ID in .env or use --company-id flag

### Authentication Errors
- Verify credentials in `.env`
- For OAuth: Check tenant ID, client ID, and secret
- For Basic: Check username and password
- Test with: `bash scripts/bc-auth.sh test`

### Upload Errors
- Check app.json is valid
- Verify app dependencies are available
- Ensure app is properly compiled
- For local: Verify BC server is running

### Installation Timeout
- PTE installation is asynchronous
- May take 5-10 minutes for large apps
- Check BC Admin Center for installation status
- Use `bc_verify` to check programmatically

## PTE vs Dev Mode Comparison

| Aspect | PTE Mode (this command) | Dev Mode (bc_publish_sandbox) |
|--------|------------------------|-------------------------------|
| **API** | Automation API | Dev Apps endpoint |
| **Process** | Upload → Install (async) | Publish → Sync (immediate) |
| **Speed** | Slower (minutes) | Faster (seconds) |
| **Use Case** | Test production process | Rapid development |
| **Company Scoped** | Yes (per company) | No (environment-wide) |
| **Mirrors Production** | Yes | No |

## Notes
- PTE mode mimics production deployment workflow
- Ideal for pre-production testing and validation
- Installation is asynchronous but automatically monitored
- Requires Automation API permissions (online)
- For faster development iteration, use `bc_publish_sandbox` instead
- Production PTE deployment: use `bc_publish_production`

## Technical Implementation
- **4-Step Workflow**: POST extensionUpload → PATCH extensionContent → POST Microsoft.NAV.upload → GET extensionDeploymentStatus
- **Auto-Company ID**: Queries `/api/v2.0/companies` endpoint if BC_COMPANY_ID not configured
- **Binary Upload**: Uses `application/octet-stream` with `--data-binary` for .app file upload
- **Status Polling**: Queries extensionDeploymentStatus every 10 seconds with 5-minute timeout
- **Resource Reuse**: Smart handling of existing extensionUpload records to prevent conflicts
- **CRLF Compliance**: Proper HTTP multipart/form-data formatting with CRLF line endings
- **Exit Codes**: 0 (success), 1 (failure), 2 (timeout) for CI/CD integration
