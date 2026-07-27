/// <summary>
/// PageExtension STA Customer Card (ID 50201) extends Record Customer Card.
/// </summary>
pageextension 50201 "STA Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Invoicing)
        {
            group(SBCBracketPricing)
            {
                Caption = 'SBC Bracket Pricing';

                field("SBC Bracket Price Code"; Rec."SBC Bracket Price Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Bracket Price Code field.';
                    Importance = Additional;
                }
            }
        }
    }
}