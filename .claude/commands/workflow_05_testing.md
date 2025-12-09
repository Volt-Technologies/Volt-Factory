# Workflow 05: Testing

Please provide the following information to start the testing phase:

**Required:**
- Feature Name: {FEATURE_NAME} (e.g., "Product Variants")
- User Story Name: {USER_STORY_NAME} (e.g., "Create Variant from Template")

**Required - Environment Details:**
- BC Tenant ID: {TENANT_ID} (e.g., 74d19fe7-2ea1-489b-9211-9a2ae69e0d10)
- Environment Name: {ENV_NAME} (e.g., "Apparel", "Sandbox" - NEVER "Production")
- Company Name: {COMPANY_NAME} (e.g., "CRONUS USA, Inc.")
- Test Codeunit ID Range: {TEST_RANGE} (e.g., 50100..60000)

---

⚠️ **SAFETY PROTOCOLS:**
**ABSOLUTE PROHIBITION: NEVER run tests in Production environments**

**Acceptable Environments:**
- Sandbox
- Development
- Testing
- UAT (User Acceptance Testing)
- Any environment explicitly labeled as non-production

---

Once you provide the information above, I will launch the **bc-test-runner** agent to:
- Read functional design from factory/2functional_design/[Feature]/[UserStory]/ for acceptance criteria
- Read technical specs from factory/3technical_design/[Feature]/[UserStory]/ for test scenarios
- **CRITICAL:** Verify environment is NOT Production
- Navigate to AL Test Tool using Chrome DevTools MCP
- Load test codeunits by ID range
- Execute all tests (may take 10-20+ minutes)
- Capture test results:
  - For passing tests: Note success
  - For failing tests: Capture complete error messages and stack traces
- Generate comprehensive test execution report in factory/5unit_test/[Feature]/[UserStory]/

**Prerequisites:**
- ✅ Development completed (Workflow 04)
- ✅ AL code implemented and compiled
- ✅ Unit tests created by bc-al-developer
- ✅ Extensions published to target BC environment

**Success Criteria:**
- ✅ All tests executed successfully
- ✅ All tests pass (no failures)
- ✅ Comprehensive test report generated in factory/5unit_test/[Feature]/[UserStory]/
- ✅ Test results documented

**Handling Test Failures:**
If tests fail:
1. Detailed failure information captured in test report
2. Request bc-al-developer to investigate and fix
3. After fixes: recompile, republish, re-execute tests
4. Only then proceed to documentation

**Next Stage:** Use `/workflow_06_documentation` to complete the documentation.
