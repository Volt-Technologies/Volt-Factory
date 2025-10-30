# Business Central Environments Guide

This document explains how to configure and manage different Business Central environments with the BC Claude Code Plugin.

## Table of Contents

- [Environment Types](#environment-types)
- [Deployment Types](#deployment-types)
- [Configuration](#configuration)
- [Multiple Environments](#multiple-environments)
- [Environment-Specific Settings](#environment-specific-settings)
- [Best Practices](#best-practices)

## Environment Types

The BC Claude Code Plugin distinguishes between two environment types:

### Sandbox Environments

**Purpose:** Development, testing, and experimentation

**Characteristics:**
- Safe for testing and breaking changes
- Supports both Dev and PTE publishing modes
- No user impact if broken
- Can be reset or recreated easily
- Ideal for daily development work

**Typical Names:**
- "Sandbox"
- "Development"
- "Dev"
- "Testing"
- "QA"
- "Staging"

**Configuration:**
```bash
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=Sandbox  # or your sandbox name
```

**Available Commands:**
- `bc_publish_sandbox` - Dev mode (fast)
- `bc_publish_sandbox_pte` - PTE mode (test production process)
- `bc_workflow_sandbox` - Complete workflow

### Production Environments

**Purpose:** Live business operations

**Characteristics:**
- Contains real business data
- Serves live users
- Requires careful change management
- PTE mode only (Dev mode blocked)
- Requires formal deployment process

**Typical Names:**
- "Production"
- "Live"
- "Prod"

**Configuration:**
```bash
BC_ENVIRONMENT_TYPE=production
BC_ENVIRONMENT_NAME=Production  # or your production name
```

**Available Commands:**
- `bc_publish_production` - PTE mode with safety checks
- `bc_workflow_production` - Complete production workflow
- **Note:** Dev mode is blocked for production

## Deployment Types

The plugin supports two deployment types based on where BC is hosted:

### Online/SaaS Deployment

**Description:** Business Central cloud service hosted by Microsoft

**Access Method:**
- Web interface: https://businesscentral.dynamics.com
- Admin Center: https://businesscentral.dynamics.com/admin
- API: https://api.businesscentral.dynamics.com

**Authentication:** OAuth 2.0 (Azure AD)

**Configuration:**
```bash
BC_DEPLOYMENT_TYPE=online

# Online authentication
BC_TENANT_ID=your-tenant-guid
BC_CLIENT_ID=your-app-client-id
BC_CLIENT_SECRET=your-app-secret

# Environment details
BC_ENVIRONMENT_NAME=Sandbox
```

**Advantages:**
- No infrastructure management
- Automatic updates
- High availability
- Managed by Microsoft

**Considerations:**
- Requires internet connectivity
- Subscription-based pricing
- Azure AD app registration required

### Local/Docker Deployment

**Description:** Business Central running on local server or Docker container

**Access Method:**
- Local server: http://localhost:7048 (default)
- Docker container: http://containerhost:7048
- On-premises server: http://bcserver:7048

**Authentication:** NavUserPassword (Basic Auth)

**Configuration:**
```bash
BC_DEPLOYMENT_TYPE=local

# Local authentication
BC_LOCAL_USERNAME=your-bc-username
BC_LOCAL_PASSWORD=your-bc-password
BC_LOCAL_SERVER_URL=http://localhost:7048

# Instance details
BC_ENVIRONMENT_NAME=BC250  # or your instance name
```

**Advantages:**
- Full control
- No internet dependency
- Custom configurations
- Good for development

**Considerations:**
- Must manage infrastructure
- Must apply updates manually
- Must ensure availability
- NavUserPassword must be enabled

## Configuration

### Basic Environment Configuration

**.env file structure:**
```bash
# ============================================================================
# DEPLOYMENT TARGET
# ============================================================================

# Deployment type: online or local
BC_DEPLOYMENT_TYPE=online

# Environment type: sandbox or production
BC_ENVIRONMENT_TYPE=sandbox

# Environment name
BC_ENVIRONMENT_NAME=Sandbox

# ============================================================================
# AUTHENTICATION (depends on deployment type)
# ============================================================================

# For online deployments
BC_TENANT_ID=
BC_CLIENT_ID=
BC_CLIENT_SECRET=

# For local deployments
BC_LOCAL_USERNAME=
BC_LOCAL_PASSWORD=
BC_LOCAL_SERVER_URL=

# ============================================================================
# OPTIONAL SETTINGS
# ============================================================================

# Company ID for API calls
BC_COMPANY_ID=

# Additional environments
BC_SANDBOX_ENV_NAME=
BC_PRODUCTION_ENV_NAME=
```

### Environment Discovery

#### Online/SaaS Environments

**List your environments:**
1. Go to https://businesscentral.dynamics.com/admin
2. Click "Environments"
3. Note environment names for configuration

**Environment naming:**
- Must match exactly as shown in Admin Center
- Case-sensitive
- Examples: "Sandbox", "Production", "Dev-MyName"

#### Local/Docker Environments

**List instances:**
```bash
# Windows (PowerShell)
Get-NAVServerInstance

# Or check BC Server Administration tool
```

**Instance naming:**
- Default instance: "BC" or "BC250" (version-dependent)
- Custom instances: As configured during setup
- Examples: "BC", "BC250", "MyDevInstance"

### launch.json Integration

The BC `.vscode/launch.json` file contains environment configuration for F5 debugging:

**Example launch.json:**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Sandbox",
            "type": "al",
            "environmentType": "Sandbox",
            "environmentName": "MySandbox",
            "tenant": "tenant-guid",
            "startupObjectId": 22,
            "startupObjectType": "Page"
        }
    ]
}
```

**Extracting to .env:**

Use the helper utility to extract configuration:
```bash
bash scripts/bc-extract-launch-config.sh
```

This will suggest .env values based on launch.json.

## Multiple Environments

### Managing Multiple Environments

You can work with multiple environments by:

1. **Using environment override flags**
2. **Maintaining multiple .env files**
3. **Setting optional environment variables**

### Method 1: Command-Line Overrides

Override environment for specific command:

```bash
# Publish to different sandbox
bash scripts/bc-publish-sandbox-dev.sh --environment "Dev-Sandbox-2"

# Verify app in production
bash scripts/bc-verify-app.sh --environment "Production"
```

### Method 2: Multiple .env Files

Create environment-specific configurations:

```
.env              # Default (sandbox)
.env.sandbox      # Sandbox configuration
.env.staging      # Staging configuration
.env.production   # Production configuration
```

**Switch environments:**
```bash
# Use sandbox
cp .env.sandbox .env

# Use production
cp .env.production .env
```

**Or with environment variable:**
```bash
# Load specific env file
export ENV_FILE=.env.production
# (Requires script modification to support)
```

### Method 3: Optional Environment Variables

Set additional environment names in `.env`:

```bash
BC_SANDBOX_ENV_NAME=MySandbox
BC_PRODUCTION_ENV_NAME=Production

# Then use in scripts or commands
# (Requires script modification to support)
```

## Environment-Specific Settings

### Sandbox-Specific Settings

**Dev Mode Options:**
- Force sync enabled
- Relaxed validation
- Schema recreation allowed
- Dependency ignore possible

**Recommended Configuration:**
```bash
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=Sandbox
BC_DEPLOYMENT_TYPE=online

# OAuth for online sandbox
BC_TENANT_ID=your-tenant
BC_CLIENT_ID=your-client-id
BC_CLIENT_SECRET=your-secret
```

### Production-Specific Settings

**PTE Mode Requirements:**
- Manual deployment process
- Confirmation required
- Admin Center recommended
- No dev mode allowed

**Recommended Configuration:**
```bash
BC_ENVIRONMENT_TYPE=production
BC_ENVIRONMENT_NAME=Production
BC_DEPLOYMENT_TYPE=online

# Separate OAuth app for production (recommended)
BC_TENANT_ID=your-tenant
BC_CLIENT_ID=prod-client-id
BC_CLIENT_SECRET=prod-secret
```

**Security Best Practices:**
- Use different Azure AD app for production
- Restrict access to production .env
- Rotate secrets regularly
- Audit all production deployments

## Environment Setup Examples

### Example 1: Online Sandbox

```bash
# .env for online sandbox development
BC_DEPLOYMENT_TYPE=online
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=Sandbox

BC_TENANT_ID=abc123-def456-ghi789
BC_CLIENT_ID=client-abc-123
BC_CLIENT_SECRET=secret-xyz-789

BC_COMPANY_ID=company-guid-123
```

**Usage:**
```bash
bc_compile
bc_publish_sandbox
```

### Example 2: Local Docker Development

```bash
# .env for local Docker development
BC_DEPLOYMENT_TYPE=local
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=BC

BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=YourPassword123!
BC_LOCAL_SERVER_URL=http://localhost:7048

BC_COMPANY_ID=default-company-guid
```

**Usage:**
```bash
bc_compile
bc_publish_sandbox
```

### Example 3: Online Production

```bash
# .env for online production
BC_DEPLOYMENT_TYPE=online
BC_ENVIRONMENT_TYPE=production
BC_ENVIRONMENT_NAME=Production

BC_TENANT_ID=prod-tenant-id
BC_CLIENT_ID=prod-client-id
BC_CLIENT_SECRET=prod-secret

BC_COMPANY_ID=prod-company-id
```

**Usage:**
```bash
bc_compile
bc_publish_production
# Then manual upload via Admin Center
```

### Example 4: Multi-Environment Organization

**Directory structure:**
```
.env.dev          # Development sandbox
.env.staging      # Staging sandbox
.env.production   # Production
.env              # Symlink to active env
```

**Switch script:**
```bash
#!/bin/bash
# switch-env.sh

case $1 in
    dev)
        cp .env.dev .env
        echo "Switched to development"
        ;;
    staging)
        cp .env.staging .env
        echo "Switched to staging"
        ;;
    production)
        cp .env.production .env
        echo "Switched to production"
        ;;
    *)
        echo "Usage: ./switch-env.sh [dev|staging|production]"
        ;;
esac
```

## Best Practices

### Development Environments

1. **Use Dev Mode**
   - Fastest iteration
   - Immediate feedback
   - Perfect for daily work

2. **Test Frequently**
   - Deploy often
   - Catch issues early
   - Validate changes quickly

3. **Separate Sandboxes**
   - Personal sandbox for development
   - Shared sandbox for team testing
   - Staging sandbox for pre-production

### Production Environments

1. **Separate Credentials**
   - Different Azure AD app
   - Different .env file
   - Restricted access

2. **Test First**
   - Always test in sandbox
   - Use PTE mode in sandbox first
   - Validate complete workflow

3. **Manual Deployment**
   - Use Admin Center for production
   - Visual confirmation
   - Better error messages

4. **Schedule Changes**
   - Maintenance windows
   - User notification
   - Rollback plan ready

### Multi-Environment Management

1. **Naming Convention**
   - Clear environment names
   - Consistent naming scheme
   - Document environment purposes

2. **Access Control**
   - Limit production access
   - Track who deploys where
   - Audit deployments

3. **Configuration Management**
   - Version control .env.example
   - Document environment setup
   - Keep production secrets secure

4. **Deployment Pipeline**
   - Dev → Test → Staging → Production
   - Gates between environments
   - Automated where possible

## Troubleshooting

### Wrong Environment Name

**Symptom:** "Environment not found" or 404 errors

**Solution:**
- Verify environment name in Admin Center (online)
- Check instance name (local)
- Ensure exact case match
- Check for typos in `.env`

### Environment Type Mismatch

**Symptom:** "Dev mode not allowed" or "PTE required"

**Solution:**
- Check `BC_ENVIRONMENT_TYPE` in `.env`
- Sandbox: Both dev and PTE allowed
- Production: Only PTE allowed
- Update `.env` to match actual environment

### Authentication Fails for Environment

**Symptom:** 401 Unauthorized when accessing environment

**Solution:**
- Verify credentials are for correct tenant
- Check Azure AD app has permissions
- Ensure environment is in same tenant
- For local: Check user has permissions in BC

### Can't Access Specific Environment

**Symptom:** Environment not accessible via API

**Solution:**
- Check environment is running
- Verify network connectivity
- Check firewall rules (local)
- Ensure environment isn't suspended (online)

## Resources

- [BC Admin Center](https://businesscentral.dynamics.com/admin)
- [BC Environments Documentation](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/tenant-admin-center-environments)
- [launch.json Configuration](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-json-launch-file)

---

For authentication setup, see [AUTHENTICATION.md](AUTHENTICATION.md)

For publishing guide, see [PUBLISHING.md](PUBLISHING.md)
