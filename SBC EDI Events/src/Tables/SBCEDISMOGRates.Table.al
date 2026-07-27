table 50081 "SBCEDI SMOG Rates"
{
    Caption = 'SBCEDI SMOG Rates';
    DataClassification = CustomerContent;
    Description = 'This table is used to store SMOG rates. Logic related to this table is in the SBCEDI Event Helper codeunit.';
    DrillDownPageId = "SBCEDI SMOG Rates";
    LookupPageId = "SBCEDI SMOG Rates";


    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            Description = 'Customer the SMOG rate applies to.';
            TableRelation = Customer."No.";
        }
        field(3; "SMOG Rate"; Decimal)
        {
            Caption = 'SMOG Rate';
            Description = 'SMOG rate to be applied to the Customer.';
            DecimalPlaces = 4;
            InitValue = 30.0000;
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
            Description = 'Start date for the SMOG rate.';
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
            Description = 'End date for the SMOG rate.';
        }
        field(10; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            Description = 'The Gen. Bus. Posting Group to be used when this rate is applied.';
            TableRelation = "Gen. Business Posting Group".Code;
        }
        field(11; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            Description = 'Customer Posting Group to be used when this rate is applied.';
            TableRelation = "Customer Posting Group".Code;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Unique; "Customer No.", "SMOG Rate")
        {
            Description = 'Unique key for Customer No. and SMOG Rate';
            Unique = true;
        }
        key(Sorting;"SMOG Rate","Start Date","End Date")
        {
            Description = 'Sorting key for SMOG Rate, Start Date, and End Date';
        }
    }
}