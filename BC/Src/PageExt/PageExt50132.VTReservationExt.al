/// <summary>
/// PageExtension VT Reservation Ext (ID 50132)
/// Extends the Reservation Entries page to show cancellation status
/// </summary>
pageextension 50132 "VT Reservation Ext" extends "Reservation Entries"
{
    layout
    {
        addafter("Reservation Status")
        {
            field("VT Is Cancelled"; Rec."VT Is Cancelled")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the reservation has been cancelled.';
                StyleExpr = VTCancellationStyle;
                Editable = false;
            }
            field("VT Cancellation DateTime"; Rec."VT Cancellation DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies when the reservation was cancelled.';
                Visible = false;
            }
        }
    }

    var
        VTCancellationStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetCancellationStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetCancellationStyle();
    end;

    local procedure SetCancellationStyle()
    begin
        if Rec."VT Is Cancelled" then
            VTCancellationStyle := 'Unfavorable'
        else
            VTCancellationStyle := '';
    end;
}