codeunit 50102 "SBC Subcontracting"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", OnAfterInsertPurchOrderHeader, '', false, false)]
    local procedure SBC_OnAfterInsertPurchOrderHeader(var RequisitionLine: Record "Requisition Line"; var PurchaseOrderHeader: Record "Purchase Header"; SpecialOrder: Boolean; CommitIsSuppressed: Boolean)
    var
        ProdOrder: Record "Production Order";
    begin
        IF ProdOrder.GET(ProdOrder.Status::Released, RequisitionLine."Prod. Order No.") THEN BEGIN
            ProdOrder."SBC Subcontracting Purch.Order" := PurchaseOrderHeader."No.";
            ProdOrder.MODIFY();
            PurchaseOrderHeader."SBC Production Order No." := RequisitionLine."Prod. Order No.";
            PurchaseOrderHeader."Requested Receipt Date" := RequisitionLine."Due Date";
            PurchaseOrderHeader."Expected Receipt Date" := RequisitionLine."Due Date";
        END;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SBC_OnAfterDeletePurchaseHeader(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.SETRANGE(Status, ProdOrder.Status::Released);
        ProdOrder.SETRANGE("SBC Subcontracting Purch.Order", Rec."No.");
        IF ProdOrder.FINDFIRST() THEN BEGIN
            ProdOrder."SBC Subcontracting Purch.Order" := '';
            ProdOrder.MODIFY();
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SBC_OnAfterDeleteTransferHeader(var Rec: Record "Transfer Header"; RunTrigger: Boolean)
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.SETRANGE(Status, ProdOrder.Status::Released);
        ProdOrder.SETRANGE("SBC Subcontracting Trans.Order", Rec."No.");
        IF ProdOrder.FINDFIRST() THEN BEGIN
            ProdOrder."SBC Subcontracting Trans.Order" := '';
            ProdOrder.MODIFY();
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production Order", OnAfterInsertEvent, '', false, false)]
    local procedure SBC_OnAfterInsertProdOrdere(var Rec: Record "Production Order"; RunTrigger: Boolean)
    var
        MfgSetup: Record "Manufacturing Setup";
    begin
        MfgSetup.Get();
        if (Rec."Location Code" = '') and (MfgSetup."SBC Default Location" <> '') then begin
            Rec."Location Code" := MfgSetup."SBC Default Location";
            Rec.modify(false);
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure SBC_OnAfterValidateEventProdOrderQty(var xRec: Record "Production Order"; var Rec: Record "Production Order"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemUOMPLT: Record "Item Unit of Measure";
        ItemUOMCS: Record "Item Unit of Measure";
        InvSetup: Record "Inventory Setup";
        OrigQtyCS: Decimal;
        NbPallets: Integer;
        NewQtyCS: Decimal;
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        PurchLine: Record "Purchase Line";
    begin
        if (Rec."Source Type" = Rec."Source Type"::Item) and (CurrFieldNo = 40) then begin
            if Rec."SBC Override Exact Qty." then begin
                if xRec.Quantity = 0 then
                    exit;
                OrigQtyCS := xRec.Quantity;
                NewQtyCS := Rec.Quantity;
            end else begin
                InvSetup.Get();
                InvSetup.TestField("SBC Pallet Unit of Measure");
                Item.Get(Rec."Source No.");
                ItemUOMCS.get(Rec."Source No.", Item."Sales Unit of Measure");
                ItemUOMPLT.Get(Rec."Source No.", InvSetup."SBC Pallet Unit of Measure");
                OrigQtyCS := Rec.Quantity;
                NbPallets := round(OrigQtyCS * ItemUOMCS."Qty. per Unit of Measure" / ItemUOMPLT."Qty. per Unit of Measure", 1, '>');
                NewQtyCS := round(NbPallets * ItemUOMPLT."Qty. per Unit of Measure" / ItemUOMCS."Qty. per Unit of Measure", 1, '>');
            end;

            if NewQtyCS <> OrigQtyCS then begin
                Rec.Quantity := NewQtyCS;

                ProdOrderLine.SetRange(Status, Rec.Status);
                ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
                if ProdOrderLine.findfirst() then begin
                    ProdOrderLine."SBC Override Exact Qty." := Rec."SBC Override Exact Qty.";
                    ProdOrderLine.Validate(Quantity, NewQtyCS);
                    ProdOrderLine.modify(false);

                    ProdOrderComp.SetRange(Status, Rec.Status);
                    ProdOrderComp.SetRange("Prod. Order No.", Rec."No.");
                    ProdOrderComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                    ProdOrderComp.SetFilter("Item No.", '<>%1', '');
                    if ProdOrdercomp.findset() then
                        repeat
                            ProdOrderComp.Validate("Quantity per");
                            ProdOrderComp.modify(false);
                        until ProdOrderComp.Next() = 0;

                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                    PurchLine.SetRange("Document No.", Rec."SBC Subcontracting Purch.Order");
                    PurchLine.SetRange("Prod. Order No.", Rec."No.");
                    PurchLine.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                    if PurchLine.findfirst() then begin
                        PurchLine.Validate(Quantity, NewQtyCS);
                        PurchLine.UpdateAmounts();
                        PurchLine.UpdatePrePaymentAmounts();
                        PurchLine.modify(false);
                    end;
                end;
            end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Prod. Order Lines", OnInitProdOrderLineAfterVariantCode, '', false, false)]
    local procedure SBC_OnInitProdOrderLineAfterVariantCode(var ProdOrderLine: Record "Prod. Order Line"; VariantCode: Code[10])
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        OnBeforeProdOrderLineValidateUnitofMeasureCodeOnInitProdOrderLineAfterVariantCode(ProdOrderLine, VariantCode, IsHandled);
        if IsHandled then
            exit;

        Item.get(ProdOrderLine."Item No.");
        ProdOrderLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Prod. Order Lines", 'OnBeforeProdOrderLineInsert', '', false, false)]
    local procedure CreateProdOrderLinesOnBeforeProdOrderLineInsert(var ProductionOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var SalesLine: Record "Sales Line"; SalesLineIsSet: Boolean)
    begin
        ProdOrderLine."SBC Override Exact Qty." := ProductionOrder."SBC Override Exact Qty.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", OnAfterCopyFromItem, '', false, false)]
    local procedure SBC_ProdOrderLine_OnAfterCopyFromItem(var xProdOrderLine: Record "Prod. Order Line"; var ProdOrderLine: Record "Prod. Order Line"; Item: Record Item; CurrentFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        OnBeforeProdOrderLineValidateUnitofMeasureCodeOnAfterCopyFromItem(ProdOrderLine, xProdOrderLine, CurrentFieldNo, IsHandled);
        if IsHandled then
            exit;

        ProdOrderLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnValidateItemNoOnCopyFromTempTransLine', '', false, false)]
    local procedure TransferLineOnValidateItemNoOnCopyFromTempTransLine(TempTransferLine: Record "Transfer Line" temporary; var TransferLine: Record "Transfer Line")
    begin
        TransferLine."SBC Override Exact Qty." := TempTransferLine."SBC Override Exact Qty.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnAfterValidateEvent, Quantity, false, false)]
    local procedure SBC_OnAfterValidateEventTransferLineQty(var xRec: Record "Transfer Line"; var Rec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemUOMPLT: Record "Item Unit of Measure";
        ItemUOMCS: Record "Item Unit of Measure";
        InvSetup: Record "Inventory Setup";
        OrigQtyCS: Decimal;
        NbPallets: Integer;
        NewQtyCS: Decimal;
    begin
        //if CurrFieldNo = 4 then begin
        if Rec."SBC Override Exact Qty." then
            exit;

        InvSetup.Get();
        InvSetup.TestField("SBC Pallet Unit of Measure");
        Item.Get(Rec."Item No.");
        ItemUOMCS.get(Rec."Item No.", Item."Sales Unit of Measure");
        ItemUOMPLT.Get(Rec."Item No.", InvSetup."SBC Pallet Unit of Measure");
        OrigQtyCS := Rec.Quantity;
        NbPallets := round(OrigQtyCS * ItemUOMCS."Qty. per Unit of Measure" / ItemUOMPLT."Qty. per Unit of Measure", 1, '>');
        NewQtyCS := round(NbPallets * ItemUOMPLT."Qty. per Unit of Measure" / ItemUOMCS."Qty. per Unit of Measure", 1, '>');
        if NewQtyCS <> OrigQtyCS then
            Rec.validate(Quantity, NewQtyCS);
        //end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnAfterAssignItemValues, '', false, false)]
    local procedure MyProcedure(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; Item: Record Item)
    begin
        TransferLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure");
    end;

    /* [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnValidateQtyToReceiveOnAfterCheckQty, '', false, false)]
    local procedure SBC_POLine_OnValidateQtyToReceiveOnAfterCheckQty(var PurchaseLine: Record "Purchase Line"; CurrFieldNo: Integer);
    var
        ProdOrderLine: Record "Prod. Order Line";
        ReservEntry: Record "Reservation Entry";
        ReservEntry2: Record "Reservation Entry";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if (CurrFieldNo = 18) and (PurchaseLine."Prod. Order No." <> '') then
            if ProdOrderLine.get(ProdOrderLine.Status::Released, PurchaseLine."Prod. Order No.", PurchaseLine."Prod. Order Line No.") then begin
                if Item.get(PurchaseLine."No.") and (ItemTrackingCode.get(Item."Item Tracking Code")) and (ItemTrackingCode."Lot Specific Tracking") then begin
                    ReservEntry.SetRange("Source ID", ProdOrderLine."Prod. Order No.");
                    ReservEntry.SetRange("Source Type", 5406);
                    ReservEntry.SetRange("Source Subtype", 3);
                    ReservEntry.SetRange("Source Prod. Order Line", ProdOrderLine."Line No.");
                    ReservEntry.SetFilter("Reservation Status", '%1|%2', ReservEntry."Reservation Status"::Prospect, ReservEntry."Reservation Status"::Surplus);
                    if ReservEntry.findset then
                        repeat
                            ReservEntry.delete(false);
                        until ReservEntry.next = 0;

                    ReservEntry.reset;
                    ReservEntry.SetRange("Source ID");
                    ReservEntry.SetRange("Source Type");
                    ReservEntry.SetRange("Source Subtype");
                    ReservEntry.SetRange("Source Prod. Order Line");
                    ReservEntry.SetRange("Reservation Status");
                    ReservEntry.SetFilter("Entry No.", '>%1', 0);
                    ReservEntry.FindLast();

                    ReservEntry2.Init();
                    ReservEntry2."Entry No." := ReservEntry."Entry No." + 1;
                    ReservEntry2.Positive := true;
                    ReservEntry2.insert(false);
                    ReservEntry2."Item No." := ProdOrderLine."Item No.";
                    ReservEntry2."Variant Code" := ProdOrderLine."Variant Code";
                    ReservEntry2."Location Code" := ProdOrderLine."Location Code";
                    ReservEntry2."Quantity (Base)" := PurchaseLine."Qty. to Receive" * ProdOrderLine."Qty. per Unit of Measure";
                    ReservEntry2."Reservation Status" := ReservEntry2."Reservation Status"::Prospect;
                    ReservEntry2."Creation Date" := today;
                    ReservEntry2."Created By" := UserId;
                    ReservEntry2."Source Type" := 5406;
                    ReservEntry2."Source Subtype" := 3;
                    ReservEntry2."Source ID" := ProdOrderLine."Prod. Order No.";
                    ReservEntry2."Source Prod. Order Line" := ProdOrderLine."Line No.";
                    ReservEntry2."Expected Receipt Date" := PurchaseLine."Expected Receipt Date";
                    ReservEntry2."Qty. per Unit of Measure" := ProdOrderLine."Qty. per Unit of Measure";
                    ReservEntry2.Quantity := PurchaseLine."Qty. to Receive";
                    ReservEntry2."Qty. to Handle (Base)" := PurchaseLine."Qty. to Receive" * ProdOrderLine."Qty. per Unit of Measure";
                    ReservEntry2."Qty. to Invoice (Base)" := PurchaseLine."Qty. to Receive" * ProdOrderLine."Qty. per Unit of Measure";
                    ReservEntry2."Item Tracking" := ReservEntry2."Item Tracking"::"Lot No.";
                    ReservEntry2."Lot No." := 'TEST_LOT_123';
                    ReservEntry2.modify(false);
                end;
            end;
    end; */

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", OnAfterValidateEvent, "SBC Purchase Order No.", false, false)]
    local procedure SBC_OnAfterValidateEventPurchOrdNo(var xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        PurchLine: Record "Purchase Line";
    begin
        if Rec."Order No." = '' then begin
            PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
            PurchLine.SetRange("Document No.", Rec."SBC Purchase Order No.");
            PurchLine.SetFilter("Prod. Order No.", '<>%1', '');
            if PurchLine.FindFirst() then begin
                Rec.Validate("Order No.", PurchLine."Prod. Order No.");
                Rec.Validate("Order Line No.", PurchLine."Prod. Order Line No.");
                Rec.Modify(false);
            end;
        end
    end;

    [EventSubscriber(ObjectType::Page, Page::"Consumption Journal", OnAfterValidateEvent, "Lot No.", false, false)]
    local procedure SBC_OnAfterValidateConsItemJOurnalLotNoe(var xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    begin
        if (Rec."Order Type" = Rec."Order Type"::Production) and (Rec."Journal Template Name" = 'CONSUMPTIO') then begin
            if Rec."Lot No." <> '' then begin
                CreateItemTrackingLines(Rec, true);
            end;
        end
    end;

    internal procedure CreateItemTrackingLines(var Rec: Record "Item Journal Line"; UpdateTracking: Boolean)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Copy(Rec);
        ItemJnlLineReserve.CreateItemTracking(ItemJournalLine);
        if UpdateTracking then
            UpdateItemTracking(ItemJournalLine);
    end;

    internal procedure UpdateItemTracking(var ItemJournalLine: Record "Item Journal Line")
    var
        TempItemJournalLine: Record "Item Journal Line" temporary;
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        SingleItemTrackingExists: Boolean;
    begin
        ItemJournalLine.Find();
        TempItemJournalLine := ItemJournalLine;

        if GetItemTracking(TempTrackingSpecification, ItemJournalLine) then
            if TempTrackingSpecification.Count() = 1 then begin
                SingleItemTrackingExists := true;
                ItemJournalLine.CopyTrackingFromSpec(TempTrackingSpecification);
                ItemJournalLine."Expiration Date" := TempTrackingSpecification."Expiration Date";
                ItemJournalLine."Warranty Date" := TempTrackingSpecification."Warranty Date";
            end;

        if not SingleItemTrackingExists then begin
            ItemJournalLine.ClearTracking();
            ItemJournalLine.ClearDates();
        end;

        if not ItemJournalLine.HasSameTracking(TempItemJournalLine) then
            ItemJournalLine.Modify();
    end;

    internal procedure GetItemTracking(var TempTrackingSpecification: Record "Tracking Specification" temporary; var Rec: Record "Item Journal Line"): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
    begin
        Rec.SetReservationFilters(ReservationEntry);
        ReservationEntry.ClearTrackingFilter();
        exit(ItemTrackingManagement.SumUpItemTracking(ReservationEntry, TempTrackingSpecification, false, true));
    end;

    var
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";

    #region postedSubcontractedDocs

    procedure GetPostPurchInv(OrderNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if OrderNo = '' then
            exit;
        PurchInvHeader.SetRange("Order No.", OrderNo);
        Page.RunModal(Page::"Posted Purchase Invoices", PurchInvHeader);
    end;

    procedure GetTransRcpt(OrderNo: Code[20])
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        if OrderNo = '' then
            exit;
        TransferReceiptHeader.SetRange("Transfer Order No.", OrderNo);
        Page.RunModal(Page::"Posted Transfer Receipts", TransferReceiptHeader);
    end;

    procedure GetTransShip(OrderNo: Code[20])
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        if OrderNo = '' then
            exit;
        TransferShipmentHeader.SetRange("Transfer Order No.", OrderNo);
        Page.RunModal(Page::"Posted Transfer Shipments", TransferShipmentHeader);
    end;

    #endregion postedSubcontractedDocs

    #region purchLineUpdate

    procedure UpdateReleasedProdOrder(OrderNo: Code[20]; ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; NewUOM: Code[10])
    var
        ProdOrderLine: Record "Prod. Order Line";
        ConfirmLbl: label 'Order %1 is created from Released Production Order %2. \ Would you like to update the RPO unit of measure from %3 to %4?', comment = '%1 = Purchase Order No., %2 = Production Order No., %3 = Original UOM, %4 = New UOM';
    begin
        if (ProdOrderLine.Get(ProdOrderLine.Status::Released, ProdOrderNo, ProdOrderLineNo)) and (ProdOrderLine."Unit of Measure Code" <> NewUOM) then
            if Confirm(StrSubstNo(ConfirmLbl, OrderNo, ProdOrderNo, ProdOrderLine."Unit of Measure Code", NewUOM)) then begin
                ProdOrderLine.validate("Unit of Measure Code", NewUOM);
                ProdOrderLine.Modify();
            end;
    end;

    #endregion purchLineUpdate


    procedure UpdateLineWeight(TransferDocNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransferDocNo);
        if TransferLine.FindSet() then
            repeat
                SetTransferLineWeight(TransferLine);
                TransferLine.Modify(false);
            until TransferLine.Next() = 0;
    end;

    procedure SetTransferLineWeight(var TransferLine: Record "Transfer Line")
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        PalletItemUOM: Record "Item Unit of Measure";
        NoQtyPerPL: Decimal;
    begin
        Clear(TransferLine."SBC Line Weight");
        Clear(TransferLine."SBC Line Cubage UOM");
        Clear(TransferLine."SBC Line Cubage");
        Clear(TransferLine."SBC Line Pallet");
        if TransferLine.Quantity <> 0 then
            if ItemUnitofMeasure.Get(TransferLine."Item No.", TransferLine."Unit of Measure Code") then begin
                if ItemUnitofMeasure.Weight = 0 then
                    ItemUnitofMeasure.Weight := (TransferLine.Quantity * TransferLine."Gross Weight")
                else
                    TransferLine."SBC Line Weight" := (TransferLine.Quantity * ItemUnitofMeasure.Weight);
                TransferLine."SBC Line Weight UOM" := ItemUnitofMeasure.Weight;
                TransferLine."SBC Line Cubage UOM" := ItemUnitofMeasure.Cubage;
                TransferLine."SBC Line Cubage" := (TransferLine.Quantity * ItemUnitofMeasure.Cubage);
                if (PalletItemUOM.Get(TransferLine."Item No.", 'PAL')) and ((PalletItemUOM."Qty. per Unit of Measure" <> 0) and (ItemUnitofMeasure."Qty. per Unit of Measure" <> 0)) then begin
                    NoQtyPerPL := (PalletItemUOM."Qty. per Unit of Measure" / ItemUnitofMeasure."Qty. per Unit of Measure");
                    TransferLine."SBC Line Pallet" := Round((TransferLine.Quantity / NoQtyPerPL), 0.1, '>');
                    TransferLine."SBC Line Pallet UOM" := NoQtyPerPL;
                end;
            end;
    end;

    //calculate total weight, total # of pallets, total cubage
    //if total cubage > max cubage, split transfer order
    //if total # of pallets > max # of pallets, split transfer order
    //if total weight > max weight, split transfer order

    procedure SplitTransferOrder(TransferHeader: Record "Transfer Header")
    var
        // TransferLine: Record "Transfer Line";
        MaxAllowWeight: Decimal;
        MaxAllowCubage: Decimal;
        TotalWeight: Decimal;
        TotalCubage: Decimal;
        MaxAllowPallets: Decimal;
        TotalPallets: Decimal;
        SplitTransOrders: list of [Code[20]];
    begin
        //calculate total weight, total # of pallets, total cubage
        GetLocationMaxReq(TransferHeader."Transfer-from Code", TransferHeader."Shortcut Dimension 1 Code", MaxAllowWeight, MaxAllowCubage, MaxAllowPallets);
        if (MaxAllowWeight = 0) and (MaxAllowCubage = 0) and (MaxAllowPallets = 0) then
            exit;

        GetOrderTotals(TransferHeader."No.", TotalWeight, TotalCubage, TotalPallets);
        if (TotalWeight <= MaxAllowWeight) and (TotalCubage <= MaxAllowCubage) and (TotalPallets <= MaxAllowPallets) then
            exit;

        SplitTransOrders.Add(TransferHeader."No.");
        SplitTransfer(SplitTransOrders, TransferHeader, MaxAllowCubage, MaxAllowPallets, MaxAllowWeight);
    end;

    local procedure SplitTransfer(var SplitTransOrders: list of [Code[20]]; TransferHeader: Record "Transfer Header"; MaxAllowCubage: Decimal; MaxAllowPallets: Decimal; MaxAllowWeight: Decimal)
    var
        TransferLine: Record "Transfer Line";
        MaxQtyPerLine: Decimal;
        TotalCubage: Decimal;
        TotalPallets: Decimal;
        TotalWeight: Decimal;
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.FindSet(true) then begin
            repeat
                MaxQtyPerLine := GetMaxQtyPerLine(TransferLine, MaxAllowCubage, MaxAllowPallets, MaxAllowWeight);
                if transferline.Quantity > MaxQtyPerLine then begin
                    splitlines(SplitTransOrders, TransferLine, TransferHeader, MaxQtyPerLine, false);
                    TransferLine.Validate(Quantity);
                    TransferLine.Modify(true);
                end;
                CalcOrigOrderTotals(SplitTransOrders, TotalWeight, TotalCubage, TotalPallets, MaxAllowCubage, MaxAllowPallets, MaxAllowWeight, TransferHeader."No.", TransferLine."Line No.");
            until TransferLine.Next() = 0;
            DeleteBlankLines(TransferHeader."No.");
        end;
    end;

    local procedure DeleteBlankLines(OrderNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", OrderNo);
        TransferLine.SetRange(Quantity, 0);
        TransferLine.DeleteAll();
    end;

    local procedure CalcOrigOrderTotals(var SplitTransOrders: list of [Code[20]]; var TotalWeight: Decimal; var TotalCubage: Decimal; var TotalPallets: Decimal; MaxAllowCubage: Decimal; MaxAllowPallets: Decimal; MaxAllowWeight: Decimal; OrderNo: Code[20]; LineNo: Integer)
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        CreateNewOrder: Boolean;
    begin
        if TransferLine.Get(OrderNo, LineNo) then begin
            TransferHeader.Get(TransferLine."Document No.");
            case true of
                ((TransferLine."SBC Line Weight" + TotalWeight) > MaxAllowWeight):
                    CreateNewOrder := true;
                ((TransferLine."SBC Line Cubage" + TotalCubage) > MaxAllowCubage):
                    CreateNewOrder := true;
                ((TransferLine."SBC Line Pallet" + TotalPallets) > MaxAllowPallets):
                    CreateNewOrder := true;
            end;
            if CreateNewOrder then
                Splitlines(SplitTransOrders, TransferLine, TransferHeader, TransferLine.Quantity, true)
            else begin
                TotalWeight += TransferLine."SBC Line Weight";
                TotalCubage += TransferLine."SBC Line Cubage";
                TotalPallets += TransferLine."SBC Line Pallet";
            end;
        end;
    end;

    local procedure GetMaxQtyPerLine(TransferLine: Record "Transfer Line"; MaxAllowCubage: Decimal; MaxAllowPallets: Decimal; MaxAllowWeight: Decimal): Decimal
    var
        MaxQtyPerCubage: Decimal;
        MaxQtyPerWeight: Decimal;
        MaxQtyPerMaxPallet: Decimal;
        MaxQtyPerLine: Decimal;
    begin
        if (MaxAllowCubage <> 0) and (TransferLine."SBC Line Cubage UOM" <> 0) then
            MaxQtyPerCubage := round((MaxAllowCubage / TransferLine."SBC Line Cubage UOM"), 1, '<'); //Line Cubage UOM equals cubage per UOM on line
        if (MaxAllowPallets <> 0) and (TransferLine."SBC Line Pallet UOM" <> 0) then
            MaxQtyPerMaxPallet := ((TransferLine."SBC Line Pallet UOM" * MaxAllowPallets)); //Line Pallet UOM equals total # of UOM on line in a pallet * allowed number of pallets = max qty per line
        if (MaxAllowWeight <> 0) and (TransferLine."SBC Line Weight UOM" <> 0) then
            MaxQtyPerWeight := round((MaxAllowWeight / TransferLine."SBC Line Weight UOM"), 1, '<'); //Line Weight UOM equals weight per UOM on the line

        if (MaxQtyPerCubage <> 0) then
            MaxQtyPerLine := MaxQtyPerCubage;

        if (MaxQtyPerMaxPallet <> 0) and ((MaxQtyPerMaxPallet < MaxQtyPerLine) or (MaxQtyPerLine = 0)) then
            MaxQtyPerLine := TransferLine."SBC Line Pallet UOM";

        if (MaxQtyPerWeight <> 0) and ((MaxQtyPerWeight < MaxQtyPerLine) or (MaxQtyPerLine = 0)) then
            MaxQtyPerLine := MaxQtyPerWeight;

        if TransferLine.Quantity < MaxQtyPerLine then
            MaxQtyPerLine := TransferLine.Quantity;
        exit(maxQtyPerLine);
    end;

    local procedure SplitLines(var SplitTransOrders: list of [Code[20]]; var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; MaxQtyPerLine: Decimal; TransferEntireLine: Boolean)
    var
        NewOrders: Integer;
        i: Integer;
    begin
        if TransferEntireLine then
            NewOrders := 1
        else
            NewOrders := Round((TransferLine.Quantity / MaxQtyPerLine), 1, '<');

        for i := 1 to NewOrders do begin
            CreateNewLine(SplitTransOrders, TransferHeader, TransferLine, MaxQtyPerLine);
            TransferLine.Quantity -= MaxQtyPerLine;
        end;
    end;

    local procedure CreateNewLine(var SplitTransOrders: list of [Code[20]]; TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line"; NewLineQty: Decimal): Boolean
    var
        NewTransferHeader: Record "Transfer Header";
        NewTransferLine: Record "Transfer Line";
    begin
        CreateSplitTransferHdr(NewTransferHeader, TransferHeader, SplitTransOrders);
        NewTransferLine.Init();
        NewTransferLine.TransferFields(TransferLine, false);
        NewTransferLine."Document No." := NewTransferHeader."No.";
        NewTransferLine."Line No." := 10000;
        NewTransferLine.Validate(Quantity, NewLineQty);
        NewTransferLine.Insert(true);
        NewTransferHeader.Validate(Status, NewTransferHeader.Status::Released);
        NewTransferHeader.Modify(true);
    end;

    local procedure CreateSplitTransferHdr(var NewTransferHeader: Record "Transfer Header"; OrigTransferHeader: Record "Transfer Header"; var SplitTransOrders: list of [Code[20]])
    var
        NewTransOrderNo: Code[20];
        NoNewOrder: Integer;
    begin
        NoNewOrder := SplitTransOrders.Count();
        if NoNewOrder < 10 then
            NewTransOrderNo := OrigTransferHeader."No." + '-0' + Format(NoNewOrder)
        else
            NewTransOrderNo := OrigTransferHeader."No." + '-' + Format(NoNewOrder);
        SplitTransOrders.Add(NewTransOrderNo);

        NewTransferHeader.Init();
        NewTransferHeader."No." := NewTransOrderNo;
        NewTransferHeader.TransferFields(OrigTransferHeader, false);
        NewTransferHeader.Insert(true);
    end;

    local procedure GetLocationMaxReq(LocationCode: Code[20]; Brand: Code[20]; var MaxAllowWeight: Decimal; var MaxAllowCubage: Decimal; var MaxAllowPallets: Decimal)
    var
        Location: Record Location;
        BrandCapacitybyLocation: Record "SBC Brand Capacity by Location";
    begin
        if (Location.Get(LocationCode)) and (Location."SBC Has Max Weight Req.") then
            MaxAllowWeight := Location."SBC Transfer Max Weight Allow";

        if BrandCapacitybyLocation.Get(LocationCode, Brand) then begin
            MaxAllowCubage := BrandCapacitybyLocation."SBC Max Cubage Allowed";
            MaxAllowPallets := BrandCapacitybyLocation."SBC Max Pallet Count";
            if BrandCapacitybyLocation."SBC Allow Double Stack" then
                MaxAllowPallets := (MaxAllowPallets * 2);
        end;
    end;

    local procedure GetOrderTotals(TransOrderNo: Code[20]; var TotalWeight: Decimal; var TotalCubage: Decimal; var TotalPallets: Decimal)
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransOrderNo);
        if TransferLine.FindSet() then begin
            TransferLine.Calcsums("SBC Line Weight");
            TotalWeight := TransferLine."SBC Line Weight";
            TransferLine.Calcsums("SBC Line Pallet");
            TotalPallets := TransferLine."SBC Line Pallet";
            TransferLine.Calcsums("SBC Line Cubage");
            TotalCubage := TransferLine."SBC Line Cubage";
        end;
        // repeat
        //     TotalWeight += TransferLine."SBC Line Weight";
        //         TotalPallets += TransferLine."SBC Line Pallet";
        //     TotalCubage += TransferLine."SBC Line Cubage";
        // until TransferLine.Next() = 0;
    end;
    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProdOrderLineValidateUnitofMeasureCodeOnInitProdOrderLineAfterVariantCode(var ProdOrderLine: Record "Prod. Order Line"; VariantCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProdOrderLineValidateUnitofMeasureCodeOnAfterCopyFromItem(var ProdOrderLine: Record "Prod. Order Line"; var xProdOrderLine: Record "Prod. Order Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    #endregion eventIntegration
}