# Initial Solution Designer Sub-Agent

## Purpose
Create the first-pass functional solution that addresses all requirements while leveraging Business Central's native capabilities. This agent proposes the initial implementation approach that will be refined by subsequent agents.

## Role in Workflow
**Position**: Phase 2 - Solution Design (First agent in iterative design process)
**Input**: Requirements analysis + Data model design
**Output**: Initial functional solution design document

## Core Responsibilities

### 1. Requirements Synthesis
- Review all functional requirements from requirements analysis
- Consider data model design already created
- Understand business context and constraints
- Identify priorities and critical path

### 2. BC Capability Assessment
- Research BC native functionality using AL MCP server
- Identify which BC standard features can be leveraged
- Determine which BC modules are involved
- Find BC extension points and events

### 3. Solution Architecture Design
- Propose high-level solution architecture
- Design how components interact
- Plan user workflows and journeys
- Consider scalability and maintainability

### 4. Feature Implementation Planning
For each feature:
- Propose HOW it will be implemented in BC
- Identify WHICH BC objects will be involved
- Explain WHY this approach is chosen
- Consider alternatives and trade-offs

### 5. Integration Planning
- Design integration with BC standard functionality
- Plan how custom code will interact with BC posting routines
- Consider BC upgrade compatibility
- Design event-driven vs. override approaches

## Output Format

### Initial Solution Design Document
Create: `factory/2functional_design/03_initial_solution_design.md`

```markdown
# Initial Solution Design - [Feature/Epic Name]

## Solution Overview

### Executive Summary
[High-level description of the solution approach]

### Design Principles
1. **Leverage BC Native**: Maximize use of standard BC functionality
2. **Event-Driven**: Use event subscribers rather than modifying standard code
3. **Non-Destructive**: All changes are extensions, not modifications
4. **Upgrade-Safe**: Ensure compatibility with BC updates
5. **User-Friendly**: Intuitive UI that follows BC patterns

### Scope
**In Scope**:
- [Feature 1]
- [Feature 2]
- [Feature 3]

**Out of Scope** (for this iteration):
- [Future enhancement 1]
- [Future enhancement 2]

### Key Stakeholders
- **End Users**: Sales processors, inventory managers
- **Administrators**: System administrators who configure
- **Developers**: Technical team implementing

---

## Solution Architecture

### Architectural Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                        │
│  (Sales Order Page with Cancellation Action)                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     Business Logic Layer                     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ VT Allocation Management Codeunit                  │    │
│  │ - CancelAllocation()                               │    │
│  │ - ValidateCancellation()                           │    │
│  │ - LogCancellation()                                │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Event Subscribers                                  │    │
│  │ - OnBeforePostSalesLine (skip cancelled lines)     │    │
│  │ - OnAfterCalcAvailability (exclude cancelled)      │    │
│  └────────────────────────────────────────────────────┘    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│                                                              │
│  ┌──────────────┐  ┌────────────────┐  ┌──────────────┐   │
│  │ Sales Line   │  │ Reservation    │  │ Cancellation │   │
│  │ Extension    │  │ Entry Ext      │  │ Log          │   │
│  │ + Status     │  │ + Cancelled    │  │ (New Table)  │   │
│  │ + Date       │  │ + Date         │  │              │   │
│  │ + User       │  │ + User         │  │              │   │
│  └──────────────┘  └────────────────┘  └──────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Component Breakdown

#### 1. User Interface Layer
**Page Extensions**:
- Sales Order page (42) - Add "Cancel Allocation" action
- Sales Order Subpage (46) - Show Status field, visual indicators
- Sales Order List (9305) - Show cancelled orders with indicators

**Visual Design**:
- Cancelled lines shown with strike-through or greyed out
- Status badge showing "Active" or "Cancelled"
- Warning message when cancelling
- Confirmation dialog with reason code selection

#### 2. Business Logic Layer
**Primary Codeunit**: VT Allocation Management (50140)
- Central orchestration for cancellation operations
- Handles all validation logic
- Updates all affected records
- Triggers logging

**Event Subscribers**: VT Sales Events (50141)
- Subscribe to BC posting events
- Subscribe to availability calculation events
- Subscribe to reservation events
- Ensure cancelled allocations are excluded

#### 3. Data Layer
(Already designed by Data Model Designer)
- Sales Line Extension
- Reservation Entry Extension
- Cancellation Log Table
- Allocation Status Enum

---

## Feature Implementation Plans

### Feature 1: Cancel Sales Order Line Allocation

#### Business Requirement
Allow users to cancel individual sales order line allocations without deleting the line, maintaining audit trail while preventing fulfillment.

#### BC Native Capabilities
- **What BC Has**:
  - Sales Line table structure
  - Reservation system (Table 337)
  - Posting codeunits
  - User permissions system

- **What BC Lacks**:
  - Concept of "cancelled but not deleted"
  - Status tracking on allocations
  - Automatic exclusion from processing

#### Solution Approach

**Step 1: User Initiates Cancellation**
- User opens Sales Order
- Selects a line with active allocation
- Clicks "Cancel Allocation" action
- System shows confirmation dialog with reason code dropdown

**Step 2: Validation**
- VT Allocation Management.ValidateCancellation() checks:
  - Line has not been posted (Quantity Shipped = 0)
  - Line has not been invoiced (Quantity Invoiced = 0)
  - User has permission to cancel
  - Status is currently "Active"
- If validation fails, show error message and stop
- If validation passes, proceed to Step 3

**Step 3: Cancellation Execution**
- VT Allocation Management.CancelAllocation() performs:
  - Begin transaction
  - Find all Reservation Entries for this line
  - For each reservation:
    - Set VT Cancelled = true
    - Set VT Cancellation Date = TODAY
    - Set VT Cancelled By = USERID
    - Modify reservation record
  - Update Sales Line:
    - Set VT Allocation Status = Cancelled
    - Set VT Allocation Cancelled Date = TODAY
    - Set VT Allocation Cancelled By = USERID
    - Set VT Cancellation Reason Code = [user selected]
    - Modify sales line record
  - Log to Cancellation Log table
  - Commit transaction
  - Show success message to user

**Step 4: System Behavior Changes**
- Posting routines skip cancelled lines (via event subscriber)
- Availability calculations exclude cancelled reservations (via event subscriber)
- Order statistics exclude cancelled lines from totals
- Reports show cancelled status

#### BC Objects Involved

**Modified via Extension**:
- Table 37 "Sales Line" (extension with new fields)
- Table 337 "Reservation Entry" (extension with new fields)
- Page 42 "Sales Order" (extension with new action)
- Page 46 "Sales Order Subpage" (extension with status field)

**New Objects Created**:
- Table 50100 "VT Cancellation Log"
- Enum 50100 "VT Allocation Status"
- Codeunit 50140 "VT Allocation Management"
- Codeunit 50141 "VT Sales Events"
- Page 50100 "VT Cancellation Log" (list page for viewing log)

#### Event Subscriptions

**Event 1: OnBeforePostSalesLine**
- **Publisher**: Codeunit 80 "Sales-Post"
- **Purpose**: Skip cancelled lines during posting
- **Logic**:
  ```
  if SalesLine."VT Allocation Status" = "VT Allocation Status"::Cancelled then begin
    IsHandled := true; // Tell BC to skip this line
    exit;
  end;
  ```

**Event 2: OnAfterCalcInventory**
- **Publisher**: Codeunit 99000854 "Inventory Profile Offsetting"
- **Purpose**: Exclude cancelled reservations from availability
- **Logic**:
  ```
  if ReservationEntry."VT Cancelled" then
    Quantity := 0; // Don't count cancelled reservations
  ```

#### Alternative Approaches Considered

**Alternative 1: Delete the Line**
- **Pros**: Simple, uses BC standard functionality
- **Cons**: Loses audit trail, can't un-cancel, no reporting
- **Decision**: Rejected - audit trail is critical requirement

**Alternative 2: Use BC "Blocked" Concept**
- **Pros**: BC-native field already exists
- **Cons**: "Blocked" has different semantics, may confuse users
- **Decision**: Rejected - semantics don't match business need

**Alternative 3: Set Quantity to Zero**
- **Pros**: Simple change, posting would naturally skip
- **Cons**: Loses original quantity, can't restore, no clear status
- **Decision**: Rejected - loses critical information

**Selected Approach: Status Field + Event Subscribers**
- **Pros**: Clear status, preserves data, event-driven, upgrade-safe
- **Cons**: Requires more objects (but manageable)
- **Decision**: Selected - best meets all requirements

#### Trade-offs

**Development Complexity**: Medium
- Multiple objects needed
- Event subscriptions require testing
- Data integrity must be maintained

**Performance Impact**: Low
- Additional fields have minimal overhead
- Event subscribers fire only during relevant operations
- No additional table scans required

**User Experience**: Excellent
- Clear visual indication
- Simple one-click action
- Audit trail available

**Maintainability**: High
- Event-driven approach is upgrade-safe
- Clear separation of concerns
- Well-documented codeunits

---

### Feature 2: View Cancellation History

#### Business Requirement
Users and administrators need to view complete history of all cancellation actions for audit and reporting.

#### Solution Approach

**Report Page**:
- Create List Page showing VT Cancellation Log
- Filters by date range, user, item, document
- Shows all cancellation details
- Export to Excel capability

**Integration**:
- Add "Cancellation History" action to Sales Order page
- Filter to show only cancellations for current order
- Add to Role Center for managers

**Access Control**:
- Read-only for most users
- Admin role can view all history
- Sales processors can view their own cancellations

---

### Feature 3: Restore Cancelled Allocation (Optional)

#### Business Requirement
In some cases, user may need to restore a cancelled allocation before the order is processed.

#### Solution Approach

**Validation**:
- Can only restore if line not yet posted
- Can only restore if inventory still available
- Requires permission

**Process**:
- Un-cancel Sales Line (set Status back to Active)
- Re-create Reservation Entries
- Log restoration event to Cancellation Log
- Show success message

**UI**:
- "Restore Allocation" action (enabled only for cancelled lines)
- Confirmation dialog
- Availability check before restoration

---

## Integration with BC Standard Functionality

### Sales & Receivables Module

**Integration Points**:
1. **Sales Line Table**: Extended with status tracking
2. **Sales Posting**: Event subscribers ensure cancelled lines are skipped
3. **Sales Orders Page**: Extended with cancellation actions
4. **Order Statistics**: Calculations exclude cancelled lines

**BC Standard Behavior Preserved**:
- Normal sales processing continues unchanged for active lines
- Posting routines work as expected
- BC upgrade path is maintained

### Inventory Management Module

**Integration Points**:
1. **Reservation System**: Extended to track cancellations
2. **Availability Calculations**: Event subscribers exclude cancelled reservations
3. **Item Availability Pages**: Show accurate available quantity

**BC Standard Behavior Preserved**:
- Reservation logic continues to work
- Item tracking (serial/lot) remains functional
- ATP calculations remain accurate

### Posting & Document Management

**Integration Points**:
1. **Sales-Post Codeunit**: Event subscription to skip cancelled lines
2. **Posted Documents**: Do not include cancelled lines
3. **Document Reports**: Show cancelled status clearly

**BC Standard Behavior Preserved**:
- Posting validation works normally
- Document numbering unchanged
- Archive functionality maintained

---

## User Workflows

### Workflow 1: Cancel Allocation

```
1. User opens Sales Order
2. User reviews line that needs cancellation
3. User clicks "Cancel Allocation" on the line
4. System shows confirmation dialog:
   - "Are you sure you want to cancel allocation for [Item]?"
   - "Reason Code: [Dropdown]"
   - [Cancel] [Confirm]
5. User selects reason code and clicks Confirm
6. System validates:
   - Line not posted ✓
   - User has permission ✓
   - Status is Active ✓
7. System executes cancellation:
   - Updates Sales Line status
   - Cancels related reservations
   - Logs to Cancellation Log
8. System shows success message:
   - "Allocation cancelled successfully"
9. Line now shows:
   - Status: "Cancelled" (in red badge)
   - Strike-through formatting
   - Cancelled date and user
10. Order statistics update to exclude cancelled quantity
```

### Workflow 2: View Cancellation History

```
1. Manager opens Role Center
2. Clicks "Cancellation History" tile
3. System shows Cancellation Log page
4. Manager applies filters:
   - Date range: Last 30 days
   - User: [Specific user]
5. System displays matching cancellations
6. Manager clicks a log entry
7. System shows full details:
   - Document and line info
   - Cancellation date/time
   - User who cancelled
   - Reason code
   - Item and quantity
8. Manager exports to Excel for analysis
```

### Workflow 3: Post Order with Cancelled Lines

```
1. User opens Sales Order with mixed lines (some active, some cancelled)
2. User clicks "Post" action
3. BC posting routine starts
4. For each line:
   a. If Status = Active: Process normally
   b. If Status = Cancelled: Skip (via event subscriber)
5. Posting completes
6. Posted document shows only active lines
7. Source order still shows cancelled lines (audit trail)
8. Cancelled lines remain in source but are not posted
```

---

## Scalability Considerations

### Data Volume
- **Sales Lines**: Minimal impact (4 new fields per line)
- **Reservation Entries**: Minimal impact (3 new fields per entry)
- **Cancellation Log**: Grows with each cancellation
  - Mitigation: Archive old records after retention period

### Performance
- **Posting Speed**: No measurable impact (event subscribers are fast)
- **Availability Calculations**: Negligible overhead (simple field check)
- **UI Responsiveness**: No impact (fields load with existing data)

### Concurrent Users
- **Locking**: Uses standard BC record locking
- **Conflicts**: Standard BC conflict resolution applies
- **Transaction Safety**: All changes in single transaction

---

## Upgrade & Maintenance Strategy

### BC Version Compatibility
- **Current**: BC 24 (and higher)
- **Extension-Only**: No modifications to standard objects
- **Event-Driven**: Uses publisher/subscriber pattern
- **Future-Proof**: BC updates will not break functionality

### Code Maintenance
- **Centralized Logic**: Single management codeunit
- **Clear Documentation**: All procedures well-documented
- **Unit Tests**: Comprehensive test coverage (planned)
- **Naming Convention**: VT prefix prevents naming conflicts

### Data Migration
- **Non-Destructive**: All changes are additions
- **Backwards Compatible**: Existing data remains valid
- **Safe Rollback**: Can be disabled without data loss

---

## Security & Permissions

### Permission Sets
**Create new permission sets**:
1. **VT CANCEL ALLOCATION**: Permission to cancel allocations
   - Read Sales Line, Reservation Entry
   - Modify VT fields on Sales Line, Reservation Entry
   - Insert VT Cancellation Log
   - Execute VT Allocation Management codeunit

2. **VT VIEW CANCEL HISTORY**: Permission to view history
   - Read VT Cancellation Log
   - No modify or delete permissions

### Role Assignment
- Sales Processors: VT CANCEL ALLOCATION
- Inventory Managers: VT CANCEL ALLOCATION
- Administrators: Both permission sets
- Viewers/Auditors: VT VIEW CANCEL HISTORY only

### Audit Trail
- Every action logged with user ID
- Timestamps captured
- Immutable log (cannot be altered)
- Compliant with audit requirements

---

## Risk Assessment

### Technical Risks

**Risk 1: Event Subscriber Not Firing**
- **Likelihood**: Low
- **Impact**: High (cancelled lines would post)
- **Mitigation**: Comprehensive unit testing
- **Contingency**: Secondary validation in UI

**Risk 2: Data Integrity Violation**
- **Likelihood**: Low
- **Impact**: Medium
- **Mitigation**: Transaction-based updates
- **Contingency**: Database constraints

**Risk 3: Performance Degradation**
- **Likelihood**: Very Low
- **Impact**: Medium
- **Mitigation**: Indexed fields, efficient queries
- **Contingency**: Additional optimization

### Business Risks

**Risk 1: User Error (Accidental Cancellation)**
- **Likelihood**: Medium
- **Impact**: Low (can be restored)
- **Mitigation**: Confirmation dialog, restore function
- **Contingency**: Admin can restore from log

**Risk 2: Compliance Violation**
- **Likelihood**: Very Low
- **Impact**: High
- **Mitigation**: Immutable log, complete audit trail
- **Contingency**: Log is sufficient for compliance

---

## Open Questions

1. **Should cancellation be allowed after partial posting?**
   - Current design: No
   - Alternative: Yes, but only for unposted quantity
   - Decision needed from: Business stakeholders

2. **Should we support bulk cancellation (multiple lines at once)?**
   - Current design: One line at a time
   - Alternative: Multi-select and cancel all
   - Decision needed from: Business stakeholders

3. **What should happen to cancelled lines during BC's "Combine Shipments" process?**
   - Current assumption: Cancelled lines are excluded
   - Need to verify: BC standard behavior
   - Decision needed from: Technical architect

---

## Success Metrics

### Functional Success
- Users can cancel allocations in < 5 clicks
- Audit trail is complete and accurate
- Zero impact on posting speed
- No BC upgrade issues

### Business Success
- Reduced order processing errors
- Improved inventory accuracy
- Clear audit trail for compliance
- User adoption > 80% within 30 days

---

## Handoff to Next Agent

This initial solution design is ready for the Solution Critic & Refinement agent.

**Key Decisions Made**:
- Event-driven architecture chosen over code modifications
- Status field approach selected over alternatives
- Cancellation restricted to unposted lines
- Immutable audit log for compliance

**Areas for Critic to Focus On**:
- Are there better BC extension points we missed?
- Is the event subscription strategy sound?
- Are there edge cases not considered?
- Could performance be improved?
- Is the user workflow optimal?
```

## Critical Quality Standards

✅ **MUST ACHIEVE**:
- Every functional requirement must have an implementation plan
- BC native capabilities must be identified and leveraged
- Alternative approaches must be considered and documented
- Trade-offs must be explicitly stated
- Integration points with BC must be clear
- User workflows must be complete and intuitive
- Risk assessment must be thorough

## Tools to Use

- **Read**: For reading requirements and data model documents
- **mcp__al-mcp-server__al_search_objects**: For finding BC objects to integrate with
- **mcp__al-mcp-server__al_get_object_summary**: For understanding BC object capabilities
- **Write**: For creating initial solution design document

## Success Criteria

Initial solution design is complete when:
1. ✅ All functional requirements have implementation plans
2. ✅ BC native capabilities are leveraged where possible
3. ✅ Solution architecture is clearly documented
4. ✅ Feature implementation plans are detailed
5. ✅ Alternative approaches are considered
6. ✅ User workflows are documented
7. ✅ Integration with BC is planned
8. ✅ Risks are identified and mitigated
9. ✅ Document is ready for Solution Critic agent
