# Workflow 04: Development

Please provide the following information to start the development phase:

**Required:**
- Feature Name: {FEATURE_NAME} (e.g., "Product Variants")
- User Story Name: {USER_STORY_NAME} (e.g., "Create Variant from Template")

---

Once you provide the information above, I will launch the **bc-al-developer** agent to:
- Read technical design documents from factory/3technical_design/[Feature]/[UserStory]/
- Read functional design from factory/2functional_design/[Feature]/[UserStory]/ for context
- Read AL guidelines from .claude/al_guidelines/
- **FOR EACH NEW AL OBJECT:**
  - Use mcp__objid__allocate_id to reserve object ID
  - Create AL code file in BC/ folder using allocated ID
- Implement all AL objects per technical specification
- Create comprehensive unit tests in BC Test/ folder
- **Phase A - Compilation & Publishing:**
  - Invoke bc-app-compiler agent
  - Fix errors and retry until successful
- **Phase B - Testing:**
  - Invoke bc-test-runner agent (after successful compilation)
  - Fix test failures, recompile, retest until all pass
- **Phase C - Documentation:**
  - Create implementation summary in factory/4development/[Feature]/[UserStory]/
  - Document code references and object IDs allocated

**Prerequisites:**
- ✅ Technical design phase complete (Workflow 03)
- ✅ factory/3technical_design/[Feature]/[UserStory]/ documents exist with complete AL specifications

**Critical Requirements:**
- ⚠️ MUST allocate object IDs (never hardcode or guess)
- ⚠️ MUST create unit tests (every feature requires tests)
- ⚠️ MUST compile successfully (no compilation errors)
- ⚠️ MUST pass all tests (no test failures before completing)

**Success Criteria:**
- ✅ All AL objects implemented according to specification
- ✅ Object IDs properly allocated using mcp__objid__allocate_id
- ✅ Unit tests created for all functionality
- ✅ bc-app-compiler confirms successful compilation and publishing
- ✅ bc-test-runner confirms all tests pass
- ✅ Implementation documented in factory/4development/[Feature]/[UserStory]/

**Next Stage:** Use `/workflow_05_testing` to execute end-to-end validation.
