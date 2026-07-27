/// <summary>
/// Report SBCTA Create Trade Ledger (ID 50202).
/// </summary>
report 50202 "SBCTA Create Trade Ledger"
{
    ApplicationArea = All;
    Caption = 'Create Trade Ledger Entries';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(DataValueEntry; "Value Entry")
        {
            DataItemTableView = where("Entry Type" = Const("Direct Cost"), "Item Ledger Entry Type" = Const(Sale), "Document Type" = filter("Sales Invoice" | "Sales Credit Memo"), "Source Type" = const("Customer"));
            RequestFilterFields = "Entry No.", "Posting Date";
            trigger OnPreDataItem()
            begin
                OpenDialogue();
                GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
            end;

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
                Customer: Record Customer;
            begin
                ValueEntry := DataValueEntry;
                SetSellToCustomerValues(ValueEntry);
                CreateCustomerCOGsTradeLedger(ValueEntry);
                if GlobalOptionCommitOnWrite and Database.IsInWriteTransaction() then
                    Database.Commit();
                // CreateItemCOGsTradeLedger(ValueEntry);
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
        layout
        {
            area(content)
            {
                group(Options)
                {
                    // field(OptionReprocessValueEntry; GlobalOptionReprocessValueEntry)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Reprocess Value Entry';
                    // }
                    field(OptionRecreateValueEntry; GlobalOptionRecreateValueEntry)
                    {
                        ApplicationArea = All;
                        Caption = 'Recreate Value Entry';
                    }
                    field(OptionCommitOnWrite; GlobalOptionCommitOnWrite)
                    {
                        ApplicationArea = All;
                        Caption = 'Commit on Write';
                    }
                    field(OptionRateCodeFilterText; GlobalRateCodeFilterText)
                    {
                        ApplicationArea = All;
                        Caption = 'Rate Code Filter';
                        Lookup = true;
                        // LookupPageId = "SBCTA Trade Budget Rate Codes";
                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            SetSelectionFilterText();
                        end;
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

    var
        GlobalSBCTACustomerEvents: Codeunit "SBCTA Customer Events";
        // GlobalSBCTAItemEvents: Codeunit "SBCTA Item Events";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";

        GlobalOptionCommitOnWrite: Boolean;
        // GlobalOptionReprocessValueEntry: Boolean;
        GlobalOptionRecreateValueEntry: Boolean;
        ProcessingDialogTextLabel: Label 'Creating Trade Ledgers.';
        GlobalDialog: Dialog;
        GlobalRateCodeFilterText: Text;

    // local procedure ProcessConditionsMet(ValueEntry: Record "Value Entry") Process: Boolean
    // var
    //     SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    // begin
    //     Process := not SBCTATrBudgetLedgerEntry.TradeBudgetEntryExistsForValueEntry(ValueEntry."Entry No.", SBCTATradeBudgetRates."Trade Budget Code", SBCTATradeBudgetRates."Trade Budget Rate Code");
    //     if Process then
    //         exit;
    //     if not GlobalOptionReprocessValueEntry then
    //         exit;
    //     Process := GlobalOptionReprocessValueEntry;
    // end;

    local procedure CreateCustomerCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    begin
        GlobalSBCTACustomerEvents.SetRunFromBatch(true);
        GlobalSBCTACustomerEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
        if GlobalRateCodeFilterText <> '' then
            GlobalSBCTACustomerEvents.SetRateCodeFilter(GlobalRateCodeFilterText);
        if not GlobalSBCTACustomerEvents.ActivateCOGsPosting(ValueEntry) then
            exit;
        GlobalSBCTACustomerEvents.ProcessValueEntry(ValueEntry);
        GlobalSBCTACustomerEvents.ClearGlobals();
    end;

    // local procedure CreateItemCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    // begin
    //     GlobalSBCTAItemEvents.SetReprocessValueEntry(GlobalOptionReprocessValueEntry);
    //     if not GlobalSBCTAItemEvents.ActivateCOGsPosting(ValueEntry) then
    //         exit;
    //     GlobalSBCTAItemEvents.CreateEntriesFromValueEntry(ValueEntry);
    //     GlobalSBCTAItemEvents.ClearGlobals();
    // end;

    local procedure SetSellToCustomerValues(var ValueEntry: Record "Value Entry")
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
            exit;
        CustLedgerEntry.SetRange("Customer No.", ValueEntry."Source No.");
        CustLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
        if ValueEntry."Document Type" = ValueEntry."Document Type"::"Sales Invoice" then
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice)
        else
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetLoadFields("Sell-to Customer No.");
        if CustLedgerEntry.IsEmpty() then
            exit;
        CustLedgerEntry.FindFirst();
        Customer.SetRange("No.", CustLedgerEntry."Sell-to Customer No.");
        Customer.SetLoadFields("No.", "Customer Posting Group");
        if Customer.IsEmpty() then
            exit;
        Customer.FindFirst();
        ValueEntry."Source No." := Customer."No.";
        ValueEntry."Source Posting Group" := Customer."Customer Posting Group";
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

    local procedure SetSelectionFilterText()
    var
        SBCTATradeBudgetRateCodes: Page "SBCTA Trade Budget Rate Codes";
        SelectionFilterManagement: Codeunit "SelectionFilterManagement";
        SelectionFilterRecord: Record "SBCTA Trade Budget Rate Codes";
        SelctionFilterRef: RecordRef;
        LookupAction: Action;
    begin
        SBCTATradeBudgetRateCodes.LookupMode(true);
        if not (SBCTATradeBudgetRateCodes.RunModal() = LookupAction::LookupOK) then
            exit;
        SBCTATradeBudgetRateCodes.SetSelectionFilter(SelectionFilterRecord);
        SelctionFilterRef.GetTable(SelectionFilterRecord);
        GlobalRateCodeFilterText := SelectionFilterManagement.GetSelectionFilter(SelctionFilterRef, SelectionFilterRecord.FieldNo("Trade Budget Rate Code"));
    end;
}