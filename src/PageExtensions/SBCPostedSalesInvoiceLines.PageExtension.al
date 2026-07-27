/// <summary>
/// PageExtension SBC Posted Sales Invoice Lines (ID 50039) extends Record Posted Sales Invoice Lines.
/// </summary>
pageextension 50039 "SBC Posted Sales Invoice Lines" extends "Posted Sales Invoice Lines"
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
    }
}