pageextension 50005 "SBC Main Post Purch Reciepts" extends "Posted Purchase Receipts"
{
    layout
    {
        addlast(Control1)
        {            
            field("Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the line number of the order that created the entry.';
            }
        }
    }
}
