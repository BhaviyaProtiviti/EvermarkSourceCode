/// <summary>
/// Table SBC Plant (ID 50040).
/// </summary>
table 50040 "SBC Plant"
{
    Caption = 'SBC Plant';
    DataClassification = EndUserPseudonymousIdentifiers;
    
    
    fields
    {
        field(1; "Plant Code"; Code[20])
        {
            Caption = 'Plant Code';
            DataClassification = EndUserPseudonymousIdentifiers;
            Description = 'This identifies the SBC Plant.';
        }
        field(10; "Plant Description"; Text[200])
        {
            Caption = 'Plant Description';
            DataClassification = CustomerContent;
            Description = 'A description of the SBC Plant.';
        }
        field(11; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
            Description = 'If this is not set, the SBC plant will not be processed against by solutions that use it.';
        }
    }
    keys
    {
        key(PK; "Plant Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Plant Code", "Plant Description", Enabled)
        {
        }
        
        
        fieldgroup(Brick; "Plant Code", "Plant Description", Enabled)
        {
        }
    }
}