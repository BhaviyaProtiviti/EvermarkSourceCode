pageextension 50362 "SBC Kinaxis RPO" extends "Released Production Order"
{
    layout
    {
        addlast(General)
        {
            field("SBC Kinaxis Purchase Order No."; Rec."SBC Kinaxis Purchase Order No.")
            {
                ApplicationArea = All;
                // Editable = false;
                ToolTip = 'Kinaxis PO';
                Visible = false;
            }
            field("SBC Kinaxis Planner Name"; Rec."SBC Kinaxis Planner Name")
            {
                ApplicationArea = All;
                // Editable = false;
                ToolTip = 'Specifies the value of the SBC Kinaxis Planner Name field.', Comment = '%';
            }
        }
    }
}
