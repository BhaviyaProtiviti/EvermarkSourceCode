pageextension 50104 "SBC Released Prod. Order" extends "Released Production Order"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("SBC Subcontracting Purchase Order"; Rec."SBC Subcontracting Purch.Order")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = false;
                TableRelation = "Purchase Header"."No." where("Document Type" = Filter('Order'));
            }
            field("SBC Subcontracting Transfer Order"; Rec."SBC Subcontracting Trans.Order")
            {
                ApplicationArea = All;
                // Visible = true;
                Editable = false;
                TableRelation = "Transfer Header"."No.";
            }
            // field("SBC Total Transfer Orders"; Rec."SBC Total Transfer Orders")
            // {
            //     ApplicationArea = All;
            // }
            field("SBC Override Exact Qty."; Rec."SBC Override Exact Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Override Pallet Rounding field.';
            }
        }
        modify(Quantity)
        {
            ToolTip = 'Quantity will automatically be rounded up to the number of Cases that will make a full pallet quantity count for the item.';
        }
    }
    actions
    {
        addafter(RefreshProductionOrder)
        {
            group(Subcontracting)
            {
                Caption = 'Subcontracting';
                action("Create Subcontracting PO & TO")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create Subcontracting Purchase Order';
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    // ToolTip = 'Create a subcontracting Purchase Order and Transfer Order.';
                    ToolTip = 'Create a subcontracting Purchase Order.';
                    trigger OnAction()
                    var
                        CalculateSubContract: Report "SBC Calculate Subcontracts";
                        ReqLine: Record "Requisition Line";
                        MakePurchOrder: Report "Carry Out Action Msg. - Req.";
                        UserSetup: Record "User Setup";
                        PurchaseHeader: Record "Purchase Header";
                        PurchaseOrder: Page "Purchase Order";
                        Text50000: Label 'The Released Production Order is already linked to Subcontracting Purchase Order %1.';
                        Text50001: label 'Subcontracting Purchase Order %1 has been created. Do you want to open it?';
                        // Text50002: Label 'The Released Production Order is already linked to Subcontracting Transfer Order %1.';
                        Text50004: Label 'The Released Production Order has more than one work center %1 and %2.';
                        WorkCenter: Record "Work Center";
                        ProdRtgLine: Record "Prod. Order Routing Line";
                        MfgSetup: Record "Manufacturing Setup";
                    begin
                        IF Rec."SBC Subcontracting Purch.Order" <> '' THEN
                            ERROR(Text50000, Rec."SBC Subcontracting Purch.Order");

                        MfgSetup.Get();
                        MfgSetup.TestField("SBC Default Routing Link");

                        ProdRtgLine.SETRANGE(Status, Rec.Status);
                        ProdRtgLine.SETRANGE("Prod. Order No.", Rec."No.");
                        IF ProdRtgLine.FINDFIRST() THEN
                            WorkCenter.get(ProdRtgLine."Work Center No.");
                        IF ProdRtgLine.FINDSET() THEN
                            REPEAT
                                IF ProdRtgLine."Work Center No." <> WorkCenter."No." THEN
                                    ERROR(Text50004, WorkCenter."No.", ProdRtgLine."Work Center No.");
                            UNTIL ProdRtgLine.NEXT() = 0;

                        if WorkCenter."Subcontractor No." <> '' then begin
                            ProdRtgLine."Routing Link Code" := MfgSetup."SBC Default Routing Link";
                            ProdRtgLine.Modify(false);
                        end;

                        UserSetup.GET(USERID);
                        UserSetup.TESTFIELD("SBC Subcontracting Batch");
                        ReqLine.INIT();
                        ReqLine."Worksheet Template Name" := 'FOR. LABOR';
                        ReqLine."Journal Batch Name" := UserSetup."SBC Subcontracting Batch";
                        ReqLine."Line No." := 10000;
                        ReqLine.INSERT();
                        CalculateSubContract.SetProdOrder(Rec."No.");
                        CalculateSubContract.USEREQUESTPAGE(FALSE);
                        CalculateSubContract.SetWkShLine(ReqLine);
                        CalculateSubContract.RUNMODAL();

                        MakePurchOrder.USEREQUESTPAGE(FALSE);
                        MakePurchOrder.SetReqWkshLine(ReqLine);
                        MakePurchOrder.RUNMODAL();
                        CLEAR(MakePurchOrder);

                        Rec.GET(Rec.Status, Rec."No.");
                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."SBC Subcontracting Purch.Order") THEN BEGIN
                            if WorkCenter."SBC Vendor Location" <> '' then begin
                                // CreateTransferOrders(WorkCenter."SBC Vendor Location");
                                // PurchaseHeader."SBC Transfer Order No." := Rec."SBC Subcontracting Trans.Order";
                                // PurchaseHeader.MODIFY();
                                // COMMIT();
                                PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."SBC Subcontracting Purch.Order");
                            end;
                            IF CONFIRM(Text50001, FALSE, Rec."SBC Subcontracting Purch.Order") THEN BEGIN
                                PurchaseHeader.RESET();
                                PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
                                PurchaseHeader.SETRANGE("No.", Rec."SBC Subcontracting Purch.Order");
                                PurchaseOrder.LOOKUPMODE(FALSE);
                                PurchaseOrder.SETTABLEVIEW(PurchaseHeader);
                                PurchaseOrder.RUNMODAL();
                            END;
                        END;
                    end;
                }
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
                action("Transfer Order")
                {
                    ApplicationArea = Basic, Suite;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Open Transfer Order'; 

                    trigger OnAction()
                    var
                        TransferHeader: Record "Transfer Header";
                        TransferOrder: Page "Transfer Order";
                    begin
                        TransferHeader.Get(Rec."SBC Subcontracting Trans.Order");
                        Page.RunModal(Page::"Transfer Order", TransferHeader);
                    end;
                }
            }
        }
        addlast("O&rder")
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

    local procedure CreateTransferOrders(TransferTo: Code[10])
    var
        TransferFrom: Code[10];
        ProdOrderLine: Record "Prod. Order Line";
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
    begin
        TransferFrom := '';
        ProdOrderLine.RESET();
        ProdOrderLine.SETRANGE(Status, Rec.Status);
        ProdOrderLine.SETRANGE("Prod. Order No.", Rec."No.");
        ProdOrderLine.SETFILTER("Item No.", '<>%1', '');
        IF ProdOrderLine.FINDSET() THEN
            REPEAT
                IF (ProdOrderLine."Location Code" <> TransferTo) AND (TransferFrom <> ProdOrderLine."Location Code") THEN BEGIN
                    TransferHeader.INIT();
                    TransferHeader."No." := '';
                    TransferHeader.INSERT(TRUE);
                    TransferHeader.VALIDATE("Transfer-from Code", ProdOrderLine."Location Code");
                    TransferHeader.VALIDATE("Transfer-to Code", TransferTo);
                    Location.SETRANGE("Use As In-Transit", TRUE);
                    Location.FINDLAST();
                    TransferHeader.VALIDATE("In-Transit Code", Location.Code);
                    TransferHeader.VALIDATE("SBC Production Order No.", Rec."No.");
                    TransferHeader.MODIFY();
                    Rec."SBC Subcontracting Trans.Order" := TransferHeader."No.";
                    Rec.MODIFY();
                    CreateTransferLine(TransferHeader, ProdOrderLine);
                END ELSE BEGIN
                    CreateTransferLine(TransferHeader, ProdOrderLine);
                END;
                TransferFrom := ProdOrderLine."Location Code";
            UNTIL ProdOrderLine.NEXT() = 0;

        OnAfterCreateTransferOrders(TransferHeader);
    end;

    local procedure CreateTransferLine(TransferHeader: Record "Transfer Header"; ProdOrderLine: Record "Prod. Order Line")
    var
        ProdComponent: Record "Prod. Order Component";
        TransferLine: Record "Transfer Line";
        LineNo: Integer;
        MfgSetup: Record "Manufacturing Setup";
        ProdComponent2: Record "Prod. Order Component";
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        RemainingQuantity: Decimal;
    begin
        MfgSetup.Get();

        ProdComponent.SETRANGE(Status, ProdOrderLine.Status);
        ProdComponent.SETRANGE("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdComponent.SETRANGE("Prod. Order Line No.", ProdOrderLine."Line No.");
        ProdComponent.SETFILTER("Item No.", '<>%1', '');
        IF ProdComponent.FINDSET() THEN
            REPEAT
                // Item.get(ProdComponent."Item No.");
                // ItemUOM.get(ProdComponent."Item No.", Item."Sales Unit of Measure");
                // RemainingQuantity := Round(ProdComponent."Remaining Quantity" / Itemuom."Qty. per Unit of Measure", 1, '>');
                TransferLine.RESET();
                TransferLine.SETRANGE("Document No.", TransferHeader."No.");
                TransferLine.SETRANGE("Item No.", ProdComponent."Item No.");
                TransferLine.SETRANGE("Variant Code", ProdComponent."Variant Code");
                IF TransferLine.FINDFIRST() THEN BEGIN
                    // TransferLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure");
                    // TransferLine.VALIDATE(Quantity, TransferLine.Quantity + RemainingQuantity);
                    TransferLine.Validate("Unit of Measure Code", ProdComponent."Unit of Measure Code");
                    TransferLine.Validate(Quantity, TransferLine.Quantity + ProdComponent."Remaining Quantity");
                    TransferLine.MODIFY();
                END ELSE BEGIN
                    TransferLine.SETRANGE("Item No.");
                    TransferLine.SETRANGE("Variant Code");
                    IF TransferLine.FINDLAST() THEN
                        LineNo := TransferLine."Line No." + 10000
                    ELSE
                        LineNo := 10000;

                    TransferLine.INIT();
                    TransferLine."Document No." := TransferHeader."No.";
                    TransferLine."Line No." := LineNo;
                    TransferLine."SBC Override Exact Qty." := ProdOrderLine."SBC Override Exact Qty.";
                    TransferLine.INSERT(TRUE);

                    TransferLine.VALIDATE("Item No.", ProdComponent."Item No.");
                    TransferLine.VALIDATE("Variant Code", ProdComponent."Variant Code");
                    // TransferLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure");
                    // TransferLine.VALIDATE(Quantity, RemainingQuantity);
                    TransferLine.Validate("Unit of Measure Code", ProdComponent."Unit of Measure Code");
                    TransferLine.Validate(Quantity, ProdComponent."Remaining Quantity");
                    TransferLine.MODIFY();
                END;

                ProdComponent2.get(ProdComponent.Status, ProdComponent."Prod. Order No.", ProdComponent."Prod. Order Line No.", ProdComponent."Line No.");
                ProdComponent2."Routing Link Code" := MfgSetup."SBC Default Routing Link";
                ProdComponent2."Location Code" := TransferHeader."Transfer-to Code";
                ProdComponent2."Flushing Method" := ProdComponent2."Flushing Method"::Manual;
                ProdComponent2.modify(false);
            UNTIL ProdComponent.NEXT() = 0;
    end;

    #region eventIntegration 

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransferOrders(TransferHeader: Record "Transfer Header")
    begin
    end;

    #endregion eventIntegration
}