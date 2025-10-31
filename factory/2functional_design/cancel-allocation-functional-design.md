# Cancel Allocation in Sales and Purchase Documents - Functional Design

## Executive Summary

This document provides a comprehensive functional design for implementing a "Cancel Allocation" feature in Microsoft Dynamics 365 Business Central. The feature enables users to cancel reservations (allocations) in Sales Orders and Purchase Orders while maintaining a complete audit trail for compliance and tracking purposes.

## Business Context

### Current State
- Business Central uses the Reservation Entry table (337) to manage allocations between supply and demand
- Users can create manual reservations through the Reservation page (498)
- Once created, reservations can only be deleted entirely - no cancellation tracking exists
- No audit trail is maintained when reservations are removed

### Future State
- Users can cancel allocations with a single action from document pages
- Cancelled allocations are tracked with full audit trail
- Reserved inventory is properly released back to available stock
- System maintains compliance with audit requirements

## BC Reservation System Research Summary

### Key Findings

1. **Reservation Entry Structure (Table 337)**
   - Stores reservation records as paired entries (positive for supply, negative for demand)
   - Key fields: Entry No., Item No., Location Code, Quantity (Base), Reservation Status
   - Field "Disallow Cancellation" can prevent cancellation
   - Uses Source Type (37 for Sales, 39 for Purchase) to identify origin

2. **Current Cancellation Mechanism**
   - BC allows deletion of reservation entries through Reservation Entries page
   - No built-in soft delete or cancellation status
   - No audit trail when reservations are removed
   - Field "Disallow Cancellation" exists but is rarely used

3. **Integration Points**
   - Sales Line (Table 37): Reserved Quantity and Reserved Qty. (Base) are FlowFields
   - Purchase Line (Table 39): Similar reservation FlowFields
   - Reservation Management Codeunit (99000845) handles core logic
   - Pages 498 (Reservation) and 497 (Reservation Entries) provide UI

## Functional Requirements

### 1. Data Model Design

#### 1.1 New Table: Allocation Cancellation History (50100)

**Purpose:** Track all allocation cancellation events for audit and compliance

**Fields:**
- Entry No. (Integer, AutoIncrement) - Primary key
- Document Type (Enum) - Sales/Purchase document type
- Document No. (Code[20]) - Document number
- Line No. (Integer) - Line number
- Source Type (Integer) - 37 for Sales, 39 for Purchase
- Item No. (Code[20]) - Item that was allocated
- Variant Code (Code[10]) - Item variant
- Location Code (Code[10]) - Location
- Quantity Cancelled (Decimal) - Cancelled quantity
- Quantity Cancelled (Base) (Decimal) - Base quantity
- Cancellation Date (Date) - Date of cancellation
- Cancellation Time (Time) - Time of cancellation
- Cancelled By User ID (Code[50]) - User who cancelled
- Cancellation Reason Code (Code[10]) - Link to Reason Codes
- Original Reservation Entry No. (Integer) - Link to original reservation
- Customer/Vendor No. (Code[20]) - Trading partner
- Customer/Vendor Name (Text[100]) - Trading partner name

#### 1.2 Table Extensions

**Sales Line Extension (50110)**
- Allocation Status (Enum: Active, Cancelled)
- Allocation Cancelled Date (Date)
- Allocation Cancelled By (Code[50])
- Cancellation History Exists (Boolean)

**Purchase Line Extension (50111)**
- Same fields as Sales Line Extension

**Reservation Entry Extension (50112)**
- Is Cancelled (Boolean)
- Cancellation Entry No. (Integer) - Link to history
- Cancellation Date (DateTime)

#### 1.3 New Enum: Allocation Status (50100)
- Values: Active, Cancelled

### 2. User Interface Design

#### 2.1 Sales Order Page Extension (50130)

**New Actions:**
- Location: Line → Functions menu
- Action: "Cancel Allocation"
- Visibility: Enabled when line has reservation and can be cancelled
- Icon: Cancel or Remove icon
- Shortcut Key: Ctrl+Shift+C

**Visual Indicators:**
- Cancelled allocations shown with strikethrough or grayed text
- New field "Allocation Status" visible in lines
- FactBox showing cancellation history summary

#### 2.2 Purchase Order Page Extension (50131)

**Similar to Sales Order:**
- Same action structure
- Same visual indicators
- Same validation rules

#### 2.3 New Pages

**Allocation Cancellation History List (50120)**
- Shows all cancellation records
- Filters by date, user, document, item
- Sortable by all key fields
- Export to Excel capability

**Allocation Cancellation Card (50121)**
- Detailed view of single cancellation
- Shows all fields including audit trail
- Links to original document and reservation

### 3. Business Logic and Rules

#### 3.1 Cancellation Validation Rules

**Can Cancel When:**
- Document Status = Open (not Released or Posted)
- Quantity Shipped/Received = 0
- No warehouse shipment/receipt exists
- User has permission "CANCEL-ALLOC"
- Line has active reservation (Reserved Quantity > 0)

**Cannot Cancel When:**
- Document is released or posted
- Partial shipment/receipt exists
- Warehouse document exists
- Field "Disallow Cancellation" = TRUE in Reservation Entry

#### 3.2 Cancellation Process Flow

1. **User Initiates Cancellation**
   - Selects line with reservation
   - Clicks Cancel Allocation action

2. **System Validation**
   - Check all validation rules
   - Display error if any rule fails

3. **Reason Code Prompt**
   - System prompts for mandatory reason code
   - User can add optional comments

4. **Confirmation Dialog**
   - "Are you sure you want to cancel the allocation for this line?"
   - Show quantity being cancelled

5. **Execute Cancellation**
   - Mark Reservation Entry as cancelled (don't delete)
   - Create history record
   - Update line extension fields
   - Release inventory

6. **Post-Cancellation**
   - Refresh page to show new status
   - Display confirmation message
   - Update related statistics

#### 3.3 Inventory Impact

**When Cancellation Occurs:**
- Reserved quantity on Reservation Entry set to 0
- Is Cancelled flag set to TRUE
- Item availability recalculated
- Planning system notified (if active)
- Warehouse availability updated

### 4. Integration Points

#### 4.1 Standard BC Components

**Reservation Management (Codeunit 99000845)**
- Subscribe to OnBeforeDeleteReservEntry event
- Prevent deletion if cancellation required
- Redirect to cancellation process

**Item Availability (Page 157)**
- Exclude cancelled reservations from calculations
- Show cancelled quantity separately if needed

**Sales/Purchase Statistics**
- Update reserved quantity calculations
- Show cancelled allocations separately

#### 4.2 Reporting Integration

**New Reports:**
- Allocation Cancellation Report (50140)
- Cancellation by User Report (50141)
- Cancellation Trend Analysis (50142)

### 5. User Workflows

#### 5.1 Cancel Sales Order Allocation

**Actor:** Sales Processor

**Preconditions:**
- Sales Order with reserved lines exists
- User has cancellation permission

**Steps:**
1. Open Sales Order
2. Select line with reservation
3. Click Line → Functions → Cancel Allocation
4. Select reason code
5. Confirm cancellation
6. System updates allocation status

**Postconditions:**
- Reservation marked as cancelled
- Inventory released
- History record created

#### 5.2 View Cancellation History

**Actor:** Sales Manager

**Steps:**
1. Open Sales Order
2. Click Navigate → Allocation History
3. View cancellation details
4. Export to Excel if needed

### 6. Error Messages and Handling

#### 6.1 Validation Errors

- "Cannot cancel allocation for released order. Please reopen the order first."
- "Cannot cancel allocation for partially shipped line."
- "Cannot cancel allocation with existing warehouse shipment."
- "You do not have permission to cancel allocations."
- "No allocation exists for this line."

#### 6.2 System Errors

- Handle locked Reservation Entry records
- Handle concurrent user modifications
- Rollback on partial failure

## Object ID Allocation

Based on the 50100-50149 range constraint:

### Tables (50100-50109)
- 50100: Allocation Cancellation History

### Table Extensions (50110-50119)
- 50110: Sales Line Extension
- 50111: Purchase Line Extension
- 50112: Reservation Entry Extension

### Pages (50120-50129)
- 50120: Allocation Cancellation History List
- 50121: Allocation Cancellation Card

### Page Extensions (50130-50139)
- 50130: Sales Order Extension
- 50131: Purchase Order Extension
- 50132: Sales Order Subform Extension
- 50133: Purchase Order Subform Extension

### Codeunits (50140-50149)
- 50140: Allocation Cancellation Mgt.
- 50141: Cancel Sales Allocation
- 50142: Cancel Purchase Allocation

### Reports (50143-50145)
- 50143: Allocation Cancellation Report
- 50144: Cancellation by User Report
- 50145: Cancellation Trend Analysis

### Enums (50100-50102)
- 50100: Allocation Status
- 50101: Cancellation Source Type

### Permission Sets
- 50100: CANCEL-ALLOC - Cancel Allocation Permission

## Acceptance Criteria

### Functional Acceptance
1. ✅ Cancel Allocation action visible on Sales/Purchase Order pages
2. ✅ Action enabled only for valid cancellation scenarios
3. ✅ Reason code mandatory for cancellation
4. ✅ Reservation entries marked as cancelled (not deleted)
5. ✅ Inventory properly released after cancellation
6. ✅ Complete audit trail in history table
7. ✅ Visual indicators show cancellation status

### Performance Criteria
1. ✅ Cancellation completes in < 2 seconds
2. ✅ Page refresh in < 1 second
3. ✅ History lookup in < 1 second
4. ✅ No blocking of other users

### Security Criteria
1. ✅ Permission-based access control
2. ✅ Audit trail cannot be modified
3. ✅ User identification captured

## Assumptions and Decisions

### Assumptions
1. Reason Codes table exists and is configured
2. Users have appropriate base BC permissions
3. Warehouse Management may or may not be enabled
4. Planning worksheets may or may not be used

### Design Decisions
1. **Soft Delete vs Hard Delete:** Chose soft delete (marking as cancelled) to preserve audit trail
2. **History Table:** Separate table for history rather than using Change Log
3. **Permission Model:** New permission set rather than extending existing ones
4. **Visual Indicators:** Strikethrough text chosen for clarity
5. **Reason Codes:** Mandatory to ensure compliance

## Edge Cases and Exception Handling

### Edge Cases
1. **Partial Reservations:** If only part of quantity is reserved, cancel only reserved portion
2. **Multiple Reservations:** If line has multiple reservation entries, cancel all
3. **Item Tracking:** If serial/lot numbers involved, maintain tracking in history
4. **Transfer Orders:** Not included in initial scope

### Exception Scenarios
1. **Concurrent Modifications:** Use record locking to prevent conflicts
2. **System Failure During Cancellation:** Transaction rollback ensures consistency
3. **Missing Reservation Entry:** Show appropriate error message

## Testing Scenarios

### Unit Testing
1. Test validation rules for each scenario
2. Test history record creation
3. Test inventory release calculations
4. Test permission checks

### Integration Testing
1. Test with warehouse management enabled
2. Test with planning worksheet active
3. Test with multiple users
4. Test with item tracking

### User Acceptance Testing
1. Sales order cancellation workflow
2. Purchase order cancellation workflow
3. History viewing and reporting
4. Permission validation

## Migration and Deployment

### Deployment Steps
1. Deploy table and table extensions
2. Deploy pages and page extensions
3. Deploy codeunits
4. Configure permissions
5. Configure reason codes
6. User training

### No Data Migration Required
- New feature, no existing data to migrate
- History starts accumulating after deployment

## Future Enhancements

### Phase 2 Possibilities
1. Extend to Transfer Orders
2. Add approval workflow for cancellations
3. Integration with Power BI for analytics
4. Email notifications for cancellations
5. Automatic cancellation for expired reservations

## Handoff to Technical Designer

### Key Technical Considerations
1. **Event Subscriptions:** Subscribe to Reservation Entry events to intercept deletions
2. **Transaction Handling:** Ensure all updates occur within single transaction
3. **Performance:** Consider indexing on history table for large volumes
4. **Error Handling:** Comprehensive try-catch blocks with meaningful messages
5. **Logging:** Consider adding detailed logging for troubleshooting

### Technical Patterns to Follow
1. Use BC standard patterns for table extensions
2. Follow BC UI guidelines for page extensions
3. Use standard BC confirmation dialogs
4. Implement standard BC permission model
5. Use BC standard date/time handling

### Integration Points Requiring Attention
1. Reservation Management codeunit integration
2. Item availability calculation updates
3. Statistics page calculations
4. Warehouse management integration (if enabled)

---

## Document Control

- **Version:** 1.0
- **Author:** BC Functional Designer Agent
- **Date:** 2025-10-29
- **Status:** Complete
- **Next Step:** Technical Design Phase