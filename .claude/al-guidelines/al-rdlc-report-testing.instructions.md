# RDLC Report Testing Rules

This document provides comprehensive guidelines for testing Business Central RDLC reports. Testing reports requires a different approach than testing standard business logic because reports produce visual output (PDF) that must be validated.

## Table of Contents

1. [Testing Architecture](#testing-architecture)
2. [Report Test Helper Codeunit](#report-test-helper-codeunit)
3. [PDF Generation Pattern](#pdf-generation-pattern)
4. [Test Codeunit Structure](#test-codeunit-structure)
5. [Test Data Setup](#test-data-setup)
6. [Validation Strategies](#validation-strategies)
7. [Common Test Patterns](#common-test-patterns)
8. [Web Service Integration](#web-service-integration)
9. [Error Handling in Tests](#error-handling-in-tests)
10. [Best Practices](#best-practices)

---

## Testing Architecture

### Overview

Report testing in Business Central follows this flow:

```
Test Setup → Create Test Data → Run Report → Generate PDF → Validate Output
```

### Key Components

| Component | Purpose | Location |
|-----------|---------|----------|
| Test Helper Codeunit | PDF generation, Base64 encoding | BC Test App |
| Test Codeunits | Individual report tests | BC Test App |
| Library Codeunits | Test data creation | BC Test App |
| VOL Test Runner WS | Web service for running tests | BC Test App |

### ID Ranges

| Object Type | ID Range |
|-------------|----------|
| Test Codeunits | 90100 - 90199 |
| Test Helper Codeunits | 90200 - 90299 |
| Test Library Codeunits | 90300 - 90399 |

---

## Report Test Helper Codeunit

### Core Helper Codeunit

Create this helper codeunit in the BC Test app to provide PDF generation capabilities:

```al
codeunit 90200 "VOL Report Test Helper"
{
    /// <summary>
    /// Runs a report with a specific record and returns the PDF as Base64.
    /// </summary>
    /// <param name="ReportId">The report object ID to run.</param>
    /// <param name="TableNo">The table number of the record.</param>
    /// <param name="RecordSystemId">The SystemId of the record to use as filter.</param>
    /// <returns>Base64 encoded PDF content.</returns>
    procedure RunReportAsPdfBase64(ReportId: Integer; TableNo: Integer; RecordSystemId: Guid): Text
    var
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        RecRef.Open(TableNo);
        if not RecRef.GetBySystemId(RecordSystemId) then
            Error(RecordNotFoundErr, TableNo, RecordSystemId);

        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);

        TempBlob.CreateInStream(InStr);
        exit(Base64Convert.ToBase64(InStr));
    end;

    /// <summary>
    /// Runs a report with filtered records and returns the PDF as Base64.
    /// </summary>
    /// <param name="ReportId">The report object ID to run.</param>
    /// <param name="RecRef">The filtered RecordRef to pass to the report.</param>
    /// <returns>Base64 encoded PDF content.</returns>
    procedure RunReportAsPdfBase64(ReportId: Integer; var RecRef: RecordRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);

        TempBlob.CreateInStream(InStr);
        exit(Base64Convert.ToBase64(InStr));
    end;

    /// <summary>
    /// Runs a report with XML parameters and returns PDF as Base64.
    /// </summary>
    /// <param name="ReportId">The report object ID to run.</param>
    /// <param name="ParametersXml">XML string with report parameters.</param>
    /// <param name="RecRef">The filtered RecordRef to pass to the report.</param>
    /// <returns>Base64 encoded PDF content.</returns>
    procedure RunReportWithParametersAsPdfBase64(ReportId: Integer; ParametersXml: Text; var RecRef: RecordRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, ParametersXml, ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);

        TempBlob.CreateInStream(InStr);
        exit(Base64Convert.ToBase64(InStr));
    end;

    /// <summary>
    /// Runs a report and saves PDF to a TempBlob for further processing.
    /// </summary>
    procedure RunReportToTempBlob(ReportId: Integer; var RecRef: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        if not Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef) then
            Error(ReportGenerationFailedErr, ReportId);
    end;

    /// <summary>
    /// Validates that a report can be generated without errors.
    /// </summary>
    /// <param name="ReportId">The report object ID to validate.</param>
    /// <param name="RecRef">The filtered RecordRef to pass to the report.</param>
    /// <returns>True if report generated successfully, false otherwise.</returns>
    procedure TryRunReport(ReportId: Integer; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        exit(Report.SaveAs(ReportId, '', ReportFormat::Pdf, OutStr, RecRef));
    end;

    /// <summary>
    /// Gets the size of the generated PDF in bytes.
    /// </summary>
    procedure GetPdfSize(ReportId: Integer; var RecRef: RecordRef): Integer
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        RunReportToTempBlob(ReportId, RecRef, TempBlob);
        exit(TempBlob.Length());
    end;

    /// <summary>
    /// Validates PDF is not empty (has content beyond header).
    /// </summary>
    procedure ValidatePdfNotEmpty(Base64Pdf: Text): Boolean
    var
        MinimumPdfSize: Integer;
    begin
        MinimumPdfSize := 1000; // Minimum reasonable PDF size in bytes
        exit(StrLen(Base64Pdf) > MinimumPdfSize);
    end;

    var
        RecordNotFoundErr: Label 'Record not found. Table: %1, SystemId: %2', Comment = '%1 = Table No, %2 = SystemId';
        ReportGenerationFailedErr: Label 'Failed to generate report %1 as PDF.', Comment = '%1 = Report ID';
}
```

---

## PDF Generation Pattern

### Basic Pattern from example.dal

The core pattern for generating PDF output:

```al
procedure GeneratePdfFromReport(ReportID: Integer; var RecRef: RecordRef): Text
var
    TempBlob: Codeunit "Temp Blob";
    InStr: InStream;
    OutStr: OutStream;
    Base64Convert: Codeunit "Base64 Convert";
begin
    TempBlob.CreateOutStream(OutStr);
    Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStr, RecRef);

    TempBlob.CreateInStream(InStr);
    exit(Base64Convert.ToBase64(InStr));
end;
```

### Report.SaveAs Parameters

```al
Report.SaveAs(
    ReportId: Integer,          // Report object ID
    Parameters: Text,           // XML parameters string (empty for defaults)
    ReportFormat: ReportFormat, // Pdf, Excel, Word, Html, Xml
    OutStream: OutStream,       // Output stream for the file
    RecordRef: RecordRef        // Filtered record(s) to run report against
): Boolean                      // Returns true if successful
```

### Using RecordRef for Dynamic Reports

```al
procedure RunDynamicReport(ReportId: Integer; TableNo: Integer; FilterField: Integer; FilterValue: Text): Text
var
    RecRef: RecordRef;
    FieldRef: FieldRef;
begin
    RecRef.Open(TableNo);
    FieldRef := RecRef.Field(FilterField);
    FieldRef.SetRange(FilterValue);

    exit(GeneratePdfFromReport(ReportId, RecRef));
end;
```

### Running Report with Specific Record by SystemId

```al
procedure RunReportForRecord(ReportId: Integer; TableNo: Integer; RecordSystemId: Guid): Text
var
    RecRef: RecordRef;
begin
    RecRef.Open(TableNo);
    if not RecRef.GetBySystemId(RecordSystemId) then
        Error('Record not found');

    exit(GeneratePdfFromReport(ReportId, RecRef));
end;
```

---

## Test Codeunit Structure

### Basic Report Test Codeunit

```al
codeunit 90100 "VOL Customer List Report Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        IsInitialized: Boolean;

    [Test]
    procedure TestCustomerListReportGenerates()
    var
        Customer: Record Customer;
        RecRef: RecordRef;
        Base64Pdf: Text;
    begin
        // [SCENARIO] Customer List report generates PDF successfully
        Initialize();

        // [GIVEN] A customer exists
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] The report is run
        RecRef.GetTable(Customer);
        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Customer List",
            RecRef);

        // [THEN] A non-empty PDF is generated
        Assert.IsTrue(
            ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
            'Report should generate non-empty PDF');
    end;

    [Test]
    procedure TestCustomerListReportWithMultipleCustomers()
    var
        Customer: Record Customer;
        RecRef: RecordRef;
        Base64Pdf: Text;
        i: Integer;
    begin
        // [SCENARIO] Report handles multiple customers
        Initialize();

        // [GIVEN] Multiple customers exist
        for i := 1 to 5 do
            LibrarySales.CreateCustomer(Customer);

        // [WHEN] The report is run for all customers
        Customer.Reset();
        RecRef.GetTable(Customer);
        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Customer List",
            RecRef);

        // [THEN] PDF is generated successfully
        Assert.IsTrue(
            ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
            'Report should generate PDF for multiple customers');
    end;

    [Test]
    procedure TestCustomerListReportNoData()
    var
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportRan: Boolean;
    begin
        // [SCENARIO] Report handles no data gracefully
        Initialize();

        // [GIVEN] No customers match filter
        Customer.SetRange("No.", 'NONEXISTENT');
        RecRef.GetTable(Customer);

        // [WHEN] The report is run
        ReportRan := ReportTestHelper.TryRunReport(
            Report::"VOL Customer List",
            RecRef);

        // [THEN] Report runs without error (may produce empty PDF)
        Assert.IsTrue(ReportRan, 'Report should run without error even with no data');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        // Setup code here

        IsInitialized := true;
        Commit();
    end;
}
```

### Document Report Test Codeunit

```al
codeunit 90101 "VOL Sales Invoice Report Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        IsInitialized: Boolean;

    [Test]
    procedure TestSalesInvoiceReportGenerates()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
        Base64Pdf: Text;
    begin
        // [SCENARIO] Sales Invoice report generates PDF for posted invoice
        Initialize();

        // [GIVEN] A posted sales invoice exists
        CreatePostedSalesInvoice(SalesInvoiceHeader);

        // [WHEN] The report is run
        RecRef.GetTable(SalesInvoiceHeader);
        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Sales Invoice",
            RecRef);

        // [THEN] A valid PDF is generated
        Assert.IsTrue(
            ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
            'Sales Invoice report should generate valid PDF');
    end;

    [Test]
    procedure TestSalesInvoiceReportBySystemId()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Base64Pdf: Text;
    begin
        // [SCENARIO] Can run report using record SystemId
        Initialize();

        // [GIVEN] A posted sales invoice
        CreatePostedSalesInvoice(SalesInvoiceHeader);

        // [WHEN] Report is run by SystemId
        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Sales Invoice",
            Database::"Sales Invoice Header",
            SalesInvoiceHeader.SystemId);

        // [THEN] PDF is generated
        Assert.IsTrue(
            ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
            'Report should generate PDF when called by SystemId');
    end;

    [Test]
    procedure TestSalesInvoiceReportWithMultipleLines()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RecRef: RecordRef;
        Base64Pdf: Text;
        LineCount: Integer;
    begin
        // [SCENARIO] Report handles invoice with multiple lines
        Initialize();

        // [GIVEN] Posted invoice with 10 lines
        CreatePostedSalesInvoiceWithLines(SalesInvoiceHeader, 10);

        // Verify lines exist
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        LineCount := SalesInvoiceLine.Count;
        Assert.AreEqual(10, LineCount, 'Invoice should have 10 lines');

        // [WHEN] Report is run
        RecRef.GetTable(SalesInvoiceHeader);
        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Sales Invoice",
            RecRef);

        // [THEN] PDF is generated (larger than single line)
        Assert.IsTrue(
            ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
            'Report should generate PDF with multiple lines');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        // Setup code
        IsInitialized := true;
        Commit();
    end;

    local procedure CreatePostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        PostedDocNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, '');
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            SalesLine.Type::Item,
            Item."No.",
            LibraryRandom.RandInt(10));

        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocNo);
    end;

    local procedure CreatePostedSalesInvoiceWithLines(var SalesInvoiceHeader: Record "Sales Invoice Header"; LineCount: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        PostedDocNo: Code[20];
        i: Integer;
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, '');

        for i := 1 to LineCount do begin
            LibraryInventory.CreateItem(Item);
            LibrarySales.CreateSalesLine(
                SalesLine,
                SalesHeader,
                SalesLine.Type::Item,
                Item."No.",
                LibraryRandom.RandInt(10));
        end;

        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocNo);
    end;
}
```

---

## Test Data Setup

### Using Library Codeunits

Business Central provides standard library codeunits for creating test data:

| Codeunit | Purpose |
|----------|---------|
| `Library - Sales` | Create customers, sales documents |
| `Library - Purchase` | Create vendors, purchase documents |
| `Library - Inventory` | Create items, inventory |
| `Library - ERM` | General ledger, currencies |
| `Library - Random` | Random values |
| `Library - Utility` | General utilities |

### Example Test Data Creation

```al
local procedure CreateTestCustomerWithBalance(var Customer: Record Customer; Balance: Decimal)
var
    GenJournalLine: Record "Gen. Journal Line";
    LibrarySales: Codeunit "Library - Sales";
    LibraryERM: Codeunit "Library - ERM";
begin
    LibrarySales.CreateCustomer(Customer);

    // Create customer ledger entry for balance
    LibraryERM.CreateGeneralJnlLine(
        GenJournalLine,
        'GENERAL',
        'DEFAULT',
        GenJournalLine."Document Type"::Invoice,
        GenJournalLine."Account Type"::Customer,
        Customer."No.",
        Balance);

    LibraryERM.PostGeneralJnlLine(GenJournalLine);
end;
```

### Creating Complete Test Scenarios

```al
local procedure CreateSalesScenario(var Customer: Record Customer; var SalesInvoiceHeader: Record "Sales Invoice Header")
var
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    Item: Record Item;
    LibrarySales: Codeunit "Library - Sales";
    LibraryInventory: Codeunit "Library - Inventory";
begin
    // Create customer with address
    LibrarySales.CreateCustomerWithAddress(Customer);

    // Create item with price
    LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
        Item,
        LibraryRandom.RandDec(100, 2),
        LibraryRandom.RandDec(50, 2));

    // Create and post sales invoice
    LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
    LibrarySales.CreateSalesLine(
        SalesLine,
        SalesHeader,
        SalesLine.Type::Item,
        Item."No.",
        LibraryRandom.RandInt(5));

    SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
end;
```

---

## Validation Strategies

### PDF Size Validation

```al
procedure ValidatePdfHasContent(Base64Pdf: Text; MinExpectedSizeKB: Integer)
var
    Assert: Codeunit Assert;
    ActualSizeBytes: Integer;
begin
    // Base64 is ~1.33x larger than binary
    ActualSizeBytes := Round(StrLen(Base64Pdf) / 1.33, 1);

    Assert.IsTrue(
        ActualSizeBytes >= MinExpectedSizeKB * 1024,
        StrSubstNo('PDF size %1 bytes is less than expected %2 KB',
            ActualSizeBytes, MinExpectedSizeKB));
end;
```

### Report Execution Validation

```al
[Test]
procedure TestReportExecutesWithoutError()
var
    Customer: Record Customer;
    RecRef: RecordRef;
begin
    // [SCENARIO] Report runs without throwing errors
    Initialize();

    // [GIVEN] Valid test data
    LibrarySales.CreateCustomer(Customer);
    RecRef.GetTable(Customer);

    // [WHEN/THEN] Report runs without error
    asserterror ReportTestHelper.RunReportAsPdfBase64(Report::"VOL Customer List", RecRef);
    Assert.AreEqual('', GetLastErrorText, 'Report should not produce errors');
end;
```

### Multiple Record Validation

```al
[Test]
procedure TestReportHandlesAllRecordTypes()
var
    Customer: array[3] of Record Customer;
    RecRef: RecordRef;
    Base64Pdf: Text;
    PdfSizes: array[3] of Integer;
    i: Integer;
begin
    // [SCENARIO] Report handles different customer configurations
    Initialize();

    // [GIVEN] Customers with different configurations
    CreateRegularCustomer(Customer[1]);
    CreateBlockedCustomer(Customer[2]);
    CreateCustomerWithBalance(Customer[3], 1000);

    // [WHEN/THEN] Report runs for each
    for i := 1 to 3 do begin
        RecRef.GetTable(Customer[i]);
        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Customer List", RecRef);

        Assert.IsTrue(
            ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
            StrSubstNo('PDF should be generated for customer type %1', i));
    end;
end;
```

---

## Common Test Patterns

### Test Report with Date Filters

```al
[Test]
procedure TestReportWithDateFilter()
var
    Customer: Record Customer;
    RecRef: RecordRef;
    Base64Pdf: Text;
    ParametersXml: Text;
begin
    Initialize();

    // [GIVEN] Customer and date range
    LibrarySales.CreateCustomer(Customer);

    // Build XML parameters for date filter
    ParametersXml := BuildDateFilterParameters(WorkDate() - 30, WorkDate());

    // [WHEN] Report runs with parameters
    RecRef.GetTable(Customer);
    Base64Pdf := ReportTestHelper.RunReportWithParametersAsPdfBase64(
        Report::"VOL Customer List",
        ParametersXml,
        RecRef);

    // [THEN] PDF generated
    Assert.IsTrue(ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf), 'PDF should be generated');
end;

local procedure BuildDateFilterParameters(StartDate: Date; EndDate: Date): Text
var
    ReportParams: Text;
begin
    // Build XML parameters string
    // Format depends on the specific report's request page
    ReportParams := StrSubstNo(
        '<?xml version="1.0" encoding="utf-8"?>' +
        '<ReportParameters>' +
        '<DataItems>' +
        '<DataItem name="Customer">' +
        '<Filter>%1..%2</Filter>' +
        '</DataItem>' +
        '</DataItems>' +
        '</ReportParameters>',
        Format(StartDate, 0, 9),
        Format(EndDate, 0, 9));

    exit(ReportParams);
end;
```

### Test Report Edge Cases

```al
[Test]
procedure TestReportWithSpecialCharacters()
var
    Customer: Record Customer;
    RecRef: RecordRef;
    Base64Pdf: Text;
begin
    // [SCENARIO] Report handles special characters in data
    Initialize();

    // [GIVEN] Customer with special characters in name
    LibrarySales.CreateCustomer(Customer);
    Customer.Name := 'Test & Co. <Special> "Chars"';
    Customer.Modify();

    // [WHEN] Report is run
    RecRef.GetTable(Customer);
    Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
        Report::"VOL Customer List", RecRef);

    // [THEN] Report generates without XML errors
    Assert.IsTrue(
        ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
        'Report should handle special characters');
end;

[Test]
procedure TestReportWithLongText()
var
    Customer: Record Customer;
    RecRef: RecordRef;
    Base64Pdf: Text;
begin
    // [SCENARIO] Report handles maximum length text
    Initialize();

    // [GIVEN] Customer with max length fields
    LibrarySales.CreateCustomer(Customer);
    Customer.Name := PadStr('', MaxStrLen(Customer.Name), 'A');
    Customer.Address := PadStr('', MaxStrLen(Customer.Address), 'B');
    Customer.Modify();

    // [WHEN] Report is run
    RecRef.GetTable(Customer);
    Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(
        Report::"VOL Customer List", RecRef);

    // [THEN] Report generates with wrapped text
    Assert.IsTrue(
        ReportTestHelper.ValidatePdfNotEmpty(Base64Pdf),
        'Report should handle max length text');
end;
```

---

## Web Service Integration

### Exposing Test Helper as Web Service

The test helper can be exposed for external testing:

```al
codeunit 90201 "VOL Report Test WS"
{
    /// <summary>
    /// Web service endpoint for running report tests.
    /// </summary>
    /// <param name="ReportId">Report ID to run.</param>
    /// <param name="TableNo">Table number for record filter.</param>
    /// <param name="SystemId">SystemId of record.</param>
    /// <returns>JSON with Base64 PDF and metadata.</returns>
    procedure RunReportTest(ReportId: Integer; TableNo: Integer; SystemId: Text): Text
    var
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        JsonResult: JsonObject;
        Base64Pdf: Text;
        GuidValue: Guid;
        ResultText: Text;
    begin
        Evaluate(GuidValue, SystemId);

        Base64Pdf := ReportTestHelper.RunReportAsPdfBase64(ReportId, TableNo, GuidValue);

        JsonResult.Add('success', true);
        JsonResult.Add('reportId', ReportId);
        JsonResult.Add('pdfBase64', Base64Pdf);
        JsonResult.Add('pdfSizeBytes', Round(StrLen(Base64Pdf) / 1.33, 1));
        JsonResult.Add('timestamp', Format(CurrentDateTime, 0, 9));

        JsonResult.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Validates report can be generated.
    /// </summary>
    procedure ValidateReport(ReportId: Integer; TableNo: Integer; SystemId: Text): Text
    var
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        RecRef: RecordRef;
        JsonResult: JsonObject;
        GuidValue: Guid;
        Success: Boolean;
        ResultText: Text;
    begin
        Evaluate(GuidValue, SystemId);

        RecRef.Open(TableNo);
        if not RecRef.GetBySystemId(GuidValue) then begin
            JsonResult.Add('success', false);
            JsonResult.Add('error', 'Record not found');
            JsonResult.WriteTo(ResultText);
            exit(ResultText);
        end;

        Success := ReportTestHelper.TryRunReport(ReportId, RecRef);

        JsonResult.Add('success', Success);
        JsonResult.Add('reportId', ReportId);
        if not Success then
            JsonResult.Add('error', GetLastErrorText);

        JsonResult.WriteTo(ResultText);
        exit(ResultText);
    end;
}
```

---

## Error Handling in Tests

### Testing Error Scenarios

```al
[Test]
procedure TestReportWithInvalidRecord()
var
    InvalidGuid: Guid;
    ErrorOccurred: Boolean;
begin
    // [SCENARIO] Report handles invalid record gracefully
    Initialize();

    // [GIVEN] An invalid SystemId
    InvalidGuid := CreateGuid();

    // [WHEN] Report is run with invalid record
    asserterror ReportTestHelper.RunReportAsPdfBase64(
        Report::"VOL Customer List",
        Database::Customer,
        InvalidGuid);

    // [THEN] Appropriate error is raised
    ErrorOccurred := GetLastErrorText <> '';
    Assert.IsTrue(ErrorOccurred, 'Should raise error for invalid record');
end;

[Test]
procedure TestReportWithInvalidReportId()
var
    Customer: Record Customer;
    RecRef: RecordRef;
    InvalidReportId: Integer;
begin
    // [SCENARIO] Invalid report ID is handled
    Initialize();

    // [GIVEN] Valid customer and invalid report ID
    LibrarySales.CreateCustomer(Customer);
    RecRef.GetTable(Customer);
    InvalidReportId := 999999;

    // [WHEN/THEN] Error is raised
    asserterror ReportTestHelper.RunReportAsPdfBase64(InvalidReportId, RecRef);
    Assert.ExpectedError(''); // System error for invalid report
end;
```

---

## Best Practices

### Test Naming Convention

```
Test[ReportName][Scenario]
```

Examples:
- `TestCustomerListReportGenerates`
- `TestSalesInvoiceReportWithMultipleLines`
- `TestCustomerListReportNoData`

### Test Organization

1. **One test codeunit per report** - Keep tests focused
2. **Use Given/When/Then comments** - Document test structure
3. **Initialize method** - Reset state before each test
4. **Library codeunits** - Use standard libraries for test data

### Test Coverage Checklist

For each report, test:

- [ ] Report generates with single record
- [ ] Report generates with multiple records
- [ ] Report handles no data (empty filter)
- [ ] Report handles special characters
- [ ] Report handles maximum length fields
- [ ] Report handles null/empty values
- [ ] Report generates correct PDF size
- [ ] Report runs without runtime errors

### Performance Considerations

```al
[Test]
procedure TestReportPerformanceWithLargeDataset()
var
    Customer: Record Customer;
    RecRef: RecordRef;
    StartTime: DateTime;
    EndTime: DateTime;
    DurationMs: Integer;
    MaxAcceptableMs: Integer;
begin
    // [SCENARIO] Report completes within acceptable time
    Initialize();

    // [GIVEN] Large dataset
    CreateManyCustomers(1000);

    // [WHEN] Report is timed
    StartTime := CurrentDateTime;
    Customer.Reset();
    RecRef.GetTable(Customer);
    ReportTestHelper.RunReportAsPdfBase64(Report::"VOL Customer List", RecRef);
    EndTime := CurrentDateTime;

    // [THEN] Duration is acceptable
    DurationMs := EndTime - StartTime;
    MaxAcceptableMs := 30000; // 30 seconds
    Assert.IsTrue(
        DurationMs < MaxAcceptableMs,
        StrSubstNo('Report took %1ms, max is %2ms', DurationMs, MaxAcceptableMs));
end;
```

---

## Object ID Summary

| Object | ID | Name |
|--------|----| -----|
| Test Helper | 90200 | VOL Report Test Helper |
| Test WS | 90201 | VOL Report Test WS |
| Customer List Tests | 90100 | VOL Customer List Report Test |
| Sales Invoice Tests | 90101 | VOL Sales Invoice Report Test |

---

## Saving Test PDFs for Human Verification

### Overview

After running report tests, save the generated PDFs to the repository for human review. This allows visual verification that the report layout matches expectations.

### Output Folder Structure

```
test-outputs/
└── reports/
    ├── CustomerList_50100_2024-12-15_143022.pdf
    ├── SalesInvoice_50101_2024-12-15_143045.pdf
    └── .gitkeep
```

### PowerShell Script for Saving PDFs

Use the provided script to save Base64 PDFs:

```powershell
# Save a single PDF
.\.claude\scripts\save-report-pdf.ps1 `
    -Base64Pdf $pdfContent `
    -ReportName "CustomerList" `
    -ReportId 50100

# Save with custom timestamp control
.\.claude\scripts\save-report-pdf.ps1 `
    -Base64Pdf $pdfContent `
    -ReportName "CustomerList" `
    -ReportId 50100 `
    -Timestamp $false
```

### Complete Test and Save Workflow

```powershell
# Run report test and save PDF in one step
.\.claude\scripts\test-report-and-save.ps1 `
    -ReportId 50100 `
    -TableNo 18 `
    -RecordSystemId "abc-123-def-456" `
    -ReportName "CustomerList" `
    -BCBaseUrl "http://localhost:7048/BC" `
    -CompanyName "CRONUS USA, Inc."
```

### Agent Workflow for PDF Saving

When testing reports, the agent should:

1. **Run the report test** using VOL Report Test Helper
2. **Capture the Base64 PDF** from the response
3. **Save to repo** using the PowerShell script
4. **Report the saved path** to the user for review

Example agent workflow:
```
1. Call BC web service: RunReportAsJson(ReportId, TableNo, RecordSystemId)
2. Extract pdfBase64 from JSON response
3. Run: save-report-pdf.ps1 -Base64Pdf $pdf -ReportName "ReportName"
4. Report: "PDF saved to: test-outputs/reports/ReportName_50100_2024-12-15_143022.pdf"
```

### Naming Convention for Saved PDFs

```
{ReportName}_{ReportId}_{Timestamp}.pdf
```

Where:
- **ReportName**: Sanitized name (special chars replaced with underscores)
- **ReportId**: The report object ID
- **Timestamp**: Format `yyyy-MM-dd_HHmmss`

### Git Handling

By default, PDFs are committed to the repo for review. If repo size becomes a concern:

1. Edit `test-outputs/.gitignore`
2. Uncomment `*.pdf` line
3. PDFs will remain local only

### Viewing Test PDFs

After tests complete, users can:
1. Navigate to `test-outputs/reports/` folder
2. Open PDF files with any PDF viewer
3. Compare visually with expected layout
4. Provide feedback if layout needs adjustment

---

## Critical Rules Summary

1. **Always use Report.SaveAs** - Not Report.Run for testing
2. **Use TempBlob for streams** - Proper stream handling
3. **Base64 for transport** - Encode PDF for JSON/HTTP
4. **RecordRef for flexibility** - Dynamic table/record handling
5. **Validate PDF not empty** - Basic sanity check
6. **Test edge cases** - Special chars, max length, null values
7. **Use Library codeunits** - Standard test data creation
8. **One test codeunit per report** - Organized test structure
9. **Document with Given/When/Then** - Clear test structure
10. **Handle errors gracefully** - Test error scenarios too
11. **Save PDFs for review** - Store in test-outputs/reports/ for human verification
