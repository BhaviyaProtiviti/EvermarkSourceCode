tableextension 50360 "SBC Kinaxis Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(50359; "SBC Kinaxis Planner Name"; Code[20])
        {
            Caption = 'SBC Kinaxis Planner Name';
            DataClassification = CustomerContent;
        }
        field(50360; "SBC Kinaxis API Updated"; Boolean)
        {
            Caption = 'SBC Kinaxis API Updated';
            DataClassification = CustomerContent;
        }
    }
}
