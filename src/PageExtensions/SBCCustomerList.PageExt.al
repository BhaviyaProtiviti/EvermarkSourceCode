/// <summary>
/// PageExtension SBC Customer List (ID 50043) extends Record Customer List.
/// </summary>
pageextension 50043 "SBC Customer List" extends "Customer List"
{
    layout
    {
        addafter("No.")
        {
            field("SBC Emerson Customer No."; Rec."SBC Emerson Customer No.")
            {
                ApplicationArea = All;
                Caption = 'SBC Emerson Customer No.';
                ToolTip = 'The Emerson Customer No. for the Customer.';
                Visible = true;
            }
        }
    }
}
