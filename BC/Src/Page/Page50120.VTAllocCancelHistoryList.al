/// <summary>
/// Page VT Alloc Cancel History List (ID 50120)
/// Displays list of all allocation cancellation history entries
/// </summary>
page 50120 "VT Alloc Cancel History List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "VT Allocation Cancel History";
    Caption = 'Allocation Cancellation History';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    CardPageId = "VT Alloc Cancel History Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number for the cancellation history record.';
                }
                field("Cancellation Date"; Rec."Cancellation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the allocation was cancelled.';
                }
                field("Cancellation Time"; Rec."Cancellation Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the allocation was cancelled.';
                    Visible = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number.';

                    trigger OnDrillDown()
                    begin
                        NavigateToDocument();
                    end;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number on the document.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number that was allocated.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code for the allocation.';
                }
                field("Quantity Cancelled"; Rec."Quantity Cancelled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that was cancelled.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the cancelled quantity.';
                    Visible = false;
                }
                field("Customer/Vendor No."; Rec."Customer/Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer or vendor number.';
                }
                field("Customer/Vendor Name"; Rec."Customer/Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer or vendor name.';
                }
                field("Cancelled By User ID"; Rec."Cancelled By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who cancelled the allocation.';
                }
                field("Cancellation Reason Code"; Rec."Cancellation Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code for the cancellation.';
                }
                field("Cancellation Comments"; Rec."Cancellation Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any additional comments for the cancellation.';
                    Visible = false;
                }
                field("Original Reservation Entry No."; Rec."Original Reservation Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original reservation entry number.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(ItemFactBox; "Item Picture")
            {
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("Item No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NavigateDocument)
            {
                ApplicationArea = All;
                Caption = 'Navigate to Document';
                ToolTip = 'Opens the original document where the allocation was cancelled.';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    NavigateToDocument();
                end;
            }
            action(ShowItem)
            {
                ApplicationArea = All;
                Caption = 'Show Item';
                ToolTip = 'Opens the item card for the cancelled allocation.';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                Promoted = true;
                PromotedCategory = Process;
            }
            action(ExportToExcel)
            {
                ApplicationArea = All;
                Caption = 'Export to Excel';
                ToolTip = 'Export the cancellation history to an Excel file.';
                Image = ExportToExcel;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ExportHistoryToExcel();
                end;
            }
        }
        area(Reporting)
        {
            action(CancellationReport)
            {
                ApplicationArea = All;
                Caption = 'Cancellation Report';
                ToolTip = 'Runs the allocation cancellation report.';
                Image = Report;
                // RunObject = Report "VT Allocation Cancel Report";
                Promoted = true;
                PromotedCategory = Report;
            }
        }
    }

    local procedure NavigateToDocument()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        PageManagement: Codeunit "Page Management";
    begin
        case Rec."Source Type" of
            DATABASE::"Sales Line":
                begin
                    if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
                        PageManagement.PageRun(SalesHeader);
                end;
            DATABASE::"Purchase Line":
                begin
                    // Map document type for purchase
                    case Rec."Document Type" of
                        Rec."Document Type"::Order:
                            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Document No.") then
                                PageManagement.PageRun(PurchaseHeader);
                        Rec."Document Type"::Quote:
                            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Quote, Rec."Document No.") then
                                PageManagement.PageRun(PurchaseHeader);
                    end;
                end;
        end;
    end;

    local procedure ExportHistoryToExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        FileName: Text;
    begin
        ExcelBuffer.DeleteAll();

        // Add headers
        ExcelBuffer.AddColumn('Entry No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Cancellation Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Document Type', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Document No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Line No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Item No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Location', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Qty Cancelled', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Cancelled By', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Reason Code', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();

        // Add data
        if Rec.FindSet() then
            repeat
                ExcelBuffer.AddColumn(Rec."Entry No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(Rec."Cancellation Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                ExcelBuffer.AddColumn(Format(Rec."Document Type"), false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(Rec."Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(Rec."Line No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(Rec."Item No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(Rec."Location Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(Rec."Quantity Cancelled", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(Rec."Cancelled By User ID", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.AddColumn(Rec."Cancellation Reason Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                ExcelBuffer.NewRow();
            until Rec.Next() = 0;

        ExcelBuffer.CreateNewBook('Cancellation History');
        ExcelBuffer.WriteSheet('History', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        FileName := 'AllocationCancellationHistory.xlsx';
        ExcelBuffer.OpenExcel();
    end;
}