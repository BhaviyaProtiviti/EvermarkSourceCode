pageextension 50006 "SBC Main Post Sales Shipments" extends "Posted Sales Shipments"
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
