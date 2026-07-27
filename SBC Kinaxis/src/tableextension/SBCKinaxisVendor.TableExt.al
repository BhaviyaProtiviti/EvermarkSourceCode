tableextension 50359 "SBC Kinaxis Vendor" extends Vendor
{
    fields
    {
        field(50359; "SBC Kinaxis Vendor Region"; Code[20])
        {
            Caption = 'SBC Vendor Region';
            DataClassification = CustomerContent;
            TableRelation = "SBC Vendor Region";
        }
        field(50360; "SBC Kinaxis Supplier Grouping"; Text[100])
        {
            Caption = 'SBC Supplier Grouping';
            DataClassification = CustomerContent;
        }
        field(50361; "SBC Kinaxis Send to Kinaxis"; Boolean)
        {
            Caption = 'SBC Send to Kinaxis';
            DataClassification = CustomerContent;
        }
        field(50362; "SBC Kinaxis Vendor UOM"; Code[10])
        {
            Caption = 'SBC Kinaxis Vendor UOM';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
        }
    }
}
