/// <summary>
/// PageExtension SBC Posted Purch Inv Lines (ID 50037) extends Record Posted Purchase Invoice Lines.
/// </summary>
pageextension 50037 "SBC Posted Purch Inv Lines" extends "Posted Purchase Invoice Lines"
{
    layout
    {
        addfirst(Control1)
        {
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
            }
        }
        addlast(Control1)
        {
            field("SBC Plant Code"; Rec."SBC Plant Code")
            {
                ApplicationArea = All;
            }
        }
    }
}
