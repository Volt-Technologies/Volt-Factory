/// <summary>
/// Codeunit VT Allocation Posting Subscribers (ID 50141)
/// Subscribes to posting events to handle cancelled allocations
/// </summary>
codeunit 50141 "VT Allocation Post Subscriber"
{
    /// <summary>
    /// Subscribes to OnBeforeTestSalesLine to skip cancelled allocation lines
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeTestSalesLine', '', false, false)]
    local procedure OnBeforeTestSalesLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    begin
        if SalesLine."VT Allocation Status" = SalesLine."VT Allocation Status"::Cancelled then begin
            if SalesLine."Quantity Shipped" = 0 then begin
                LogSkippedSalesLine(SalesLine);
                IsHandled := true;
            end;
        end;
    end;

    /// <summary>
    /// Subscribes to OnBeforeTestPurchLine to skip cancelled allocation lines
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLine', '', false, false)]
    local procedure OnBeforeTestPurchLine(PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; var IsHandled: Boolean)
    begin
        if PurchaseLine."VT Allocation Status" = PurchaseLine."VT Allocation Status"::Cancelled then begin
            if PurchaseLine."Quantity Received" = 0 then begin
                LogSkippedPurchaseLine(PurchaseLine);
                IsHandled := true;
            end;
        end;
    end;

    /// <summary>
    /// Subscribes to reservation entry deletion to prevent deletion of cancelled entries
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteReservationEntry(var Rec: Record "Reservation Entry"; RunTrigger: Boolean)
    begin
        if Rec."VT Is Cancelled" then
            if not GuiAllowed then
                exit;

        if Rec."VT Is Cancelled" then
            if Confirm('This reservation has been cancelled. Do you want to delete the cancelled reservation entry?', false) then
                exit
            else
                Error('Deletion of cancelled reservation entry was cancelled by user.');
    end;

    /// <summary>
    /// Logs skipped sales line during posting
    /// </summary>
    local procedure LogSkippedSalesLine(SalesLine: Record "Sales Line")
    var
        EventLogEntry: Record "Activity Log";
        DescriptionTxt: Label 'Sales Line %1 on Document %2 was skipped during posting due to cancelled allocation', Comment = '%1 = Line No., %2 = Document No.';
    begin
        EventLogEntry.LogActivity(
            SalesLine.RecordId,
            EventLogEntry.Status::Success,
            'VT Allocation Cancellation',
            StrSubstNo(DescriptionTxt, SalesLine."Line No.", SalesLine."Document No."),
            '');
    end;

    /// <summary>
    /// Logs skipped purchase line during posting
    /// </summary>
    local procedure LogSkippedPurchaseLine(PurchaseLine: Record "Purchase Line")
    var
        EventLogEntry: Record "Activity Log";
        DescriptionTxt: Label 'Purchase Line %1 on Document %2 was skipped during posting due to cancelled allocation', Comment = '%1 = Line No., %2 = Document No.';
    begin
        EventLogEntry.LogActivity(
            PurchaseLine.RecordId,
            EventLogEntry.Status::Success,
            'VT Allocation Cancellation',
            StrSubstNo(DescriptionTxt, PurchaseLine."Line No.", PurchaseLine."Document No."),
            '');
    end;

}