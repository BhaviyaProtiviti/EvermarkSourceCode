tableextension 50008 "SBC Item Unit of Measure" extends "Item Unit of Measure"
{
    fields
    {
        field(50000; "SBC Measurement System"; Enum "SBC Measurement System")
        {
            DataClassification = CustomerContent;
            Caption = 'SBC Measurement System';
            Editable = false;
        }
    }
}