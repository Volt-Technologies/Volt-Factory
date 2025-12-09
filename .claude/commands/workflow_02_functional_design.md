# Workflow 02: Functional Design

Please provide the following information to start the functional design phase:

**Required:**
- Feature Name: {FEATURE_NAME} (e.g., "Product Variants", "Seasonal Planning")

**Optional:**
- Priority guidance (MVP vs post-MVP focus): {PRIORITY}
- Execution mode (full/fast): {MODE}

---

Once you provide the information above,READ **bc-functional-designer** agent nad use it as your system prompt
- Read research documents from factory/1research/[Feature]/ for business context
- Execute 7 sub-agents through 4 phases:
  - Phase 1: Requirements analysis and BC standard functionality research
  - Phase 2: Iterative solution refinement (2-3 cycles)
  - Phase 3: UI/UX design
  - Phase 4: Create User Stories with Given-When-Then acceptance criteria
- Create functional design documents (01-07) per user story
- Organize outputs in factory/2functional_design/[Feature]/[UserStory]/

**Prerequisites:**
- ✅ Business research phase complete (Workflow 01)
- ✅ Research documents exist in factory/1research/[Feature]/

**Success Criteria:**
- ✅ User Stories created with acceptance criteria
- ✅ Functional design documents (01-07) per user story
- ✅ Folder structure: factory/2functional_design/[Feature]/[UserStory]/
- ✅ Handoff documents prepared

**Next Stage:** Use `/workflow_03_technical_design` to process the User Stories for this Feature.
