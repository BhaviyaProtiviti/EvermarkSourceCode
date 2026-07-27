tableextension 50115 "SBC Main G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(50000; "SBC Approval Entry No."; Integer)
        {
            Caption = 'SBC Approval Entry No.';
            DataClassification = CustomerContent;
        }
        field(50001; "SBC Incoming Doc No."; Integer)
        {
            Caption = 'SBC Incoming Doc No.';
            DataClassification = CustomerContent;
        }
    }
}
