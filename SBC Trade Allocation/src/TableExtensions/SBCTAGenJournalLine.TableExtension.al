/// <summary>
/// TableExtension SBCTA Gen. Journal Line (ID 50200) extends Record Gen. Journal Line.
/// </summary>
tableextension 50200 "SBCTA Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(50200; "SBCTA ID"; Guid)
        {
            Caption = 'SBCTA ID';
            DataClassification = SystemMetadata;
        }
    }
}