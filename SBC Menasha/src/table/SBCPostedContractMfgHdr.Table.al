/// <summary>
/// Table SBC Posted Contract Mfg Hdr (ID 50352).
/// </summary>
table 50352 "SBC Posted Contract Mfg Hdr"
{
    Caption = 'SBC Posted Contract Mfg Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SBC Import Document No."; Code[20])
        {
            Caption = 'Import Document No.';
        }
        field(2; "SBC Contract Type"; Enum "SBC Contract Type")
        {
            Caption = 'Contract File Type';
        }
        field(3; "SBC Contract Source"; Enum "SBC Contract Source")
        {
            Caption = 'Contract Source';
        }
        field(4; "SBC Import Name"; Text[100])
        {
            Caption = 'Import Name';
        }
        field(10; "SBC Import Receive Date"; Date)
        {
            Caption = 'Import Received Date';
        }
        field(100; "SBC No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
    }
    keys
    {
        key(PK; "SBC Import Document No.", "SBC Contract Type")
        {
            Clustered = true;
        }
    }

    var
    Handler: Codeunit "SBC TblHdlr Contract Mfg. Hdr";

    trigger OnDelete()
    begin
        Handler.OnDeleteContractMfgHeader(Rec);
    end;
}

