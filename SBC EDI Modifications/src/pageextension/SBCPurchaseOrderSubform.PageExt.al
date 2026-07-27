pageextension 50158 "SBC Purchase Order Subform Ext" extends "Purchase Order Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("SBC Original Order Qty."; Rec."SBC Original Order Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the original order quantity when the purchase order line was first created.';
                Editable = false;
            }
            field("SBC Original Approved Qty."; Rec."SBC Original Approved Qty.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity that was originally approved when the purchase order was first released.';
                Editable = false;
            }
            field("SBC EDI Received Qty"; Rec."SBC EDI Received Qty")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the EDI Received Quantity';
            }
        }
    }
}
