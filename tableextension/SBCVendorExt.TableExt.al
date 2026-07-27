tableextension 50001 "SBC Vendor Ext" extends Vendor
{
    fields
    {
        field(50000; "SBC Vendor Group Code"; Code[20])
        {
            Caption = 'SBC Vendor Group Code';
            DataClassification = CustomerContent;
            TableRelation = "SBC Vendor Group";
        }
        field(50001; "SBC Sensitive Vendor"; Boolean)
        {
            Caption = 'SBC Sensitive Vendor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (Rec."SBC Sensitive Vendor") and (Rec."SBC Vendor Group Code" <> '') then
                    Rec."SBC Vendor Group Code" := '';
            end;
        }
        field(50002; "SBC Vendor Region"; Code[20])
        {
            Caption = 'SBC Vendor Region';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
            ObsoleteReason = 'Moved to Kinaxis app';
            ObsoleteState = Removed;
        }
        field(50003; "SBC Supplier Grouping"; Text[100])
        {
            Caption = 'SBC Supplier Grouping';
            DataClassification = CustomerContent;
            ObsoleteReason = 'Moved to Kinaxis app';
            ObsoleteState = Removed;
        }
        field(50004; "SBC Send to Kinaxis"; Boolean)
        {
            Caption = 'SBC Send to Kinaxis';
            DataClassification = CustomerContent;
            ObsoleteReason = 'Moved to Kinaxis app';
            ObsoleteState = Removed;
        }
        field(50005; "SBC Use Buy-From Pricing"; Boolean)
        {
            Caption = 'SBC Use Buy-From Pricing';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (Rec."No." <> Rec."Pay-to Vendor No.") and (Rec."SBC Use Buy-From Pricing") then
                    Error('You can only set the "SBC Use Buy-From Pricing" field to true when the vendor is also the pay-to vendor.');
            end;
        }
    }
}
