---
allowed-tools: Bash(*)
description: Compile Business Central app(s)
---

# Business Central Multi-App Compilation Command

## Purpose
This command compiles Business Central AL extensions using the AL compiler. It automatically discovers and compiles all BC apps in the configured directory.

## How It Works

### Multi-App Support
The compilation script automatically finds and compiles ALL Business Central apps within the configured root directory:
- Recursively searches for all `app.json` files under the apps root directory
- Compiles each app independently in its own folder
- Generates a summary report showing success/failure for each app
- Continues compilation even if individual apps fail

### Configuration
The script reads configuration from the `.env` file in the repository root:
- **BC_APPS_ROOT**: Root path to search for BC apps (default: `BC`)
- **BC_COMPILER_PATH**: Custom compiler path (optional)
- **BC_PACKAGE_CACHE**: Custom package cache path (optional, defaults to per-app `.alpackages`)
- **BC_OUTPUT_DIR**: Custom output directory (optional, defaults to app folder)

### Compilation Process
1. Run the `.claude/scripts/compile.sh` script
2. The script will:
   - Load configuration from `.env` file
   - Detect the operating system (Windows/Linux/macOS)
   - Find all `app.json` files recursively
   - Make the compiler executable if needed (Linux/macOS)
   - Remove existing compiled versions
   - Compile each app using the AL compiler
   - Generate a summary report

### Output
Each app is compiled to:
- Default: `{app-folder}/{app-name}.app` (name from app.json)
- Custom: `{BC_OUTPUT_DIR}/{app-name}.app` (if BC_OUTPUT_DIR is set)

## Usage

### Basic Usage
Simply run the compile command - it will use defaults from `.env`:
```bash
bash .claude/scripts/compile.sh
```

### Advanced Usage
Override configuration with command-line parameters:
```bash
bash .claude/scripts/compile.sh --appsroot "path/to/apps" --compiler "path/to/compiler"
```

Available parameters:
- `--appsroot PATH`: Root path to search for BC apps
- `--compiler PATH`: Path to compiler folder
- `--packagecache PATH`: Global package cache folder
- `--output PATH`: Custom output directory
- `--help`: Show help message

## Examples

### Single App (Default)
With default `.env` configuration, compiles the app in the `BC` folder:
- Searches: `BC/app.json`
- Output: `BC/BC.app`

### Multiple Apps
If you have multiple apps under `BC`:
```
BC/
├── AppOne/
│   └── app.json
└── AppTwo/
    └── app.json
```
The script will find and compile both apps:
- Output: `BC/AppOne/AppOne.app` and `BC/AppTwo/AppTwo.app`

### Custom Apps Root
Update `.env` to search a different directory:
```
BC_APPS_ROOT=MyApps
```
Then all apps under `MyApps/` will be discovered and compiled.

## Notes
- The script is backward compatible - works with single app or multiple apps
- Compilation continues even if one app fails, allowing you to see all errors
- Dependencies should be placed in each app's `.alpackages` folder
- The AL compiler is already included in `.claude/scripts/compiler/` for all platforms
