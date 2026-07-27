tableextension 50155 SBCSalesLineTable extends "Sales Line"
{
    fields
    {
        field(50100; "SBC Original Order Qty."; Decimal)
        {
            Caption = 'Original Order Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }
}
