/// <summary>
/// Codeunit SBC Misc Events (ID 50040).
/// </summary>
codeunit 50040 "SBC Misc Events"
{
    var
        SBCUnitErrorLabel: Label 'Only one SBC unit can be set per unit of measure.';
        TotalCaseUnitsSetErrorLabel: Label 'You can only have one unit of measure set as a case unit.';
        TotalPalletLayerUnitsSetErrorLabel: Label 'You can only have one unit of measure set as a pallet layer unit.';
        TotalPalletUnitsSetErrorLabel: Label 'You can only have one unit of measure set as a pallet unit.';

#if not NewPricingExperienceEnabled
    local procedure ItemUsesBillToPricing(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        SalesPrice: Record "Sales Price";
    begin
        SalesPrice.SetFilter("Item No.", '%1', SalesLine."No.");
        SalesPrice.SetFilter("Sales Code", '%1', SalesHeader."Sell-to Customer No.");
        SalesPrice.SetFilter("Currency Code", '%1', SalesHeader."Currency Code");
        SalesPrice.SetFilter("Starting Date", '<=%1', SalesHeader."Posting Date");
        SalesPrice.SetRange("SBC Use Bill-To Pricing", true);
        exit(not SalesPrice.IsEmpty());
    end;
#else
    local procedure ItemUsesBillToPricing(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetFilter("Source Type",'%1',"Price Source Type"::Customer);
        PriceListLine.SetFilter("Source No.",'%1',SalesHeader."Sell-to Customer No.");
        PriceListLine.SetFilter("Asset Type", '%1',"Price Asset Type"::Item);
        PriceListLine.SetFilter("Asset No.",'%1',SalesLine."No.");
        PriceListLine.SetFilter("Currency Code",'%1',SalesHeader."Currency Code");
        PriceListLine.SetFilter("Starting Date", '<=%1', SalesHeader."Posting Date");
        PriceListLine.SetRange("SBC Use Bill-To Pricing", true);
        exit(not PriceListLine.IsEmpty());
    end;
#endif
    local procedure SetPricingPreference(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        SBCBillToCustomerEvents: Codeunit "SBC BillTo Customer Events";
    begin
        if not PriceUpdateAllowed(SalesHeader, SalesLine) then
            exit;

        // Swap these values but do not write them. We want to preserve the Bill-To relationshipo on the Order.
        SBCBillToCustomerEvents.Unbind(true);
#if not NewPricingExperienceEnabled
        SBCBillToCustomerEvents.Bind();
#else
        SBCBillToCustomerEvents.Bind(SalesHeader);
#endif
        exit(true);
    end;

    local procedure CustomerUsesBillToPricing(SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("No.", SalesHeader."Sell-to Customer No.");
        Customer.SetFilter("Bill-to Customer No.", '%1', SalesHeader."Bill-to Customer No.");
        Customer.SetRange("SBC Use Bill-To Pricing", true);
        exit(not Customer.IsEmpty());
    end;

    local procedure PriceUpdateAllowed(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"): Boolean

    begin
        // If not quantity is set, then do not apply this logic.
        if SalesLine.Quantity = 0 then
            exit;
        // If the line is not an item, then do not apply this logic.
        if SalesLine.Type <> "Sales Line Type"::Item then
            exit;
        // If the Bill-To is the same as the Sell-To, then do not apply this logic.
        if SalesHeader."Sell-to Customer No." = SalesHeader."Bill-to Customer No." then
            exit;

        // This logic will only be applied if the Bill-To on the customer matches the current bill-to. If another bill-to is set, this logic will not apply.
        if CustomerUsesBillToPricing(SalesHeader) then
            exit;

        // If the item uses bill-to pricing, then allow it.
        if ItemUsesBillToPricing(SalesHeader, SalesLine) then
            exit;

        // If the default behavior is to be used for the order, then allow it.

        exit(true);
    end;

    local procedure NoSBCUnitsSet(var Rec: Record "Unit of Measure") Result: Boolean
    begin
        Result := not Rec."SBC Pallet Layer Unit" and not Rec."SBC Pallet Unit" and not Rec."SBC Case Unit";
    end;

    local procedure CheckSBCUnitSetCount(var Rec: Record "Unit of Measure")
    var
        SetCount: Integer;
    begin
        if Rec."SBC Case Unit" then
            SetCount += 1;
        if Rec."SBC Pallet Layer Unit" then
            SetCount += 1;
        if Rec."SBC Pallet Unit" then
            SetCount += 1;
        if SetCount = 1 then
            exit;
        error(SBCUnitErrorLabel);
    end;

    local procedure CheckTotalCaseUnits(UomCode: Code[10])
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Case Unit", true);
        UnitofMeasure.SetFilter("Code", '<>%1', UomCode);
        if UnitofMeasure.Count() = 0 then
            exit;
        Error(ErrorInfo.Create().Message(TotalCaseUnitsSetErrorLabel));
    end;

    local procedure CheckTotalPalletLayerUnits(UomCode: Code[10])
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Pallet Layer Unit", true);
        UnitofMeasure.SetFilter("Code", '<>%1', UomCode);
        if UnitofMeasure.Count() = 0 then
            exit;
        Error(ErrorInfo.Create().Message(TotalPalletLayerUnitsSetErrorLabel));
    end;

    local procedure CheckTotalPalletUnits(UomCode: Code[10])
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Pallet Unit", true);
        UnitofMeasure.SetFilter("Code", '<>%1', UomCode);
        if UnitofMeasure.Count() = 0 then
            exit;
        Error(ErrorInfo.Create().Message(TotalPalletUnitsSetErrorLabel));
    end;

    local procedure CheckSBCUnit(var Rec: Record "Unit of Measure")
    begin
        if NoSBCUnitsSet(Rec) then
            exit;
        CheckSBCUnitSetCount(Rec);
        if Rec."SBC Case Unit" then
            CheckTotalCaseUnits(Rec.Code);
        if Rec."SBC Pallet Layer Unit" then
            CheckTotalPalletLayerUnits(Rec.Code);
        if Rec."SBC Pallet Unit" then
            CheckTotalPalletUnits(Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnUpdateUnitPriceOnBeforeFindPrice, '', false, false)]
    local procedure OnUpdateUnitPriceOnBeforeFindPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
        IsHandled := SetPricingPreference(SalesHeader, SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure", OnBeforeInsertEvent, '', false, false)]
    local procedure UOMOnBeforeInsertEvent(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    begin
        CheckSBCUnit(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure", OnBeforeModifyEvent, '', false, false)]
    local procedure UOMOnBeforeModifyEvent(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    begin
        CheckSBCUnit(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterAssignItemValues, '', false, false)]
    local procedure OnAfterAssignItemValues(var PurchLine: Record "Purchase Line"; Item: Record Item; CurrentFieldNo: Integer; PurchHeader: Record "Purchase Header")
    begin
        PurchLine."SBC Plant Item No." := Item."SBC Plant Item No.";
        PurchLine."SBC Plant Code" := Item."SBC Plant Code";
    end;

    #region "SBC Use Sell-To Posting"



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean)
    var
        SellToCustomer: Record Customer;
        SBCSellToPostingHandler: Codeunit "SBC Sell-To Posting Handler";
    begin
        if SalesHeader."Bill-to Customer No." = SalesHeader."Sell-to Customer No." then
            exit;
        if SalesHeader."Applies-to Doc. No." <> '' then
            exit;
        SellToCustomer.SetRange("No.", SalesHeader."Sell-to Customer No.");
        SellToCustomer.SetRange("SBC Use Sell-To Posting", true);
        if SellToCustomer.IsEmpty() then
            exit;
        SellToCustomer.SetLoadFields("No.", "Gen. Bus. Posting Group");
        SellToCustomer.FindFirst();
        if SalesHeader."Gen. Bus. Posting Group" = SellToCustomer."Gen. Bus. Posting Group" then
            exit;
        SBCSellToPostingHandler.SetSellToCustomer(SellToCustomer);
        SBCSellToPostingHandler.Bind();
    end;


    #endregion "SBC Use Sell-To Posting"

    #region itemUOM


    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", OnAfterInsertEvent, '', false, false)]
    local procedure ItemUnitOfMeasureOnAfterInsertEvent(var Rec: Record "Item Unit of Measure")
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        if Rec."Qty. per Unit of Measure" = 0 then
            exit;

        OnBeforeTieHighItemUnitOfMeasureOnAfterInsertEvent(Rec, IsHandled);
        if IsHandled then
            exit;

        if not Item.Get(Rec."Item No.") then
            exit;
        Item.SetItemUnits();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", OnBeforeModifyEvent, '', false, false)]
    local procedure ItemUnitOfMeasureOnAfterValidateEventQtyPerUnitOfMeasure(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure")
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        if Rec."Qty. per Unit of Measure" = 0 then
            exit;

        OnBeforeTieHighItemUnitOfMeasureOnAfterModifyEvent(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        Item.Get(Rec."Item No.");
        Item.SetItemUnits();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBC Misc Events", OnBeforeTieHighItemUnitOfMeasureOnAfterModifyEvent, '', false, false)]
    local procedure SBCMiscEvents_OnBeforeTieHighItemUnitOfMeasureOnAfterModifyEvent(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure"; var IsHandled: Boolean)
    begin
        IsHandled := OnlyMeasurementSystemChanged(Rec);
    end;

    local procedure OnlyMeasurementSystemChanged(var Rec: Record "Item Unit of Measure"): Boolean
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
        i: Integer;
        MeasurementSystemFieldNo: Integer;
    begin
        if not ItemUnitofMeasure.Get(Rec."Item No.", Rec.Code) then
            exit(false);

        MeasurementSystemFieldNo := Rec.FieldNo("SBC Measurement System");
        RecRef.GetTable(Rec);
        xRecRef.GetTable(ItemUnitofMeasure);

        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            xFldRef := xRecRef.FieldIndex(i);
            if (FldRef.Class = FieldClass::Normal) and (FldRef.Type <> FieldType::Blob) then
                if Format(FldRef.Value) <> Format(xFldRef.Value) then begin
                    if FldRef.Number <> MeasurementSystemFieldNo then
                        exit(false); // another field changed — let normal processing continue
                end;
        end;

        exit(true);
    end;
    #endregion itemUOM

    #region purchaseLine

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, 'EVM Expected Ship Date', false, false)]
    local procedure PurchaseLineOnBeforeValidateEventExpectedShipDate(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if Rec.IsTemporary then
            exit;
        if not PurchasesPayablesSetup.Get() then
            exit;
        if Format(PurchasesPayablesSetup."EVM Expected Receipt Date Calculation") = '' then
            exit;

        Rec.Validate("Expected Receipt Date", CalcDate(PurchasesPayablesSetup."EVM Expected Receipt Date Calculation", Rec."EVM Expected Ship Date"));
    end;

    #endregion purchaseLine

    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTieHighItemUnitOfMeasureOnAfterInsertEvent(var Rec: Record "Item Unit of Measure"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTieHighItemUnitOfMeasureOnAfterModifyEvent(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure"; var IsHandled: Boolean)
    begin
    end;

    #endregion eventIntegration
}