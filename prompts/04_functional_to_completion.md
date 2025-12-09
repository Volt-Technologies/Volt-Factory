# Complete Implementation from Functional Design: [Feature Name]

## Prerequisites

This workflow assumes:
- ✅ Functional design has been completed
- ✅ Azure DevOps work items exist with functional specifications (Epic, Features, User Stories, Tasks)
- ✅ Business requirements and acceptance criteria are documented

If you don't have a functional design yet, use `02_business_to_functional_design.md` first.

---

## Workflow Scope

This workflow starts from an existing functional design and executes through to completion.

**Workflow**: Existing Functional Design → Technical Design → Development → Compilation/Publishing → Testing → Documentation

---

## Phase 1: Technical Design

**Agent**: `bc-technical-designer`

**Responsibilities**:
1. Call the `azure-devops-manager` agent to retrieve all tasks from Azure DevOps
2. Read and analyze all functional requirements from the Azure DevOps work items
3. Research and analyze Business Central source code to understand current implementations
4. Create detailed technical design specifying:
   - Tables (names, IDs, fields, data types, relationships)
   - Pages (names, IDs, extensions, actions, layouts)
   - Codeunits (names, IDs, functions, signatures, algorithms)
   - Object relationships and dependencies
   - Events to subscribe to
   - Detailed algorithms for core logic
5. Create technical subtasks in Azure DevOps under existing functional tasks
6. Document complete technical specifications in each subtask's Description field

**Output**: Comprehensive technical design documented as subtasks in Azure DevOps.

---

## Phase 2: Development

**Agent**: `bc-al-developer`

**Responsibilities**:
1. Call the `azure-devops-manager` agent to retrieve all technical tasks
2. Work through tasks sequentially, implementing each one:
   - Implement AL code in the `BC` folder:
     * Tables and table extensions
     * Pages and page extensions
     * Codeunits with required functions
     * Event subscriptions
     * Error handling and validation
   - Write unit tests in the `BC Test` folder for each feature
   - Follow AL coding standards and best practices
   - Use proper object numbering and naming conventions
3. Build the app incrementally, compiling and testing at logical checkpoints
4. After completing implementation, trigger compilation and publishing (Phase 3)

**Output**: Complete AL code implementation and unit tests.

---

## Phase 3: Compilation and Publishing

**Agent**: `bc-app-compiler`

**Responsibilities**:
1. Compile the Business Central app from the `BC` folder
2. Compile the test app from the `BC Test` folder
3. Publish the compiled app to the Business Central environment
4. Report detailed results including compilation/publishing status and any errors

**Iteration Cycle**:
5. If compilation or publishing fails:
   - Provide detailed error information to `bc-al-developer`
   - `bc-al-developer` analyzes and fixes the code
   - Retry compilation and publishing
6. Continue until both apps compile and publish successfully
7. Once successful, proceed to Phase 4 (Testing)

---

## Phase 4: Testing

**Agent**: `bc-test-runner`

**Responsibilities**:
1. Execute all unit tests via Business Central's AL Test Tool web interface
2. Monitor test execution (may take 10-20+ minutes)
3. Capture comprehensive test results:
   - Passed/failed test counts
   - Detailed error messages for failures
   - Stack traces and assertion failures
   - Test codeunit and procedure names

**Iteration Cycle**:
4. If tests fail:
   - Provide detailed test failure information to `bc-al-developer`
   - `bc-al-developer` analyzes and fixes the code or tests
   - Trigger recompilation (Phase 3) and republishing
   - Re-execute tests
5. Continue until all unit tests pass
6. Once all tests pass, proceed to Phase 5 (Documentation)

---

## Phase 5: Documentation

**Agent**: `gitbook-documentation-builder`

**Responsibilities**:
1. Create comprehensive end-user documentation for the implemented features
2. Document all modules and functionality
3. Generate step-by-step user guides with screenshots (captured via Chrome DevTools MCP)
4. Organize documentation in the `docs/Documentation` folder
5. Update the SUMMARY.md file to include new documentation pages
6. Document:
   - Feature overview and purpose
   - How to access and use the functionality
   - Step-by-step instructions for each use case
   - Field descriptions and validation rules
   - Business rules and constraints
   - Troubleshooting common issues
   - Visual guides with annotated screenshots

**Output**: Complete user-facing documentation in GitBook format.

---

## Success Criteria

The complete implementation is considered successful when:
1. ✅ Technical design subtasks are created in Azure DevOps with detailed specifications (Phase 1)
2. ✅ All technical tasks are implemented in AL code (Phase 2)
3. ✅ All unit tests are written in the BC Test folder (Phase 2)
4. ✅ The Business Central app compiles without errors (Phase 3)
5. ✅ The app publishes successfully to the environment (Phase 3)
6. ✅ All unit tests execute and pass successfully (Phase 4)
7. ✅ Complete user documentation is created with screenshots (Phase 5)

---

## Notes

- Each agent maintains clear documentation and progress tracking
- All Azure DevOps work items follow the hierarchy: Epic → Feature → User Story → Task → Subtask
- Development follows Business Central AL best practices
- **Iteration cycles** are built-in:
  - `bc-al-developer` writes/fixes code
  - `bc-app-compiler` compiles and publishes
  - If compilation fails, loop back to `bc-al-developer`
  - If compilation succeeds, `bc-test-runner` executes tests
  - If tests fail, loop back to `bc-al-developer` (triggers recompilation)
  - Continue until both compilation and testing succeed
- Documentation is created as the final step after all tests pass
