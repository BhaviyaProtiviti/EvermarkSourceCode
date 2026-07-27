pageextension 50009 "SBC Item Units of Measure" extends "Item Units of Measure"
{
    layout
    {
        addafter(Code)
        {
            field("SBC Measurement System"; Rec."SBC Measurement System")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Measurement System for the Unit of Measure.';
            }
        }
    }
}