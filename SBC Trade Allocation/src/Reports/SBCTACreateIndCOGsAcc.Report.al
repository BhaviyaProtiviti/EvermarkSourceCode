/// <summary>
/// Report SBCTA Create Trade Accruals (ID 50200).
/// </summary>
report 50205 "SBCTA Create Ind. COGs Acc."
{
    Caption = 'Create Indirect COGs Accruals';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = true;


    dataset
    {
        dataitem(SBCTAIndirectCOGsLedger; "SBCTA Indirect COGs Ledger")
        {
            RequestFilterFields = "Entry No.", "Posting Date", "Trade Budget Code", "Trade Budget Rate Code";
            DataItemTableView = sorting("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.") where("Trade Accrual No." = const(0), "Trade Accrual Line No." = const(0), "Accrued Amount" = const(0), "Trade Budget Amount" = filter('<>0'));

            trigger OnPreDataItem()
            begin
                GlobalSBCTATradeBudgetOptions.SetFilter("Ignore Trade Target",'%1',true);
                GlobalIgnoreTradeTarget := not GlobalSBCTATradeBudgetOptions.IsEmpty();
                OpenDialogue();
                if SBCTAIndirectCOGsLedger.IsEmpty() then
                    exit;
                GlobalSBCTATradeAccrualHeader := GlobalSBCTATradeAccrualHeader.CreateIndirectCogsAccrualHeader();
            end;

            trigger OnAfterGetRecord()
            var
                SBCTATradeBudget: Record "SBCTA Trade Budget";
            begin
                SBCTATradeBudget := SBCTAIndirectCOGsLedger.GetBudget();
                GlobalSBCTATradeAccrualHeader.AddIndirectCogsAccrualLine(SBCTAIndirectCOGsLedger, SBCTATradeBudget,GlobalIgnoreTradeTarget);
            end;

            trigger OnPostDataItem()
            begin
                CloseDialog();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        SourceTable = "SBCTA Indirect COGs Ledger";
        SourceTableView = sorting("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.") where("Trade Accrual No." = const(0), "Trade Accrual Line No." = const(0), "Accrued Amount" = const(0), "Trade Budget Amount" = filter('<>0'));
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

    internal procedure GetIndirectCOGsAccrualHeader() SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header"
    begin
        SBCTATradeAccrualHeader := GlobalSBCTATradeAccrualHeader;
    end;

    local procedure OpenDialogue()
    begin
        if not GuiAllowed() then
            exit;
        GlobalDialog.Open(ProcessingDialogTextLabel);
    end;

    local procedure CloseDialog()
    begin
        if not GuiAllowed() then
            exit;
        GlobalDialog.Close();
    end;

    var
        GlobalSBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
        GlobalSBCTATradeBudgetOptions : Record "SBCTA Trade Budget Options";
        ProcessingDialogTextLabel: Label 'Creating Indirect COGs Accruals.';
        GlobalIgnoreTradeTarget: Boolean;
        GlobalDialog: Dialog;

    // GlobalSBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";

}