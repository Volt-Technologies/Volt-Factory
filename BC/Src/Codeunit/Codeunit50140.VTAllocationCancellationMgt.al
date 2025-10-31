/// <summary>
/// Codeunit VT Allocation Cancellation Mgt (ID 50140)
/// Manages the cancellation of allocations in sales and purchase documents
/// </summary>
codeunit 50140 "VT Allocation Cancellation Mgt"
{
    Permissions = tabledata "Reservation Entry" = rimd,
                  tabledata "Sales Line" = rm,
                  tabledata "Purchase Line" = rm,
                  tabledata "VT Allocation Cancel History" = ri;

    /// <summary>
    /// Processes the cancellation of allocations for selected sales lines
    /// </summary>
    procedure ProcessSalesLineCancellation(var SalesLine: Record "Sales Line")
    var
        TempSalesLine: Record "Sales Line" temporary;
        ConfirmManagement: Codeunit "Confirm Management";
        ReasonCode: Code[10];
        Comments: Text[250];
        CancellationCount: Integer;
        ConfirmMsg: Label 'Are you sure you want to cancel the allocation for %1 selected line(s)?', Comment = '%1 = Number of lines';
        SuccessMsg: Label 'Successfully cancelled allocations for %1 line(s).', Comment = '%1 = Number of lines';
        NoLinesMsg: Label 'No lines with valid allocations were found to cancel.';
    begin
        // Copy selected lines to temp buffer
        if SalesLine.FindSet() then
            repeat
                if SalesLine.CanCancelAllocation() then begin
                    TempSalesLine := SalesLine;
                    TempSalesLine.Insert();
                end;
            until SalesLine.Next() = 0;

        if TempSalesLine.IsEmpty() then begin
            Message(NoLinesMsg);
            exit;
        end;

        // Get confirmation
        TempSalesLine.SetRange("Document Type", TempSalesLine."Document Type");
        TempSalesLine.SetRange("Document No.", TempSalesLine."Document No.");
        if not ConfirmManagement.GetResponseOrDefault(
            StrSubstNo(ConfirmMsg, TempSalesLine.Count()), false) then
            exit;

        // Get reason code
        if not GetCancellationReasonCode(ReasonCode, Comments) then
            exit;

        // Process cancellations
        if TempSalesLine.FindSet() then
            repeat
                if CancelSingleSalesLineAllocation(TempSalesLine, ReasonCode, Comments) then
                    CancellationCount += 1;
            until TempSalesLine.Next() = 0;

        if CancellationCount > 0 then begin
            Message(SuccessMsg, CancellationCount);
            Commit();
        end;
    end;

    /// <summary>
    /// Cancels allocation for a single sales line
    /// </summary>
    procedure CancelSingleSalesLineAllocation(var SalesLine: Record "Sales Line"; ReasonCode: Code[10]; Comments: Text[250]): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        VTAllocCancelHistory: Record "VT Allocation Cancel History";
    begin
        if not ValidateSalesLineCancellation(SalesLine) then
            exit(false);

        // Find and process reservation entries
        ReservationEntry.SetRange("Source Type", DATABASE::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        ReservationEntry.SetRange("VT Is Cancelled", false);
        ReservationEntry.SetFilter("Reservation Status", '<>%1', ReservationEntry."Reservation Status"::Prospect);

        if ReservationEntry.FindSet(true) then begin
            repeat
                // Create history entry
                VTAllocCancelHistory.CreateSalesCancellationEntry(SalesLine, ReservationEntry, ReasonCode, Comments);

                // Mark reservation as cancelled
                ReservationEntry.MarkAsCancelled(VTAllocCancelHistory."Entry No.");
            until ReservationEntry.Next() = 0;

            // Update sales line
            SalesLine."VT Allocation Status" := SalesLine."VT Allocation Status"::Cancelled;
            SalesLine."VT Allocation Cancelled Date" := Today;
            SalesLine."VT Allocation Cancelled By" := UserId;
            SalesLine.Modify(true);

            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Validates if a sales line can have its allocation cancelled
    /// </summary>
    local procedure ValidateSalesLineCancellation(SalesLine: Record "Sales Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
        ErrorMsg: Label 'Cannot cancel allocation: %1', Comment = '%1 = Error reason';
    begin
        // Check document status
        if not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            Error(ErrorMsg, 'Sales order not found');

        if SalesHeader.Status <> SalesHeader.Status::Open then
            Error(ErrorMsg, 'Document must be in Open status');

        // Check quantities
        if SalesLine."Quantity Shipped" <> 0 then
            Error(ErrorMsg, 'Line has already been partially or fully shipped');

        // Check warehouse
        if SalesLine.HasWarehouseShipment() then
            Error(ErrorMsg, 'Line has an existing warehouse shipment');

        // Check if already cancelled
        if SalesLine."VT Allocation Status" = SalesLine."VT Allocation Status"::Cancelled then
            Error(ErrorMsg, 'Allocation is already cancelled');

        exit(true);
    end;

    /// <summary>
    /// Processes the cancellation of allocations for selected purchase lines
    /// </summary>
    procedure ProcessPurchaseLineCancellation(var PurchaseLine: Record "Purchase Line")
    var
        TempPurchaseLine: Record "Purchase Line" temporary;
        ConfirmManagement: Codeunit "Confirm Management";
        ReasonCode: Code[10];
        Comments: Text[250];
        CancellationCount: Integer;
        ConfirmMsg: Label 'Are you sure you want to cancel the allocation for %1 selected line(s)?', Comment = '%1 = Number of lines';
        SuccessMsg: Label 'Successfully cancelled allocations for %1 line(s).', Comment = '%1 = Number of lines';
        NoLinesMsg: Label 'No lines with valid allocations were found to cancel.';
    begin
        // Copy selected lines to temp buffer
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine.CanCancelAllocation() then begin
                    TempPurchaseLine := PurchaseLine;
                    TempPurchaseLine.Insert();
                end;
            until PurchaseLine.Next() = 0;

        if TempPurchaseLine.IsEmpty() then begin
            Message(NoLinesMsg);
            exit;
        end;

        // Get confirmation
        TempPurchaseLine.SetRange("Document Type", TempPurchaseLine."Document Type");
        TempPurchaseLine.SetRange("Document No.", TempPurchaseLine."Document No.");
        if not ConfirmManagement.GetResponseOrDefault(
            StrSubstNo(ConfirmMsg, TempPurchaseLine.Count()), false) then
            exit;

        // Get reason code
        if not GetCancellationReasonCode(ReasonCode, Comments) then
            exit;

        // Process cancellations
        if TempPurchaseLine.FindSet() then
            repeat
                if CancelSinglePurchaseLineAllocation(TempPurchaseLine, ReasonCode, Comments) then
                    CancellationCount += 1;
            until TempPurchaseLine.Next() = 0;

        if CancellationCount > 0 then begin
            Message(SuccessMsg, CancellationCount);
            Commit();
        end;
    end;

    /// <summary>
    /// Cancels allocation for a single purchase line
    /// </summary>
    procedure CancelSinglePurchaseLineAllocation(var PurchaseLine: Record "Purchase Line"; ReasonCode: Code[10]; Comments: Text[250]): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        VTAllocCancelHistory: Record "VT Allocation Cancel History";
    begin
        if not ValidatePurchaseLineCancellation(PurchaseLine) then
            exit(false);

        // Find and process reservation entries
        ReservationEntry.SetRange("Source Type", DATABASE::"Purchase Line");
        ReservationEntry.SetRange("Source Subtype", PurchaseLine."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", PurchaseLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", PurchaseLine."Line No.");
        ReservationEntry.SetRange("VT Is Cancelled", false);
        ReservationEntry.SetFilter("Reservation Status", '<>%1', ReservationEntry."Reservation Status"::Prospect);

        if ReservationEntry.FindSet(true) then begin
            repeat
                // Create history entry
                VTAllocCancelHistory.CreatePurchaseCancellationEntry(PurchaseLine, ReservationEntry, ReasonCode, Comments);

                // Mark reservation as cancelled
                ReservationEntry.MarkAsCancelled(VTAllocCancelHistory."Entry No.");
            until ReservationEntry.Next() = 0;

            // Update purchase line
            PurchaseLine."VT Allocation Status" := PurchaseLine."VT Allocation Status"::Cancelled;
            PurchaseLine."VT Allocation Cancelled Date" := Today;
            PurchaseLine."VT Allocation Cancelled By" := UserId;
            PurchaseLine.Modify(true);

            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Validates if a purchase line can have its allocation cancelled
    /// </summary>
    local procedure ValidatePurchaseLineCancellation(PurchaseLine: Record "Purchase Line"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMsg: Label 'Cannot cancel allocation: %1', Comment = '%1 = Error reason';
    begin
        // Check document status
        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            Error(ErrorMsg, 'Purchase order not found');

        if PurchaseHeader.Status <> PurchaseHeader.Status::Open then
            Error(ErrorMsg, 'Document must be in Open status');

        // Check quantities
        if PurchaseLine."Quantity Received" <> 0 then
            Error(ErrorMsg, 'Line has already been partially or fully received');

        // Check warehouse
        if PurchaseLine.HasWarehouseReceipt() then
            Error(ErrorMsg, 'Line has an existing warehouse receipt');

        // Check if already cancelled
        if PurchaseLine."VT Allocation Status" = PurchaseLine."VT Allocation Status"::Cancelled then
            Error(ErrorMsg, 'Allocation is already cancelled');

        exit(true);
    end;

    /// <summary>
    /// Prompts user for cancellation reason code and optional comments
    /// </summary>
    procedure GetCancellationReasonCode(var ReasonCode: Code[10]; var Comments: Text[250]): Boolean
    var
        ReasonCodeRec: Record "Reason Code";
        ReasonCodeList: Page "Reason Codes";
        CommentsDialog: Page "Comment Sheet";
    begin
        // Set filter for cancellation reason codes
        ReasonCodeRec.SetFilter(Code, 'CANCEL*|ALLOC*');
        if ReasonCodeRec.IsEmpty() then
            ReasonCodeRec.Reset();

        ReasonCodeList.SetTableView(ReasonCodeRec);
        ReasonCodeList.LookupMode(true);
        ReasonCodeList.Caption('Select Cancellation Reason');

        if ReasonCodeList.RunModal() = ACTION::LookupOK then begin
            ReasonCodeList.GetRecord(ReasonCodeRec);
            ReasonCode := ReasonCodeRec.Code;

            // Optionally get comments
            Comments := '';
            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Creates cancellation history entry
    /// </summary>
    procedure CreateCancellationHistory(SourceType: Integer; SourceSubtype: Integer; DocumentNo: Code[20]; LineNo: Integer; ItemNo: Code[20]; LocationCode: Code[10]; QuantityCancelled: Decimal; ReasonCode: Code[10])
    var
        VTAllocCancelHistory: Record "VT Allocation Cancel History";
    begin
        VTAllocCancelHistory.Init();
        VTAllocCancelHistory."Source Type" := SourceType;
        VTAllocCancelHistory."Source Subtype" := SourceSubtype;
        VTAllocCancelHistory."Document No." := DocumentNo;
        VTAllocCancelHistory."Line No." := LineNo;
        VTAllocCancelHistory."Item No." := ItemNo;
        VTAllocCancelHistory."Location Code" := LocationCode;
        VTAllocCancelHistory."Quantity Cancelled" := QuantityCancelled;
        VTAllocCancelHistory."Quantity Cancelled (Base)" := QuantityCancelled;
        VTAllocCancelHistory."Cancellation Date" := Today;
        VTAllocCancelHistory."Cancellation Time" := Time;
        VTAllocCancelHistory."Cancelled By User ID" := UserId;
        VTAllocCancelHistory."Cancellation Reason Code" := ReasonCode;
        VTAllocCancelHistory.Insert(true);
    end;
}