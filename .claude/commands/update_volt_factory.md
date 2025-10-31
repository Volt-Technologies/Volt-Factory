---
allowed-tools: Bash(git:*)
description: Update from Volt Factory template repository
---

# Update Volt Factory Command

## Purpose
This command synchronizes updates from the Volt-Factory template repository into the current repository. It's designed for repositories that were created from the Volt-Factory template and need to pull in upstream changes.

## How It Works

### Template Sync Process
The command performs the following steps:
1. Reads the template repository URL from configuration
2. Adds the template repository as a git remote (if not already added)
3. Fetches the latest changes from the template repository
4. Rebases the current branch onto the template's main branch
5. Provides guidance on resolving any merge conflicts

### Configuration
The template repository URL is configured using the `VOLT_FACTORY_TEMPLATE_REPO` environment variable in `.claude/settings.local.json`:
```json
{
  "env": {
    "VOLT_FACTORY_TEMPLATE_REPO": "https://github.com/grvolttechnologies/Volt-Apparel"
  }
}
```

### Sync Strategy
The command uses git rebase to maintain a clean, linear history:
- Creates a remote named `volt-factory-template` (if it doesn't exist)
- Fetches from the template repository
- Rebases your current branch onto `volt-factory-template/main`
- Preserves your local commits on top of template updates

## Usage

### Basic Usage
Simply run the update command:
```
/update_volt_factory
```

The command will:
1. Check for the Volt Factory template repository URL in configuration
2. Perform the update automatically
3. Report any conflicts that need manual resolution

### Handling Conflicts
If conflicts occur during rebase:
1. Review the conflicting files reported by git
2. Edit the files to resolve conflicts
3. Stage the resolved files: `git add <file>`
4. Continue the rebase: `git rebase --continue`
5. Or abort the rebase: `git rebase --abort`

### When to Update
Use this command to:
- Pull in new features added to the Volt-Factory template
- Get updates to agents, commands, or workflows
- Synchronize configuration changes from the template
- Update shared scripts and utilities

## Configuration Examples

### Using settings.local.json (Recommended)
Add to `.claude/settings.local.json`:
```json
{
  "env": {
    "VOLT_FACTORY_TEMPLATE_REPO": "https://github.com/grvolttechnologies/Volt-Apparel"
  },
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "SlashCommand(/update_volt_factory)"
    ]
  }
}
```

## Safety Notes
- The command uses `git rebase`, which rewrites history
- Always commit or stash your local changes before updating
- If you have unpushed commits, they will be rebased on top of template changes
- You can always abort the rebase with `git rebase --abort`
- Consider creating a backup branch before updating: `git branch backup-before-update`

## Troubleshooting

### Template URL Not Found
If you see "Template repository URL not configured":
1. Add the URL to `.claude/settings.local.json` or set the environment variable
2. Ensure the JSON syntax is valid
3. Restart Claude Code if needed

### Permission Denied
If you get authentication errors:
1. Ensure you have access to the template repository
2. Configure git credentials (SSH key or personal access token)
3. Test access: `git ls-remote <template-url>`

### Conflicts Every Time
If you consistently get conflicts in the same files:
1. Consider whether those files should be template-managed
2. You might want to exclude certain files from the template
3. Or maintain them separately in your repository

## Example Workflow

### Initial Setup
```bash
# Clone your repository from the template
git clone https://github.com/yourorg/your-repo

# Configure the template URL
# Edit .claude/settings.local.json to add VOLT_FACTORY_TEMPLATE_REPO

# First update
/update_volt_factory
```

### Regular Updates
```bash
# Commit your work
git add .
git commit -m "My feature work"

# Update from Volt Factory template
/update_volt_factory

# If no conflicts, push your changes
git push
```

### With Conflicts
```bash
# Update from template
/update_volt_factory

# See conflicts
git status

# Resolve each conflict
# Edit files, then:
git add <resolved-file>

# Continue rebase
git rebase --continue

# Push (may need --force-with-lease if rebased)
git push --force-with-lease
```

## Notes
- This command is designed for repositories created from Volt-Factory template
- The template repository remains the source of truth for shared components
- Your local customizations are preserved and rebased on top
- Regular updates help prevent large merge conflicts
- The `volt-factory-template` remote is automatically managed

---

# Implementation Instructions

When this command is invoked, perform the following steps:

1. **Check Configuration**:
   - Read the `VOLT_FACTORY_TEMPLATE_REPO` environment variable
   - If not found, inform the user that the template repository URL is not configured
   - Provide instructions on how to configure it in `.claude/settings.local.json`

2. **Verify Git Status**:
   - Run `git status` to check for uncommitted changes
   - If there are uncommitted changes, warn the user and recommend committing or stashing them first
   - Ask the user if they want to continue anyway

3. **Check Current Branch**:
   - Run `git branch --show-current` to get the current branch name
   - Store this for later use in the rebase

4. **Add Template Remote**:
   - Run `git remote -v` to check if `volt-factory-template` remote exists
   - If not, run `git remote add volt-factory-template $VOLT_FACTORY_TEMPLATE_REPO`
   - If it exists but URL differs, run `git remote set-url volt-factory-template $VOLT_FACTORY_TEMPLATE_REPO`

5. **Fetch from Template**:
   - Run `git fetch volt-factory-template main`
   - This downloads the latest changes from the template repository

6. **Perform Rebase**:
   - Run `git rebase volt-factory-template/main`
   - Capture the output

7. **Handle Results**:
   - If rebase succeeds:
     - Inform the user that the update completed successfully
     - Show a summary of changes with `git log --oneline HEAD@{1}..HEAD`
   - If rebase fails with conflicts:
     - List the conflicting files
     - Provide clear instructions on how to resolve conflicts
     - Explain the commands: `git add <file>`, `git rebase --continue`, `git rebase --abort`
   - If rebase fails for other reasons:
     - Show the error message
     - Suggest running `git rebase --abort` to return to the original state

8. **Post-Update Guidance**:
   - Remind the user to test their code after updating
   - If they have unpushed commits, inform them they may need to force push with `git push --force-with-lease`
   - Warn about force pushing and suggest they coordinate with their team

## Example Execution Flow

```bash
# Step 1: Check environment
echo "Template URL: $VOLT_FACTORY_TEMPLATE_REPO"

# Step 2: Check status
git status

# Step 3: Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Step 4: Add/update remote
git remote add volt-factory-template "$VOLT_FACTORY_TEMPLATE_REPO" 2>/dev/null || \
git remote set-url volt-factory-template "$VOLT_FACTORY_TEMPLATE_REPO"

# Step 5: Fetch
git fetch volt-factory-template main

# Step 6: Rebase
git rebase volt-factory-template/main

# Step 7: Check result
if [ $? -eq 0 ]; then
  echo "Update completed successfully!"
  git log --oneline HEAD@{1}..HEAD
else
  echo "Conflicts detected. Please resolve them."
  git status
fi
```
