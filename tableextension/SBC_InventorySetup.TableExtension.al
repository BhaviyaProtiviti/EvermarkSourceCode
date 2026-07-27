tableextension 50103 "SBC_Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        field(50000; "SBC Layer Unit of Measure"; Code[10])
        {
            Caption = 'SBC Layer Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            Description = 'This is the Layer unit of measure used in sending EDI 832 Master catalog.';
        }
        field(50001; "SBC Pallet Unit of Measure"; Code[10])
        {
            Caption = 'SBC Pallet Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            Description = 'This is the Pallet unit of measure used in sending EDI 832 Master catalog.';
        }

        field(50002; "SBC Match Inventory Doc No."; Code[20])
        {
            // ODW EDI 846 enhancement
            Caption = 'Matching Invt Doc No.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
            Description = 'This is the number series code used for matching inventory for ODW 846';
        }
        field(50003; "SBC Match Invt Journal Templ"; Code[20])
        {
            // ODW EDI 846 enhancement
            Caption = 'Matching Invt Journal Template';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template".Name;
            Description = 'This is the itme journal template code used for matching inventory for ODW 846';
        }
        field(50004; "SBC Match Invt Journal Batch "; Code[20])
        {
            // ODW EDI 846 enhancement
            Caption = 'Matching Invt Journal Batch';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("SBC Match Invt Journal Templ"));
            Description = 'This is the item journal batch code used for matching inventory for ODW 846';
        }
        field(50005; "SBC Parse Lot Code"; Boolean)
        {
            // SBC Expiration Date Calculation
            Caption = 'SBC Parse Lot Code';
            DataClassification = CustomerContent;
        }
        field(50006; "SBC Lot Code Date Format"; Integer)
        {
            // SBC Expiration Date Calculation
            Caption = 'SBC Lot Code Date Format';
            DataClassification = CustomerContent;
            TableRelation = Language."Windows Language ID";
            ValidateTableRelation = false;
        }
        field(50007; "SBC Adjustment Batch"; Code[10])
        {
            // SBC Expiration Date Calculation
            Caption = 'SBC Adjustment Batch';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name Where("Journal Template Name" = const('RECLASS'));
        }
        field(50008; "SBC AdjmtItemJournalTemplate"; Code[10])
        {
            // SBC Expiration Date Calculation
            Caption = 'SBC Adjustment Item Journal Template';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template".Name where("Name" = const('RECLASS'));
        }
    }
}