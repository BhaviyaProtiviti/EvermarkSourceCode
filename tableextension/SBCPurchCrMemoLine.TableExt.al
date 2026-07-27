tableextension 50006 "SBC Purch. Cr. Memo Line" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(50002; "SBC Vendor Group Code"; Code[20])
        {
            Caption = 'SBC Vendor Group Code';
            DataClassification = CustomerContent;
            Description = 'This is the related Vendor Group Code.';
        }
    }
}
