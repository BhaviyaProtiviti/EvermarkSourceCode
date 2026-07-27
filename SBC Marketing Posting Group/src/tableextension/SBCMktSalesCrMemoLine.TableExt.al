tableextension 50145 "SBC Mkt Sales Cr. Memo Line" extends "Sales Cr.Memo Line"
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
