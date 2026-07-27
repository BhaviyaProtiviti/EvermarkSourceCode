/// <summary>
/// PageExtension SBC Sales Prices (ID 50054) extends Record Sales Prices.
/// </summary>
#if not NewPricingExperienceEnabled
pageextension 50054 "SBC Sales Prices" extends "Sales Prices"
{
    layout
    {
        addafter("Starting Date")
        {
            field("SBC Use Bill-To Pricing"; Rec."SBC Use Bill-To Pricing")
            {
                ApplicationArea = All;
                Caption = 'Use Bill-To Pricing';
                ToolTip = 'Use Bill-To Pricing for the Customer.';
                Visible = true;
            }
        }
    }
}
#endif