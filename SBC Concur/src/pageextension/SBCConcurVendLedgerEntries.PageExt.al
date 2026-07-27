pageextension 50125 "SBC Concur Vend Ledger Entries" extends "Vendor Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("SBC Employee ID";Rec."SBC Employee ID")
            {
                ApplicationArea = All;
                ToolTip = 'SBC Employee ID';
            }
        }
    }
}
