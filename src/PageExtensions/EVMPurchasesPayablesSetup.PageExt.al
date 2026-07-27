pageextension 50030 "EVM Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("EVM Expected Receipt Date Calculation"; Rec."EVM Expected Receipt Date Calculation")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Date Formula to use when calculating the Expected Receipt Date from the Expected Ship Date.';
            }
        }
    }
}