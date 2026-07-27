tableextension 50353 "SBC CA Sales Header" extends "Sales Header"
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
