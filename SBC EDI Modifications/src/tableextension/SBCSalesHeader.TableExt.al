tableextension 50180 "SBC Sales Header" extends "Sales Header"
{
    fields
    {
        field(50100; "SBC ODW Update Ship Date"; Boolean)
        {
            Caption = 'ODW Update Planned Ship Date ';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
