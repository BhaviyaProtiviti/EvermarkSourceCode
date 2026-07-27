tableextension 50126 "SBC Concur Vend Ledger Entry" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50100; "SBC Employee ID"; text[30])
        {
            Caption = 'SBC Empmloyee ID';
            DataClassification = CustomerContent;
        }
    }
}
