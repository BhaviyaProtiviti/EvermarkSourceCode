/// <summary>
/// PageExtension SBC Posted Sales Shipments (ID 50049) extends Record Posted Sales Shipments.
/// </summary>
pageextension 50049 "SBC Posted Sales Shipments" extends "Posted Sales Shipments"
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
    }
}
