tableextension 50130 "SBC Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "SBC Commercial Invoice Note"; Text[2048])
        {
            Caption = 'Commercial Invoice Note';
            DataClassification = CustomerContent;
        }
        field(50001; "SBC Use Location Pricing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Location Pricing';
        }
        field(50002; "SBC Customer Dimension Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Dimension Code';
            TableRelation = Dimension.Code;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
}