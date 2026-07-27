/// <summary>
/// TableExtension SBC EDI Pmt. Remit Advice Line (ID 50086) extends Record LAX EDI Pmt. Remit Advice Line.
/// </summary>
tableextension 50086 "SBC EDI Pmt. Remit Advice Line" extends "LAX EDI Pmt. Remit Advice Line"
{
    // #275
    fields
    {
        field(50080; "SBC Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
    }
    // #275
    keys
    {
        key(AmountSort; "Document Type", Amount)
        {
            Description = 'Sorting Key';
        }
    }
}