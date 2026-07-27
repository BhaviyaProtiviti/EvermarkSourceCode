/// <summary>
/// PageExtension SBC Units of Measure (ID 50058) extends Record Units of Measure.
/// </summary>
pageextension 50058 "SBC Units of Measure" extends "Units of Measure"
{
    layout{
        addafter(Description)
        {
            
            field("SBC Case Unit"; Rec."SBC Case Unit")
            {
                ApplicationArea = All;
                ToolTip = 'This is a case unit of measure.';
                Visible = true;
            }
            field("SBC Pallet Layer Unit"; Rec."SBC Pallet Layer Unit")
            {
                ApplicationArea = All;
                ToolTip = 'This is a pallet layer unit of measure.';
                Visible = true;
            }
            field("SBC Pallet Unit"; Rec."SBC Pallet Unit")
            {
                ApplicationArea = All;
                ToolTip = 'This is a pallet layer unit of measure.';
                Visible = true;
            }
        }
    }
}