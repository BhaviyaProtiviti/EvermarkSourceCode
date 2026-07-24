pageextension 50609 "TIG Payment Methods Ext" extends "Payment Methods"
{
    layout
    {
        addafter(Description)
        {
            field("TIG Payment Type"; Rec."TIG Payment Type")
            {
                applicationarea = all;
            }
        }
    }
}