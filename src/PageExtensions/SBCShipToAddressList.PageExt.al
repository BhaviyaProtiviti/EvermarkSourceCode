/// <summary>
/// PageExtension SBC Ship-To Address List (ID 50053) extends Record Ship-to Address List.
/// </summary>
pageextension 50053 "SBC Ship-To Address List" extends "Ship-to Address List"
{
    layout
    {
        addafter(Code)
        {
            field("SBC Emerson Ship-to Code"; Rec."SBC Emerson Ship-to Code")
            {
                ApplicationArea = All;
                Caption = 'SBC Emerson Ship-to Code';
                ToolTip = 'The Emerson Ship-To Code for the Ship-To Address.';
                Visible = true;
            }
        }
    }
}