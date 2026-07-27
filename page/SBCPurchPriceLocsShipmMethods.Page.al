page 50001 "SBCPurchPriceLocs/ShipmMethods"
{
    PageType = List;
    Caption = 'EB Purch. Price Locations/Shipment Methods';
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;
    SourceTable = "SBCPurchPriceLoc/ShipmMethod";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not CostChanged then
                            if Rec."Location Code" <> xRec."Location Code" then
                                CostChanged := true;
                    end;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not CostChanged then
                            if Rec."Shipment Method Code" <> xRec."Shipment Method Code" then
                                CostChanged := true;
                    end;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not CostChanged then
                            if Rec."Direct Unit Cost" <> xRec."Direct Unit Cost" then
                                CostChanged := true;
                    end;
                }
            }
        }
    }

    trigger OnClosePage()
    var
        CustomEvents: Codeunit "Custom Base Events";
        PurchasePrice: Record "Purchase Price";
    begin
        if CostChanged then begin
            if GetPurchasePriceRecord(PurchasePrice) then
                if Dialog.Confirm(UpdatePricesLabel) then
                    CustomEvents.UpdatePurchasePricesOnOpenPurchaseOrders(PurchasePrice);
        end;
    end;

    var
        CostChanged: Boolean;
        UpdatePricesLabel: Label 'Prices have been updated, do you want to update open purchase orders?';


    local procedure GetPurchasePriceRecord(var PurchasePrice: Record "Purchase Price"): Boolean
    begin
        if PurchasePrice.Get(Rec."Item No.", Rec."Vendor No.", Rec."Starting Date", Rec."Currency Code", Rec."Variant Code", Rec."Unit of Measure Code", Rec."Minimum Quantity") then
            exit(true);

        exit(false);
    end;
}