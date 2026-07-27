tableextension 50087 "SBC Sales&Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50080; "EVM Trade Partner Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EVM Trade Partner Customer No.';
            TableRelation = Customer."No.";
        }
    }
}