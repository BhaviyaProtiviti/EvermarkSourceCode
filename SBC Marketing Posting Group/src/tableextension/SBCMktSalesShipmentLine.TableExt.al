tableextension 50144 "SBC Mkt Sales Shipment Line" extends "Sales Shipment Line"
{
    fields
    {
        field(50141; "SBC Marketing Posting Group"; Code[20])
        {
            Caption = 'SBC Marketing Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
    }
}
