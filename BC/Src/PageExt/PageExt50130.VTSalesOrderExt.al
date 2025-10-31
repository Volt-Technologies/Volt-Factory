/// <summary>
/// PageExtension VT Sales Order Ext (ID 50130)
/// Extends the Sales Order page to add allocation cancellation functionality
/// </summary>
pageextension 50130 "VT Sales Order Ext" extends "Sales Order"
{
    actions
    {
        addafter("F&unctions")
        {
            action("VT Cancel Allocation")
            {
                ApplicationArea = All;
                Caption = 'Cancel Allocation';
                ToolTip = 'Cancel the allocation (reservation) for the selected sales lines.';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = VTCancelAllocationEnabled;

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                    VTAllocCancelMgt: Codeunit "VT Allocation Cancellation Mgt";
                begin
                    CurrPage.SalesLines.Page.GetRecord(SalesLine);
                    SalesLine.SetRange("Document Type", SalesLine."Document Type");
                    SalesLine.SetRange("Document No.", SalesLine."Document No.");
                    CurrPage.SalesLines.Page.SetSelectionFilter(SalesLine);

                    if SalesLine.FindSet() then
                        VTAllocCancelMgt.ProcessSalesLineCancellation(SalesLine);

                    CurrPage.Update(false);
                end;
            }
            action("VT Allocation History")
            {
                ApplicationArea = All;
                Caption = 'Allocation History';
                ToolTip = 'View the allocation cancellation history for this document.';
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "VT Alloc Cancel History List";
                RunPageLink = "Source Type" = CONST(37),
                            "Document Type" = FIELD("Document Type"),
                            "Document No." = FIELD("No.");
            }
        }
    }

    var
        VTCancelAllocationEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateCancelAllocationEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateCancelAllocationEnabled();
    end;

    local procedure UpdateCancelAllocationEnabled()
    begin
        VTCancelAllocationEnabled := Rec.Status = Rec.Status::Open;
    end;
}