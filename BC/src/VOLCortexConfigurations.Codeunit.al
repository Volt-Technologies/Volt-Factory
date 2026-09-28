/// <summary>
/// Configurations exposed to Cortex as the codeunit web service "CortexConfigurations".
/// Every public Apply*/Verify* procedure takes one InputJson text and returns a JSON
/// text: { "success": bool, "message": text, "details": object }. GetConfigurations()
/// lists them so the Cortex UI can build a dropdown. Registered per environment AND
/// per company through BC/WS.xml.
/// The JSON property names, the catalogue entry names and the procedure names are a
/// wire contract with the Cortex API and are therefore literals, never Labels: a
/// translated key would break the caller. Only text a consultant reads is a Label.
/// The codeunit id below is the template's; use any free id in your app's range.
/// Contract: docs/cortex-projects/configurations-codeunit-contract.md (Cortex repo).
/// </summary>
codeunit 59990 "VOL Cortex Configurations"
{
    Access = Public;

    var
        StockoutDescriptionLbl: Label 'Stockout warning enabled on Sales & Receivables Setup';
        StockoutAppliedMsg: Label 'Stockout Warning set to true';
        SalesSetupReadMsg: Label 'Read Sales & Receivables Setup';
        SalesSetupMissingErr: Label 'Sales & Receivables Setup has no record';

    /// <summary>
    /// The catalogue Cortex reads to build its dropdown. Procedure names are explicit
    /// because Cortex derives nothing. Add one AddEntry call per configuration, and
    /// state any order-of-operations rule in the description.
    /// </summary>
    procedure GetConfigurations(): Text
    var
        Catalogue: JsonArray;
        Result: Text;
    begin
        AddEntry(Catalogue,
            'SalesReceivablesSetup',
            StockoutDescriptionLbl,
            'Sales',
            'ApplySalesReceivablesSetup',
            'VerifySalesReceivablesSetup',
            true,
            ExpectedSalesReceivablesSetup());
        Catalogue.WriteTo(Result);
        exit(Result);
    end;

    /// <summary>The values Apply establishes — what Verify must report afterwards.</summary>
    local procedure ExpectedSalesReceivablesSetup() Expect: JsonObject
    begin
        Expect.Add('stockoutWarning', true);
    end;

    /// <summary>Sets Stockout Warning on Sales and Receivables Setup. Idempotent.</summary>
    procedure ApplySalesReceivablesSetup(InputJson: Text): Text
    var
        Details: JsonObject;
    begin
        if not TryApplySalesReceivablesSetup() then
            exit(Failure(GetLastErrorText()));
        Details.Add('stockoutWarning', true);
        exit(Success(StockoutAppliedMsg, Details));
    end;

    /// <summary>
    /// Reads Sales and Receivables Setup. Read-only, so Cortex may run it against any
    /// environment without confirmation. Return EVERY field this configuration cares
    /// about: these key names are exactly what lands in the work item's `expect`.
    /// </summary>
    procedure VerifySalesReceivablesSetup(InputJson: Text): Text
    var
        SalesSetup: Record "Sales & Receivables Setup";
        Details: JsonObject;
    begin
        if not SalesSetup.Get() then
            exit(Failure(SalesSetupMissingErr));
        Details.Add('stockoutWarning', SalesSetup."Stockout Warning");
        Details.Add('calcInvDiscount', SalesSetup."Calc. Inv. Discount");
        exit(Success(SalesSetupReadMsg, Details));
    end;

    [TryFunction]
    local procedure TryApplySalesReceivablesSetup()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if not SalesSetup.Get() then
            SalesSetup.Insert(true);
        SalesSetup.Validate("Stockout Warning", true);
        SalesSetup.Modify(true);
    end;

    /// <summary>
    /// Appends one catalogue entry in the shape the Cortex API parses. Expect is
    /// what Apply establishes, keyed exactly as Verify reports it: Cortex copies it
    /// into the configuration when the function is bound, so Apply &amp; verify checks
    /// the card against what the function meant to set. Pass an empty object only
    /// when the target is "whatever the card says now".
    /// </summary>
    local procedure AddEntry(var Catalogue: JsonArray; Name: Text; Description: Text; AreaName: Text; ApplyProc: Text; VerifyProc: Text; Idempotent: Boolean; Expect: JsonObject)
    var
        Entry: JsonObject;
    begin
        Entry.Add('name', Name);
        Entry.Add('description', Description);
        Entry.Add('area', AreaName);
        Entry.Add('apply', ApplyProc);
        if VerifyProc <> '' then
            Entry.Add('verify', VerifyProc)
        else
            Entry.Add('verify', JsonNull());
        Entry.Add('idempotent', Idempotent);
        if Expect.Keys.Count() > 0 then
            Entry.Add('expect', Expect);
        Catalogue.Add(Entry);
    end;

    local procedure JsonNull() Value: JsonValue
    begin
        Value.SetValueToNull();
    end;

    /// <summary>The success half of the uniform result shape.</summary>
    local procedure Success(Message: Text; Details: JsonObject): Text
    var
        Result: JsonObject;
        ResultText: Text;
    begin
        Result.Add('success', true);
        Result.Add('message', Message);
        Result.Add('details', Details);
        Result.WriteTo(ResultText);
        exit(ResultText);
    end;

    /// <summary>
    /// The refusal half. Cortex records a non-true success as a blocked run carrying
    /// this message, which is why an error is never allowed to propagate to HTTP.
    /// </summary>
    local procedure Failure(Message: Text): Text
    var
        Result: JsonObject;
        Details: JsonObject;
        ResultText: Text;
    begin
        Result.Add('success', false);
        Result.Add('message', Message);
        Result.Add('details', Details);
        Result.WriteTo(ResultText);
        exit(ResultText);
    end;
}
