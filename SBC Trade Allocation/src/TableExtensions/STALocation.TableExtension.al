/// <summary>
/// TableExtension STA Location (ID 50202) extends Record Location.
/// </summary>
tableextension 50202 "STA Location" extends Location
{
    fields
    {
        field(50200; "SBC Enable Indirect Cost"; Boolean)
        {
            Caption = 'SBC Enable Indirect Cost Tracking';
            DataClassification = SystemMetadata;
            Description = 'When this field is enabled, Indirect Cost tracking will be allowed for the specified location.';
        }
    }
}