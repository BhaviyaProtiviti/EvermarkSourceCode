/// <summary>
/// Enum SBCTA COGs Calc Type (ID 50203).
/// </summary>
enum 50203 "SBCTA COGs Calc Type"
{
    Extensible = true;
    
    value(0; "Gross Sale")
    {
        Caption = 'Gross Sale';
    }
    value(1; "Net Sale")
    {
        Caption = 'Net Sale';
    }
    value(2; "Cost Only")
    {
        Caption = 'Cost Only';
    }
    value(3; "Discount Only")
    {
        Caption = 'Discount Only';
    }
}