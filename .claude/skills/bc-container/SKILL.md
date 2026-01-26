---
name: bc-container
description: Create and manage isolated Business Central Docker containers for parallel development or testing. Use when starting work on a new feature that needs an isolated BC environment. Handles container creation, startup, and environment configuration. Windows-only (BC Docker requires Windows).
license: MIT
compatibility: Windows only. Requires Docker Desktop, BCContainerHelper PowerShell module, and volt-technologies/volt-bc-tools package.
metadata:
  author: volt-technologies
  version: "1.0.0"
allowed-tools: Bash(node:*) Bash(npx:*) Bash(volt-bc:*) Bash(docker:*) Bash(pwsh:*) Bash(powershell:*) Read Edit
---

# BC Container Skill

Create and manage Business Central Docker containers using `volt-technologies/volt-bc-tools`.

## Prerequisites

1. **Windows OS**: BC Docker containers only run on Windows
2. **Docker Desktop**: Must be installed and running
3. **BCContainerHelper**: PowerShell module for BC container management
4. **Package installed**: `npm install volt-technologies/volt-bc-tools`

## Quick Commands

### Create Container
```bash
npx volt-bc dev container create --name bc-feature --version 24.0
```

### List Containers
```bash
npx volt-bc dev container list
```

### Remove Container
```bash
npx volt-bc dev container remove bc-feature
```

## Workflow

### Step 1: Check Configuration

Read `.env` to verify container settings:
```bash
npx volt-bc config
```

Check if feature containers are enabled:
- `USE_FEATURE_CONTAINERS=true` - Create isolated containers
- `USE_FEATURE_CONTAINERS=false` - Use existing container

### Step 2: Check Existing Containers

Before creating, check if container exists:
```bash
docker ps -a --filter "name=bc-feature"
```

If container exists:
- **Stopped**: Start it with `docker start bc-feature`
- **Running**: Use existing container

### Step 3: Create Container

```bash
npx volt-bc dev container create \
  --name bc-feature \
  --version 24.0 \
  --country us \
  --memory 8G \
  --username admin \
  --password P@ssw0rd
```

**Options**:
- `--name <name>` - Container name (required)
- `--version <version>` - BC version (e.g., 24.0)
- `--country <code>` - Country code (default: us)
- `--memory <limit>` - Memory limit (default: 8G)
- `--username <user>` - Admin username (default: admin)
- `--password <pass>` - Admin password
- `--license <path>` - Path to license file
- `--no-test-toolkit` - Skip test toolkit installation

### Step 4: Update Environment

After creating, update `.env`:
```env
CURRENT_FEATURE_CONTAINER=bc-feature
```

## Container Naming Convention

Format: `bc-{feature-name}`

Examples:
- `bc-product-variants`
- `bc-customer-portal`
- `bc-invoice-processing`

## Configuration Reference

### Container Settings in `.env`

```env
# Enable feature containers (true/false)
USE_FEATURE_CONTAINERS=true

# Current feature container name
CURRENT_FEATURE_CONTAINER=bc-feature

# BC version for new containers
BC_ARTIFACT_VERSION=24.0

# Container credentials
BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=P@ssw0rd
```

## Using the Reusable Script

The skill uses a single reusable PowerShell script:

```powershell
# Create container
powershell -ExecutionPolicy Bypass -File ".claude/scripts/bc-create-container.ps1" `
  -ContainerName "bc-feature" `
  -ImageName "bcimage" `
  -Username "admin" `
  -Password "P@ssw0rd"
```

**Do NOT** create feature-specific scripts (e.g., `create-product-variants-container.ps1`).

## Output Format

After successful creation:
```
✓ BC Container Created Successfully

Container Name: bc-feature
Image: mcr.microsoft.com/businesscentral:24.0
Status: Running
Web Client URL: http://localhost:80/BC
Username: admin
Password: P@ssw0rd

Next Steps:
- Container is ready for development
- Use Web Client URL to access BC
- Deploy extensions using the container name
```

## Programmatic Usage

```typescript
import { ContainerManager } from 'volt-technologies/volt-bc-tools';

const manager = new ContainerManager();

// Create container
const result = await manager.create({
  containerName: 'bc-feature',
  bcVersion: '24.0',
  country: 'us',
  memoryLimit: '8G',
  username: 'admin',
  password: 'P@ssw0rd',
  includeTestToolkit: true,
});

if (result.success) {
  console.log(`Container created: ${result.container?.name}`);
  console.log(`Web Client: ${result.container?.webClientUrl}`);
}

// List containers
const containers = await manager.listContainers();

// Remove container
await manager.remove('bc-feature', true);
```

## Error Handling

### Non-Windows System
```
Error: BC Docker requires Windows
```
**Solution**: Use BC Online sandbox instead

### Docker Not Running
```
Error: Docker Desktop is not running
```
**Solution**: Start Docker Desktop

### BCContainerHelper Not Installed
```
Error: BCContainerHelper module not found
```
**Solution**:
```powershell
Install-Module BCContainerHelper -Force
```

### Port Conflicts
```
Error: Port 80 already in use
```
**Solution**: Stop conflicting container or use different port

### Insufficient Resources
```
Error: Not enough memory
```
**Solution**: Increase Docker Desktop memory allocation

## Best Practices

1. **Check before creating**: Always check if container exists first
2. **Use consistent naming**: Follow `bc-{feature}` convention
3. **Update .env**: Always update `CURRENT_FEATURE_CONTAINER` after creation
4. **Reuse containers**: Start existing containers instead of creating new ones
5. **Clean up**: Remove unused containers to save disk space

## Integration Points

The `CURRENT_FEATURE_CONTAINER` variable is used by:
- **bc-compiler**: Publishes apps to the container
- **bc-test-runner**: Runs tests in the container

Always keep this value current after container operations.
