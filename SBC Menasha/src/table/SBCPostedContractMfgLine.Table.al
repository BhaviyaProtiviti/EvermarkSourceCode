/// <summary>
/// Table SBC Posted Contract Mfg Line (ID 50354).
/// </summary>
table 50354 "SBC Posted Contract Mfg Line"
{
    Caption = 'Posted Contract Mfg Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SBC Import Document No."; Code[20])
        {
            Caption = 'Import Document No.';
        }
        field(2; "SBC Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "SBC Contract Source"; Enum "SBC Contract Source")
        {
            Caption = 'Contract Source Type';
        }
        field(4; "SBC Contract Type"; Enum "SBC Contract Type")
        {
            Caption = 'Contract File Type';
        }
        field(8; "SBC Production Order No."; Code[20])
        {
            Caption = 'Released Prod. Order No.';
        }
        field(10; "SBC Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
        }
        field(11; "SBC Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(12; "SBC Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "SBC Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(14; "SBC SLED/BBD"; Date)
        {
            Caption = 'SLED/BBD';
        }
        field(15; "SBC Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(16; "SBC Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(17; "SBC UOM Code"; Code[10])
        {
            Caption = 'UOM Code';
        }
        field(18; "SBC Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(30; "SBC Material Type"; Text[50])
        {
            Caption = 'Material Type';
        }
        field(31; "SBC Matl. Group Desc."; Text[100])
        {
            Caption = 'Matl. Group Desc.';
        }
        field(32; "SBC Count of Handling Unit"; Decimal)
        {
            Caption = 'Count of Handling Unit';
        }
    }
    keys
    {
        key(PK; "SBC Import Document No.", "SBC Contract Source", "SBC Contract Type", "SBC Line No.")
        {
            Clustered = true;
        }
        key(P1; "SBC Purchase Order No.")
        {
        }
    }
}

