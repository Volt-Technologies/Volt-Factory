# AL RDLC Report Development Rules

This document provides comprehensive guidelines for developing Business Central Report objects with RDLC layouts. The agent MUST follow these rules exhaustively to produce correct, compilable, and renderable reports.

## Table of Contents
1. [Report Object Structure](#report-object-structure)
2. [DataItems and Columns](#dataitems-and-columns)
3. [Triggers and Events](#triggers-and-events)
4. [Request Page](#request-page)
5. [Layout References](#layout-references)
6. [Labels and Captions](#labels-and-captions)
7. [Variable Declarations](#variable-declarations)
8. [Common Patterns](#common-patterns)
9. [Naming Conventions](#naming-conventions)
10. [Object ID Ranges](#object-id-ranges)

---

## Report Object Structure

### Basic Report Skeleton

Every AL report object MUST follow this structure:

```al
report 50100 "VOL Sample Report"
{
    Caption = 'Sample Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = "VOLSampleReport.rdlc";

    dataset
    {
        // DataItems go here
    }

    requestpage
    {
        // Request page layout and triggers
    }

    rendering
    {
        layout("VOLSampleReport.rdlc")
        {
            Type = RDLC;
            LayoutFile = './src/Reports/VOLSampleReport.rdlc';
        }
    }

    labels
    {
        // Report labels for captions
    }

    var
        // Global variables
}
```

### Mandatory Properties

| Property | Description | Required |
|----------|-------------|----------|
| `Caption` | Display name in UI | Yes |
| `UsageCategory` | Where report appears in search | Recommended |
| `ApplicationArea` | License area filter | Recommended |
| `DefaultRenderingLayout` | Default RDLC layout name | Yes (if using rendering section) |

### Alternative Layout Reference (Legacy Style)

For simpler reports without multiple layouts:

```al
report 50100 "VOL Sample Report"
{
    Caption = 'Sample Report';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/VOLSampleReport.rdlc';

    dataset { ... }
}
```

**IMPORTANT**: Use the `rendering` section approach for new development. It supports multiple layouts and is the modern pattern.

---

## DataItems and Columns

### DataItem Declaration

DataItems define the data sources for the report. Each dataitem represents a table.

```al
dataset
{
    dataitem(Customer; Customer)
    {
        DataItemTableView = sorting("No.") where(Blocked = const(" "));
        RequestFilterFields = "No.", "Customer Posting Group", "Country/Region Code";

        column(No_Customer; "No.")
        {
        }
        column(Name_Customer; Name)
        {
        }
        column(Balance_LCY_Customer; "Balance (LCY)")
        {
        }
    }
}
```

### DataItem Properties

| Property | Description | Example |
|----------|-------------|---------|
| `DataItemTableView` | Default sorting and filtering | `sorting("No.") where(Status = const(Open))` |
| `RequestFilterFields` | Fields users can filter on | `"No.", "Customer Posting Group"` |
| `PrintOnlyIfDetail` | Only print if child has records | `PrintOnlyIfDetail = true;` |
| `MaxIteration` | Limit iterations | `MaxIteration = 1;` |

### Nested DataItems

For master-detail relationships (e.g., Header-Lines):

```al
dataset
{
    dataitem(SalesHeader; "Sales Header")
    {
        DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
        RequestFilterFields = "No.", "Sell-to Customer No.";

        column(No_SalesHeader; "No.") { }
        column(SellToCustomerNo; "Sell-to Customer No.") { }

        dataitem(SalesLine; "Sales Line")
        {
            DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

            column(LineNo_SalesLine; "Line No.") { }
            column(Description_SalesLine; Description) { }
            column(Quantity_SalesLine; Quantity) { }
            column(Amount_SalesLine; Amount) { }
        }
    }
}
```

### DataItemLink Rules

- `DataItemLink` connects child dataitem to parent
- Uses `field()` function to reference parent fields
- Multiple links separated by commas
- Child records automatically filtered by parent values

### Column Declaration

Columns define what data is exposed to the RDLC layout.

```al
column(ColumnName; SourceExpression)
{
    // Optional properties
}
```

### Column Naming Convention - CRITICAL

**The column name in AL becomes the field name in RDLC DataSet with special character handling:**

| AL Column Name | RDLC Field Name |
|----------------|-----------------|
| `No_Customer` | `No_Customer` |
| `"Balance (LCY)"` | `Balance__LCY_` |
| `Address 2` | `Address_2` |
| `"Sell-to Customer No."` | `Sell_to_Customer_No_` |

**Rule**: Spaces, periods, parentheses, and hyphens become underscores in RDLC.

### Recommended Column Naming Pattern

Use this pattern for clear RDLC field references:

```al
// Pattern: FieldName_TableName (without special chars)
column(No_Customer; "No.") { }
column(Name_Customer; Name) { }
column(BalanceLCY_Customer; "Balance (LCY)") { }
column(SelltoCustomerNo_SalesHeader; "Sell-to Customer No.") { }
```

### Calculated Columns

For calculated values, use variables:

```al
dataitem(Customer; Customer)
{
    column(TotalOrders; TotalOrderCount) { }

    trigger OnAfterGetRecord()
    begin
        TotalOrderCount := GetOrderCount("No.");
    end;
}

var
    TotalOrderCount: Integer;

local procedure GetOrderCount(CustomerNo: Code[20]): Integer
var
    SalesHeader: Record "Sales Header";
begin
    SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
    exit(SalesHeader.Count);
end;
```

### FlowField Columns

FlowFields MUST be calculated before use:

```al
dataitem(Customer; Customer)
{
    column(Balance_Customer; "Balance (LCY)") { }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Balance (LCY)");
    end;
}
```

---

## Triggers and Events

### DataItem Triggers

```al
dataitem(Customer; Customer)
{
    trigger OnPreDataItem()
    begin
        // Runs once before processing records
        // Use for: Setting filters, initializing variables
        SetRange("Date Filter", StartDate, EndDate);
    end;

    trigger OnAfterGetRecord()
    begin
        // Runs for each record
        // Use for: Calculations, CalcFields, conditional logic
        CalcFields("Balance (LCY)");

        if "Balance (LCY)" = 0 then
            CurrReport.Skip();
    end;

    trigger OnPostDataItem()
    begin
        // Runs once after all records processed
        // Use for: Finalizing calculations, cleanup
    end;
}
```

### Report-Level Triggers

```al
report 50100 "VOL Sample Report"
{
    trigger OnInitReport()
    begin
        // Runs when report initializes
        // Use for: Setting initial values
        CompanyInfo.Get();
    end;

    trigger OnPreReport()
    begin
        // Runs before any data processing
        // Use for: Validations, setting up header data
        if StartDate > EndDate then
            Error(InvalidDateRangeErr);
    end;

    trigger OnPostReport()
    begin
        // Runs after all processing complete
        // Use for: Final messages, logging
    end;
}
```

### CurrReport Functions

| Function | Description |
|----------|-------------|
| `CurrReport.Skip()` | Skip current record, don't output |
| `CurrReport.Break()` | Stop processing current dataitem |
| `CurrReport.Quit()` | Exit report completely |
| `CurrReport.Preview()` | Open in preview mode |
| `CurrReport.Print()` | Send directly to printer |
| `CurrReport.SaveAs()` | Save to file |

---

## Request Page

### Basic Request Page

```al
requestpage
{
    SaveValues = true;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';

                field(StartDateField; StartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the start date for the report period.';
                }
                field(EndDateField; EndDate)
                {
                    ApplicationArea = All;
                    Caption = 'End Date';
                    ToolTip = 'Specifies the end date for the report period.';
                }
                field(IncludeBlockedField; IncludeBlocked)
                {
                    ApplicationArea = All;
                    Caption = 'Include Blocked';
                    ToolTip = 'Specifies if blocked records should be included.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if StartDate = 0D then
            StartDate := WorkDate();
        if EndDate = 0D then
            EndDate := WorkDate();
    end;
}

var
    StartDate: Date;
    EndDate: Date;
    IncludeBlocked: Boolean;
```

### Request Page Properties

| Property | Description |
|----------|-------------|
| `SaveValues = true` | Remember user's last selections |

---

## Layout References

### Modern Rendering Section (Recommended)

```al
rendering
{
    layout("VOLCustomerList.rdlc")
    {
        Type = RDLC;
        LayoutFile = './src/Reports/VOLCustomerList.rdlc';
        Caption = 'Customer List (Standard)';
    }
    layout("VOLCustomerListAlt.rdlc")
    {
        Type = RDLC;
        LayoutFile = './src/Reports/VOLCustomerListAlt.rdlc';
        Caption = 'Customer List (Alternative)';
    }
}
```

### Layout File Path Rules

- Paths are relative to the AL file location
- Use forward slashes `/` in paths
- File extension must be `.rdlc`
- Path is case-sensitive on some platforms

### Recommended Folder Structure

```
src/
├── Reports/
│   ├── VOLCustomerList.Report.al
│   ├── VOLCustomerList.rdlc
│   ├── VOLSalesInvoice.Report.al
│   └── VOLSalesInvoice.rdlc
```

---

## Labels and Captions

### Report Labels Section

Labels provide translatable text for the RDLC:

```al
labels
{
    ReportTitleLbl = 'Customer List', Comment = 'Report title shown at top';
    PageNoLbl = 'Page', Comment = 'Page number label';
    TotalLbl = 'Total', Comment = 'Total label for sums';
    DateFilterLbl = 'Date Filter:', Comment = 'Label for date filter display';
    PreparedByLbl = 'Prepared by:', Comment = 'Label showing who prepared report';
    CompanyNameLbl = 'Company Name', Comment = 'Company name header';
}
```

### Using Labels in DataItem Columns

Labels can be exposed as columns:

```al
dataitem(Customer; Customer)
{
    column(ReportTitle; ReportTitleLbl) { }
    column(PageNoCaption; PageNoLbl) { }
    column(TotalCaption; TotalLbl) { }

    // Data columns...
}
```

### Label in RDLC Reference

In RDLC, labels are accessed as fields:
```
=Fields!ReportTitle.Value
```

---

## Variable Declarations

### Global Variables Pattern

```al
var
    // Records
    CompanyInfo: Record "Company Information";
    GLSetup: Record "General Ledger Setup";

    // Formatting
    FormatAddr: Codeunit "Format Address";
    FormatDoc: Codeunit "Format Document";

    // Report Data
    CustAddr: array[8] of Text[100];
    CompanyAddr: array[8] of Text[100];

    // Calculated Values
    TotalAmount: Decimal;
    LineCount: Integer;

    // Parameters from Request Page
    StartDate: Date;
    EndDate: Date;
    IncludeBlocked: Boolean;

    // Error Labels
    InvalidDateRangeErr: Label 'Start Date must not be after End Date.';
```

### Address Formatting Pattern

For address fields, use the standard array pattern:

```al
dataitem(Customer; Customer)
{
    column(CustAddr1; CustAddr[1]) { }
    column(CustAddr2; CustAddr[2]) { }
    column(CustAddr3; CustAddr[3]) { }
    column(CustAddr4; CustAddr[4]) { }
    column(CustAddr5; CustAddr[5]) { }
    column(CustAddr6; CustAddr[6]) { }
    column(CustAddr7; CustAddr[7]) { }
    column(CustAddr8; CustAddr[8]) { }

    trigger OnAfterGetRecord()
    begin
        FormatAddr.FormatAddr(
            CustAddr,
            Name,
            "Name 2",
            '',
            Address,
            "Address 2",
            City,
            "Post Code",
            County,
            "Country/Region Code");
    end;
}
```

---

## Common Patterns

### Document Report Pattern (Invoice/Order Style)

```al
report 50100 "VOL Sales Invoice"
{
    Caption = 'Sales Invoice';
    DefaultRenderingLayout = "VOLSalesInvoice.rdlc";

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "Posting Date";

            column(No_Header; "No.") { }
            column(PostingDate_Header; "Posting Date") { }
            column(SelltoCustomerNo_Header; "Sell-to Customer No.") { }
            column(SelltoCustomerName_Header; "Sell-to Customer Name") { }
            column(BilltoAddress; BilltoAddr[1]) { }
            column(BilltoAddress2; BilltoAddr[2]) { }
            // ... more address columns

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddress; CompanyAddr[1]) { }
            // ... more company columns

            dataitem(SalesInvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(LineNo_Line; "Line No.") { }
                column(Type_Line; Type) { }
                column(No_Line; "No.") { }
                column(Description_Line; Description) { }
                column(Quantity_Line; Quantity) { }
                column(UnitPrice_Line; "Unit Price") { }
                column(LineAmount_Line; "Line Amount") { }
                column(VATPercent_Line; "VAT %") { }

                trigger OnAfterGetRecord()
                begin
                    TotalAmount += "Line Amount";
                    TotalVATAmount += "Amount Including VAT" - "Line Amount";
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // Reset totals for each document
                TotalAmount := 0;
                TotalVATAmount := 0;

                // Format addresses
                FormatAddr.SalesInvBillTo(BilltoAddr, SalesInvoiceHeader);
            end;

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                FormatAddr.Company(CompanyAddr, CompanyInfo);
            end;
        }
    }

    rendering
    {
        layout("VOLSalesInvoice.rdlc")
        {
            Type = RDLC;
            LayoutFile = './src/Reports/VOLSalesInvoice.rdlc';
        }
    }

    var
        CompanyInfo: Record "Company Information";
        FormatAddr: Codeunit "Format Address";
        BilltoAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        TotalAmount: Decimal;
        TotalVATAmount: Decimal;
}
```

### List Report Pattern

```al
report 50101 "VOL Customer List"
{
    Caption = 'Customer List';
    DefaultRenderingLayout = "VOLCustomerList.rdlc";

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Customer Posting Group", "Country/Region Code";

            column(No_Customer; "No.") { }
            column(Name_Customer; Name) { }
            column(Address_Customer; Address) { }
            column(City_Customer; City) { }
            column(PhoneNo_Customer; "Phone No.") { }
            column(BalanceLCY_Customer; "Balance (LCY)") { }

            // Labels as columns
            column(ReportTitle; ReportTitleLbl) { }
            column(PageCaption; PageCaptionLbl) { }
            column(NoCaption; NoCaptionLbl) { }
            column(NameCaption; NameCaptionLbl) { }

            trigger OnAfterGetRecord()
            begin
                CalcFields("Balance (LCY)");
                TotalBalance += "Balance (LCY)";
            end;

            trigger OnPreDataItem()
            begin
                TotalBalance := 0;
            end;
        }
    }

    labels
    {
        ReportTitleLbl = 'Customer List';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        NameCaptionLbl = 'Name';
        TotalLbl = 'Total';
    }

    var
        TotalBalance: Decimal;
}
```

### Grouping Report Pattern

For reports with subtotals by group:

```al
report 50102 "VOL Sales by Customer"
{
    Caption = 'Sales by Customer';
    DefaultRenderingLayout = "VOLSalesByCustomer.rdlc";

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Customer Posting Group";
            PrintOnlyIfDetail = true;

            column(No_Customer; "No.") { }
            column(Name_Customer; Name) { }
            column(CustomerTotal; CustomerTotalAmount) { }

            dataitem(SalesInvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Sell-to Customer No." = field("No.");
                DataItemTableView = sorting("Sell-to Customer No.", "Posting Date");

                column(PostingDate_Line; "Posting Date") { }
                column(DocumentNo_Line; "Document No.") { }
                column(Description_Line; Description) { }
                column(Amount_Line; Amount) { }

                trigger OnAfterGetRecord()
                begin
                    CustomerTotalAmount += Amount;
                    GrandTotal += Amount;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CustomerTotalAmount := 0;
            end;
        }
    }

    var
        CustomerTotalAmount: Decimal;
        GrandTotal: Decimal;
}
```

---

## Naming Conventions

### Report Object Naming

| Element | Convention | Example |
|---------|------------|---------|
| Report Object | `VOL [Description]` | `VOL Sales Invoice` |
| Report File | `VOL[Description].Report.al` | `VOLSalesInvoice.Report.al` |
| RDLC File | `VOL[Description].rdlc` | `VOLSalesInvoice.rdlc` |
| Layout Name | `VOL[Description].rdlc` | `"VOLSalesInvoice.rdlc"` |

### Column Naming

| Pattern | Example |
|---------|---------|
| Field from table | `FieldName_TableAlias` |
| Calculated field | `Calculated[Description]` |
| Label | `[Description]Caption` or `[Description]Lbl` |
| Address array | `[Type]Addr[1-8]` |

### Variable Naming

| Type | Convention | Example |
|------|------------|---------|
| Record | Table name | `CompanyInfo: Record "Company Information"` |
| Address array | `[Type]Addr` | `BilltoAddr: array[8] of Text[100]` |
| Total | `Total[Field]` | `TotalAmount: Decimal` |
| Error label | `[Description]Err` | `InvalidDateErr: Label '...'` |

---

## Object ID Ranges

### Main App ID Range (BC App)

| Object Type | Range |
|-------------|-------|
| Reports | 50100 - 50199 |

### Test App ID Range (BC Test App)

| Object Type | Range |
|-------------|-------|
| Test Codeunits | 90100 - 90199 |
| Test Helper Codeunits | 90200 - 90299 |

---

## Report Execution Patterns

### Running Report from Code

```al
// Simple run
Report.Run(Report::"VOL Customer List");

// Run with record filter
var
    Customer: Record Customer;
begin
    Customer.SetRange("Customer Posting Group", 'DOMESTIC');
    Report.Run(Report::"VOL Customer List", true, false, Customer);
end;

// Parameters: ReportID, RequestWindow, SystemPrinter, RecordRef
```

### Report.SaveAs for PDF Output

```al
procedure SaveReportAsPdf(CustomerNo: Code[20]): Text
var
    Customer: Record Customer;
    TempBlob: Codeunit "Temp Blob";
    InStr: InStream;
    OutStr: OutStream;
    Base64Convert: Codeunit "Base64 Convert";
    RecRef: RecordRef;
begin
    Customer.Get(CustomerNo);
    RecRef.GetTable(Customer);

    TempBlob.CreateOutStream(OutStr);
    Report.SaveAs(Report::"VOL Customer List", '', ReportFormat::Pdf, OutStr, RecRef);

    TempBlob.CreateInStream(InStr);
    exit(Base64Convert.ToBase64(InStr));
end;
```

### Using RecordRef for Dynamic Reports

```al
procedure RunReportWithRecordRef(ReportId: Integer; RecordSystemId: Guid; TableNo: Integer): Text
var
    RecRef: RecordRef;
    TempBlob: Codeunit "Temp Blob";
    InStr: InStream;
    OutStr: OutStream;
    Base64Convert: Codeunit "Base64 Convert";
begin
    RecRef.Open(TableNo);
    if not RecRef.GetBySystemId(RecordSystemId) then
        Error('Record not found');

    TempBlob.CreateOutStream(OutStr);
    Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef);

    TempBlob.CreateInStream(InStr);
    exit(Base64Convert.ToBase64(InStr));
end;
```

---

## Critical Rules Summary

1. **Column names become RDLC field names** - special characters convert to underscores
2. **CalcFields required for FlowFields** - always call in OnAfterGetRecord
3. **DataItemLink connects child to parent** - use `field()` function
4. **Layout path is relative** - use forward slashes
5. **Labels must be exposed as columns** - to appear in RDLC DataSet
6. **Address arrays have 8 elements** - use FormatAddress codeunit
7. **Reset totals in header OnAfterGetRecord** - for document reports
8. **PrintOnlyIfDetail = true** - when header depends on lines
9. **SaveValues = true on requestpage** - for user convenience
10. **Use VOL prefix** - for all custom report objects
