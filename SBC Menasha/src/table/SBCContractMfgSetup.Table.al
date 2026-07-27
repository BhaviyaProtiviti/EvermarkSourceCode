/// <summary>
/// Table SBC Contract Mfg. Setup (ID 50254).
/// </summary>
table 50351 "SBC Contract Mfg. Setup"
{
    Caption = 'SBC Contract Mfg. Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "SBC Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "SBC No. Series"; Code[20])
        {
            Caption = 'Contract Mfg. Import No. Series';
            TableRelation = "No. Series";
        }
        field(3; "SBC Processed No. Series"; Code[20])
        {
            Caption = 'Processed Contract Mfg. Import No. Series';
        }
        field(4; "SBC Prod. Order Jnl Template"; Code[10])
        {
            Caption = 'Prod. Order Jnl. Template';
        }
        field(5; "SBC Prod. Order Jnl. Batch"; Code[10])
        {
            Caption = 'Menasha Inventory Jnl. Batch Name';
        }
        field(20; "SBC Menasha Item Jnl. Template"; Code[10])
        {
            Caption = 'Menasha Inv. Journal Template Name';
            TableRelation = "Item Journal Template";
        }
        field(21; "SBC Menasha Item Jnl. Batch"; Code[10])
        {
            Caption = 'Menasha Inventory Jnl. Batch Name';
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("SBC Menasha Item Jnl. Template"), "No. Series" = filter(<> ''));
        }
        field(22; "SBC Menasha Item Jnl. Location"; Code[20])
        {
            Caption = 'Menasha Item Jnl. Default Location Code';
            TableRelation = Location;
        }
        field(50; "SBC WestRock Item Jnl Template"; Code[10])
        {
            Caption = 'WestRock Inv. Journal Template Name';
            TableRelation = "Item Journal Template";
        }
        field(51; "SBC WestRock Item Jnl. Batch"; Code[10])
        {
            Caption = 'WestRock Inventory Jnl. Batch Name';
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("SBC WestRock Item Jnl Template"), "No. Series" = filter(<> ''));
        }
        field(52; "SBC WestRock Item Jnl Location"; Code[20])
        {
            Caption = 'WestRock Item Jnl. Default Location Code';
            TableRelation = Location;
        }
        field(53; "SBC WR Consumption Location"; code[10])
        {
            Caption = 'Westrock Consumption Location';
            tableRelation = Location;
        }
    }
    keys
    {
        key(PK; "SBC Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    /// <summary>
    /// GetRecordOnce.
    /// </summary>
    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Rec.Get();
        RecordHasBeenRead := true;
    end;
}
