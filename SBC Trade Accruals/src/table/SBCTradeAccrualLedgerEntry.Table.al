table 50702 SBCTradeAccrualLedgerEntry
{
    fields
    {
        field(1; PostingDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(2; documentNo; Code[20])
        {
            Caption = 'Document No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Invoice Header"."No." where("Order No." = field(orderNo)));
        }
        field(3; orderNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order No.';
        }
        field(4; OrderLineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Line No.';
        }
        field(5; ItemNo; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            Caption = 'Item No.';
        }
        field(6; CustomerCode; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Code';
            ObsoleteState = Pending;
            ObsoleteReason = 'Use CustomerNo instead.';
        }
        field(7; CustomerNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
        }
        field(8; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
        }
        field(9; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(10; CustomerGroup; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Group';
        }
        field(11; GlobalDimension1; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(12; GlobalDimension2; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(13; GlobalDimension4; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,4';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4), Blocked = const(false));
            Caption = 'Shortcut Dimension 4 Code';
        }
        field(14; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(15; Type; Enum SBCTradeSetupType)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(16; Base; Enum SBCTradeSetupBase)
        {
            DataClassification = CustomerContent;
            Caption = 'Base';
        }
        field(17; Rate; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Rate';
        }
        field(18; LineNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(19; "Derived From Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Derived From Amount';
        }

    }

    keys
    {
        key(Key1; PostingDate, orderNo, LineNo)
        {
            Clustered = true;
        }
    }

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