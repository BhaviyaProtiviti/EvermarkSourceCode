pageextension 50165 "SBC Purchase Order Ext" extends "Purchase Order"
{
    layout
    {

        addlast(General)
        {
            field("Transfer Order Created"; Rec."SBC Create Transfer Order")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Indicates whether a transfer order has been created for this purchase order/receipt.';
            }

            field("Linked Transfer Order No."; Rec."SBC Linked Transfer Order No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'The transfer order number linked to this purchase order/receipt, if any.';
            }
        }
    }


    actions
    {
        addafter("O&rder") // Add under Related → Order
        {
            action(ViewTransferOrders)
            {
                ApplicationArea = All;
                Caption = 'Transfer Orders';
                Enabled = true;
                Image = Link;
                RunObject = Page "SBC Purch Order Transfer List";
                RunPageLink = "Purchase Order No." = FIELD("No.");
                Visible = true;
                ToolTip = 'View all transfer orders linked to this purchase order.';
            }
        }
    }


}
