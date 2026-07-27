/// <summary>
/// TableExtension SBC Item Journal Line (ID 50350) extends Record Item Journal Line.
/// </summary>
tableextension 50350 "SBC Item Journal Line" extends "Item Journal Line"
{
    fields
    {
        field(50350; "SBC Post HideDialog"; Boolean)
        {
            Caption = 'SBC Post HideDialog';
            DataClassification = CustomerContent;
        }
    }
}
