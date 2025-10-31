# Troubleshooting Guide

## Overview

This guide provides solutions to common issues, error messages, and challenges encountered when using the Allocation Cancellation feature. Issues are organized by category with clear explanations of causes and step-by-step resolution procedures.

## Quick Reference Table

| Error/Issue | Likely Cause | Quick Solution | Section Link |
|-------------|--------------|----------------|--------------|
| Cancel Allocation button is disabled | Document not in Open status | Reopen the document | [Button Issues](#button-disabled-or-not-visible) |
| "Document must be in Open status" | Document is Released | Reopen the document | [Document Status Errors](#document-must-be-in-open-status) |
| "Line has been shipped" | Partial or full shipment posted | Cannot cancel; already shipped | [Shipment/Receipt Errors](#line-has-been-shipped-or-received) |
| "Warehouse shipment exists" | Active warehouse document | Delete warehouse shipment | [Warehouse Errors](#warehouse-shipment-or-receipt-exists) |
| "Allocation is already cancelled" | Already processed | Check history; recreate if needed | [Already Cancelled](#allocation-already-cancelled) |
| "No lines with valid allocations" | No active reservations on selected lines | Verify reservations exist | [No Valid Lines](#no-lines-with-valid-allocations-found) |
| History page is empty | Filters applied or no cancellations | Clear filters | [History Issues](#history-page-shows-no-records) |
| Cannot export to Excel | Excel not configured | Check Excel integration | [Export Issues](#export-to-excel-fails) |

---

## Button and Access Issues

### Cancel Allocation Button is Disabled or Not Visible

**Symptoms**:
- The **Cancel Allocation** button appears grayed out and cannot be clicked
- The button is not visible in the Actions ribbon

**Possible Causes**:

1. **Document Status is Not Open**
   - The document is in Released, Pending Approval, or Posted status
   - Only documents in Open status can have allocations cancelled

2. **No Lines Selected**
   - No order line is currently selected
   - The system cannot determine which lines to cancel

3. **User Permissions**
   - Current user lacks the required permissions to cancel allocations
   - Security settings may restrict the action

4. **Extension Not Installed**
   - The Allocation Cancellation extension is not published to the environment
   - The extension installation failed or is pending

**Resolution Steps**:

**Step 1**: Verify Document Status
1. Look at the **Status** field in the document header
2. If status is anything other than **Open**:
   - Click **Actions** > **Functions** > **Reopen**
   - Confirm the reopen action
   - Verify status changes to **Open**
3. The Cancel Allocation button should now be enabled

**Step 2**: Select a Line
1. Click on any line in the order lines section
2. Verify a line is highlighted/selected
3. The button should become enabled if the document is Open

**Step 3**: Check Permissions
1. Contact your Business Central administrator
2. Request verification of the following permissions:
   - Modify access to Sales Line or Purchase Line table
   - RIMD (Read, Insert, Modify, Delete) access to Reservation Entry table
   - Read and Insert access to VT Allocation Cancel History table
3. Administrator should verify permission sets include the required objects

**Step 4**: Verify Extension Installation
1. Navigate to **Extension Management** (Alt+Q > "Extension Management")
2. Search for "Volt" or "Allocation"
3. Verify the extension is listed and shows status "Installed"
4. If not installed, contact your administrator to publish the extension

---

### Allocation History Button Does Not Open Filtered View

**Symptoms**:
- Clicking **Allocation History** from a sales or purchase order opens the history page
- The history shows all records instead of filtering to the current document

**Cause**:
- Page link filters may not be properly applied
- Filter logic in the page extension may have an issue

**Resolution**:
1. Manually filter the history page:
   - Click in the **Document No.** column header
   - Select **Filter...**
   - Enter the document number from the order
   - Click **OK**
2. Optionally, filter by **Source Type**:
   - 37 for Sales orders
   - 39 for Purchase orders
3. If issue persists, contact your system administrator to verify page extension code

---

## Error Messages During Cancellation

### "Cannot cancel allocation: Sales order not found" (or Purchase order not found)

**Symptoms**:
- Error appears when attempting to cancel allocations
- The error references a sales or purchase order not being found

**Cause**:
- The document was deleted after the lines were selected
- Database connectivity issue prevented retrieval of the order header
- Document number mismatch in the system

**Resolution**:
1. Refresh the page (F5 or Ctrl+R)
2. Close and reopen the order
3. Verify the order exists in the system:
   - Search for the document number in the Sales Orders or Purchase Orders list
   - If the order does not exist, it may have been deleted or posted
4. If the order exists but error persists, log out and log back in
5. If issue continues, contact your administrator

---

### "Document must be in Open status"

**Symptoms**:
- Error message appears when clicking **Cancel Allocation**
- The action is blocked and no cancellation occurs

**Cause**:
- The document status is Released, Pending Approval, Pending Prepayment, or Posted
- Only documents in Open status can have allocations cancelled

**Why This Restriction Exists**:
- Released orders may be in process at the warehouse
- Released status indicates the order has been approved and locked for processing
- Changing allocations on released orders could disrupt warehouse operations

**Resolution**:

**Option 1: Reopen the Document**
1. Click **Actions** > **Functions** > **Reopen**
2. A confirmation dialog may appear; click **Yes**
3. The status changes to **Open**
4. Now you can cancel allocations
5. After cancellation, you can release the order again if needed

**Option 2: Coordinate with Warehouse**
- If the order is released and warehouse activities have begun, coordinate with warehouse staff before reopening
- Ensure no warehouse shipments or receipts are in progress
- Communicate the change to avoid processing conflicts

**Important Note**: Reopening a document may require approval workflow re-execution depending on your organization's processes.

---

### "Line has been shipped" or "Line has been received"

**Symptoms**:
- Error message when attempting to cancel allocations on a specific line
- Error states: "Cannot cancel allocation: Line has already been partially or fully shipped" (sales) or "...received" (purchase)

**Cause**:
- The order line has a posted shipment (sales) or posted receipt (purchase)
- The **Quantity Shipped** (sales) or **Quantity Received** (purchase) field is greater than zero
- Allocations cannot be cancelled once inventory has physically moved

**Why This Restriction Exists**:
- Posted shipments/receipts create item ledger entries
- These ledger entries have reservation links that must remain intact
- Cancelling allocations on shipped/received lines would create data inconsistencies
- The physical inventory movement has already occurred; the reservation is historical

**Resolution**:

**If Partial Shipment/Receipt**:
- You **cannot** cancel the allocation on this line
- The reservation is locked by the posted quantity
- Consider these alternatives:
  1. If additional quantity needs to be cancelled, reduce the outstanding quantity on the line
  2. Create a new line for any additional requirements
  3. For future orders, cancel allocations before any shipment/receipt occurs

**If Full Shipment/Receipt**:
- The line is completely processed
- No allocation cancellation is needed or possible
- The line's purpose is fulfilled

**Prevention**:
- Always cancel allocations before posting shipments or receipts
- Review allocation changes during order review meetings before releasing to warehouse
- Establish workflow processes that require allocation confirmation before release

---

### "Warehouse shipment exists" or "Warehouse receipt exists"

**Symptoms**:
- Error message when attempting to cancel allocations
- Error states: "Cannot cancel allocation: Line has an existing warehouse shipment" (sales) or "...warehouse receipt" (purchase)

**Cause**:
- A warehouse shipment (sales) or warehouse receipt (purchase) document has been created for the order line
- Warehouse documents link to specific allocations
- Cancelling allocations while warehouse documents exist would create inconsistencies

**Why This Restriction Exists**:
- Warehouse documents represent physical work assignments
- Warehouse staff may be actively picking or receiving based on these documents
- Allocations must align with warehouse processing expectations

**Resolution**:

**Step 1: Identify the Warehouse Document**

For Sales Orders:
1. From the sales order, click **Actions** > **Warehouse** > **Warehouse Shipment Lines**
2. Locate the shipment document linked to the order line
3. Note the warehouse shipment number

For Purchase Orders:
1. From the purchase order, click **Actions** > **Warehouse** > **Warehouse Receipt Lines**
2. Locate the receipt document linked to the order line
3. Note the warehouse receipt number

**Step 2: Coordinate with Warehouse**
- Contact warehouse staff to determine if work has begun on the document
- If picking or receiving is in progress, wait until it completes or coordinate work stoppage
- Ensure warehouse staff understands the allocation will be cancelled

**Step 3: Delete or Process the Warehouse Document**

**Option A: Delete the Warehouse Document** (if work has not begun)
1. Navigate to the warehouse shipment or warehouse receipt
2. Open the document
3. Delete the line(s) associated with the order line
   - Or delete the entire warehouse document if it only contains those lines
4. Return to the sales or purchase order
5. Now you can cancel the allocation

**Option B: Post the Warehouse Document** (if work is complete)
1. Complete the warehouse shipment or receipt posting
2. The order line will be marked as shipped/received
3. Allocation cancellation is no longer needed or possible

**Prevention**:
- Cancel allocations before creating warehouse documents
- Establish process controls that require allocation review before warehouse document creation
- Use document release as a checkpoint for allocation confirmation

---

### "Allocation is already cancelled"

**Symptoms**:
- Error message when attempting to cancel allocations
- Error states: "Cannot cancel allocation: Allocation is already cancelled"

**Cause**:
- The line's **VT Allocation Status** field is already set to "Cancelled"
- A previous cancellation operation already processed this line
- The system prevents duplicate cancellation

**Resolution**:

**Step 1: Verify Allocation Status**
1. Look at the order line's **Allocation Status** field
2. If it shows "Cancelled", the line has already been processed
3. Check the **Allocation Cancelled Date** and **Allocation Cancelled By** fields for details

**Step 2: Review Cancellation History**
1. Click **Actions** > **Functions** > **Allocation History**
2. Find the history record(s) for this line
3. Review when and why the cancellation occurred
4. Determine if the cancellation was intentional or a mistake

**Step 3: Take Appropriate Action**

**If Cancellation Was Intentional**:
- No further action needed
- The allocation has already been released
- Inventory is available for other orders

**If You Need to Recreate a Reservation**:
1. Use the standard Business Central **Reserve** function:
   - Select the line
   - Click **Line** > **Reserve**
   - Create a new reservation from available inventory
2. After creating a new reservation:
   - The line's allocation status remains "Cancelled" (refers to past cancellation)
   - The line now has active reservations again
   - If needed in the future, you can cancel the new allocation (creating another history record)

**If Cancellation Was a Mistake**:
- Cancellations cannot be undone
- Recreate the reservation as described above
- The history record remains for audit purposes

---

### "No lines with valid allocations were found to cancel"

**Symptoms**:
- Message appears after clicking **Cancel Allocation** and selecting **Yes** to confirm
- No cancellation occurs, no reason code is prompted

**Cause**:
- None of the selected lines have active reservations
- The selected lines fail eligibility validation
- Common reasons:
  - **Reserved Quantity** is zero (no allocation exists)
  - Lines are on return orders or credit memos (not supported)
  - Lines have already been shipped or received
  - Allocations have already been cancelled

**Resolution**:

**Step 1: Verify Reservations Exist**
1. Look at the **Reserved Quantity** field on each line
2. If all values are zero, there are no active allocations
3. Use the **Reserve** function to view reservation details:
   - Select a line
   - Click **Line** > **Reserve**
   - Check if any reservation entries exist with status other than "Prospect"

**Step 2: Check Line Eligibility**
Review each line for these conditions:
- **Document Type**: Must be Order or Quote (not Return Order or Credit Memo)
- **Quantity Shipped/Received**: Must be zero
- **Allocation Status**: Must not already be Cancelled
- **Reservation Status**: Must have entries with status other than "Prospect"

**Step 3: Select Eligible Lines**
1. If some lines are eligible and others are not:
   - The system will process only the eligible lines
   - Reselect only the lines you know have active allocations
2. If no lines are eligible:
   - No cancellation is possible
   - Verify if cancellation was already performed using Allocation History

**Prevention**:
- Before initiating cancellation, verify Reserved Quantity > 0
- Use filters to show only lines with reservations
- Check Allocation Status to avoid reprocessing cancelled lines

---

## Permission and Access Errors

### "You do not have permission to perform this action"

**Symptoms**:
- Error message when clicking **Cancel Allocation** or accessing history
- Action is blocked by security

**Cause**:
- Current user's permission set does not include required objects
- Required permissions:
  - Modify access to Sales Line (Table 37) or Purchase Line (Table 39)
  - RIMD access to Reservation Entry (Table 337)
  - Read and Insert access to VT Allocation Cancel History (Table 50100)
  - Execute permission on VT Allocation Cancellation Mgt codeunit (Codeunit 50140)

**Resolution**:
1. Contact your Business Central administrator
2. Request the required permissions listed above
3. Administrator should:
   - Open **Permission Sets** page
   - Add the required objects to the user's permission set
   - Or create a new permission set specifically for allocation cancellation
4. Log out and log back in after permissions are granted
5. Retry the operation

---

## History and Reporting Issues

### History Page Shows No Records

**Symptoms**:
- The Allocation Cancellation History page opens but displays no records
- Expected to see history but the list is empty

**Possible Causes**:

1. **Filters Are Applied**
   - Filters from a previous session may still be active
   - Date range filters may exclude all records

2. **No Cancellations Have Occurred**
   - If the feature was just installed, no history exists yet
   - All cancellation attempts may have failed

3. **Viewing Document-Specific History**
   - Opened from a specific order that has no cancellations
   - The document filter is excluding all records

**Resolution**:

**Step 1: Clear All Filters**
1. Press **Shift+F3** or click **Edit List** > **Show Filter Pane**
2. Check for active filters in the filter pane
3. Click **Clear Filters** to remove all filters
4. If records appear, the issue was filters

**Step 2: Verify Data Exists**
1. Check if any cancellations have been performed in the system
2. Test by performing a cancellation on a test order
3. Refresh the history page to see if the test record appears

**Step 3: Check Date Range**
1. Click the **Cancellation Date** column header
2. Remove any date filters
3. Sort by **Cancellation Date** descending to see most recent records first

**Step 4: Verify Database Access**
1. Check if other pages load correctly
2. Try refreshing the page (F5)
3. If other pages also show no data, database connectivity may be an issue
4. Contact your administrator

---

### Export to Excel Fails

**Symptoms**:
- Clicking **Export to Excel** produces an error
- Excel file is generated but is empty
- Download does not start

**Possible Causes**:

1. **Excel Not Installed**
   - Excel must be installed on the client machine for the export function to work

2. **Browser Blocks Download**
   - Browser security settings may block the file download
   - Pop-up blocker may prevent the download dialog

3. **No Records to Export**
   - Filters may result in zero records selected for export
   - Empty dataset produces empty Excel file

4. **Excel Integration Not Configured**
   - Business Central Excel integration may not be properly configured in the environment

**Resolution**:

**Step 1: Verify Records Exist**
1. Before exporting, verify the history page shows records
2. Clear any filters that may be limiting results
3. Select **All** or specific records you want to export

**Step 2: Check Browser Settings**
1. Ensure pop-ups are allowed for Business Central
2. Check browser download settings
3. Try a different browser (Edge, Chrome, Firefox)

**Step 3: Try Alternative Export Methods**

**Method A: Open in Excel**
1. Right-click on the history page
2. Select **Open in Excel**
3. Business Central generates an Excel file with data connection
4. Open and save the file locally

**Method B: Copy to Clipboard**
1. Select the records you want to export (Ctrl+A for all)
2. Right-click and select **Copy** or press Ctrl+C
3. Open Excel manually
4. Paste the data (Ctrl+V)

**Step 4: Contact Administrator**
- If exports consistently fail, contact your Business Central administrator
- Administrator should verify:
  - Excel integration is configured in Business Central setup
  - Office Add-ins are properly deployed
  - User permissions include Excel export rights

---

## Data and Display Issues

### Allocation Status Field Not Visible

**Symptoms**:
- Cannot see the **Allocation Status** field on sales or purchase order lines
- Field is documented but not displayed

**Cause**:
- The field is added to the table but not displayed in the default page view
- Page personalization may have hidden the field
- For purchase orders, the subpage may not include the field by default

**Resolution**:

**Step 1: Show the Field via Personalization**
1. On the sales or purchase order page, navigate to the order lines section
2. Click **Personalize** (gear icon in the toolbar)
3. In personalization mode:
   - Find **VT Allocation Status** in the field list on the left
   - Drag it to the desired location in the columns area
   - Position it after **Reserved Quantity** for logical grouping
4. Click **Done** to save personalization
5. The field should now be visible

**Step 2: Reset Personalization** (if field still doesn't appear)
1. Click **Personalize** > **Clear personalization**
2. Confirm the reset
3. Re-apply personalization to show the field

**Step 3: Verify Extension Installation**
- If field cannot be found in the personalization field list:
  - The extension may not be properly installed
  - Contact administrator to verify extension publishing
  - Check Extension Management page

---

### Reserved Quantity Does Not Update After Cancellation

**Symptoms**:
- Allocation is cancelled successfully
- Allocation Status changes to "Cancelled"
- But Reserved Quantity still shows the previous value

**Cause**:
- The page needs to be refreshed to show updated values
- Business Central caches data temporarily for performance
- Reserved Quantity is a calculated field that may not refresh automatically

**Resolution**:
1. Press **F5** or **Ctrl+R** to refresh the page
2. Or close and reopen the sales/purchase order
3. The Reserved Quantity should now show **0** for cancelled lines
4. Verify by using **Line** > **Reserve** to view reservation details

**Note**: The reservation entries are marked as cancelled (VT Is Cancelled = TRUE) and have quantity set to zero, so the standard Business Central calculations should reflect this immediately upon refresh.

---

### History Record Shows Wrong Customer/Vendor Name

**Symptoms**:
- History record displays an incorrect or outdated customer/vendor name
- The name doesn't match the current master data

**Cause**:
- The Customer/Vendor Name field stores a snapshot at the time of cancellation
- If the customer or vendor was later renamed, the history retains the old name
- This is intentional for historical accuracy

**Resolution**:
- **This is not an error**; it's by design for audit trail purposes
- The history record shows the name as it existed when the cancellation occurred
- The Customer/Vendor No. field can be used to navigate to current master data:
  1. Click on the Customer/Vendor No. field (if configured as a drilldown)
  2. Or manually search for the customer/vendor using the number
  3. View current information on the Customer/Vendor Card

**Why This Is Important**:
- Provides accurate historical context
- Supports audit requirements
- Prevents confusion if names are reused

---

## Performance Issues

### Cancellation Process Is Slow

**Symptoms**:
- Clicking **Cancel Allocation** causes long wait times
- System appears to freeze or hang
- Cancellation eventually completes but takes several minutes

**Possible Causes**:

1. **Large Number of Reservation Entries**
   - Order line has many reservation entries
   - Each entry must be processed individually

2. **Database Performance**
   - Database server is under heavy load
   - Network latency between client and server

3. **Concurrent User Activity**
   - Many users performing reservations or cancellations simultaneously
   - Database locking contention

**Resolution**:

**Step 1: Cancel in Smaller Batches**
- Instead of selecting all lines, select 5-10 at a time
- Process in multiple cancellation operations
- This reduces the transaction size and improves responsiveness

**Step 2: Avoid Peak Usage Times**
- Perform cancellations during off-peak hours if possible
- Coordinate with other users to avoid concurrent operations

**Step 3: Contact Administrator**
- If performance is consistently poor:
  - Database may need performance tuning
  - Indexes on Reservation Entry table may need rebuilding
  - Consider hardware upgrades or database optimization

**Prevention**:
- Avoid creating excessive reservation entries
- Use automatic reservation policies appropriately
- Regularly review and clean up unnecessary reservations before cancellation

---

### History Page Loads Slowly

**Symptoms**:
- Opening Allocation Cancellation History page takes a long time
- Scrolling through records is sluggish
- Filtering or sorting is slow

**Causes**:
- Large number of history records (thousands or more)
- Insufficient database indexing
- Network latency

**Resolution**:

**Step 1: Apply Filters Before Loading**
1. When opening history, immediately apply a date range filter:
   - Filter **Cancellation Date** to recent period (e.g., last 30 days)
   - This reduces the number of records loaded
2. Use additional filters:
   - Filter by Customer/Vendor No. if analyzing specific partners
   - Filter by Item No. if analyzing specific items

**Step 2: Use Document-Specific History**
- Instead of opening global history, access from specific orders
- Click **Allocation History** from the sales or purchase order
- This automatically filters to that document only

**Step 3: Export for Analysis**
- For large-scale analysis, export data to Excel
- Perform analysis in Excel rather than in Business Central
- This offloads processing to the local machine

**Step 4: Archival Strategy**
- Develop a data archival strategy with your administrator:
  - Export historical data periodically
  - Consider purging very old records if compliance allows
  - Balance audit trail needs with performance

---

## Integration and Workflow Issues

### Cancellation Works But Inventory Not Available

**Symptoms**:
- Allocation cancellation completes successfully
- History record is created
- But inventory does not appear available for other orders

**Possible Causes**:

1. **Inventory is Allocated Elsewhere**
   - The same inventory was already allocated to another order
   - Multiple demands exist for limited supply

2. **Item Availability Calculation Delay**
   - Business Central's availability calculations may not refresh immediately
   - Cache or session data may be outdated

3. **Inventory Tracking Issues**
   - Item tracking (serial/lot numbers) may restrict reallocation
   - Tracking reservations may require specific inventory

**Resolution**:

**Step 1: Refresh Inventory Availability**
1. Navigate to the **Item Card** for the item
2. Check **Available Inventory** and **Qty. on Sales Order**
3. Press F5 to refresh
4. Use **Actions** > **Item Availability by** to see detailed availability

**Step 2: Check Other Allocations**
1. From the Item Card, click **Actions** > **Item** > **Reservation Entries**
2. Review all active reservation entries
3. Verify the cancelled entry shows VT Is Cancelled = TRUE and Quantity = 0
4. Check if other reservation entries exist that consume the inventory

**Step 3: Verify Item Tracking**
- If the item uses serial/lot number tracking:
  - The cancelled allocation may have been linked to specific tracking
  - New allocations must match available tracked inventory
  - Review item tracking assignments

**Step 4: Create New Reservation**
1. Open the order where you want to allocate inventory
2. Select the line
3. Click **Line** > **Reserve**
4. Select available inventory and create the reservation
5. If no inventory appears available, check item ledger entries for actual stock

---

### Planning System Does Not Recognize Released Inventory

**Symptoms**:
- Allocation is cancelled
- Planning worksheets do not show the released inventory as available supply
- Planning system suggests new purchase orders or production

**Cause**:
- Planning system may need to be refreshed
- Planning calculations are typically batch processes that run periodically
- Real-time reservation changes may not be immediately reflected

**Resolution**:
1. **Refresh Planning Manually**:
   - Open the **Planning Worksheet** or **Requisition Worksheet**
   - Click **Actions** > **Functions** > **Calculate Plan**
   - Select regenerative plan or change plan as appropriate
   - Run the calculation
2. **Verify Item Planning Parameters**:
   - Check the item's **Reordering Policy** and **Reserve** settings
   - Ensure the item is set to use reservations appropriately
3. **Wait for Scheduled Planning Run**:
   - If your organization runs MRP on a schedule, wait for the next run
   - Planning calculations will incorporate the cancelled allocation

---

## Reason Code Issues

### Cannot Find Appropriate Reason Code

**Symptoms**:
- Reason code selection dialog opens
- None of the available codes fit the business scenario
- Unsure which code to select

**Resolution**:

**Immediate Solution**:
- Select the closest available reason code
- Make note of the need for a new code
- Proceed with cancellation

**Long-Term Solution**:
1. Contact your Business Central administrator
2. Request new reason codes be created:
   - Navigate to **Reason Codes** page
   - Click **New**
   - Enter code and description matching business needs
3. Common useful codes to add:
   - ALLOC-CANCEL (general)
   - ALLOC-CUSTCHG (customer change)
   - ALLOC-PRIORITY (priority reallocation)
   - ALLOC-VENDCHG (vendor change)
   - CANCEL-ORDER (order cancellation)

---

### Reason Code Selection is Mandatory

**Symptoms**:
- Cannot proceed with cancellation without selecting a reason code
- Want to skip reason code selection

**Cause**:
- Reason code selection is mandatory by design for audit trail purposes
- Business Central enforces the requirement

**Resolution**:
- **You must select a reason code**
- This is intentional for compliance and audit trail
- If a generic code is needed:
  - Request administrator create a code like "OTHER" or "UNSPECIFIED"
  - Use this for cases where specific reasons don't apply
- Best practice: Always select the most accurate reason code available

---

## Contact and Escalation

If you encounter issues not covered in this guide:

### Level 1: Internal Support
1. Contact your organization's Business Central support team
2. Provide:
   - Exact error message (screenshot if possible)
   - Steps you performed leading to the issue
   - Document numbers and line numbers involved
   - Your user ID and when the issue occurred

### Level 2: Administrator
1. Contact your Business Central administrator
2. Administrator should verify:
   - Extension is properly installed and up to date
   - User permissions are correctly configured
   - Database performance is acceptable
   - No known system issues or outages

### Level 3: Developer/Vendor
1. If the issue appears to be a bug in the extension:
   - Collect detailed reproduction steps
   - Export history and reservation entry data if relevant
   - Contact the extension developer/vendor
2. Provide:
   - Business Central version
   - Extension version
   - Detailed error logs
   - Steps to reproduce

---

## Preventive Measures

To avoid common issues:

### Before Cancellation
- Verify document is in Open status
- Check for active warehouse documents
- Review reserved quantities
- Confirm lines have not been shipped/received
- Communicate with stakeholders

### During Cancellation
- Select appropriate reason codes
- Process in smaller batches if performance is a concern
- Verify selections before confirming

### After Cancellation
- Verify cancellation completed successfully
- Check history record was created
- Refresh pages to see updated values
- Reallocate inventory if needed

### Regular Maintenance
- Review reason codes and add new ones as needed
- Train users on proper usage
- Audit cancellation history periodically
- Address systemic issues causing frequent cancellations

---

## Related Topics

- **[Overview](overview.md)**: Understand the purpose and scope of allocation cancellation
- **[Getting Started](getting-started.md)**: Prerequisites and access information
- **[Cancel Sales Order Allocations](cancel-sales-order-allocation.md)**: Step-by-step cancellation process
- **[Cancel Purchase Order Allocations](cancel-purchase-order-allocation.md)**: Step-by-step cancellation process
- **[View Cancellation History](view-cancellation-history.md)**: Working with history records
- **[Field Reference](field-reference.md)**: Complete field descriptions
