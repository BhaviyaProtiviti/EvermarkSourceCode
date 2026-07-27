tableextension 50362 "SBC Kinaxis Production Order" extends "Production Order"
{
    fields
    {
        field(50359; "SBC Kinaxis Planner Name"; Code[20])
        {
            Caption = 'SBC Kinaxis Planner Name';
            DataClassification = CustomerContent;
        }
        field(50360; "SBC Kinaxis Purchase Order No."; Code[20])
        {
            Caption = 'SBC Kinaxis Purchase Order No.';
            DataClassification = CustomerContent;
        }
        field(50361; "SBC Kinaxis Expected Ship Date"; Date)
        {
            Caption = 'SBC Kinaxis Expected Ship Date';
            DataClassification = CustomerContent;
        }
    }
}
