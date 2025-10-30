---
allowed-tools: Bash(*)
description: Publish BC app to sandbox environment (dev mode)
---

# Business Central Sandbox Publishing Command

## Purpose
This command publishes Business Central apps to a sandbox environment using Dev mode. This is the fastest way to publish during development and supports hot-reloading of schema changes.

## How It Works

### Dev Mode Publishing
- Uses the `/dev/apps` endpoint (same as VS Code F5 debugging)
- Supports hot-reloading and rapid iteration
- Can force-sync database schema changes
- **Only works for sandbox environments** (not production)
- Supports both online/SaaS and local/Docker deployments

### Prerequisites
1. App must be compiled first (run `bc_compile` if needed)
2. Authentication configured in `.env` file:
   - **For online/SaaS**: BC_TENANT_ID, BC_CLIENT_ID, BC_CLIENT_SECRET
   - **For local/Docker**: BC_LOCAL_USERNAME, BC_LOCAL_PASSWORD, BC_LOCAL_SERVER_URL
3. BC_ENVIRONMENT_TYPE must be set to "sandbox" in `.env`

## Execution Steps

### 1. Check if App is Compiled
Before publishing, verify the app is compiled:
- Look for .app files in the BC apps directory
- If no .app files found, run `bc_compile` first

### 2. Run the Publishing Script
Execute: `bash scripts/bc-publish-sandbox-dev.sh`

The script will:
- Load configuration from `.env`
- Validate environment type is sandbox
- Auto-detect the compiled .app file
- Authenticate using configured method (OAuth or Basic)
- Publish to the Dev endpoint
- Report success or failure with details

### 3. Handle Results
- **Success**: App is published and synchronized, ready to use
- **Failure**: Review error message and suggest fixes

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
```

### Local/Docker Deployment
Ensure `.env` has:
```bash
BC_DEPLOYMENT_TYPE=local
BC_ENVIRONMENT_TYPE=sandbox
BC_LOCAL_USERNAME=<your-username>
BC_LOCAL_PASSWORD=<your-password>
BC_LOCAL_SERVER_URL=http://localhost:7048
BC_ENVIRONMENT_NAME=<your-instance-name>
```

## Common Scenarios

### Scenario 1: Quick Publish (most common)
User: "Publish my app to sandbox"
1. Check if .app file exists
2. If not, run `bc_compile`
3. Run `bash scripts/bc-publish-sandbox-dev.sh`
4. Report results

### Scenario 2: Publish with Force Sync
User: "Publish with force sync"
1. Ensure app is compiled
2. Run `bash scripts/bc-publish-sandbox-dev.sh --force-sync`
3. Report results

### Scenario 3: Publish Specific App
User: "Publish the CustomerManagement app"
1. Find the specific .app file
2. Run `bash scripts/bc-publish-sandbox-dev.sh --app-path "path/to/app.app"`
3. Report results

### Scenario 4: Publish to Different Environment
User: "Publish to my dev sandbox"
1. Ensure app is compiled
2. Run `bash scripts/bc-publish-sandbox-dev.sh --environment "DevSandbox"`
3. Report results

## Advanced Options

The publishing script supports additional flags:
- `--app-path PATH`: Specify which .app file to publish
- `--environment NAME`: Override environment name from .env
- `--force-sync`: Use force sync mode (default)
- `--synchronize`: Use synchronize mode (safer, may fail if breaking changes)
- `--recreate`: Use recreate mode (drops and recreates tables)
- `--ignore-dependencies`: Skip dependency validation
- `--strict-dependencies`: Enforce strict dependency checks

## Error Handling

### Authentication Errors
- Verify credentials in `.env`
- For OAuth: Check tenant ID, client ID, and client secret
- For Basic: Check username and password
- Run `bash scripts/bc-auth.sh test` to test authentication

### Environment Errors
- Verify BC_ENVIRONMENT_TYPE=sandbox in `.env`
- Dev mode cannot be used for production environments
- Check environment name matches BC Admin Center (online) or instance name (local)

### App Not Found Errors
- Run `bc_compile` to compile the app first
- Check BC_APPS_ROOT path in `.env`
- Verify .app files exist in the app directories

### Publishing Errors
- Check app dependencies are satisfied
- Verify app.json configuration is valid
- For local: Ensure BC server is running and accessible
- Review detailed error message from API response

## Notes
- Dev mode is designed for rapid iteration during development
- Changes are synchronized immediately
- Same endpoint used by VS Code F5 debugging
- For production deployments, use `bc_publish_production` instead
- Multiple apps can be published by running the command multiple times
