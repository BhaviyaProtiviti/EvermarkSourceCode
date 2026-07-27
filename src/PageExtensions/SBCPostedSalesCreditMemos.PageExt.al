/// <summary>
/// PageExtension SBC Posted Sales Credit Memos (ID 50047) extends Record Posted Sales Credit Memos.
/// </summary>
pageextension 50047 "SBC Posted Sales Credit Memos" extends "Posted Sales Credit Memos"
{
    layout
    {
        addafter("Sell-to Customer No.")
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
        addafter("Bill-to Customer No.")
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
        addafter("Ship-to Code")
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
        addlast(Control1)
        {
            field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
            {
                ApplicationArea = All;
                Caption = 'Applies-to Doc. No.';
                Editable = false;
                ToolTip = 'The document number that the credit memo applies to.';
            }
        }
    }
}
