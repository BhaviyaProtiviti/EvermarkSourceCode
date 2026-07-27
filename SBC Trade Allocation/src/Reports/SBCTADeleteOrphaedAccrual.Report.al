report 50207 "SBCTA Delete Orphaed Accrual"
{
    ApplicationArea = All;
    Caption = 'SBCTA Delete Orphaed Accrual';
    UsageCategory = Administration;
    ProcessingOnly = true;
  
    dataset
    {
        dataitem(SBCTATradeAccrualLine; "SBCTA Trade Accrual Line")
        {
            trigger OnAfterGetRecord()
            var 
                SBCTATradeAccrualHeader : Record "SBCTA Trade Accrual Header";
            begin
                SBCTATradeAccrualHeader.SetRange("Trade Accrual No.", SBCTATradeAccrualLine."Trade Accrual No.");
                if not SBCTATradeAccrualHeader.IsEmpty() then
                    CurrReport.Skip();
                SBCTATradeAccrualLine.Delete(true);
            end;
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
}