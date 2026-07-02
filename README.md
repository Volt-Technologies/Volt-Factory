# Volt Factory

Business Central AL development project by Volt Technologies, powered by Claude Code.

## Prerequisites

### 1. Install Node.js

Download and install **Node.js 18+** from [nodejs.org](https://nodejs.org/).

Verify the installation:

```bash
node --version
npm --version
```

### 2. Install the Volt Marketplace and Plugins

This project uses the **Volt Technologies Claude Code Marketplace** for BC development tools and AI agents.

> **Access required:** You need access to the [Volt-Technologies](https://github.com/Volt-Technologies/claude-code-marketplace/) GitHub organization. Request access from your team lead if you don't have it.

#### a) Authenticate with GitHub

```bash
gh auth login
```

#### b) Add the marketplace

Inside Claude Code, run:

```
/plugin marketplace add Volt-Technologies/claude-code-marketplace
```

#### c) Install the plugins

```
/plugin install bc-tools@volt-bc-tools
/plugin install bc-tech-agents@volt-bc-tools
```

- **bc-tools** provides the core skill: symbol download, compilation, publishing, testing, and container management.
- **bc-tech-agents** provides four specialized AI agents for BC development (`bc-al-developer`, `bc-app-compiler`, `bc-test-runner`, `bc-docker-container-creator`).

#### d) Keep plugins up to date

```
/plugin marketplace update
```

For full details on the marketplace, see the [claude-code-marketplace README](https://github.com/Volt-Technologies/claude-code-marketplace).

### 3. Install the Code Spell Checker Extension

This project uses [cSpell settings](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-cspell-bundled-dictionaries) in `.vscode/settings.json` to flag misspellings in AL code and comments.

#### a) Install from the Marketplace

Open the [Code Spell Checker (cSpell Bundled Dictionaries)](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-cspell-bundled-dictionaries) page and click **Install**, or install it from within VS Code:

1. Open the Extensions view (`Ctrl+Shift+X`).
2. Search for `streetsidesoftware.code-spell-checker-cspell-bundled-dictionaries`.
3. Click **Install**.

Or install it from the command line:

```bash
code --install-extension streetsidesoftware.code-spell-checker-cspell-bundled-dictionaries
```

#### b) Reload VS Code

Reload the window (`Ctrl+Shift+P` → `Developer: Reload Window`) so the extension picks up the `cSpell.words` list already configured for this project.

Opening the `BC` or `BC Test` folder will also prompt you to install this extension automatically, since it's listed under recommended extensions.

### 4. Configure the `.env` File

Copy the `.env` file template and fill in your tenant credentials. The key fields to configure are:

```env
# Azure AD Tenant
BC_TENANT_ID=your-tenant-guid
BC_CLIENT_ID=your-app-client-id
BC_CLIENT_SECRET=your-app-client-secret

# Environment
BC_ENVIRONMENT_NAME=your-environment-name
BC_COMPANY_ID=your-company-guid
```

Ask your team lead for the correct tenant ID, client credentials, and environment name for your project.
