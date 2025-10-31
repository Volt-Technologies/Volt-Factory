/// <summary>
/// Page VT Alloc Cancel History Card (ID 50121)
/// Displays detailed view of a single allocation cancellation history entry
/// </summary>
page 50121 "VT Alloc Cancel History Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "VT Allocation Cancel History";
    Caption = 'Allocation Cancellation History Card';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number for the cancellation history record.';
                    Importance = Promoted;
                }
                field("Cancellation Date"; Rec."Cancellation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the allocation was cancelled.';
                    Importance = Promoted;
                }
                field("Cancellation Time"; Rec."Cancellation Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the allocation was cancelled.';
                }
                field("Cancelled By User ID"; Rec."Cancelled By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who cancelled the allocation.';
                    Importance = Promoted;
                }
                field("Cancellation Reason Code"; Rec."Cancellation Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code for the cancellation.';
                    Importance = Promoted;
                }
                field("Cancellation Comments"; Rec."Cancellation Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any additional comments for the cancellation.';
                    MultiLine = true;
                }
            }

            group(DocumentInformation)
            {
                Caption = 'Document Information';

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number.';
                    Importance = Promoted;

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
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source type (37 for Sales, 39 for Purchase).';
                    Visible = false;
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source subtype.';
                    Visible = false;
                }
            }

            group(ItemInformation)
            {
                Caption = 'Item Information';

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number that was allocated.';
                    Importance = Promoted;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item variant code.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code for the allocation.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the cancelled quantity.';
                }
            }

            group(QuantityInformation)
            {
                Caption = 'Quantity Information';

                field("Quantity Cancelled"; Rec."Quantity Cancelled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that was cancelled.';
                    Importance = Promoted;
                    Style = Strong;
                }
                field("Quantity Cancelled (Base)"; Rec."Quantity Cancelled (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base quantity that was cancelled.';
                }
            }

            group(TradingPartner)
            {
                Caption = 'Trading Partner';

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
            }

            group(ReservationInformation)
            {
                Caption = 'Reservation Information';

                field("Original Reservation Entry No."; Rec."Original Reservation Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original reservation entry number.';

                    trigger OnDrillDown()
                    var
                        ReservationEntry: Record "Reservation Entry";
                    begin
                        if ReservationEntry.Get(Rec."Original Reservation Entry No.") then
                            Page.Run(Page::"Reservation Entries", ReservationEntry);
                    end;
                }
            }
        }

        area(FactBoxes)
        {
            part(ItemPicture; "Item Picture")
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

            action(ShowReservationEntry)
            {
                ApplicationArea = All;
                Caption = 'Show Original Reservation';
                ToolTip = 'Opens the original reservation entry.';
                Image = ReservationLedger;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReservationEntry: Record "Reservation Entry";
                begin
                    if ReservationEntry.Get(Rec."Original Reservation Entry No.") then
                        Page.Run(Page::"Reservation Entries", ReservationEntry)
                    else
                        Message('The original reservation entry no longer exists.');
                end;
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
}