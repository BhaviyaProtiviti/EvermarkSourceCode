tableextension 50003 "SBC Purch. Inv. Header" extends "Purch. Inv. Header"
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
