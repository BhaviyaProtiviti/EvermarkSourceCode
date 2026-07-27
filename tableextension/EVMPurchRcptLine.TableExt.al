tableextension 50010 "EVM Purch. Rcpt. Line" extends "Purch. Rcpt. Line"
{
    fields
    {
        field(50009; "EVM Expected Ship Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Ship Date';
        }
    }
}