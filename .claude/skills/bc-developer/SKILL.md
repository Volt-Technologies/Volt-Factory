---
name: bc-developer
description: Complete Business Central AL development toolkit. Includes AL code development, compilation using embedded alc.exe, publishing to BC environments (online/local Docker), automated testing, and container management. Uses @volt-technologies/volt-bc-tools package.
license: MIT
compatibility: Windows required for local Docker. Node.js 18+ and @volt-technologies/volt-bc-tools package.
allowed-tools: Bash(npx:*) Bash(node:*) Read Edit Write Glob Grep mcp__objid__allocate_id mcp__objid__config mcp__objid__analyze_workspace mcp__ide__getDiagnostics
---

# BC Developer Skill

Complete Business Central AL development toolkit using `@volt-technologies/volt-bc-tools`.

## Capabilities

| Area | Description |
|------|-------------|
| **AL Development** | Write tables, pages, codeunits, reports, enums following AL guidelines |
| **Compilation** | Compile AL code using embedded alc.exe compiler with LinterCop |
| **Publishing** | Deploy apps to BC Online (SaaS) or local Docker containers |
| **Testing** | Execute automated tests via OData or Docker |
| **Containers** | Create and manage BC Docker containers for development |

## Quick Start

### Compile All Apps
```bash
npx ts-node .claude/skills/bc-developer/scripts/compile.ts --all
```

### Publish to Environment
```bash
npx ts-node .claude/skills/bc-developer/scripts/publish.ts "./output/App.app"
```

### Run Tests
```bash
npx ts-node .claude/skills/bc-developer/scripts/run-tests.ts --range "70200..70249"
```

### Manage Container
```bash
npx ts-node .claude/skills/bc-developer/scripts/container.ts create --name "bc-feature"
```

## Scripts Reference

| Script | Purpose | Example |
|--------|---------|---------|
| `compile.ts` | Compile AL apps | `--all` or `--app-path "./BC"` |
| `publish.ts` | Publish .app files | `"./output/App.app" --sync-mode ForceSync` |
| `run-tests.ts` | Execute tests | `--range "70200..70249"` |
| `container.ts` | Docker management | `create --name "bc-test"` |
| `verify.ts` | Verify installation | `--app-name "My App"` |

## Embedded Compiler

The skill includes a complete AL compiler in `scripts/compiler/`:

```
scripts/compiler/extension/bin/
├── win32/alc.exe        # Windows compiler
└── Analyzers/           # LinterCop, CodeCop, UICop, etc.
```

## Configuration

All scripts read from `.env` at the repository root:

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

## Development Workflow

### 1. Write AL Code

Follow guidelines in `.claude/al-guidelines/`:
- Use VOL prefix for custom objects
- Tables singular, list pages plural
- Always create List + Card pages
- Update permissionset with new objects

### 2. Allocate Object IDs

**MANDATORY**: Use `mcp__objid__allocate_id` before creating objects:

```
mode: "reserve"
appPath: "C:\path\to\BC"
object_type: "table"
preferred_range: {from: 70100, to: 70199}
object_metadata: {
  name: "VOL Product Variant",
  file: "src/ProductVariants/VOLProductVariant.Table.al"
}
```

### 3. Compile

```bash
npx ts-node .claude/skills/bc-developer/scripts/compile.ts --all
```

### 4. Publish

```bash
npx ts-node .claude/skills/bc-developer/scripts/publish.ts "./output/App.app"
```

### 5. Test

```bash
npx ts-node .claude/skills/bc-developer/scripts/run-tests.ts --range "70200..70249"
```

### 6. Iterate

If tests fail, fix code and repeat from step 3.

## Object Creation Pattern

For each new table:

1. **Allocate IDs** for table, list page, card page
2. **Create table** with LookupPageId, DrillDownPageId
3. **Create list page** with CardPageId
4. **Create card page**
5. **Update permissionset** with all objects

```al
table 70100 "VOL Product Variant"
{
    Caption = 'Product Variant';
    DataClassification = CustomerContent;
    LookupPageId = "VOL Product Variants";
    DrillDownPageId = "VOL Product Variants";
}

page 70100 "VOL Product Variants"
{
    PageType = List;
    SourceTable = "VOL Product Variant";
    CardPageId = "VOL Product Variant Card";
}

page 70101 "VOL Product Variant Card"
{
    PageType = Card;
    SourceTable = "VOL Product Variant";
}
```

## LinterCop Rules (Critical)

| Rule | Severity | Description |
|------|----------|-------------|
| LC0001 | Warning | FlowFields MUST have `Editable = false` |
| LC0003 | Warning | Use object names, NOT IDs |
| LC0040 | Info | Always specify RunTrigger parameter |
| LC0081 | Info | Use `IsEmpty()` not `Count() > 0` |

## Troubleshooting

### Compilation Errors

**Missing symbols**: Download symbols or check .alpackages folder

**AL0118 - Member not found**: Check field name spelling, verify dependencies

### Publishing Errors

**Authentication failed**: Verify credentials in .env

**Schema sync conflict**: Use `--sync-mode ForceSync`

### Container Errors

**Docker not running**: Start Docker Desktop first

**Container won't start**: Check logs with `docker logs <name>`

## File Structure

```
scripts/
├── compiler/           # Embedded AL compiler
│   └── extension/bin/  # alc.exe and analyzers
├── compile.ts          # Compilation script
├── publish.ts          # Publishing script
├── run-tests.ts        # Test execution
├── container.ts        # Container management
├── verify.ts           # App verification
└── README.md           # Script documentation
```

## Package Dependency

This skill requires `@volt-technologies/volt-bc-tools`:

```bash
npm install @volt-technologies/volt-bc-tools
```

The package provides:
- `ALCompiler` - Compile AL code
- `AppPublisher` - Publish apps
- `TestRunner` - Run tests
- `ContainerManager` - Manage Docker containers
- `EnvLoader` - Load .env configuration
