/// <summary>
/// Enum SBCOE Export Row Type (ID 50061).
/// </summary>
enum 50061 "SBCOE Row Type"
{
    Extensible = true;
    /// <summary>
    /// Default
    /// </summary>
    value(0; " ")
    {
        Caption = ' ';
    }
    /// <summary>
    /// Header row type.
    /// </summary>
    value(1; Header)
    {
        Caption = 'Header';
    }
    /// <summary>
    /// Detail row type.
    /// </summary>
    value(2; Detail)
    {
        Caption = 'Detail';
    }
    /// <summary>
    /// Footer row type.
    /// </summary>
    value(3; Footer)
    {
        Caption = 'Footer';
    }
}
