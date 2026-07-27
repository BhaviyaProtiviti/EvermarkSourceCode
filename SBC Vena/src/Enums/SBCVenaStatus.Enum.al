/// <summary>
/// Enum SBC Vena Status (ID 50256).
/// </summary>
enum 50256 "SBC Vena Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; EDITING)
    {
        Caption = 'EDITING';
    }
    value(2; NOT_STARTED)
    {
        Caption = 'NOT_STARTED';
    }
    value(3; SUBMITTED)
    {
        Caption = 'SUBMITTED';
    }
    value(4; RUNNING)
    {
        Caption = 'RUNNING';
    }
    value(5; COMPLETED)
    {
        Caption = 'COMPLETED';
    }
    value(6; ERROR)
    {
        Caption = 'ERROR';
    }
    value(7; CANCELLED)
    {
        Caption = 'CANCELLED';
    }
    value(8; WAITING)
    {
        Caption = 'WAITING';
    }
    value(9; QUEUED)
    {
        Caption = 'QUEUED';
    }
    value(10; EXPIRED)
    {
        Caption = 'EXPIRED';
    }
}