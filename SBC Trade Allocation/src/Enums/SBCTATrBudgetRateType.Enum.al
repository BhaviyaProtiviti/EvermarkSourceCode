/// <summary>
/// These rate types drive how rates are calculated for the budget.
/// </summary>
enum 50201 "SBCTA Tr. Budget Rate Type"
{
    Extensible = true;

    value(0; Percent)
    {
        Caption = 'Percent';
    }
    value(1; Amount)
    {
        Caption = ' Amount';
    }
}