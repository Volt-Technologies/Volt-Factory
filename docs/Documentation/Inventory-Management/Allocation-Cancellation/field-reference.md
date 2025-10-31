# Field Reference

## Overview

This comprehensive field reference documents all fields added or modified by the Allocation Cancellation feature. Fields are organized by table and include detailed information about data types, purpose, validation rules, editability, and relationships.

## Table of Contents

- [Sales Line Fields](#sales-line-fields)
- [Purchase Line Fields](#purchase-line-fields)
- [Reservation Entry Fields](#reservation-entry-fields)
- [Allocation Cancellation History Fields](#allocation-cancellation-history-fields)
- [Allocation Status Enum Values](#allocation-status-enum-values)

---

## Sales Line Fields

These fields are added to the **Sales Line** table (Table 37) to track allocation cancellation status on sales order lines.

### VT Allocation Status

| Property | Value |
|----------|-------|
| **Field Number** | 50100 |
| **Field Name** | VT Allocation Status |
| **Caption** | Allocation Status |
| **Data Type** | Enum (VT Allocation Status) |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | Active |

**Purpose**: Indicates whether the allocation on the sales line is active or has been cancelled.

**Valid Values**:
- **Active** (0): The allocation is currently active or no allocation has been cancelled
- **Cancelled** (1): The allocation has been cancelled through the cancellation process

**When Updated**:
- Set to "Cancelled" when the **Cancel Allocation** action is executed
- Automatically set to "Active" when a new sales line is created
- Triggers update of related cancellation tracking fields (date and user)

**Business Logic**:
- Cannot be manually changed by users
- Only updated through the cancellation management codeunit
- Used to filter lines eligible for cancellation (cannot cancel if already cancelled)
- Displayed in sales order subform with visual styling (grey/subordinate for cancelled status)

**Related Fields**:
- VT Allocation Cancelled Date
- VT Allocation Cancelled By
- VT Cancel History Exists

---

### VT Allocation Cancelled Date

| Property | Value |
|----------|-------|
| **Field Number** | 50101 |
| **Field Name** | VT Allocation Cancelled Date |
| **Caption** | Allocation Cancelled Date |
| **Data Type** | Date |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | Blank |

**Purpose**: Records the date when the allocation was cancelled.

**When Updated**:
- Set to TODAY when VT Allocation Status changes to "Cancelled"
- Remains unchanged once set (permanent record)

**Business Logic**:
- Automatically populated by validation trigger on VT Allocation Status field
- Cannot be manually edited
- Used for audit trail and reporting
- Remains even if order is later modified or deleted

**Usage in Queries/Reports**:
- Filter cancellations by date range
- Calculate cancellation trends over time
- Compliance and audit reporting

---

### VT Allocation Cancelled By

| Property | Value |
|----------|-------|
| **Field Number** | 50102 |
| **Field Name** | VT Allocation Cancelled By |
| **Caption** | Allocation Cancelled By |
| **Data Type** | Code[50] |
| **Table Relation** | User."User Name" |
| **Validate Table Relation** | No |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | Blank |

**Purpose**: Records the user ID of the person who cancelled the allocation.

**When Updated**:
- Set to USERID when VT Allocation Status changes to "Cancelled"
- Remains unchanged once set (permanent record)

**Business Logic**:
- Automatically populated by validation trigger on VT Allocation Status field
- Cannot be manually edited
- Provides accountability for cancellation actions
- Used for user activity analysis and performance tracking

**Technical Notes**:
- Relates to User table but does not validate (allows for deleted users)
- Stores user name, not user security ID
- Maximum length 50 characters

---

### VT Cancel History Exists

| Property | Value |
|----------|-------|
| **Field Number** | 50103 |
| **Field Name** | VT Cancel History Exists |
| **Caption** | Cancellation History Exists |
| **Field Class** | FlowField (calculated field) |
| **Data Type** | Boolean |
| **Editable** | No (always false for FlowFields) |
| **Required** | No |

**Purpose**: Indicates whether one or more cancellation history records exist for this sales line.

**Calculation Formula**:
```
EXIST("VT Allocation Cancel History" WHERE(
    "Source Type" = CONST(37),
    "Document Type" = FIELD("Document Type"),
    "Document No." = FIELD("Document No."),
    "Line No." = FIELD("Line No.")))
```

**Business Logic**:
- Returns TRUE if any history records exist for this line
- Returns FALSE if no history records exist
- Dynamically calculated when accessed (not stored)
- Useful for conditional UI elements or reporting

**Usage**:
- Show/hide "View History" buttons
- Filter lines that have been cancelled
- Reporting on lines with cancellation activity

**Technical Notes**:
- Must be explicitly calculated using CALCFIELDS in AL code
- Not automatically calculated in all contexts
- Performance consideration: Calculate only when needed

---

## Purchase Line Fields

These fields are added to the **Purchase Line** table (Table 39) to track allocation cancellation status on purchase order lines.

### VT Allocation Status

| Property | Value |
|----------|-------|
| **Field Number** | 50100 |
| **Field Name** | VT Allocation Status |
| **Caption** | Allocation Status |
| **Data Type** | Enum (VT Allocation Status) |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | Active |

**Purpose**: Indicates whether the allocation on the purchase line is active or has been cancelled.

**Valid Values**:
- **Active** (0): The allocation is currently active or no allocation has been cancelled
- **Cancelled** (1): The allocation has been cancelled through the cancellation process

**When Updated**:
- Set to "Cancelled" when the **Cancel Allocation** action is executed
- Automatically set to "Active" when a new purchase line is created
- Triggers update of related cancellation tracking fields (date and user)

**Business Logic**:
- Cannot be manually changed by users
- Only updated through the cancellation management codeunit
- Used to filter lines eligible for cancellation (cannot cancel if already cancelled)

**Note**: Unlike sales lines, the purchase line subform may not display this field by default. Use page personalization to add it if needed.

**Related Fields**:
- VT Allocation Cancelled Date
- VT Allocation Cancelled By
- VT Cancel History Exists

---

### VT Allocation Cancelled Date

| Property | Value |
|----------|-------|
| **Field Number** | 50101 |
| **Field Name** | VT Allocation Cancelled Date |
| **Caption** | Allocation Cancelled Date |
| **Data Type** | Date |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | Blank |

**Purpose**: Records the date when the allocation was cancelled.

**When Updated**:
- Set to TODAY when VT Allocation Status changes to "Cancelled"
- Remains unchanged once set (permanent record)

**Business Logic**: Same as Sales Line equivalent. See Sales Line section above.

---

### VT Allocation Cancelled By

| Property | Value |
|----------|-------|
| **Field Number** | 50102 |
| **Field Name** | VT Allocation Cancelled By |
| **Caption** | Allocation Cancelled By |
| **Data Type** | Code[50] |
| **Table Relation** | User."User Name" |
| **Validate Table Relation** | No |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | Blank |

**Purpose**: Records the user ID of the person who cancelled the allocation.

**When Updated**: Same as Sales Line equivalent. See Sales Line section above.

---

### VT Cancel History Exists

| Property | Value |
|----------|-------|
| **Field Number** | 50103 |
| **Field Name** | VT Cancel History Exists |
| **Caption** | Cancellation History Exists |
| **Field Class** | FlowField (calculated field) |
| **Data Type** | Boolean |
| **Editable** | No (always false for FlowFields) |
| **Required** | No |

**Purpose**: Indicates whether one or more cancellation history records exist for this purchase line.

**Calculation Formula**:
```
EXIST("VT Allocation Cancel History" WHERE(
    "Source Type" = CONST(39),
    "Document No." = FIELD("Document No."),
    "Line No." = FIELD("Line No.")))
```

**Business Logic**: Similar to Sales Line equivalent, but filters by Source Type = 39 (Purchase Line).

---

## Reservation Entry Fields

These fields are added to the **Reservation Entry** table (Table 337) to mark reservations as cancelled and link them to history records.

### VT Is Cancelled

| Property | Value |
|----------|-------|
| **Field Number** | 50100 |
| **Field Name** | VT Is Cancelled |
| **Caption** | Is Cancelled |
| **Data Type** | Boolean |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | FALSE |

**Purpose**: Indicates whether this reservation entry has been cancelled through the allocation cancellation process.

**Valid Values**:
- **FALSE**: Reservation is active and has not been cancelled
- **TRUE**: Reservation has been cancelled

**When Updated**:
- Set to TRUE by the MarkAsCancelled procedure when cancellation is processed
- Never set back to FALSE (cancellations are permanent)

**Business Logic**:
- Used to filter active vs. cancelled reservations
- Prevents re-cancellation of already-cancelled entries
- Does not delete the reservation entry; marks it as cancelled
- When TRUE, the Quantity and Quantity (Base) fields are set to 0

**Impact**:
- Cancelled reservation entries remain in the table
- Standard BC reservation calculations exclude cancelled entries (quantity = 0)
- Maintains referential integrity with original reservation linkages

**Related Fields**:
- VT Cancellation Entry No.
- VT Cancellation DateTime

---

### VT Cancellation Entry No.

| Property | Value |
|----------|-------|
| **Field Number** | 50101 |
| **Field Name** | VT Cancellation Entry No. |
| **Caption** | Cancellation Entry No. |
| **Data Type** | Integer |
| **Table Relation** | "VT Allocation Cancel History"."Entry No." |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | 0 |

**Purpose**: Links the cancelled reservation entry to the corresponding history record in the VT Allocation Cancellation History table.

**When Updated**:
- Set when MarkAsCancelled procedure is called
- Value is the Entry No. from the newly created history record

**Business Logic**:
- Provides traceability from reservation entry to cancellation history
- Enables drilldown from reservation entry to full cancellation details
- Zero value indicates no cancellation has occurred

**Usage**:
- Navigate from reservation entry to cancellation history record
- Verify which history record documents a specific cancellation
- Audit trail and compliance reporting

---

### VT Cancellation DateTime

| Property | Value |
|----------|-------|
| **Field Number** | 50102 |
| **Field Name** | VT Cancellation DateTime |
| **Caption** | Cancellation DateTime |
| **Data Type** | DateTime |
| **Editable** | No (system-managed) |
| **Required** | No |
| **Default Value** | 0DT (blank) |

**Purpose**: Records the precise date and time when the reservation entry was cancelled.

**When Updated**:
- Set to CURRENTDATETIME when MarkAsCancelled procedure is called

**Business Logic**:
- Provides high-precision timestamp for audit purposes
- Useful for detailed operational analysis
- Can be used to calculate time between reservation creation and cancellation

**Technical Notes**:
- DateTime type includes date and time with millisecond precision
- Stored in UTC if system is configured for UTC storage
- Display format depends on user regional settings

---

## Allocation Cancellation History Fields

These fields make up the **VT Allocation Cancel History** table (Table 50100), which stores permanent records of all cancellations.

### Entry No.

| Property | Value |
|----------|-------|
| **Field Number** | 1 |
| **Field Name** | Entry No. |
| **Caption** | Entry No. |
| **Data Type** | Integer |
| **AutoIncrement** | Yes |
| **Editable** | No |
| **Required** | Yes (primary key) |

**Purpose**: Unique identifier for each cancellation history record.

**Business Logic**:
- Auto-incremented by OnInsert trigger
- Primary key for the table
- Used to link reservation entries to history records
- Sequential numbering ensures chronological ordering

**Technical Notes**:
- Starts at 1 and increments for each new record
- Never reused, even if records are deleted
- Safe for concurrent inserts (database-managed)

---

### Document Type

| Property | Value |
|----------|-------|
| **Field Number** | 2 |
| **Field Name** | Document Type |
| **Caption** | Document Type |
| **Data Type** | Enum (Sales Document Type) |
| **Editable** | No |
| **Required** | No |

**Purpose**: Indicates the type of source document where the cancellation occurred.

**Valid Values**:
- **Quote** (0)
- **Order** (1)
- *Other values from Sales Document Type enum*

**Business Logic**:
- For sales documents, directly copied from Sales Line."Document Type"
- For purchase documents, mapped from Purchase Document Type to Sales Document Type enum
  - Purchase Order → Sales Order
  - Purchase Quote → Sales Quote
- Used for filtering and grouping history records

**Technical Note**: Uses Sales Document Type enum for both sales and purchase records to simplify the data model. The Source Type field distinguishes between sales and purchase.

---

### Document No.

| Property | Value |
|----------|-------|
| **Field Number** | 3 |
| **Field Name** | Document No. |
| **Caption** | Document No. |
| **Data Type** | Code[20] |
| **Editable** | No |
| **Required** | No |

**Purpose**: Stores the document number of the sales or purchase order where the cancellation occurred.

**Business Logic**:
- Copied from Sales Line."Document No." or Purchase Line."Document No."
- Used to navigate back to source document
- Part of the DocumentKey secondary index for fast lookups

**Technical Notes**:
- Maximum length 20 characters
- Format depends on the number series configured for sales/purchase orders
- Value persists even if source document is deleted

---

### Line No.

| Property | Value |
|----------|-------|
| **Field Number** | 4 |
| **Field Name** | Line No. |
| **Caption** | Line No. |
| **Data Type** | Integer |
| **Editable** | No |
| **Required** | No |

**Purpose**: Stores the line number within the source document where the cancellation occurred.

**Business Logic**:
- Copied from Sales Line."Line No." or Purchase Line."Line No."
- Combined with Document Type and Document No. to uniquely identify the source line
- Multiple history records can exist for the same line if cancelled multiple times (after recreating allocations)

---

### Source Type

| Property | Value |
|----------|-------|
| **Field Number** | 5 |
| **Field Name** | Source Type |
| **Caption** | Source Type |
| **Data Type** | Integer |
| **Editable** | No |
| **Required** | No |

**Purpose**: Internal identifier indicating whether the cancellation occurred on a sales or purchase document.

**Valid Values**:
- **37**: Sales Line
- **39**: Purchase Line

**Business Logic**:
- Used to determine which type of document to open when navigating
- Used in filtering for document-specific history views
- Constant values defined by Business Central's table numbering system

**Technical Note**: This is a table number reference, not an enum. It corresponds to the database table ID.

---

### Item No.

| Property | Value |
|----------|-------|
| **Field Number** | 6 |
| **Field Name** | Item No. |
| **Caption** | Item No. |
| **Data Type** | Code[20] |
| **Table Relation** | Item |
| **Editable** | No |
| **Required** | No |

**Purpose**: Identifies the item whose allocation was cancelled.

**Business Logic**:
- Copied from Sales Line."No." or Purchase Line."No."
- Used for item-based reporting and analysis
- Links to Item table for drilldown to item details

**Usage**:
- Filter history by item
- Analyze cancellation frequency per item
- Identify items with high allocation volatility

---

### Variant Code

| Property | Value |
|----------|-------|
| **Field Number** | 7 |
| **Field Name** | Variant Code |
| **Caption** | Variant Code |
| **Data Type** | Code[10] |
| **Table Relation** | "Item Variant".Code WHERE("Item No." = FIELD("Item No.")) |
| **Editable** | No |
| **Required** | No |

**Purpose**: Identifies the item variant whose allocation was cancelled (if applicable).

**Business Logic**:
- Copied from Sales Line."Variant Code" or Purchase Line."Variant Code"
- Blank if the item does not use variants or no specific variant was specified
- Used for variant-specific reporting

**Technical Notes**:
- Maximum length 10 characters
- Table relation is conditional on Item No. field

---

### Location Code

| Property | Value |
|----------|-------|
| **Field Number** | 8 |
| **Field Name** | Location Code |
| **Caption** | Location Code |
| **Data Type** | Code[10] |
| **Table Relation** | Location |
| **Editable** | No |
| **Required** | No |

**Purpose**: Identifies the warehouse location where the allocation was cancelled.

**Business Logic**:
- Copied from Sales Line."Location Code" or Purchase Line."Location Code"
- Important for multi-location operations
- Used for location-based analysis and reporting

**Usage**:
- Filter history by location
- Analyze cancellation patterns by warehouse
- Support location-specific operational reviews

---

### Quantity Cancelled

| Property | Value |
|----------|-------|
| **Field Number** | 9 |
| **Field Name** | Quantity Cancelled |
| **Caption** | Quantity Cancelled |
| **Data Type** | Decimal |
| **Decimal Places** | 0:5 |
| **Editable** | No |
| **Required** | No |

**Purpose**: Records the quantity of inventory that was released by the cancellation.

**Business Logic**:
- Calculated as ABS(Reservation Entry.Quantity)
- Always positive (absolute value)
- In the unit of measure specified in "Unit of Measure Code" field
- Used for quantitative analysis of cancellations

**Technical Notes**:
- Decimal type allows fractional quantities
- Precision up to 5 decimal places
- Does not include sign (always positive)

---

### Quantity Cancelled (Base)

| Property | Value |
|----------|-------|
| **Field Number** | 10 |
| **Field Name** | Quantity Cancelled (Base) |
| **Caption** | Quantity Cancelled (Base) |
| **Data Type** | Decimal |
| **Decimal Places** | 0:5 |
| **Editable** | No |
| **Required** | No |

**Purpose**: Records the quantity cancelled in the item's base unit of measure.

**Business Logic**:
- Calculated as ABS(Reservation Entry."Quantity (Base)")
- Converted to base UOM regardless of the line's UOM
- Used for consistent reporting across different units of measure
- Always positive (absolute value)

**Usage**:
- Aggregate quantities across different UOMs
- Standardized reporting and analysis
- Inventory impact calculations

---

### Cancellation Date

| Property | Value |
|----------|-------|
| **Field Number** | 11 |
| **Field Name** | Cancellation Date |
| **Caption** | Cancellation Date |
| **Data Type** | Date |
| **Editable** | No |
| **Required** | No |

**Purpose**: The date the cancellation was performed.

**Business Logic**:
- Set to TODAY when history record is created
- Used for date-based filtering and trending
- Part of the DateKey index for efficient date range queries

---

### Cancellation Time

| Property | Value |
|----------|-------|
| **Field Number** | 12 |
| **Field Name** | Cancellation Time |
| **Caption** | Cancellation Time |
| **Data Type** | Time |
| **Editable** | No |
| **Required** | No |

**Purpose**: The time of day the cancellation was performed.

**Business Logic**:
- Set to TIME when history record is created
- Provides precise timing for audit purposes
- Combined with Cancellation Date for complete timestamp

**Technical Note**: Time type stores time of day without date component. Precision to the second.

---

### Cancelled By User ID

| Property | Value |
|----------|-------|
| **Field Number** | 13 |
| **Field Name** | Cancelled By User ID |
| **Caption** | Cancelled By User ID |
| **Data Type** | Code[50] |
| **Table Relation** | User."User Name" |
| **Validate Table Relation** | No |
| **Editable** | No |
| **Required** | No |

**Purpose**: Records which user performed the cancellation.

**Business Logic**:
- Set to USERID when history record is created
- Used for accountability and user activity analysis
- Part of the UserKey index for efficient user-based queries

**Technical Notes**:
- Stores user name, not User Security ID
- Does not validate table relation (allows for deleted users)
- Maximum length 50 characters

---

### Cancellation Reason Code

| Property | Value |
|----------|-------|
| **Field Number** | 14 |
| **Field Name** | Cancellation Reason Code |
| **Caption** | Cancellation Reason Code |
| **Data Type** | Code[10] |
| **Table Relation** | "Reason Code" |
| **Editable** | No |
| **Required** | No |

**Purpose**: Business reason code explaining why the allocation was cancelled.

**Business Logic**:
- Selected by user during cancellation process
- Mandatory during cancellation (user must select a code)
- Used for categorizing and analyzing cancellation patterns
- Part of the ReasonKey index for efficient reason-based queries

**Usage**:
- Categorize cancellations by business reason
- Identify common cancellation causes
- Support process improvement initiatives
- Compliance and audit reporting

---

### Original Reservation Entry No.

| Property | Value |
|----------|-------|
| **Field Number** | 15 |
| **Field Name** | Original Reservation Entry No. |
| **Caption** | Original Reservation Entry No. |
| **Data Type** | Integer |
| **Editable** | No |
| **Required** | No |

**Purpose**: Links the history record back to the original reservation entry that was cancelled.

**Business Logic**:
- Copied from Reservation Entry."Entry No."
- Enables traceability between history and reservation entries
- Used for detailed technical analysis and troubleshooting

**Technical Notes**:
- Reservation entry still exists in Reservation Entry table with VT Is Cancelled = TRUE
- Both tables reference each other for bi-directional navigation

---

### Customer/Vendor No.

| Property | Value |
|----------|-------|
| **Field Number** | 16 |
| **Field Name** | Customer/Vendor No. |
| **Caption** | Customer/Vendor No. |
| **Data Type** | Code[20] |
| **Editable** | No |
| **Required** | No |

**Purpose**: Identifies the trading partner (customer or vendor) associated with the cancelled allocation.

**Business Logic**:
- For sales: Copied from Sales Line."Sell-to Customer No."
- For purchase: Copied from Purchase Line."Buy-from Vendor No."
- Used for partner-specific reporting and analysis

**Usage**:
- Filter history by customer or vendor
- Analyze cancellation patterns by trading partner
- Support customer service inquiries

---

### Customer/Vendor Name

| Property | Value |
|----------|-------|
| **Field Number** | 17 |
| **Field Name** | Customer/Vendor Name |
| **Caption** | Customer/Vendor Name |
| **Data Type** | Text[100] |
| **Editable** | No |
| **Required** | No |

**Purpose**: Stores the name of the trading partner for human-readable display.

**Business Logic**:
- For sales: Copied from Customer.Name
- For purchase: Copied from Vendor.Name
- Denormalized for performance (avoids joins in list views)
- Value persists even if customer/vendor is renamed or deleted

**Technical Notes**:
- Maximum length 100 characters
- Snapshot of name at time of cancellation
- May differ from current name if partner was renamed

---

### Unit of Measure Code

| Property | Value |
|----------|-------|
| **Field Number** | 18 |
| **Field Name** | Unit of Measure Code |
| **Caption** | Unit of Measure Code |
| **Data Type** | Code[10] |
| **Table Relation** | "Unit of Measure" |
| **Editable** | No |
| **Required** | No |

**Purpose**: Identifies the unit of measure for the Quantity Cancelled field.

**Business Logic**:
- Copied from Sales Line."Unit of Measure Code" or Purchase Line."Unit of Measure Code"
- Provides context for interpreting Quantity Cancelled
- Used when quantity needs to be displayed with correct UOM

---

### Cancellation Comments

| Property | Value |
|----------|-------|
| **Field Number** | 19 |
| **Field Name** | Cancellation Comments |
| **Caption** | Cancellation Comments |
| **Data Type** | Text[250] |
| **Editable** | No |
| **Required** | No |

**Purpose**: Stores optional free-text comments explaining the cancellation in more detail.

**Business Logic**:
- Optional field (can be blank)
- Entered by user during cancellation process (if implemented)
- Currently not prompted in standard UI but available in data model for future enhancement

**Technical Notes**:
- Maximum length 250 characters
- Stored as Text type (not CLOBs)

---

### Source Subtype

| Property | Value |
|----------|-------|
| **Field Number** | 20 |
| **Field Name** | Source Subtype |
| **Caption** | Source Subtype |
| **Data Type** | Integer |
| **Editable** | No |
| **Required** | No |

**Purpose**: Internal identifier for the document subtype (Order, Quote, etc.).

**Business Logic**:
- Copied from Sales Line."Document Type".AsInteger() or Purchase Line."Document Type".AsInteger()
- Used in conjunction with Source Type for precise document identification
- Corresponds to enum integer values

**Technical Notes**:
- 0 = Quote, 1 = Order, etc.
- Stored as integer for database efficiency
- Redundant with Document Type field but useful for technical queries

---

## Allocation Status Enum Values

The **VT Allocation Status** enum (Enum 50100) has two defined values:

### Active (Value 0)

**Meaning**: The allocation on the order line is currently active, or no allocation has ever been cancelled on this line.

**Usage**:
- Default value for new lines
- Indicates normal operational state
- Line is eligible for cancellation if it has active reservations

**Display**: Shows as "Active" in the UI

---

### Cancelled (Value 1)

**Meaning**: The allocation on the order line has been cancelled through the cancellation process.

**Usage**:
- Set by the cancellation management codeunit
- Indicates the allocation has been released
- Line is not eligible for re-cancellation unless new allocations are created

**Display**: Shows as "Cancelled" in the UI, often with subordinate/gray styling

**Business Logic**:
- Does not prevent creating new reservations on the same line
- If new reservations are created and then cancelled, another history record is generated
- Permanent marker of past cancellation activity

---

## Index and Key Structure

For optimal performance, the VT Allocation Cancel History table includes these keys:

### Primary Key (PK)
- **Fields**: Entry No.
- **Clustered**: Yes
- **Purpose**: Unique identifier, default sorting

### DocumentKey
- **Fields**: Document Type, Document No., Line No.
- **Purpose**: Fast lookups when filtering history from a specific document

### DateKey
- **Fields**: Cancellation Date, Cancellation Time
- **Purpose**: Date range queries and chronological analysis

### UserKey
- **Fields**: Cancelled By User ID, Cancellation Date
- **Purpose**: User activity analysis and reporting

### ItemKey
- **Fields**: Item No., Cancellation Date
- **Purpose**: Item-level analysis and trending

### ReasonKey
- **Fields**: Cancellation Reason Code, Cancellation Date
- **Purpose**: Reason-based analysis and categorization

---

## Field Usage Summary

| Field Category | Primary Use Case | Key Fields |
|----------------|------------------|------------|
| **Identification** | Uniquely identify the cancellation | Entry No., Document Type, Document No., Line No. |
| **Item Information** | Identify what was cancelled | Item No., Variant Code, Location Code, Quantity Cancelled |
| **Audit Trail** | Who, when, why | Cancelled By User ID, Cancellation Date, Cancellation Time, Cancellation Reason Code |
| **Traceability** | Link to source records | Source Type, Source Subtype, Original Reservation Entry No. |
| **Analysis** | Reporting and trending | Customer/Vendor No., Item No., Cancellation Reason Code, Cancellation Date |

---

## Related Topics

- **[Overview](overview.md)**: Understand the purpose and scope of allocation cancellation
- **[Getting Started](getting-started.md)**: Prerequisites and access information
- **[Cancel Sales Order Allocations](cancel-sales-order-allocation.md)**: How to use the cancellation features
- **[Cancel Purchase Order Allocations](cancel-purchase-order-allocation.md)**: How to use the cancellation features
- **[View Cancellation History](view-cancellation-history.md)**: Working with history records
- **[Troubleshooting](troubleshooting.md)**: Detailed error resolution
