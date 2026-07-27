/// <summary>
/// Report SBCTA Create Accrual and Credits (ID 50203).
/// </summary>
report 50203 "SBCTA Create Accrual & Credits"
{
    Caption = 'Create Accrual and Credits';
    ProcessingOnly = true;
    ApplicationArea = All;
    UseRequestPage = true;
    UsageCategory = Tasks;
    dataset
    {
        // dataitem(; "")
        // {
        // }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(Option_GlobalJournalPostingDate; GlobalJournalPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Posting Date';
                        ToolTip = 'The Posting Date that will be set for the entries created in the journal.';
                    }
                    field(Option_GlobalAccrualDateFilter; GlobalAccrualDateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Accrual Date Filter';
                        ToolTip = 'The range of dates allowed for accrual entries.';
                    }
                    field(Option_GlobalCreateTradeCredits; GlobalCreateTradeCredits)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Direct Trade Journals';
                        ToolTip = 'Creates Direct Trade Journals.';
                    }
                    field(Option_GlobalCreateIndirectCogsCredits; GlobalCreateIndirectCogsCredits)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Indirect COGs Journals';
                        ToolTip = 'Creates Indirect COGs Journals.';
                    }
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

    trigger OnPostReport()
    begin
        CreateAccrualAndCredit();
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    internal procedure CreateAccrualAndCredit()
    var
        SBCTACreateAccrualCredits: Report "SBCTA Create Accrual Credits";
    begin
        // CreateTradeAccrual();
        if GlobalCreateTradeCredits then
            CreateTradeAccrual();
        if GlobalCreateIndirectCogsCredits then
            CreateIndirectCOGsAccrual();
        // if SBCTATradeAccrualHeader.AccrualLinesExist() then begin
        //     SBCTATradeAccrualHeader.SetRecFilter();
        //     SBCTACreateAccrualCredits.SetTableView(SBCTATradeAccrualHeader);
        // end;

        if GlobalAccrualDateFilter <> '' then
            SBCTACreateAccrualCredits.SetDateFilter(GlobalAccrualDateFilter);
        if GlobalJournalPostingDate <> 0D then
            SBCTACreateAccrualCredits.SetJournalPostingDate(GlobalJournalPostingDate);
        SBCTACreateAccrualCredits.SetCreateTradeCredits(GlobalCreateTradeCredits);
        SBCTACreateAccrualCredits.SetCreateIndirectCogsCredits(GlobalCreateIndirectCogsCredits);
        SBCTACreateAccrualCredits.UseRequestPage(false);
        SBCTACreateAccrualCredits.SetSuppressAlerts(true);
        SBCTACreateAccrualCredits.Run();
    end;

    local procedure CreateTradeAccrual()
    var
        SBCTACreateTradeAccruals: Report "SBCTA Create Trade Accruals";
        SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        SBCTATrBudgetLedgerEntry.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.");
        SBCTATrBudgetLedgerEntry.SetRange("Trade Accrual No.", 0);
        SBCTATrBudgetLedgerEntry.SetRange("Trade Accrual Line No.", 0);
        SBCTATrBudgetLedgerEntry.SetRange("Accrued Amount", 0);
        SBCTATrBudgetLedgerEntry.SetFilter("Trade Budget Amount", '<>%1', 0);
        if GlobalAccrualDateFilter <> '' then
            SBCTATrBudgetLedgerEntry.SetFilter("Posting Date", GlobalAccrualDateFilter);
        SBCTACreateTradeAccruals.SetTableView(SBCTATrBudgetLedgerEntry);
        SBCTACreateTradeAccruals.UseRequestPage(false);
        SBCTACreateTradeAccruals.RunModal();
        SBCTATradeAccrualHeader := SBCTACreateTradeAccruals.GetTradeAccrualHeader();
        if (SBCTATradeAccrualHeader."Trade Accrual No." <> 0) and not SBCTATradeAccrualHeader.AccrualLinesExist() then
            SBCTATradeAccrualHeader.Delete();
    end;

    local procedure CreateIndirectCOGsAccrual()
    var
        SBCTACreateIndCOGsAcc: Report "SBCTA Create Ind. COGs Acc.";
        SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
        SBCTAIndirectCogsLedger: Record "SBCTA Indirect COGs Ledger";
    begin
        SBCTAIndirectCogsLedger.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.");
        SBCTAIndirectCogsLedger.SetRange("Trade Accrual No.", 0);
        SBCTAIndirectCogsLedger.SetRange("Trade Accrual Line No.", 0);
        SBCTAIndirectCogsLedger.SetRange("Accrued Amount", 0);
        // SBCTAIndirectCogsLedger.SetFilter("Document Type",'<>%1&<>%2', "Item Ledger Document Type"::"Sales Invoice" , "Item Ledger Document Type"::"Sales Credit Memo" ); // We are excluding sales documents from accruals for Indirect COGs
        SBCTAIndirectCogsLedger.SetFilter("Trade Budget Amount", '<>%1', 0);
        if GlobalAccrualDateFilter <> '' then
            SBCTAIndirectCogsLedger.SetFilter("Posting Date", GlobalAccrualDateFilter);
        SBCTACreateIndCOGsAcc.SetTableView(SBCTAIndirectCogsLedger);
        SBCTACreateIndCOGsAcc.UseRequestPage(false);
        SBCTACreateIndCOGsAcc.RunModal();
        SBCTATradeAccrualHeader := SBCTACreateIndCOGsAcc.GetIndirectCOGsAccrualHeader();
        if (SBCTATradeAccrualHeader."Trade Accrual No." <> 0) and not SBCTATradeAccrualHeader.AccrualLinesExist() then
            SBCTATradeAccrualHeader.Delete();
    end;

    var
        GlobalJournalPostingDate: Date;
        GlobalAccrualDateFilter: Text;
        GlobalCreateTradeCredits: Boolean;
        // GlobalCreateIndirectCogsCredits: Boolean;
        GlobalCreateIndirectCogsCredits: Boolean;
}