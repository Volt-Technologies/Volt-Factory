# Cancel Purchase Order Allocations

## Overview

This guide provides step-by-step instructions for cancelling inventory allocations (reservations) on purchase order lines. Cancelling an allocation releases the reserved supply, making it available for allocation to other demand, while preserving the order line and maintaining a complete audit trail.

## When to Cancel Purchase Order Allocations

Consider cancelling purchase order allocations in these scenarios:

- **Vendor Changes Order**: Vendor reduces delivery quantity, changes delivery date, or modifies the order
- **Production Plan Changes**: Manufacturing schedule changes require reallocating incoming components to different production orders
- **Order Reallocation**: A different sales order or production order requires the incoming inventory
- **Order Cancellation**: Vendor cancels delivery, but you want to preserve the purchase order record
- **Supply Chain Adjustments**: Supplier delays require reallocating expected supply to different demands
- **Multi-Source Procurement**: Switching from one supplier to another and need to cancel allocations on the old order

## Prerequisites

Before cancelling purchase order allocations, verify:

1. **Document Status**: The purchase order must be in "Open" status
   - Orders in "Released" status must be reopened before cancellation
   - Use the "Reopen" action on the purchase order to change status back to "Open"

2. **Receiving Status**: The order line must not have been received
   - Lines with "Quantity Received" greater than zero cannot have allocations cancelled
   - Partial receipts prevent cancellation of the entire line's allocation

3. **Warehouse Status**: The order line must not have an active warehouse receipt
   - If warehouse receipt documents exist for the line, they must be deleted first
   - Coordinate with warehouse operations before cancellation

4. **Active Allocations**: The order line must have active reservations
   - Lines without reservations will not be available for cancellation
   - Use the "Reserve" action to view current allocations

5. **User Permissions**: You must have appropriate permissions to modify purchase lines and reservation entries

## Step-by-Step: Cancel Single or Multiple Purchase Order Line Allocations

### Step 1: Open the Purchase Order

1. Press **Alt+Q** to open the Search function
2. Type "Purchase Orders" and press **Enter**
3. Locate and open the desired purchase order
   - Use filters to narrow down the list (vendor, order date, status, etc.)
   - Double-click the order to open it

**Expected Result**: The Purchase Order page opens, displaying the order header and lines.

### Step 2: Verify Document Status

Check the **Status** field in the order header:

- If status is **Open**: Proceed to next step
- If status is **Released** or other:
  1. Click **Actions** > **Functions** > **Reopen**
  2. Confirm the reopen action
  3. Verify status changes to **Open**

**Expected Result**: The Status field displays "Open" and the Cancel Allocation button is enabled.

### Step 3: Identify Lines with Active Allocations

In the order lines section, review each line:

1. Check the **Reserved Quantity** field
   - Lines with a value greater than zero have active allocations
   - Lines with zero have no allocations to cancel

2. Check the **Allocation Status** field (may require personalization to display)
   - **Active**: The line has an active allocation that can be cancelled
   - **Cancelled**: The line's allocation has already been cancelled
   - *Blank/Empty*: The line has never had an allocation

3. To view detailed reservation information:
   - Select the line
   - Click **Line** > **Reserve**
   - Review the reservation entries in the Reservation page
   - Close the Reservation page when done

**Expected Result**: You have identified which lines have allocations that can be cancelled.

### Step 4: Select Lines for Cancellation

You can cancel allocations for one or multiple lines:

**To cancel a single line:**
- Click on the line to select it

**To cancel multiple lines:**
- Click the first line
- Hold **Ctrl** and click additional lines to select them
- Or hold **Shift** and click the last line to select a range

**Important**: The system will automatically filter out any selected lines that don't meet cancellation criteria. You will see a message if no eligible lines were selected.

**Expected Result**: One or more order lines are highlighted/selected.

### Step 5: Initiate Cancellation

1. Click **Actions** in the ribbon
2. Navigate to **Functions** group
3. Click **Cancel Allocation**

Alternatively:
- The **Cancel Allocation** button may appear as a promoted action in the main ribbon for quick access

**Expected Result**: A confirmation dialog appears.

### Step 6: Confirm Cancellation

A confirmation message appears:

> "Are you sure you want to cancel the allocation for X selected line(s)?"

Where X is the number of eligible lines.

- Click **Yes** to proceed with cancellation
- Click **No** to abort the operation

**Expected Result**: If you click Yes, the Reason Code selection dialog appears. If you click No, the operation is cancelled and no changes are made.

### Step 7: Select Reason Code

The Reason Codes page opens in lookup mode:

1. Review the available reason codes
   - The system may filter to show only cancellation-related codes (codes starting with "CANCEL" or "ALLOC")
   - If no filtered codes exist, all reason codes are displayed

2. Select the appropriate reason code by clicking on it:
   - **ALLOC-CANCEL**: General allocation cancellation
   - **ALLOC-REALLOC**: Reallocating to different demand
   - **ALLOC-PRIORITY**: Priority change in production or sales
   - **ALLOC-VENDCHG**: Vendor requested change
   - Or any other configured reason code

3. Click **OK** to confirm selection
   - Or click **Cancel** to abort the entire cancellation operation

**Expected Result**: The reason code is selected and cancellation processing begins.

### Step 8: Processing Confirmation

After processing completes, a success message appears:

> "Successfully cancelled allocations for X line(s)."

Where X is the number of lines that were successfully processed.

**Expected Result**: The message confirms how many allocations were cancelled.

### Step 9: Verify Cancellation Results

Review the order lines to confirm cancellation:

1. **Allocation Status** field changes to **Cancelled**
   - This indicates the allocation has been cancelled
   - The field may need to be added to the subpage via personalization

2. **Reserved Quantity** field updates to **0** (zero)
   - The supply is no longer reserved for specific demand
   - The standard BC quantity may take a moment to refresh

3. Additional information (visible via personalization or drill-down):
   - **Allocation Cancelled Date**: Shows today's date
   - **Allocation Cancelled By**: Shows your user ID

**Expected Result**: The selected lines now show Cancelled status and zero reserved quantity.

## Viewing Cancellation History

After cancelling allocations, you can view the history:

### From the Purchase Order

1. On the purchase order page, click **Actions**
2. Navigate to **Functions** group
3. Click **Allocation History**

**Expected Result**: The Allocation Cancellation History page opens, filtered to show only cancellations for the current purchase order.

### History Details

The history record shows:
- Entry number (unique identifier)
- Cancellation date and time
- Document type and number
- Line number
- Item number and description
- Location code
- Quantity cancelled
- Vendor number and name
- Cancelled by user ID
- Cancellation reason code
- Original reservation entry number

## Business Rules and Validation

The system enforces the following rules during cancellation:

### Document-Level Validations

1. **Document Must Exist**: The purchase order must exist in the database
   - Error: "Cannot cancel allocation: Purchase order not found"

2. **Document Must Be Open**: The order status must be "Open"
   - Error: "Cannot cancel allocation: Document must be in Open status"

### Line-Level Validations

3. **No Received Quantity**: The line's Quantity Received must be zero
   - Error: "Cannot cancel allocation: Line has already been partially or fully received"

4. **No Warehouse Receipt**: The line must not have an existing warehouse receipt
   - Error: "Cannot cancel allocation: Line has an existing warehouse receipt"

5. **Not Already Cancelled**: The Allocation Status must not already be "Cancelled"
   - Error: "Cannot cancel allocation: Allocation is already cancelled"

### Reservation-Level Validations

6. **Must Have Active Reservations**: The line must have reservation entries with:
   - Reservation Status not equal to "Prospect"
   - VT Is Cancelled = false

7. **Return Orders Not Supported**: Purchase Return Orders cannot have allocations cancelled
   - Lines on return orders are automatically filtered out

### Automatic Handling

- If you select multiple lines and some don't meet the criteria, the system will process only the eligible lines
- A message displays: "No lines with valid allocations were found to cancel" if no selected lines are eligible
- Each line is validated individually before processing

## What Happens During Cancellation

When you cancel an allocation, the system performs these operations:

### 1. Reservation Entry Updates

For each active reservation entry on the line:
- **VT Is Cancelled** field set to **True**
- **VT Cancellation Entry No.** set to the history entry number
- **VT Cancellation DateTime** set to current date and time
- **Quantity** field set to **0**
- **Quantity (Base)** field set to **0**

The reservation entry remains in the system but is marked as cancelled and has zero quantity.

### 2. Purchase Line Updates

The purchase line is updated with:
- **VT Allocation Status** set to **Cancelled**
- **VT Allocation Cancelled Date** set to today's date
- **VT Allocation Cancelled By** set to your user ID

### 3. History Record Creation

A new record is created in the VT Allocation Cancellation History table with:
- Auto-incremented entry number
- Document type, number, and line number
- Item number, variant code, location code, and unit of measure
- Quantity cancelled (from reservation entry)
- Cancellation date, time, and user ID
- Reason code and optional comments
- Original reservation entry number
- Vendor number and name
- Source type (39 for Purchase Line)

### 4. Supply Availability Update

- The reserved supply is released from specific demand
- The incoming quantity can be allocated to other orders or production
- No physical inventory quantities change
- Item Ledger Entries are not affected

## Tips and Best Practices

### Before Cancelling

1. **Communicate with Stakeholders**: Notify production planning, sales, and warehouse before cancelling allocations
2. **Review Reservation Details**: Use the "Reserve" function to understand what demand is linked to the supply
3. **Check Dependent Demands**: Verify if sales orders or production orders are expecting this supply
4. **Document Business Reason**: Be prepared to select an accurate reason code

### During Cancellation

1. **Select Appropriate Reason Code**: Choose the reason code that best describes the business justification
2. **Cancel in Batches**: If cancelling many lines, consider processing them in groups for better control
3. **Verify Selection**: Double-check you've selected the correct lines before confirming

### After Cancellation

1. **Verify Results**: Always check that the cancellation completed as expected
2. **Review History**: Check the history record to ensure all details are captured correctly
3. **Reallocate if Needed**: If supply should be allocated elsewhere, create new reservations on the target demands
4. **Communicate Completion**: Notify relevant parties that the cancellation is complete
5. **Update Production Plans**: If the cancelled supply was allocated to production, update production schedules

### Process Efficiency

1. **Use Multi-Select**: When cancelling multiple lines, select them all at once rather than processing one at a time
2. **Pre-Filter Orders**: Use filters on the Purchase Orders list to quickly find orders needing cancellation
3. **Leverage History**: Review past cancellation history to understand patterns and improve processes

## Common Scenarios

### Scenario 1: Vendor Reduces Delivery Quantity

**Situation**: Vendor can only deliver 50 units instead of the ordered 100 units, but 100 units are allocated to a sales order.

**Steps**:
1. Open the purchase order
2. Reduce the Quantity field on the line from 100 to 50
3. The Reserved Quantity still shows 100 (over-reserved)
4. Select the line and click **Cancel Allocation**
5. Select reason code "ALLOC-VENDCHG" (Vendor requested change)
6. After cancellation, use the **Reserve** function to reserve 50 units to the sales order
7. Create additional purchase orders or expedite other suppliers for the remaining 50 units

### Scenario 2: Production Priority Change

**Situation**: Production schedule changes and components from Purchase Order A need to be reallocated to a different production order.

**Steps**:
1. Open Purchase Order A
2. Identify the line with the needed component (e.g., 200 units allocated to Production Order 001)
3. Select the line and click **Cancel Allocation**
4. Select reason code "ALLOC-PRIORITY" (Priority change)
5. Navigate to the Reservation page for the new production order (Production Order 002)
6. Reserve the 200 units from Purchase Order A to Production Order 002

### Scenario 3: Switching Suppliers

**Situation**: You need to switch from Vendor A to Vendor B for an item, and need to cancel allocations on Vendor A's purchase order.

**Steps**:
1. Create a new purchase order for Vendor B with the required quantity
2. Open Vendor A's purchase order
3. Select all lines that need to be reallocated (Ctrl+A or manual selection)
4. Click **Cancel Allocation**
5. Select reason code "ALLOC-REALLOC" (Reallocating to different order)
6. On the new Vendor B purchase order, use the **Reserve** function to link the supply to the original demands (sales orders, production orders, etc.)
7. Consider deleting or archiving Vendor A's purchase order if it's no longer needed

### Scenario 4: Vendor Cancels Delivery

**Situation**: Vendor cancels the purchase order, but you want to preserve the order record for future reference and audit.

**Steps**:
1. Open the purchase order
2. Select all lines (Ctrl+A in the lines section, or manually select each)
3. Click **Cancel Allocation**
4. Select reason code "CANCEL-ORDER" (Order cancelled)
5. After cancellation, add comments to the purchase order header explaining the vendor cancellation
6. Create new purchase orders with alternative vendors if needed
7. The original order remains in the system with cancelled allocations

## Understanding Supply and Demand Relationships

Purchase order allocations typically link to:

**Sales Orders**: Purchase order line supplies inventory for a specific sales order line
- When cancelled, the sales order line shows reduced or zero reserved quantity
- The sales order can be fulfilled from other supply sources or new reservations must be created

**Production Orders**: Purchase order line supplies components for a specific production order
- When cancelled, the production order component line loses its supply link
- Production planning must identify alternative supply or the component will show as shortage

**Assembly Orders**: Purchase order line supplies components for assembly orders
- Similar to production orders, cancelling breaks the supply link
- Assembly availability calculations will reflect the missing supply

**Transfer Orders**: Purchase order line may link to transfer order demands
- Cancellation requires coordination between locations
- Transfer orders may need rescheduling or alternative supply

## Coordination with Warehouse Management

If your organization uses warehouse management:

### Before Cancellation
- Verify no warehouse receipt documents have been created
- Coordinate with warehouse staff to avoid receiving conflicts
- Check if partial receipts have been recorded in warehouse systems

### After Cancellation
- Notify warehouse staff of the cancellation
- Update expected receipt schedules in warehouse systems
- Cancel or modify warehouse receipt documents if they exist

### Warehouse Receipt Conflicts
If you encounter "Line has an existing warehouse receipt" error:
1. Navigate to Warehouse Receipts
2. Find the receipt document linked to the purchase order
3. Delete the warehouse receipt line or entire document
4. Then retry the allocation cancellation

## Impact on Downstream Processes

Cancelling purchase order allocations affects:

**Planning Worksheets**: Planning systems will detect the supply gap and may suggest new purchase orders or alternative supply sources.

**Item Availability**: The item's availability calculations will reflect the reduced or removed supply commitment.

**Sales Promising**: If the supply was linked to sales orders, sales date promising calculations will change.

**Production Scheduling**: If components were allocated to production, production schedules may need adjustment.

**MRP (Material Requirements Planning)**: MRP calculations will regenerate to address the supply gap.

## Troubleshooting

For detailed troubleshooting information, see the [Troubleshooting Guide](troubleshooting.md).

### Quick Reference

| Issue | Likely Cause | Quick Fix |
|-------|--------------|-----------|
| Cancel Allocation button is disabled | Document is not in Open status | Use "Reopen" action to change status to Open |
| "No lines with valid allocations" message | Selected lines don't have active reservations | Verify lines have Reserved Quantity > 0 |
| "Line has been received" error | Partial or full receipt has occurred | Cannot cancel; allocation is locked by receipt |
| "Warehouse receipt exists" error | Active warehouse receipt document exists | Delete or process warehouse receipt first |

## Related Topics

- **[Overview](overview.md)**: Understand the purpose and scope of allocation cancellation
- **[Getting Started](getting-started.md)**: Prerequisites and access information
- **[Cancel Sales Order Allocations](cancel-sales-order-allocation.md)**: Sales-side allocation cancellation
- **[View Cancellation History](view-cancellation-history.md)**: Review and analyze cancellation records
- **[Field Reference](field-reference.md)**: Complete field descriptions
- **[Troubleshooting](troubleshooting.md)**: Detailed error resolution
