tableextension 50141 "SBC Mkt Item" extends Item
{
    fields
    {
        field(50141; "SBC Has Marketing Display"; Boolean)
        {
            Caption = 'SBC Has Marketing Display';
            DataClassification = CustomerContent;

        }
        field(50142; "SBC Marketing Posting Group"; Code[20])
        {
            Caption = 'SBC Marketing Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
    }
}
