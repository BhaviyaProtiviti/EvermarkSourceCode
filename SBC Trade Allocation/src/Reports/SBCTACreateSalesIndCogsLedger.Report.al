/// <summary>
/// Report SBCTA Create Trade Ledger (ID 50202).
/// </summary>
report 50210 "SBCTA Create Sales Ind. COGs"
{
    ApplicationArea = All;
    Caption = 'Create Sales Indirect COGs Ledger Entries';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(DataValueEntry; "Value Entry")
        {
            DataItemTableView = where("Entry Type" = filter("Direct Cost"|"Revaluation"), "Item Ledger Entry Type" = filter(Sale | "Negative Adjmt."|"Positive Adjmt."), "Document Type" = filter("Sales Invoice" | "Sales Credit Memo"), "Source Type" = filter("Customer"  | " "));
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
                // case
                //     ValueEntry."Item Ledger Entry Type" of
                //     ValueEntry."Item Ledger Entry Type"::Sale:
                //         begin
                            SetCustomerValues(ValueEntry);
                            CreateItemCOGsTradeLedger(ValueEntry);
                            ProcessCommit();
                        // end;
                    // ValueEntry."Item Ledger Entry Type"::Purchase,ValueEntry."Item Ledger Entry Type"::"Negative Adjmt.",ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.":
                    //     begin
                    //         SetVendorValues(ValueEntry);
                    //         CreatePurchItemCOGsTradeLedger(ValueEntry);
                    //         ProcessCommit();
                    //     end;
                // end;
                // CreateCustomerCOGsTradeLedger(ValueEntry);
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
        GlobalSBCTAItemEvents: Codeunit "SBCTA Item Events";

        GlobalSBCTAPurchItemEvents: Codeunit "SBCTA Purch Item Events";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalOptionCommitOnWrite: Boolean;
        // GlobalOptionReprocessValueEntry: Boolean;
        GlobalRateCodeFilterText: Text;
        GlobalOptionRecreateValueEntry: Boolean;
        ProcessingDialogTextLabel: Label 'Creating Indirect COGs Ledgers.';
        GlobalDialog: Dialog;

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

    // local procedure CreateCustomerCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    // begin
    //     GlobalSBCTACustomerEvents.SetRunFromBatch(true);
    //     GlobalSBCTACustomerEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
    //     if not GlobalSBCTACustomerEvents.ActivateCOGsPosting(ValueEntry) then
    //         exit;

    //     GlobalSBCTACustomerEvents.CreateEntriesFromValueEntry(ValueEntry);
    //     GlobalSBCTACustomerEvents.ClearGlobals();
    // end;

    local procedure CreateItemCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    begin
        GlobalSBCTAItemEvents.SetRunFromBatch(true);
        GlobalSBCTAItemEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
        if GlobalRateCodeFilterText <> '' then
           GlobalSBCTAItemEvents.SetRateCodeFilter(GlobalRateCodeFilterText) ;         
        if not GlobalSBCTAItemEvents.ActivateCOGsPosting(ValueEntry) then
            exit;
        GlobalSBCTAItemEvents.CreateEntriesFromValueEntry(ValueEntry);
        GlobalSBCTAItemEvents.ClearGlobals();
    end;

    // local procedure CreatePurchItemCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    // begin
    //     GlobalSBCTAPurchItemEvents.SetRunFromBatch(true);
    //     GlobalSBCTAPurchItemEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
    //     if GlobalRateCodeFilterText <> '' then
    //        GlobalSBCTAPurchItemEvents.SetRateCodeFilter(GlobalRateCodeFilterText);
    //     if not GlobalSBCTAPurchItemEvents.ActivateCOGsPosting(ValueEntry) then
    //         exit;
    //     GlobalSBCTAPurchItemEvents.CreateEntriesFromValueEntry(ValueEntry);
    //     GlobalSBCTAPurchItemEvents.ClearGlobals();
    // end;

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

    local procedure SetCustomerValues(var ValueEntry: Record "Value Entry")
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

    // local procedure SetVendorValues(var ValueEntry: Record "Value Entry")
    // var
    //     Vendor: Record Vendor;
    //     VendorLedgerEntry: Record "Vendor Ledger Entry";
    // begin
    //     if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
    //         exit;
    //     VendorLedgerEntry.SetRange("Vendor No.", ValueEntry."Source No.");
    //     VendorLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
    //     if ValueEntry."Document Type" = ValueEntry."Document Type"::"Purchase Invoice" then
    //         VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice)
    //     else
    //         VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
    //     VendorLedgerEntry.SetLoadFields("Buy-from Vendor No.");
    //     if VendorLedgerEntry.IsEmpty() then
    //         exit;
    //     VendorLedgerEntry.FindFirst();
    //     Vendor.SetRange("No.", VendorLedgerEntry."Buy-from Vendor No.");
    //     Vendor.SetLoadFields("No.", "Vendor Posting Group");
    //     if Vendor.IsEmpty() then
    //         exit;
    //     Vendor.FindFirst();
    //     ValueEntry."Source No." := Vendor."No.";
    //     ValueEntry."Source Posting Group" := Vendor."Vendor Posting Group";
    // end;


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

    local procedure ProcessCommit()
    begin
        if GlobalOptionCommitOnWrite and Database.IsInWriteTransaction() then
            Database.Commit();
    end;
}