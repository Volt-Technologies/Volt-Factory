# AL RDLC Report Development from PDF Mock-up

This guide defines how to analyze a PDF mock-up (example report) and translate it into a working RDLC report layout. When a user provides a PDF example, follow these rules to create the corresponding AL report object and RDLC layout.

## PDF Mock-up Analysis Workflow

### Step 1: Initial PDF Analysis

When you receive a PDF mock-up, analyze it systematically:

```
1. DOCUMENT STRUCTURE
   - Page orientation (Portrait/Landscape)
   - Page size (Letter, A4, Legal)
   - Margins (approximate in inches)
   - Number of pages (single page or multi-page pattern)

2. HEADER SECTION
   - Company logo position and size
   - Report title text and formatting
   - Date/time display
   - Page numbers format
   - Any filter/parameter display

3. BODY CONTENT
   - Data table structure (columns, rows)
   - Column headers and their alignment
   - Data types in each column (text, numbers, dates, amounts)
   - Column widths (relative proportions)
   - Row grouping patterns
   - Subtotals and grouping levels

4. FOOTER SECTION
   - Footer text content
   - Page number format
   - Total summaries
```

### Step 2: Identify Data Requirements

From the PDF, determine what data is needed:

```
CHECKLIST:
[ ] Primary data source table (e.g., Customer, Sales Header)
[ ] Related tables needed (e.g., Sales Line, Item)
[ ] Fields to display in each column
[ ] Calculated fields needed
[ ] Grouping hierarchy (Group By fields)
[ ] Sorting requirements
[ ] Filter parameters from request page
```

### Step 3: Map PDF Elements to RDLC Components

| PDF Element | RDLC Component | Notes |
|-------------|----------------|-------|
| Report title | TextBox in PageHeader | Static or parameter-based |
| Column headers | Header row in Tablix | TablixHeader cells |
| Data rows | Detail row in Tablix | TablixBody with TablixCells |
| Group headers | Group header row | TablixMember with Group |
| Subtotals | Group footer row | Aggregate expressions |
| Grand totals | Tablix footer or PageFooter | Sum expressions |
| Page numbers | TextBox in PageFooter | =Globals!PageNumber |
| Logo | Image in PageHeader | EmbeddedImage reference |

## PDF Visual Analysis Guidelines

### Analyzing Column Structure

When looking at a data table in the PDF:

```
1. COUNT COLUMNS
   - Count visible columns from left to right
   - Note any merged header cells (spanning columns)

2. MEASURE COLUMN WIDTHS
   - Estimate relative widths (e.g., 15%, 30%, 20%, 35%)
   - Convert to inches for RDLC (typical page width: 6.5" usable)
   - Example: 15% of 6.5" = 0.975in

3. IDENTIFY ALIGNMENT
   - Text columns: typically left-aligned
   - Number columns: typically right-aligned
   - Date columns: can be left or center
   - Header alignment often matches data alignment

4. DETECT DATA TYPES
   - Text: Variable content, left-aligned
   - Code: Fixed format like "CUST001", often uppercase
   - Integer: Whole numbers, no decimals
   - Decimal: Numbers with decimal points (amounts, quantities)
   - Date: Date format patterns
   - Boolean: Yes/No, checkmarks
```

### Analyzing Grouping Patterns

Look for visual grouping indicators:

```
GROUPING INDICATORS:
- Indentation of rows
- Bold or highlighted group headers
- Subtotal rows with different styling
- Blank rows separating groups
- Group header spanning full width
- Alternating group backgrounds

EXAMPLE HIERARCHY:
Level 1: Customer (bold, full-width header)
  Level 2: Document Type (indented, semi-bold)
    Detail: Individual lines (most indented)
    Subtotal: Document totals
  Subtotal: Customer totals
Grand Total: Report totals
```

### Analyzing Formatting

Extract formatting details:

```
FONTS:
- Header font: typically bold, possibly larger
- Data font: regular weight
- Total font: often bold
- Estimate sizes: Headers 10-12pt, Data 8-10pt

COLORS:
- Header background: often shaded (light gray, blue)
- Alternating rows: subtle shading for readability
- Total rows: highlighted background
- Negative numbers: red

BORDERS:
- Table outline: typically solid
- Column separators: thin lines or none
- Row separators: thin lines or none
- Header bottom border: often thicker

SPACING:
- Cell padding: typically 2-4pt
- Row height: based on font size + padding
- Line spacing within cells
```

## Translation Process

### From PDF Analysis to AL Report

```al
// Example: PDF shows Customer List with columns:
// No. | Name | City | Balance

report 50100 "VOL Customer List"
{
    Caption = 'Customer List';
    DefaultRenderingLayout = RDLCLayout;

    dataset
    {
        dataitem(Customer; Customer)
        {
            // Map PDF columns to AL columns
            column(No_; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column(City; City)
            {
            }
            column(Balance_LCY_; "Balance (LCY)")
            {
            }
            // Add system columns for headers/footers
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
        }
    }

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/Reports/Layouts/VOLCustomerList.Report.rdlc';
        }
    }

    var
        ReportTitleLbl: Label 'Customer List';
}
```

### From PDF Analysis to RDLC Measurements

```
PDF PAGE ANALYSIS → RDLC SETTINGS

Page Size Detection:
- US Letter: 8.5" x 11" (most common)
- A4: 8.27" x 11.69"
- Legal: 8.5" x 14"

Margin Estimation:
- Standard margins: 0.5" to 1" all sides
- Narrow margins: 0.25" to 0.5"
- If content is close to edge: smaller margins

Usable Width Calculation:
- Letter with 1" margins: 8.5 - 2 = 6.5" usable
- A4 with 1" margins: 8.27 - 2 = 6.27" usable

Column Width Conversion:
1. Measure relative column widths from PDF
2. Convert percentages to inches
3. Account for cell padding in RDLC
```

### RDLC Size Specifications from PDF

```xml
<!-- Page Setup based on PDF analysis -->
<PageWidth>8.5in</PageWidth>
<PageHeight>11in</PageHeight>
<LeftMargin>0.5in</LeftMargin>
<RightMargin>0.5in</RightMargin>
<TopMargin>0.5in</TopMargin>
<BottomMargin>0.5in</BottomMargin>

<!-- Body width = PageWidth - LeftMargin - RightMargin -->
<!-- 8.5 - 0.5 - 0.5 = 7.5in -->
<Body>
  <Height>9in</Height>
  <Width>7.5in</Width>
</Body>
```

## Common PDF Patterns and RDLC Solutions

### Pattern 1: Simple List Report

**PDF Characteristics:**
- Single header row
- Multiple data rows
- No grouping
- Optional totals at bottom

**RDLC Structure:**
```
PageHeader: Report title, date, page number
Body: Single Tablix with header row + detail row
PageFooter: Page X of Y
```

### Pattern 2: Grouped Report with Subtotals

**PDF Characteristics:**
- Group headers (e.g., by Customer)
- Detail rows within each group
- Subtotals per group
- Grand total at end

**RDLC Structure:**
```
PageHeader: Report title, filters
Body: Tablix with:
  - Static header row (column titles)
  - Group header row (group value)
  - Detail row (line items)
  - Group footer row (subtotals)
  - Tablix footer (grand totals)
PageFooter: Page numbers
```

### Pattern 3: Document-Style Report (Invoice/Order)

**PDF Characteristics:**
- Header section with document info
- Bill-to/Ship-to addresses
- Line items table
- Totals section
- Footer with terms/notes

**RDLC Structure:**
```
PageHeader: Company logo, document title
Body:
  - Rectangle: Document header info
  - Rectangle: Address blocks (side by side)
  - Tablix: Line items
  - Rectangle: Totals section
PageFooter: Terms, page numbers
```

### Pattern 4: Multi-Column Report

**PDF Characteristics:**
- Data in 2 or 3 columns
- Newspaper-style flow

**RDLC Structure:**
```
Body: Tablix with Columns property > 1
  - Set ColumnSpacing
  - Content flows left-to-right, top-to-bottom
```

## Expression Mapping from PDF Values

### Static Text from PDF

If PDF shows static text "Customer Report", use:
```xml
<Value>Customer Report</Value>
```

### Dynamic Values

If PDF shows a field value, map to expression:
```xml
<!-- Customer number from data -->
<Value>=Fields!No_.Value</Value>

<!-- Formatted amount -->
<Value>=Format(Fields!Balance_LCY_.Value, "#,##0.00")</Value>

<!-- Date formatted -->
<Value>=Format(Fields!PostingDate.Value, "MM/dd/yyyy")</Value>
```

### Calculated Totals from PDF

If PDF shows totals:
```xml
<!-- Sum of column -->
<Value>=Sum(Fields!Amount.Value)</Value>

<!-- Count of rows -->
<Value>=CountRows()</Value>

<!-- Running total -->
<Value>=RunningValue(Fields!Amount.Value, Sum, Nothing)</Value>
```

## Validation Checklist

After creating RDLC from PDF mock-up, verify:

```
STRUCTURE VALIDATION:
[ ] Page size matches PDF
[ ] Margins create similar usable area
[ ] Number of columns matches
[ ] Column widths are proportionally correct
[ ] Grouping levels match PDF hierarchy

CONTENT VALIDATION:
[ ] All visible fields are included
[ ] Headers match PDF text
[ ] Data alignment matches (left/right/center)
[ ] Number formats match (decimals, thousands separator)
[ ] Date formats match

FORMATTING VALIDATION:
[ ] Font sizes are similar
[ ] Bold/regular matches PDF
[ ] Colors approximate PDF (or client preference)
[ ] Borders match PDF style
[ ] Row spacing is similar

FUNCTIONALITY VALIDATION:
[ ] Grouping produces same visual breaks
[ ] Subtotals appear at correct positions
[ ] Grand totals are present if in PDF
[ ] Page breaks occur appropriately
[ ] Headers repeat on new pages (if shown in multi-page PDF)
```

## Handling Ambiguity in PDF Analysis

When PDF details are unclear:

### Font Size Uncertainty
```
Default to:
- Report title: 14pt bold
- Section headers: 12pt bold
- Column headers: 10pt bold
- Data cells: 9pt regular
- Footers: 8pt regular
```

### Color Uncertainty
```
Default to:
- Headers: #4472C4 (blue) or #404040 (dark gray)
- Alternating rows: #F2F2F2 (light gray)
- Totals background: #D9E2F3 (light blue)
- Borders: #000000 (black) or #808080 (gray)
```

### Measurement Uncertainty
```
Default column widths by type:
- Code fields (No., ID): 1.0in - 1.25in
- Name/Description: 2.0in - 3.0in
- Date fields: 0.85in - 1.0in
- Amount fields: 1.0in - 1.25in
- Quantity fields: 0.75in - 1.0in
- Percentage fields: 0.75in
```

## Example: Complete PDF to RDLC Translation

### Given PDF Mock-up Shows:

```
+------------------------------------------------------------------+
|  ACME Corporation              CUSTOMER BALANCE REPORT           |
|                                As of: 12/15/2024                 |
+------------------------------------------------------------------+
| Customer No. | Customer Name        | City          | Balance    |
+------------------------------------------------------------------+
| CUST001      | Alpine Ski House     | Denver        |   1,234.56 |
| CUST002      | Blue Sky Airlines    | Seattle       |   5,678.90 |
| CUST003      | Canyon Road Sports   | Phoenix       |     456.78 |
+------------------------------------------------------------------+
|                                          TOTAL:     |   7,370.24 |
+------------------------------------------------------------------+
|                                               Page 1 of 1        |
+------------------------------------------------------------------+
```

### Resulting AL Report:

```al
report 50100 "VOL Customer Balance Report"
{
    Caption = 'Customer Balance Report';
    DefaultRenderingLayout = RDLCLayout;

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No_; "No.") { }
            column(Name; Name) { }
            column(City; City) { }
            column(Balance_LCY_; "Balance (LCY)") { }
            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportTitle; ReportTitleLbl) { }
            column(AsOfDate; AsOfDateLbl + Format(WorkDate())) { }
        }
    }

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/Reports/Layouts/VOLCustomerBalanceReport.Report.rdlc';
        }
    }

    var
        ReportTitleLbl: Label 'CUSTOMER BALANCE REPORT';
        AsOfDateLbl: Label 'As of: ';
}
```

### RDLC Key Measurements:

```xml
<!-- Page: Letter size, 0.5" margins -->
<PageWidth>8.5in</PageWidth>
<PageHeight>11in</PageHeight>
<LeftMargin>0.5in</LeftMargin>
<RightMargin>0.5in</RightMargin>

<!-- Columns (total width: 7.5in) -->
<!-- Customer No.: 1.25in (17%) -->
<!-- Customer Name: 2.5in (33%) -->
<!-- City: 1.75in (23%) -->
<!-- Balance: 1.25in (17%) -->
<!-- Padding/borders: 0.75in (10%) -->
```

## Integration with Testing

After generating RDLC from PDF mock-up:

1. **Compile and publish** the report
2. **Generate test PDF** using VOL Report Test Helper
3. **Save test PDF** to `test-outputs/reports/` folder
4. **Compare visually** with original mock-up
5. **Iterate** if layout doesn't match expectations

The test PDF output allows human verification that the generated RDLC matches the original PDF mock-up intent.
