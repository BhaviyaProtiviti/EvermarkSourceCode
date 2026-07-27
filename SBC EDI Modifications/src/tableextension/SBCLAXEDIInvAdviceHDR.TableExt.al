tableextension 50157 "SBCLAXEDIInvAdviceHDR" extends "LAX EDI Inventory Advice Hdr."
{
    fields
    {
        field(50100; "ADJ Code"; Text[20])
        {
            Caption = 'Adjustment Code';
            DataClassification = CustomerContent;
        }
    }
}
