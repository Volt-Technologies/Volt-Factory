# Functional Design Request: [Feature Name]

## Feature Overview

**Replace this section with your business requirement description.**

Example: Develop a feature that enables users to cancel allocations in sales orders, purchase orders, and other related document types within Business Central.

## Workflow Scope

This workflow will **ONLY** execute the **Functional Design** phase. It will not proceed to technical design, development, or other phases.

**Workflow**: Business Requirement → Functional Design ✋ **STOP**

---

## Phase 1: Functional Design

**Agent**: `bc-functional-designer`

**Responsibilities**:
1. Analyze the business requirement provided above
2. Research Business Central's existing mechanisms related to the feature
3. Create a comprehensive functional design that specifies:
   - **What** needs to be built in Business Central
   - **Where** the functionality will exist (which modules, pages, tables)
   - **When** functionality should trigger (business events, user actions)
   - **How** users will interact with the features (UI/UX flows)
   - **Why** specific BC mechanisms are chosen over alternatives

**Azure DevOps Integration**:
4. Call the `azure-devops-manager` agent to create a well-organized work item hierarchy:
   - **Epic**: High-level business capability (e.g., "Document Allocation Cancellation System")
   - **Features**: Major functional areas within the epic (e.g., "Cancel Allocation in Sales Orders", "Cancel Allocation in Purchase Orders")
   - **User Stories**: Specific user-facing functionality (e.g., "As a sales processor, I can cancel an allocation on a sales order line so that reserved inventory is released")
   - **Tasks**: Functional-level work items that describe what needs to be designed/built (e.g., "Design allocation cancellation validation rules", "Define UI changes for allocation cancellation")
5. Ensure all work items follow the proper hierarchy: Epic → Feature → User Story → Task
6. Provide comprehensive documentation in Azure DevOps work item Description fields including:
   - Complete functional specifications
   - Business rules and validation logic
   - User interaction flows and scenarios
   - Data model changes required
   - Integration points with existing BC functionality
   - Edge cases and exception handling
   - Acceptance criteria

**Output**: Complete functional design and organized Azure DevOps work item hierarchy.

---

## Success Criteria

The functional design phase is considered complete when:
1. ✅ All functional design work items are created in Azure DevOps with proper hierarchy (Epic → Feature → User Story → Task)
2. ✅ Each work item contains comprehensive functional specifications in its Description field
3. ✅ Business rules, validation logic, and user flows are clearly documented
4. ✅ Acceptance criteria are defined for each user story
5. ✅ The functional design is ready to be handed off to technical design (if continuing later)

---

## Next Steps (Not Executed in This Workflow)

After this workflow completes, you can continue with:
- **Technical Design**: Use `03_functional_to_technical_design.md` or `04_functional_to_completion.md`
- **Full Implementation**: Use `04_functional_to_completion.md` to go from functional design through documentation

---

## Notes

- This workflow **stops after functional design** and does not proceed further
- The `bc-functional-designer` agent will maintain clear documentation and progress tracking
- All Azure DevOps work items will follow the strict hierarchy: Epic → Feature → User Story → Task
- The functional design should follow Business Central best practices and patterns
- **No code will be written** in this workflow - this is purely functional specification work
