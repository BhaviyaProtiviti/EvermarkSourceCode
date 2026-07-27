pageextension 50105 "SBC Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter(Status)
        {
            field("SBC Production Order No."; Rec."SBC Production Order No.")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = false;
            }
        }
    }
}