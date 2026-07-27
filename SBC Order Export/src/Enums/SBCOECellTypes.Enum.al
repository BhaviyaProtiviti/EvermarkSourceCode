/// <summary>
/// Enum SBCOE Cell Types (ID 50062). Cell types for SBCOE.
/// </summary>
enum 50062 "SBCOE Cell Types"
{
    Extensible = true;
    /// <summary>
    /// Excel cell type of Number.
    /// </summary>
    value(0; Number)
    {
        Caption = 'Number';
    }
    /// <summary>
    /// Excel cell type of Text.
    /// </summary>
    value(1; Text)
    {
        Caption = 'Text';
    }
    /// <summary>
    /// Excel cell type of Date.
    /// </summary>
    value(2; Date)
    {
        Caption = 'Date';
    }
    /// <summary>
    /// Excel cell type of Time.
    /// </summary>
    value(3; Time)
    {
        Caption = 'Time';
    }
}
