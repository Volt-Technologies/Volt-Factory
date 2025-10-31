# Technical Design Request: [Feature Name]

## Prerequisites

This workflow assumes:
- ✅ Functional design has been completed
- ✅ Azure DevOps work items exist with functional specifications (Epic, Features, User Stories, Tasks)
- ✅ Business requirements and acceptance criteria are documented

If you don't have a functional design yet, use `02_business_to_functional_design.md` first.

---

## Workflow Scope

This workflow will **ONLY** execute the **Technical Design** phase. It will not proceed to development, testing, or other phases.

**Workflow**: Existing Functional Design → Technical Design ✋ **STOP**

---

## Phase 1: Technical Design

**Agent**: `bc-technical-designer`

**Responsibilities**:

### 1. Retrieve Functional Requirements
- Call the `azure-devops-manager` agent to retrieve all tasks from Azure DevOps that have been assigned for the BC Technical Designer to process
- Read and analyze all functional requirements from the Azure DevOps work items

### 2. Research Business Central Source Code
Analyze the Business Central codebase to understand:
- Current implementation patterns related to the feature
- Tables that will be involved (e.g., existing tables that need extensions)
- Pages that will need modifications or extensions
- Codeunits and functions that handle related logic
- Existing events that can be subscribed to
- Standard BC patterns and best practices applicable to this feature

### 3. Create Detailed Technical Design

Specify the following in detail:

#### **Tables**
- All tables that need to be modified or created
- Table names and IDs (using proper object ID allocation)
- Fields to be added:
  * Field names and IDs
  * Data types and properties
  * Relationships and dependencies
  * Validation requirements

#### **Pages**
- All pages that need to be modified or created
- Page names and IDs
- Page extensions required
- New actions, buttons, and UI elements
- Field placements and visibility rules
- Layout specifications

#### **Codeunits**
- All codeunits involved
- Codeunit names and IDs
- Functions that need to be created or modified:
  * Function signatures (names, parameters, return types)
  * Detailed algorithm descriptions
  * Error handling specifications
  * Integration points with existing BC functionality

#### **Object Relationships**
- How all objects relate to each other
- Table relationships and foreign keys
- Page-to-table bindings
- Codeunit-to-table/page references
- Data flow between objects

#### **Events**
- Standard Business Central events to subscribe to
- Event names and locations
- Event parameters
- Subscription logic and requirements
- Custom events to publish (if needed)

#### **Algorithms**
Detailed algorithms for:
- Core business logic implementation
- Validation procedures
- State transition workflows
- Integration with existing BC posting routines
- Error handling and rollback procedures

### 4. Azure DevOps Integration
- Create new **subtasks** in Azure DevOps under the existing tasks from the functional design
- Each subtask should represent a specific technical implementation item:
  * Example: "Extend Sales Line table with Cancelled Allocation field"
  * Example: "Create codeunit function CancelSalesLineAllocation"
  * Example: "Subscribe to OnBeforePostSalesLine event"
  * Example: "Add Cancel Allocation action to Sales Order page"
- Link subtasks appropriately to their parent tasks and user stories
- Provide detailed technical specifications in the Description field of each subtask:
  * Complete AL code structure
  * Object IDs and naming conventions
  * Implementation notes and considerations
  * Dependencies on other subtasks

**Output**: Comprehensive technical design documented as subtasks in Azure DevOps.

---

## Success Criteria

The technical design phase is considered complete when:
1. ✅ All functional tasks have been analyzed and understood
2. ✅ Business Central source code research is complete
3. ✅ Detailed technical specifications are created for all AL objects (tables, pages, codeunits)
4. ✅ Technical subtasks are created in Azure DevOps under the appropriate parent tasks
5. ✅ Each subtask contains complete technical specifications in its Description field
6. ✅ Object relationships, event subscriptions, and algorithms are fully documented
7. ✅ The technical design is ready to be handed off to developers (if continuing later)

---

## Next Steps (Not Executed in This Workflow)

After this workflow completes, you can continue with:
- **Development**: Use `05_development_to_completion.md` to implement the technical design through to documentation
- **Development Only**: Create a custom workflow that stops after development

---

## Notes

- This workflow **stops after technical design** and does not proceed to code implementation
- The `bc-technical-designer` agent will research existing BC code patterns to ensure the design follows best practices
- All Azure DevOps subtasks will be properly linked to their parent tasks and user stories
- The technical design should be detailed enough that a developer can implement it without ambiguity
- **No code will be written** in this workflow - this is purely technical specification work
- Proper AL object ID allocation should be considered (may integrate with object ID management system)
