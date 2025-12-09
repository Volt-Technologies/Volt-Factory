---
allowed-tools: Bash(*)
description: Complete sandbox workflow (compile + publish + verify)
---

# Business Central Sandbox Workflow Command

## Purpose
This command executes a complete end-to-end workflow for sandbox development: compile all apps, publish to sandbox environment, and verify installation. This is the most common workflow during active development.

## Workflow Steps

The complete sandbox workflow includes:

1. **Version Increment**: Automatically increment app version by 1 (e.g., 1.0.0.5 → 1.0.0.6)
2. **Compile**: Build all BC apps from source with new version
3. **Publish**: Deploy to sandbox using dev mode
4. **Verify**: Confirm successful installation

### IMPORTANT: Automatic Version Increment

**ALWAYS increment the version number before compilation:**
- Read the current version from `app.json`
- Increment the last digit by 1 (e.g., 1.0.0.5 → 1.0.0.6)
- Update `app.json` with the new version
- Then proceed with compilation

**Why this is required:**
- Business Central rejects duplicate package IDs with same version
- Dev mode does not automatically replace existing versions
- Manual version management prevents deployment conflicts
- Each deployment should have a unique version number

**Example:**
```bash
# Before workflow: Check current version
Current version in app.json: 1.0.0.5

# Step 1: Increment version
Update app.json: 1.0.0.5 → 1.0.0.6

# Step 2: Compile with new version
bc_compile

# Step 3: Publish
bc_publish_sandbox

# Step 4: Verify
bash scripts/bc-verify-app.sh
```

## How It Works

### Sequential Execution
The command runs steps in order:
- If compilation fails, publishing is skipped
- If publishing fails, verification is skipped
- Each step's output is displayed
- Final summary shows overall success/failure

### Dev Mode Default
Uses dev mode publishing for speed:
- Fast iteration during development
- Immediate schema synchronization
- Same as VS Code F5 debugging
- Perfect for sandbox environments

## Prerequisites

1. **Source code** ready to compile
2. **Authentication configured** in `.env`
3. **Sandbox environment** accessible
4. **Dependencies** in `.alpackages` folders

## Execution

### Run Complete Workflow
Simply run the four commands in sequence:

```bash
# Step 1: Increment version
bash scripts/bc-increment-version.sh BC

# Step 2: Compile all apps
bc_compile

# Step 3: Publish to sandbox
bc_publish_sandbox

# Step 4: Verify installation
bash scripts/bc-verify-app.sh
```

Or execute manually:

```bash
# Run all steps
bash scripts/bc-increment-version.sh BC && \
bash scripts/compile.sh && \
bash scripts/bc-publish-sandbox-dev.sh && \
bash scripts/bc-verify-app.sh
```

**Helper Script:**
The `bc-increment-version.sh` script automates version management:
- Reads current version from app.json
- Increments last digit by 1
- Updates app.json with new version
- Creates backup before modification
- Verifies the change was successful

## Common Scenarios

### Scenario 1: Regular Development Iteration
User: "Compile and publish my changes"

**Steps:**
1. Read current version from BC/app.json
2. Increment version by 1 (e.g., 1.0.0.5 → 1.0.0.6)
3. Update app.json with new version
4. Run compilation command
5. Wait for successful compile
6. Run publish command
7. Wait for successful publish
8. Run verification
9. Confirm app is installed with new version
10. Report "App v1.0.0.6 deployed and verified successfully"

**Expected Output:**
```
=== Version Increment ===
Updated version: 1.0.0.5 → 1.0.0.6

=== Compiling BC Apps ===
✓ Volt Apparel v1.0.0.6 compiled successfully (1.1M)

=== Publishing to Sandbox ===
✓ App published successfully

=== Verifying Installation ===
✓ App is installed
Version: 1.0.0.6
State: Installed
```

### Scenario 2: Fresh Start After Changes
User: "I made changes, deploy everything"

**Steps:**
1. Increment version number in app.json
2. Compile all apps from source with new version
3. Publish updated apps
4. Verify new version is installed
5. Report results with version numbers

### Scenario 3: Multiple Apps
User: "Deploy all my apps"

**Steps:**
1. For each app found:
   - Read and increment version in app.json
   - Compile the app with new version
   - Publish to sandbox
   - Verify installation
2. Report summary of all apps with their new versions

### Scenario 4: Quick Fix and Deploy
User: "I fixed a bug, push it now"

**Steps:**
1. Increment version number (e.g., 1.0.0.6 → 1.0.0.7)
2. Run compilation (quick for small changes)
3. Publish immediately to sandbox
4. Verify installation
5. Confirm fix is deployed with new version
6. Suggest testing the fix

## Configuration

Uses existing `.env` configuration:

```bash
# Compilation settings
BC_APPS_ROOT=BC

# Deployment settings
BC_DEPLOYMENT_TYPE=online  # or local
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=MySandbox

# Authentication (online)
BC_TENANT_ID=<your-tenant-id>
BC_CLIENT_ID=<your-client-id>
BC_CLIENT_SECRET=<your-client-secret>

# Or authentication (local)
BC_LOCAL_USERNAME=<username>
BC_LOCAL_PASSWORD=<password>
BC_LOCAL_SERVER_URL=http://localhost:7048
```

## Workflow Variations

### Fast Workflow (Skip Verification)
For rapid iteration when verification isn't needed:
```bash
bc_compile && bc_publish_sandbox
```

### PTE Workflow (Test Production Process)
Use PTE mode instead of dev mode:
```bash
bc_compile
bc_publish_sandbox_pte
# Wait a few minutes for async installation
bash scripts/bc-verify-app.sh
```

### Compile Only
Just build without deploying:
```bash
bc_compile
```

### Publish Only
Deploy already-compiled app:
```bash
bc_publish_sandbox
```

## Error Handling

### Compilation Fails
- Display compilation errors
- Do NOT proceed to publishing
- Suggest reviewing AL code errors
- Fix errors and retry

**Response:**
```
Compilation failed. Please fix the following errors:
[error details]

After fixing, run bc_compile again.
```

### Publishing Fails
- Display publishing error
- Do NOT proceed to verification
- Suggest common fixes:
  - Check authentication
  - Verify environment name
  - Check dependencies

**Response:**
```
Publishing failed: [error details]

Common solutions:
- Verify .env credentials
- Check BC_ENVIRONMENT_NAME
- Ensure dependencies are met

After fixing, run bc_publish_sandbox again.
```

### Verification Fails
- App may not be installed yet
- May still be installing (rare with dev mode)
- Suggest retry or check manually

**Response:**
```
Verification: App not found

Possible reasons:
- Installation still in progress (try again)
- Different environment name
- Check Admin Center manually
```

## Success Indicators

### Complete Success
All steps completed:
- ✓ Compilation successful
- ✓ Publishing successful
- ✓ Verification successful
- App is ready for testing

### Partial Success
Some steps completed:
- ✓ Compilation successful
- ✗ Publishing failed
- Action: Fix publishing issue and retry

## Best Practices

### 1. ALWAYS Increment Version First
**Critical workflow requirement:**
- Never skip version increment
- Automated version bump prevents deployment conflicts
- Read current version → Add 1 → Update app.json
- Example: 1.0.0.5 → 1.0.0.6 → 1.0.0.7 → ...
- BC will reject duplicate versions with HTTP 422 error

### 2. Run After Every Change
Make this workflow muscle memory:
- Make code changes
- Increment version automatically
- Run compilation
- Run publishing
- Test in BC
- Iterate

### 3. Check Verification
Always confirm verification succeeds:
- Ensures app is actually installed
- Confirms version number is correct (matches incremented version)
- Detects silent failures

### 4. Watch for Warnings
Pay attention to compilation warnings:
- May indicate future problems
- Fix warnings proactively
- Keep code clean

### 5. Track Version History
Maintain version discipline:
- Each deployment gets unique version
- Never reuse version numbers
- Keep changelog of what changed in each version
- Makes debugging and rollback easier

## Integration with Development Flow

### Typical Development Session

1. **Start**: Open VS Code, make changes to AL code
2. **Save**: Save all files
3. **Deploy**: Run this workflow command
4. **Test**: Open BC, test changes
5. **Iterate**: Repeat from step 1

### CI/CD Integration

For automated pipelines:
```bash
#!/bin/bash
# CI/CD pipeline script

# Run complete workflow
bash scripts/compile.sh || exit 1
bash scripts/bc-publish-sandbox-dev.sh || exit 1
bash scripts/bc-verify-app.sh || exit 1

echo "CI/CD deployment successful"
```

## Time Expectations

### Typical Timings
- **Compilation**: 5-30 seconds (depends on app size)
- **Publishing**: 5-15 seconds (dev mode is fast)
- **Verification**: 2-5 seconds (API query)
- **Total**: ~30-60 seconds for complete workflow

### Factors Affecting Speed
- App size and complexity
- Number of apps being deployed
- Network latency (online deployments)
- BC server load

## Notes
- This is the recommended workflow for sandbox development
- Dev mode provides fastest iteration speed
- Verification step confirms deployment success
- Can be scripted for automation
- Use PTE mode when testing production deployment process
- For production, use `bc_workflow_production` instead
- Consider creating shell aliases for frequently used workflows

## Technical Implementation
- Uses HTTP multipart/form-data with proper CRLF line endings for file uploads
- Implements Microsoft's Automation API standards for BC extension deployment
- Automatic retry logic and error handling for network issues
- Compatible with both online (SaaS) and local (Docker) BC deployments
