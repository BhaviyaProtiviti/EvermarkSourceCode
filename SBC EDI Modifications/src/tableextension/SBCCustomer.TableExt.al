tableextension 50152 "SBC Customer Ext" extends Customer
{
    fields
    {
        field(50150; "SBC Auto Cancel Back Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'SBC Auto Cancel Back Order';
        }
    }
}