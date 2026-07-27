pageextension 50159 "SBC Customer Templ. Card" extends "Customer Templ. Card"
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