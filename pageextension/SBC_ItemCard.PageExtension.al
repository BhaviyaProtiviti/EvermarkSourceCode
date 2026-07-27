pageextension 50101 "SBC Item Card" extends "Item Card"
{
    layout
    {
        modify("Net Weight")
        {
            trigger OnAfterValidate()
            begin
                if Rec."SBC Gross Weight Percentage" <> 0 then begin
                    Rec."Gross Weight" := Rec."Net Weight" * (1 + Rec."SBC Gross Weight Percentage");
                end
                else begin
                    Rec."Gross Weight" := Rec."Net Weight" * 1.05;
                end;

            end;
        }
        addafter("Shelf No.")
        {
            field("SBC Shelf Life (Days)"; Rec."SBC Shelf Life (Days)")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
        addafter("Tariff No.")
        {
            field("SBC Hazardous Material Code"; Rec."SBC Hazardous Material Code")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
        addbefore("Item Category Code")
        {
            field("SBC Production Line"; Rec."SBC Production Line")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Production Line field.';
            }
        }
        addafter("Safety Stock Quantity")
        {
            field("SBC Safety Stock Days"; Rec."SBC Safety Stock Days")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Safety Stock Days field.';
            }
        }
        addafter("Minimum Order Quantity")
        {
            field("SBC MOQ UOM"; Rec."SBC MOQ UOM")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the MOQ UOM field.';
            }
        }
        addlast(Planning)
        {

            field("SBC Run Strategy"; Rec."SBC Run Strategy")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Run Strategy field.';
            }
        }
        addlast("Costs & Posting")
        {
            field("SBC Landed Cost"; Rec."SBC Landed Cost")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Landed Cost field.';
            }
        }
        addafter(Description)
        {
            field("SBC Description Short"; Rec."SBC Description Short")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description Short field.';
            }
        }
        addlast(InventoryGrp)
        {
            field("SBC Expiration on Label"; Rec."SBC Expiration on Label")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Expiration on Label field.';
            }
            field("SBC Exportable"; Rec."SBC Exportable")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Exportable field.';
            }
        }
        addafter("Base Unit of Measure")
        {
            field("SBC Measurement System"; Rec."SBC Measurement System")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Measurement System used by Base Unit of Measure';
            }
        }
    }
}