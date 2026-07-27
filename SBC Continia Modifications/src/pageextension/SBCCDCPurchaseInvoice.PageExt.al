pageextension 50161 "SBC CDC Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field("SBC CDC Our Order No."; Rec."SBC CDC Our Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'SBC Our Order No.';
            }
        }
    }
}
