/// <summary>
/// PageExtension VT Purchase Order Ext (ID 50131)
/// Extends the Purchase Order page to add allocation cancellation functionality
/// </summary>
pageextension 50131 "VT Purchase Order Ext" extends "Purchase Order"
{
    actions
    {
        addafter("F&unctions")
        {
            action("VT Cancel Allocation")
            {
                ApplicationArea = All;
                Caption = 'Cancel Allocation';
                ToolTip = 'Cancel the allocation (reservation) for the selected purchase lines.';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = VTCancelAllocationEnabled;

                trigger OnAction()
                var
                    PurchaseLine: Record "Purchase Line";
                    VTAllocCancelMgt: Codeunit "VT Allocation Cancellation Mgt";
                begin
                    CurrPage.PurchLines.Page.GetRecord(PurchaseLine);
                    PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type");
                    PurchaseLine.SetRange("Document No.", PurchaseLine."Document No.");
                    CurrPage.PurchLines.Page.SetSelectionFilter(PurchaseLine);

                    if PurchaseLine.FindSet() then
                        VTAllocCancelMgt.ProcessPurchaseLineCancellation(PurchaseLine);

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
                RunPageLink = "Source Type" = CONST(39),
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