/// <summary>
/// This enum is used to define the direction of a text pad in a Column Definition,
/// </summary>
enum 50063 "SBCOE Pad Direction"
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
    /// The text pad is left aligned.
    /// </summary>
    ///
    value(1; Left)
    {
        Caption = 'Left';
    }
    /// <summary>
    /// The text pad is right aligned.
    /// </summary>
    value(2; Right)
    {
        Caption = 'Right';
    }
}