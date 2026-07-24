tableextension 50601 "TIG Bank Clearing Standard" extends "Bank Clearing Standard"
{
    fields
    {
        field(50600; "TIG Clearing System ID Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Clearing System ID Code';
        }
    }
}