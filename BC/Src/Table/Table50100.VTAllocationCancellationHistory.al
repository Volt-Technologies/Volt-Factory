/// <summary>
/// Table VT Allocation Cancellation History (ID 50100)
/// Stores the complete history of allocation cancellations for audit and compliance purposes
/// </summary>
table 50100 "VT Allocation Cancel History"
{
    Caption = 'VT Allocation Cancellation History';
    DataClassification = CustomerContent;
    LookupPageId = "VT Alloc Cancel History List";
    DrillDownPageId = "VT Alloc Cancel History List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            Editable = false;
            // 37 for Sales, 39 for Purchase
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            Editable = false;
        }
        field(7; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            Editable = false;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            Editable = false;
        }
        field(9; "Quantity Cancelled"; Decimal)
        {
            Caption = 'Quantity Cancelled';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(10; "Quantity Cancelled (Base)"; Decimal)
        {
            Caption = 'Quantity Cancelled (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(11; "Cancellation Date"; Date)
        {
            Caption = 'Cancellation Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Cancellation Time"; Time)
        {
            Caption = 'Cancellation Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Cancelled By User ID"; Code[50])
        {
            Caption = 'Cancelled By User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(14; "Cancellation Reason Code"; Code[10])
        {
            Caption = 'Cancellation Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
            Editable = false;
        }
        field(15; "Original Reservation Entry No."; Integer)
        {
            Caption = 'Original Reservation Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Customer/Vendor No."; Code[20])
        {
            Caption = 'Customer/Vendor No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Customer/Vendor Name"; Text[100])
        {
            Caption = 'Customer/Vendor Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            Editable = false;
        }
        field(19; "Cancellation Comments"; Text[250])
        {
            Caption = 'Cancellation Comments';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Source Subtype"; Integer)
        {
            Caption = 'Source Subtype';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DocumentKey; "Document Type", "Document No.", "Line No.")
        {
        }
        key(DateKey; "Cancellation Date", "Cancellation Time")
        {
        }
        key(UserKey; "Cancelled By User ID", "Cancellation Date")
        {
        }
        key(ItemKey; "Item No.", "Cancellation Date")
        {
        }
        key(ReasonKey; "Cancellation Reason Code", "Cancellation Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
    end;

    /// <summary>
    /// Creates a cancellation entry for a sales line allocation cancellation
    /// </summary>
    procedure CreateSalesCancellationEntry(SalesLine: Record "Sales Line"; ReservationEntry: Record "Reservation Entry"; ReasonCode: Code[10]; Comments: Text[250])
    var
        Customer: Record Customer;
    begin
        Init();
        "Document Type" := SalesLine."Document Type";
        "Document No." := SalesLine."Document No.";
        "Line No." := SalesLine."Line No.";
        "Source Type" := DATABASE::"Sales Line";
        "Source Subtype" := SalesLine."Document Type".AsInteger();
        "Item No." := SalesLine."No.";
        "Variant Code" := SalesLine."Variant Code";
        "Location Code" := SalesLine."Location Code";
        "Unit of Measure Code" := SalesLine."Unit of Measure Code";
        "Quantity Cancelled" := Abs(ReservationEntry.Quantity);
        "Quantity Cancelled (Base)" := Abs(ReservationEntry."Quantity (Base)");
        "Cancellation Date" := Today;
        "Cancellation Time" := Time;
        "Cancelled By User ID" := UserId;
        "Cancellation Reason Code" := ReasonCode;
        "Cancellation Comments" := Comments;
        "Original Reservation Entry No." := ReservationEntry."Entry No.";
        "Customer/Vendor No." := SalesLine."Sell-to Customer No.";
        if Customer.Get(SalesLine."Sell-to Customer No.") then
            "Customer/Vendor Name" := Customer.Name;
        Insert(true);
    end;

    /// <summary>
    /// Creates a cancellation entry for a purchase line allocation cancellation
    /// </summary>
    procedure CreatePurchaseCancellationEntry(PurchaseLine: Record "Purchase Line"; ReservationEntry: Record "Reservation Entry"; ReasonCode: Code[10]; Comments: Text[250])
    var
        Vendor: Record Vendor;
        PurchDocType: Enum "Purchase Document Type";
    begin
        Init();
        // Map Purchase Document Type to Sales Document Type enum for storage
        case PurchaseLine."Document Type" of
            PurchDocType::Order:
                "Document Type" := "Document Type"::Order;
            PurchDocType::Quote:
                "Document Type" := "Document Type"::Quote;
            else
                "Document Type" := "Document Type"::Order;
        end;
        "Document No." := PurchaseLine."Document No.";
        "Line No." := PurchaseLine."Line No.";
        "Source Type" := DATABASE::"Purchase Line";
        "Source Subtype" := PurchaseLine."Document Type".AsInteger();
        "Item No." := PurchaseLine."No.";
        "Variant Code" := PurchaseLine."Variant Code";
        "Location Code" := PurchaseLine."Location Code";
        "Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
        "Quantity Cancelled" := Abs(ReservationEntry.Quantity);
        "Quantity Cancelled (Base)" := Abs(ReservationEntry."Quantity (Base)");
        "Cancellation Date" := Today;
        "Cancellation Time" := Time;
        "Cancelled By User ID" := UserId;
        "Cancellation Reason Code" := ReasonCode;
        "Cancellation Comments" := Comments;
        "Original Reservation Entry No." := ReservationEntry."Entry No.";
        "Customer/Vendor No." := PurchaseLine."Buy-from Vendor No.";
        if Vendor.Get(PurchaseLine."Buy-from Vendor No.") then
            "Customer/Vendor Name" := Vendor.Name;
        Insert(true);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        VTAllocCancelHistory: Record "VT Allocation Cancel History";
    begin
        VTAllocCancelHistory.SetLoadFields("Entry No.");
        if VTAllocCancelHistory.FindLast() then
            exit(VTAllocCancelHistory."Entry No." + 1);
        exit(1);
    end;
}