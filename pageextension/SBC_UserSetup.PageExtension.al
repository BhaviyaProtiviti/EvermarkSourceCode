pageextension 50103 "SBC User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("SBC Subcontracting Batch"; Rec."SBC Subcontracting Batch")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}