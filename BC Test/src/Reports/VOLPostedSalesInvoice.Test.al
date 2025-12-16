/// <summary>
/// Test Codeunit VOL Posted Sales Invoice Test (ID 90100).
/// Tests Report 50000 "VOL Posted Sales Invoice" to ensure it generates valid PDF output.
/// Uses existing posted invoices from the system - no Microsoft Test Libraries required.
/// </summary>
codeunit 90100 "VOL Posted Sales Invoice Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        EmptyPdfErr: Label 'Report generated an empty PDF';
        ExpectedValueErr: Label 'Expected %1 but got %2', Comment = '%1 = Expected value, %2 = Actual value';
        ExpectedTrueErr: Label 'Expected condition to be true: %1', Comment = '%1 = Condition description';
        ExpectedFalseErr: Label 'Expected condition to be false: %1', Comment = '%1 = Condition description';

    [Test]
    procedure TestPostedInvoiceReportGeneratesFromExistingInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PdfBase64: Text;
        PdfSize: Integer;
    begin
        // [SCENARIO] Report generates valid PDF for an existing posted sales invoice

        // [GIVEN] An existing posted sales invoice in the system
        if not SalesInvoiceHeader.FindFirst() then
            exit;

        // [WHEN] The report is run for this invoice
        PdfBase64 := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Posted Sales Invoice",
            Database::"Sales Invoice Header",
            SalesInvoiceHeader.SystemId);

        // [THEN] A non-empty PDF is generated
        AssertNotEqual('', PdfBase64, EmptyPdfErr);
        PdfSize := ReportTestHelper.GetPdfSizeFromBase64(PdfBase64);
        AssertTrue(PdfSize > 0, 'PDF size should be greater than zero');
    end;

    [Test]
    procedure TestPostedInvoiceReportWithMultipleLines()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PdfBase64: Text;
        PdfSize: Integer;
    begin
        // [SCENARIO] Report handles invoices with multiple lines

        // [GIVEN] Find a posted invoice that has multiple lines
        SalesInvoiceHeader.Reset();
        if SalesInvoiceHeader.FindSet() then
            repeat
                SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                if SalesInvoiceLine.Count() > 1 then
                    break;
            until SalesInvoiceHeader.Next() = 0;

        if SalesInvoiceLine.Count() <= 1 then
            exit;

        // [WHEN] The report is run for this invoice
        PdfBase64 := ReportTestHelper.RunReportAsPdfBase64(
            Report::"VOL Posted Sales Invoice",
            Database::"Sales Invoice Header",
            SalesInvoiceHeader.SystemId);

        // [THEN] A non-empty PDF is generated
        AssertNotEqual('', PdfBase64, EmptyPdfErr);
        PdfSize := ReportTestHelper.GetPdfSizeFromBase64(PdfBase64);
        AssertTrue(PdfSize > 0, 'PDF with multiple lines should not be empty');
    end;

    [Test]
    procedure TestPostedInvoiceReportNoData()
    var
        PdfBase64: Text;
        Success: Boolean;
    begin
        // [SCENARIO] Report handles scenario with no matching data gracefully

        // [GIVEN] A non-existent record SystemId
        // [WHEN] The report is run with invalid SystemId
        Success := ReportTestHelper.TryRunReportAsPdfBase64(
            Report::"VOL Posted Sales Invoice",
            Database::"Sales Invoice Header",
            CreateGuid(),
            PdfBase64);

        // [THEN] Report should fail for non-existent record
        AssertFalse(Success, 'Report should fail for non-existent record');
    end;

    [Test]
    procedure TestPostedInvoiceReportMultipleInvoices()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PdfBase64: Text;
        PdfSize: Integer;
        InvoiceCount: Integer;
    begin
        // [SCENARIO] Report generates correctly for multiple different invoices

        // [GIVEN] Multiple posted sales invoices exist
        SalesInvoiceHeader.Reset();
        if not SalesInvoiceHeader.FindSet() then
            exit;

        // [WHEN/THEN] Run report for up to 3 invoices and verify each generates PDF
        repeat
            PdfBase64 := ReportTestHelper.RunReportAsPdfBase64(
                Report::"VOL Posted Sales Invoice",
                Database::"Sales Invoice Header",
                SalesInvoiceHeader.SystemId);

            PdfSize := ReportTestHelper.GetPdfSizeFromBase64(PdfBase64);
            AssertTrue(PdfSize > 0, 'Invoice ' + SalesInvoiceHeader."No." + ' should generate valid PDF');

            InvoiceCount += 1;
        until (SalesInvoiceHeader.Next() = 0) or (InvoiceCount >= 3);

        AssertTrue(InvoiceCount > 0, 'At least one invoice should be tested');
    end;

    [Test]
    procedure TestPostedInvoiceReportJsonOutput()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        JsonResult: Text;
    begin
        // [SCENARIO] Report can generate JSON output with metadata

        // [GIVEN] An existing posted sales invoice
        if not SalesInvoiceHeader.FindFirst() then
            exit;

        // [WHEN] The report is run with JSON output
        JsonResult := ReportTestHelper.RunReportAsJson(
            Report::"VOL Posted Sales Invoice",
            Database::"Sales Invoice Header",
            SalesInvoiceHeader.SystemId);

        // [THEN] JSON result is returned with content
        AssertNotEqual('', JsonResult, 'JSON result should not be empty');
        AssertTrue(StrPos(JsonResult, 'success') > 0, 'JSON should contain success field');
        AssertTrue(StrPos(JsonResult, 'reportId') > 0, 'JSON should contain reportId field');
    end;

    local procedure AssertTrue(Condition: Boolean; Description: Text)
    begin
        if not Condition then
            Error(ExpectedTrueErr, Description);
    end;

    local procedure AssertFalse(Condition: Boolean; Description: Text)
    begin
        if Condition then
            Error(ExpectedFalseErr, Description);
    end;

    local procedure AssertNotEqual(Expected: Text; Actual: Text; Description: Text)
    begin
        if Expected = Actual then
            Error(ExpectedValueErr, 'not ' + Expected, Actual);
    end;

    local procedure AssertAreEqual(Expected: Integer; Actual: Integer; Description: Text)
    begin
        if Expected <> Actual then
            Error(ExpectedValueErr, Format(Expected), Format(Actual));
    end;
}
