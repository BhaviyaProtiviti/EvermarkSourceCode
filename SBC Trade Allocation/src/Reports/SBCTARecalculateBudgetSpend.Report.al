/// <summary>
/// Report SBCTA Recalculate Budget Spend (ID 50206).
/// </summary>
report 50206 "SBCTA Recalculate Budget Spend"
{
    Caption = 'Recalculate Budget Spend';
    ProcessingOnly = true;
    UseRequestPage = true;
    dataset
    {
        dataitem(SBCTATradeBudget; "SBCTA Trade Budget")
        {

            dataitem(SBCTATradeBudgetRates; "SBCTA Trade Budget Rates")
            {
                DataItemLinkReference = "SBCTATradeBudget";
                DataItemLink = "Trade Budget Code" = field("Trade Budget Code");
      

                trigger OnAfterGetRecord()
                begin
                    SBCTATradeBudgetRates."Trade Budget Actual" := 0;
                    SBCTATradeBudgetRates.Modify();
                    RecalculateBudgetRate();
                end;
            }
        }
    }
    requestpage
    {

        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    local procedure RecalculateBudgetRate()
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        TradeBudgetTotal: Decimal;
        SignFactor : Integer;
    begin
        SBCTATradeAccrualLine.SetRange("Trade Budget Code", SBCTATradeBudget."Trade Budget Code");
        SBCTATradeAccrualLine.SetRange("Trade Budget Rate Code", SBCTATradeBudgetRates."Trade Budget Rate Code");
        if SBCTATradeAccrualLine.IsEmpty() then
            exit;
        SBCTATradeAccrualLine.FindSet();
        repeat
            if SBCTATradeAccrualLine."Calculation Method" =  SBCTATradeAccrualLine."Calculation Method"::"Cost Only" then
                SignFactor := -1
            else
                SignFactor := 1;
            TradeBudgetTotal += (SignFactor * SBCTATradeAccrualLine."Accrued Amount");
        until SBCTATradeAccrualLine.Next() = 0;
        if TradeBudgetTotal = 0 then
            exit;
        SBCTATradeBudgetRates."Trade Budget Actual" := TradeBudgetTotal;
        SBCTATradeBudgetRates.Modify();
    end;
}