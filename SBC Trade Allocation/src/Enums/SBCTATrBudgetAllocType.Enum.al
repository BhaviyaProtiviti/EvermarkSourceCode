/// <summary>
/// These types are used on the SBCTA Trade Accrual Line.
/// </summary>
enum 50200 "SBCTA Calc. Basis Type"
{
    Extensible = true;

    value(0; "COGS")
    {
        Caption = 'COGS';
    }
    value(1; "A/R")
    {
        Caption = 'A/R';
    }
    // value(2; Credit)
    // {
    //     Caption = 'Credit';
    // }
}