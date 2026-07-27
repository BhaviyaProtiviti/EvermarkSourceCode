/// <summary>
/// Codeunit SBCTA Create Trade Ledgers (ID 50212).
/// </summary>
codeunit 50212 "SBCTA Create Trade Ledgers"
{
    trigger OnRun()
    begin
        Init();
        Process();
    end;




    // local procedure CreateCustomerCOGsTradeLedger(var ValueEntry: Record "Value Entry")
    // var
    //     GlobalDim1Name: Text[50];
    //     GlobalDim2Name: Text[50];
    // begin

    //     // if GlobalDimension1NameDictionary.Get(ValueEntry."Global Dimension 1 Code", GlobalDim1Name) then;
    //     // if GlobalDimension2NameDictionary.Get(ValueEntry."Global Dimension 2 Code", GlobalDim2Name) then;

    //     ProcessValueEntry(ValueEntry);
    //     // ClearGlobals();
    // end;




    local procedure BuildDimensionNameValueDictionary(var DimValueDictionaryObject: Dictionary of [Code[20], Text[50]]; GlobalDimNumber: Integer)
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetRange("Global Dimension No.", GlobalDimNumber);
        if DimensionValue.IsEmpty() then
            exit;
        DimensionValue.SetLoadFields(Code, name);
        DimensionValue.FindSet(false);
        repeat
            DimValueDictionaryObject.Add(DimensionValue.Code, DimensionValue.name);
        until DimensionValue.Next() = 0;
    end;

    local procedure BuildTradeRateCodeGuidDictionary(var TradeRateCodeGuidDictionary: Dictionary of [Code[20], Guid])
    var
        SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes";
    begin
        SBCTATradeBudgetRateCodes.SetRange("Rate Type", "SBCTA Budget Group Type"::Customer);
        if SBCTATradeBudgetRateCodes.IsEmpty() then
            exit;
        SBCTATradeBudgetRateCodes.SetLoadFields("Trade Budget Rate Code", SystemId);
        SBCTATradeBudgetRateCodes.FindSet(false);
        repeat
            TradeRateCodeGuidDictionary.Add(SBCTATradeBudgetRateCodes."Trade Budget Rate Code", SBCTATradeBudgetRateCodes.SystemId);
        until SBCTATradeBudgetRateCodes.Next() = 0;

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

    // local procedure SetSelectionFilterText()
    // var
    //     SBCTATradeBudgetRateCodes: Page "SBCTA Trade Budget Rate Codes";
    //     SelectionFilterManagement: Codeunit "SelectionFilterManagement";
    //     SelectionFilterRecord: Record "SBCTA Trade Budget Rate Codes";
    //     SelctionFilterRef: RecordRef;
    //     LookupAction: Action;
    // begin
    //     SBCTATradeBudgetRateCodes.LookupMode(true);
    //     if not (SBCTATradeBudgetRateCodes.RunModal() = LookupAction::LookupOK) then
    //         exit;
    //     SBCTATradeBudgetRateCodes.SetSelectionFilter(SelectionFilterRecord);
    //     SelctionFilterRef.GetTable(SelectionFilterRecord);
    //     GlobalRateCodeFilterText := SelectionFilterManagement.GetSelectionFilter(SelctionFilterRef, SelectionFilterRecord.FieldNo("Trade Budget Rate Code"));
    // end;

    local procedure Init()
    begin
        OpenDialogue();
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        BuildDimensionNameValueDictionary(GlobalDimension1NameDictionary, 1);
        BuildDimensionNameValueDictionary(GlobalDimension2NameDictionary, 2);
        BuildTradeRateCodeGuidDictionary(GlobalTradeRateCodeGuidDictionary);
    end;

    local procedure Process()
    var
        ValueEntry: Record "Value Entry";
        SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes";
        ValueEntryFilterBuilder: FilterPageBuilder;
        ValueEntryLabel: Label 'Value Entry';
        TradeBudgetRateCodeLabel: Label 'Trade Budget Rate Code Filter';
        GlobalRateCodeId: Guid;
    begin
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Document Type", '%1|%2', ValueEntry."Document Type"::"Sales Invoice", ValueEntry."Document Type"::"Sales Credit Memo");
        ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
        ValueEntry.SetFilter("Sales Amount (Actual)", '<>%1', 0);

        ValueEntryFilterBuilder.AddRecord(ValueEntryLabel, ValueEntry);
        ValueEntryFilterBuilder.SetView(ValueEntryLabel, ValueEntry.GetView());
        ValueEntryFilterBuilder.AddRecord(TradeBudgetRateCodeLabel, SBCTATradeBudgetRateCodes);
        if not ValueEntryFilterBuilder.RunModal() then
            exit;
        ValueEntry.SetView(ValueEntryFilterBuilder.GetView(ValueEntryLabel));
        SBCTATradeBudgetRateCodes.SetView(ValueEntryFilterBuilder.GetView(TradeBudgetRateCodeLabel));
        GlobalRateCodeFilterText := SBCTATradeBudgetRateCodes.GetFilter(SBCTATradeBudgetRateCodes."Trade Budget Rate Code");
        if ValueEntry.IsEmpty() then
            exit;
        ValueEntry.FindSet(false);
        repeat
            if ValueEntry."Document No." <> GlobalLastDocumentNo then
                SetSellToCustomerValues(ValueEntry);
            if ActivateCOGsPosting(ValueEntry) then
                ProcessTradeCategories(ValueEntry);
            if GlobalOptionCommitOnWrite then
                if Database.IsInWriteTransaction() then
                    Database.Commit();
        until ValueEntry.Next() = 0;
    end;

    internal procedure ActivateCOGsPosting(var ValueEntry: Record "Value Entry") Activate: Boolean
    var
        SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        SBCTATradeBudget: Record "SBCTA Trade Budget";
    begin
        SBCTATradeBudget.SetFilter("Start Date", '<=%1', ValueEntry."Posting Date");
        SBCTATradeBudget.SetFilter("End Date", '>=%1', ValueEntry."Posting Date");
        SBCTATradeBudget.SetRange("Group Type", "SBCTA Budget Group Type"::Customer);
        SBCTATradeBudget.SetRange("Group Code", GlobalCustomer."Customer Posting Group");
        SBCTATradeBudget.SetRange(Enabled, true);
        SBCTATradeBudget.SetRange("Shortcut Dimension 1 Code", ValueEntry."Global Dimension 1 Code");
        if SBCTATradeBudget.IsEmpty() then
            SBCTATradeBudget.SetFilter("Shortcut Dimension 1 Code",'%1',''); //If no named budget, search specifically for a blank budget.
        if SBCTATradeBudget.IsEmpty() then
            exit;
        SBCTATradeBudget.SetLoadFields("Trade Budget Code");
        SBCTATradeBudget.FindFirst();
        // GlobalTradeBudgetCodeTextBuilder.Clear();
        // GlobalTradeBudgetCodeTextBuilder.Append(SBCTATradeBudget."Trade Budget Code");
        GlobalBudgetCode := SBCTATradeBudget."Trade Budget Code";
        Activate := SBCTATradeBudgetSetup.GetCustomerSetup(GlobalCustomer."Customer Posting Group", GlobalCustomer."No.", ValueEntry."Global Dimension 1 Code", SBCTATradeBudgetSetup); // todo(Change this so that it takes item category or item dimension into account.) Change this to take the Trade Budget Code.
        if not Activate then
            exit;
        if GlobalRateCodeFilterText <> '' then
            SBCTATradeBudgetSetup.SetFilter("Trade Budget Rate Code", GlobalRateCodeFilterText);
        Activate := not SBCTATradeBudgetSetup.IsEmpty();
        if not Activate then
            exit;
    end;

    // internal procedure ProcessValueEntry(ValueEntry: Record "Value Entry")
    // begin
    //     // GlobalRunFromBatch := true;
    //     SetSellToCustomerValues(ValueEntry);
    //     if not ActivateCOGsPosting(ValueEntry) then
    //         exit;
    //     ProcessTradeCategories(ValueEntry);
    // end;

    local procedure SetSellToCustomerValues(var ValueEntry: Record "Value Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        GlobalCustomer.Reset();
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
        GlobalCustomer.SetRange("No.", CustLedgerEntry."Sell-to Customer No.");
        GlobalCustomer.SetLoadFields("No.", "Customer Posting Group");
        if GlobalCustomer.IsEmpty() then
            exit;
        GlobalCustomer.FindFirst();
        GlobalLastDocumentNo := ValueEntry."Document No.";
        // GlobalLastDocumentNoTextBuilder.Clear();
        // GlobalLastDocumentNoTextBuilder.Append(ValueEntry."Document No.");
    end;

    internal procedure ProcessTradeCategories(var ValueEntry: Record "Value Entry")
    var
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
        EntryExists: Boolean;
        RecreateEntry: Boolean;
        TradeBudgetAmount: Decimal;
        TradeBudgetBasis: Decimal;
    begin
        SBCTATradeBudgetRates.SetRange("Trade Budget Code", GlobalBudgetCode);
        SBCTATradeBudgetRates.SetFilter("Trade Budget Rate", '<>%1', 0);
        If SBCTATradeBudgetRates.IsEmpty() then
            exit;
        // For each valid rate code.
        SBCTATradeBudgetRates.FindSet();
        repeat
            TradeBudgetBasis := -1 * ValueEntry."Sales Amount (Actual)" + ValueEntry."Discount Amount"; // Adds the discount amount back in. -- Need to add back other methods here if desired by EB.

            TradeBudgetAmount := GetAmount(TradeBudgetBasis, 1, 1, "SBCTA Calc. Basis Type"::COGS, SBCTATradeBudgetRates); // 1 is fine because this already takes into account the quantity.
            if TradeBudgetAmount = 0 then
                exit;

            CreateLedgerEntry(TradeBudgetAmount, TradeBudgetBasis, ValueEntry, SBCTATradeBudgetRates);
        until SBCTATradeBudgetRates.Next() = 0;
    end;



    internal procedure GetAmount(ValueAmount: Decimal; ValuedQuantity: Decimal; AmountConversionFactor: Decimal; SBCTACalcBasisType: Enum "SBCTA Calc. Basis Type"; var SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates") TradeBudgetAmount: Decimal
    var
        Currency: Record Currency;
        SignFactor: Integer;
        ExtendedAmount: Decimal;
    begin
        ExtendedAmount := ValueAmount * ValuedQuantity;
        if ExtendedAmount = 0 then
            exit;
        // Currency.InitRoundingPrecision();
        if ExtendedAmount < 0 then
            SignFactor := -1
        else
            SignFactor := 1;

        case SBCTATradeBudgetRates."Trade Budget Rate Type" of
            SBCTATradeBudgetRates."Trade Budget Rate Type"::Percent:
                TradeBudgetAmount := Round((ExtendedAmount * SBCTATradeBudgetRates."Trade Budget Rate") / 100, 0.00001);
            SBCTATradeBudgetRates."Trade Budget Rate Type"::Amount:
                // TradeBudgetAmount := Round((SignFactor * (ValuedQuantity / AmountConversionFactor) * SBCTATradeBudgetRates."Trade Budget Rate"), 0.00001); // This is done so that base quantity can be converted to the same unit of measure as the trade budget rate.
                TradeBudgetAmount := Round(((ValuedQuantity / AmountConversionFactor) * SBCTATradeBudgetRates."Trade Budget Rate"), 0.00001); // This is done so that base quantity can be converted to the same unit of measure as the trade budget rate. --2024-11-26 Added for parity with Customer and Item processing codeunits.
        end;
        if SBCTACalcBasisType <> SBCTACalcBasisType::COGS then
            exit;
        TradeBudgetAmount *= -1;
    end;

    internal procedure CreateLedgerEntry(TradeBudgetAmount: Decimal; LedgerAmount: Decimal; var ValueEntry: Record "Value Entry"; var SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates") Created: Boolean
    var
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        SignFactor: Integer;
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        // if GlobalReprocessEntry and GlobalFromValueEntry then
        //     SBCTATrBudgetLedgerEntry := Rec
        // else
        SBCTATrBudgetLedgerEntry.Init();

        SBCTATrBudgetLedgerEntry."Value Entry No." := ValueEntry."Entry No.";
        SignFactor := -1;
        case ValueEntry."Document Type" of
            ValueEntry."Document Type"::"Sales Invoice", ValueEntry."Document Type"::"Purchase Invoice":
                GenJournalDocumentType := GenJournalDocumentType::Invoice;
            ValueEntry."Document Type"::"Sales Credit Memo", ValueEntry."Document Type"::"Purchase Credit Memo":
                GenJournalDocumentType := GenJournalDocumentType::"Credit Memo";
        end;
        SBCTATrBudgetLedgerEntry."Trade Budget Code" := SBCTATradeBudgetRates."Trade Budget Code";
        SBCTATrBudgetLedgerEntry."Trade Budget Rate Code" := SBCTATradeBudgetRates."Trade Budget Rate Code";
        SBCTATrBudgetLedgerEntry."Trade Budget Rate Code ID" := GlobalTradeRateCodeGuidDictionary.Get(SBCTATradeBudgetRates."Trade Budget Rate Code");
        SBCTATrBudgetLedgerEntry."Trade Budget Rate ID" := SBCTATradeBudgetRates.SystemId;
        SBCTATrBudgetLedgerEntry."Document No." := ValueEntry."Document No.";
        SBCTATrBudgetLedgerEntry."Document Line No." := ValueEntry."Document Line No.";
        SBCTATrBudgetLedgerEntry."Document Type" := GenJournalDocumentType;
        SBCTATrBudgetLedgerEntry."Posting Date" := ValueEntry."Posting Date";
        SBCTATrBudgetLedgerEntry."Group Type" := "SBCTA Budget Group Type"::Customer;
        // SBCTATrBudgetLedgerEntry."Group Code" := ValueEntry."Source Posting Group";
        // SBCTATrBudgetLedgerEntry."Customer No." := ValueEntry."Source No.";
        SBCTATrBudgetLedgerEntry."Group Code" := GlobalCustomer."Customer Posting Group";
        SBCTATrBudgetLedgerEntry."Customer No." := GlobalCustomer."No.";
        SBCTATrBudgetLedgerEntry."Calculation Basis" := "SBCTA Calc. Basis Type"::COGS;
        SBCTATrBudgetLedgerEntry."Calculation Method" := "SBCTA COGs Calc Type"::"Gross Sale";
        SBCTATrBudgetLedgerEntry."Trade Budget Amount" := TradeBudgetAmount;
        SBCTATrBudgetLedgerEntry."Source Entry Amount" := SignFactor * LedgerAmount;
        SBCTATrBudgetLedgerEntry."Sales Amount" := ValueEntry."Sales Amount (Actual)";
        SBCTATrBudgetLedgerEntry."Cost Amount" := SignFactor * ValueEntry."Cost Amount (Actual)";
        SBCTATrBudgetLedgerEntry."Discount Amount" := SignFactor * ValueEntry."Discount Amount";
        SBCTATrBudgetLedgerEntry."Dimension Set ID" := ValueEntry."Dimension Set ID";
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 1 Code" := ValueEntry."Global Dimension 1 Code";
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 2 Code" := ValueEntry."Global Dimension 2 Code";

        // GlobalSBCTATrBudgetLedgerEntry."Shortcut Dimension 1 Name" := GlobalDim1Name;
        // GlobalSBCTATrBudgetLedgerEntry."Shortcut Dimension 2 Name" := GlobalDim2Name;
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 1 Name" := GlobalDimension1NameDictionary.Get(ValueEntry."Global Dimension 1 Code");
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 2 Name" := GlobalDimension2NameDictionary.Get(ValueEntry."Global Dimension 2 Code");
        SBCTATrBudgetLedgerEntry."Item No." := ValueEntry."Item No.";
        // if EntryExists then
        //     Created := SBCTATrBudgetLedgerEntry.Modify(true)
        // else
        Created := SBCTATrBudgetLedgerEntry.Insert(true);
    end;



    var

        GlobalRateCodeFilterText: Text;
        // GlobalSBCTAItemEvents: Codeunit "SBCTA Item Events";
        GlobalSBCTACustomerEvents: Codeunit "SBCTA Customer Events";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalCustomer: Record Customer;
        GlobalBudgetCode: Code[20];
        GlobalLastDocumentNo: Code[20];
        GlobalOptionCommitOnWrite: Boolean;
        GlobalOptionRecreateValueEntry: Boolean;
        ProcessingDialogTextLabel: Label 'Creating Trade Ledgers.';
        GlobalDialog: Dialog;
        GlobalDimension1NameDictionary: Dictionary of [Code[20], Text[50]];
        GlobalDimension2NameDictionary: Dictionary of [Code[20], Text[50]];
        GlobalTradeRateCodeGuidDictionary: Dictionary of [Code[20], Guid];

}