/// <summary>
/// Report SBCTA Create Trade Accruals (ID 50200).
/// </summary>
report 50200 "SBCTA Create Trade Accruals"
{
    Caption = 'Create Trade Accruals';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = true;


    dataset
    {
        dataitem(SBCTATrBudgetLedgerEntry; "SBCTA Tr. Budget Ledger Entry")
        {
            RequestFilterFields = "Entry No.", "Posting Date", "Trade Budget Code", "Trade Budget Rate Code";
            DataItemTableView = sorting("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.") where("Trade Accrual No." = const(0), "Trade Accrual Line No." = const(0), "Accrued Amount" = const(0), "Trade Budget Amount" = filter('<>0'));

            trigger OnPreDataItem()
            begin
                GlobalSBCTATradeBudgetOptions.SetFilter("Ignore Trade Target", '%1', true);
                GlobalIgnoreTradeTarget := not GlobalSBCTATradeBudgetOptions.IsEmpty();
                OpenDialogue();
                if SBCTATrBudgetLedgerEntry.IsEmpty() then
                    exit;
                GlobalSBCTATradeAccrualHeader := GlobalSBCTATradeAccrualHeader.CreateTradeAccrualHeader();
                
            end;

            trigger OnAfterGetRecord()
            var
                SBCTATradeBudget: Record "SBCTA Trade Budget";
            begin
                SBCTATradeBudget := SBCTATrBudgetLedgerEntry.GetBudget();
                GlobalSBCTATradeAccrualHeader.AddTradeAccrualLine(SBCTATrBudgetLedgerEntry, SBCTATradeBudget, GlobalIgnoreTradeTarget);
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
        SourceTable = "SBCTA Tr. Budget Ledger Entry";
        SourceTableView = sorting("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.") where("Trade Accrual No." = const(0), "Trade Accrual Line No." = const(0), "Accrued Amount" = const(0), "Trade Budget Amount" = filter('<>0'));
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

    internal procedure GetTradeAccrualHeader() SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header"
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
        ProcessingDialogTextLabel: Label 'Creating Trade Accruals.';
        GlobalDialog: Dialog;


        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";

        GlobalIgnoreTradeTarget: Boolean;

    // GlobalSBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";

}