---
allowed-tools: Bash(powershell*), Bash(pwsh*)
description: Upload BC license to Docker container
---

# Business Central License Upload Command

## Purpose
This command uploads a Business Central license file (.bclicense) to the configured Docker container, restarts the BC service instance, and verifies the license was applied successfully.

## How It Works

### Configuration
The script reads configuration from the `.env` file:
- **CURRENT_FEATURE_CONTAINER**: The Docker container to upload the license to
- **License file**: Looks for `license.bclicense` in the repository root by default

### Process
1. Loads container name from `.env` (CURRENT_FEATURE_CONTAINER)
2. Locates the license file (default: `license.bclicense` in repo root)
3. Imports BCContainerHelper module
4. Verifies the container is running
5. Uploads the license using `Import-BcContainerLicense`
6. Restarts the BC service instance (automatic with -restart flag)
7. Reads back the license information using `Get-BcContainerLicenseInformation` to confirm

### Requirements
- BCContainerHelper PowerShell module installed
- Docker container running
- Valid `.bclicense` file

## Usage

### Basic Usage (uses defaults from .env)
```powershell
powershell -ExecutionPolicy Bypass -File scripts/bc-upload-license.ps1
```

### Custom Container and License
```powershell
powershell -ExecutionPolicy Bypass -File scripts/bc-upload-license.ps1 -ContainerName "bc-my-container" -LicenseFile "C:\path\to\license.bclicense"
```

## Parameters
- **ContainerName**: Name of the BC Docker container (default: from CURRENT_FEATURE_CONTAINER in .env)
- **LicenseFile**: Path to the .bclicense file (default: license.bclicense in repository root)

## Notes
- The BC service is automatically restarted after license upload
- License information is read back to verify the upload was successful
- If verification fails, check the BC web client manually under License Information
