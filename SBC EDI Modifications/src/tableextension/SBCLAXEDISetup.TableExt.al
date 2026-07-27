tableextension 50150 "SBC LAX EDI Setup" extends "LAX EDI Setup"
{
    fields
    {
        field(50150; "SBC 945 Adjust Inventory"; Boolean)
        {
            Caption = '945 Adjust Inventory';
            DataClassification = CustomerContent;
        }
        field(50151; "SBC 945 Journal Template Name"; Code[10])
        {
            Caption = '945 Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";
        }
        field(50152; "SBC 945 Journal Batch Name"; Code[10])
        {
            Caption = '945 Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("SBC 945 Journal Template Name"), "Item Tracking on Lines" = const(true));
        }
        field(50153; "SBC Journal Location Code"; Code[10])
        {
            Caption = 'Journal Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(50154; "SBC 945 Document No."; Code[20])
        {
            Caption = '945 Document No.';
            DataClassification = CustomerContent;
        }
        field(50160; "SBC 846 Positive Adj. Only"; Boolean)
        {
            Caption = '846 Inforce Inventory Floor Zero';
            DataClassification = CustomerContent;
        }        
        field(50165; "SBC 810 Allow Create Shipment"; Boolean)
        {
            Caption = '810 Allows Create Shimpents';
            DataClassification = CustomerContent;
        }
        field(50166; "SBC 810 Journal Template Name"; Code[10])
        {
            Caption = '810 Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";
        }
        field(50167; "SBC 810 Journal Batch Name"; Code[10])
        {
            Caption = '810 Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("SBC 945 Journal Template Name"), "Item Tracking on Lines" = const(true));
        }
        field(50168; "SBC 810 Document No."; Code[20])
        {
            Caption = '810 Document No.';
            DataClassification = CustomerContent;
        }        
        field(50169; "SBC Skip Trans Order 945"; Boolean)
        {
            Caption = 'Skip Transfer Order 945 Inv. Adj.';
            DataClassification = CustomerContent;
        }
    }
}
