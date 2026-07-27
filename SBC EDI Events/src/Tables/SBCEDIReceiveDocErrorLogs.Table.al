table 50141 "SBC EDI Receive Doc Error Logs"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SBC Internal Doc. No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Internal Doc. No.';
        }
        field(2; "SBC Trade Partner No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Trade Partner No.';
        }
        field(3; "SBC EDI Document No."; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Document No.';
        }
        field(4; "SBC Error Message Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message Text';
        }
        field(5; "SBC Error Occured At"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Error Occured At';
        }
        field(6; "SBC Error Resolved At"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Error Resolved At';
        }
    }

    keys
    {
        key(PK; "SBC Internal Doc. No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}