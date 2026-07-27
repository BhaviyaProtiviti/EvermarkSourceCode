enum 50703 SBCInboundCostEntryType
{
    Extensible = true;

    value(0; "Inbound Freight")
    {
        Caption = 'Inbound Freight';
    }
    value(1; "WH Inbound Variable")
    {
        Caption = 'WH Inbound Variable';
    }
    value(2; "WH Overhead - Fixed")
    {
        Caption = 'WH Overhead - Fixed';
    }
    value(3; "SBC Custom/Duty")
    {
        Caption = 'Custom/Duty';
    }
}