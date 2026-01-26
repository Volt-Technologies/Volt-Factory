---
name: bc-compiler
description: Compile and publish Business Central AL applications. Use when AL code development is complete and needs compilation, or when compiled apps need publishing to BC sandbox or production environments. Handles single or multiple apps, dependency ordering, and provides detailed diagnostic output.
license: MIT
compatibility: Requires Node.js 18+, volt-technologies/volt-bc-tools package. Windows required for local Docker publishing.
metadata:
  author: volt-technologies
  version: "1.0.0"
allowed-tools: Bash(node:*) Bash(npx:*) Bash(volt-bc:*) Read
---

# BC Compiler Skill

Compile and publish Business Central AL applications using `volt-technologies/volt-bc-tools`.

## Prerequisites

1. **Package installed**: `npm install volt-technologies/volt-bc-tools`
2. **Configuration**: `.env` file with BC environment settings
3. **Dependencies**: `.alpackages` folder with symbol packages

## Quick Commands

### Compile All Apps
```bash
npx volt-bc dev compile --all
```

### Compile Specific App
```bash
npx volt-bc dev compile --app-path "./BC/MyApp"
```

### Publish to Sandbox (Dev Mode)
```bash
npx volt-bc dev publish "./output/Publisher_AppName_1.0.0.0.app"
```

## Workflow

### Step 1: Verify Environment

Check configuration before compiling:

```bash
npx volt-bc config
```

### Step 2: Compile Apps

```bash
npx volt-bc dev compile --all
```

**On Success**: Shows compiled .app files in output directory.

**On Failure**: Shows diagnostics with file path, line number, error code, and message:
```
✗ Compilation failed with 2 errors
  src/Customer.Table.al:15: [AL0118] The member 'InvalidField' is not found
  src/Sales.Codeunit.al:42: [AL0132] Variable 'amount' is not declared
```

### Step 3: Publish App

After successful compilation:

```bash
npx volt-bc dev publish "./output/Publisher_AppName_1.0.0.0.app" --sync-mode ForceSync
```

**Sync Modes**:
- `Add` - Add only, fail on schema conflicts
- `Clean` - Clean install (development only)
- `Development` - Development sync
- `ForceSync` - Force sync all changes (default)

## Configuration

### Required `.env` Settings

```env
BC_DEPLOYMENT_TYPE=online    # or 'local'
BC_ENVIRONMENT_TYPE=sandbox  # or 'production'
BC_ENVIRONMENT_NAME=Sandbox
BC_APPS_ROOT=BC
```

### Online/SaaS Authentication
```env
BC_TENANT_ID=your-tenant-guid
BC_CLIENT_ID=your-app-client-id
BC_CLIENT_SECRET=your-app-client-secret
```

### Local/Docker Authentication
```env
CURRENT_FEATURE_CONTAINER=container-name
BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=your-password
```

## Multiple Apps

When multiple apps exist under `BC_APPS_ROOT`, the compiler:
1. Discovers all `app.json` files recursively
2. Analyzes dependencies between apps
3. Compiles in dependency order (base apps first)

## Error Resolution

See [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md) for common errors:
- Missing symbols
- Authentication failures
- Schema sync issues

## Programmatic Usage

```typescript
import { ALCompiler, AppPublisher, EnvLoader } from 'volt-technologies/volt-bc-tools';

const config = new EnvLoader().load();

// Compile
const compiler = new ALCompiler({
  packageCachePath: '.alpackages',
  outputDir: 'output',
});
const result = await compiler.compileAll('BC');

// Publish
if (result.success) {
  const publisher = new AppPublisher({
    environment: config.deploymentType,
    containerName: config.containerName,
    tenantId: config.tenantId,
    clientId: config.clientId,
    clientSecret: config.clientSecret,
    environmentName: config.environmentName,
  });

  for (const r of result.results) {
    if (r.appFile) await publisher.publish(r.appFile);
  }
}
```

## Integration with Testing

After successful publish, invoke the `bc-test-runner` skill to execute automated tests.
