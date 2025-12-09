---
allowed-tools: Bash(git:*), Read, Edit
description: Update from Volt Factory template repository (auto-resolves conflicts and pushes)
---

# Update Volt Factory Command

## Purpose
This command synchronizes updates from the Volt-Factory template repository into the current repository. It's designed for repositories that were created from the Volt-Factory template and need to pull in upstream changes.

**Fully Automated**: This command handles everything end-to-end:
- ✅ Fetches template updates
- ✅ Rebases your commits on top of template changes
- ✅ Automatically resolves common conflicts (`.env`, command files)
- ✅ Safely force-pushes using `--force-with-lease`
- ✅ Reports completion status

Just run `/update_volt_factory` and it does the rest!

## How It Works

### Template Sync Process
The command performs the following steps:
1. Reads the template repository URL from configuration
2. Adds the template repository as a git remote (if not already added)
3. Fetches the latest changes from the template repository
4. Rebases the current branch onto the template's main branch
5. Automatically resolves common merge conflicts
6. Pushes changes to remote using `--force-with-lease` (safe force push)
7. Reports completion status and summary

### Configuration
The template repository URL is configured using the `VOLT_FACTORY_TEMPLATE_REPO` environment variable in `.claude/settings.local.json`:
```json
{
  "env": {
    "VOLT_FACTORY_TEMPLATE_REPO": "https://github.com/grvolttechnologies/Volt-Factory"
  }
}
```

### Sync Strategy
The command uses git rebase to maintain a clean, linear history:
- Creates a remote named `volt-factory-template` (if it doesn't exist)
- Fetches from the template repository
- Rebases your current branch onto `volt-factory-template/main`
- Preserves your local commits on top of template updates
- Automatically resolves known conflicts
- Force-pushes safely using `--force-with-lease`

## Usage

### Basic Usage
Simply run the update command:
```
/update_volt_factory
```

The command will:
1. Check for the Volt Factory template repository URL in configuration
2. Perform the update automatically via git rebase
3. Automatically resolve common conflicts (`.env`, `.claude/commands/update_volt_factory.md`)
4. Push changes to remote with `--force-with-lease` if needed
5. Report completion status

### Automatic Conflict Resolution
The command automatically handles common conflicts:

**Known Conflicts**:
- `.claude/commands/update_volt_factory.md`: Always accepts template version and updates URLs
- `.env`: Removes `VOLT_FACTORY_TEMPLATE_REPO` if present (now managed in `.claude/settings.local.json`)

**Unknown Conflicts**:
- For other files, the command will analyze and attempt resolution
- Documentation/config files: Prefers template version
- User-specific data: Preserves your version
- Complex conflicts: Will ask for your guidance

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
    "VOLT_FACTORY_TEMPLATE_REPO": "https://github.com/grvolttechnologies/Volt-Factory"
  },
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Read",
      "Edit",
      "SlashCommand(/update_volt_factory)"
    ]
  }
}
```

## Safety Notes
- The command uses `git rebase`, which rewrites history
- The command automatically uses `git push --force-with-lease` (safer than `--force`)
- Always commit or stash your local changes before updating (command will warn you)
- Your commits will be rebased on top of template updates
- You can abort anytime with `git rebase --abort` if something goes wrong
- Consider creating a backup branch before updating: `git branch backup-before-update`
- `--force-with-lease` prevents accidental overwrites if someone else pushed to the branch

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

# Update from Volt Factory template (handles conflicts and push automatically)
/update_volt_factory

# That's it! The command handles:
# - Fetching template updates
# - Rebasing your commits
# - Resolving common conflicts
# - Force pushing with --force-with-lease
```

### Advanced: Manual Conflict Resolution
If the command encounters an unknown conflict it can't resolve automatically:
```bash
# The command will inform you of the conflict and pause

# Review the conflict
git status

# Resolve manually by editing the file
# Then tell the command to continue

# Or abort the entire update
git rebase --abort
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
     - Show a summary of changes with `git log --oneline --graph --all -10`
     - Skip to step 9 (Force Push)
   - If rebase fails with conflicts:
     - Proceed to step 8 (Automatic Conflict Resolution)
   - If rebase fails for other reasons:
     - Show the error message
     - Suggest running `git rebase --abort` to return to the original state
     - STOP execution

8. **Automatic Conflict Resolution**:
   - Read the conflicting files using `git status`
   - For each conflict, apply resolution strategy:

   **Common Conflict: `.claude/commands/update_volt_factory.md`**
   - This file often conflicts when configuration approaches differ between template versions
   - Resolution strategy: ALWAYS accept the template version (theirs) and update URLs
   - Read the file to find conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
   - Remove all conflict markers
   - Keep the template's version (between `=======` and `>>>>>>>`)
   - Replace any repository-specific URLs with the correct template URL
   - Ensure all references to `VOLT_FACTORY_TEMPLATE_REPO` point to "https://github.com/grvolttechnologies/Volt-Factory"

   **Common Conflict: `.env`**
   - This file may conflict if older versions had `VOLT_FACTORY_TEMPLATE_REPO` in `.env`
   - Resolution strategy: ALWAYS accept the template version (remove VOLT_FACTORY_TEMPLATE_REPO from .env)
   - Read the file to find conflict markers
   - Remove all conflict markers and the VOLT_FACTORY_TEMPLATE_REPO section
   - Keep only the Business Central and Azure DevOps configuration from template

   **Unknown Conflicts**:
   - For any other conflicting files, read the file and analyze the conflict
   - If it's a documentation or configuration file, prefer the template version
   - If it contains user-specific data (credentials, environment names), preserve user version
   - When uncertain, show the conflict to the user and ask for guidance

   - After resolving all conflicts:
     - Stage all resolved files: `git add <resolved-files>`
     - Continue the rebase: `git rebase --continue`
     - Verify the rebase completed successfully
     - Show final status with `git status`

9. **Force Push to Remote**:
   - After successful rebase, check if branch has diverged from remote
   - Run `git status` to see if branch is ahead/diverged
   - If the branch has diverged or is ahead:
     - Inform the user that force push is required due to rebase
     - Execute: `git push --force-with-lease`
     - Verify push succeeded
     - Show final status: `git status`
   - If branch is not diverged:
     - Execute normal push: `git push`

10. **Post-Update Summary**:
    - Display success message
    - List the conflicts that were automatically resolved
    - Show the current branch status
    - Remind the user to test their code after updating
    - Note that the repository is now synchronized with the Volt-Factory template

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

# Step 7: Handle conflicts automatically
if [ $? -ne 0 ]; then
  # Check for known conflicts
  CONFLICTS=$(git diff --name-only --diff-filter=U)

  # Resolve .claude/commands/update_volt_factory.md
  if echo "$CONFLICTS" | grep -q "update_volt_factory.md"; then
    # Read file, remove conflict markers, keep template version
    # Update URLs to point to Volt-Factory
    git add .claude/commands/update_volt_factory.md
  fi

  # Resolve .env
  if echo "$CONFLICTS" | grep -q "^.env$"; then
    # Remove conflict markers and VOLT_FACTORY_TEMPLATE_REPO section
    git add .env
  fi

  # Continue rebase
  git rebase --continue
fi

# Step 8: Force push (safe)
git status
if git status | grep -q "have diverged"; then
  git push --force-with-lease
else
  git push
fi

# Step 9: Show summary
echo "Update completed successfully!"
git log --oneline --graph --all -10
git status
```
