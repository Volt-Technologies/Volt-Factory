# Cancel Sales Order Allocations

## Overview

This guide provides step-by-step instructions for cancelling inventory allocations (reservations) on sales order lines. Cancelling an allocation releases the reserved inventory, making it available for allocation to other orders, while preserving the order line and maintaining a complete audit trail.

## When to Cancel Sales Order Allocations

Consider cancelling sales order allocations in these scenarios:

- **Customer Changes Order**: Customer reduces quantity, changes delivery date, or modifies the order in a way that makes the current reservation unnecessary
- **Order Prioritization**: A higher-priority order requires inventory currently allocated to a standard order
- **Order Cancellation**: Customer cancels the order, but you want to preserve the order record for historical purposes
- **Inventory Reallocation**: Business needs require reallocating inventory to different customers or orders
- **Order Consolidation**: Multiple orders are being combined and allocations need adjustment
- **Supply Chain Disruption**: Supplier delays require reallocating available inventory to different orders

## Prerequisites

Before cancelling sales order allocations, verify:

1. **Document Status**: The sales order must be in "Open" status
   - Orders in "Released" status must be reopened before cancellation
   - Use the "Reopen" action on the sales order to change status back to "Open"

2. **Shipping Status**: The order line must not have been shipped
   - Lines with "Quantity Shipped" greater than zero cannot have allocations cancelled
   - Partial shipments prevent cancellation of the entire line's allocation

3. **Warehouse Status**: The order line must not have an active warehouse shipment
   - If warehouse shipment documents exist for the line, they must be deleted first
   - Coordinate with warehouse operations before cancellation

4. **Active Allocations**: The order line must have active reservations
   - Lines without reservations will not be available for cancellation
   - Use the "Reserve" action to view current allocations

5. **User Permissions**: You must have appropriate permissions to modify sales lines and reservation entries

## Step-by-Step: Cancel Single or Multiple Sales Order Line Allocations

### Step 1: Open the Sales Order

1. Press **Alt+Q** to open the Search function
2. Type "Sales Orders" and press **Enter**
3. Locate and open the desired sales order
   - Use filters to narrow down the list (customer, order date, status, etc.)
   - Double-click the order to open it

**Expected Result**: The Sales Order page opens, displaying the order header and lines.

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

2. Check the **Allocation Status** field (appears after Reserved Quantity)
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

![Cancel Allocation button on Sales Order](images/sales-order-cancel-allocation-button.png)
*The Cancel Allocation button is located in the Actions ribbon along with other allocation-related actions*

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
   - **ALLOC-REALLOC**: Reallocating to different order
   - **ALLOC-PRIORITY**: Higher priority order requirement
   - **ALLOC-CUSTCHG**: Customer requested change
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
   - The field may appear with gray/subordinate styling
   - This indicates the allocation has been cancelled

2. **Reserved Quantity** field updates to **0** (zero)
   - The inventory is no longer reserved for this line
   - The standard BC quantity may take a moment to refresh

3. Additional information (visible via personalization or drill-down):
   - **Allocation Cancelled Date**: Shows today's date
   - **Allocation Cancelled By**: Shows your user ID

**Expected Result**: The selected lines now show Cancelled status and zero reserved quantity.

## Viewing Cancellation History

After cancelling allocations, you can view the history:

### From the Sales Order

1. On the sales order page, click **Actions**
2. Navigate to **Functions** group
3. Click **Allocation History**

**Expected Result**: The Allocation Cancellation History page opens, filtered to show only cancellations for the current sales order.

### History Details

The history record shows:
- Entry number (unique identifier)
- Cancellation date and time
- Document type and number
- Line number
- Item number and description
- Location code
- Quantity cancelled
- Customer number and name
- Cancelled by user ID
- Cancellation reason code
- Original reservation entry number

## Business Rules and Validation

The system enforces the following rules during cancellation:

### Document-Level Validations

1. **Document Must Exist**: The sales order must exist in the database
   - Error: "Cannot cancel allocation: Sales order not found"

2. **Document Must Be Open**: The order status must be "Open"
   - Error: "Cannot cancel allocation: Document must be in Open status"

### Line-Level Validations

3. **No Shipped Quantity**: The line's Quantity Shipped must be zero
   - Error: "Cannot cancel allocation: Line has already been partially or fully shipped"

4. **No Warehouse Shipment**: The line must not have an existing warehouse shipment
   - Error: "Cannot cancel allocation: Line has an existing warehouse shipment"

5. **Not Already Cancelled**: The Allocation Status must not already be "Cancelled"
   - Error: "Cannot cancel allocation: Allocation is already cancelled"

### Reservation-Level Validations

6. **Must Have Active Reservations**: The line must have reservation entries with:
   - Reservation Status not equal to "Prospect"
   - VT Is Cancelled = false

7. **Return Orders Not Supported**: Sales Return Orders cannot have allocations cancelled
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

### 2. Sales Line Updates

The sales line is updated with:
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
- Customer number and name
- Source type (37 for Sales Line)

### 4. Inventory Availability Update

- The reserved inventory is released
- The quantity becomes available for allocation to other orders
- No physical inventory quantities change
- Item Ledger Entries are not affected

## Tips and Best Practices

### Before Cancelling

1. **Communicate with Stakeholders**: Notify warehouse, customer service, and other relevant parties before cancelling allocations
2. **Review Reservation Details**: Use the "Reserve" function to understand exactly what's allocated before cancelling
3. **Check Related Orders**: Verify if the inventory is needed for other pending orders
4. **Document Business Reason**: Be prepared to select an accurate reason code

### During Cancellation

1. **Select Appropriate Reason Code**: Choose the reason code that best describes the business justification
2. **Cancel in Batches**: If cancelling many lines, consider processing them in groups for better control
3. **Verify Selection**: Double-check you've selected the correct lines before confirming

### After Cancellation

1. **Verify Results**: Always check that the cancellation completed as expected
2. **Review History**: Check the history record to ensure all details are captured correctly
3. **Reallocate if Needed**: If inventory should be allocated elsewhere, create new reservations on the target orders
4. **Communicate Completion**: Notify relevant parties that the cancellation is complete

### Process Efficiency

1. **Use Multi-Select**: When cancelling multiple lines, select them all at once rather than processing one at a time
2. **Pre-Filter Orders**: Use filters on the Sales Orders list to quickly find orders needing cancellation
3. **Leverage History**: Review past cancellation history to understand patterns and improve processes

## Common Scenarios

### Scenario 1: Customer Reduces Order Quantity

**Situation**: Customer reduces order quantity from 100 to 50 units, but 100 units are already reserved.

**Steps**:
1. Open the sales order
2. Reduce the Quantity field on the line from 100 to 50
3. The Reserved Quantity still shows 100 (over-reserved)
4. Select the line and click **Cancel Allocation**
5. Select reason code "ALLOC-CUSTCHG" (Customer requested change)
6. After cancellation, use the **Reserve** function to reserve 50 units
7. The Reserved Quantity now matches the Quantity (50)

### Scenario 2: Prioritizing Rush Order

**Situation**: A rush order needs inventory that's currently allocated to a standard order.

**Steps**:
1. Open the standard order (lower priority)
2. Identify the line with the needed item
3. Note the Reserved Quantity (e.g., 25 units)
4. Select the line and click **Cancel Allocation**
5. Select reason code "ALLOC-PRIORITY" (Higher priority order requirement)
6. Open the rush order (higher priority)
7. Use the **Reserve** function to allocate the 25 units to the rush order

### Scenario 3: Order Cancellation

**Situation**: Customer cancels the entire order, but you want to preserve the order record.

**Steps**:
1. Open the sales order
2. Select all lines (Ctrl+A in the lines section, or manually select each)
3. Click **Cancel Allocation**
4. Select reason code "CANCEL-ORDER" (Order cancelled by customer)
5. After cancellation, change the order status or add comments explaining the cancellation
6. The order remains in the system with cancelled allocations for future reference

## Troubleshooting

For detailed troubleshooting information, see the [Troubleshooting Guide](troubleshooting.md).

### Quick Reference

| Issue | Likely Cause | Quick Fix |
|-------|--------------|-----------|
| Cancel Allocation button is disabled | Document is not in Open status | Use "Reopen" action to change status to Open |
| "No lines with valid allocations" message | Selected lines don't have active reservations | Verify lines have Reserved Quantity > 0 |
| "Line has been shipped" error | Partial or full shipment has occurred | Cannot cancel; allocation is locked by shipment |
| "Warehouse shipment exists" error | Active warehouse shipment document exists | Delete or process warehouse shipment first |

## Related Topics

- **[Overview](overview.md)**: Understand the purpose and scope of allocation cancellation
- **[Getting Started](getting-started.md)**: Prerequisites and access information
- **[View Cancellation History](view-cancellation-history.md)**: Review and analyze cancellation records
- **[Field Reference](field-reference.md)**: Complete field descriptions
- **[Troubleshooting](troubleshooting.md)**: Detailed error resolution
