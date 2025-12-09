# Workflow 03: Technical Design

Please provide the following information to start the technical design phase:

**Required:**
- Feature Name: {FEATURE_NAME} (e.g., "Product Variants")
- User Story Name: {USER_STORY_NAME} (e.g., "Create Variant from Template")

---

Once you provide the information above, I will launch the **bc-technical-designer** agent to:
- Read functional design documents from factory/2functional_design/[Feature]/[UserStory]/
- Read parent Feature business context from factory/1research/[Feature]/
- Research Business Central standard objects using AL MCP tools
- Design AL objects with exact IDs, field definitions, and procedure signatures
- Design algorithms for complex business logic
- Create technical design documentation in factory/3technical_design/[Feature]/[UserStory]/:
  1. **technical_specifications.md**: Complete AL technical specification
  2. **al_object_designs.md**: Detailed AL object designs (tables, pages, codeunits)
  3. **algorithm_designs.md**: Step-by-step algorithms for complex business logic
  4. **HANDOFF_TO_DEVELOPMENT.md**: Handoff document for developers

**Prerequisites:**
- ✅ Functional design phase complete (Workflow 02)
- ✅ factory/2functional_design/[Feature]/[UserStory]/ documents exist

**Success Criteria:**
- ✅ Technical design documents created for the User Story
- ✅ Development specifications complete with AL object details
- ✅ Test scenarios documented
- ✅ Object IDs allocated and tracked
- ✅ Handoff document prepared

**Next Stages:**
- Use `/workflow_04_development` to implement the User Story
- Use `/workflow_05_testing` to test the implementation
- Use `/workflow_06_documentation` to document the feature
