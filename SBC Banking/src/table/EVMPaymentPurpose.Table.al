table 50600 "EVM Payment Purpose"
{
    Caption = 'Payment Purpose';
    DrillDownPageId = "EVM Payment Purposes";
    LookupPageId = "EVM Payment Purposes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Country Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country Code';
            TableRelation = "Country/Region".Code;
        }
        field(2; "Payment Purpose Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Purpose Code';
        }
        field(3; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Country Code", "Payment Purpose Code")
        {
            Clustered = true;
        }
    }
}