# Handoff Notes for BC Technical Designer

## Overview
This document provides essential handoff information from the Functional Designer to the Technical Designer for implementing the Cancel Allocation feature in Business Central.

## Completed Functional Design Deliverables

### 1. Research Documentation
- **BC Reservation System Analysis:** Complete understanding of Table 337 (Reservation Entry) structure and behavior
- **Current State Mapping:** Documented how BC currently handles reservations
- **Gap Analysis:** Identified that BC lacks cancellation tracking and audit trail

### 2. Functional Design Document
- **Location:** `factory/2functional_design/cancel-allocation-functional-design.md`
- **Status:** Complete and comprehensive
- **Contents:** Full functional specifications including data model, UI design, business logic, and integration points

### 3. Azure DevOps Work Items
- **Epic 121:** Document Allocation Cancellation System
- **Feature 122:** Cancel Allocation in Sales Documents
- **Feature 123:** Cancel Allocation in Purchase Documents
- **User Story 124:** Cancel allocation on sales order line
- **Task 125:** Design Allocation Cancellation History table
- **Status:** Initial hierarchy created, additional user stories and tasks can be added as needed

## Key Technical Implementation Points

### Critical Design Decisions

1. **Soft Delete Approach**
   - **Decision:** Mark Reservation Entries as cancelled rather than deleting them
   - **Reason:** Preserves audit trail and allows potential reversal
   - **Implementation:** Add "Is Cancelled" field to Reservation Entry via table extension

2. **History Tracking**
   - **Decision:** New dedicated history table rather than using Change Log
   - **Reason:** Specific fields needed, better performance, easier reporting
   - **Implementation:** Table 50100 with comprehensive tracking fields

3. **Permission Model**
   - **Decision:** New permission set "CANCEL-ALLOC"
   - **Reason:** Granular control over who can cancel allocations
   - **Implementation:** Create permission set with specific table and page permissions

### Technical Challenges to Address

1. **Reservation Entry Modification**
   - **Challenge:** Reservation Entry is a core BC table
   - **Solution:** Use table extension with minimal fields
   - **Alternative:** If extension not possible, track state in history table only

2. **FlowField Updates**
   - **Challenge:** Sales/Purchase Line reserved quantity FlowFields need to exclude cancelled
   - **Solution:** May need to override with new FlowFields or use events to adjust calculations

3. **Concurrent User Access**
   - **Challenge:** Multiple users might try to cancel same allocation
   - **Solution:** Implement proper record locking and error handling

### Event Subscriptions Required

```al
// Key events to subscribe to:
1. OnBeforeDeleteReservEntry - Prevent deletion, redirect to cancellation
2. OnAfterReleaseSalesDoc - Prevent cancellation on released orders
3. OnBeforeCalculateItemAvailability - Exclude cancelled reservations
4. OnAfterPostSalesLine - Prevent cancellation of posted lines
```

### Performance Considerations

1. **History Table Indexing**
   - Add secondary keys for common search patterns
   - Consider filtered keys for active vs cancelled

2. **FlowField Calculations**
   - Monitor performance impact of filtering cancelled reservations
   - Consider caching if performance issues arise

3. **Bulk Operations**
   - Design for potential bulk cancellation scenarios
   - Implement progress dialog for long-running operations

## Object ID Allocation Strategy

### Reserved Ranges
- **Tables:** 50100-50109 (1 used, 9 available)
- **Table Extensions:** 50110-50119 (3 used, 7 available)
- **Pages:** 50120-50129 (2 used, 8 available)
- **Page Extensions:** 50130-50139 (4 used, 6 available)
- **Codeunits:** 50140-50149 (3 planned, 7 available)

### Naming Conventions
- Prefix all objects with "VOL" or company prefix
- Use clear, descriptive names
- Include "Cancel" or "Cancellation" in object names for clarity

## Integration Testing Requirements

### Test Scenarios to Implement
1. **Basic Cancellation Flow**
   - Create reservation → Cancel → Verify history
   - Verify inventory release

2. **Edge Cases**
   - Partially shipped orders (should fail)
   - Released orders (should fail)
   - Multiple reservations on same line

3. **Integration Points**
   - Warehouse management enabled/disabled
   - Item tracking (serial/lot numbers)
   - Planning worksheet interactions

### Test Data Requirements
- Items with different reservation policies
- Various document states (Open, Released, Partially Shipped)
- Multiple users with different permissions

## Required Standard BC Patterns

### UI Patterns
```al
// Standard confirmation dialog
if not Confirm('Are you sure you want to cancel the allocation?', false) then
    exit;

// Standard error message
Error('Cannot cancel allocation for released order.');

// Standard success message
Message('Allocation cancelled successfully.');
```

### Data Access Patterns
```al
// Use standard BC record references
RecRef.GetTable(ReservationEntry);

// Standard filtering
ReservationEntry.SetRange("Source Type", 37); // Sales
ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
```

## Questions Needing Business Confirmation

1. **Partial Cancellation**
   - Should users be able to cancel part of a reservation?
   - Current design assumes all-or-nothing

2. **Cancellation Reversal**
   - Should cancelled allocations be reversible?
   - Current design assumes permanent cancellation

3. **Notification Requirements**
   - Should other users be notified of cancellations?
   - Email notifications not currently in scope

4. **Reporting Frequency**
   - How often will cancellation reports be run?
   - Consider data retention policies

## Next Steps for Technical Designer

1. **Review Functional Design Document**
   - Validate technical feasibility of all requirements
   - Identify any additional technical constraints

2. **Create Technical Design Document**
   - Detailed AL code structure
   - Event subscription architecture
   - Error handling strategy

3. **Update Azure DevOps Tasks**
   - Break down functional tasks into technical subtasks
   - Add effort estimates
   - Identify dependencies

4. **Prototype Critical Components**
   - Test Reservation Entry extension approach
   - Validate FlowField calculation changes
   - Confirm permission model works

5. **Review with Functional Designer**
   - Discuss any technical constraints found
   - Agree on implementation approach
   - Finalize object naming

## Contact Information

- **Functional Design Document:** `factory/2functional_design/cancel-allocation-functional-design.md`
- **Azure DevOps Project:** Factory
- **Epic ID:** 121
- **Key Features:** 122 (Sales), 123 (Purchase)

## Risk Mitigation

### High Risk Items
1. **Reservation Entry Modification:** May need escalation if extension insufficient
2. **Performance Impact:** Monitor closely in testing
3. **Integration Complexity:** Warehouse management integration needs careful testing

### Mitigation Strategies
1. Have fallback approach using events only
2. Implement comprehensive logging for troubleshooting
3. Plan phased rollout (Sales first, then Purchase)

---

**Handoff Status:** ✅ Complete
**Date:** 2025-10-29
**Next Action:** Technical Designer to begin technical design phase