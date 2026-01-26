# BC Compiler Troubleshooting

## Compilation Errors

### AL0118: Member not found
```
Error: AL0118: The member 'FieldName' is not found in 'Table "Customer"'
```
**Solutions**:
1. Check field name spelling (case-sensitive)
2. Verify field exists in base table or dependent extension
3. Ensure dependency declared in `app.json`

### AL0132: Variable not declared
```
Error: AL0132: Variable 'myVar' is not declared
```
**Solutions**:
1. Add variable in `var` section
2. Check spelling
3. Verify scope (local vs global)

### Symbol not found
```
Error: Cannot find definition for 'Table 18 Customer'
```
**Solutions**:
1. Download symbols in VS Code: "AL: Download Symbols"
2. Check `.alpackages` has required .app files
3. Verify `app.json` dependencies match your symbols

## Publishing Errors

### OAuth authentication failed
```
Error: OAuth token request failed: AADSTS700016
```
**Solutions**:
1. Verify `BC_CLIENT_ID` and `BC_CLIENT_SECRET`
2. Confirm `BC_TENANT_ID` matches Azure AD
3. Check app registration API permissions

### Environment not found
```
Error: Environment 'MySandbox' not found
```
**Solutions**:
1. Check exact name in BC Admin Center
2. Verify `BC_ENVIRONMENT_NAME` in `.env`

### Schema sync failed
```
Error: Cannot sync schema - breaking change detected
```
**Solutions**:
1. Use `--sync-mode ForceSync` for development
2. Mark fields as `ObsoleteState = Removed` first
3. For production: use upgrade codeunits

### Container not found
```
Error: Container 'bc-container' not found
```
**Solutions**:
1. Check: `docker ps -a`
2. Start: `docker start bc-container`
3. Create new container

## Configuration Errors

### Missing .env file
Create `.env` with required variables:
```env
BC_DEPLOYMENT_TYPE=online
BC_ENVIRONMENT_TYPE=sandbox
BC_ENVIRONMENT_NAME=Sandbox
BC_APPS_ROOT=BC
```

## Quick Fixes

### Full Rebuild
```bash
rm -rf output/*.app
npx volt-bc dev compile --all
```

### Environment Reset
```bash
# Uninstall and republish
npx volt-bc dev publish ./output/MyApp.app --sync-mode ForceSync
```
