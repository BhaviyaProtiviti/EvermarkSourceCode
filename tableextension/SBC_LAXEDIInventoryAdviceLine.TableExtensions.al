tableextension 50101 "SBC_EDIInventoryAdviceLine" extends "LAX EDI Inventory Advice Line"
{
    fields
    {
        field(50000; "SBC Layer Qty. per Sales UOM"; Decimal)
        {
            Caption = 'SBC Layer Qty. per Sales UOM';
            DataClassification = CustomerContent;
        }
        field(50001; "SBC Layer UPC Code"; Code[20])
        {
            Caption = 'SBC Layer UPC Code';
            DataClassification = CustomerContent;
        }
        field(50002; "SBC Layer Width"; Decimal)
        {
            Caption = 'SBC Layer Width';
            DataClassification = CustomerContent;
        }
        field(50003; "SBC Layer Height"; Decimal)
        {
            Caption = 'SBC Layer Height';
            DataClassification = CustomerContent;
        }
        field(50004; "SBC Layer Length"; Decimal)
        {
            Caption = 'SBC Layer Length';
            DataClassification = CustomerContent;
        }
        field(50005; "SBC Layer Weight"; Decimal)
        {
            Caption = 'SBC Layer Weight';
            DataClassification = CustomerContent;
        }
        field(50010; "SBC Pallet Qty. per Sales UOM"; Decimal)
        {
            Caption = 'SBC Pallet Qty. per Sales UOM';
            DataClassification = CustomerContent;
        }
        field(50011; "SBC Pallet UPC Code"; Code[20])
        {
            Caption = 'SBC Pallet UPC Code';
            DataClassification = CustomerContent;
        }
        field(50012; "SBC Pallet Width"; Decimal)
        {
            Caption = 'SBC Pallet Width';
            DataClassification = CustomerContent;
        }
        field(50013; "SBC Pallet Height"; Decimal)
        {
            Caption = 'SBC Pallet Height';
            DataClassification = CustomerContent;
        }
        field(50014; "SBC Pallet Length"; Decimal)
        {
            Caption = 'SBC Pallet Length';
            DataClassification = CustomerContent;
        }
        field(50015; "SBC Pallet Weight"; Decimal)
        {
            Caption = 'SBC Pallet Weight';
            DataClassification = CustomerContent;
        }
    }
}
