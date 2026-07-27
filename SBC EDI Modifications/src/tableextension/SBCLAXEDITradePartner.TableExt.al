tableextension 50154 "SBC LAX EDI Trade Partner" extends "LAX EDI Trade Partner"
{
    fields
    {
        field(50150; "SBC RecDoc PostDate Field Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'SBC 810 Document Posting Date Field Name';
        }
    }
}