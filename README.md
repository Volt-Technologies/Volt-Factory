# TO DO

Set the .env variables

# MS Learn MCP
claude mcp add --transport http microsoft_docs_mcp https://learn.microsoft.com/api/mcp


# DevOps MCP server
we dont use mcirosoft's because it doesnt allow PAT.
Run the following command to add the mcp server for Azure DevOps where Contoso is the organization name, mostly VoltBC
claude mcp add azureDevOps -s user -e AZURE_DEVOPS_ORG_URL="https://dev.azure.com/VoltBC/" -e AZURE_DEVOPS_AUTH_METHOD="pat" -e AZURE_DEVOPS_PAT="2IuiGd1v9AbXnysPidVeJ6mejeozYRveBFbodMeqeoCIXK8NDlSKJQQJ99BJACAAAAAyZ7RBAAASAZDO3Ebp" -e AZURE_DEVOPS_DEFAULT_PROJECT="Factory" -- npx @tiberriver256/mcp-server-azure-devops

# Business Central Claude Code Plugin
A comprehensive development solution for compiling and publishing Business Central (Dynamics 365 BC) AL extensions using Claude Code. This repository provides automated compilation and deployment tools with support for multiple apps, multiple environments, cross-platform compatibility, and flexible configuration.

## Features

### Compilation
- **Multi-App Compilation**: Automatically discovers and compiles all BC apps in your workspace
- **Cross-Platform Support**: Works seamlessly on Windows, Linux, and macOS
- **Auto-Discovery**: Recursively finds all `app.json` files in your apps directory
- **Versioned Output**: Compiled apps include version number in filename
- **Error Resilience**: Continues compiling remaining apps even if one fails

### Publishing
- **Multiple Publishing Modes**: Dev mode (fast) and PTE mode (production-ready)
- **Sandbox & Production**: Support for both sandbox and production environments
- **Online & Local**: Works with Microsoft cloud (OAuth) and local/Docker (Basic Auth)
- **Automated Publishing**: Push apps to BC environments via API
- **Real-Time Monitoring**: Automatic deployment status tracking with live updates
- **App Verification**: Check installation status after deployment
- **Complete Workflows**: End-to-end compile → publish → verify automation
- **Smart Configuration**: Auto-fetch company ID from BC API when not configured

### Integration
- **Claude Code Integration**: Native slash command support with `bc_` prefix
- **Flexible Configuration**: Environment-based configuration via `.env` file
- **Comprehensive Reporting**: Detailed summaries with success/failure status
- **Safety Features**: Production confirmations and validation checks

## Quick Start

1. **Clone or download this repository**
2. **Configure your apps** (optional):
   - Edit [.env](.env) to customize paths and settings
   - Default configuration works with the `BC` folder
3. **Compile your apps**:
   - Via Claude Code: `/bc_compile`
   - Via command line: `bash scripts/compile.sh`
4. **Publish to sandbox**:
   - Via Claude Code: `/bc_workflow_sandbox`
   - Automatically compiles, publishes, and verifies

## Recent Improvements

### PTE Publishing with Automatic Monitoring (v2.0)

The PTE (Per-Tenant Extension) publishing workflow has been completely rewritten with advanced automation:

**4-Step Automated Workflow:**
1. **Resource Creation**: Creates or reuses extensionUpload resource with smart conflict resolution
2. **Binary Upload**: Uploads .app file with proper HTTP multipart/form-data (CRLF-compliant)
3. **Installation Trigger**: Invokes Microsoft.NAV.upload bound action
4. **Real-Time Monitoring**: Automatically polls deployment status every 10 seconds until complete

**Key Features:**
- ✅ **Automatic Status Tracking**: No more manual checking - monitors installation progress in real-time
- ✅ **Smart Company Detection**: Auto-fetches company ID from BC API if not configured
- ✅ **Complete Error Reporting**: Detailed failure information with actionable recommendations
- ✅ **HTTP Compliance**: Fixed multipart/form-data with proper CRLF line endings
- ✅ **Production-Ready**: Exit codes (0/1/2) for CI/CD integration
- ✅ **Progress Indicators**: Live status updates during 2-5 minute installation process

**Example Output:**
```bash
Step 4: Monitoring installation status...
[1] Status: InProgress
[2] Status: InProgress
...
[12] Status: Completed

✓ SUCCESS: Extension installed successfully (PTE mode)
The extension is now available in Business Central!
```

See [PTE Publishing Command](.claude/commands/bc_publish_sandbox_pte.md) for complete documentation.

## Repository Structure

```
BC Claude code plugin/
├── .env                              # Environment configuration
├── .env.example                      # Configuration template
├── .claude/                          # Claude Code configuration
│   └── commands/
│       ├── bc_compile.md             # Compile command
│       ├── bc_publish_sandbox.md     # Sandbox publishing
│       ├── bc_publish_sandbox_pte.md # Sandbox PTE publishing
│       ├── bc_publish_production.md  # Production publishing
│       ├── bc_verify.md              # App verification
│       ├── bc_workflow_sandbox.md    # Complete sandbox workflow
│       └── bc_workflow_production.md # Complete production workflow
├── BC/                               # Default BC apps directory
│   ├── app.json                      # App manifest
│   ├── HelloWorld.al                 # AL source code
│   └── .alpackages/                  # BC dependencies
├── scripts/
│   ├── compile.sh                    # Multi-app compilation
│   ├── bc-auth.sh                    # Authentication handler
│   ├── bc-publish-sandbox-dev.sh     # Sandbox dev publishing
│   ├── bc-publish-sandbox-pte.sh     # Sandbox PTE publishing
│   ├── bc-publish-production-pte.sh  # Production PTE publishing
│   ├── bc-verify-app.sh              # App verification
│   ├── bc-config-validate.sh         # Config validation
│   ├── bc-extract-launch-config.sh   # launch.json extractor
│   └── compiler/                     # AL Compiler (cross-platform)
│       └── extension/bin/
│           ├── win32/                # Windows compiler
│           ├── linux/                # Linux compiler
│           └── darwin/               # macOS compiler
├── docs/
│   ├── PUBLISHING.md                 # Publishing guide
│   ├── ENVIRONMENTS.md               # Environment configuration
│   └── AUTHENTICATION.md             # Auth setup guide
└── README.md                         # This file
```

## Configuration

### Environment Variables (.env)

The [.env](.env) file in the repository root configures the compilation behavior:

```bash
# Root directory containing BC apps (can contain multiple apps with app.json files)
# The compiler will recursively search for all app.json files under this path
# Default: BC
BC_APPS_ROOT=BC

# Optional: Custom compiler path
# If not set, uses: scripts/compiler/extension/bin/{OS}/alc
# BC_COMPILER_PATH=

# Optional: Custom package cache directory for dependencies
# If not set, uses: {app_folder}/.alpackages for each app
# BC_PACKAGE_CACHE=

# Optional: Custom output directory for compiled apps
# If not set, outputs to: {app_folder}/{app_name}.app
# BC_OUTPUT_DIR=
```

### Configuration Examples

#### Single App (Default Setup)
Keep the default configuration to compile a single app in the `BC` folder:
```bash
BC_APPS_ROOT=BC
```

Result:
- Searches: `BC/app.json`
- Compiles: `BC/BC.app`

#### Multiple Apps in Same Directory
Organize multiple apps under the `BC` folder:
```
BC/
├── AppOne/
│   ├── app.json
│   └── *.al files
└── AppTwo/
    ├── app.json
    └── *.al files
```

Configuration (same as default):
```bash
BC_APPS_ROOT=BC
```

Result:
- Finds: `BC/AppOne/app.json` and `BC/AppTwo/app.json`
- Compiles: `BC/AppOne/AppOne.app` and `BC/AppTwo/AppTwo.app`

#### Custom Apps Location
Use a different directory for your apps:
```bash
BC_APPS_ROOT=MyBusinessCentralApps
```

#### Global Package Cache
Share dependencies across all apps:
```bash
BC_PACKAGE_CACHE=shared-packages
```

#### Custom Output Directory
Compile all apps to a specific output folder:
```bash
BC_OUTPUT_DIR=build/output
```

## Compilation

### Multi-App Compilation Architecture

The compilation system is designed to handle multiple Business Central apps efficiently:

1. **Auto-Discovery**: The script recursively searches the `BC_APPS_ROOT` directory for all `app.json` files
2. **Independent Compilation**: Each app is compiled independently with its own:
   - Package cache (`.alpackages` folder)
   - Output file (`{app-name}.app`)
   - Compilation settings
3. **Error Handling**: If one app fails to compile, the script continues with remaining apps
4. **Summary Report**: At the end, you get a complete summary showing:
   - Total apps found
   - Successfully compiled apps with file sizes
   - Failed apps with their locations
   - Common troubleshooting tips

### Using the Compile Command

#### Via Claude Code (Recommended)
```
/compile
```

This runs the compilation script through Claude Code, providing a streamlined experience with automatic error handling and helpful suggestions.

#### Via Command Line
```bash
bash scripts/compile.sh
```

With custom parameters:
```bash
bash scripts/compile.sh --appsroot "MyApps" --output "build"
```

Available parameters:
- `--appsroot PATH`: Root path to search for BC apps
- `--compiler PATH`: Path to compiler folder
- `--packagecache PATH`: Global package cache folder
- `--output PATH`: Custom output directory
- `--help`: Show help message

### Compilation Output Example

```
=== Business Central AL Multi-App Compilation Script ===
Starting compilation process...
Detected OS: win32

Loading configuration from .env file...
  BC_APPS_ROOT=BC

Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Apps Root:     C:/Users/Usuario/Desktop/BC Claude code plugin/BC
Compiler:      C:/Users/Usuario/Desktop/BC Claude code plugin/scripts/compiler/extension/bin/win32/alc.exe
Package Cache: Per-app (.alpackages in each app folder)
Output Dir:    Per-app (each app in its own folder)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Discovering Business Central apps...
Found 2 app(s) to compile:
  - C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppOne
  - C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppTwo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Compiling: AppOne
Location:  C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppOne
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Compilation settings:
  Project:       C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppOne
  Package Cache: C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppOne/.alpackages
  Output:        C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppOne/AppOne.app

✓ SUCCESS: AppOne compiled successfully (256K)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Compiling: AppTwo
Location:  C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppTwo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Compilation settings:
  Project:       C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppTwo
  Package Cache: C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppTwo/.alpackages
  Output:        C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppTwo/AppTwo.app

✓ SUCCESS: AppTwo compiled successfully (128K)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
=== COMPILATION SUMMARY ===
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total apps found:       2
Successfully compiled:  2
Failed:                 0

✓ Successful compilations:
  - AppOne → C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppOne/AppOne.app (256K)
  - AppTwo → C:/Users/Usuario/Desktop/BC Claude code plugin/BC/AppTwo/AppTwo.app (128K)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Compilation process completed successfully!
```

## Publishing

After compiling your apps, you can publish them to Business Central environments using the integrated publishing commands.

### Quick Publishing

**For Sandbox Development:**
```bash
bc_compile              # Compile all apps
bc_publish_sandbox      # Publish to sandbox (dev mode)
```

**For Production:**
```bash
bc_compile               # Compile all apps
bc_publish_production    # Validate and guide production deployment
# Then upload manually via BC Admin Center
```

### Publishing Modes

| Mode | Command | Environment | Use Case |
|------|---------|-------------|----------|
| **Dev Mode** | `bc_publish_sandbox` | Sandbox only | Fast development iteration |
| **PTE Mode** | `bc_publish_sandbox_pte` | Sandbox | Test production process |
| **Production** | `bc_publish_production` | Production | Live deployments |

### Available Commands

All commands use the `bc_` prefix for easy discovery:

- **bc_compile** - Compile all BC apps
- **bc_publish_sandbox** - Publish to sandbox (dev mode, fast)
- **bc_publish_sandbox_pte** - Publish to sandbox (PTE mode, test production)
- **bc_publish_production** - Production deployment (with safety checks)
- **bc_verify** - Verify app installation status
- **bc_workflow_sandbox** - Complete sandbox workflow
- **bc_workflow_production** - Complete production workflow

### Publishing Configuration

Configure publishing in `.env`:

```bash
# ============================================================================
# PUBLISHING CONFIGURATION
# ============================================================================

# Deployment type: online (Microsoft cloud) or local (Docker/on-premises)
BC_DEPLOYMENT_TYPE=online

# Environment type: sandbox or production
BC_ENVIRONMENT_TYPE=sandbox

# === ONLINE/SAAS AUTHENTICATION (OAuth 2.0) ===
BC_TENANT_ID=your-tenant-id
BC_CLIENT_ID=your-app-client-id
BC_CLIENT_SECRET=your-app-secret

# === LOCAL/DOCKER AUTHENTICATION (NavUserPassword) ===
BC_LOCAL_USERNAME=your-username
BC_LOCAL_PASSWORD=your-password
BC_LOCAL_SERVER_URL=http://localhost:7048

# === ENVIRONMENT CONFIGURATION ===
BC_ENVIRONMENT_NAME=Sandbox
BC_COMPANY_ID=your-company-id
```

See [.env.example](.env.example) for complete configuration template.

### Authentication Setup

#### Online/SaaS (OAuth 2.0)

1. Create Azure AD App Registration
2. Grant API permission: `Automation.ReadWrite.All`
3. Grant admin consent
4. Configure `.env` with tenant ID, client ID, and secret

See [docs/AUTHENTICATION.md](docs/AUTHENTICATION.md) for detailed setup.

#### Local/Docker (NavUserPassword)

1. Enable NavUserPassword in BC Server
2. Create BC user with appropriate permissions
3. Configure `.env` with username, password, and server URL

See [docs/AUTHENTICATION.md](docs/AUTHENTICATION.md) for detailed setup.

### Publishing Workflow Examples

#### Daily Development (Sandbox)
```bash
# Make code changes, then:
bc_compile && bc_publish_sandbox

# Verify deployment:
bash scripts/bc-verify-app.sh
```

#### Pre-Production Testing
```bash
# Test PTE deployment process in sandbox:
bc_compile
bc_publish_sandbox_pte

# Wait for async installation:
sleep 60

# Verify installation:
bash scripts/bc-verify-app.sh
```

#### Production Release
```bash
# 1. Update version in app.json

# 2. Compile production version:
bc_compile

# 3. Run production validation:
bc_publish_production
# (Shows checklist, requires "DEPLOY" confirmation)

# 4. Upload manually via BC Admin Center:
# - Go to https://businesscentral.dynamics.com/admin
# - Navigate to Environments → Production → Apps
# - Upload the compiled .app file
# - Monitor installation

# 5. Verify deployment:
bash scripts/bc-verify-app.sh --environment "Production"
```

### Dev Mode vs PTE Mode

**Dev Mode** (Sandbox Only):
- Single-step publish and sync
- Immediate schema updates (seconds)
- Perfect for rapid development
- Same as VS Code F5 debugging
- Command: `bc_publish_sandbox`
- **Use for**: Daily development iteration

**PTE Mode** (Sandbox & Production):
- 4-step automated workflow with monitoring
- Asynchronous installation (2-5 minutes)
- **NEW**: Real-time status tracking
- **NEW**: Auto-fetches company ID
- Formal deployment process
- Required for production
- Commands: `bc_publish_sandbox_pte`, `bc_publish_production`
- **Use for**: Pre-production testing and live deployments

**Key Differences:**

| Feature | Dev Mode | PTE Mode |
|---------|----------|----------|
| **Speed** | 5-15 seconds | 2-5 minutes |
| **Monitoring** | Immediate | Real-time polling |
| **Environment** | Sandbox only | Sandbox & Production |
| **Process** | Single API call | 4-step workflow |
| **Company ID** | Not required | Auto-fetched if needed |
| **Use Case** | Development | Testing & Production |

### Documentation

Comprehensive guides available:

- **[Publishing Guide](docs/PUBLISHING.md)** - Complete publishing documentation
- **[Environments Guide](docs/ENVIRONMENTS.md)** - Environment configuration
- **[Authentication Guide](docs/AUTHENTICATION.md)** - OAuth and Basic Auth setup

## Business Central App Development

### App Structure

Each Business Central app should have the following structure:

```
YourApp/
├── app.json                    # Required: App manifest
├── *.al                        # AL source code files
└── .alpackages/                # Dependencies (Microsoft BC packages)
    ├── Microsoft_Application_*.app
    ├── Microsoft_Base Application_*.app
    └── Microsoft_System_*.app
```

### app.json Configuration

Example `app.json`:

```json
{
  "id": "your-app-guid",
  "name": "YourAppName",
  "publisher": "Your Publisher Name",
  "version": "1.0.0.0",
  "platform": "1.0.0.0",
  "application": "26.0.0.0",
  "idRanges": [
    {
      "from": 50100,
      "to": 50149
    }
  ],
  "dependencies": [],
  "runtime": "15.0"
}
```

### Dependencies

Dependencies should be placed in each app's `.alpackages` folder:
- Download required Microsoft packages from your BC environment
- Copy `.app` files to `.alpackages/`
- The compiler will automatically reference them during compilation

## Troubleshooting

### Common Issues

**"No app.json files found"**
- Verify `BC_APPS_ROOT` points to the correct directory
- Ensure your app folders contain `app.json` files
- Check file permissions

**"Compilation failed" for specific app**
- Check for syntax errors in AL code
- Verify all dependencies are in `.alpackages/`
- Ensure `app.json` configuration is valid
- Check BC version compatibility

**"AL Compiler not found"**
- Verify the compiler exists in `scripts/compiler/extension/bin/{os}/`
- On Linux/macOS, ensure the compiler has execute permissions
- Try running: `chmod +x scripts/compiler/extension/bin/{os}/alc`

**Windows path issues**
- The script automatically converts Unix paths to Windows paths
- If issues persist, use absolute Windows paths in `.env`

### Getting Help

- Check the [compile.md](.claude/commands/compile.md) documentation
- Review compilation output for specific error messages
- Verify your BC version matches the compiler version
- Ensure all dependencies are compatible with your target BC version

## Development Workflow

### Typical Development Cycle

1. **Write AL Code**: Create or modify `.al` files in your app folder
2. **Compile**: Run `/compile` to build all apps
3. **Review**: Check compilation summary for any errors
4. **Fix Issues**: Address any compilation errors
5. **Deploy**: Upload compiled `.app` files to your BC environment

### Best Practices

- **Version Control**: Keep your `.app` files out of git (already in `.gitignore`)
- **Dependencies**: Document required dependencies in each app's README
- **Testing**: Compile regularly to catch errors early
- **Naming**: Use descriptive names in `app.json` for better output clarity
- **Structure**: Keep related apps in separate folders under `BC_APPS_ROOT`

## Platform Support

### Windows
- Compiler: `scripts/compiler/extension/bin/win32/alc.exe`
- Tested on Windows 10/11 with Git Bash, MSYS2, and native Command Prompt

### Linux
- Compiler: `scripts/compiler/extension/bin/linux/alc`
- Tested on Ubuntu 20.04+ and Debian-based distributions
- Requires: bash, grep, sed, find, du

### macOS
- Compiler: `scripts/compiler/extension/bin/darwin/alc`
- Tested on macOS 11 (Big Sur) and later
- Requires: bash (system default or brew-installed)

## Technical Details

### Compiler

The AL compiler is extracted from Microsoft's official AL Language extension for VS Code and included in this repository for convenience. It supports:
- Business Central AL compilation
- Dependency resolution via package cache
- Cross-platform operation
- Standard compiler flags

### Script Features

The [compile.sh](scripts/compile.sh) script includes:
- OS detection and automatic compiler selection
- `.env` file parsing with comment support
- Recursive app.json discovery using `find`
- JSON parsing using `grep` and `sed`
- Path conversion for Windows compatibility
- Error handling and exit codes
- Colored output and progress indicators

### Publishing Implementation

#### Dev Mode Publishing (bc-publish-sandbox-dev.sh)
- **HTTP Compliance**: Uses proper CRLF (`\r\n`) line endings in multipart/form-data
- **Binary Upload**: Uploads .app files with `application/octet-stream` content type
- **Fast Deployment**: Single POST to `/dev/apps` endpoint with immediate schema sync
- **Error Handling**: Validates response codes (200/201/204) and provides detailed error messages

#### PTE Mode Publishing (bc-publish-sandbox-pte.sh)
**4-Step Microsoft-Compliant Workflow:**

1. **POST /extensionUpload** - Create or reuse deployment resource
   - Auto-fetches company ID via GET `/api/v2.0/companies` if not configured
   - Smart resource reuse prevents "entity already exists" conflicts
   - Configures schedule ("Current version") and schema sync mode ("Add")

2. **PATCH /extensionUpload({id})/extensionContent** - Upload binary content
   - Streams .app file as `application/octet-stream`
   - Uses `--data-binary` for proper binary handling
   - Validates upload success before proceeding

3. **POST /extensionUpload({id})/Microsoft.NAV.upload** - Trigger installation
   - OData bound action invocation
   - Includes Content-Length: 0 header for empty POST
   - Queues extension for asynchronous installation

4. **GET /extensionDeploymentStatus** - Monitor until complete
   - Polls every 10 seconds (configurable)
   - Maximum 30 attempts (5 minutes timeout)
   - Detects status: `InProgress`, `Completed`, `Failed`, `Scheduled`
   - Exit codes: 0 (success), 1 (failure), 2 (timeout)

**Key Technical Implementations:**
- **CRLF Compliance**: All HTTP requests use proper `\r\n` line endings via `printf`
- **Resource Management**: GET before POST to reuse existing extensionUpload records
- **Error Recovery**: Comprehensive error handling with actionable recommendations
- **Status Polling**: Exponential backoff optional, fixed 10s interval for predictability
- **JSON Parsing**: Robust `grep`/`sed` extraction of systemId, status, and metadata

### API Endpoints Used

**Business Central APIs:**
- `/v2.0/{env}/dev/apps` - Dev mode publishing
- `/v2.0/{env}/api/microsoft/automation/v2.0/companies({id})/extensionUpload` - PTE upload
- `/v2.0/{env}/api/microsoft/automation/v2.0/companies({id})/extensionDeploymentStatus` - Status monitoring
- `/v2.0/{env}/api/v2.0/companies` - Company ID auto-fetch
- `/admin/v2.25/applications/businesscentral/environments/{env}/apps` - Verification

**Authentication:**
- OAuth 2.0 with client credentials flow (online/SaaS)
- NavUserPassword basic authentication (local/Docker)
- Token caching with 1-hour expiration

## License

This repository is provided as-is for Business Central development purposes. The AL compiler belongs to Microsoft Corporation and is subject to their licensing terms.

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## Acknowledgments

- Microsoft for the AL Language compiler
- Anthropic for Claude Code
- The Business Central developer community

---

**Happy Coding!** If you encounter any issues or have suggestions, please open an issue on the repository.
