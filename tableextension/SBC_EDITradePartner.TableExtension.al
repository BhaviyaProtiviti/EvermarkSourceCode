tableextension 50107 "SBC_EDI Trade Partner" extends "LAX EDI Trade Partner"
{
    fields
    {
        field(50000; "SBC Item Master Sync."; Boolean)
        {
            Caption = 'SBC Item Master Sync.';
            DataClassification = CustomerContent;
            Description = 'This is a flag allowing to synchronize from the Item Master records with the EDI Trade Partner Item table for this Trade Partner.';
        }
    }
}