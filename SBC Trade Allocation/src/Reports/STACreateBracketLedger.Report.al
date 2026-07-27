report 50209 "STA Create Bracket Ledger"
{
    ApplicationArea = All;
    Caption = 'SBC Create Bracket Price Ledger';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = where("SBC Bracket Price Code" = filter('<>'''''));
            RequestFilterFields = "No.", "SBC Bracket Price Code";

            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLinkReference = Customer;
                DataItemLink = "Sell-to Customer No." = field("No.");
                DataItemTableView = where("Document Type" = filter("Invoice" | "Credit Memo"));

                dataitem(HeaderValueEntry; "Value Entry")
                {
                    DataItemLinkReference = "Cust. Ledger Entry";
                    DataItemLink = "Document No." = field("Document No.");
                    DataItemTableView = where("Entry Type" = Const("Direct Cost"), "Item Ledger Entry Type" = Const(Sale), "Document Type" = filter("Sales Invoice" | "Sales Credit Memo"), "Source Type" = const("Customer"), Adjustment = const(false), "Sales Amount (Actual)" = filter('<>0'), "Invoiced Quantity" = filter('<>0'));
                    RequestFilterFields = "Entry No.", "Posting Date";

                    //TODO: Base this report on The Customer Ledger Entries of Customers that have brackets. This would be much faster and have less searching. 
                    // dataitem(LineValueEntry; "Value Entry")
                    // {
                    //     DataItemTableView = where("Entry Type" = Const("Direct Cost"), "Item Ledger Entry Type" = Const(Sale), "Document Type" = filter("Sales Invoice" | "Sales Credit Memo"), "Source Type" = const("Customer"), Adjustment = const(false), "Sales Amount (Actual)" = filter('<>0'));
                    //     RequestFilterFields = "Entry No.", "Posting Date";
                    //     DataItemLinkReference = HeaderValueEntry;
                    //     DataItemLink = "Document No." = field("Document No.");

                    //     trigger OnPreDataItem()
                    //     begin
                    //         LineValueEntry.SetCurrentKey("Item Ledger Entry No.", "Document No.", "Document Line No.");
                    //         // LineValueEntry.FindSet();
                    //         LineValueEntry.CopyFilters(HeaderValueEntry);
                    //     end;

                    //     trigger OnAfterGetRecord()
                    //     begin
                    //         PassValueEntryToHandler(LineValueEntry);

                    //     end;
                    //     trigger OnPostDataItem()
                    //     begin
                    //         Finish(LineValueEntry);
                    //         ProcessCommit();
                    //     end;

                    // }
                    trigger OnPreDataItem()
                    var
                        Customer: Record Customer;
                    begin
                        // OpenDialogue();

                        // GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
                        // Customer.SetFilter("SBC Bracket Price Code", '<>%1', '');
                        // if Customer.IsEmpty() then
                        //     exit;
                        // Customer.SetLoadFields("No.", "SBC Bracket Price Code");
                        // Customer.FindSet(false);
                        // repeat
                        //     GlobalBracketDictionary.Add(Customer."No.", Customer."SBC Bracket Price Code");
                        // until Customer.Next() = 0;
                        // GlobalSTABracketPriceEvents.SetGlobalBracketValues(GlobalBracketDictionary);
                        // HeaderValueEntry.SetCurrentKey("Item Ledger Entry No.", "Document No.", "Document Line No.");
                        // HeaderValueEntry.FindSet();
                    end;

                    trigger OnAfterGetRecord()
                    var
                        // ValueEntry: Record "Value Entry";
                        // Customer: Record Customer;
                        ValueEntryRecordRef: RecordRef;
                    begin
                        // ValueEntry := HeaderValueEntry;
                        // if (ValueEntry."Document No." = GlobalLastDocNo) and not GlobalValidValueEntry then
                        //     CurrReport.Skip();
                        // GlobalLastDocNo := ValueEntry."Document No.";
                        ValueEntryRecordRef.GetTable(HeaderValueEntry);
                        GlobalValidValueEntry := GlobalSTABracketPriceEvents.BindEventCU(ValueEntryRecordRef, Database::"Value Entry");
                        if not GlobalValidValueEntry then
                            CurrReport.Skip();

                        GlobalSTABracketPriceEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
                        PassValueEntryToHandler(HeaderValueEntry);
                        Finish(HeaderValueEntry);
                        ProcessCommit();
                    end;

                    // trigger OnPostDataItem()
                    // begin
                    //     GlobalSTABracketPriceEvents.ClearGlobalBracketValues();
                      
                    // end;
                }

                trigger OnPostDataItem()
                begin
                    GlobalSTABracketPriceEvents.ClearGlobalBracketValues();
                end;
            }
             trigger OnPreDataItem()
             begin
                OpenDialogue();
             end;
            trigger OnAfterGetRecord()
            begin
                GlobalSTABracketPriceEvents.SetGlobalBracketValues(Customer."No.", Customer."SBC Bracket Price Code");
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
        GlobalBracketDictionary: Dictionary of [Code[20], Code[20]]; // key: Customer No., value: Bracket Price Code
        GlobalLastDocNo: Code[20];

        GlobalSBCTAPurchItemEvents: Codeunit "SBCTA Purch Item Events";
        GlobalSTABracketPriceEvents: Codeunit "STA Bracket Price Events";
        // GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalOptionCommitOnWrite: Boolean;
        // GlobalOptionReprocessValueEntry: Boolean;
        GlobalRateCodeFilterText: Text;
        GlobalOptionRecreateValueEntry: Boolean;
        GlobalValidValueEntry: Boolean;
        ProcessingDialogTextLabel: Label 'Creating Bracket Price Ledgers.';
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

    // local procedure CreateItemCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    // begin
    //     GlobalSBCTAItemEvents.SetRunFromBatch(true);
    //     GlobalSBCTAItemEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
    //     if GlobalRateCodeFilterText <> '' then
    //         GlobalSBCTAItemEvents.SetRateCodeFilter(GlobalRateCodeFilterText);
    //     if not GlobalSBCTAItemEvents.ActivateCOGsPosting(ValueEntry) then
    //         exit;
    //     GlobalSBCTAItemEvents.CreateEntriesFromValueEntry(ValueEntry);
    //     GlobalSBCTAItemEvents.ClearGlobals();
    // end;

    // local procedure CreatePurchItemCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    // begin
    //     GlobalSBCTAPurchItemEvents.SetRunFromBatch(true);
    //     GlobalSBCTAPurchItemEvents.SetRecreateValueEntry(GlobalOptionRecreateValueEntry);
    //     if GlobalRateCodeFilterText <> '' then
    //         GlobalSBCTAPurchItemEvents.SetRateCodeFilter(GlobalRateCodeFilterText);
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

    // local procedure SetCustomerValues(var ValueEntry: Record "Value Entry")
    // var
    //     Customer: Record Customer;
    //     CustLedgerEntry: Record "Cust. Ledger Entry";
    // begin
    //     if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
    //         exit;
    //     CustLedgerEntry.SetRange("Customer No.", ValueEntry."Source No.");
    //     CustLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
    //     if ValueEntry."Document Type" = ValueEntry."Document Type"::"Sales Invoice" then
    //         CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice)
    //     else
    //         CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
    //     CustLedgerEntry.SetLoadFields("Sell-to Customer No.");
    //     if CustLedgerEntry.IsEmpty() then
    //         exit;
    //     CustLedgerEntry.FindFirst();
    //     Customer.SetRange("No.", CustLedgerEntry."Sell-to Customer No.");
    //     Customer.SetLoadFields("No.", "Customer Posting Group");
    //     if Customer.IsEmpty() then
    //         exit;
    //     Customer.FindFirst();
    //     ValueEntry."Source No." := Customer."No.";
    //     ValueEntry."Source Posting Group" := Customer."Customer Posting Group";
    // end;

    // local procedure SetVendorValues(var ValueEntry: Record "Value Entry")
    // var
    //     Vendor: Record Vendor;
    //     VendorLedgerEntry: Record "Vendor Ledger Entry";
    // begin
    //     if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
    //         exit;
    //     VendorLedgerEntry.SetRange("Vendor No.", ValueEntry."Source No.");
    //     VendorLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
    //     // if ValueEntry."Document Type" = ValueEntry."Document Type"::"Purchase Invoice" then
    //     //     VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice)
    //     // else
    //     //     VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
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

    [IntegrationEvent(false, false)]
    local procedure PassValueEntryToHandler(var ValueEntry: Record "Value Entry")
    begin

    end;


    [IntegrationEvent(false, false)]
    local procedure Finish(ValueEntry: Record "Value Entry")
    begin

    end;
}