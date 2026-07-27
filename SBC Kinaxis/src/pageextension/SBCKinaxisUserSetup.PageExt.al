pageextension 50360 "SBC Kinaxis User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {

            field("SBC Kinaxis Planner Name"; Rec."SBC Kinaxis Planner Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the SBC Kinaxis Planner Name.', Comment = '%';
            }
        }
    }
}
