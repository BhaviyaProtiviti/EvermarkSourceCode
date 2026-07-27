tableextension 50106 "SBC_Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(50000; "SBC Production Order No."; Code[20])
        {
            Caption = 'SBC Production Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the related Production Order No..';
        }
        field(50001; "SBC Transfer Order No."; Code[20])
        {
            Caption = 'SBC Transfer Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the related Transfer Order No..';
        }
        field(50002; "SBC Vendor Group Code"; Code[20])
        {
            Caption = 'SBC Vendor Group Code';
            DataClassification = CustomerContent;
            Description = 'This is the related Vendor Group Code.';
        }
    }
}