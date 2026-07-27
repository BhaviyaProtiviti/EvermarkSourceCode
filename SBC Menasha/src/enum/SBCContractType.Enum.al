/// <summary>
/// Enum SBC Contract Mfg. File Type (ID 50250).
/// </summary>
enum 50350 "SBC Contract Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(50250; "SBC Inventory")
    {
        Caption = 'Inventory';
    }
    value(50251; "SBC Consumption")
    {
        Caption = 'Consumption';
    }
    value(50252; "SBC Finished Goods")
    {
        Caption = 'Finished Goods';
    }
}
