/// <summary>
/// This enum is used to define the type of padding to be used when padding is required.
/// </summary>
enum 50064 "SBCOE Pad Type"
{
    Extensible = true;
    /// <summary>
    /// Default value of no padding.
    /// </summary>
    value(0; " ")
    {
        Caption = ' ';
    }
    /// <summary>
    /// Space padding is used when padding is required.
    /// </summary>
    value(1; Space)
    {
        Caption = 'Space Pad';
    }
    /// <summary>
    /// Zero padding is used when padding is required.
    /// </summary>
    value(2; Zero)
    {
        Caption = ' Zero Pad';
    }
    /// <summary>
    /// A character of the user's choosing is added when when padding is required.
    /// </summary>
    value(3; Custom)
    {
        Caption = 'Custom Pad Character';
    }
}