tableextension 50005 "SBC Purch. Cr Memo Header" extends "Purch. Cr. Memo Hdr."
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
