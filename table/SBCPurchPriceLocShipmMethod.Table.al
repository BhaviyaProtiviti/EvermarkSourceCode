table 50001 "SBCPurchPriceLoc/ShipmMethod"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(5; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            MinValue = 0;
        }
        field(6; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(7; "Shipment Method Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method".Code;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Vendor No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Location Code", "Shipment Method Code")
        {
            Clustered = true;
        }
    }
}