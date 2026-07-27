tableextension 50165 "SBC Purchase Hdr" extends "Purchase Header"
{
    fields
    {
        field(50105; "SBC Create Transfer Order"; Boolean)
        {
            Caption = 'Create Transfer Order';
            DataClassification = ToBeClassified;
        }

        field(50106; "SBC Linked Transfer Order No."; Code[20])
        {
            Caption = 'Linked Transfer Order No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
