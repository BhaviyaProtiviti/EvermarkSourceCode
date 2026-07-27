tableextension 50149 "SBC Invt. Post Buffer" extends "Invt. Posting Buffer"
{
    fields
    {
        field(50141; "SBC Marketing Posting Group"; Code[20])
        {
            Caption = 'SBC Marketing Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(50142; "SBC Marketing Amount"; Decimal)
        {
            Caption = 'SBC Marketing Amount';
            DataClassification = CustomerContent;
        } 
    }
}
