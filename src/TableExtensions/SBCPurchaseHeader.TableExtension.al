/// <summary>
/// TableExtension SBC Purchase Header (ID 50036) extends Record Purchase Header.
/// </summary>
tableextension 50036 "SBC Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(50035; "SBC Block Order"; Boolean)
        {
            Caption = 'SBC Block Order';
            DataClassification = SystemMetadata;
            Description = 'This field is set when an order is created from the Multi-Order creation process.';
        }
        field(50036; "SBC Mass Update"; Boolean)
        {
            Caption = 'SBC Mass Update';
            DataClassification = SystemMetadata;
            Description = 'This field is set when an order is created from the Mass Update process.';
        }
    }
}