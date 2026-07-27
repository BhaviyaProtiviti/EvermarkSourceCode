
pageextension 50152 "SBC Item Card Mod" extends "Item Card"
{
    layout
    {
        addafter("Sales Unit of Measure")
        {            
            field("SBC Qty. per Sales UOM"; Rec."SBC Qty. per Sales UOM")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Qty. per Sales UOM field.';
            }
        }
    }
}
