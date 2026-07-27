pageextension 50155 SBCSalesLine extends "Sales Order Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("SBC Qty. per Sales UOM"; Rec."SBC Original Order Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Original Order Quantity';

            }
        }

    }

}
