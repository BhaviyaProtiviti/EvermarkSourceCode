tableextension 50109 "SBC_Work center" extends "Work Center"
{
    fields
    {
        field(50000; "SBC Vendor Location"; Code[20])
        {
            Caption = 'SBC Vendor Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = filter(false));
            Description = 'This is the related Production Order No..';
        }
    }
}