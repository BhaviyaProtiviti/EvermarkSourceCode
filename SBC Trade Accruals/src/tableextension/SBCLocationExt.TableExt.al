tableextension 50703 SBCLocationExt extends Location
{
    fields
    {
        field(50700; "SBCCalcInboundCosts"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculate Inbound Costs';
            Description = 'Specifies if you want to calculate Inbound Costs for this Location';
        }
    }
}