tableextension 50030 "EVM Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50030; "EVM Expected Receipt Date Calculation"; DateFormula)
        {
            DataClassification = CustomerContent;
            Caption = 'EVM Expected Receipt Date Calculation';
            InitValue = 0D;
        }
    }
}