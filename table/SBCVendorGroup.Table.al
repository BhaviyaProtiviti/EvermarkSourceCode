table 50000 "SBC Vendor Group"
{
    Caption = 'SBC Vendor Group';
    DataCaptionFields = "SBC Code", "SBC Description";
    DataClassification = CustomerContent;
    DrillDownPageId = "SBC Vendor Groups";
    
    fields
    {
        field(1; "SBC Code"; Code[20])
        {
            Caption = 'SBC Code';
        }
        field(2; "SBC Description"; Text[100])
        {
            Caption = 'SBC Description';
        }
    }
    keys
    {
        key(PK; "SBC Code")
        {
            Clustered = true;
        }
    }
     fieldgroups
    {
        fieldgroup(DropDown; "SBC Code", "SBC Description")
        {
        }
    }
}
