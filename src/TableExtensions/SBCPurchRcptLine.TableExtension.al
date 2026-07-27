/// <summary>
/// TableExtension SBC Purch. Rcpt. Line (ID 50051) extends Record Purch. Rcpt. Line.
/// </summary>
tableextension 50051 "SBC Purch. Rcpt. Line" extends "Purch. Rcpt. Line"
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