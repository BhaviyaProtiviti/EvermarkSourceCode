pageextension 50110 "SBC Released Prod. Order List" extends "Released Production Orders"
{
    layout
    {
        modify("Location Code")
        {
            visible = true;
        }
        moveafter(Quantity; "Location Code")
        moveafter("Location Code"; "Routing No.")
        moveafter("Source No."; Description)
        moveafter("No."; "Due Date")

        addafter("Routing No.")
        {
            field("SBC Subcontracting Purchase Order"; Rec."SBC Subcontracting Purch.Order")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = false;
                TableRelation = "Purchase Header"."No." where("Document Type" = Filter('Order'));
            }
            // field("SBC Subcontracting Transfer Order"; Rec."SBC Subcontracting Trans.Order")
            // {
            //     ApplicationArea = All;
            //     Visible = true;
            //     Editable = false;
            //     TableRelation = "Transfer Header"."No.";
            // }
        }
    }
    actions
    {
        addbefore("Change &Status")
        {
            group(Subcontracting)
            {
                Caption = 'Subcontracting';
                action("Purchase Order Card")
                {
                    ApplicationArea = Basic, Suite;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Open the Purchase Order Card.';

                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                        PurchaseOrder: Page "Purchase Order";
                    begin
                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."SBC Subcontracting Purch.Order") THEN BEGIN
                            PurchaseHeader.RESET();
                            PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
                            PurchaseHeader.SETRANGE("No.", Rec."SBC Subcontracting Purch.Order");
                            PurchaseOrder.LOOKUPMODE(FALSE);
                            PurchaseOrder.SETTABLEVIEW(PurchaseHeader);
                            PurchaseOrder.RUNMODAL();
                        END;
                    end;
                }
                // action("Transfer Order Card")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Ellipsis = true;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     PromotedIsBig = true;
                //     ToolTip = 'Open the Transfer Order Card.';

                //     trigger OnAction()
                //     var
                //         TransferHeader: Record "Transfer Header";
                //         TransferOrder: Page "Transfer Order";
                //     begin
                //         IF TransferHeader.GET(Rec."SBC Subcontracting Trans.Order") THEN BEGIN
                //             TransferHeader.RESET();
                //             TransferHeader.SETRANGE("No.", Rec."SBC Subcontracting Trans.Order");
                //             TransferOrder.LOOKUPMODE(FALSE);
                //             TransferOrder.SETTABLEVIEW(TransferHeader);
                //             TransferOrder.RUNMODAL();
                //         END;
                //     end;
                // }
            }
        }
        addlast(navigation)
        {
            group(AssocPostedDoc)
            {
                Caption = 'Associated Posted Documents';
                Image = Documents;

                action(SBCPostedInv)
                {
                    Caption = 'Posted Purchase Invoice';
                    ApplicationArea = All;
                    Image = Document;

                    trigger OnAction()
                    var
                        SBCSubcontracting: Codeunit "SBC Subcontracting";
                    begin
                        SBCSubcontracting.GetPostPurchInv(Rec."SBC Original Purch Order No.");
                    end;
                }
                // action(SBCPostedTransRec)
                // {
                //     Caption = 'Posted Transfer Receipt';
                //     ApplicationArea = All;
                //     Image = Document;

                //     trigger OnAction()
                //     var
                //         SBCSubcontracting: Codeunit "SBC Subcontracting";
                //     begin
                //         SBCSubcontracting.GetTransRcpt(Rec."SBC Original Trans. Order No.");
                //     end;
                // }
                // action(SBCPostedTransShip)
                // {
                //     Caption = 'Posted Transfer Shipment';
                //     ApplicationArea = All;
                //     Image = Document;

                //     trigger OnAction()
                //     var
                //         SBCSubcontracting: Codeunit "SBC Subcontracting";
                //     begin
                //         SBCSubcontracting.GetTransShip(Rec."SBC Original Trans. Order No.");
                //     end;
                // }
            }
        }
    }
}