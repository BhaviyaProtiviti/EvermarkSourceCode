pageextension 50091 "SBC Sales&Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast("SBC Additional Settings")
        {
            field("EVM Trade Partner Customer No."; Rec."EVM Trade Partner Customer No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Customer No. to use when running SBC Utility - Correct Invoices.';
            }
        }
    }
}