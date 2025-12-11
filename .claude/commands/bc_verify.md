---
allowed-tools: Bash(*)
description: Verify BC app installation status
---

# Business Central App Verification Command

## Purpose
This command verifies the installation status of Business Central apps by querying the BC Admin Center API (online) or Automation API (local). Useful for checking if an app was published successfully and viewing its current state.

## How It Works

### Verification Methods
- **Online/SaaS**: Uses Admin Center API to query app status
- **Local/Docker**: Uses Automation API or Extension Management data
- **Auto-detection**: Automatically finds app ID from app.json
- **List mode**: Can show all installed extensions with `--all` flag

### What Gets Verified
- App installation status
- Current version number
- App state (installed, failed, updating, etc.)
- Publisher information
- App ID confirmation

## Prerequisites

1. **Authentication configured** in `.env`:
   - **For online/SaaS**: BC_TENANT_ID, BC_CLIENT_ID, BC_CLIENT_SECRET
   - **For local/Docker**: BC_LOCAL_USERNAME, BC_LOCAL_PASSWORD, BC_LOCAL_SERVER_URL
2. **App ID** (auto-detected from app.json or specify with --app-id)
3. **API Permissions** (online): Admin Center API access

## Execution Steps

### 1. Run Verification Script
Execute: `bash .claude/scripts/bc-verify-app.sh`

The script will:
- Load configuration from `.env`
- Auto-detect app ID from local app.json (if not specified)
- Authenticate using configured method
- Query the BC environment for app status
- Display app installation details

### 2. Review Results
The output shows:
- App display name
- Current version
- Installation state
- Publisher
- App ID
- Full API response for details

## Common Scenarios

### Scenario 1: Verify After Publishing
User: "Check if my app was published successfully"
1. Run: `bash .claude/scripts/bc-verify-app.sh`
2. Script auto-detects app ID from local app.json
3. Queries BC environment
4. Shows installation status

### Scenario 2: Check Specific App
User: "Check status of app with ID xyz"
1. Run: `bash .claude/scripts/bc-verify-app.sh --app-id "xyz-guid"`
2. Queries for specific app
3. Shows detailed status

### Scenario 3: List All Apps
User: "Show me all installed extensions"
1. Run: `bash .claude/scripts/bc-verify-app.sh --all`
2. Lists all extensions in environment
3. Shows name and basic info for each

### Scenario 4: Check Different Environment
User: "Verify app in production environment"
1. Run: `bash .claude/scripts/bc-verify-app.sh --environment "Production"`
2. Queries production environment
3. Shows app status in production

### Scenario 5: Monitor PTE Installation
User: "Check if PTE installation completed"
1. Publish with PTE mode: `bc_publish_sandbox_pte`
2. Wait a few minutes
3. Run: `bash .claude/scripts/bc-verify-app.sh`
4. Check if state is "Installed"
5. Repeat if still "Installing" or "Pending"

## Configuration

### Online/SaaS Verification
Ensure `.env` has:
```bash
BC_DEPLOYMENT_TYPE=online
BC_TENANT_ID=<your-tenant-id>
BC_CLIENT_ID=<your-client-id>
BC_CLIENT_SECRET=<your-client-secret>
BC_ENVIRONMENT_NAME=<your-environment-name>
```

### Local/Docker Verification
Ensure `.env` has:
```bash
BC_DEPLOYMENT_TYPE=local
BC_LOCAL_USERNAME=<your-username>
BC_LOCAL_PASSWORD=<your-password>
BC_LOCAL_SERVER_URL=http://localhost:7048
BC_ENVIRONMENT_NAME=<your-instance-name>
```

## Command Options

Available flags:
- `--app-id GUID`: Specify app ID to verify (auto-detected if not provided)
- `--environment NAME`: Override environment name from .env
- `--all`: Show all installed extensions instead of specific app
- `--help`: Show help message

## App Installation States

Common states you may see:

### Installed
- ✓ App is successfully installed and active
- Ready for use
- This is the desired state

### Installing
- ⏳ Installation in progress
- Wait a few minutes and check again
- Common with PTE mode deployments

### Pending
- ⏳ Installation queued but not started
- May take time to begin
- System is processing the request

### Failed
- ✗ Installation encountered an error
- Check Admin Center for error details
- Review app dependencies and compatibility

### Uninstalling
- ⏳ App is being removed
- Part of update or removal process
- Wait for completion

## Error Handling

### App Not Found (404)
- App has not been published to this environment
- App ID is incorrect
- Installation may still be in progress
- Check with `--all` to see what's installed

**Solutions:**
- Publish the app first: `bc_publish_sandbox`
- Verify app ID in app.json matches
- Check environment name is correct
- Wait if PTE installation was just initiated

### Authentication Errors
- Verify credentials in `.env`
- For OAuth: Check tenant ID, client ID, and secret
- For Basic: Check username and password
- Test with: `bash .claude/scripts/bc-auth.sh test`

### Permission Errors
- Admin Center API requires specific permissions
- Verify Azure AD app has admin permissions
- For online: May need `Application.ReadWrite.All` or similar
- Check with BC admin if access is restricted

### API Errors
- Check environment name is correct
- Verify BC server is running (local)
- Check network connectivity
- Review API response for specific error message

## Understanding the Output

### Successful Verification
```
✓ Query Successful
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App Details:

Name:        MyApp
Version:     1.0.0.0
State:       Installed
Publisher:   My Company
App ID:      fff9ead6-096d-4948-8662-1990771aaed3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### App Not Found
```
⚠ App Not Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App ID: fff9ead6-096d-4948-8662-1990771aaed3
Environment: Sandbox

The specified app is not installed in this environment.

Try:
  - Publish the app: bc_publish_sandbox
  - Check all apps: bash .claude/scripts/bc-verify-app.sh --all
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Integration with Publishing Workflow

### Typical Workflow
1. **Compile**: `bc_compile`
2. **Publish**: `bc_publish_sandbox`
3. **Verify**: `bash .claude/scripts/bc-verify-app.sh`
4. **Confirm**: Check state is "Installed"

### PTE Workflow
1. **Compile**: `bc_compile`
2. **Publish**: `bc_publish_sandbox_pte`
3. **Wait**: PTE installation takes time
4. **Verify**: `bash .claude/scripts/bc-verify-app.sh`
5. **Monitor**: Repeat until state is "Installed"

### Troubleshooting Workflow
1. **Publish fails**: Review error message
2. **Installation stalls**: Use verify to check state
3. **App missing**: Verify with `--all` flag
4. **Wrong version**: Check version number in output

## Notes
- Verification uses read-only API calls (safe to run anytime)
- Auto-detection works when single app.json is present
- Multiple apps require specifying --app-id
- PTE installations are asynchronous (may take minutes)
- Check regularly after PTE deployment to monitor progress
- Admin Center web portal shows same information visually
- Useful for CI/CD pipelines to confirm deployment success
