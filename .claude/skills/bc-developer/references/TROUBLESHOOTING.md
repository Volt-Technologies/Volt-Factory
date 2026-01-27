# BC Developer Troubleshooting

## Compilation Errors

### AL0118 - Member Not Found
```
Error: The member 'FieldName' is not found in 'Table "TableName"'
```
**Cause**: Field doesn't exist or wrong spelling.

**Solution**:
1. Check exact field name in table definition
2. Verify table extension is compiled before dependent objects
3. Check for typos in field name

### AL0132 - Variable Not Declared
```
Error: Variable 'varName' is not declared
```
**Solution**:
1. Declare the variable in the var section
2. Check variable name casing (must match declaration)

### AL0185 - Object Not Found
```
Error: Object 'ObjectName' is not found
```
**Solution**:
1. Download symbols: `F1 > AL: Download Symbols`
2. Check .alpackages folder has required .app files
3. Verify app.json dependencies

### LC0001 - FlowField Editable
```
Warning: FlowFields should have Editable = false
```
**Solution**:
```al
field(100; "Total"; Decimal)
{
    FieldClass = FlowField;
    Editable = false;  // Add this
    CalcFormula = sum(...);
}
```

### LC0003 - Use Object Names
```
Warning: Use object names instead of IDs
```
**Solution**:
```al
// Wrong
SourceTable = 18;

// Correct
SourceTable = Customer;
```

## Publishing Errors

### Authentication Failed
```
Error: AADSTS7000215: Invalid client secret provided
```
**Solution**:
1. Verify BC_CLIENT_SECRET in .env
2. Check secret hasn't expired in Azure AD
3. Regenerate secret if needed

### Schema Sync Conflict
```
Error: Sync failed due to schema conflict
```
**Solution**:
```powershell
# Use ForceSync mode
-SyncMode ForceSync
```

### App Already Published
```
Error: App with same version already exists
```
**Solution**:
1. Increment version in app.json
2. Or use Clean sync mode for development

## Docker Container Errors

### Docker Not Running
```
Error: Cannot connect to Docker daemon
```
**Solution**:
1. Open Docker Desktop
2. Wait for it to start completely
3. Verify with `docker ps`

### Container Won't Start
```
Error: Container exited immediately
```
**Solution**:
```bash
docker logs bc-container  # Check logs
docker restart bc-container
```

### Insufficient Memory
```
Error: Not enough memory to start container
```
**Solution**:
1. Open Docker Desktop Settings
2. Go to Resources > Advanced
3. Increase memory to at least 8GB
4. Apply & Restart

### BCContainerHelper Not Found
```
Error: BCContainerHelper module not found
```
**Solution**:
```powershell
Install-Module BCContainerHelper -Force
```

## Test Errors

### Test Codeunit Not Found
```
Error: Test codeunit 70200 not found
```
**Solution**:
1. Verify test app is published
2. Check codeunit ID range is correct
3. Confirm app installation: `bc-verify-app.ps1`

### Test Timeout
```
Error: Test execution timed out
```
**Solution**:
1. Check for infinite loops in test
2. Increase timeout in test runner
3. Split large tests into smaller units

### Permission Error in Tests
```
Error: You do not have permission to...
```
**Solution**:
```al
// Add to test codeunit
TestPermissions = Disabled;
```

## Common Solutions

### Restart Container
```bash
docker restart bc-container
```

### View Container Logs
```bash
docker logs bc-container --tail 100
```

### Enter Container Shell
```bash
docker exec -it bc-container powershell
```

### Check Container Status
```bash
docker inspect bc-container --format '{{.State.Status}}'
```

### Force Symbol Download
1. Delete .alpackages folder
2. Run `F1 > AL: Download Symbols`

### Clean Build
1. Delete output folder
2. Delete .alpackages folder
3. Re-download symbols
4. Recompile

## Configuration Issues

### Missing .env Variables
```
Error: BC_TENANT_ID is not set
```
**Solution**: Ensure .env has all required variables:
```env
BC_DEPLOYMENT_TYPE=online
BC_TENANT_ID=your-tenant-guid
BC_CLIENT_ID=your-client-id
BC_CLIENT_SECRET=your-secret
BC_ENVIRONMENT_NAME=Sandbox
```

### Wrong Environment
```
Error: Environment 'Sandbox' not found
```
**Solution**:
1. Verify BC_ENVIRONMENT_NAME in .env
2. Check environment exists in BC Admin Center
3. Ensure correct tenant

## Compiler Script Errors

### AL1006 - Metadata File Not Found
```
error AL1006: Metadata file 'CodeCop' could not be found
```
**Cause**: Analyzer DLL paths not properly resolved.

**Solution**:
1. Ensure `@volt-technologies/volt-bc-tools` v1.0.3+ is installed
2. The library automatically resolves analyzer paths from the compiler's Analyzers folder
3. Verify analyzer DLLs exist in `scripts/compiler/extension/bin/Analyzers/`

### Compilation Shows 0 Errors But Fails
```
Compilation failed with 0 errors
```
**Cause**: Windows line ending issue in diagnostic parsing (fixed in v1.0.3).

**Solution**:
1. Update to `@volt-technologies/volt-bc-tools` v1.0.3+
2. Library now handles both `\n` and `\r\n` line endings

### Dynamic Require Not Supported
```
Error: Dynamic require of "child_process" is not supported
```
**Cause**: ESM module issue with older library version.

**Solution**: Update to `@volt-technologies/volt-bc-tools` v1.0.3+

### Paths With Spaces Fail
```
Command failed with exit code 1 (no error message)
```
**Cause**: Windows path escaping issue with spaces in paths.

**Solution**:
1. Update to `@volt-technologies/volt-bc-tools` v1.0.3+
2. Library now properly quotes paths on Windows

## Best Practices

1. **Always allocate IDs first**: Use mcp__objid__allocate_id
2. **Compile frequently**: Catch errors early
3. **Update permissionset**: Before compiling new objects
4. **Check feature ranges**: Use BC/FeatureRanges.md
5. **Clean up containers**: Save disk space with `docker system prune`
6. **Keep library updated**: Use v1.0.3+ for Windows fixes
