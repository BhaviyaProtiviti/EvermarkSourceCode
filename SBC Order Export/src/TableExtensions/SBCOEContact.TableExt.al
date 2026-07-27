/// <summary>
///  Adds fields to the Contact table to support the SBCOE Export Email Group table.
/// </summary>
tableextension 50060 "SBCOE Contact" extends Contact
{
    fields
    {
        field(50061; "SBCOE Email Group Code"; Code[20])
        {
            Caption = 'Email Group Code';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'The list of emails associated with this export.';
            Enabled = false;
            TableRelation = "SBCOE Export Email Group"."Email Group Code";
        }
        field(50062; "SBCOE Export Recipient"; Boolean)
        {
            Caption = 'Order Export Recipient';
            DataClassification = CustomerContent;
            Description = 'If this field is set, a contact is allowed to receive order export spreadsheets via Email.';
        }
    }
}
