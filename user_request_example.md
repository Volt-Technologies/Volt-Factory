# Feature Development Request: Cancel Allocation in Sales and Purchase Documents

## Feature Overview

Develop a feature that enables users to cancel allocations in:
- Sales orders
- Purchase orders
- Other sales document types
- Other purchase document types

This feature should allow users to cancel allocations while maintaining data integrity and audit trails within Business Central.

## Development Workflow

This feature will be developed through a multi-agent workflow following Business Central best practices and proper project management structure in Azure DevOps.

### Phase 1: Functional Design

**Agent**: `bc-functional-designer`

**Responsibilities**:
1. Analyze the business requirement for canceling allocations in sales and purchase documents
2. Research Business Central's existing allocation mechanisms and document types
3. Create a comprehensive functional design that specifies:
   - What needs to be built in Business Central
   - Where the functionality will exist (which modules, pages, tables)
   - When functionality should trigger (business events, user actions)
   - How users will interact with the features (UI/UX flows)
   - Why specific BC mechanisms are chosen over alternatives

**Azure DevOps Integration**:
4. Call the `azure-devops-manager` agent to create a well-organized work item hierarchy:
   - **Epic**: High-level business capability (e.g., "Document Allocation Cancellation System")
   - **Features**: Major functional areas within the epic (e.g., "Cancel Allocation in Sales Orders", "Cancel Allocation in Purchase Orders", "Cancel Allocation in Other Sales Documents", "Cancel Allocation in Other Purchase Documents")
   - **User Stories**: Specific user-facing functionality (e.g., "As a sales processor, I can cancel an allocation on a sales order line so that reserved inventory is released")
   - **Tasks**: Functional-level work items that the technical design will later decompose (e.g., "Design allocation cancellation validation rules", "Define UI changes for allocation cancellation")
5. Ensure all work items follow the proper hierarchy: Epic → Feature → User Story → Task
6. Provide comprehensive documentation in Azure DevOps work item Description fields including:
   - Complete functional specifications
   - Business rules and validation logic
   - User interaction flows and scenarios
   - Data model changes required
   - Integration points with existing BC functionality
   - Edge cases and exception handling
   - Acceptance criteria

**Output**: Complete functional design and organized Azure DevOps work item hierarchy ready for technical design.

---

### Phase 2: Technical Design

**Agent**: `bc-technical-designer`

**Responsibilities**:
1. Call the `azure-devops-manager` agent to retrieve all tasks from Azure DevOps that have been assigned for the BC Technical Designer to process
2. Read and analyze all functional requirements from the Azure DevOps work items created in Phase 1
3. Research and analyze the Business Central source code to understand:
   - Current allocation mechanisms and their implementation
   - Tables involved in allocations (e.g., Reservation Entry, Item Ledger Entry, Sales Line, Purchase Line)
   - Pages that display allocation information
   - Codeunits and functions that handle allocation logic
   - Existing events related to allocations that can be subscribed to
4. Create a detailed technical design that specifies:
   - **Tables**: All tables that need to be modified or created, including:
     * Table names and IDs
     * Fields to be added (field names, IDs, data types, properties)
     * Field relationships and dependencies
   - **Pages**: All pages that need to be modified or created, including:
     * Page names and IDs
     * Page extensions required
     * New actions, buttons, and UI elements
     * Field placements and visibility rules
   - **Codeunits**: All codeunits involved, including:
     * Codeunit names and IDs
     * Functions that need to be created or modified
     * Function signatures, parameters, and return types
     * Algorithm descriptions for each function
   - **Object Relationships**: How all objects relate to each other:
     * Table relationships and foreign keys
     * Page-to-table bindings
     * Codeunit-to-table/page references
     * Event subscriptions and publishers
   - **Events**: Standard Business Central events that need to be subscribed to:
     * Event names and locations
     * Event parameters
     * Subscription logic and requirements
   - **Algorithm Design**: Detailed algorithms for:
     * Cancellation validation logic
     * Allocation release procedures
     * State transition workflows
     * Integration with existing BC posting routines

**Azure DevOps Integration**:
5. Create new subtasks in Azure DevOps under the existing tasks from Phase 1
6. Each subtask should represent a specific technical implementation item (e.g., "Extend Sales Line table with Cancelled Allocation field", "Create codeunit function CancelSalesLineAllocation", "Subscribe to OnBeforePostSalesLine event")
7. Link subtasks appropriately to their parent tasks and user stories
8. Provide detailed technical specifications in the Description fields of each subtask

**Output**: Comprehensive technical design documented as subtasks in Azure DevOps, ready for development.

---

### Phase 3: Development

**Agent**: `bc-al-developer`

**Responsibilities**:
1. Call the `azure-devops-manager` agent to retrieve all technical tasks from Azure DevOps that need to be implemented
2. Work through tasks sequentially, implementing each one:
   - Read the technical specifications from the Azure DevOps task
   - Implement the required AL code in the `BC` folder:
     * Create or modify tables, table extensions
     * Create or modify pages, page extensions
     * Create or modify codeunits with required functions
     * Implement event subscriptions
     * Add proper error handling and validation
   - Write unit tests in the `BC Test` folder for each implemented feature
   - Follow AL coding standards and best practices
   - Ensure proper object numbering and naming conventions
3. Build the Business Central app incrementally, testing each task's implementation
4. After completing all tasks, or at logical checkpoints, request testing via the compilation and testing workflow (see Phase 4)

**Output**: Complete AL code implementation and unit tests in the BC and BC Test folders.

---

### Phase 4: Compilation, Publishing, and Testing

**Agent**: `bc-app-compiler-tester`

**Responsibilities**:
1. Compile the Business Central app from the `BC` folder
2. Compile the test app from the `BC Test` folder
3. Publish the compiled app to the Business Central environment
4. Execute all unit tests
5. Report detailed results including:
   - Compilation status (success/failures with specific errors)
   - Publishing status
   - Test execution results (passed/failed tests with details)
   - Error messages, stack traces, and file/line references for any failures

**Iteration Cycle**:
6. If compilation, publishing, or testing fails:
   - The `bc-app-compiler-tester` agent provides detailed error information
   - The `bc-al-developer` agent:
     * Analyzes the errors
     * Makes necessary corrections to the AL code
     * Updates unit tests if needed
   - The cycle repeats: `bc-al-developer` fixes code → `bc-app-compiler-tester` compiles, publishes, and tests again
7. Continue this iteration until:
   - The app compiles successfully
   - The app publishes successfully
   - All unit tests pass
8. Only consider the feature complete when all three conditions are met.

---

### Phase 5: Documentation

**Agent**: `gitbook-documentation-builder`

**Responsibilities**:
1. Create comprehensive end-user documentation for the newly developed features
2. Document all modules and functionality that were implemented
3. Generate step-by-step user guides with screenshots captured via Playwright
4. Organize documentation in the appropriate module structure within the `docs/Documentation` folder
5. Update the SUMMARY.md file to include the new documentation pages
6. Document:
   - Feature overview and purpose
   - How to access and use the new functionality
   - Step-by-step instructions for each use case
   - Field descriptions and validation rules
   - Business rules and constraints
   - Troubleshooting common issues
   - Visual guides with annotated screenshots

**Output**: Complete user-facing documentation in GitBook format with screenshots, properly organized in the docs structure.

---

## Success Criteria

The feature is considered complete when:
1. ✅ All functional design work items are created in Azure DevOps with proper hierarchy
2. ✅ All technical design subtasks are created in Azure DevOps with detailed specifications
3. ✅ All technical tasks are implemented in AL code
4. ✅ All unit tests are written and passing
5. ✅ The Business Central app compiles without errors
6. ✅ The app publishes successfully to the Business Central environment
7. ✅ All unit tests execute and pass successfully
8. ✅ Complete user-facing documentation is created with screenshots and organized in GitBook structure

## Notes

- Each agent should maintain clear documentation and progress tracking
- All Azure DevOps work items should follow the strict hierarchy: Epic → Feature → User Story → Task → Subtask
- The development should follow Business Central AL best practices and coding standards
- All code changes should be made in the `BC` folder, and all tests in the `BC Test` folder
- The iteration cycle between `bc-al-developer` and `bc-app-compiler-tester` should continue until all issues are resolved
- Documentation should be created for all newly developed features using the `gitbook-documentation-builder` agent as the final step

