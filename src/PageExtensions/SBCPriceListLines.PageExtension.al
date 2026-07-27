/// <summary>
/// PageExtension SBC Price List Lines (ID 50055) extends Record Price List Lines.
/// </summary>
#if NewPricingExperienceEnabled
pageextension 50055 "SBC Price List Lines" extends "Price List Lines"
{
    layout
    {
        addafter(StartingDate)
        {
            field("SBC Use Bill-To Pricing"; Rec."SBC Use Bill-To Pricing")
            {
                ApplicationArea = All;
                ToolTip = 'Use Bill-To Pricing for the Customer.';
                Visible = true;
            }
        }
    }
}
#endif