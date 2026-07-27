table 50101 "SBC AmEx Remittance Import"
{
    Caption = 'SBC AmEx Remittance Import';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SBC Entry No."; Integer)
        {
            Caption = 'SBC Import Entry No.';
        }
        field(2; "SBC Line No."; Integer)
        {
            Caption = 'SBC Import Line No.';
        }
        field(3; "SBC Import Date"; Date)
        {
            Caption = 'SBC Import Date';
        }
        field(5; "SBC AmEx Employee Name"; Text[250])
        {
            Caption = 'SBC AmEx Employee Name';
        }
        field(6; "SBC AmEx Employee ID"; Text[30])
        {
            Caption = 'SBC AmEx Employee ID';
        }
        field(7; "SBC AmEx Balance Due"; Decimal)
        {
            Caption = 'SBC AmEx Balance Due';
        }
        field(8; "SBC AmEx Payment Due"; Decimal)
        {
            Caption = 'SBC AmEx Payment Due';
        }
        field(9; "SBC AmEx Card Member Status"; Text[20])
        {
            Caption = 'SBC AmEx Card Member Status';
        }
        field(10; "SBC AmEx Control Acct Name"; Text[150])
        {
            Caption = 'SBC AmEx Basic Control Acct Name';
        }
        field(11; "SBC AmEx Control Acct No."; Text[20])
        {
            Caption = 'SBC AmEx Basic Control Acct. No.';
        }
        field(12; "SBC AmEx Billed Currency"; Text[5])
        {
            Caption = 'SBC AmEx Billed Currency';
        }
        field(13; "SBC Amex Cost Center"; Text[20])
        {
            Caption = 'SBC Amex Cost Center';
        }
        field(14; "SBC AmEx Report Date"; Date)
        {
            Caption = 'SBC AmEx Report Date';
        }
        field(20; "SBC Payment Created"; Boolean)
        {
            Caption = 'AmEx Payment Created';
        }
    }
    keys
    {
        key(PK; "SBC Entry No.", "SBC Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if Rec."SBC Entry No." = 0 then 
            Rec."SBC Entry No." := GetNextEntryNo();
    end;

    procedure GetNextEntryNo(): Integer
    var
        SBCAmExRemittanceImport: Record "SBC AmEx Remittance Import";
    begin
        if SBCAmExRemittanceImport.FindLast() then
            exit(SBCAmExRemittanceImport."SBC Entry No." + 1)
        else
            exit(1);
    end;
}
