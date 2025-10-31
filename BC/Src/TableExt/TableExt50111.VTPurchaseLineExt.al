/// <summary>
/// TableExtension VT Purchase Line Ext (ID 50111)
/// Extends the Purchase Line table to add allocation cancellation fields
/// </summary>
tableextension 50111 "VT Purchase Line Ext" extends "Purchase Line"
{
    fields
    {
        field(50100; "VT Allocation Status"; Enum "VT Allocation Status")
        {
            Caption = 'Allocation Status';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                if "VT Allocation Status" = "VT Allocation Status"::Cancelled then begin
                    "VT Allocation Cancelled Date" := Today;
                    "VT Allocation Cancelled By" := UserId;
                end;
            end;
        }
        field(50101; "VT Allocation Cancelled Date"; Date)
        {
            Caption = 'Allocation Cancelled Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50102; "VT Allocation Cancelled By"; Code[50])
        {
            Caption = 'Allocation Cancelled By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(50103; "VT Cancel History Exists"; Boolean)
        {
            Caption = 'Cancellation History Exists';
            FieldClass = FlowField;
            CalcFormula = exist("VT Allocation Cancel History" WHERE(
                "Source Type" = CONST(39),
                "Document No." = FIELD("Document No."),
                "Line No." = FIELD("Line No.")));
            Editable = false;
        }
    }

    /// <summary>
    /// Checks if the purchase line can have its allocation cancelled
    /// </summary>
    procedure CanCancelAllocation(): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        // Check if line is open and not received
        if Rec."Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then
            exit(false);

        if Rec."Quantity Received" <> 0 then
            exit(false);

        if Rec."Qty. Received (Base)" <> 0 then
            exit(false);

        // Check if there are active reservations
        ReservationEntry.SetRange("Source Type", DATABASE::"Purchase Line");
        ReservationEntry.SetRange("Source Subtype", Rec."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", Rec."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", Rec."Line No.");
        ReservationEntry.SetFilter("Reservation Status", '<>%1', ReservationEntry."Reservation Status"::Prospect);
        ReservationEntry.SetRange("VT Is Cancelled", false);
        exit(not ReservationEntry.IsEmpty());
    end;

    /// <summary>
    /// Gets the total reserved quantity for the purchase line (excluding cancelled)
    /// </summary>
    procedure GetActiveReservedQty(): Decimal
    var
        ReservationEntry: Record "Reservation Entry";
        TotalQty: Decimal;
    begin
        ReservationEntry.SetRange("Source Type", DATABASE::"Purchase Line");
        ReservationEntry.SetRange("Source Subtype", Rec."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", Rec."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", Rec."Line No.");
        ReservationEntry.SetRange("VT Is Cancelled", false);
        ReservationEntry.SetFilter("Reservation Status", '<>%1', ReservationEntry."Reservation Status"::Prospect);
        if ReservationEntry.FindSet() then
            repeat
                TotalQty += Abs(ReservationEntry.Quantity);
            until ReservationEntry.Next() = 0;
        exit(TotalQty);
    end;

    /// <summary>
    /// Checks if line has warehouse receipt
    /// </summary>
    procedure HasWarehouseReceipt(): Boolean
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WarehouseReceiptLine.SetRange("Source Type", DATABASE::"Purchase Line");
        WarehouseReceiptLine.SetRange("Source Subtype", Rec."Document Type".AsInteger());
        WarehouseReceiptLine.SetRange("Source No.", Rec."Document No.");
        WarehouseReceiptLine.SetRange("Source Line No.", Rec."Line No.");
        exit(not WarehouseReceiptLine.IsEmpty());
    end;
}