# Business Central App Publishing Guide

This document provides comprehensive information about publishing Business Central AL extensions using the BC Claude Code Plugin.

## Table of Contents

- [Publishing Overview](#publishing-overview)
- [Dev Mode vs PTE Mode](#dev-mode-vs-pte-mode)
- [Publishing to Sandbox](#publishing-to-sandbox)
- [Publishing to Production](#publishing-to-production)
- [API Endpoints](#api-endpoints)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Publishing Overview

Business Central apps can be published using two distinct modes, each serving different purposes in the development and deployment lifecycle.

### Publishing Modes

| Mode | Purpose | Environment | Speed | Use Case |
|------|---------|-------------|-------|----------|
| **Dev Mode** | Rapid development | Sandbox only | Fast (seconds) | Active development |
| **PTE Mode** | Formal deployment | Sandbox & Production | Slower (minutes) | Pre-production & Production |

### Publishing Process Flow

```
Source Code (.al files)
    ↓
[Compilation] - Creates .app file
    ↓
[Publishing] - Deploys to BC environment
    ↓
[Verification] - Confirms installation
    ↓
App Available in BC
```

## Dev Mode vs PTE Mode

### Dev Mode Publishing

**Endpoint:** `/dev/apps`

**Characteristics:**
- Single-step publish and synchronize
- Immediate schema updates
- Force-sync capabilities
- Same endpoint as VS Code F5 debugging
- Environment-wide installation
- **Sandbox only** (blocked for production)

**When to Use:**
- Daily development work
- Quick iterations and testing
- Schema changes during development
- Debugging and troubleshooting
- CI/CD development pipelines

**How It Works:**
1. POST .app file to `/dev/apps` endpoint
2. Server validates app
3. Schema synchronized immediately
4. App installed and available instantly

**Supported Schema Modes:**
- `forcesync` - Force schema changes (default, recommended for dev)
- `synchronize` - Safe sync (may fail on breaking changes)
- `recreate` - Drop and recreate tables (data loss!)

**Example Command:**
```bash
bc_publish_sandbox
```

### PTE Mode Publishing

**Endpoint:** Automation API (`/api/microsoft/automation/v2.0/extensionUpload`)

**Characteristics:**
- Multi-step upload and install process
- Asynchronous installation
- Per-company targeting possible
- Formal validation and approval workflow
- **Works for sandbox and production**

**When to Use:**
- Testing production deployment process
- Staging environment deployments
- Production releases
- Extension upgrades
- Apps requiring formal approval

**How It Works:**
1. POST .app file to Automation API
2. Upload completes immediately
3. Installation queued in background
4. Installation executes asynchronously
5. May take 5-15 minutes to complete
6. Must verify installation status after

**Example Commands:**
```bash
# Sandbox PTE
bc_publish_sandbox_pte

# Production PTE
bc_publish_production
```

## Publishing to Sandbox

### Quick Development Publishing

For rapid development iteration, use dev mode:

```bash
# Compile and publish
bc_compile
bc_publish_sandbox
```

**Process:**
1. Compiles app(s) to .app files
2. Publishes to sandbox using dev endpoint
3. Schema synchronized automatically
4. Ready for testing immediately

### PTE Testing in Sandbox

To test production deployment process:

```bash
# Compile and publish with PTE
bc_compile
bc_publish_sandbox_pte

# Wait for installation
sleep 60

# Verify installation
bash scripts/bc-verify-app.sh
```

**Process:**
1. Compiles app(s)
2. Uploads via Automation API
3. Installation queued
4. Wait for async installation
5. Verify installation completed

### Sandbox Publishing Options

**Dev Mode Flags:**
```bash
bash scripts/bc-publish-sandbox-dev.sh [options]

Options:
  --app-path PATH          Specific .app file to publish
  --environment NAME       Target environment
  --force-sync             Force schema sync (default)
  --synchronize            Safe schema sync
  --recreate               Recreate tables (data loss!)
  --ignore-dependencies    Skip dependency checks
  --strict-dependencies    Enforce strict dependency validation
```

**PTE Mode Flags:**
```bash
bash scripts/bc-publish-sandbox-pte.sh [options]

Options:
  --app-path PATH          Specific .app file to publish
  --environment NAME       Target environment
  --company-id GUID        Target company for installation
  --no-install-dependencies  Skip automatic dependency installation
```

## Publishing to Production

### Production Publishing Requirements

1. **Environment Type:** Must be set to `production` in `.env`
2. **Deployment Mode:** PTE only (dev mode blocked)
3. **Testing:** Thoroughly tested in sandbox first
4. **Approval:** Confirmation required before deployment
5. **Method:** Manual upload via Admin Center (recommended)

### Production Publishing Process

**Step 1: Compile Production Version**
```bash
# Update version in app.json first
bc_compile
```

**Step 2: Run Production Validation**
```bash
bc_publish_production
```

This script:
- Validates production configuration
- Displays pre-deployment checklist
- Requires explicit confirmation (type "DEPLOY")
- Provides deployment instructions

**Step 3: Manual Deployment via Admin Center**

1. Go to https://businesscentral.dynamics.com/admin
2. Navigate to Environments → Production
3. Click Apps → Upload Extension
4. Select compiled .app file
5. Configure installation options:
   - Install dependencies: Yes
   - Sync mode: Add (safe)
6. Click Install
7. Monitor installation progress

**Step 4: Verify Deployment**
```bash
bash scripts/bc-verify-app.sh --environment "Production"
```

### Production Safety Features

**Confirmation Prompts:**
- Must explicitly type "DEPLOY"
- Cannot bypass with flags
- Forces review of deployment details

**Pre-Deployment Checklist:**
- ✓ App tested in sandbox
- ✓ Dependencies verified
- ✓ Schema changes backward compatible
- ✓ Maintenance window scheduled
- ✓ Rollback plan ready

**Validation:**
- Blocks dev mode for production
- Requires `BC_ENVIRONMENT_TYPE=production`
- Validates online deployment only

## API Endpoints

### OAuth Token Acquisition

**Endpoint:** `https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/token`

**Method:** POST

**Parameters:**
- `grant_type`: client_credentials
- `client_id`: Azure AD app client ID
- `client_secret`: Azure AD app client secret
- `scope`: https://api.businesscentral.dynamics.com/.default

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJh...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### Dev Mode Publishing Endpoint

**URL:** `https://api.businesscentral.dynamics.com/v2.0/{ENVIRONMENT_NAME}/dev/apps`

**For Local:** `{BC_LOCAL_SERVER_URL}/{ENVIRONMENT_NAME}/dev/apps`

**Method:** POST

**Query Parameters:**
- `tenant`: Tenant ID (online only)
- `SchemaUpdateMode`: forcesync | synchronize | recreate
- `DependencyPublishingOption`: default | ignore | strict

**Headers:**
- `Authorization`: Bearer {token} (online) or Basic {credentials} (local)
- `Content-Type`: multipart/form-data
- `Accept`: application/json

**Body:** Multipart form with .app file

**Success Response:** 200 OK

### PTE Publishing Endpoint (Automation API)

**URL (Online):** `https://api.businesscentral.dynamics.com/v2.0/{TENANT_ID}/{ENVIRONMENT_NAME}/api/microsoft/automation/v2.0/companies({COMPANY_ID})/extensionUpload`

**URL (Local):** `{BC_LOCAL_SERVER_URL}/{ENVIRONMENT_NAME}/api/microsoft/automation/v2.0/companies({COMPANY_ID})/extensionUpload`

**Method:** POST

**Headers:**
- `Authorization`: Bearer {token} (online) or Basic {credentials} (local)
- `Content-Type`: multipart/form-data
- `Accept`: application/json

**Body:** Multipart form with:
- `extension`: .app file
- `metadata`: JSON with installation options

**Success Response:** 200 OK (upload complete, installation queued)

### App Verification Endpoint (Admin Center API)

**URL:** `https://api.businesscentral.dynamics.com/admin/v2.25/applications/businesscentral/environments/{ENVIRONMENT_NAME}/apps/{APP_ID}`

**Method:** GET

**Headers:**
- `Authorization`: Bearer {token}
- `Accept`: application/json

**Response:**
```json
{
  "id": "app-guid",
  "displayName": "App Name",
  "version": "1.0.0.0",
  "state": "Installed",
  "publisher": "Publisher Name"
}
```

## Best Practices

### Development Phase

1. **Use Dev Mode for Development**
   - Fastest iteration speed
   - Immediate feedback
   - Same as VS Code F5 debugging

2. **Commit Before Publishing**
   - Always commit code before deploying
   - Makes rollback easier
   - Tracks changes properly

3. **Version Increments**
   - Update version for each deployment
   - Use semantic versioning
   - Track versions in git tags

4. **Test Regularly**
   - Publish and test frequently
   - Don't accumulate untested changes
   - Catch issues early

### Pre-Production Phase

1. **Test with PTE Mode in Sandbox**
   - Mimics production deployment
   - Tests Automation API
   - Validates installation process

2. **Test Upgrades**
   - Deploy multiple versions
   - Test upgrade path
   - Verify data migration

3. **Dependency Testing**
   - Test with all dependencies
   - Verify dependency versions
   - Check compatibility

4. **Performance Testing**
   - Test with production-like data
   - Check query performance
   - Monitor resource usage

### Production Phase

1. **Always Use Manual Deployment**
   - Admin Center provides safety
   - Visual confirmation
   - Better error messages

2. **Schedule Maintenance Windows**
   - Minimize user impact
   - Allow time for testing
   - Plan for rollback time

3. **Communicate**
   - Notify users before deployment
   - Provide estimated downtime
   - Send completion notification

4. **Monitor After Deployment**
   - Watch for errors
   - Check user reports
   - Monitor performance

5. **Document Everything**
   - Record deployment time
   - Document issues encountered
   - Track lessons learned

## Troubleshooting

### Authentication Errors

**Symptom:** "Authentication failed" or 401 Unauthorized

**Solutions:**
- Verify credentials in `.env`
- Check Azure AD app permissions
- Ensure app secret hasn't expired
- Test with: `bash scripts/bc-auth.sh test`

### App Not Found After Publishing

**Symptom:** Verification returns 404

**Possible Causes:**
- Installation still in progress (PTE mode)
- Wrong environment name
- App published to different environment
- App ID mismatch

**Solutions:**
- Wait and retry (PTE installations take time)
- Verify environment name in `.env`
- Check Admin Center manually
- Use `--all` flag to list all apps

### Schema Sync Errors

**Symptom:** "Schema synchronization failed"

**Causes:**
- Breaking database changes
- Dependencies not met
- Data conflicts

**Solutions:**
- Use `--force-sync` for dev environments
- Fix dependency issues
- Review schema changes for compatibility
- Use `--recreate` only if data loss acceptable

### Dependency Errors

**Symptom:** "Dependency not found" or validation errors

**Solutions:**
- Ensure dependencies in `.alpackages` folder
- Check dependency versions match requirements
- Use `--ignore-dependencies` only for testing
- Verify dependencies installed in target environment

### PTE Installation Timeout

**Symptom:** Installation stays in "Installing" state

**Solutions:**
- Wait longer (can take 10-15 minutes)
- Check Admin Center for detailed status
- Look for error messages in Admin Center
- Verify dependencies are available
- Check app signing if required

### Production Deployment Blocked

**Symptom:** "Dev mode not allowed for production"

**This is intentional!**

Dev mode is blocked for production environments for safety.

**Solution:**
- Use PTE mode only for production
- Follow manual deployment process
- Upload via Admin Center

### Company ID Required Error

**Symptom:** "Company ID is required" from Automation API

**Solution:**
- Set `BC_COMPANY_ID` in `.env`
- Or use `--company-id` flag
- Get company ID from BC (Companies → API Setup)

## Common Publishing Scenarios

### Scenario 1: Daily Development
```bash
# Make changes, then:
bc_compile && bc_publish_sandbox
```

### Scenario 2: Pre-Production Testing
```bash
bc_compile
bc_publish_sandbox_pte
# Wait for installation
bash scripts/bc-verify-app.sh
```

### Scenario 3: Production Release
```bash
# 1. Update version in app.json
# 2. Compile
bc_compile
# 3. Validate
bc_publish_production
# 4. Upload manually via Admin Center
# 5. Verify
bash scripts/bc-verify-app.sh --environment "Production"
```

### Scenario 4: Multiple Apps
```bash
# Compile all apps
bc_compile

# Publish each app
for app in BC/*/app.json; do
    app_dir=$(dirname "$app")
    app_file=$(find "$app_dir" -name "*.app")
    bash scripts/bc-publish-sandbox-dev.sh --app-path "$app_file"
done
```

### Scenario 5: Hotfix Deployment
```bash
# 1. Fix code
# 2. Update version (hotfix increment)
# 3. Compile
bc_compile
# 4. Test in sandbox first!
bc_publish_sandbox
# 5. If OK, deploy to production
bc_publish_production
# 6. Manual upload via Admin Center
# 7. Monitor closely
```

## Resources

- [Business Central Developer Docs](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/)
- [AL Language Extension](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al)
- [Business Central Admin Center](https://businesscentral.dynamics.com/admin)
- [Azure AD App Registration](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)

---

For environment configuration, see [ENVIRONMENTS.md](ENVIRONMENTS.md)

For authentication setup, see [AUTHENTICATION.md](AUTHENTICATION.md)
