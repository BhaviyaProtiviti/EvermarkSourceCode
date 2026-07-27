table 50701 SBCTradeSetupLines
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group".Code;
            Caption = 'Customer Group';

        }
        field(2; "Global Dimension 1"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(3; CustomerNo; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            Caption = 'Customer No.';
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            Caption = 'Item No.';
        }
        field(5; Type; Enum SBCTradeSetupType)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(6; Base; Enum SBCTradeSetupBase)
        {
            DataClassification = CustomerContent;
            Caption = 'Base';
        }
        field(7; Rate; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rate';
        }
        field(8; "Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Start Date';
        }
        field(9; "End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'End Date';
        }
        field(10; "Expense Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Expense Account';
        }
        field(12; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(13; "Balancing Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Balancing Account';
        }
        field(14; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Customer Group", "Global Dimension 1", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        SBCTradeLines: Record SBCTradeSetupLines;

    begin
        SBCTradeLines.SetRange("Customer Group", "Customer Group");
        SBCTradeLines.SetRange("Global Dimension 1", "Global Dimension 1");
        if SBCTradeLines.FindLast() then
            "Line No." := SBCTradeLines."Line No." + 10000
        else
            "Line No." := 10000;
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