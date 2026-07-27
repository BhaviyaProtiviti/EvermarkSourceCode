tableextension 50363 "SBC Kinaxis Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(50360; "SBC Kinaxis API Updated"; Boolean)
        {
            Caption = 'SBC Kinaxis API Updated';
            DataClassification = CustomerContent;
        }
        field(50361; "EVM Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Date';
        }
        field(50362; "EVM Orignl. Req. Recpt. Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Requested Receipt Date';
        }
    }
}
