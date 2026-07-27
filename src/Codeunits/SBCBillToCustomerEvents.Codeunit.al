/// <summary>
/// Codeunit SBC BillTo Customer Events (ID 50041).
/// </summary>
codeunit 50041 "SBC BillTo Customer Events"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
#if not NewPricingExperienceEnabled
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", OnBeforeSalesLineLineDiscExists, '', false, false)]
    local procedure OnBeforeSalesLineLineDiscExists(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var TempSalesLineDisc: Record "Sales Line Discount" temporary; StartingDate: Date; Qty: Decimal; QtyPerUOM: Decimal; ShowAll: Boolean; var IsHandled: Boolean)
    begin
        SetBillToValues(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", OnBeforeSalesLinePriceExists, '', false, false)]
    local procedure OnBeforeSalesLinePriceExists(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var TempSalesPrice: Record "Sales Price" temporary; Currency: Record Currency; CurrencyFactor: Decimal; StartingDate: Date; Qty: Decimal; QtyPerUOM: Decimal; ShowAll: Boolean; var InHandled: Boolean)
    begin
        SetBillToValues(SalesHeader);
    end;

    internal procedure Bind()
    begin
        if IsBound() then
            exit;
        GlobalBound := BindSubscription(SBCBillToCustomerEvents);
    end;
#else

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Source List", OnAddOnBeforeInsert, '', false, false)]
    local procedure OnAddOnBeforeInsert(var PriceSource: Record "Price Source")
    begin
        SetPricingPreference(PriceSource);
    end;
    local procedure SetCustomerPricingPreference(var PriceSource: Record "Price Source")
    begin
        if PriceSource."Source No." <> GlobalSalesHeader."Bill-to Customer No." then
            exit;
        PriceSource.Validate("Source No.", GlobalSalesHeader."Sell-to Customer No.");
    end;

    local procedure SetContactPricingPreference(var PriceSource: Record "Price Source")
    begin
        if PriceSource."Source No." <> GlobalSalesHeader."Bill-to Contact No." then
            exit;
        PriceSource.Validate("Source No.", GlobalSalesHeader."Sell-to Contact No.");
    end;

    local procedure SetPricingPreference(var PriceSource: Record "Price Source")
    begin
        case PriceSource."Source Type" of
            PriceSource."Source Type"::Customer:
                SetCustomerPricingPreference(PriceSource);
            PriceSource."Source Type"::Contact:
                SetContactPricingPreference(PriceSource);
        end;
    end;

    internal procedure Bind(SalesHeader: Record "Sales Header")
    begin
        if IsBound() then
            exit;
        GlobalBound := BindSubscription(SBCBillToCustomerEvents);
        GlobalSalesHeader := SalesHeader;
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterUpdateUnitPrice, '', false, false)]
    local procedure OnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer)
    begin
        SetListPriceDiscount(SalesLine);
        Unbind();
    end;

    internal procedure SetListPriceDiscount(var SalesLine: Record "Sales Line")
    var
        Currency: Record Currency;
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        CurrencyCode: Code[10];
        NewUnitPrice: Decimal;
        PreviousUnitPrice: Decimal;
    begin
        // if a Unit price is not set on the item, this logic will not run.
        if SalesLine.Quantity = 0 then
            exit;
        Item.SetRange("No.", SalesLine."No.");
        Item.SetFilter("Unit Price", '<>%1', 0);
        if Item.IsEmpty() then
            exit;
        ItemUnitofMeasure.SetRange("Item No.", SalesLine."No.");
        ItemUnitofMeasure.SetRange(Code, SalesLine."Unit of Measure Code");
        if ItemUnitofMeasure.IsEmpty() then
            exit;

        CurrencyCode := SalesLine.GetSalesHeader()."Currency Code";
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(CurrencyCode);
        PreviousUnitPrice := SalesLine."Unit Price";
        Item.SetLoadFields("Unit Price");
        Item.FindFirst();
        ItemUnitofMeasure.SetLoadFields("Qty. per Unit of Measure");
        ItemUnitofMeasure.FindFirst();
        NewUnitPrice := Round(Item."Unit Price" * ItemUnitofMeasure."Qty. per Unit of Measure", Currency."Unit-Amount Rounding Precision");
        if SalesLine."Unit Price" >= NewUnitPrice then
            exit;
        SalesLine.Validate("Unit Price", NewUnitPrice);
        SalesLine.Validate("Line Discount %", Round(100*(1-(PreviousUnitPrice/SalesLine."Unit Price")),Currency."Unit-Amount Rounding Precision"));
    end;

    internal procedure IsBound(): Boolean
    begin
        exit(GlobalBound);
    end;

    internal procedure Unbind()
    begin
        Unbind(false);
    end;

    internal procedure Unbind(Force: Boolean)
    begin
        if not Force then
            if not IsBound() then
                exit;

        if not UnbindSubscription(SBCBillToCustomerEvents) then
            if not Force then
                exit;

        ClearGlobals();
    end;

    local procedure ClearGlobals()
    begin
        Clear(GlobalBound);
#if NewPricingExperienceEnabled
        Clear(GlobalSalesHeader);
#endif
    end;

    local procedure SetBillToValues(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."Bill-to Customer No." := SalesHeader."Sell-to Customer No.";
        SalesHeader."Bill-to Contact No." := SalesHeader."Sell-to Contact No.";
    end;

    var
        GlobalBound: Boolean;
#if NewPricingExperienceEnabled
        GlobalSalesHeader: Record "Sales Header";
#endif
        SBCBillToCustomerEvents: Codeunit "SBC BillTo Customer Events";
}