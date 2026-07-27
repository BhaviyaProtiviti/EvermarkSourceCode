tableextension 50168 "SBC Purch Recpt Ext" extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50100; "SBC Transfer Order No."; Code[20])
        {
            Caption = 'Transfer Order No.';
        }
        field(50101; "SBC Posted Trans Shipment No."; Code[20])
        {
            Caption = 'Posted Transfer Shipment No.';
        }
        field(50102; "SBC Posted Trans Receipt No."; Code[20])
        {
            Caption = 'Posted Transfer Receipt No.';
        }
    }
}
