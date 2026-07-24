tableextension 50602 "EVM Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(50600; "EVM Payment Purpose Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EVM Payment Purpose Code';
            TableRelation = "EVM Payment Purpose"."Payment Purpose Code";
        }
    }
}