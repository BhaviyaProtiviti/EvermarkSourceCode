/// <summary>
/// PageExtension STA Location Card (ID 50202) extends Record Location Card.
/// </summary>
pageextension 50202 "STA Location Card" extends "Location Card"
{
    layout {

        addafter(Warehouse)
        {
            group(SBCIndirectCosts)
            {
                Caption = 'SBC Indirect Costs';
                Description = 'Location-related settings that are relevant to Indirect Cost tracking.';
                
                field("SBC Enable Indirect Cost"; Rec."SBC Enable Indirect Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this field is enabled, Indirect Cost tracking will be allowed for the specified location.';
                }
            }
        }
    }
}