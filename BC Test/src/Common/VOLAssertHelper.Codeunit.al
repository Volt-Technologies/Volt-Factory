codeunit 90003 "VOL Assert Helper"
{
    // Manual assertion helpers for BC AL tests.
    //
    // Use these instead of Microsoft's Library Assert / Assert.AreEqual family.
    // The OData-based TestRunner (codeunit 90000 "VOL Test Runner WS") invokes
    // tests outside the AL Test Tool runtime, where the Microsoft Test Libraries
    // do not behave reliably. Plain Error() calls work in both the AL Test Tool
    // UI and the OData runner, so that is the portable pattern.
    //
    // Every assertion takes a Context: Text argument so the failure message
    // identifies WHICH assertion failed when a single test calls many.

    Access = Public;

    procedure AssertEquals(Expected: Text; Actual: Text; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected "%2", got "%3".', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: Integer; Actual: Integer; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected %2, got %3.', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: Decimal; Actual: Decimal; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected %2, got %3.', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: Boolean; Actual: Boolean; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected %2, got %3.', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: Code[20]; Actual: Code[20]; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected "%2", got "%3".', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: Date; Actual: Date; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected %2, got %3.', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: DateTime; Actual: DateTime; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected %2, got %3.', Context, Expected, Actual);
    end;

    procedure AssertEquals(Expected: Guid; Actual: Guid; Context: Text)
    begin
        if Expected <> Actual then
            Error('Assertion failed [%1]: Expected %2, got %3.', Context, Format(Expected), Format(Actual));
    end;

    procedure AssertNear(Expected: Decimal; Actual: Decimal; Tolerance: Decimal; Context: Text)
    begin
        if Abs(Expected - Actual) > Tolerance then
            Error('Assertion failed [%1]: Expected %2 +/- %3, got %4 (diff %5).',
                Context, Expected, Tolerance, Actual, Actual - Expected);
    end;

    procedure AssertTrue(Condition: Boolean; Context: Text)
    begin
        if not Condition then
            Error('Assertion failed [%1]: Expected true, got false.', Context);
    end;

    procedure AssertFalse(Condition: Boolean; Context: Text)
    begin
        if Condition then
            Error('Assertion failed [%1]: Expected false, got true.', Context);
    end;

    procedure AssertBlank(Value: Text; Context: Text)
    begin
        if Value <> '' then
            Error('Assertion failed [%1]: Expected blank, got "%2".', Context, Value);
    end;

    procedure AssertNotBlank(Value: Text; Context: Text)
    begin
        if Value = '' then
            Error('Assertion failed [%1]: Expected non-blank value.', Context);
    end;

    procedure AssertContains(Haystack: Text; Needle: Text; Context: Text)
    begin
        if StrPos(Haystack, Needle) = 0 then
            Error('Assertion failed [%1]: Expected "%2" to contain "%3".', Context, Haystack, Needle);
    end;

    /// <summary>
    /// Verifies that the last error (typically captured with a preceding
    /// guarded call) contains the expected fragment.
    /// Pair this with ClearLastError() in test setup / teardown.
    /// </summary>
    procedure AssertErrorContains(ExpectedFragment: Text; ActualErrorText: Text; Context: Text)
    begin
        if ActualErrorText = '' then
            Error('Assertion failed [%1]: Expected an error containing "%2", but no error was raised.',
                Context, ExpectedFragment);
        if StrPos(ActualErrorText, ExpectedFragment) = 0 then
            Error('Assertion failed [%1]: Expected error containing "%2", got "%3".',
                Context, ExpectedFragment, ActualErrorText);
    end;

    /// <summary>
    /// Verifies that a recordset is empty. Pass a filtered record; typical use
    /// is to confirm a Delete() cascaded as expected or that no matching rows
    /// exist after a validation error should have rolled back.
    /// </summary>
    procedure AssertRecordEmpty(var RecRef: RecordRef; Context: Text)
    begin
        if not RecRef.IsEmpty() then
            Error('Assertion failed [%1]: Expected no records, found %2.', Context, RecRef.Count());
    end;

    /// <summary>
    /// Verifies that a recordset contains exactly the expected number of rows.
    /// </summary>
    procedure AssertRecordCount(var RecRef: RecordRef; ExpectedCount: Integer; Context: Text)
    var
        ActualCount: Integer;
    begin
        ActualCount := RecRef.Count();
        if ActualCount <> ExpectedCount then
            Error('Assertion failed [%1]: Expected %2 records, found %3.', Context, ExpectedCount, ActualCount);
    end;
}
