/// <summary>
/// Codeunit VOL Test Runner WS (ID 90000).
/// Web service codeunit for running automated tests via API calls.
/// Exposes procedures for bc-tester agent to execute tests and retrieve results.
/// </summary>
codeunit 90000 "VOL Test Runner WS"
{
    Permissions = tabledata "AL Test Suite" = RIMD,
                  tabledata "Test Method Line" = RIMD;

    /// <summary>
    /// Runs all tests for a specific extension and returns results as JSON.
    /// This is the main entry point for the bc-tester agent.
    /// </summary>
    /// <param name="ExtensionId">The App ID (GUID) of the extension to test. Leave empty to run all tests.</param>
    /// <returns>JSON string with test results including pass/fail counts and detailed results per test.</returns>
    procedure RunTestsByExtension(ExtensionId: Text): Text
    var
        ALTestSuite: Record "AL Test Suite";
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        SuiteName: Code[10];
        ResultJson: Text;
    begin
        SuiteName := 'AGENT';

        // Create or clear the test suite
        if ALTestSuite.Get(SuiteName) then begin
            TestMethodLine.SetRange("Test Suite", SuiteName);
            TestMethodLine.DeleteAll(true);
        end else begin
            TestSuiteMgt.CreateTestSuite(SuiteName);
            ALTestSuite.Get(SuiteName);
        end;

        // Add test codeunits from extension
        if ExtensionId <> '' then
            TestSuiteMgt.SelectTestMethodsByExtension(ALTestSuite, ExtensionId)
        else
            TestSuiteMgt.SelectTestMethodsByRange(ALTestSuite, '1..999999999');

        // Run all tests
        TestMethodLine.SetRange("Test Suite", SuiteName);
        if TestMethodLine.FindFirst() then
            TestSuiteMgt.RunAllTests(TestMethodLine);

        // Build results JSON
        ResultJson := BuildTestResultsJson(SuiteName);

        exit(ResultJson);
    end;

    /// <summary>
    /// Runs all tests in a specific test suite by name.
    /// </summary>
    /// <param name="SuiteName">The name of the test suite to run.</param>
    /// <returns>JSON string with test results.</returns>
    procedure RunTestSuite(SuiteName: Code[10]): Text
    var
        ALTestSuite: Record "AL Test Suite";
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        ResultJson: Text;
    begin
        if not ALTestSuite.Get(SuiteName) then
            exit('{"error": "Test suite not found: ' + SuiteName + '"}');

        TestMethodLine.SetRange("Test Suite", SuiteName);
        if TestMethodLine.FindFirst() then
            TestSuiteMgt.RunAllTests(TestMethodLine);

        ResultJson := BuildTestResultsJson(SuiteName);
        exit(ResultJson);
    end;

    /// <summary>
    /// Runs a single test codeunit by ID on the isolating runner: everything the
    /// tests write is rolled back. This is the standard door.
    /// </summary>
    /// <param name="CodeunitId">The ID of the test codeunit to run.</param>
    procedure RunTestCodeunit(CodeunitId: Integer): Text
    begin
        exit(RunCodeunitInSuite('SINGLE', CodeunitId, '', Codeunit::"Test Runner - Isol. Codeunit"));
    end;

    /// <summary>
    /// Runs a test codeunit and KEEPS the data it writes: the suite runs on
    /// "Test Runner - Isol. Disabled", so every record the tests create is
    /// committed and can be opened in BC afterwards. Used by Cortex "Keep in
    /// sandbox" scenario runs and by `volt-bc dev test --non-isolated`.
    /// Sandbox only: Cortex refuses a keep-data run against Production before
    /// calling. Standard runs should keep using RunTestCodeunit.
    /// </summary>
    /// <param name="CodeunitId">The ID of the test codeunit to run.</param>
    procedure RunTestCodeunitNonIsolated(CodeunitId: Integer): Text
    begin
        exit(RunCodeunitInSuite('KEEPDATA', CodeunitId, '', Codeunit::"Test Runner - Isol. Disabled"));
    end;

    /// <summary>
    /// Runs a single named [Test] method of a codeunit and keeps the data it
    /// writes. Use it when sibling methods in the same codeunit would clean up
    /// the data you want to look at.
    /// </summary>
    /// <param name="CodeunitId">The ID of the test codeunit.</param>
    /// <param name="MethodName">The exact [Test] procedure name to run.</param>
    procedure RunTestMethodNonIsolated(CodeunitId: Integer; MethodName: Text): Text
    begin
        exit(RunCodeunitInSuite('KEEPDATA', CodeunitId, MethodName, Codeunit::"Test Runner - Isol. Disabled"));
    end;

    /// <summary>
    /// One implementation behind the three run doors: (re)create the suite,
    /// switch its test runner, load the codeunit's methods, optionally keep a
    /// single method, run, and report. A suite created by CreateTestSuite sits
    /// on the default runner, which rolls every test back, so the runner switch
    /// is what makes a keep-data run actually keep its data.
    /// </summary>
    local procedure RunCodeunitInSuite(SuiteName: Code[10]; CodeunitId: Integer; MethodFilter: Text; TestRunnerId: Integer): Text
    var
        ALTestSuite: Record "AL Test Suite";
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        CodeunitMetadata: Record "CodeUnit Metadata";
    begin
        if not CodeunitMetadata.Get(CodeunitId) then
            exit(StrSubstNo('{"error": "Codeunit not found: %1"}', Format(CodeunitId)));

        if CodeunitMetadata.SubType <> CodeunitMetadata.SubType::Test then
            exit(StrSubstNo('{"error": "Codeunit is not a test codeunit: %1"}', Format(CodeunitId)));

        if ALTestSuite.Get(SuiteName) then begin
            TestMethodLine.SetRange("Test Suite", SuiteName);
            TestMethodLine.DeleteAll(true);
        end else begin
            TestSuiteMgt.CreateTestSuite(SuiteName);
            ALTestSuite.Get(SuiteName);
        end;

        if ALTestSuite."Test Runner Id" <> TestRunnerId then
            TestSuiteMgt.ChangeTestRunner(ALTestSuite, TestRunnerId);

        CodeunitMetadata.SetRange(ID, CodeunitId);
        TestSuiteMgt.GetTestMethods(ALTestSuite, CodeunitMetadata);

        if MethodFilter <> '' then begin
            TestMethodLine.Reset();
            TestMethodLine.SetRange("Test Suite", SuiteName);
            TestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::"Function");
            TestMethodLine.SetFilter("Function", '<>%1', MethodFilter);
            TestMethodLine.ModifyAll(Run, false);
        end;

        TestMethodLine.Reset();
        TestMethodLine.SetRange("Test Suite", SuiteName);
        if TestMethodLine.FindFirst() then
            TestSuiteMgt.RunAllTests(TestMethodLine);

        exit(BuildTestResultsJson(SuiteName));
    end;

    /// <summary>
    /// Gets the test results for a suite without running tests.
    /// </summary>
    /// <param name="SuiteName">The name of the test suite.</param>
    /// <returns>JSON string with the current test results.</returns>
    procedure GetTestResults(SuiteName: Code[10]): Text
    begin
        exit(BuildTestResultsJson(SuiteName));
    end;

    /// <summary>
    /// Lists all available test suites.
    /// </summary>
    /// <returns>JSON array of test suite names.</returns>
    procedure ListTestSuites(): Text
    var
        ALTestSuite: Record "AL Test Suite";
        JsonArray: JsonArray;
        JsonObj: JsonObject;
        ResultText: Text;
    begin
        if ALTestSuite.FindSet() then
            repeat
                Clear(JsonObj);
                JsonObj.Add('name', ALTestSuite.Name);
                JsonObj.Add('description', ALTestSuite.Description);
                JsonObj.Add('testRunnerId', ALTestSuite."Test Runner Id");
                JsonArray.Add(JsonObj);
            until ALTestSuite.Next() = 0;

        JsonArray.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Lists all test codeunits available in the system.
    /// </summary>
    /// <returns>JSON array of test codeunit information.</returns>
    procedure ListTestCodeunits(): Text
    var
        CodeunitMetadata: Record "CodeUnit Metadata";
        JsonArray: JsonArray;
        JsonObj: JsonObject;
        ResultText: Text;
    begin
        CodeunitMetadata.SetRange(SubType, CodeunitMetadata.SubType::Test);
        if CodeunitMetadata.FindSet() then
            repeat
                Clear(JsonObj);
                JsonObj.Add('id', CodeunitMetadata.ID);
                JsonObj.Add('name', CodeunitMetadata.Name);
                JsonObj.Add('appId', Format(CodeunitMetadata."App ID"));
                JsonArray.Add(JsonObj);
            until CodeunitMetadata.Next() = 0;

        JsonArray.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Lists the [Test] methods of every test codeunit this environment publishes,
    /// grouped by codeunit, WITHOUT running anything. Cortex reads this to fill the
    /// scenario binding pickers with what the environment can actually execute
    /// (decided 2026-09-21: discovery asks BC, not the repo). AppIdFilter narrows
    /// the answer to one app, normally the project's BC Test app id; empty lists
    /// every test codeunit installed.
    /// The methods are found the way a run finds them: GetTestMethods loads the
    /// codeunits' [Test] procedures into a suite as Test Method Lines. The
    /// DISCOVER suite is emptied before and after, so nothing runs and nothing is
    /// left behind.
    /// </summary>
    /// <param name="AppIdFilter">An app id (GUID, braces optional) or empty for all.</param>
    /// <returns>JSON { appId, codeunits: [ { id, name, appId, methods: [ ... ] } ] }.</returns>
    procedure ListTestMethods(AppIdFilter: Text): Text
    var
        ALTestSuite: Record "AL Test Suite";
        TestMethodLine: Record "Test Method Line";
        CodeunitMetadata: Record "CodeUnit Metadata";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        Result: JsonObject;
        Codeunits: JsonArray;
        CodeunitJson: JsonObject;
        Methods: JsonArray;
        ResultText: Text;
        AppId: Guid;
        SuiteName: Code[10];
    begin
        SuiteName := 'DISCOVER';
        if AppIdFilter <> '' then
            if not Evaluate(AppId, AppIdFilter) then
                exit(StrSubstNo('{"error": "Invalid app id: %1"}', AppIdFilter));

        CodeunitMetadata.SetRange(SubType, CodeunitMetadata.SubType::Test);
        if AppIdFilter <> '' then
            CodeunitMetadata.SetRange("App ID", AppId);

        if not CodeunitMetadata.IsEmpty() then begin
            if ALTestSuite.Get(SuiteName) then begin
                TestMethodLine.SetRange("Test Suite", SuiteName);
                TestMethodLine.DeleteAll(true);
            end else begin
                TestSuiteMgt.CreateTestSuite(SuiteName);
                ALTestSuite.Get(SuiteName);
            end;

            // Loads one Codeunit line plus one Function line per [Test] procedure
            // for every codeunit in the filter. Discovery only: RunAllTests is
            // never called here.
            TestSuiteMgt.GetTestMethods(ALTestSuite, CodeunitMetadata);

            if CodeunitMetadata.FindSet() then
                repeat
                    Clear(CodeunitJson);
                    Clear(Methods);
                    CodeunitJson.Add('id', CodeunitMetadata.ID);
                    CodeunitJson.Add('name', CodeunitMetadata.Name);
                    CodeunitJson.Add('appId', Format(CodeunitMetadata."App ID"));

                    TestMethodLine.Reset();
                    TestMethodLine.SetRange("Test Suite", SuiteName);
                    TestMethodLine.SetRange("Test Codeunit", CodeunitMetadata.ID);
                    TestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::"Function");
                    TestMethodLine.SetFilter("Function", '<>%1', 'OnRun');
                    if TestMethodLine.FindSet() then
                        repeat
                            Methods.Add(TestMethodLine."Function");
                        until TestMethodLine.Next() = 0;

                    CodeunitJson.Add('methods', Methods);
                    Codeunits.Add(CodeunitJson);
                until CodeunitMetadata.Next() = 0;

            TestMethodLine.Reset();
            TestMethodLine.SetRange("Test Suite", SuiteName);
            TestMethodLine.DeleteAll(true);
        end;

        Result.Add('appId', AppIdFilter);
        Result.Add('codeunits', Codeunits);
        Result.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Simple health check procedure to verify the web service is working.
    /// </summary>
    /// <returns>JSON with status and timestamp.</returns>
    procedure Ping(): Text
    var
        JsonObj: JsonObject;
        ResultText: Text;
    begin
        JsonObj.Add('status', 'ok');
        JsonObj.Add('service', 'VOL Test Runner WS');
        JsonObj.Add('timestamp', Format(CurrentDateTime, 0, 9));
        JsonObj.Add('version', '1.0.0');
        JsonObj.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Runs a report and returns the PDF as Base64 encoded string.
    /// This function is exposed as a web service for direct report testing.
    /// </summary>
    /// <param name="ReportId">The ID of the report to run (e.g., 50000).</param>
    /// <param name="TableNo">The table number of the record (e.g., 112 for Sales Invoice Header).</param>
    /// <param name="RecordSystemId">The SystemId (GUID) of the record to use as data source.</param>
    /// <returns>JSON string with success status, PDF Base64 content, and metadata.</returns>
    procedure RunReportAsPdf(ReportId: Integer; TableNo: Integer; RecordSystemId: Text): Text
    var
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        JsonObj: JsonObject;
        PdfBase64: Text;
        Success: Boolean;
        ErrorText: Text;
        StartTime: DateTime;
        EndTime: DateTime;
        ResultText: Text;
        RecordGuid: Guid;
    begin
        StartTime := CurrentDateTime;

        // Convert string to GUID
        if not Evaluate(RecordGuid, RecordSystemId) then begin
            JsonObj.Add('success', false);
            JsonObj.Add('error', 'Invalid SystemId format: ' + RecordSystemId);
            JsonObj.WriteTo(ResultText);
            exit(ResultText);
        end;

        // Try to generate PDF
        Success := ReportTestHelper.TryRunReportAsPdfBase64(ReportId, TableNo, RecordGuid, PdfBase64);

        if not Success then
            ErrorText := GetLastErrorText();

        EndTime := CurrentDateTime;

        // Build JSON response
        JsonObj.Add('reportId', ReportId);
        JsonObj.Add('tableNo', TableNo);
        JsonObj.Add('recordSystemId', RecordSystemId);
        JsonObj.Add('success', Success);
        JsonObj.Add('startTime', Format(StartTime, 0, 9));
        JsonObj.Add('endTime', Format(EndTime, 0, 9));
        JsonObj.Add('durationMs', EndTime - StartTime);

        if Success then begin
            JsonObj.Add('pdfSizeBytes', ReportTestHelper.GetPdfSizeFromBase64(PdfBase64));
            JsonObj.Add('pdfBase64', PdfBase64);
            JsonObj.Add('hasPdfContent', PdfBase64 <> '');
        end else
            JsonObj.Add('error', ErrorText);

        JsonObj.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Lists all available reports in the system.
    /// </summary>
    /// <returns>JSON array of report information (ID, name, caption).</returns>
    procedure ListAvailableReports(): Text
    var
        AllObjWithCaption: Record "AllObjWithCaption";
        JsonArray: JsonArray;
        JsonObj: JsonObject;
        ResultText: Text;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        if AllObjWithCaption.FindSet() then
            repeat
                Clear(JsonObj);
                JsonObj.Add('id', AllObjWithCaption."Object ID");
                JsonObj.Add('name', AllObjWithCaption."Object Name");
                JsonObj.Add('caption', AllObjWithCaption."Object Caption");
                JsonArray.Add(JsonObj);
            until AllObjWithCaption.Next() = 0;

        JsonArray.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Tests a report by finding the first available record and generating PDF.
    /// Useful for quick report validation without specifying a specific record.
    /// </summary>
    /// <param name="ReportId">The ID of the report to test.</param>
    /// <param name="TableNo">The table number to find a record from.</param>
    /// <returns>JSON string with test results and PDF Base64 content.</returns>
    procedure TestReportWithFirstRecord(ReportId: Integer; TableNo: Integer): Text
    var
        RecRef: RecordRef;
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        JsonObj: JsonObject;
        PdfBase64: Text;
        Success: Boolean;
        ErrorText: Text;
        ResultText: Text;
        SystemId: Guid;
    begin
        // Open table and find first record
        RecRef.Open(TableNo);
        if not RecRef.FindFirst() then begin
            JsonObj.Add('success', false);
            JsonObj.Add('error', 'No records found in table ' + Format(TableNo));
            JsonObj.WriteTo(ResultText);
            exit(ResultText);
        end;

        // Get SystemId from RecordRef
        SystemId := RecRef.Field(RecRef.SystemIdNo()).Value();

        // Try to generate PDF
        Success := ReportTestHelper.TryRunReportAsPdfBase64(ReportId, TableNo, SystemId, PdfBase64);

        if not Success then
            ErrorText := GetLastErrorText();

        // Build JSON response
        JsonObj.Add('reportId', ReportId);
        JsonObj.Add('tableNo', TableNo);
        JsonObj.Add('recordSystemId', Format(SystemId));
        JsonObj.Add('recordNo', Format(RecRef.RecordId));
        JsonObj.Add('success', Success);

        if Success then begin
            JsonObj.Add('pdfSizeBytes', ReportTestHelper.GetPdfSizeFromBase64(PdfBase64));
            JsonObj.Add('pdfBase64', PdfBase64);
            JsonObj.Add('hasPdfContent', PdfBase64 <> '');
        end else
            JsonObj.Add('error', ErrorText);

        JsonObj.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// Tests a report by automatically finding the first posted sales invoice.
    /// This function is designed for RDLC report testing - it finds test data automatically
    /// and captures detailed error information if report generation fails.
    /// </summary>
    /// <param name="ReportId">The ID of the report to test (e.g., 50000 for VOL Posted Sales Invoice).</param>
    /// <returns>JSON string with test results, PDF Base64 content (if successful), and detailed error information (if failed).</returns>
    procedure TestReportWithFirstPostedSalesInvoice(ReportId: Integer): Text
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReportTestHelper: Codeunit "VOL Report Test Helper";
        JsonObj: JsonObject;
        PdfBase64: Text;
        Success: Boolean;
        ErrorText: Text;
        ErrorDetails: Text;
        StartTime: DateTime;
        EndTime: DateTime;
        ResultText: Text;
        SystemId: Guid;
    begin
        StartTime := CurrentDateTime;

        // Find first posted sales invoice
        if not SalesInvoiceHeader.FindFirst() then begin
            JsonObj.Add('success', false);
            JsonObj.Add('error', 'No posted sales invoices found in the system');
            JsonObj.Add('reportId', ReportId);
            JsonObj.Add('tableNo', Database::"Sales Invoice Header");
            JsonObj.WriteTo(ResultText);
            exit(ResultText);
        end;

        SystemId := SalesInvoiceHeader.SystemId;

        // Try to generate PDF with error handling
        ClearLastError();
        Success := ReportTestHelper.TryRunReportAsPdfBase64(ReportId, Database::"Sales Invoice Header", SystemId, PdfBase64);

        if not Success then begin
            ErrorText := GetLastErrorText();
            ErrorDetails := GetLastErrorCallStack();
        end;

        EndTime := CurrentDateTime;

        // Build JSON response
        JsonObj.Add('reportId', ReportId);
        JsonObj.Add('tableNo', Database::"Sales Invoice Header");
        JsonObj.Add('recordSystemId', Format(SystemId));
        JsonObj.Add('recordNo', SalesInvoiceHeader."No.");
        JsonObj.Add('customerNo', SalesInvoiceHeader."Sell-to Customer No.");
        JsonObj.Add('postingDate', Format(SalesInvoiceHeader."Posting Date", 0, 9));
        JsonObj.Add('success', Success);
        JsonObj.Add('startTime', Format(StartTime, 0, 9));
        JsonObj.Add('endTime', Format(EndTime, 0, 9));
        JsonObj.Add('durationMs', EndTime - StartTime);

        if Success then begin
            JsonObj.Add('pdfSizeBytes', ReportTestHelper.GetPdfSizeFromBase64(PdfBase64));
            JsonObj.Add('pdfBase64', PdfBase64);
            JsonObj.Add('hasPdfContent', PdfBase64 <> '');
        end else begin
            JsonObj.Add('error', ErrorText);
            if ErrorDetails <> '' then
                JsonObj.Add('errorDetails', ErrorDetails);
        end;

        JsonObj.WriteTo(ResultText);
        exit(ResultText);
    end;

    local procedure BuildTestResultsJson(SuiteName: Code[10]): Text
    var
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        ResultJson: JsonObject;
        CodeunitsArray: JsonArray;
        CodeunitJson: JsonObject;
        TestsArray: JsonArray;
        TestJson: JsonObject;
        CurrentCodeunitId: Integer;
        Success: Integer;
        Fail: Integer;
        Skipped: Integer;
        NotExecuted: Integer;
        TotalTests: Integer;
        CodeunitResultText: Text;
    begin
        // Calculate summary
        TestMethodLine.SetRange("Test Suite", SuiteName);
        if TestMethodLine.FindFirst() then
            TestSuiteMgt.CalcTestResults(TestMethodLine, Success, Fail, Skipped, NotExecuted);

        TotalTests := Success + Fail + Skipped + NotExecuted;

        // Build summary
        ResultJson.Add('suite', SuiteName);
        ResultJson.Add('timestamp', Format(CurrentDateTime, 0, 9));
        ResultJson.Add('totalTests', TotalTests);
        ResultJson.Add('passed', Success);
        ResultJson.Add('failed', Fail);
        ResultJson.Add('skipped', Skipped);
        ResultJson.Add('notExecuted', NotExecuted);
        ResultJson.Add('success', Fail = 0);

        // Build detailed results by codeunit
        TestMethodLine.Reset();
        TestMethodLine.SetRange("Test Suite", SuiteName);
        TestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::Codeunit);
        TestMethodLine.SetRange(Run, true);

        if TestMethodLine.FindSet() then
            repeat
                Clear(CodeunitJson);
                CodeunitJson.Add('codeunitId', TestMethodLine."Test Codeunit");
                CodeunitJson.Add('codeunitName', TestMethodLine.Name);
                CodeunitJson.Add('result', Format(TestMethodLine.Result));
                CodeunitJson.Add('startTime', Format(TestMethodLine."Start Time", 0, 9));
                CodeunitJson.Add('finishTime', Format(TestMethodLine."Finish Time", 0, 9));

                // Get individual test methods for this codeunit
                Clear(TestsArray);
                CurrentCodeunitId := TestMethodLine."Test Codeunit";
                BuildTestMethodsArray(SuiteName, CurrentCodeunitId, TestsArray);
                CodeunitJson.Add('tests', TestsArray);

                CodeunitsArray.Add(CodeunitJson);
            until TestMethodLine.Next() = 0;

        ResultJson.Add('codeunits', CodeunitsArray);

        ResultJson.WriteTo(CodeunitResultText);
        exit(CodeunitResultText);
    end;

    local procedure BuildTestMethodsArray(SuiteName: Code[10]; CodeunitId: Integer; var TestsArray: JsonArray)
    var
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        TestJson: JsonObject;
        ErrorMessage: Text;
        ErrorCallStack: Text;
    begin
        TestMethodLine.SetRange("Test Suite", SuiteName);
        TestMethodLine.SetRange("Test Codeunit", CodeunitId);
        TestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::"Function");
        TestMethodLine.SetFilter("Function", '<>%1', 'OnRun');

        if TestMethodLine.FindSet() then
            repeat
                Clear(TestJson);
                TestJson.Add('method', TestMethodLine."Function");
                TestJson.Add('name', TestMethodLine.Name);
                TestJson.Add('result', Format(TestMethodLine.Result));
                TestJson.Add('startTime', Format(TestMethodLine."Start Time", 0, 9));
                TestJson.Add('finishTime', Format(TestMethodLine."Finish Time", 0, 9));

                if TestMethodLine.Result = TestMethodLine.Result::Failure then begin
                    ErrorMessage := TestSuiteMgt.GetFullErrorMessage(TestMethodLine);
                    ErrorCallStack := TestSuiteMgt.GetErrorCallStack(TestMethodLine);
                    TestJson.Add('errorMessage', ErrorMessage);
                    TestJson.Add('errorCallStack', ErrorCallStack);
                end;

                TestsArray.Add(TestJson);
            until TestMethodLine.Next() = 0;
    end;
}
