/// <summary>
/// TableExtension SBC Purch. Inv. Line (ID 50050) extends Record Purch. Inv. Line.
/// </summary>
tableextension 50052 "SBC Purch. Inv. Line" extends "Purch. Inv. Line"
{
   fields
    {
         field(50042; "SBC Plant Code"; Code[20])
        {
            Caption = 'SBC Plant Code';
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'The code that identifies the supplier plant for the item.';
            TableRelation = "SBC Plant"."Plant Code";
        }
        field(50043; "SBC Plant Item No."; Code[20])
        {
            Caption = 'SBC Plant Item No.';
            DataClassification = CustomerContent;
            Description = 'The Plant-specific item number.';

        }
    }
}