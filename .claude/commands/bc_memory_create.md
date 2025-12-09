# Generate Development Memory Log

Generate or update development memory log for maintaining context across Claude Code sessions for the Volt Apparel project.

## When to Use This Command

- End of development session
- After completing major features
- Before switching contexts
- Documenting decisions made
- Tracking technical debt

## Memory Generation Workflow

### Step 1: Gather Session Information

Collect information about:
1. **Features completed**: What was built
2. **Decisions made**: Architecture, design, technical choices
3. **Issues encountered**: Problems and solutions
4. **Work in progress**: Incomplete tasks
5. **Next steps**: Planned work

### Step 2: Generate Memory Document

Create or update `DEVELOPMENT_MEMORY.md` with 12 sections:

#### 1. Last Session Summary
```markdown
## Last Session: [Date]
**Duration**: [hours]
**Focus**: [Feature/Bug Fix/Refactoring]
**Completed**: [What was finished]
**Status**: [Ready for testing/In progress/Blocked]
```

#### 2. Recent Features Implemented
```markdown
## Recent Features
### Style Color Management (Completed 2025-01-15)
- **Objects**: VT Style Color table, VT Style Color Card page
- **Functionality**: Add/edit colors, link to styles, image upload
- **Location**: BC/src/Styles/
- **Tests**: BC_Test/Features/Styles/VTStyleColorTests.Codeunit.al
- **Status**: Compiled, published, tests passing
```

#### 3. Active Development Contexts
```markdown
## Currently Working On
### Cut Ticket Optimization (In Progress)
- **Objective**: Improve posting performance
- **Current**: Analyzing line processing loop
- **Blocker**: Circular FlowField dependency (AL0896)
- **Next**: Refactor to normal field with trigger
```

#### 4. Technical Decisions Made
```markdown
## Key Decisions
### 2025-01-15: Season Validation Approach
- **Decision**: Validate season on style creation, not posting
- **Rationale**: Early validation prevents invalid data entry
- **Impact**: Requires VT Season table extension
- **Alternatives Considered**: Validate at posting (rejected - too late)
```

#### 5. Known Issues / Technical Debt
```markdown
## Technical Debt
### High Priority
- [ ] Fix AL0896 in VT Cut Ticket Header (circular FlowField)
- [ ] Add SetLoadFields to VT Style List page (performance)

### Medium Priority
- [ ] Refactor VT Allocation Engine (complex nested loops)
- [ ] Add indexes to VT Style Color table

### Low Priority
- [ ] Consolidate duplicate fabric calculation logic
- [ ] Update XML comments for public procedures
```

#### 6. Code Patterns Established
```markdown
## Established Patterns
### VT Object Naming
- Tables: VT [Entity Name] (e.g., VT Style, VT Cut Ticket Header)
- Pages: VT [Entity] Card/List/Document
- Codeunits: VT [Function] Management/Posting

### Error Handling
- TryFunctions for recoverable errors
- Error labels with Comment for translation
- Event subscribers for validation extension points
```

#### 7. Azure DevOps Status
```markdown
## Work Item Status
### Epic: Style Management (80% complete)
- Feature: Style Creation ✅ Complete
- Feature: Color Variants ✅ Complete
- Feature: Size Matrix 🔄 In Progress
- Feature: Fabric BOM ⏳ Not Started

### Current Sprint
- 12 tasks completed
- 3 tasks in progress
- 2 tasks blocked (waiting on design)
```

#### 8. Environment Configuration
```markdown
## Current Environment
- **Sandbox**: Volt-Apparel-Dev
- **BC Version**: 24.0
- **Extensions**: Base Application, System Application
- **Launch.json**: Configured for dev environment
- **.objidconfig**: VT range 50100-50199 allocated
```

#### 9. Performance Optimization Notes
```markdown
## Performance Work
### Completed Optimizations
- Added SetLoadFields to VT Style List (15s → 2s)
- Fixed N+N query in cut ticket posting (5min → 15s)

### Planned Optimizations
- Add key to VT Cut Ticket Line (Season + Style + Color)
- Implement temporary table for fabric calculations
```

#### 10. Testing Status
```markdown
## Test Coverage
### Implemented Tests
- VT Style creation and validation (15 tests, all passing)
- VT Season management (8 tests, all passing)
- VT Color variant logic (12 tests, all passing)

### Tests Needed
- VT Cut Ticket posting (complex scenarios)
- VT Fabric BOM calculations (edge cases)
- VT Allocation engine (performance tests)
```

#### 11. Integration Points
```markdown
## External Integrations
### PLM System API
- **Status**: Design complete, implementation pending
- **Endpoint**: /api/v1.0/vt/styles
- **Auth**: OAuth 2.0
- **Next**: Implement API page objects

### Mobile App Integration
- **Status**: Requirements gathering
- **Use Case**: Cut ticket scanning
- **Technology**: Power Apps / REST API
```

#### 12. Next Session Planning
```markdown
## Next Steps
### Immediate (Next Session)
1. Fix AL0896 circular FlowField in VT Cut Ticket Header
2. Implement VT Size Matrix feature
3. Write tests for cut ticket validation

### Short Term (This Week)
4. Complete Style Management epic
5. Begin PLM API implementation
6. Performance testing with production data volumes

### Medium Term (This Month)
7. Mobile app API design
8. Production deployment preparation
```

### Step 3: Update Memory Regularly

Update memory when:
- **After each session**: Log what was accomplished
- **After major decisions**: Document rationale
- **When encountering issues**: Record problems and solutions
- **Before context switch**: Save current state

### Step 4: Use Memory for Session Continuity

At start of new session:
1. Read DEVELOPMENT_MEMORY.md
2. Understand last session context
3. Review next steps
4. Continue from where left off

## Memory Best Practices

### Be Specific
❌ Bad: "Fixed bug"
✅ Good: "Fixed AL0896 circular FlowField in VT Cut Ticket Header.Total Qty by converting to normal field with OnValidate trigger"

### Include Context
❌ Bad: "Added validation"
✅ Good: "Added season expiry validation to VT Style table OnInsert trigger to prevent styles being created for expired seasons (business requirement from user story US-042)"

### Track Decisions
❌ Bad: "Used approach A"
✅ Good: "Chose event subscriber over table extension for Item integration because: 1) Less invasive, 2) Easier to maintain, 3) Allows other extensions to coexist. Rejected table modification and direct extension approaches."

### Link to Artifacts
- Reference file paths: `BC/src/Styles/VTStyle.Table.al`
- Link to Azure DevOps: Work Item #1234
- Note factory documents: `factory/3technical_design/Styles/CreateStyle/`

## Output

Creates/updates `DEVELOPMENT_MEMORY.md` with:
1. Complete session history
2. Technical decisions documented
3. Code patterns established
4. Known issues tracked
5. Next steps planned
6. Context preserved for continuity

## Usage Example

User: "Update development memory before ending session"

The command generates comprehensive memory documentation capturing all context from the current development session for seamless continuation in the next session.
