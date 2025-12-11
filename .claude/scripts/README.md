# BC PowerShell Scripts

PowerShell scripts for Business Central Docker container management and testing.

All scripts read configuration from the `.env` file at the repository root, so you typically don't need to specify parameters for common values like container name, credentials, etc.

## Available Scripts

### bc-create-container.ps1
Creates an isolated BC Docker container for development.

```powershell
# Create container with default settings
.\bc-create-container.ps1 -ContainerName "bc-my-feature"

# With custom memory limit
.\bc-create-container.ps1 -ContainerName "bc-test" -MemoryLimit "12G"
```

**Parameters:**
- `-ContainerName` (required): Name of the container to create
- `-ImageName`: Docker image name (default: bcimage)
- `-ArtifactUrl`: BC artifact URL (default: latest sandbox)
- `-Username`: Admin username (default: from .env or "admin")
- `-Password`: Admin password (default: from .env)
- `-MemoryLimit`: Container memory (default: 8G)
- `-IncludeTestToolkit`: Include test framework (default: true)

---

### bc-publish-app.ps1
Publishes a BC app to a Docker container.

```powershell
# Publish app using container from .env
.\bc-publish-app.ps1 -AppFile "BC\MyApp.app"

# Publish to specific container
.\bc-publish-app.ps1 -AppFile "BC Test\BC Test_1.0.0.1.app" -ContainerName "bc-my-feature"
```

**Parameters:**
- `-AppFile` (required): Path to the .app file
- `-ContainerName`: Target container (default: from .env)
- `-SkipVerification`: Skip signature verification (default: true)
- `-SyncMode`: Add, Clean, Development, ForceSync (default: ForceSync)

---

### bc-run-tests.ps1
Runs AL tests in BC Docker containers.

```powershell
# Run tests using container from .env
.\bc-run-tests.ps1 -TestCodeunitIdRange "70200..70249"

# Run tests in specific container
.\bc-run-tests.ps1 -ContainerName "bc-my-feature" -TestCodeunitIdRange "70200..70206"
```

**Parameters:**
- `-TestCodeunitIdRange` (required): Test codeunit range (e.g., "70200..70249")
- `-ContainerName`: Target container (default: from .env)
- `-CompanyName`: BC company name (default: from .env or "CRONUS International Ltd.")
- `-OutputPath`: Results output path (default: test-results)
- `-Username`: Admin username (default: from .env)
- `-Password`: Admin password (default: from .env)

---

### bc-verify-app.ps1
Verifies BC app installation and dependencies.

```powershell
# Verify all apps
.\bc-verify-app.ps1

# Verify specific app with codeunit check
.\bc-verify-app.ps1 -AppName "BC Test" -CheckCodeunitRange "70200..70249"
```

**Parameters:**
- `-AppName`: Name of the app to verify (default: shows all)
- `-ContainerName`: Target container (default: from .env)
- `-CheckCodeunitRange`: Optional codeunit range to verify in database

---

### bc-assign-permissions.ps1
Assigns permission sets to BC users.

```powershell
# Assign SUPER to admin user
.\bc-assign-permissions.ps1

# Assign different permission set
.\bc-assign-permissions.ps1 -PermissionSet "D365 FULL ACCESS"
```

**Parameters:**
- `-ContainerName`: Target container (default: from .env)
- `-UserName`: User to modify (default: from .env or "admin")
- `-PermissionSet`: Permission set to assign (default: SUPER)

---

### bc-upload-license.ps1
Uploads a BC license to a Docker container.

```powershell
# Upload using defaults from .env
.\bc-upload-license.ps1

# Upload specific license
.\bc-upload-license.ps1 -ContainerName "bc-my-feature" -LicenseFile "C:\licenses\my.bclicense"
```

**Parameters:**
- `-ContainerName`: Target container (default: from .env)
- `-LicenseFile`: Path to .bclicense file (default: license.bclicense in repo root)

---

## Configuration (.env)

These scripts read from the `.env` file at the repository root. Key variables:

```env
# Container name (used by most scripts)
CURRENT_FEATURE_CONTAINER=bc-product-attributes

# Credentials
BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=P@ssw0rd

# Company
BC_COMPANY_NAME=CRONUS International Ltd.
```

## Requirements

- Windows with Docker Desktop
- BCContainerHelper PowerShell module (auto-installed if missing)
- PowerShell 5.1 or later
