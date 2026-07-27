tableextension 50153 "SBC Customer Templ." extends "Customer Templ."
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