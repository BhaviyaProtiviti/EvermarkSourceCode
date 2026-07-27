/// <summary>
/// TableExtension SBCSR Item (ID 50180) extends Record Item.
/// </summary>
tableextension 50181 "SBCSR Item" extends Item
{
    fields
    {
        field(50180; "SBCSR Sync Date"; DateTime)
        {
            Caption = 'SpecRight Sync Date';
            DataClassification = CustomerContent;
            Description = 'Date and time of the last sync with SpecRight';
        }
    }
}