tableextension 50609 "TIG Payment Method Ext" extends "Payment Method"
{
    fields
    {
        field(50600; "TIG Payment Type"; Enum "TIG Payment Type")
        {
            caption = 'Payment Type';
            DataClassification = CustomerContent;
        }
    }
}