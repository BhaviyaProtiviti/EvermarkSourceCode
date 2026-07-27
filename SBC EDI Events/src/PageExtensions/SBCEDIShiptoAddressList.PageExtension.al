/// <summary>
/// PageExtension SBCEDI Ship-to Address List (ID 50086) extends Record Ship-to Address List.
/// </summary>
pageextension 50086 "SBCEDI Ship-to Address List" extends "Ship-to Address List"
{
    layout
    {
        addafter("SBC Emerson Ship-to Code")
        {

            field("SBC Auto-Created Ship-To"; Rec."SBC Auto-Created Ship-To")
            {
                ApplicationArea = All;
                ToolTip = 'This field is set when a ship-to is auto created during the EDI850 insert process.';
                Visible = true;
            }
        }
    }
}