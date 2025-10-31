# Development Implementation to Completion: [Feature Name]

## Prerequisites

This workflow assumes:
- ✅ Technical design has been completed
- ✅ Azure DevOps technical subtasks exist with detailed AL specifications
- ✅ Object designs (tables, pages, codeunits) are documented
- ✅ Algorithms and implementation details are specified

If you don't have a technical design yet, use `03_functional_to_technical_design.md` or `04_functional_to_completion.md` first.

---

## Workflow Scope

This workflow starts from existing technical specifications and executes development through to documentation.

**Workflow**: Existing Technical Design → Development → Compilation/Publishing → Testing → Documentation

---

## Phase 1: Development

**Agent**: `bc-al-developer`

**Responsibilities**:

### 1. Retrieve Technical Specifications
- Call the `azure-devops-manager` agent to retrieve all technical tasks from Azure DevOps
- Read and understand technical specifications from each subtask's Description field

### 2. Implement AL Code
Work through tasks sequentially, implementing each one in the `BC` folder:

**Tables**:
- Create table extensions or new tables as specified
- Add fields with correct IDs, data types, and properties
- Implement field validation procedures
- Set up relationships and keys

**Pages**:
- Create page extensions or new pages
- Add actions, buttons, and UI elements
- Implement field layouts and visibility logic
- Add event handlers for user interactions

**Codeunits**:
- Create codeunits with specified functions
- Implement algorithms as designed
- Add proper error handling and validation
- Subscribe to Business Central events
- Integrate with existing BC functionality

**Best Practices**:
- Follow AL coding standards
- Use proper object numbering conventions
- Add meaningful comments and documentation
- Implement comprehensive error messages
- Ensure code maintainability

### 3. Write Unit Tests
In the `BC Test` folder, create tests for each feature:
- Test normal operation scenarios
- Test edge cases and boundary conditions
- Test error handling and validation
- Test integration points
- Follow AAA pattern (Arrange, Act, Assert)

### 4. Incremental Building
- Build the app incrementally at logical checkpoints
- Verify code compiles as you go
- Fix any issues immediately

### 5. Trigger Compilation and Publishing
After completing all implementations, request compilation and publishing (Phase 2)

**Output**: Complete AL code implementation in `BC` folder and unit tests in `BC Test` folder.

---

## Phase 2: Compilation and Publishing

**Agent**: `bc-app-compiler`

**Responsibilities**:
1. Compile the Business Central app from the `BC` folder
2. Compile the test app from the `BC Test` folder
3. Publish the compiled app to the Business Central environment
4. Report detailed results:
   - Compilation status (success/failures)
   - Publishing status
   - Error messages with file/line references

**Iteration Cycle**:
5. If compilation or publishing fails:
   - Provide detailed error information
   - `bc-al-developer` analyzes errors and fixes code
   - Retry compilation and publishing
6. Continue until the app compiles and publishes successfully
7. Once successful, proceed to Phase 3 (Testing)

---

## Phase 3: Testing

**Agent**: `bc-test-runner`

**Responsibilities**:
1. Execute all unit tests via Business Central's AL Test Tool web interface
2. Monitor test execution (may take 10-20+ minutes)
3. Capture comprehensive test results:
   - Total passed/failed test counts
   - Detailed error messages for each failure
   - Stack traces and assertion failures
   - Test codeunit and test procedure names
   - Execution times

**Iteration Cycle**:
4. If tests fail:
   - Provide detailed failure information
   - `bc-al-developer` analyzes failures and fixes code or tests
   - Trigger recompilation and republishing (Phase 2)
   - Re-execute tests
5. Continue until all unit tests pass successfully
6. Once all tests pass, proceed to Phase 4 (Documentation)

---

## Phase 4: Documentation

**Agent**: `gitbook-documentation-builder`

**Responsibilities**:
1. Create comprehensive end-user documentation for the newly implemented features
2. Document all modules and functionality that were developed
3. Generate step-by-step user guides with screenshots captured via Playwright
4. Organize documentation in the appropriate module structure within `docs/Documentation` folder
5. Update the SUMMARY.md file to include new documentation pages
6. Document:
   - **Feature Overview**: What the feature does and why it's useful
   - **Access Instructions**: How to navigate to the feature in Business Central
   - **Step-by-Step Guides**: Detailed instructions for each use case with screenshots
   - **Field Reference**: Description of all fields, their purpose, and validation rules
   - **Business Rules**: Constraints, requirements, and business logic
   - **Troubleshooting**: Common issues and how to resolve them
   - **Examples**: Real-world scenarios showing the feature in action

**Output**: Complete user-facing documentation in GitBook format with screenshots.

---

## Success Criteria

The development to completion workflow is successful when:
1. ✅ All technical tasks are implemented in AL code (Phase 1)
2. ✅ All unit tests are written and structured properly (Phase 1)
3. ✅ The Business Central app compiles without errors (Phase 2)
4. ✅ The app publishes successfully to the environment (Phase 2)
5. ✅ All unit tests execute and pass successfully (Phase 3)
6. ✅ Complete user-facing documentation is created with screenshots (Phase 4)
7. ✅ Documentation is organized properly in the GitBook structure (Phase 4)

---

## Notes

- **Iteration Cycles**: Built-in automated loops ensure quality:
  - `bc-al-developer` writes/fixes code
  - `bc-app-compiler` compiles and publishes
  - If compilation fails, loop back to `bc-al-developer`
  - If compilation succeeds, `bc-test-runner` executes tests
  - If tests fail, loop back to `bc-al-developer` (triggers recompilation)
  - Continue until both compilation and all tests succeed
- **Code Quality**: The developer agent follows AL best practices and coding standards
- **Test Coverage**: Unit tests should cover normal operations, edge cases, and error handling
- **Documentation Quality**: Documentation should be comprehensive, clear, and include visual aids
- All code changes are made in the `BC` folder, all tests in `BC Test` folder
- Documentation is created only after all tests pass successfully
