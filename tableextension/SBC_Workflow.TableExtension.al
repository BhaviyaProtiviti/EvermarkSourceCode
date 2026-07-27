tableextension 50116 "SBC Workflow" extends Workflow
{
    fields
    {
        field(50000; "SBC Custom Purch Workflow"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Custom Purch Doc. Workflow';
            Description = 'Enable custom purchase document workflow for non inventory';
        }
        field(50001; "SBC Purchase Final Approver"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "User Setup"."User ID";
            Caption = 'Final Approver';
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

    var
        myInt: Integer;
}