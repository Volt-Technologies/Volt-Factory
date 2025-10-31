/// <summary>
/// TableExtension VT Reservation Entry Ext (ID 50112)
/// Extends the Reservation Entry table to add cancellation tracking fields
/// </summary>
tableextension 50112 "VT Reservation Entry Ext" extends "Reservation Entry"
{
    fields
    {
        field(50100; "VT Is Cancelled"; Boolean)
        {
            Caption = 'Is Cancelled';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50101; "VT Cancellation Entry No."; Integer)
        {
            Caption = 'Cancellation Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "VT Allocation Cancel History"."Entry No.";
            Editable = false;
        }
        field(50102; "VT Cancellation DateTime"; DateTime)
        {
            Caption = 'Cancellation DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    /// <summary>
    /// Marks the reservation entry as cancelled
    /// </summary>
    procedure MarkAsCancelled(CancellationEntryNo: Integer)
    begin
        Rec."VT Is Cancelled" := true;
        Rec."VT Cancellation Entry No." := CancellationEntryNo;
        Rec."VT Cancellation DateTime" := CurrentDateTime;
        Rec.Quantity := 0;
        Rec."Quantity (Base)" := 0;
        Rec.Modify(true);
    end;

    /// <summary>
    /// Checks if the reservation can be cancelled
    /// </summary>
    procedure CanBeCancelled(): Boolean
    begin
        if Rec."VT Is Cancelled" then
            exit(false);

        if Rec."Disallow Cancellation" then
            exit(false);

        if Rec."Reservation Status" = Rec."Reservation Status"::Prospect then
            exit(false);

        exit(true);
    end;
}