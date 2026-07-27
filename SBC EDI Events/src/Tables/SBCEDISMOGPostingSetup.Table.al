/// <summary>
/// Table SBC EDI SMOG Posting Setup (ID 50142).
/// Single-record setup table that stores the Gen. Bus. Posting Groups to apply
/// when processing an EDI 850 Sales Order, depending on whether the document
/// contains a SMOG indicator in the MSG segment.
/// </summary>
table 50143 "SBC EDI SMOG Posting Setup"
{
    Caption = 'SBC EDI SMOG Posting Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBC EDI SMOG Posting Setup";
    LookupPageId = "SBC EDI SMOG Posting Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "SMOGGenBusPostingGroup"; Code[20])
        {
            Caption = 'SMOG Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'Applied to the Sales Order Gen. Bus. Posting Group when the EDI document MSG segment contains the SMOG keyword.';
            TableRelation = "Gen. Business Posting Group".Code;
        }
        field(3; "Non-SMOGGenBusPostingGroup"; Code[20])
        {
            Caption = 'Non-SMOG Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'Applied to the Sales Order Gen. Bus. Posting Group when the EDI document MSG segment does NOT contain the SMOG keyword.';
            TableRelation = "Gen. Business Posting Group".Code;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
