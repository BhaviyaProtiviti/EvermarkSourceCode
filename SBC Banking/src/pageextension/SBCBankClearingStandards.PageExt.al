pageextension 50601 "SBC Bank Clearing Standards" extends "Bank Clearing Standards"
{
    layout
    {
        addlast(Group)
        {
            field("TIG Clearing System ID Code"; "TIG Clearing System ID Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Clearing System ID Code (Ex: USABA, CACPA)';
            }
        }
    }
}