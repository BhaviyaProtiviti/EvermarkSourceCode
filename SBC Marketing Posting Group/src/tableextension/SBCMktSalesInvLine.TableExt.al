tableextension 50143 "SBC Mkt Sales Inv. Line" extends "Sales Invoice Line"
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
