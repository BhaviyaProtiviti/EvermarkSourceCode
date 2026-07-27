pageextension 50114 "SBC Item Category" extends "Item Categories"

{
    layout
    {
        addafter(Description)
        {
            field("SBC Default Brand Dimension"; Rec."SBC Default Brand Dimension")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}