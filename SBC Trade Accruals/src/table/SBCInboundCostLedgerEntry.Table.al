table 50704 "SBCInboundCostLedgerEntry"
{
    DataClassification = CustomerContent;
    Caption = 'Inbound Cost Ledger Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(3; "Document Type"; Enum SBCInboundDocumentTypes)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(4; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(5; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(6; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(7; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(8; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
        }
        field(9; "Accrual Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Accrual Rate';
        }
        field(10; "Accrual Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Accrual Amount';
        }
        field(11; "Item Ledger Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Ledger Entry No.';
        }
        field(12; GlobalDimension1; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(13; GlobalDimension2; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(14; GlobalDimension4; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,4';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4), Blocked = const(false));
            Caption = 'Shortcut Dimension 4 Code';
        }
        field(15; "Entry Type"; Enum "SBCInboundCostEntryType")
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
        }
        field(16; "Posted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Posted';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        if Posted then
            Error(ErrorMsg, "Entry No.");
    end;

    var
        ErrorMsg: Label 'Cannot delete posted inbound cost entry.', Comment = '%1';
}