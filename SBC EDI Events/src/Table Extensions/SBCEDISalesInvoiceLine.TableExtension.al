/// <summary>
/// TableExtension  (ID 50083) extends Record SBCEDI Sales Line.
/// </summary>
tableextension 50085 "SBCEDI Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(50080; "SBC Previous Line Discount"; Decimal)
        {
            Caption = 'SBC Previous Line Discount';
            DataClassification = CustomerContent;
        }
        field(50081; "SBC Previous EDI Unit Price"; Decimal)
        {
            Caption = 'SBC Previous EDI Unit Price';
            DataClassification = CustomerContent;
        }
        field(50082; "SBC Current EDI Unit Price"; Decimal)
        {
            Caption = 'SBC Current EDI Unit Price';
            DataClassification = CustomerContent;
        }
    }
}