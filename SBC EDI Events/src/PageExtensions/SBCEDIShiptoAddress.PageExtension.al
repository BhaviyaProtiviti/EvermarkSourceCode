/// <summary>
/// PageExtension SBCEDI Ship-to Address (ID 50085) extends Record Ship-to Address.
/// </summary>
pageextension 50085 "SBCEDI Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addafter("SBC Emerson Ship-to Code")
        {
            
            field("SBC Auto-Created Ship-To"; Rec."SBC Auto-Created Ship-To")
            {
                ApplicationArea = All;
                ToolTip = 'This field is set when a ship-to is auto created during the EDI850 insert process.';
                Visible =true;
            }
        }
    }
}