pageextension 50163 "SBC Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("SBC Auto Cancel Back Order"; Rec."SBC Auto Cancel Back Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that Back Orders will be auto canceled for this Customer.';
            }
        }
    }
}