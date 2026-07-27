/// <summary>
/// TableExtension SBC Ship-to Address (ID 50046) extends Record Ship-to Address.
/// </summary>
tableextension 50046 "SBC Ship-to Address" extends "Ship-to Address"
{
    fields
    {
        field(50040; "SBC Emerson Ship-to Code"; Code[20])
        {
            Caption = 'SBC Emerson Ship-to Code';
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'The Emerson Ship-To Code for the Ship-To Address.';
        }
    }
}