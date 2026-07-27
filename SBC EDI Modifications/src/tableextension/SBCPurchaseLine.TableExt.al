tableextension 50158 "SBC EDI Purchase Line" extends "Purchase Line"
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
        field(50101; "SBC Original Approved Qty."; Decimal)
        {
            Caption = 'Original Approved Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50102; "SBC EDI Received Qty"; Decimal)
        {
            Caption = 'EDI Received Qty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }
}
