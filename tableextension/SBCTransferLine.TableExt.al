tableextension 50113 "SBC_Transfer Line" extends "Transfer Line"
{
    fields
    {
        field(50100; "SBC Override Exact Qty."; Boolean)
        {
            Caption = 'Override Pallet Rounding';
            DataClassification = CustomerContent;
        }
        field(50101; "SBC Line Weight"; Decimal)
        {
            Caption = 'SBC Line Weight';
            DataClassification = CustomerContent;
        }
        field(50102; "SBC Line Weight UOM"; Decimal)
        {
            Caption = 'SBC Line Weight Per UOM';
            DataClassification = CustomerContent;
        }
        field(50103; "SBC Line Cubage"; Decimal)
        {
            Caption = 'SBC Line Cubage';
            DataClassification = CustomerContent;
        }
        field(50104; "SBC Line Cubage UOM"; Decimal)
        {
            Caption = 'SBC Line Cubage Per UOM';
            DataClassification = CustomerContent;
        }
        field(50105; "SBC Line Pallet"; Decimal)
        {
            Caption = 'SBC Line Pallet';
            DataClassification = CustomerContent;
        }
        field(50106; "SBC Line Pallet UOM"; Decimal)
        {
            Caption = 'SBC Line Pallet Per UOM';
            DataClassification = CustomerContent;
        }
    }
}