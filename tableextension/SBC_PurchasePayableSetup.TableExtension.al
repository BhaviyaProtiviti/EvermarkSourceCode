tableextension 50117 "SBC Purch Payable Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50000; "SBC Purchase Final Approver"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "User Setup"."User ID";
            ObsoleteState = Removed;
        }
        field(50001; "SBC Purch Appr % Margin"; Decimal)
        {
            Caption = 'SBC Purchase Doc Approval % Margin';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(50002; "SBC Never Delete PO's"; Boolean)
        {
            Caption = 'SBC Never Delete PO''s';
            DataClassification = CustomerContent;
        }
        field(50003; "SBC Require Purch. Price"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Require Purchase Price';
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