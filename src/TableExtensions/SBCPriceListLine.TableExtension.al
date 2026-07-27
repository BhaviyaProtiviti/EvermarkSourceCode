/// <summary>
/// TableExtension SBC Price List Line (ID 50048) extends Record Price List Line.
/// </summary>
tableextension 50048 "SBC Price List Line" extends "Price List Line"
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