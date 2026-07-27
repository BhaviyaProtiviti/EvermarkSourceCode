pageextension 50702 SBCLocationCardExt extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("SBCCalcInboundCosts"; Rec."SBCCalcInboundCosts")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if you want to calculate Inbound Costs for this Location.';
            }
        }
    }

}