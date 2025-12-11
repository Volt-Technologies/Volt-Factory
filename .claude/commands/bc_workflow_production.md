---
allowed-tools: Bash(*)
description: Complete production workflow (compile + validate + guide deployment)
---

# Business Central Production Workflow Command

## Purpose
This command manages the complete production deployment workflow with safety checks, validation, and deployment guidance. Production deployments require extra care and follow a controlled process.

## ⚠ PRODUCTION DEPLOYMENT WORKFLOW

This workflow is for **PRODUCTION ENVIRONMENTS** with **LIVE USERS**.

## Workflow Overview

The production workflow includes:

1. **Pre-Deployment Validation**
2. **Compilation** (with production version)
3. **Production Script Execution** (validation + confirmation)
4. **Manual Deployment** (via Admin Center)
5. **Post-Deployment Verification**

## Complete Production Deployment Process

### Phase 1: Pre-Deployment (Do First)

**Before running any commands:**

1. ✓ **Test in Sandbox**
   - Deploy to sandbox with PTE mode
   - Run complete test suite
   - Verify all functionality
   - Test with production-like data

2. ✓ **Review Changes**
   - Document all changes
   - Identify breaking changes
   - Plan data migration (if needed)
   - Review schema modifications

3. ✓ **Prepare Rollback Plan**
   - Document rollback steps
   - Backup production (if possible)
   - Identify rollback timing
   - Prepare previous version

4. ✓ **Schedule Deployment**
   - Choose maintenance window
   - Notify stakeholders
   - Notify users
   - Allocate deployment time

5. ✓ **Update Configuration**
   - Ensure `.env` configured for production
   - Verify production credentials
   - Test authentication
   - Confirm environment name

### Phase 2: Compilation

**Update version and compile:**

1. **Update app.json**:
   - Increment version number
   - Update release notes
   - Verify app ID is correct

2. **Run Compilation**:
   ```bash
   bc_compile
   ```

3. **Verify Compilation**:
   - Check compiled .app file exists
   - Verify version in filename
   - Note file size and location

**Example:**
```
✓ BC_1.0.1.0.app compiled successfully
Location: BC/BC_1.0.1.0.app
```

### Phase 3: Production Validation

**Run production publishing script for validation:**

```bash
bc_publish_production
```

The script will:
- Load production configuration
- Validate environment type
- Display app details
- Show pre-deployment checklist
- Request confirmation (must type "DEPLOY")
- Provide deployment instructions

**Do NOT skip the confirmation prompt!**

### Phase 4: Manual Deployment

**Upload via BC Admin Center:**

1. **Access Admin Center**:
   - Go to https://businesscentral.dynamics.com/admin
   - Sign in with admin account

2. **Navigate to Production**:
   - Select "Environments"
   - Choose production environment
   - Go to "Apps" section

3. **Upload Extension**:
   - Click "Upload Extension"
   - Browse to compiled .app file
   - Select file
   - Click "Upload"

4. **Configure Installation**:
   - Review extension details
   - Set: Install dependencies = Yes
   - Set: Sync mode = Add (safe)
   - Schedule: Immediate or scheduled
   - Click "Install"

5. **Monitor Installation**:
   - Watch progress bar
   - Wait for completion (5-15 minutes)
   - Check for errors or warnings

### Phase 5: Post-Deployment Verification

**Verify successful deployment:**

1. **Check Installation Status**:
   ```bash
   bash .claude/scripts/bc-verify-app.sh --environment "Production"
   ```

2. **Verify Details**:
   - State should be "Installed"
   - Version should match deployed version
   - No error messages

3. **Functional Testing**:
   - Test critical user workflows
   - Verify data integrity
   - Check integration points
   - Monitor for errors

4. **Monitor System**:
   - Watch for user reports
   - Check error logs
   - Monitor performance
   - Be ready for rollback if needed

### Phase 6: Post-Deployment Activities

**After successful deployment:**

1. **Notify Stakeholders**:
   - Deployment completed successfully
   - New version number
   - Summary of changes
   - Known issues (if any)

2. **Update Documentation**:
   - Record deployment date/time
   - Document any issues encountered
   - Update version tracking
   - Note lessons learned

3. **Clean Up**:
   - Archive deployment artifacts
   - Update issue tracker
   - Close deployment ticket

## Configuration

### Production .env Settings

```bash
# Compilation
BC_APPS_ROOT=BC

# Production deployment
BC_DEPLOYMENT_TYPE=online
BC_ENVIRONMENT_TYPE=production

# Production environment
BC_ENVIRONMENT_NAME=Production  # Your production env name

# Production OAuth (separate from sandbox)
BC_TENANT_ID=<production-tenant-id>
BC_CLIENT_ID=<production-client-id>
BC_CLIENT_SECRET=<production-secret>

# Production company
BC_COMPANY_ID=<production-company-id>
```

### Security Best Practices

1. **Separate Credentials**:
   - Use different Azure AD app for production
   - Restrict access to production secrets
   - Rotate secrets regularly

2. **Access Control**:
   - Limit who can deploy to production
   - Require approval process
   - Audit all production deployments

3. **Configuration Management**:
   - Keep production .env secure
   - Never commit production secrets
   - Use environment-specific configs

## Scheduled Release Workflow

### Week Before Release

- [ ] Finalize features in sandbox
- [ ] Complete testing
- [ ] Update version numbers
- [ ] Prepare release notes
- [ ] Schedule deployment window

### Day Before Release

- [ ] Final sandbox testing
- [ ] Notify users of upcoming deployment
- [ ] Confirm maintenance window
- [ ] Review rollback plan
- [ ] Verify production .env configuration

### Deployment Day

- [ ] Start maintenance window
- [ ] Compile production version
- [ ] Run production validation script
- [ ] Upload to Admin Center
- [ ] Monitor installation
- [ ] Verify deployment
- [ ] Test critical functionality
- [ ] End maintenance window
- [ ] Notify users of completion

### After Release

- [ ] Monitor for issues (24-48 hours)
- [ ] Collect user feedback
- [ ] Document lessons learned
- [ ] Plan next release

## Hotfix Workflow

For urgent production fixes:

1. **Assess Urgency**:
   - Is it truly urgent?
   - Can it wait for scheduled release?
   - What's the risk of waiting?

2. **Quick Validation**:
   - Test fix in sandbox
   - Verify fix resolves issue
   - Check for side effects

3. **Expedited Deployment**:
   - Update version (hotfix increment)
   - Compile
   - Deploy immediately
   - Monitor closely

4. **Follow-Up**:
   - Document hotfix
   - Plan proper fix for next release
   - Review what caused the issue

## Error Handling

### Compilation Fails
- **Stop immediately**
- Fix compilation errors
- Do NOT proceed to production
- Retest in sandbox

### Validation Fails
- **Review error carefully**
- Check configuration
- Verify environment settings
- Do NOT bypass validation

### Installation Fails (Admin Center)
- **Stop deployment**
- Review error messages
- Assess impact
- Execute rollback if necessary
- Investigate root cause

### Post-Deployment Issues
- **Assess severity**
- Minor: Monitor and plan fix
- Major: Execute rollback immediately
- Document issue for analysis

## Rollback Procedure

If major issues arise:

1. **Decide to Rollback**:
   - Severity assessment
   - User impact
   - Data integrity

2. **Execute Rollback**:
   - Admin Center → Apps
   - Uninstall problematic version
   - Reinstall previous version
   - Verify functionality restored

3. **Post-Rollback**:
   - Notify users
   - Investigate failure
   - Plan remediation
   - Schedule reattempt

## Time Expectations

### Complete Production Workflow

- **Pre-deployment checks**: 30-60 minutes
- **Compilation**: 1-2 minutes
- **Admin Center upload**: 5-10 minutes
- **Installation**: 5-15 minutes
- **Verification**: 5-10 minutes
- **Post-deployment testing**: 30-60 minutes
- **Total**: 1.5-3 hours (including buffer)

**Plan for longer maintenance window than minimum time needed.**

## Comparison: Sandbox vs Production Workflow

| Aspect | Sandbox | Production |
|--------|---------|------------|
| **Validation** | Minimal | Extensive |
| **Confirmation** | None | Required |
| **Deployment** | Automated | Manual |
| **Testing** | Optional | Mandatory |
| **Timing** | Anytime | Scheduled |
| **Rollback** | Low priority | Plan required |
| **Duration** | ~1 minute | ~2 hours |
| **Risk** | Low | High |

## Notes
- **Production = Manual process**: Automation available but manual recommended for safety
- **Always test first**: Never deploy to production without sandbox testing
- **Use Admin Center**: Recommended for all production deployments
- **Document everything**: Keep records of all production changes
- **Communication is key**: Keep stakeholders informed throughout
- **Plan for failure**: Always have rollback plan ready
- **Monitor closely**: Watch for issues after deployment
- **Learn and improve**: Review each deployment, improve process
