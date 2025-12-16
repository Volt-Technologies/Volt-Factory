# Volt Factory

A Business Central AL development framework built on Claude Code. Provides streamlined workflows for coding, compiling, publishing, and testing BC extensions.

## Overview

Volt Factory is a technical development environment for Microsoft Dynamics 365 Business Central AL development. It automates the complete development cycle:

- **AL Code Development** - Write production-quality AL code following enforced standards
- **Compilation** - Multi-app cross-platform compilation
- **Publishing** - Deploy to sandbox or production environments
- **Testing** - Automated test execution with comprehensive reporting

## Repository Structure

```
Volt-Factory/
├── .env                              # Environment configuration
├── .env.example                      # Configuration template
├── README.md                         # This file
│
├── .claude/                          # Claude Code configuration
│   ├── CLAUDE.md                     # Main agent instructions
│   │
│   ├── agents/                       # Specialized sub-agents
│   │   ├── bc-app-compiler.md        # Compilation and publishing
│   │   └── bc-test-runner.md         # Test execution
│   │
│   ├── commands/                     # Slash commands
│   │   ├── bc_compile.md             # /bc_compile
│   │   ├── bc_publish_sandbox.md     # /bc_publish_sandbox
│   │   ├── bc_workflow_sandbox.md    # /bc_workflow_sandbox
│   │   └── ...
│   │
│   ├── scripts/                      # Build and publish scripts
│   │   ├── compile.sh                # Cross-platform compilation
│   │   └── compiler/                 # AL compiler binaries
│   │
│   └── al-guidelines/                # AL coding standards (reference only)
│       ├── al-guidelines.instructions.md
│       ├── al-code-style.instructions.md
│       ├── al-naming-conventions.instructions.md
│       ├── BestPractices/
│       ├── patterns/
│       └── lintercop/
│
├── BC/                               # Main Business Central app
│   ├── app.json                      # App manifest
│   ├── src/                          # AL source code
│   └── .alpackages/                  # BC dependencies
│
└── BC Test/                          # Test app
    ├── app.json
    └── src/
```

## Quick Start

### Prerequisites

- Claude Code installed and configured
- Business Central environment (sandbox or production)
- Git for version control

### Setup

1. **Clone and configure**:
   ```bash
   git clone <repository-url> Volt-Factory
   cd Volt-Factory
   cp .env.example .env
   # Edit .env with your BC environment settings
   ```

2. **Compile**:
   ```
   /bc_compile
   ```

3. **Publish to sandbox**:
   ```
   /bc_publish_sandbox
   ```

4. **Complete workflow** (compile + publish + verify):
   ```
   /bc_workflow_sandbox
   ```

## Development Workflow

The mandatory workflow for any AL development:

1. **Code** - Write AL code following the guidelines
2. **Compile** - Use bc-app-compiler to compile (`/bc_compile`)
3. **Publish** - Deploy to BC (`/bc_publish_sandbox`)
4. **Test** - Write and run automated tests
5. **Verify** - Only done when all tests pass

If any step fails, fix the issues and restart from step 1.

## Available Commands

| Command | Description |
|---------|-------------|
| `/bc_compile` | Compile all BC apps |
| `/bc_publish_sandbox` | Publish to sandbox (dev mode) |
| `/bc_publish_sandbox_pte` | Publish to sandbox (PTE mode) |
| `/bc_workflow_sandbox` | Complete sandbox workflow |
| `/bc_verify` | Verify app installation |

## App Folder Structure

Organize AL objects by feature:

```
src/
├── [Feature A]/
│   ├── table/
│   ├── tableextension/
│   ├── page/
│   ├── pageextension/
│   └── codeunit/
├── [Feature B]/
│   └── ...
└── Common/
    └── permissionset/
```

## Environment Configuration

Key settings in `.env`:

```bash
# Apps directory
BC_APPS_ROOT=BC

# Deployment type: online or local
BC_DEPLOYMENT_TYPE=online

# Environment type: sandbox or production
BC_ENVIRONMENT_TYPE=sandbox

# OAuth credentials (for online/SaaS)
BC_TENANT_ID=your-tenant-id
BC_CLIENT_ID=your-client-id
BC_CLIENT_SECRET=your-secret
BC_ENVIRONMENT_NAME=Sandbox
```

## Important Notes

- Always update the permissionset before compiling
- Do not change file formats to fix compilation errors
- Do not remove dependencies from the Test app
- Download symbols if you get missing object errors
- Test Runner app must be installed in BC environments

## License

This repository is provided as-is for Business Central development. The AL compiler belongs to Microsoft Corporation.
