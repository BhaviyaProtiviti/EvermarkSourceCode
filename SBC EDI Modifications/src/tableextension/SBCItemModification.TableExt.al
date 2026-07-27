tableextension 50151 "SBC Item Modification" extends Item
{
    fields
    {
        field(50150; "SBC Qty. per Sales UOM"; Decimal)
        {
            Caption = 'Qty. per Sales UOM';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Item Unit of Measure"."Qty. per Unit of Measure" where("Item No." = field("No."),Code = field("Sales Unit of Measure")));
        }
    }
}
