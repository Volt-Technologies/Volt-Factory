/// <summary>
/// Codeunit VOL Test Runner WS (ID 78000).
/// Web service codeunit for running automated tests via API calls.
/// Exposes procedures for bc-tester agent to execute tests and retrieve results.
/// </summary>
codeunit 90000 "VOL Test Runner WS"
{
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
    /// Runs a specific test codeunit by ID.
    /// </summary>
    /// <param name="CodeunitId">The ID of the test codeunit to run.</param>
    /// <returns>JSON string with test results for the specific codeunit.</returns>
    procedure RunTestCodeunit(CodeunitId: Integer): Text
    var
        ALTestSuite: Record "AL Test Suite";
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        CodeunitMetadata: Record "CodeUnit Metadata";
        SuiteName: Code[10];
        ResultJson: Text;
    begin
        SuiteName := 'SINGLE';

        // Verify codeunit exists and is a test codeunit
        if not CodeunitMetadata.Get(CodeunitId) then
            exit('{"error": "Codeunit not found: ' + Format(CodeunitId) + '"}');

        if CodeunitMetadata.SubType <> CodeunitMetadata.SubType::Test then
            exit('{"error": "Codeunit is not a test codeunit: ' + Format(CodeunitId) + '"}');

        // Create or clear the test suite
        if ALTestSuite.Get(SuiteName) then begin
            TestMethodLine.SetRange("Test Suite", SuiteName);
            TestMethodLine.DeleteAll(true);
        end else begin
            TestSuiteMgt.CreateTestSuite(SuiteName);
            ALTestSuite.Get(SuiteName);
        end;

        // Add the specific test codeunit
        CodeunitMetadata.SetRange(ID, CodeunitId);
        TestSuiteMgt.GetTestMethods(ALTestSuite, CodeunitMetadata);

        // Run the tests
        TestMethodLine.SetRange("Test Suite", SuiteName);
        if TestMethodLine.FindFirst() then
            TestSuiteMgt.RunAllTests(TestMethodLine);

        ResultJson := BuildTestResultsJson(SuiteName);
        exit(ResultJson);
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
