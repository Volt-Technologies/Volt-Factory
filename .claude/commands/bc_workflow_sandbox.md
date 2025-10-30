---
allowed-tools: Bash(*)
description: Complete sandbox workflow (compile + publish + verify)
---

# Business Central Sandbox Workflow Command

## Purpose
This command executes a complete end-to-end workflow for sandbox development: compile all apps, publish to sandbox environment, and verify installation. This is the most common workflow during active development.

## Workflow Steps

The complete sandbox workflow includes:

1. **Compile**: Build all BC apps from source
2. **Publish**: Deploy to sandbox using dev mode
3. **Verify**: Confirm successful installation

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
Simply run the three commands in sequence:

```bash
# Step 1: Compile all apps
bc_compile

# Step 2: Publish to sandbox
bc_publish_sandbox

# Step 3: Verify installation
bash scripts/bc-verify-app.sh
```

Or execute manually:

```bash
# Run all steps
bash scripts/compile.sh && \
bash scripts/bc-publish-sandbox-dev.sh && \
bash scripts/bc-verify-app.sh
```

## Common Scenarios

### Scenario 1: Regular Development Iteration
User: "Compile and publish my changes"

**Steps:**
1. Run compilation command
2. Wait for successful compile
3. Run publish command
4. Wait for successful publish
5. Run verification
6. Confirm app is installed
7. Report "App deployed and verified successfully"

**Expected Output:**
```
=== Compiling BC Apps ===
✓ BC compiled successfully (256K)

=== Publishing to Sandbox ===
✓ App published successfully

=== Verifying Installation ===
✓ App is installed
Version: 1.0.0.0
State: Installed
```

### Scenario 2: Fresh Start After Changes
User: "I made changes, deploy everything"

**Steps:**
1. Compile all apps from source
2. Publish updated apps
3. Verify new version is installed
4. Report results with version numbers

### Scenario 3: Multiple Apps
User: "Deploy all my apps"

**Steps:**
1. Compile finds all app.json files
2. Compiles each app
3. For each compiled app:
   - Publish to sandbox
   - Verify installation
4. Report summary of all apps

### Scenario 4: Quick Fix and Deploy
User: "I fixed a bug, push it now"

**Steps:**
1. Run compilation (quick for small changes)
2. Publish immediately to sandbox
3. Verify installation
4. Confirm fix is deployed
5. Suggest testing the fix

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

### 1. Run After Every Change
Make this workflow muscle memory:
- Make code changes
- Run workflow
- Test in BC
- Iterate

### 2. Check Verification
Always confirm verification succeeds:
- Ensures app is actually installed
- Confirms version number is correct
- Detects silent failures

### 3. Watch for Warnings
Pay attention to compilation warnings:
- May indicate future problems
- Fix warnings proactively
- Keep code clean

### 4. Use Version Numbers
Track changes with versions:
- Update version in app.json before workflow
- Verify correct version after deployment
- Makes debugging easier

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
