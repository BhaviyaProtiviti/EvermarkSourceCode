codeunit 50143 "SBC Kinaxis Internal Hdlr"
{

    #region eventSubscription

    #region productionOrder_API_EventSubscription

    // KinaxisProductionOrderOnAfterInsertEvent is called after the production order is inserted in the "Production Order" table.
    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterInsertEvent', '', false, false)]
    local procedure KinaxisProductionOrderOnAfterInsertEvent(var Rec: Record "Production Order"; RunTrigger: Boolean)
    var
        KinaxisInternalHdlr: Codeunit "SBC Kinaxis Internal Hdlr";
        IsHandled: boolean;
    begin
        OnBeforeKinaxisProductionOrderOnAfterInsertEvent(Rec, RunTrigger, IsHandled);
        if IsHandled then
            exit;

        if Rec."SBC Kinaxis Purchase Order No." <> '' then
            KinaxisInternalHdlr.Kinaxis_ProcessRPO(Rec);

        OnAfterKinaxisProductionOrderOnAfterInsertEvent(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBC Subcontracting", OnBeforeProdOrderLineValidateUnitofMeasureCodeOnAfterCopyFromItem, '', false, false)]
    local procedure SBCSubcontractingOnBeforeProdOrderLineValidateUnitofMeasureCodeOnAfterCopyFromItem(var ProdOrderLine: Record "Prod. Order Line"; var xProdOrderLine: Record "Prod. Order Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)

    begin
        if ProdOrderLine.Status <> ProdOrderLine.Status::Released then
            exit;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBC Subcontracting", OnBeforeProdOrderLineValidateUnitofMeasureCodeOnInitProdOrderLineAfterVariantCode, '', false, false)]
    local procedure SBCSubcontractingOnBeforeProdOrderLineValidateUnitofMeasureCodeOnInitProdOrderLineAfterVariantCode(var ProdOrderLine: Record "Prod. Order Line"; VariantCode: Code[10]; var IsHandled: Boolean)
    begin
        if ProdOrderLine.Status <> ProdOrderLine.Status::Released then
            exit;

        IsHandled := GetVendorUoM(ProdOrderLine);
    end;

    [TryFunction]
    local procedure GetVendorUoM(var ProdOrderLine: Record "Prod. Order Line")
    var
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        Item.Get(ProdOrderLine."Item No.");
        Vendor.Get(Item."Vendor No.");
        if Vendor."SBC Kinaxis Vendor UOM" = '' then
            Error(' ');
        ProdOrderLine.Validate("Unit of Measure Code", Vendor."SBC Kinaxis Vendor UOM");
    end;

    #endregion productionOrder_API_EventSubscription

    #region purchaseOrder_API_EventSubscription

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", OnBeforeInsertHeader, '', false, false)]
    local procedure ReqWkshMakeOrderOnBeforeInsertHeader(RequisitionLine: Record "Requisition Line"; var OrderDateReq: Date)
    var
        ProductionOrder: Record "Production Order";
    begin
        if ProductionOrder.Get(ProductionOrder.Status::Released, RequisitionLine."Prod. Order No.") and (ProductionOrder."SBC Kinaxis Purchase Order No." <> '') then
            OrderDateReq := Today();
    end;

    // Kinaxis_ReqWkshMakeOrderOnBeforePurchOrderHeaderInsert is called before the purchase order header is inserted in the "Req. Wksh.-Make Order" codeunit.
    // It is used to set the "No." and "SBC Kinaxis Planner Name" fields in the purchase order header based on the production order number.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", OnBeforePurchOrderHeaderInsert, '', false, false)]
    local procedure Kinaxis_ReqWkshMakeOrderOnBeforePurchOrderHeaderInsert(var PurchaseHeader: Record "Purchase Header"; RequisitionLine: Record "Requisition Line")
    var
        ProductionOrder: Record "Production Order";
    begin
        if ProductionOrder.Get(ProductionOrder.Status::Released, RequisitionLine."Prod. Order No.") and (ProductionOrder."SBC Kinaxis Purchase Order No." <> '') then begin
            PurchaseHeader."No." := ProductionOrder."SBC Kinaxis Purchase Order No.";
            PurchaseHeader."SBC Kinaxis Planner Name" := ProductionOrder."SBC Kinaxis Planner Name";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", OnBeforePurchOrderLineInsert, '', false, false)]
    local procedure Kinaxis_ReqWkshMakeOrderOnBeforePurchOrderLineInsert(var PurchOrderHeader: Record "Purchase Header"; var PurchOrderLine: Record "Purchase Line"; var ReqLine: Record "Requisition Line"; CommitIsSuppressed: Boolean)
    var
        ProductionOrder: Record "Production Order";
    begin
        if ProductionOrder.Get(ProductionOrder.Status::Released, ReqLine."Prod. Order No.") and (ProductionOrder."SBC Kinaxis Purchase Order No." <> '') then begin
            PurchOrderLine."Promised Receipt Date" := ProductionOrder."Due Date";
            PurchOrderLine."EVM Expected Ship Date" := ProductionOrder."SBC Kinaxis Expected Ship Date";
        end;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterModifyEvent, '', false, false)]
    // local procedure PurchaseLineOnAfterModifyEvent(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; RunTrigger: Boolean)
    // var
    //     PurchaseHeader: Record "Purchase Header";
    // begin
    //     if not Rec."SBC Kinaxis API Updated" then
    //         exit;

    //     if (PurchaseHeader.Get(Rec."Document Type", Rec."Document No.")) and (PurchaseHeader.Status = PurchaseHeader.Status::Open) and (not PurchaseHeader."SBC Kinaxis API Updated") then begin
    //         PurchaseHeader."SBC Kinaxis API Updated" := Rec."SBC Kinaxis API Updated";
    //         PurchaseHeader.Modify();
    //     end;
    // end;

    #endregion purchaseOrder_API_EventSubscription

    #region transferOrder_API_EventSubscription 

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", OnAfterInsertEvent, '', false, false)]
    local procedure TransferHeaderOnAfterInsertEvent(var Rec: Record "Transfer Header"; RunTrigger: Boolean)
    begin
        if not Rec."SBC Kinaxis API Updated" then
            exit;

        Rec.Validate("Transfer-from Code");
        Rec.Validate("Transfer-to Code");
        Rec.Validate("In-Transit Code");
    end;

    #endregion transferOrder_API_EventSubscription

    #endregion eventSubscription

    #region purchaseOrder_API

    procedure Kinaxis_OnInsert(var Rec: Record "Purchase Header")
    begin
        Rec."Document Type" := Rec."Document Type"::Order;
        Rec."SBC Kinaxis API Updated" := true;
    end;

    procedure Kinaxis_OnInsert(var Rec: Record "Purchase Line")
    begin
        Rec."Document Type" := Rec."Document Type"::Order;
        Rec.Validate(Quantity);
        Rec.Validate("Qty. to Receive");
        Rec.Validate("Requested Receipt Date");
        Rec.UpdateAmounts();
        Rec."SBC Kinaxis API Updated" := true;
    end;

    procedure Kinaxis_OnModify(var Rec: Record "Purchase Line"; xRec: Record "Purchase Line")
    begin
        Rec."SBC Kinaxis API Updated" := true;
        if (Rec.Quantity <> xRec.Quantity) or (Rec."Promised Receipt Date" <> xRec."Promised Receipt Date") then begin
            if Rec.Quantity <> xRec.Quantity then begin
                Rec.Validate(Quantity);
                Rec.UpdateAmounts();
            end;
            UpdateRPO(Rec);
        end;
    end;

    local procedure UpdateRPO(Rec: Record "Purchase Line")
    var
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
        ProductionOrder.SetRange("SBC Kinaxis Purchase Order No.", Rec."Document No.");
        if ProductionOrder.FindFirst() then begin
            if Rec."Promised Receipt Date" <> ProductionOrder."Due Date" then begin
                ProductionOrder.SetUpdateEndDate();
                ProductionOrder.Validate("Due Date", Rec."Promised Receipt Date");
            end;
            if Rec.Quantity <> ProductionOrder.Quantity then
                ProductionOrder.Validate(Quantity, Rec.Quantity);
            ProductionOrder.Modify(true);

            ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
            ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
            ProdOrderLine.SetRange("Item No.", Rec."No.");
            ProdOrderLine.SetFilter(Quantity, '<>%1', Rec.Quantity);
            if ProdOrderLine.FindFirst() then begin
                ProdOrderLine.Validate(Quantity, Rec.Quantity);
                ProdOrderLine.Modify(true);
            end;
            ReplanRPO(ProductionOrder."No.");
        end;
    end;

    local procedure ReplanRPO(ProdOrderNo: Code[20])
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetRange("No.", ProdOrderNo);
        REPORT.RunModal(REPORT::"Replan Production Order", false, true, ProdOrder);
    end;

    #endregion purchaseOrder_API

    #region prodOrder_API

    procedure Kinaxis_OnInsert(var Rec: Record "Production Order")
    var
        MfgSetup: Record "Manufacturing Setup";
    begin
        Rec.TestField("SBC Kinaxis Planner Name");
        Rec.TestField("SBC Kinaxis Purchase Order No.");
        Rec."SBC Override Exact Qty." := true;
        Rec.Validate(Quantity);
        if Rec."Location Code" = '' then begin
            MfgSetup.Get();
            Rec."Location Code" := CopyStr(MfgSetup."SBC Default Location", 1, 10);
        end
    end;

    procedure Kinaxis_OnModify(var Rec: Record "Production Order"; xRec: Record "Production Order")
    var
        KinaxisRelease_ReopenPO: Codeunit "SBC Kinaxis Release_Reopen PO";
    begin
        if Rec.Quantity <> xRec.Quantity then begin
            Rec.Validate(Quantity);
            UpdatePurchaseQty(Rec);
            KinaxisRelease_ReopenPO.ReleaseKinaxisOrder(Rec."SBC Kinaxis Purchase Order No.");
        end;
    end;

    #region createPO

    procedure Kinaxis_ProcessRPO(Rec: Record "Production Order")
    begin
        kinaxis_RefreshProdOrder(Rec);
        Kinaxis_CreateOrder(Rec);
    end;

    local procedure Kinaxis_RefreshProdOrder(Rec: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProductionOrder: Record "Production Order";
    begin
        ProdOrderLine.SetRange(Status, Rec.Status);
        ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
        if not ProdOrderLine.IsEmpty() then
            exit;

        Commit(); // Commit the transaction to ensure that the changes are saved before running the report.

        ProductionOrder.SetRange(Status, Rec.Status);
        ProductionOrder.SetRange("No.", Rec."No.");
        REPORT.RunModal(REPORT::"Refresh Production Order", false, true, ProductionOrder);
    end;

    local procedure Kinaxis_CreateOrder(Rec: Record "Production Order")
    var
        ReqLine: Record "Requisition Line";
        UserSetup: Record "User Setup";
        WorkCenter: Record "Work Center";
        ProdRtgLine: Record "Prod. Order Routing Line";
        MfgSetup: Record "Manufacturing Setup";
        CalculateSubContract: Report "SBC Calculate Subcontracts";
        MakePurchOrder: Report "Carry Out Action Msg. - Req.";
    begin
        if Rec."SBC Subcontracting Purch.Order" <> '' then
            exit;

        MfgSetup.Get();
        MfgSetup.TestField("SBC Default Routing Link");

        ProdRtgLine.SETRANGE(Status, Rec.Status);
        ProdRtgLine.SETRANGE("Prod. Order No.", Rec."No.");
        if ProdRtgLine.FINDFIRST() then
            WorkCenter.get(ProdRtgLine."Work Center No.");
        if ProdRtgLine.FINDSET() then
            repeat
                if ProdRtgLine."Work Center No." <> WorkCenter."No." then
                    exit;
            until ProdRtgLine.NEXT() = 0;

        if WorkCenter."Subcontractor No." <> '' then begin
            ProdRtgLine."Routing Link Code" := MfgSetup."SBC Default Routing Link";
            ProdRtgLine.Modify(false);
        end;

        UserSetup.SetRange("SBC Kinaxis Planner Name", Rec."SBC Kinaxis Planner Name");
        if not UserSetup.FINDFIRST() then
            error('Kinaxis Planner Name not found.');
        UserSetup.TESTFIELD("SBC Subcontracting Batch");
        ReqLine.INIT();
        ReqLine."Worksheet Template Name" := 'FOR. LABOR';
        ReqLine."Journal Batch Name" := UserSetup."SBC Subcontracting Batch";
        ReqLine."Line No." := 10000;
        ReqLine.INSERT();
        CalculateSubContract.SetProdOrder(Rec."No.");
        CalculateSubContract.USEREQUESTPAGE(false);
        CalculateSubContract.SetWkShLine(ReqLine);
        CalculateSubContract.RUNMODAL();

        MakePurchOrder.USEREQUESTPAGE(false);
        MakePurchOrder.SetReqWkshLine(ReqLine);
        MakePurchOrder.RUNMODAL();
        commit(); //
    end;

    #endregion createPO

    #region updatePOQty

    local procedure UpdatePurchaseQty(Rec: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        PurchLine: Record "Purchase Line";
    begin
        ProdOrderLine.SetRange(Status, Rec.Status);
        ProdOrderLine.SetRange("Prod. Order No.", Rec."No.");
        if ProdOrderLine.findfirst() then begin
            ProdOrderLine."SBC Override Exact Qty." := Rec."SBC Override Exact Qty.";
            ProdOrderLine.Validate(Quantity, Rec.Quantity);
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
                PurchLine."EVM Expected Ship Date" := Rec."SBC Kinaxis Expected Ship Date";
                PurchLine."Promised Receipt Date" := Rec."Due Date";
                PurchLine.Validate(Quantity, Rec.Quantity);
                PurchLine.UpdateAmounts();
                PurchLine.UpdatePrePaymentAmounts();
                PurchLine.Modify(false);
            end;
        end;
    end;

    #endregion updatePOQty

    #endregion prodOrder_API

    #region transferOrder_API

    procedure Kinaxis_OnInsert(var Rec: Record "Transfer Header")
    begin
        Rec."SBC Kinaxis API Updated" := true;
    end;

    procedure Kinaxis_OnInsert(var Rec: Record "Transfer Line")
    begin
        // Rec."SBC Override Exact Qty." := true;
    end;

    #endregion transferOrder_API

    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeKinaxisProductionOrderOnAfterInsertEvent(var Rec: Record "Production Order"; RunTrigger: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterKinaxisProductionOrderOnAfterInsertEvent(var Rec: Record "Production Order")
    begin
    end;

    #endregion eventIntegration

}