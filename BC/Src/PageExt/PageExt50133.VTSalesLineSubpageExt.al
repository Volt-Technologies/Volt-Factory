/// <summary>
/// PageExtension VT Sales Line Subpage Ext (ID 50133)
/// Extends the Sales Order Subform to show allocation cancellation status
/// </summary>
pageextension 50133 "VT Sales Line Subpage Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter("Reserved Quantity")
        {
            field("VT Allocation Status"; Rec."VT Allocation Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the allocation status (Active or Cancelled).';
                StyleExpr = VTAllocationStatusStyle;
                Editable = false;
            }
        }
    }

    var
        VTAllocationStatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetAllocationStatusStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetAllocationStatusStyle();
    end;

    local procedure SetAllocationStatusStyle()
    begin
        if Rec."VT Allocation Status" = Rec."VT Allocation Status"::Cancelled then
            VTAllocationStatusStyle := 'Subordinate'
        else
            VTAllocationStatusStyle := '';
    end;
}