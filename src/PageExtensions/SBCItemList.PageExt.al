/// <summary>
/// PageExtension SBC Item List (ID 50041) extends Record Item List.
/// </summary>
pageextension 50041 "SBC Item List" extends "Item List"
{
    layout
    {
        addafter(InventoryField)
        {
            field("SBC Created Date"; Rec."SBC Created Date")
            {
                ApplicationArea = All;
                Caption = 'SBC Created Date';
                Editable = false;
                ToolTip = 'The historical first created date of the item.';
                Visible = true;
            }
            field("SBC Obsolete Date"; Rec."SBC Obsolete Date")
            {
                ApplicationArea = All;
                Caption = 'SBC Obsolete Date';
                Editable = false;
                ToolTip = 'The date the item was made obsolete.';
                Visible = true;
            }
        }
        addafter(InventoryField)
        {
            field(CaseQtyOnHand; GlobalCaseQtyOnhand)
            {
                ApplicationArea = All;
                Caption = 'SBC Case Qty. on Hand';
                Editable = false;
                ToolTip = 'The number of cases on hand.';
                Visible = true;
                DecimalPlaces = 0;
            }
            field("SBC Tie Qty";Rec."SBC Tie Qty")
            {
                ApplicationArea = All;
                Caption = 'Tie Qty';
                Editable = false;
                ToolTip = 'The number of cases per layer.';
                Visible = false;
            }
            field("SBC High Qty";Rec."SBC High Qty")
            {
                ApplicationArea = All;
                Caption = 'High Qty';
                Editable = false;
                ToolTip = 'The number of layers per pallet.';
                Visible = false;
            }
        }
        addafter("No.")
        {


            field(GTIN; Rec.GTIN)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Global Trade Item Number (GTIN) for the item. For example, the GTIN is used with bar codes to track items, and when sending and receiving documents electronically. The GTIN number typically contains a Universal Product Code (UPC), or European Article Number (EAN).';
                Visible = false;
            }
            field("SBC Plant Code"; Rec."SBC Plant Code")
            {
                ApplicationArea = All;
                ToolTip = 'The code that identifies the supplier plant for the item.';
                Visible = false;
                
            }
            field("SBC Plant Item No."; Rec."SBC Plant Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'The Plant-specific item number.';
                Visible = false;

            }
        }
    }
    var

    var
        GlobalCaseQtyOnhand: Decimal;

    trigger OnAfterGetRecord()
    begin
        SetUnitGlobals();
    end;

    local procedure SetUnitGlobals()
    var
        CaseQuantityPerBaseUnit: Decimal;
        CaseQuantityRoundingPrecision: Decimal;
    begin
        Rec.GetItemUnitsByCase(CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision);
        SetCaseInventoryQty(CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision);
    end;

    local procedure SetCaseInventoryQty(var CaseQuantityPerBaseUnit: Decimal; var CaseQuantityRoundingPrecision: Decimal)
    begin
        if CaseQuantityPerBaseUnit <= 1 then
            exit;
        Rec.CalcFields(Inventory);
        GlobalCaseQtyOnhand := Round(Rec.Inventory / CaseQuantityPerBaseUnit, CaseQuantityRoundingPrecision, '<');
    end;
}
