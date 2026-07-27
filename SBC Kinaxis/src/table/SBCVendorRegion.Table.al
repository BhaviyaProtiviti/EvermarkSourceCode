table 50359 "SBC Vendor Region"
{
    Caption = 'SBC Vendor Region';
    DataClassification = CustomerContent;
    LookupPageId = "SBC Vendor Region List";
    DrillDownPageId = "SBC Vendor Region List";

    fields
    {
        field(1; "SBC Region Code"; Code[20])
        {
            Caption = 'SBC Region Code';
        }
        field(2; "SBC Name"; Text[100])
        {
            Caption = 'SBC Name';
        }
    }
    keys
    {
        key(PK; "SBC Region Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "SBC Region Code", "SBC Name")
        {
        }
    }
}
