pageextension 50000 "SBC Purchase Prices" extends "Purchase Prices"
{
    layout
    {
        modify("Direct Unit Cost")
        {
            ToolTip = 'The default Unit Cost to use when no valid Location/Shipment Method combination can be found for the line.';

            trigger OnAfterValidate()
            begin
                if not CostChanged then
                    if Rec."Direct Unit Cost" <> xRec."Direct Unit Cost" then
                        CostChanged := true;
            end;
        }
        addafter("Item No.")
        {
            field("SBC Item Description"; Rec."SBC Item Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a description of the item.';
                Editable = false;
            }
        }
    }
    actions
    {
        addafter(CopyPrices)
        {
            action(UpdatePrices)
            {
                ApplicationArea = All;
                Caption = 'Update Prices';
                Image = Change;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    CustomEvents: Codeunit "Custom Base Events";
                begin
                    CustomEvents.UpdatePurchasePricesOnOpenPurchaseOrders(Rec);
                    CostChanged := false;
                end;
            }
            action(SBCLocationShipmentMethods)
            {
                ApplicationArea = All;
                Caption = 'Location & Shipment Method Prices';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "SBCPurchPriceLocs/ShipmMethods";
                RunPageLink = "Item No." = field("Item No."),
                              "Vendor No." = field("Vendor No."),
                              "Starting Date" = field("Starting Date"),
                              "Currency Code" = field("Currency Code"),
                              "Variant Code" = field("Variant Code"),
                              "Unit of Measure Code" = field("Unit of Measure Code"),
                              "Minimum Quantity" = field("Minimum Quantity");
            }
        }
    }
    trigger OnClosePage()
    var
        CustomEvents: Codeunit "Custom Base Events";
    begin
        if CostChanged then begin
            if Dialog.Confirm(UpdatePricesLabel) then
                CustomEvents.UpdatePurchasePricesOnOpenPurchaseOrders(Rec);
        end;
    end;

    var
        CostChanged: Boolean;
        UpdatePricesLabel: Label 'Prices have been updated, do you want to update open purchase orders?';
}