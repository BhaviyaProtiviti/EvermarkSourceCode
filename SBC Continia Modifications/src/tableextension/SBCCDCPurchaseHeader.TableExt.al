tableextension 50161 "SBC CDC Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(50160; "SBC CDC Our Order No."; Text[250])
        {
            Caption = 'SBC CDC Our Order No.';
            DataClassification = CustomerContent;
        }
    }
}
