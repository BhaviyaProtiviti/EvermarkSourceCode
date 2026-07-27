tableextension 50124 "SBC Concur Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(50100; "SBC Employee ID"; text[30])
        {
            Caption = 'SBC Empmloyee ID';
            DataClassification = CustomerContent;
        }
        field(50101; "SBC Employee Name"; text[250])
        {
            Caption = 'SBC Concur Employee Name';
            DataClassification = CustomerContent;
        }
    }
}
