enum 50600 "TIG Payment Type"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; ACH)
    {
        Caption = 'ACH';
    }
    value(2; MTS)
    {
        Caption = 'MTS'; //USD Wire
    }
    value(3; Check)
    {
        Caption = 'Check';
    }
    value(6; IWI)
    {
        Caption = 'IWI'; //Foreign Currency Wire
    }
}