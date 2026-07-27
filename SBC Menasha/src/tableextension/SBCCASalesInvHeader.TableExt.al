tableextension 50354 "SBC CA Sales Inv. Header" extends "Sales Invoice Header"
{
    fields
    {
        field(50350; "SBC CA Sales Doc Import"; Boolean)
        {
            Caption = 'Canadian Sales Doc Import';
            DataClassification = CustomerContent;
        }
    }
}
