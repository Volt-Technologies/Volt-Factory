# BC Developer Scripts

TypeScript scripts using `@volt-technologies/volt-bc-tools` for Business Central development.

## Prerequisites

1. Install dependencies:
   ```bash
   npm install @volt-technologies/volt-bc-tools
   ```

2. Configure `.env` file with BC settings (see Configuration below)

## Available Scripts

### compile.ts - Compile AL Applications

```bash
# Compile all apps
npx ts-node scripts/compile.ts --all

# Compile specific app
npx ts-node scripts/compile.ts --app-path "./BC/MyApp"

# Output as JSON
npx ts-node scripts/compile.ts --all --json
```

Options:
- `--all` - Compile all apps in BC_APPS_ROOT
- `--app-path <path>` - Compile specific app
- `--output <dir>` - Output directory (default: output)
- `--json` - Output as JSON

### publish.ts - Publish Applications

```bash
# Publish to environment from .env
npx ts-node scripts/publish.ts "./output/Publisher_App_1.0.0.0.app"

# With sync mode
npx ts-node scripts/publish.ts "./output/App.app" --sync-mode ForceSync

# Force local environment
npx ts-node scripts/publish.ts "./output/App.app" --environment local
```

Options:
- `--sync-mode <mode>` - Add, Clean, Development, ForceSync (default: ForceSync)
- `--environment <env>` - online or local (default: from .env)
- `--json` - Output as JSON

### run-tests.ts - Run AL Tests

```bash
# Run specific codeunit
npx ts-node scripts/run-tests.ts --codeunit 70200

# Run codeunit range
npx ts-node scripts/run-tests.ts --range "70200..70249"

# Run by extension
npx ts-node scripts/run-tests.ts --extension "your-extension-guid"

# Run test suite
npx ts-node scripts/run-tests.ts --suite "DEFAULT"
```

Options:
- `--codeunit <id>` - Run specific test codeunit
- `--range <start..end>` - Run codeunits in range
- `--extension <id>` - Run all tests for extension
- `--suite <name>` - Run test suite
- `--environment <env>` - online or local
- `--output <dir>` - Output directory (default: test-results)
- `--json` - Output as JSON

### container.ts - Container Management

```bash
# Create container
npx ts-node scripts/container.ts create --name "bc-my-feature"

# With options
npx ts-node scripts/container.ts create --name "bc-test" --country us --memory 8G

# List containers
npx ts-node scripts/container.ts list

# Get container info
npx ts-node scripts/container.ts info --name "bc-my-feature"

# List installed apps
npx ts-node scripts/container.ts apps --name "bc-my-feature"

# Start/stop/restart
npx ts-node scripts/container.ts start --name "bc-my-feature"
npx ts-node scripts/container.ts stop --name "bc-my-feature"
npx ts-node scripts/container.ts restart --name "bc-my-feature"

# Remove container
npx ts-node scripts/container.ts remove --name "bc-my-feature"
```

Actions:
- `create` - Create new container
- `remove` - Remove container
- `start` - Start stopped container
- `stop` - Stop running container
- `restart` - Restart container services
- `list` - List all containers
- `info` - Get container info
- `apps` - List installed apps

### verify.ts - Verify App Installation

```bash
# Verify specific app
npx ts-node scripts/verify.ts --app-name "My App"

# List all installed apps
npx ts-node scripts/verify.ts

# Verify in specific environment
npx ts-node scripts/verify.ts --app-name "My App" --environment local
```

## Configuration (.env)

```env
# Deployment type
BC_DEPLOYMENT_TYPE=online          # or 'local' for Docker
BC_ENVIRONMENT_TYPE=sandbox        # or 'production'
BC_ENVIRONMENT_NAME=Sandbox

# Online authentication
BC_TENANT_ID=your-tenant-guid
BC_CLIENT_ID=your-app-client-id
BC_CLIENT_SECRET=your-app-client-secret

# Local Docker
CURRENT_FEATURE_CONTAINER=bc-feature-name
BC_LOCAL_USERNAME=admin
BC_LOCAL_PASSWORD=your-password

# App configuration
BC_APPS_ROOT=BC
BC_COMPANY_NAME=CRONUS USA, Inc.
```

## Embedded Compiler

The `compiler/` folder contains the embedded AL compiler (alc.exe) with analyzers:

```
compiler/
└── extension/
    └── bin/
        ├── win32/alc.exe    # Windows compiler
        └── Analyzers/       # LinterCop, CodeCop, UICop, etc.
```

The compile.ts script automatically uses this embedded compiler.
