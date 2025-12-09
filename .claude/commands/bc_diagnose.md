# AL Diagnostics & Debugging

Your goal is to diagnose and resolve AL issues in the Volt Apparel Business Central solution.

## When to Use This Command

- Runtime errors or exceptions
- Configuration issues (authentication, symbols, dependencies)
- Compilation problems
- Performance issues
- Integration failures
- Unexpected behavior in VT objects (styles, cut tickets, seasons)

## Diagnostic Workflow

### Step 1: Gather Information

Ask the user:
1. What is the issue? (error message, unexpected behavior, performance problem)
2. When does it happen? (always, sometimes, specific conditions)
3. Which VT objects are involved? (table, page, codeunit)
4. Recent changes? (new code, configuration changes)
5. Environment? (sandbox, production)

### Step 2: Invoke bc-debugger Agent

For systematic investigation, use the Task tool to launch the bc-debugger agent:

```
Task(
  subagent_type: "bc-debugger",
  description: "Diagnose [issue]",
  prompt: "Investigate the following issue: [user description].

  Environment: [sandbox/production]
  Affected objects: [VT Style, VT Cut Ticket, etc.]
  Error message: [if applicable]
  Recent changes: [if applicable]

  Perform systematic diagnosis following the debugging workflow:
  1. Reproduce the issue
  2. Isolate the problem using Glob/Grep
  3. Diagnose root cause
  4. Recommend fix
  5. Verify the fix"
)
```

### Step 3: For Specific Issues

**Runtime Errors**:
- bc-debugger will locate error source
- Identify validation failures or data state issues
- Check event subscribers and triggers

**Performance Issues**:
- bc-debugger analyzes code structure
- Looks for N+N patterns, FlowField issues
- Checks for AL0896 circular dependencies
- Reviews indexing and SetLoadFields usage

**Integration Issues**:
- bc-debugger verifies event subscriber signatures
- Checks API authentication/authorization
- Reviews request/response payloads

**Configuration Issues**:
- Check launch.json configuration
- Verify app.json dependencies
- Review .objidconfig settings
- Check BC environment connectivity

### Step 4: Apply Fix

Once bc-debugger identifies root cause:

1. **If code change needed**:
   - Invoke bc-al-developer to implement fix
   - Follow AL guidelines from `.claude/al_guidelines/`
   - Use bc-app-compiler to compile
   - Use bc-test-runner to verify fix

2. **If configuration change needed**:
   - Update configuration files
   - Document the change
   - Test the fix

3. **If AL0896 circular FlowField**:
   - Change FlowField to normal field with trigger
   - Or restructure calculation logic
   - Recompile and test

### Step 5: Verify Resolution

- Reproduce original issue to confirm fix
- Run regression tests for related features
- Document the issue and solution

## Common Volt Apparel Issues

### Issue: "VT Style Not Found"
**Diagnosis**: Check if style is blocked or deleted
**Tools**: Grep to find validation code, Read VTStyle.Table.al
**Fix**: Add proper validation or unblock style

### Issue: "Cut Ticket Posting Fails"
**Diagnosis**: Missing fabric inventory or blocked style
**Tools**: bc-debugger traces posting codeunit
**Fix**: Validate inventory before posting

### Issue: "Season Validation Error"
**Diagnosis**: Expired or inactive season
**Tools**: Grep for ValidateSeasonCode procedure
**Fix**: Update season status or validation logic

### Issue: "Performance Slow on Style List"
**Diagnosis**: Missing SetLoadFields or inefficient query
**Tools**: bc-debugger analyzes page code
**Fix**: Add SetLoadFields, optimize query

## Key Reminders

- **Always use bc-debugger** for systematic investigation
- **VT prefix objects** are custom Volt Apparel code
- **AL guidelines** at `.claude/al_guidelines/` apply to fixes
- **Safety first**: Verify environment before making changes
- **Document findings**: Record root cause and solution

## Output

Provide:
1. Root cause explanation
2. Recommended fix
3. Implementation plan
4. Verification steps
5. Prevention recommendations
