/// <summary>
/// TableExtension SBCEDI Ship-to Address (ID 50082) extends Record Ship-to Address.
/// </summary>
tableextension 50082 "SBCEDI Ship-to Address" extends "Ship-to Address"
{
    fields
    {
        field(50080; "SBC Auto-Created Ship-To"; Boolean)
        {
            Caption = 'SBC Auto-Created Ship-To';
            DataClassification = CustomerContent;
            Description = 'This field is set when a ship-to is auto created during the EDI850 insert process.';
        }
    }
}