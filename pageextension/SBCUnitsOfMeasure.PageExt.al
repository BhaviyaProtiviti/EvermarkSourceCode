pageextension 50010 "SBC Units of Measure2" extends "Units of Measure"
{
    layout
    {
        addafter(Description)
        {
            field("SBC Measurement System"; Rec."SBC Measurement System")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Measurement System for the Unit of Measure.';
            }
        }
    }
}