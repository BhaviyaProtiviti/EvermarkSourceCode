/// <summary>
/// TableExtension SBCEDI Customer (ID 50081) extends Record Customer.
/// </summary>
tableextension 50081 "SBCEDI Customer" extends Customer
{
    fields
    {
        field(50080; "SBC Ignore Price Discrepancy"; Boolean)
        {
            Caption = 'SBC Ignore Price Discrepancy';
            DataClassification = CustomerContent;
            Description = 'If this is set, the EDI price discrepancy check will be ignored for this Customer.';
        }
        field(50081; "SBC Auto-Created Customer"; Boolean)
        {
            Caption = 'SBC Auto-Created Customer';
            DataClassification = CustomerContent;
            Description = 'This field is set when a Customer is auto created during the EDI850 insert process.';
        }
        field(50082; "SBC Always Accept EDI Price"; Boolean)
        {
            Caption = 'SBC Always Accept EDI Price';
            DataClassification = CustomerContent;
            Description = 'This field is used primarily so that zero dollar prices will be accepted rather than ignored.';
        }
    }
}