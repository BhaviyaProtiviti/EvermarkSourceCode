tableextension 50156 "SBCLAXEDIInvAdviceLine" extends "LAX EDI Inventory Advice Line"
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
