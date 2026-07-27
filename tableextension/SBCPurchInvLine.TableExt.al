tableextension 50004 "SBC Purch. Inv. Line 2" extends "Purch. Inv. Line"
{
    fields
    {
        field(50002; "SBC Vendor Group Code"; Code[20])
        {
            Caption = 'SBC Vendor Group Code';
            DataClassification = CustomerContent;
            Description = 'This is the related Vendor Group Code.';
        }
        field(50003; "SBC Buy-From Vendor Name"; Text[100])
        {
            Caption = 'Buy-from Vendor Name';
            CalcFormula = lookup(Vendor.Name where("No." = field("Buy-from Vendor No.")));
            FieldClass = FlowField;
        }
        field(50009; "EVM Expected Ship Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Ship Date';
        }
    }
}
