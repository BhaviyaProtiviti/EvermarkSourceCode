tableextension 50114 "SBC Prod. Order Line" extends "Prod. Order Line"
{
    fields
    {
        field(50100; "SBC Override Exact Qty."; Boolean)
        {
            Caption = 'Override Pallet Rounding';
            DataClassification = CustomerContent;
        }
    }
}
