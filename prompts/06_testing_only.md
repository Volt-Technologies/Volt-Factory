# Testing Workflow: [Feature Name]

## Prerequisites

This workflow assumes:
- ✅ AL code has been developed in the `BC` folder
- ✅ Unit tests have been written in the `BC Test` folder
- ✅ The Business Central app has been compiled successfully
- ✅ The app has been published to the Business Central environment

If your code hasn't been compiled and published yet, you need to run compilation first (use `bc-app-compiler` agent or `/bc_compile` command).

---

## Workflow Scope

This workflow focuses exclusively on executing tests and iterating on failures.

**Workflow**: Existing Code (compiled & published) → Testing → (If failures: Development → Compilation → Testing) → Repeat until all tests pass

---

## Phase 1: Testing

**Agent**: `bc-test-runner`

**Responsibilities**:

### 1. Execute Unit Tests
- Navigate to the Business Central AL Test Tool web interface
- Execute all unit tests from the published test app
- Monitor test execution progress (can take 10-20+ minutes depending on test suite size)

### 2. Capture Test Results
Collect comprehensive test execution results:
- **Summary Statistics**:
  - Total number of tests executed
  - Number of tests passed
  - Number of tests failed
  - Execution time per test

- **For Each Failed Test**:
  - Test codeunit name
  - Test procedure name
  - Detailed error message
  - Stack trace
  - Assertion failure details
  - Line numbers and file references

- **For Each Passed Test**:
  - Test codeunit name
  - Test procedure name
  - Execution time

### 3. Report Results
Provide a detailed test report including:
- Overall test execution summary
- Complete list of failed tests with error details
- Complete list of passed tests
- Recommendations for fixing failures (if patterns are identified)

**Output**: Comprehensive test execution report with all failures and passes documented.

---

## Phase 2: Fix Failures (If Tests Fail)

If any tests fail, the workflow automatically enters an iteration cycle:

### Step 1: Development Agent Fixes Issues

**Agent**: `bc-al-developer`

**Responsibilities**:
1. Analyze the test failure details provided by `bc-test-runner`
2. Identify the root cause of each failure:
   - Is the implementation code incorrect?
   - Is the test itself incorrect or flawed?
   - Are there missing edge case handlings?
   - Are there integration issues?
3. Make necessary corrections:
   - Fix bugs in the implementation code (`BC` folder)
   - Update incorrect unit tests (`BC Test` folder)
   - Add missing validation or error handling
   - Adjust business logic as needed
4. Document what was changed and why

### Step 2: Recompile and Republish

**Agent**: `bc-app-compiler`

**Responsibilities**:
1. Compile the updated Business Central app
2. Compile the updated test app
3. Publish both apps to the environment
4. Report compilation and publishing status

### Step 3: Re-execute Tests

**Agent**: `bc-test-runner`

**Responsibilities**:
1. Execute the full test suite again
2. Capture new test results
3. Compare with previous run to verify fixes
4. Report updated test results

### Step 4: Repeat Until All Tests Pass

Continue the iteration cycle (Development → Compilation → Testing) until:
- ✅ All unit tests pass successfully
- ✅ No test failures remain
- ✅ Test execution completes without errors

---

## Success Criteria

The testing workflow is considered successful when:
1. ✅ All unit tests execute successfully (Phase 1)
2. ✅ No test failures are reported (Phase 1)
3. ✅ Test execution completes without runtime errors (Phase 1)
4. ✅ If failures occurred, all were fixed through the iteration cycle (Phase 2)
5. ✅ Final test run shows 100% pass rate

---

## Iteration Cycle Diagram

```
┌─────────────────────────────────────────────┐
│         bc-test-runner                      │
│    Execute Tests & Report Results          │
└─────────────────┬───────────────────────────┘
                  │
                  ├─── All Tests Pass? ───> ✅ SUCCESS - Workflow Complete
                  │
                  └─── Tests Failed?
                        │
                        ▼
          ┌────────────────────────────┐
          │    bc-al-developer         │
          │  Analyze & Fix Issues      │
          └────────────┬───────────────┘
                       │
                       ▼
          ┌────────────────────────────┐
          │    bc-app-compiler         │
          │  Compile & Publish         │
          └────────────┬───────────────┘
                       │
                       │
                       └────────> Loop back to bc-test-runner
```

---

## Next Steps (Not Executed in This Workflow)

After all tests pass, you can:
- **Create Documentation**: Use `07_documentation_only.md` to generate user guides
- **Deploy to Production**: Follow your deployment procedures for production release

---

## Notes

- **Test Execution Time**: Be patient - test execution can take 10-20+ minutes or longer for comprehensive test suites
- **Automatic Iteration**: The workflow automatically loops through Development → Compilation → Testing until all tests pass
- **No Manual Intervention Needed**: The agents will continue iterating until success
- **Test Coverage**: This workflow executes all tests in the `BC Test` folder - ensure your test coverage is comprehensive
- **Environment**: Tests run against the published app in the configured Business Central environment
- **Web Interface**: The `bc-test-runner` uses Playwright to interact with the BC AL Test Tool web interface
- **Detailed Reporting**: Each test failure includes stack traces and assertion details to aid in debugging
- **Test Isolation**: Each test should be independent and not rely on other tests' state
