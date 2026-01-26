# BC Test Runner Troubleshooting

## OData API Errors

### 403 Forbidden
```
Error: Request failed with status 403
```
**Cause**: Missing permissions for Azure AD app.

**Solution**:
1. Open BC → Web Services page
2. Verify `TestRunner` web service exists
3. In BC → Users, find the Azure AD app user
4. Assign `TestVolt` permission set (60000)

### 404 Not Found
```
Error: Resource not found
```
**Cause**: Web service not registered.

**Solution**:
1. Open BC → Web Services page
2. Add new web service:
   - Object Type: Codeunit
   - Object ID: 78000
   - Service Name: TestRunner
   - Published: Yes

### 401 Unauthorized
```
Error: Authentication failed
```
**Solution**:
1. Verify `.env` credentials:
   - `BC_TENANT_ID`
   - `BC_CLIENT_ID`
   - `BC_CLIENT_SECRET`
2. Check Azure AD app has BC API permissions

### 500 Internal Server Error
**Cause**: Runtime error in test code.

**Solution**:
1. Check BC event log for details
2. Verify test codeunit has `Subtype = Test`
3. Check for initialization errors

## BCContainerHelper Errors

### Container Not Found
```
Error: Container 'bc-feature' not found
```
**Solution**:
```bash
docker ps -a  # List all containers
docker start bc-feature  # Start if stopped
```

### Module Not Loaded
```
Error: BCContainerHelper module not found
```
**Solution**:
```powershell
Install-Module BCContainerHelper -Force
Import-Module BCContainerHelper
```

### Test Execution Timeout
**Cause**: Tests taking too long.

**Solution**:
- Increase timeout in script (default: 600 seconds)
- Check for infinite loops in test code
- Reduce test scope

## Common Test Failures

### Assert Failure
```
Error: Assert.AreEqual failed. Expected: X, Actual: Y
```
**Solution**: Review test logic and expected values.

### Record Not Found
```
Error: The record does not exist
```
**Solution**: Ensure test data setup creates required records.

### Permission Error
```
Error: You do not have permission to read table X
```
**Solution**:
1. Check `TestPermissions` attribute on test codeunit
2. Add table to `TestVolt` permission set

## Performance Issues

### Tests Running Slowly
- Reduce database operations
- Use `TestPermissions = Disabled` when safe
- Mock external dependencies

### Timeout During Large Test Suite
- Run tests in smaller batches
- Use `--codeunit` for specific tests
- Increase script timeout
