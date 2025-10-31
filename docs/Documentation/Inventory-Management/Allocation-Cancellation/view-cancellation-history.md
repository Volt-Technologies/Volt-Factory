# View Cancellation History

## Overview

The Allocation Cancellation History provides a complete, permanent record of all allocation cancellations performed in Business Central. This audit trail is essential for compliance, analysis, and understanding past allocation decisions. This guide explains how to access, filter, analyze, and export cancellation history data.

## Why History Tracking Matters

Cancellation history serves multiple critical business functions:

**Audit and Compliance**: Provides verifiable records of who cancelled allocations, when, and why - essential for internal audits and regulatory compliance.

**Operational Analysis**: Identifies patterns in cancellations that may indicate process improvements, training needs, or systemic issues.

**Customer Service**: Enables customer service representatives to explain allocation changes when customers inquire about order status.

**Performance Metrics**: Supports KPIs such as:
- Cancellation rate by customer, item, or user
- Frequency of cancellations by reason code
- Impact of cancellations on order fulfillment times

**Dispute Resolution**: Provides factual records to resolve disputes about order changes or inventory allocation decisions.

## Accessing Cancellation History

There are three primary ways to access cancellation history, each serving different use cases.

### Method 1: Global History View (All Cancellations)

To view all allocation cancellations across the entire system:

1. Press **Alt+Q** to open the Search function
2. Type "Allocation Cancellation History" or "Alloc Cancel History"
3. Press **Enter** or click on **Allocation Cancellation History** in the results

**Expected Result**: The Allocation Cancellation History page opens, displaying all cancellation records from all documents.

**Use This Method When**:
- Performing system-wide analysis or reporting
- Searching for cancellations across multiple orders
- Generating comprehensive audit reports
- Analyzing cancellation trends by user, item, date range, or reason code

### Method 2: Document-Specific History (From Sales Order)

To view cancellation history for a specific sales order:

1. Open the desired sales order
   - Press **Alt+Q** > type "Sales Orders" > open the specific order
2. Click **Actions** in the ribbon
3. Navigate to **Functions** group
4. Click **Allocation History**

**Expected Result**: The Allocation Cancellation History page opens, filtered to show only cancellations for the current sales order.

**Use This Method When**:
- Reviewing changes made to a specific customer order
- Investigating why a sales order's allocations were cancelled
- Answering customer inquiries about their specific order
- Verifying cancellation details before creating new allocations

### Method 3: Document-Specific History (From Purchase Order)

To view cancellation history for a specific purchase order:

1. Open the desired purchase order
   - Press **Alt+Q** > type "Purchase Orders" > open the specific order
2. Click **Actions** in the ribbon
3. Navigate to **Functions** group
4. Click **Allocation History**

**Expected Result**: The Allocation Cancellation History page opens, filtered to show only cancellations for the current purchase order.

**Use This Method When**:
- Reviewing changes made to a vendor order
- Understanding supply reallocation decisions
- Coordinating with procurement teams about order changes
- Verifying cancellation details before creating new allocations

## Understanding the History List Page

The Allocation Cancellation History page displays records in a list format with multiple columns.

### Visible Columns (Default View)

| Column Name | Description | Purpose |
|-------------|-------------|---------|
| **Entry No.** | Unique sequential identifier for each cancellation | References a specific cancellation transaction |
| **Cancellation Date** | The date the cancellation occurred | Used for date-based filtering and sorting |
| **Document Type** | Type of source document (Order, Quote, etc.) | Identifies whether cancellation came from sales or purchase |
| **Document No.** | Source document number (clickable link) | Navigate directly to the source order |
| **Line No.** | Line number on the source document | Identifies the specific order line |
| **Item No.** | The item that was allocated | Key field for item-based analysis |
| **Location Code** | Warehouse location of the allocation | Important for multi-location operations |
| **Quantity Cancelled** | Amount of inventory released by cancellation | Shows the magnitude of the cancellation |
| **Customer/Vendor No.** | Trading partner identifier | Links cancellation to specific customer or vendor |
| **Customer/Vendor Name** | Trading partner name | Human-readable identification |
| **Cancelled By User ID** | User who performed the cancellation | Accountability and process analysis |
| **Cancellation Reason Code** | Business reason for the cancellation | Key field for trend analysis |

### Hidden Columns (Available via Personalization)

| Column Name | Description |
|-------------|-------------|
| **Cancellation Time** | Precise time the cancellation occurred |
| **Unit of Measure Code** | UOM for the cancelled quantity |
| **Cancellation Comments** | Optional user-entered comments |
| **Original Reservation Entry No.** | Links to the specific reservation entry that was cancelled |
| **Variant Code** | Item variant if applicable |
| **Source Type** | Internal identifier (37=Sales, 39=Purchase) |
| **Source Subtype** | Internal document type identifier |

To show hidden columns:
1. Click **Personalize** in the page toolbar
2. Drag desired fields from the field list to the column area
3. Click **Done** to save your personalization

## Filtering and Searching History

Effective filtering is essential for finding relevant history records quickly.

### Common Filtering Scenarios

#### Filter by Date Range

To see cancellations within a specific time period:

1. Click in the **Cancellation Date** column header
2. Select **Filter...**
3. Enter date range (e.g., "01/01/2024..01/31/2024" for January 2024)
4. Click **OK**

**Alternative Method**:
- Click the filter icon in the column header
- Select date range using the date picker

#### Filter by User

To see all cancellations performed by a specific user:

1. Click in the **Cancelled By User ID** column header
2. Select **Filter...**
3. Enter the user ID or select from the lookup
4. Click **OK**

**Use Case**: Supervisor reviewing an employee's cancellation activity or auditing user actions.

#### Filter by Item

To see all cancellations for a specific item:

1. Click in the **Item No.** column header
2. Select **Filter...**
3. Enter the item number or use the lookup (F6 or click dropdown)
4. Click **OK**

**Use Case**: Analyzing allocation volatility for a specific product.

#### Filter by Customer or Vendor

To see all cancellations related to a specific trading partner:

1. Click in the **Customer/Vendor No.** column header
2. Select **Filter...**
3. Enter the customer or vendor number
4. Click **OK**

**Use Case**: Customer service investigating allocation changes for a specific customer.

#### Filter by Reason Code

To see cancellations with a specific business reason:

1. Click in the **Cancellation Reason Code** column header
2. Select **Filter...**
3. Enter or select the reason code
4. Click **OK**

**Use Case**: Management analyzing frequency of specific cancellation types (e.g., customer changes vs. priority reallocation).

#### Filter by Document

To see all cancellations for a specific document:

1. Click in the **Document No.** column header
2. Select **Filter...**
3. Enter the document number
4. Click **OK**

**Use Case**: Viewing complete cancellation history for a specific order.

### Advanced Filtering

Use the **Filter Pane** for complex multi-field filters:

1. Press **Shift+F3** or click **Edit List** > **Show Filter Pane**
2. The filter pane appears on the left side
3. Add multiple filter criteria:
   - Click **+ Field** to add additional filter fields
   - Enter filter values for each field
   - Filters are applied with AND logic (all criteria must match)
4. Clear filters by clicking the **X** next to each filter or **Clear Filters** button

**Example Multi-Field Filter**:
- Cancellation Date: 01/01/2024..03/31/2024
- Cancelled By User ID: MANAGER1
- Cancellation Reason Code: ALLOC-PRIORITY

This shows all priority-based cancellations by MANAGER1 in Q1 2024.

### Sorting Records

Click any column header to sort by that column:
- **First click**: Sort ascending
- **Second click**: Sort descending
- **Third click**: Remove sort

Hold **Shift** and click multiple column headers to sort by multiple columns in sequence.

### FlowFilter and Quick Filters

Use the **Search** box at the top of the page for quick filtering:
1. Click in the search box
2. Type any value (item number, customer name, reason code, etc.)
3. Press **Enter**
4. Business Central searches across all visible text fields

Note: This is a quick filter, not a permanent filter. Clear it by clicking the **X** in the search box.

## Navigating to Source Documents

One of the most powerful features of the history page is direct navigation to source documents.

### Navigate via Document Number Field

1. Locate the history record you want to investigate
2. Click on the **Document No.** field (it appears as a hyperlink)
3. Business Central opens the appropriate page:
   - Sales orders open the Sales Order page
   - Purchase orders open the Purchase Order page
   - The system automatically determines the correct page based on Source Type

**Expected Result**: The source document opens, and you can view its current state.

Note: The document may have been modified, posted, or deleted since the cancellation occurred. The history record remains even if the source document no longer exists.

### Navigate via Action Button

1. Select a history record by clicking on the row
2. Click **Actions** > **Process** > **Navigate to Document**
3. The source document opens

**Use Case**: Same as clicking the document number, but useful if the hyperlink is not visible due to personalization.

## Viewing Related Item Information

To view detailed information about the item that was cancelled:

1. Select a history record
2. Click **Actions** > **Process** > **Show Item**
3. The Item Card opens for the cancelled item

**Expected Result**: You can view item details such as:
- Current inventory levels
- Reservation policies
- Item tracking codes
- Supply and demand planning

This is useful for understanding the broader context of the cancellation.

## Using the Item Picture FactBox

The **Item Picture** FactBox appears on the right side of the history page (if FactBoxes are enabled):

- Automatically displays the item picture for the selected history record
- Helps quickly identify the product visually
- Particularly useful for retail, apparel, and consumer goods

To show/hide FactBoxes:
- Press **Ctrl+F7** or click **Page** > **FactBoxes**

## Exporting Cancellation History

The system provides built-in export functionality for external analysis and reporting.

### Export to Excel

1. Open the Allocation Cancellation History page
2. Apply any desired filters to limit the data
3. Click **Actions** > **Report** > **Export to Excel**
4. Business Central generates an Excel file and prompts you to open or save it

**Expected Result**: An Excel workbook containing the following columns:
- Entry No.
- Cancellation Date
- Document Type
- Document No.
- Line No.
- Item No.
- Location
- Qty Cancelled
- Cancelled By
- Reason Code

**Use Cases**:
- Creating pivot tables for analysis
- Generating charts and graphs
- Distributing reports to stakeholders who don't have Business Central access
- Archiving historical data
- Performing statistical analysis

### Alternative Export Methods

**Copy to Excel (Standard BC Feature)**:
1. Select the records you want to export
2. Press **Ctrl+A** to select all (or select specific rows)
3. Right-click and choose **Open in Excel** or use **Actions** > **Excel** > **Edit in Excel**
4. Business Central generates an Excel file with live data connection

**Export to Word**:
1. Select records
2. Right-click and choose **Send to** > **Microsoft Word**
3. Creates a Word document with the data in table format

## Analyzing Cancellation Patterns

Use the history data to identify patterns and improve processes.

### Analysis by Time Period

**Monthly Trends**:
1. Filter by date range (e.g., each month)
2. Count the number of entries
3. Compare month-over-month to identify increasing or decreasing trends

**Insights**: Rising cancellation rates may indicate:
- Process issues in order taking or inventory management
- Seasonal demand volatility
- Supply chain instability

### Analysis by Reason Code

**Frequency by Reason**:
1. Group by Cancellation Reason Code (using Excel pivot table after export)
2. Count occurrences of each reason
3. Calculate percentages

**Insights**: High percentages of specific reasons may indicate:
- **ALLOC-CUSTCHG**: Customer service or sales order management issues
- **ALLOC-PRIORITY**: Capacity planning or prioritization process problems
- **CANCEL-ORDER**: Customer satisfaction or sales forecasting issues

### Analysis by User

**Cancellation Activity by User**:
1. Group by Cancelled By User ID
2. Count cancellations per user
3. Compare to user workload and responsibilities

**Insights**: Significantly higher cancellations by specific users may indicate:
- Training needs
- Process misunderstandings
- Users handling more complex orders
- Users managing high-change customers

### Analysis by Item

**Item-Level Volatility**:
1. Group by Item No.
2. Count cancellations per item
3. Identify items with frequent cancellations

**Insights**: Items with high cancellation rates may have:
- Supply reliability issues
- Demand volatility
- Reservation policy problems
- Forecasting challenges

### Analysis by Customer/Vendor

**Trading Partner Analysis**:
1. Group by Customer/Vendor No.
2. Count cancellations per partner
3. Identify high-change trading partners

**Insights**: Partners with frequent cancellations may benefit from:
- Improved communication processes
- Modified reservation policies
- Different service level agreements
- Forecast collaboration

## History Record Permanence

Important characteristics of history records:

**Permanent Records**: History records are **never deleted** by standard processes. They remain in the system indefinitely for audit purposes.

**Read-Only**: All fields in the history table are non-editable. Once created, records cannot be modified or deleted through standard UI.

**Retention**: Organizations should establish data retention policies for history records:
- Archive old records periodically to maintain performance
- Export to external systems for long-term archiving
- Consult with compliance and legal teams for retention requirements

**Referential Integrity**: History records remain even if:
- The source sales or purchase order is deleted
- The item is removed from the system
- The user account is disabled
- The customer or vendor is merged or deleted

This ensures a complete audit trail even as master data changes over time.

## Reporting and Dashboards

While the feature includes an export function, organizations may want to develop custom reports:

**Suggested Custom Reports**:
- Monthly Cancellation Summary by Reason Code
- User Cancellation Activity Report
- Item Cancellation Trend Analysis
- Customer-Specific Cancellation History
- Cancellation Volume by Location

**Power BI Integration**:
Organizations using Power BI can connect to the VT Allocation Cancellation History table to create:
- Real-time dashboards
- Trend visualizations
- KPI tracking
- Automated reporting

Consult with your Business Central administrator or BI team to implement these solutions.

## Permissions and Access Control

History viewing permissions can be controlled separately from cancellation action permissions:

**Read-Only History Access**: Users can have permission to view history without the ability to perform cancellations.

**Typical Permission Scenarios**:
- **Auditors**: Read access to history, no modification or cancellation rights
- **Managers**: Full read access to history, cancellation rights
- **Order Processors**: Limited history access (own cancellations only), cancellation rights
- **Customer Service**: Read access to history for specific customers, no cancellation rights

Consult your Business Central administrator to configure appropriate permission sets.

## Best Practices

### Regular Review

Establish a process to regularly review cancellation history:
- **Weekly**: Supervisors review cancellations by their team
- **Monthly**: Management reviews trends and patterns
- **Quarterly**: Analyze for process improvement opportunities

### Documentation

When performing analysis:
- Document findings from history analysis
- Share insights with relevant teams
- Track actions taken based on historical data

### Integration with Other Processes

Link cancellation history to:
- Performance reviews
- Process improvement initiatives
- Training programs
- Customer satisfaction initiatives

## Troubleshooting History Access

### History Page Not Found

**Issue**: Allocation Cancellation History does not appear in search.

**Solution**:
- Verify the feature extension is installed
- Check user permissions
- Contact administrator to verify deployment

### Empty History List

**Issue**: History page opens but shows no records.

**Solution**:
- Check if filters are applied (clear all filters)
- Verify cancellations have actually been performed
- Check date range filters

### Cannot Export to Excel

**Issue**: Export to Excel action fails or produces empty file.

**Solution**:
- Verify Excel is installed
- Check browser settings for downloads
- Try "Open in Excel" as alternative method
- Check file permissions on download location

### Navigation to Document Fails

**Issue**: Clicking Document No. does nothing or shows error.

**Solution**:
- Document may have been deleted
- Document may be archived
- Check permissions to view sales/purchase orders
- Try using document navigation from appropriate list page

## Related Topics

- **[Overview](overview.md)**: Understand the purpose and scope of allocation cancellation
- **[Getting Started](getting-started.md)**: Prerequisites and access information
- **[Cancel Sales Order Allocations](cancel-sales-order-allocation.md)**: How to perform cancellations
- **[Cancel Purchase Order Allocations](cancel-purchase-order-allocation.md)**: How to perform cancellations
- **[Field Reference](field-reference.md)**: Complete field descriptions
- **[Troubleshooting](troubleshooting.md)**: Detailed error resolution
