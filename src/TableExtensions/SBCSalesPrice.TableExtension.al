/// <summary>
/// TableExtension SBC Sales Price (ID 50047) extends Record Sales Price.
/// </summary>
tableextension 50047 "SBC Sales Price" extends "Sales Price"
{
    fields
    {
        field(50041; "SBC Use Bill-To Pricing"; Boolean)
        {
            Caption = 'Use Bill-To Pricing';
            DataClassification = CustomerContent;
            Description = 'Use Bill-To Pricing for the Customer.';
        }
    }
}