/// <summary>
/// Table SBC Contract Mfg. Import Header (ID 50250).
/// </summary>
table 50350 "SBC Contract Mfg. Header"
{
    Caption = 'SBC Contract Mfg. Header';
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

            trigger OnValidate()
            begin
                Handler.OnValidateImportName(Rec, xRec);
            end;
        }
        field(10; "SBC Import Receive Date"; Date)
        {
            Caption = 'Import Received Date';
        }
        field(11; "SBC Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        field(12; "SBC Has Line Errors"; Boolean)
        {
            Caption = 'Has Line Errors';
        }
        field(25; "SBC Item Journal Created"; Boolean)
        {
            Caption = 'Item Journal Created';
        }
        field(26; "SBC Item Journal Doc No."; Code[20])
        {
            Caption = 'Item Journal Doc. No.';
        }
        field(100; "SBC No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
    }
    keys
    {
        key(PK; "SBC Import Document No.", "SBC Contract Source", "SBC Contract Type")
        {
            Clustered = true;
        }

    }

    var
        Handler: Codeunit "SBC TblHdlr Contract Mfg. Hdr";

    trigger OnInsert()
    begin
        Handler.InitInsert(Rec, xRec);
    end;

    trigger OnDelete()
    begin
        Handler.OnDeleteContractMfgHeader(Rec);
    end;
    
    procedure ArchiveProcessedLines()
    begin
        Handler.ArchivePartialProcessedContract(Rec);
    end;
}
