---
allowed-tools: Bash(*)
description: Start the Serena UVX MCP server for AL development
---

# Serena UVX MCP Server Command

## Purpose
This command starts the Serena Model Context Protocol (MCP) server, which provides enhanced AL (Application Language) development capabilities for Business Central within Claude Code.

## What is Serena?

Serena is an MCP server specifically designed for Microsoft Dynamics 365 Business Central AL development. It provides:

- **AL Object Search**: Search for AL objects (tables, pages, codeunits, etc.) across your codebase
- **Object Definitions**: Get detailed definitions of AL objects including fields, methods, and properties
- **Code References**: Find where AL objects and methods are used throughout your projects
- **Symbol Navigation**: Navigate AL symbols and understand object relationships
- **Package Information**: Query AL package dependencies and their contents

## How It Works

### UVX Tool Runner
The command uses `uvx` (Universal Virtual eXecutor) to run Serena directly from its GitHub repository without requiring a local installation. This ensures you always have access to the latest version.

### MCP Integration
Once started, Serena runs as an MCP server that Claude Code can communicate with to provide AL-specific development assistance.

## Usage

### Starting the Server
```bash
uvx --from git+https://github.com/SShadowS/serena serena start-mcp-server
```

### What Happens
1. UVX fetches the latest Serena from GitHub
2. Serena initializes the MCP server
3. The server listens for Claude Code requests
4. AL development tools become available

## Prerequisites

1. **Python Environment**: Python 3.8+ installed
2. **UVX**: Universal Virtual eXecutor tool installed
3. **Git**: Required to fetch from GitHub repository
4. **AL Workspace**: A Business Central AL project in your workspace
5. **AL Extension**: Microsoft's AL Language extension for VS Code (`ms-dynamics-smb.al`)

### AL Extension Setup (Critical)

Serena requires the Microsoft AL extension to provide full AL language support. Configure it using one of these methods:

**Option 1: VS Code Installation (Recommended - Auto-detected)**
- Install the "AL Language" extension in VS Code
- Serena will automatically detect and use it

**Option 2: Environment Variable**
```bash
# Set AL_EXTENSION_PATH to your extension location
export AL_EXTENSION_PATH="/path/to/ms-dynamics-smb.al"
```

**Option 3: Working Directory**
- Place the `ms-dynamics-smb.al` folder in your working directory
- Serena will discover it automatically

**Verifying AL Extension:**
Check if the AL extension is installed:
```bash
code --list-extensions | grep ms-dynamics-smb.al
```

## Configuration

### Installing UVX
If you don't have UVX installed:

**On Windows (PowerShell):**
```powershell
pip install uvx
```

**On macOS/Linux:**
```bash
pip install uvx
```

### Verifying Installation
Check that UVX is available:
```bash
uvx --version
```

## MCP Server Capabilities

Once running, Serena provides these MCP tools with full AL Language Server Protocol (LSP) support via Microsoft's official AL extension:

### 1. AL Object Search
Search for AL objects by name or pattern:
- Tables
- Pages
- Codeunits
- Reports
- Queries
- XMLPorts
- Enums
- Interfaces
- And more...

### 2. Object Definitions & Navigation
Retrieve complete object definitions including:
- Field structures
- Method signatures
- Properties and attributes
- Relationships and dependencies
- Go-to-definition support (`al/gotodefinition`)
- Symbol navigation across your workspace

### 3. Reference Finding
Find all references to:
- Objects
- Methods
- Variables
- Fields
- Symbol usages across files

### 4. Package Management
Query information about:
- Installed AL packages
- Package dependencies
- Symbol information
- Extension references

### 5. Workspace Management
- Active workspace control (`al/setActiveWorkspace`)
- Automatic VS Code extension discovery
- Multi-project support
- Project-specific configurations

## Project Activation

After starting the Serena server, you need to activate your AL project workspace:

### Activating a Project
Tell Claude to activate your project:
- "Activate the project /path/to/my_bc_project"
- "Activate the project C:\Users\Usuario\Repositories\V\Volt-Factory"
- Or use a project name if configured

### Project Indexing (Recommended for Large Projects)
For faster symbol lookups in large AL workspaces, pre-index your project:

```bash
uvx --from git+https://github.com/SShadowS/serena serena project index
```

This creates a searchable index of all AL objects, improving performance significantly.

### Project Configuration
Serena automatically creates project-specific configuration:
- Location: `.serena/project.yml` in your workspace
- Auto-generated on first project activation
- Stores project-specific settings and preferences

## Common Scenarios

### Scenario 1: Starting Development Session
User: "Start the AL development tools"

**Steps:**
1. Run the Serena start command
2. Wait for server initialization
3. Activate the project workspace
4. Confirm MCP connection established
5. AL tools are now available

**Expected Output:**
```
Starting Serena MCP server...
✓ Server initialized
✓ Connected to workspace
✓ Project activated
✓ AL tools ready
```

### Scenario 2: Finding AL Objects
User: "Find all Customer-related tables"

**Steps:**
1. Ensure Serena is running
2. Use AL search to find Customer tables
3. Display results with object IDs and names
4. Provide navigation to definitions

### Scenario 3: Exploring Object Structure
User: "Show me the fields in the Customer table"

**Steps:**
1. Query object definition for Customer table
2. Parse and display field list
3. Show field properties (type, length, etc.)
4. Highlight key fields and relationships

## Troubleshooting

### Server Won't Start

**Problem:** UVX command fails or times out

**Solutions:**
- Check Python is installed: `python --version`
- Verify UVX installation: `pip install --upgrade uvx`
- Check internet connection (needed for GitHub access)
- Try running with verbose output: `uvx --verbose ...`

### MCP Connection Issues

**Problem:** Server starts but Claude Code can't connect

**Solutions:**
- Restart Claude Code
- Check if another MCP server is running on same port
- Review Claude Code MCP configuration
- Check server logs for errors

### AL Extension Not Found

**Problem:** Serena can't find the Microsoft AL extension

**Solutions:**
- Verify AL extension is installed in VS Code: `code --list-extensions | grep ms-dynamics-smb.al`
- Install if missing: Open VS Code → Extensions → Search "AL Language" → Install
- Set environment variable: `export AL_EXTENSION_PATH="/path/to/extension"`
- On Windows, extension is typically at: `%USERPROFILE%\.vscode\extensions\ms-dynamics-smb.al-*`
- On macOS/Linux: `~/.vscode/extensions/ms-dynamics-smb.al-*`

### Python Environment Issues

**Problem:** Python dependencies missing or conflicting

**Solutions:**
- Use a virtual environment: `python -m venv .venv`
- Activate environment before running UVX
- Install requirements if needed

### Git Access Issues

**Problem:** Can't fetch from GitHub repository

**Solutions:**
- Verify Git is installed: `git --version`
- Check GitHub access: `git ls-remote https://github.com/SShadowS/serena`
- Check firewall/proxy settings
- Try with SSH instead: `git+ssh://git@github.com/oraios/serena`

## Performance Considerations

### Startup Time
- First run: 10-30 seconds (downloads from GitHub)
- Subsequent runs: 5-15 seconds (cached)
- Workspace indexing: Varies by project size

### Resource Usage
- Memory: ~50-200 MB depending on workspace size
- CPU: Low when idle, moderate during indexing
- Disk: Minimal (cached packages only)

## Best Practices

### 1. Start Early
Start Serena at the beginning of your development session:
- Ensures AL tools are ready when needed
- Allows workspace indexing to complete
- Prevents delays during development

### 2. Keep Running
Leave Serena running throughout your session:
- Maintains indexed workspace state
- Faster responses to queries
- Better integration with Claude Code

### 3. Restart After Changes
Restart Serena after major workspace changes:
- Adding/removing AL packages
- Changing workspace structure
- Updating symbol references

### 4. Monitor Server Health
Watch for server status messages:
- Connection established
- Indexing complete
- Error conditions

## Integration with Development Flow

### Typical Development Session

1. **Start**: Open workspace in Claude Code
2. **Initialize**: Run `/bc_start_serena`
3. **Wait**: Allow server to initialize and index
4. **Develop**: Use AL tools throughout session
5. **Stop**: Server stops when Claude Code closes

### Working with Other Commands

Serena complements other BC commands:
- Use with `/bc_compile` for context-aware compilation
- Combine with `/bc_workflow_sandbox` for full development flow
- Reference AL objects while using `/bc_publish_sandbox`

## Advanced Usage

### Transport Options

**Default (stdio):** Standard input/output communication (recommended for Claude Code)
```bash
uvx --from git+https://github.com/SShadowS/serena serena start-mcp-server --transport stdio
```

**SSE Mode:** HTTP-based communication for manual server lifecycle control
```bash
uvx --from git+https://github.com/SShadowS/serena serena start-mcp-server --transport sse --port 9121
```
Then connect client to `http://localhost:9121/sse`

### Web Dashboard

Serena includes a built-in web dashboard (runs on localhost by default):
- View server logs in real-time
- Monitor MCP connections
- Control server shutdown
- Check server health status

The dashboard can be disabled in configuration if not needed.

### Custom Server Configuration

**Global Configuration:**
Edit global settings:
```bash
uv run serena config edit
```
Location: `~/.serena/serena_config.yml`

**Project-Specific Configuration:**
Location: `.serena/project.yml` (auto-generated per project)

**Local Installation:**
If you need to customize Serena settings:

1. Clone the repository locally:
   ```bash
   git clone https://github.com/SShadowS/serena
   cd serena
   ```

2. Modify configuration files as needed

3. Run from local copy:
   ```bash
   uvx --from . serena start-mcp-server
   ```

### Command-Line Arguments

Start server with additional options:

```bash
uvx --from git+https://github.com/SShadowS/serena serena start-mcp-server \
  --context ide-assistant \
  --project /path/to/project \
  --transport stdio
```

Available arguments:
- `--context <type>`: Adapt behavior for different clients (ide-assistant, codex, etc.)
- `--project <path_or_name>`: Auto-activate project at startup
- `--transport <stdio|sse>`: Communication protocol
- `--port <number>`: Port for SSE mode
- `--help`: View all available options

### Docker Usage (Experimental)

Run Serena in a Docker container:
```bash
docker run --rm -i --network host \
  -v C:\Users\Usuario\Repositories\V\Volt-Factory:/workspaces/projects \
  ghcr.io/oraios/serena:latest serena start-mcp-server --transport stdio
```

### Nix Support

For Nix users:
```bash
nix run github:oraios/serena -- start-mcp-server --transport stdio
```

### Running in Background
To run the server in the background (optional):

**On Windows (PowerShell):**
```powershell
Start-Process -NoNewWindow uvx -ArgumentList "--from", "git+https://github.com/SShadowS/serena", "serena", "start-mcp-server"
```

**On macOS/Linux:**
```bash
uvx --from git+https://github.com/SShadowS/serena serena start-mcp-server &
```

## Server Lifecycle

### Automatic Management
Claude Code typically manages the MCP server lifecycle:
- Starts when requested
- Maintains connection
- Stops when session ends

### Manual Control
You can manually control the server:
- Start: Run this command
- Stop: Ctrl+C in server terminal
- Restart: Stop and start again

## Notes
- Serena is maintained by the Oraios community
- The MCP server protocol ensures secure communication
- Server runs locally with no external data transmission
- AL symbols are indexed from your local workspace only
- Compatible with both single-app and multi-app workspaces
- Works with standard Business Central AL Language extension

## Related Commands
- `/bc_compile`: Compile AL apps with Serena context
- `/bc_workflow_sandbox`: Full development workflow
- `/bc_workflow_production`: Production deployment workflow

## Further Reading
- Serena GitHub (Original): https://github.com/SShadowS/serena
- Serena AL Fork: https://github.com/SShadowS/serena
- MCP Protocol: https://github.com/anthropics/model-context-protocol
- UVX Documentation: https://github.com/pypa/uvx
- Microsoft AL Language: https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al

## Support
For issues with Serena:
- GitHub Issues (Original): https://github.com/SShadowS/serena/issues
- GitHub Issues (AL Fork): https://github.com/SShadowS/serena/issues
- Check logs for error details
- Verify environment meets prerequisites
- Check web dashboard for server status
