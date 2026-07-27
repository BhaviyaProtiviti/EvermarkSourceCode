/// <summary>
/// PageExtension SBCTA General Journal (ID 50200) extends Record General Journal.
/// </summary>
pageextension 50200 "SBCTA General Journal" extends "General Journal"
{
    actions
    {
        addlast(processing)
        {
            action(CreateTradeCredits)
            {
                ApplicationArea = All;
                Caption = 'Create Accrual Journals';
                ToolTip = 'This process creates accrual journals for Direct Trade and Indirect COGs ledgers.';
                // Promoted = true;
                // PromotedCategory = Process;
                Image = CreateCreditMemo;
                trigger OnAction()
                var
                    SBCTATradeAccrualMgmt: Codeunit "SBCTA Trade Accrual Mgmt.";
                    SBCTACreateAccrualCredits : Report "SBCTA Create Accrual & Credits";
                begin
                    // SBCTATradeAccrualMgmt.CreateAccrualAndCredit();
                    SBCTACreateAccrualCredits.Run();
                end;
            }


        }

        addlast(Category_Process)
        {
            actionref(CreateTradeCredits_Promoted; CreateTradeCredits)
            {
            }
        }




    }
}