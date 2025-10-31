/// <summary>
/// Codeunit VT Allocation Cancel Install (ID 50142)
/// Handles installation and setup of the allocation cancellation feature
/// </summary>
codeunit 50142 "VT Allocation Cancel Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitializeReasonCodes();
        // Permission set creation removed - handle manually if needed
    end;

    /// <summary>
    /// Initializes default reason codes for allocation cancellation
    /// </summary>
    local procedure InitializeReasonCodes()
    var
        ReasonCode: Record "Reason Code";
    begin
        // Create default cancellation reason codes if they don't exist
        if not ReasonCode.Get('CANC-CUST') then begin
            ReasonCode.Init();
            ReasonCode.Code := 'CANC-CUST';
            ReasonCode.Description := 'Customer Requested Cancellation';
            if ReasonCode.Insert() then;
        end;

        if not ReasonCode.Get('CANC-STOCK') then begin
            ReasonCode.Init();
            ReasonCode.Code := 'CANC-STOCK';
            ReasonCode.Description := 'Stock Availability Issue';
            if ReasonCode.Insert() then;
        end;

        if not ReasonCode.Get('CANC-PRICE') then begin
            ReasonCode.Init();
            ReasonCode.Code := 'CANC-PRICE';
            ReasonCode.Description := 'Price Adjustment Required';
            if ReasonCode.Insert() then;
        end;

        if not ReasonCode.Get('CANC-ERROR') then begin
            ReasonCode.Init();
            ReasonCode.Code := 'CANC-ERROR';
            ReasonCode.Description := 'Allocation Error Correction';
            if ReasonCode.Insert() then;
        end;

        if not ReasonCode.Get('CANC-OTHER') then begin
            ReasonCode.Init();
            ReasonCode.Code := 'CANC-OTHER';
            ReasonCode.Description := 'Other Cancellation Reason';
            if ReasonCode.Insert() then;
        end;
    end;

}