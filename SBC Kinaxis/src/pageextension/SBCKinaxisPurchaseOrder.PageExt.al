pageextension 50361 "SBC Kinaxis Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Purchaser Code")
        {

            field("SBC Kinaxis Planner Name"; Rec."SBC Kinaxis Planner Name")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the SBC Planner name.', Comment = '%';
            }
        }
    }
}
