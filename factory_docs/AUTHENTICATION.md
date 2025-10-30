# Business Central Authentication Guide

This document explains how to configure authentication for the BC Claude Code Plugin to publish apps to Business Central environments.

## Table of Contents

- [Authentication Methods](#authentication-methods)
- [OAuth 2.0 Setup (Online/SaaS)](#oauth-20-setup-onlinesaas)
- [NavUserPassword Setup (Local/Docker)](#navuserpassword-setup-localdocker)
- [Testing Authentication](#testing-authentication)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)

## Authentication Methods

The BC Claude Code Plugin supports two authentication methods:

| Method | Deployment Type | Use Case |
|--------|----------------|----------|
| **OAuth 2.0** | Online/SaaS | Microsoft-hosted BC cloud |
| **NavUserPassword** | Local/Docker | Self-hosted BC instances |

The plugin automatically selects the correct method based on `BC_DEPLOYMENT_TYPE` in `.env`.

## OAuth 2.0 Setup (Online/SaaS)

OAuth 2.0 is used for authenticating with Microsoft-hosted Business Central (online/SaaS).

### Overview

**Authentication Flow:**
1. Plugin requests access token from Azure AD
2. Azure AD validates client credentials
3. Azure AD issues access token
4. Plugin uses token in API requests to BC
5. Token valid for ~1 hour, cached automatically

**Required Components:**
- Azure AD tenant
- Azure AD app registration
- Client ID and secret
- API permissions granted

### Step-by-Step Setup

#### Step 1: Access Azure Portal

1. Go to https://portal.azure.com
2. Sign in with admin account
3. Navigate to "Azure Active Directory"

#### Step 2: Create App Registration

1. Click "App registrations" in left menu
2. Click "New registration"
3. Fill in details:
   - **Name**: "BC Publishing Tool" (or your choice)
   - **Supported account types**: "Accounts in this organizational directory only"
   - **Redirect URI**: Leave empty (not needed for client credentials)
4. Click "Register"

#### Step 3: Copy Application Details

After registration:
1. Note the **Application (client) ID** - this is your `BC_CLIENT_ID`
2. Note the **Directory (tenant) ID** - this is your `BC_TENANT_ID`

#### Step 4: Create Client Secret

1. In your app registration, go to "Certificates & secrets"
2. Click "New client secret"
3. Fill in:
   - **Description**: "BC Publishing Secret" (or your choice)
   - **Expires**: Choose expiration (6 months, 1 year, or custom)
4. Click "Add"
5. **IMPORTANT**: Copy the secret **VALUE** immediately - this is your `BC_CLIENT_SECRET`
   - You won't be able to see it again!
   - If you lose it, create a new secret

#### Step 5: Grant API Permissions

1. In your app registration, go to "API permissions"
2. Click "Add a permission"
3. Select "APIs my organization uses"
4. Search for "Dynamics 365 Business Central"
5. Select "Dynamics 365 Business Central"
6. Choose "Application permissions" (not Delegated)
7. Select **"Automation.ReadWrite.All"**
   - This permission allows publishing extensions
8. Click "Add permissions"
9. Click "Grant admin consent for [your organization]"
   - **This step is critical!**
   - Only admins can grant consent
10. Confirm admin consent

#### Step 6: Configure .env

Add credentials to `.env`:

```bash
BC_DEPLOYMENT_TYPE=online

# Azure AD Authentication
BC_TENANT_ID=your-directory-tenant-id-here
BC_CLIENT_ID=your-application-client-id-here
BC_CLIENT_SECRET=your-secret-value-here

# OAuth scope (usually don't need to change)
BC_OAUTH_SCOPE=https://api.businesscentral.dynamics.com/.default
```

#### Step 7: Test Authentication

```bash
bash scripts/bc-auth.sh test
```

Expected output:
```
Testing authentication...
Deployment type: online
Environment: Sandbox

Acquiring OAuth access token...
✓ OAuth token acquired successfully (expires in 3600s)
✓ Authentication successful
```

### OAuth Token Details

**Token Characteristics:**
- **Lifetime**: ~1 hour (3600 seconds)
- **Scope**: `https://api.businesscentral.dynamics.com/.default`
- **Type**: Bearer token
- **Caching**: Automatically cached in `.bc_token_cache`
- **Renewal**: Automatic when expired

**Token Cache:**
- Location: `.bc_token_cache` (git-ignored)
- Format: Plain text with access token and expiry
- Permissions: 600 (owner read/write only)
- Automatic renewal when expired

### Required API Permissions

| Permission | Type | Purpose |
|------------|------|---------|
| `Automation.ReadWrite.All` | Application | Publish extensions via Automation API |

**Optional Permissions** (for extended functionality):
- `API.ReadWrite.All` - General BC API access
- `Environment.ReadWrite.All` - Environment management

### OAuth Troubleshooting

**Error: "invalid_client"**
- Verify client ID is correct
- Check client secret hasn't expired
- Ensure app registration exists

**Error: "unauthorized_client"**
- Grant admin consent for API permissions
- Wait 5-10 minutes after granting consent
- Check "Application permissions" (not Delegated)

**Error: "invalid_scope"**
- Verify scope is `https://api.businesscentral.dynamics.com/.default`
- Check API permissions include BC

**Error: "Token expired"**
- This is normal after 1 hour
- Plugin automatically renews
- If persists, clear cache: `bash scripts/bc-auth.sh clear-cache`

## NavUserPassword Setup (Local/Docker)

NavUserPassword authentication is used for self-hosted Business Central instances (local servers, Docker containers).

### Overview

**Authentication Method:** HTTP Basic Authentication

**Required Components:**
- BC user account with appropriate permissions
- NavUserPassword authentication enabled in BC
- BC server URL

### Step-by-Step Setup

#### Step 1: Enable NavUserPassword Authentication

**In BC Server Administration:**

1. Open "Business Central Server Administration" tool
2. Select your BC instance
3. Click "Edit"
4. Go to "Client Services" tab
5. Find "Credential Type"
6. Set to "NavUserPassword" or "Windows, NavUserPassword"
7. Click "Save"
8. Restart BC Service

**Or via PowerShell:**
```powershell
Set-NAVServerConfiguration -ServerInstance BC `
    -KeyName ClientServicesCredentialType `
    -KeyValue "NavUserPassword"

Restart-NAVServerInstance -ServerInstance BC
```

#### Step 2: Create BC User

**In Business Central Client:**

1. Search for "Users"
2. Click "New"
3. Fill in user details:
   - **User Name**: admin (or your choice)
   - **Full Name**: API Admin
4. Set password
5. Assign permissions:
   - Add permission set: "SUPER" (for full access)
   - Or create custom permission set with extension management rights
6. Save user

**Or via PowerShell:**
```powershell
New-NAVServerUser -ServerInstance BC `
    -UserName "admin" `
    -Password (ConvertTo-SecureString "YourPassword" -AsPlainText -Force) `
    -FullName "API Admin"

New-NAVServerUserPermissionSet -ServerInstance BC `
    -UserName "admin" `
    -PermissionSetId "SUPER"
```

#### Step 3: Get Server URL

**Default URLs:**
- Default: `http://localhost:7048`
- With instance: `http://localhost:7048/BC250`
- Remote: `http://servername:7048`
- Docker: `http://containerhost:7048`

**Finding your URL:**
1. Check BC Server Administration tool
2. Note "Server Instance" name
3. Note port number (usually 7048 for HTTP, 7049 for HTTPS)

#### Step 4: Configure .env

Add credentials to `.env`:

```bash
BC_DEPLOYMENT_TYPE=local

# NavUserPassword Authentication
BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=YourSecurePassword123!
BC_LOCAL_SERVER_URL=http://localhost:7048

# BC instance name
BC_ENVIRONMENT_NAME=BC  # or your instance name (BC250, etc.)
```

#### Step 5: Test Authentication

```bash
bash scripts/bc-auth.sh test
```

Expected output:
```
Testing authentication...
Deployment type: local
Environment: BC

✓ Authentication successful
Auth header: Authorization: Basic YWRtaW46...
```

### NavUserPassword Troubleshooting

**Error: "Authentication failed" or 401**
- Verify username and password are correct
- Check user exists in BC
- Ensure user has appropriate permissions
- Verify NavUserPassword is enabled

**Error: "Connection refused"**
- Check BC server is running
- Verify BC_LOCAL_SERVER_URL is correct
- Check port number (7048 for HTTP, 7049 for HTTPS)
- Check firewall allows connections

**Error: "Access denied"**
- User may lack necessary permissions
- Add "SUPER" permission set
- Or grant specific extension management permissions

## Testing Authentication

### Manual Testing

```bash
# Test authentication
bash scripts/bc-auth.sh test

# Get authorization header
bash scripts/bc-auth.sh get-header

# Get just the token/credentials
bash scripts/bc-auth.sh get-token

# Clear cached token (OAuth only)
bash scripts/bc-auth.sh clear-cache
```

### Automated Testing

Include in CI/CD pipeline:

```bash
#!/bin/bash
# test-auth.sh

# Test authentication before deployment
if ! bash scripts/bc-auth.sh test; then
    echo "Authentication test failed!"
    exit 1
fi

echo "Authentication OK, proceeding with deployment..."
```

### Validation Script

Use the config validation utility:

```bash
bash scripts/bc-config-validate.sh
```

This checks:
- Deployment type is valid
- Required credentials are present
- Authentication works
- Environment is accessible

## Troubleshooting

### General Authentication Issues

**Problem:** Authentication fails intermittently

**Solutions:**
- OAuth: Check token cache isn't corrupted - clear it
- Basic: Verify credentials haven't changed
- Check network connectivity
- Verify BC service is running

**Problem:** "Access denied" errors

**Solutions:**
- Verify permissions granted
- OAuth: Check admin consent granted
- Basic: Check user has SUPER permission set
- Verify app/user hasn't been disabled

**Problem:** Authentication works but publishing fails

**Solutions:**
- Authentication OK but lacks specific permissions
- OAuth: May need additional API permissions
- Basic: User may need specific extension management rights
- Check environment is correct

### OAuth-Specific Issues

**Problem:** Token acquisition fails

**Solutions:**
- Verify tenant ID, client ID, secret are correct
- Check app registration still exists
- Ensure secret hasn't expired (check expiry date)
- Grant admin consent if not granted

**Problem:** "insufficient_privileges" error

**Solutions:**
- Grant admin consent for API permissions
- Verify "Application permissions" not "Delegated"
- Check correct permission: `Automation.ReadWrite.All`
- Wait 5-10 minutes after granting consent

### Basic Auth-Specific Issues

**Problem:** Basic auth not accepted

**Solutions:**
- Check NavUserPassword is enabled
- Verify BC server configuration
- Restart BC service after enabling
- Check credential type setting

**Problem:** Password special characters cause issues

**Solutions:**
- Avoid special characters in password: & < > | " '
- Use alphanumeric + basic symbols: ! @ # $ % ^ *
- Or URL-encode the password if needed

## Security Best Practices

### OAuth 2.0 Security

1. **Separate Apps for Environments**
   - Different Azure AD app for production
   - Separate credentials per environment
   - Easier to revoke if compromised

2. **Secret Management**
   - Rotate secrets regularly (every 3-6 months)
   - Never commit secrets to version control
   - Use Azure Key Vault for production secrets

3. **Principle of Least Privilege**
   - Grant only required API permissions
   - Don't use personal admin accounts
   - Use service accounts with minimal permissions

4. **Monitoring**
   - Review Azure AD sign-in logs
   - Monitor for unauthorized access
   - Set up alerts for suspicious activity

5. **Secret Expiration**
   - Set appropriate expiration
   - Renew before expiry
   - Document renewal process

### NavUserPassword Security

1. **Strong Passwords**
   - Use complex passwords (16+ characters)
   - Include uppercase, lowercase, numbers, symbols
   - Avoid dictionary words

2. **Dedicated Service Accounts**
   - Create dedicated user for API access
   - Don't use personal user accounts
   - Name clearly: "API_Publishing_Service"

3. **Minimal Permissions**
   - Grant only extension management permissions
   - Avoid SUPER if possible
   - Create custom permission set

4. **Network Security**
   - Use HTTPS (port 7049) not HTTP
   - Restrict network access to BC server
   - Use VPN for remote access
   - Configure firewall rules

5. **Password Rotation**
   - Change passwords regularly
   - Use password manager
   - Document password policy

### .env File Security

1. **File Permissions**
   ```bash
   chmod 600 .env  # Owner read/write only
   ```

2. **Git Ignore**
   - Ensure `.env` in `.gitignore`
   - Never commit credentials
   - Use `.env.example` as template

3. **Encryption**
   - Consider encrypting .env for storage
   - Use secrets management tools
   - Azure Key Vault, HashiCorp Vault, etc.

4. **Access Control**
   - Limit who has access to production .env
   - Track access to credentials
   - Audit credential usage

### Multi-Environment Security

1. **Separate Credentials**
   ```
   .env.dev        # Dev credentials
   .env.staging    # Staging credentials
   .env.production # Production credentials (most restricted)
   ```

2. **Different Azure AD Apps**
   - Dev app: Relaxed permissions
   - Production app: Strict permissions, different tenant

3. **Credential Scope**
   - Dev: Can use personal accounts
   - Staging: Service accounts
   - Production: Dedicated service accounts with approval process

## Resources

- [Azure AD App Registration](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)
- [Business Central Authentication](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-develop-connect-apps)
- [OAuth 2.0 Client Credentials Flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow)
- [BC Server Administration](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/administration)

---

For environment configuration, see [ENVIRONMENTS.md](ENVIRONMENTS.md)

For publishing guide, see [PUBLISHING.md](PUBLISHING.md)
