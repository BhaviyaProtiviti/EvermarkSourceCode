tableextension 50110 "SBC_Manufacturing Setup" extends "Manufacturing Setup"
{
    fields
    {
        field(50000; "SBC Default Location"; Code[20])
        {
            Caption = 'SBC Default Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = filter(false));
            Description = 'This is the default Location Code assigned to newly created Production Orders.';
        }
        field(50001; "SBC Default Routing Link"; Code[10])
        {
            Caption = 'SBC Default Routing Link';
            DataClassification = CustomerContent;
            TableRelation = "Routing Link";
            Description = 'This is the default Routing Link assigned to subcontracting routings and components.';
        }
    }
}