/// <summary>
/// Page SBC Plant (ID 50041).
/// </summary>
page 50041 "SBC Plant"
{
    ApplicationArea = All;
    Caption = 'SBC Plant';
    PageType = List;
    SourceTable = "SBC Plant";
    UsageCategory = Administration;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Plant Code"; Rec."Plant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This identifies the SBC Plant.';
                }
                field("Plant Description"; Rec."Plant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'A description of the SBC Plant.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is not set, the SBC plant will not be processed against by solutions that use it.';
                }
            }
        }
    }
}