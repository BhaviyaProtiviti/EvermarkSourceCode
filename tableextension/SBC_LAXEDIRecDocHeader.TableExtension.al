tableextension 50111 "SBC_EDI Rec. Document Header" extends "LAX EDI Receive Document Hdr."
{
    fields
    {
        field(50000; "SBC Sales Order No."; Code[20])
        {
            Caption = 'SBC Sales Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the Sales Order Number that is being referenced in the EDI file.';
            Editable = false;
        }
        field(50001; "SBC Purchase Order No."; Code[20])
        {
            Caption = 'SBC Purchase Order No.';
            DataClassification = CustomerContent;
            Description = 'This is the Purchase Order Number that is being referenced in the EDI file.';
            Editable = false;
        }
        field(50002; "SBC Vendor Invoice No."; Text[250])
        {
            Caption = 'SBC Vendor Invoice No.';
            DataClassification = CustomerContent;
            Description = 'This is the Vendor Invoice Number that is being referenced in the EDI file.';
            Editable = false;
        }
        field(50003; "SBC Total Invoice Amount"; Text[250])
        {
            Caption = 'SBC Total Invoice Amount';
            DataClassification = CustomerContent;
            Description = 'This is the Total Invoice Amount that is being referenced in the EDI file.';
            Editable = false;
        }
    }
}