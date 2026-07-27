/// <summary>
/// PageExtension SBC Ship-to Address (ID 50052) extends Record Ship-to Address.
/// </summary>
pageextension 50052 "SBC Ship-to Address" extends "Ship-to Address"
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
