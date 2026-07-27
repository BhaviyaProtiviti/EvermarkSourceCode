pageextension 50351 "SBC CA Import Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("SBC CA Import Cust.";Rec."SBC CA Import Cust.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer is to be used to create Sales Invoices and Sales Cr. Memos in the Canadian Sales Import process.';
            }
        }
    }
}
