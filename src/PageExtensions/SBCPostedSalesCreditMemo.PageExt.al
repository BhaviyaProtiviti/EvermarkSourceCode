/// <summary>
/// PageExtension SBC Posted Sales Credit Memo (ID 50046) extends Record Posted Sales Credit Memo.
/// </summary>
pageextension 50046 "SBC Posted Sales Credit Memo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addfirst("Sell-to")
        {
            field("Sell-To Emerson Customer No."; Rec."Sell-To Emerson Customer No.")
            {
                ApplicationArea = All;
                Caption = 'Sell-To Emerson Customer No.';
                Editable = false;
                ToolTip = 'SBC Emerson Customer No. for the Sell-To Customer';
                Visible = true;
            }
        }
        addfirst("Bill-to")
        {
            field("Bill-to Emerson Customer No."; Rec."Bill-to Emerson Customer No.")
            {
                ApplicationArea = All;
                Caption = 'Bill-to Emerson Customer No.';
                Editable = false;
                ToolTip = 'SBC Emerson Customer No. for the Bill-To Customer';
                Visible = false;
            }
        }
        addfirst("Ship-to")
        {
            field("SBC Emerson Ship-to Code"; Rec."SBC Emerson Ship-to Code")
            {
                ApplicationArea = All;
                Caption = 'SBC Emerson Ship-to Code';
                Editable = false;
                ToolTip = 'The Emerson Ship-To Code for the Ship-To Address.';
                Visible = true;
            }
        }
    }
}
