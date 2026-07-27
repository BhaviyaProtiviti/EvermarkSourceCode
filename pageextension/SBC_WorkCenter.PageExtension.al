pageextension 50108 "SBC Work Center Card" extends "Work Center Card"
{
    layout
    {
        addafter("Subcontractor No.")
        {
            field("SBC Vendor Location"; Rec."SBC Vendor Location")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = true;
            }
        }
    }
}