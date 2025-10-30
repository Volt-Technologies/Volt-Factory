---
allowed-tools: Bash(*)
description: Publish BC app to production environment (PTE mode)
---

# Business Central Production Publishing Command

## Purpose
This command handles production deployments of Business Central apps. It includes safety validations, confirmation prompts, and guidance for proper production PTE deployment.

## ⚠ PRODUCTION DEPLOYMENT WARNING

This command is for **PRODUCTION ENVIRONMENTS** with **LIVE USERS AND DATA**.

Before using this command:
- ✓ App has been thoroughly tested in sandbox
- ✓ All dependencies are verified and available
- ✓ Database schema changes are backward compatible
- ✓ Deployment is scheduled during maintenance window
- ✓ Rollback plan is documented and ready
- ✓ Stakeholders have been notified

## Production Publishing Requirements

### 1. PTE Mode Only
Production deployments **MUST** use PTE (Per-Tenant Extension) mode:
- Dev mode is **blocked** for production
- Uses formal Automation API process
- Requires proper app validation
- May require app signing

### 2. Environment Configuration
Ensure `.env` is configured for production:
```bash
BC_DEPLOYMENT_TYPE=online  # Local production not automated
BC_ENVIRONMENT_TYPE=production
BC_ENVIRONMENT_NAME=<your-production-env-name>
BC_TENANT_ID=<your-tenant-id>
BC_CLIENT_ID=<your-client-id>
BC_CLIENT_SECRET=<your-client-secret>
```

### 3. App Signing (May Be Required)
Some production environments require code-signed apps:
- Obtain code signing certificate
- Sign .app file with certificate
- Verify signature before deployment

## Execution Steps

### 1. Pre-Deployment Validation
Before running the command:
- Verify app is compiled with production version
- Test thoroughly in sandbox environment first
- Review all breaking changes and migration needs
- Backup production environment (if possible)
- Schedule deployment window with stakeholders

### 2. Run Production Publishing Script
Execute: `bash scripts/bc-publish-production-pte.sh`

The script will:
- Load configuration from `.env`
- Validate environment type is "production"
- Display app details and target environment
- **Require explicit confirmation** (type "DEPLOY")
- Provide deployment guidance

### 3. Manual Deployment Steps
Due to production security requirements, full automated PTE deployment via API requires:
- Code signing certificate
- Admin Center API access
- Multi-step approval process

**RECOMMENDED PRODUCTION DEPLOYMENT APPROACH:**

1. **Compile app** with production version:
   ```bash
   bc_compile
   ```

2. **Test in sandbox** with PTE mode:
   ```bash
   bc_publish_sandbox_pte
   ```

3. **Upload to production** via BC Admin Center:
   - Open Business Central Admin Center
   - Navigate to Environments → Production
   - Go to Apps section
   - Click "Upload Extension"
   - Select your compiled .app file
   - Review and confirm installation

4. **Monitor deployment**:
   - Watch installation progress in Admin Center
   - Check for errors or warnings
   - Verify app appears in Extension Management

5. **Post-deployment validation**:
   - Test critical functionality
   - Verify data integrity
   - Monitor for errors
   - Use `bc_verify` to check installation

### 4. Handle Results
The script provides:
- Pre-deployment checklist
- Confirmation prompt (safety)
- Deployment guidance
- Admin Center instructions
- Path to compiled .app file

## Configuration

### Production Environment Setup
```bash
# .env configuration for production
BC_DEPLOYMENT_TYPE=online
BC_ENVIRONMENT_TYPE=production
BC_TENANT_ID=<production-tenant-id>
BC_CLIENT_ID=<production-app-client-id>
BC_CLIENT_SECRET=<production-app-secret>
BC_ENVIRONMENT_NAME=Production  # Or your production env name
BC_COMPANY_ID=<production-company-id>
```

### Security Best Practices
1. **Separate credentials** for production
2. **Different Azure AD app** for production deployments
3. **Restricted access** to production .env
4. **Audit logging** enabled
5. **Change approval** process in place

## Common Scenarios

### Scenario 1: Standard Production Deployment
User: "Deploy app to production"
1. Run comprehensive pre-deployment checks
2. Execute: `bash scripts/bc-publish-production-pte.sh`
3. Review deployment checklist
4. Type "DEPLOY" to confirm
5. Follow manual deployment instructions
6. Upload via Admin Center
7. Monitor installation
8. Verify with `bc_verify`

### Scenario 2: Production Hotfix
User: "Deploy urgent hotfix to production"
1. Verify hotfix is tested in sandbox
2. Update version in app.json
3. Compile: `bc_compile`
4. Run production script for validation
5. Upload via Admin Center (expedited)
6. Monitor closely
7. Prepare rollback if needed

### Scenario 3: Scheduled Release
User: "Deploy scheduled release to production"
1. Coordinate with maintenance window
2. Notify users of deployment
3. Run production publishing script
4. Confirm all validations pass
5. Upload during maintenance window
6. Complete post-deployment testing
7. Notify users of completion

## Safety Features

### Confirmation Requirement
- Must type "DEPLOY" explicitly
- Cannot bypass with flags (by design)
- Forces manual review of deployment details
- Prevents accidental production deployments

### Environment Validation
- Blocks dev mode for production
- Requires BC_ENVIRONMENT_TYPE=production
- Validates online deployment only
- Checks app file exists and is valid

### Pre-Deployment Checklist
The script displays critical reminders:
- Test coverage verification
- Dependency availability
- Schema compatibility
- Maintenance window scheduling
- Rollback plan readiness

## Production Deployment via Admin Center

### Step-by-Step Guide

1. **Access Admin Center**:
   - Go to https://businesscentral.dynamics.com/admin
   - Sign in with admin credentials

2. **Navigate to Environment**:
   - Select "Environments"
   - Choose your production environment

3. **Upload Extension**:
   - Click "Apps" or "Extensions"
   - Click "Upload Extension" button
   - Browse to your .app file
   - Click "Upload"

4. **Configure Installation**:
   - Review extension details
   - Select installation options:
     - Install dependencies: Yes (recommended)
     - Sync mode: Add (safe for production)
   - Set installation schedule (immediate or scheduled)

5. **Confirm and Monitor**:
   - Review summary
   - Click "Install"
   - Monitor installation progress
   - Wait for completion (may take 5-15 minutes)

6. **Verify Installation**:
   - Check extension appears in list
   - Status should be "Installed"
   - Version should match deployed version
   - Test critical functionality

## Error Handling

### Configuration Errors
- Verify BC_ENVIRONMENT_TYPE=production
- Check BC_DEPLOYMENT_TYPE=online
- Validate all credentials are production values

### Permission Errors
- Admin Center requires admin permissions
- Verify user has environment admin role
- Check Azure AD app has necessary permissions

### Upload Errors (Admin Center)
- Check app file is not corrupted
- Verify app.json is valid
- Ensure dependencies are available in production
- Check app signature if signing is required

### Installation Failures
- Review error messages in Admin Center
- Check schema sync mode compatibility
- Verify no conflicting extensions
- Check database state and locks

## Rollback Procedure

If deployment fails or issues arise:

1. **Immediate Issues**:
   - Uninstall extension via Admin Center
   - Previous version should resume
   - Monitor for data integrity

2. **Gradual Issues**:
   - Assess impact severity
   - Document issues
   - Plan rollback during maintenance window
   - Communicate with users

3. **Rollback Steps**:
   - Uninstall problematic version
   - Reinstall previous stable version
   - Verify functionality restored
   - Analyze failure for future prevention

## Notes
- **Production = Manual Process**: Automated API deployment requires additional setup
- **Test First**: Always test PTE deployment in sandbox first
- **Use Admin Center**: Recommended for production deployments
- **Safety First**: Confirmation prompts prevent accidents
- **Documentation**: Keep deployment records
- **Communication**: Notify stakeholders before and after deployment
- For automated CI/CD: Consider staged rollout with monitoring
