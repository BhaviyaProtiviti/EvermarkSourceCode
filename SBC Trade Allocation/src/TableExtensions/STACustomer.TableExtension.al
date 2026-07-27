/// <summary>
/// TableExtension STA Customer (ID 50201) extends Record Customer.
/// </summary>
tableextension 50201 "STA Customer" extends Customer
{
    fields
    {
        field(50200; "SBC Bracket Price Code"; Code[20])
        {
            Caption = 'SBC Bracket Price Code';
            DataClassification = CustomerContent;
            TableRelation = "STA Bracket Price Code"."Bracket Price Code";
        }
    }
}