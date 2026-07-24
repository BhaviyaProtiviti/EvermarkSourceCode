table 50601 EVMAzureFileShareSetup
{
    Caption = 'Azure File Share Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;

        }
        field(2; "Storage Account"; Text[250])
        {
            Caption = 'Storage Account';
            DataClassification = CustomerContent;
        }
        field(3; "File Share"; Text[250])
        {
            Caption = 'File Share';
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

}