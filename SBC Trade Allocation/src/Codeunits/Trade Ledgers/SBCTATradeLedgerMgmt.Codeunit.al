/// <summary>
/// This codeunit posts trade budget ledgers.
/// </summary>
codeunit 50200 "SBCTA Trade Ledger Mgmt."
{

    var
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalSTABracketPriceLedger: Record "STA Bracket Price Ledger";
        GlobalSBCTACustomerEvents: Codeunit "SBCTA Customer Events";
        GlobalSBCTAITemEvents: Codeunit "SBCTA Item Events";
        GlobalSBCTAIPurchTemEvents: Codeunit "SBCTA Purch Item Events";
        GlobalSBCTAPreviewPostingHandler: Codeunit "SBCTA Preview Posting Events";

        GlobalSBCTALedgerEntryHandler: Codeunit "SBCTA Ledger Entry Handler";

        GlobalSTABracketPriceEvents: Codeunit "STA Bracket Price Events";
        GlobalSBCTACOGSPreviewHandler: Codeunit "SBCTA COGS Preview Events";
        GlobalSTABracketPreviewHandler: Codeunit "STA Bracket Preview Handler";
        COGSAccountSetupErrorLabel: Label 'COGS Account is not definied in General Posting Setup for Gen. Bus. Posting Group %1 and Gen. Prod. Posting Group %2';


    #region "Bracket Pricing"

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostCommitSalesDoc, '', false, false)]
    local procedure OnBeforePostCommitSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; var ModifyHeader: Boolean; var CommitIsSuppressed: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)

    var
        SalesHeaderRecordRef: RecordRef;
    begin
        if SolutionDisabled() then
            exit;
        if not (SalesHeader."Document Type" in ["Sales Document Type"::Order, "Sales Document Type"::"Credit Memo"]) then
            exit;
        SalesHeaderRecordRef.GetTable(SalesHeader);
        GlobalSTABracketPriceEvents.Unbind(true);
        GlobalSTABracketPriceEvents.BindEventCU(SalesHeaderRecordRef, Database::"Sales Header");
    end;

    #endregion "Bracket Pricing"


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterCalcPosShares, '', false, false)]
    // local procedure OnAfterCalcPosShares(var ItemJournalLine: Record "Item Journal Line"; var DirCost: Decimal; var OvhdCost: Decimal; var PurchVar: Decimal; var DirCostACY: Decimal; var OvhdCostACY: Decimal; var PurchVarACY: Decimal; var CalcUnitCost: Boolean; CalcPurchVar: Boolean; Expected: Boolean; GlobalItemLedgerEntry: Record "Item Ledger Entry")
    // var
    //     ItemLedgerEntry: Record "Item Ledger Entry";
    //     SBCTATradeBudget: Record "SBCTA Trade Budget";
    //     ItemCategory: Record "Item Category";
    //      SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    // begin
    //     // GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
    //     // if not GlobalSBCTATradeBudgetOptions."Use Dimension Matching" then begin
    //     //     ItemLedgerEntry.SetRange("Entry No.", GlobalItemLedgerEntry."Entry No.");
    //     //     ItemLedgerEntry.SetLoadFields("Item Category Code");
    //     //     if not ItemLedgerEntry.FindFirst() then
    //     //         exit;
    //     //     ItemCategory.SetRange("Code", ItemLedgerEntry."Item Category Code");
    //     //     ItemCategory.SetLoadFields("Code");
    //     //     if not ItemCategory.FindFirst() then
    //     //         exit;
    //     // end;

    //     // if GlobalSBCTATradeBudgetOptions."Use Dimension Matching" then
    //     //     SBCTATradeBudget.SetRange("Shortcut Dimension 1 Code", GlobalItemLedgerEntry."Global Dimension 1 Code")
    //     // else
    //     //     SBCTATradeBudget.SetRange("Group Code", ItemCategory.Code);
    //     //   SBCTATradeBudget.SetRange(Enabled, true);
    //     // if SBCTATradeBudget.IsEmpty() then
    //     //     exit;
    //     // SBCTATradeBudget.FindFirst();
    //     OvhdCost := 0.42;
    // end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnPostInvtPostBufferOnAfterPostInvtPostBuf, '', false, false)]
    local procedure OnPostInvtPostBufferOnAfterPostInvtPostBuf(var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; var ValueEntry: Record "Value Entry"; CalledFromItemPosting: Boolean; CalledFromTestReport: Boolean; RunOnlyCheck: Boolean; PostPerPostGrp: Boolean);
    begin
        if not ProcessValueEntry(ValueEntry) then
            exit;

        if ValueEntry."Location Code" = '' then
            exit;
        if not (ValueEntry."Entry Type" in [ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Entry Type"::Revaluation]) then
            exit;
        // if not (ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::Sale, "Item Ledger Entry Type"::Purchase, "Item Ledger Entry Type"::"Positive Adjmt.", "Item Ledger Entry Type"::"Negative Adjmt."]) then
        //     exit;
        if not (ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::Sale, "Item Ledger Entry Type"::Purchase, "Item Ledger Entry Type"::Output, "Item Ledger Entry Type"::Transfer]) or
            ((ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::Transfer]) and
                (not (ValueEntry."Source Code" = GlobalSBCTALedgerEntryHandler.GetReclassSourceCode()) and // Not a Reclass Item Journal //Todo(Add source code selection or filtering to the UI rather than as a text constant here.)
                 not ((ValueEntry."Document Type" = "Item Ledger Document Type"::"Transfer Receipt") and (ValueEntry.Type = "Capacity Type Journal"::"Work Center"))) or // Not a Transfer Receipt linked to a Workcenter
            ((ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::Output]) and // Specific Output Check
             not ((ValueEntry."Document Type" = "Item Ledger Document Type"::" ") and (ValueEntry.Type = "Capacity Type Journal"::"Work Center"))))
                 then
            exit; // Rebuild this condition. It lets through unexpected transactions. The real intent is to allow Sales, Purchases, '', Transfer for Reclass Source Code //Output added to burden outbound inventory linked to a PO.
                  // This should exclude transfers exclusively that don't use the correct source code. Also test for transfer receipts.

        case GlobalInvtPostBuf."Account Type" of
            "Invt. Posting Buffer Account Type"::COGS:
                InitializeDirectCostPosting(GlobalInvtPostBuf, ValueEntry);
            "Invt. Posting Buffer Account Type"::"COGS (Interim)":
                begin
                    InitializeDirectCostPosting(GlobalInvtPostBuf, ValueEntry);
                    if ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::"Positive Adjmt.", "Item Ledger Entry Type"::"Negative Adjmt."] then
                        InitializePurchForItemCOGsPosting(GlobalInvtPostBuf, ValueEntry);
                end;
            "Invt. Posting Buffer Account Type"::Inventory,
             "Invt. Posting Buffer Account Type"::"Inventory (Interim)", "Invt. Posting Buffer Account Type"::"Inventory Adjmt.",  // Added to capture postive and negative adjustments.
             "Invt. Posting Buffer Account Type"::"WIP Inventory": //Added to capture Work Center Output
                if ValueEntry."Item Ledger Entry Type" <> "Item Ledger Entry Type"::Sale then
                    InitializePurchForItemCOGsPosting(GlobalInvtPostBuf, ValueEntry);

            "Invt. Posting Buffer Account Type"::"Direct Cost Applied":
                InitializePurchForItemCOGsPosting(GlobalInvtPostBuf, ValueEntry);
        end;
    end;

    /// <summary>
    /// This event is subscribed to so that Item Journal Adjustments can burden Indirect Costs
    /// </summary>
    /// <param name="GlobalInvtPostBuf">Temporary VAR Record "Invt. Posting Buffer".</param>
    /// <param name="GenJnlLine">VAR Record "Gen. Journal Line".</param>
    /// <param name="ValueEntry">VAR Record "Value Entry".</param>
    /// <param name="GenJnlPostLine">VAR Codeunit "Gen. Jnl.-Post Line".</param>
    /// <param name="CalledFromItemPosting">Boolean.</param>
    /// <param name="PostPerPostGroup">Boolean.</param>
    /// <param name="IsHandled">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnBeforePostInvtPostBufProcessGlobalInvtPostBuf, '', false, false)]
    local procedure OnBeforePostInvtPostBufProcessGlobalInvtPostBuf(var GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var GenJnlLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CalledFromItemPosting: Boolean; PostPerPostGroup: Boolean; var IsHandled: Boolean)
    var
        SBCTALedgerEntryHandler: Codeunit "SBCTA Ledger Entry Handler";
    begin
        if not ProcessValueEntry(ValueEntry) then
            exit;

        if not (ValueEntry."Item Ledger Entry Type" in [ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.", ValueEntry."Item Ledger Entry Type"::"Negative Adjmt."]) then
            // and (not (ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::Transfer]) and (ValueEntry."Source Code" = 'RECLASSJNL')) 
            exit;
        SBCTALedgerEntryHandler.Bind(); // We are binding early to take advantage of StartOrContinuePosting.
        // InitializePurchForItemCOGsPosting(GlobalInvtPostBuf, ValueEntry);
    end;

    internal procedure GetItemEntryRelationFromDocument(DocumentNo: Code[20]; TableNo: Integer) ItemEntryRelation: Record "Item Entry Relation";
    begin
        ItemEntryRelation.SetRange("Source ID", DocumentNo);
        ItemEntryRelation.SetRange("Source Type", TableNo);
    end;

    internal procedure GetIndirectCostValueEntry(ItemLedgerEntry: Record "Item Ledger Entry") ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetRange("Entry Type", "Cost Entry Type"::"Indirect Cost");
    end;

    internal procedure GetIndirectCostValueEntry(ItemLedgerEntryNo: Integer; PostingDescription: Text[100]; ItemLedgerDocumentType: Enum "Item Ledger Document Type") ValueEntry: Record "Value Entry";
    var
        ItemLedgerDocumentSearchType: Enum "Item Ledger Document Type";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        // if PostingDescription <> '' then
        ValueEntry.SetFilter(Description, '%1', PostingDescription);
        case ItemLedgerDocumentType of
            "Item Ledger Document Type"::"Purchase Invoice":
                ItemLedgerDocumentSearchType := "Item Ledger Document Type"::"Purchase Receipt";
            "Item Ledger Document Type"::"Purchase Credit Memo":
                ItemLedgerDocumentSearchType := "Item Ledger Document Type"::"Purchase Return Shipment";
            "Item Ledger Document Type"::"Sales Invoice":
                ItemLedgerDocumentSearchType := "Item Ledger Document Type"::"Sales Shipment";
            "Item Ledger Document Type"::"Sales Credit Memo":
                ItemLedgerDocumentSearchType := "Item Ledger Document Type"::"Sales Return Receipt";
            else
                ItemLedgerDocumentSearchType := ItemLedgerDocumentType;
        end;
        ValueEntry.SetRange("Document Type", ItemLedgerDocumentSearchType);
    end;

    local procedure InitializeForCustomerCOGsPosting(InvtPostingBuffer: Record "Invt. Posting Buffer" temporary; var ValueEntry: Record "Value Entry")
    begin
        if ValueEntry."Applies-to Entry" <> 0 then //Adjustment Entries
            exit;
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        if GlobalSBCTATradeBudgetOptions."Calculation Basis" <> Enum::"SBCTA Calc. Basis Type"::"COGS" then
            exit;
        if not GlobalSBCTACustomerEvents.ActivateCOGsPosting(ValueEntry, InvtPostingBuffer) then
            exit;
        GlobalSBCTACustomerEvents.Bind(false);
    end;

    local procedure InitializeForItemCOGsPosting(InvtPostingBuffer: Record "Invt. Posting Buffer" temporary; var ValueEntry: Record "Value Entry")
    begin
        if ValueEntry."Applies-to Entry" <> 0 then //Adjustment Entries
            exit;
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        if GlobalSBCTATradeBudgetOptions."Calculation Basis" <> Enum::"SBCTA Calc. Basis Type"::"COGS" then
            exit;

        if not GlobalSBCTAItemEvents.ActivateCOGsPosting(ValueEntry) then
            exit;
        GlobalSBCTAItemEvents.Bind(false);
    end;

    local procedure InitializePurchForItemCOGsPosting(InvtPostingBuffer: Record "Invt. Posting Buffer" temporary; var ValueEntry: Record "Value Entry")
    begin
        if ValueEntry."Applies-to Entry" <> 0 then //Adjustment Entries
            exit;
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        if GlobalSBCTATradeBudgetOptions."Calculation Basis" <> Enum::"SBCTA Calc. Basis Type"::"COGS" then
            exit;

        if not GlobalSBCTAIPurchTemEvents.ActivateCOGsPosting(ValueEntry) then
            exit;
        GlobalSBCTAIPurchTemEvents.Bind(false);
    end;

    local procedure InitializeDirectCostPosting(var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; var ValueEntry: Record "Value Entry")
    begin
        InitializeForCustomerCOGsPosting(GlobalInvtPostBuf, ValueEntry);
        InitializeForItemCOGsPosting(GlobalInvtPostBuf, ValueEntry);
    end;

    local procedure BindTradePreviewHandler()
    begin
        if GlobalSBCTAPreviewPostingHandler.IsBound() then
            exit;
        GlobalSBCTAPreviewPostingHandler.Bind(true);
    end;


    local procedure UnbindTradePreviewHandler()
    begin
        GlobalSBCTAPreviewPostingHandler.Unbind(true);
    end;

    local procedure BindCOGSPreviewHandler()
    begin
        if GlobalSBCTACogsPreviewHandler.IsBound() then
            exit;
        GlobalSBCTACogsPreviewHandler.Bind(true);
    end;

    local procedure BindSTABracketPreviewHandler()
    begin
        if GlobalSTABracketPreviewHandler.IsBound() then
            exit;
        GlobalSTABracketPreviewHandler.Bind(true);
    end;

    local procedure UnbindCOGsPreviewHandler()
    begin
        GlobalSBCTACogsPreviewHandler.Unbind(true);
    end;

    local procedure UnbindSTABracketPreviewHandler()
    begin
        GlobalSTABracketPreviewHandler.Unbind(true);
    end;

    local procedure SetCustomerSalesRecordRef(RecVar: Variant)
    var
        TypeHelper: Codeunit "Type Helper";
        SalesDocRecordRef: RecordRef;
    begin
        TypeHelper.CopyRecVariantToRecRef(RecVar, SalesDocRecordRef);
        if Format(SalesDocRecordRef) = '' then
            exit;
        if SalesDocRecordRef.Number <> Database::"Sales Header" then
            exit;
        GlobalSBCTACustomerEvents.SetSalesDocRecordRef(SalesDocRecordRef);
    end;

    local procedure ProcessValueEntry(var ValueEntry: Record "Value Entry") Process: Boolean;
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetLoadFields("Disable Solution", "Skip During Adjust Cost");
        SBCTATradeBudgetOptions.FindFirst();

        if SBCTATradeBudgetOptions."Disable Solution" then
            exit;
        if ValueEntry.Adjustment and SBCTATradeBudgetOptions."Skip During Adjust Cost" then
            exit;

        Process := true;
    end;

    local procedure SolutionDisabled() Disabled: Boolean;
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetLoadFields("Disable Solution");
        SBCTATradeBudgetOptions.SetRange("Disable Solution", true);
        Disabled := not SBCTATradeBudgetOptions.IsEmpty();
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnSystemSetPostingPreviewActive', '', false, false)]
    local procedure SetTrueOnSystemSetPostingPreviewActive(var Result: Boolean)
    begin
        if SolutionDisabled() then
            exit;
        // Result := true;
        //Activate Preview Handler here.
        BindTradePreviewHandler();
        BindCOGSPreviewHandler();
        BindSTABracketPreviewHandler()
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnBeforeRunPreview', '', false, false)]
    local procedure OnBeforeRunPreview(Subscriber: Variant; RecVar: Variant)
    begin
        if SolutionDisabled() then
            exit;
        SetCustomerSalesRecordRef(RecVar);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeRunSalesPost', '', false, false)]
    local procedure OnBeforeRunSalesPost(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; var SuppressCommit: Boolean)
    begin
        if SolutionDisabled() then
            exit;
        SetCustomerSalesRecordRef(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"G/L Posting Preview", 'OnClosePageEvent', '', false, false)]
    local procedure SBCTAOnClosePageEvent(var Rec: Record "Document Entry" temporary)
    begin
        if SolutionDisabled() then
            exit;
        UnbindTradePreviewHandler();
        UnbindCOGsPreviewHandler();
        UnbindSTABracketPreviewHandler();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckGLAccDirectPosting', '', false, false)]
    local procedure AllowDirectPosting(var GenJournalLine: Record "Gen. Journal Line"; GLAcc: Record "G/L Account"; var IsHandled: Boolean)
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        if SolutionDisabled() then
            exit;
        if IsNullGuid(GenJournalLine."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(GenJournalLine."SBCTA ID") then
            exit;
        SBCTATradeBudgetOptions.SetRange("Allow Direct Posting", true);
        if SBCTATradeBudgetOptions.IsEmpty() then
            exit;
        IsHandled := true
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeGetCustomerReceivablesAccount', '', false, false)]
    local procedure SwapReceivablesAccountOnCreditPosting(GenJournalLine: Record "Gen. Journal Line"; CustomerPostingGroup: Record "Customer Posting Group"; var ReceivablesAccount: Code[20]; var IsHandled: Boolean)
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
    begin
        if SolutionDisabled() then
            exit;
        if IsNullGuid(GenJournalLine."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(GenJournalLine."SBCTA ID") then
            exit;
        SBCTATradeBudgetOptions.SetRange("Swap Receivables Account", true);
        if SBCTATradeBudgetOptions.IsEmpty() then
            exit;
        SBCTATradeAccrualLine.SetRange("Journal Line Id", GenJournalLine."SBCTA ID");
        SBCTATradeAccrualLine.SetLoadFields("Trade Budget Rate Code");
        SBCTATradeAccrualLine.FindFirst();
        if not SBCTATradeBudgetSetup.GetCustomerSetup(CustomerPostingGroup.Code, GenJournalLine."Account No.", GenJournalLine."Shortcut Dimension 1 Code", SBCTATradeAccrualLine."Trade Budget Rate Code", SBCTATradeBudgetSetup) then
            exit;
        SBCTATradeBudgetSetup.SetLoadFields("Posting Account");
        SBCTATradeBudgetSetup.FindFirst();
        ReceivablesAccount := SBCTATradeBudgetSetup."Posting Account";
        if ReceivablesAccount = '' then
            exit;
        IsHandled := ReceivablesAccount <> CustomerPostingGroup."Receivables Account"
    end;

    internal procedure SetSellToCustomerValues(var ValueEntry: Record "Value Entry")
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


    #region AdjustCost

    /// <summary>
    /// OnBeforePostItemJnlLine. I think this issue is caused because the reversal process does not create a new IC VE Entry. This is a secondary check to ensure that the IC VE Entry is not part of the solution. The root of this issue still needs to be resolved.
    /// </summary>
    /// <param name="ItemJournalLine">VAR Record "Item Journal Line".</param>
    /// <param name="OrigValueEntry">Record "Value Entry".</param>
    /// <param name="NewAdjustedCost">Decimal.</param>
    /// <param name="NewAdjustedCostACY">Decimal.</param>
    /// <param name="SkipUpdateJobItemCost">Boolean.</param>
    /// <param name="IsHandled">VAR Boolean.</param>

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment", OnBeforePostItemJnlLine, '', false, false)]
    local procedure OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; SkipUpdateJobItemCost: Boolean; var IsHandled: Boolean)
    var
        SBCTAIndirectCOGsLedgerVE: Record "SBCTA Indirect COGs Ledger";
        SBCTAIndirectCOGsLedgerDocItem: Record "SBCTA Indirect COGs Ledger";
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes";
    begin
        // Solution Disabling is explicitly not checked for here.
        SBCTATradeBudgetOptions.SetRange("Skip During Adjust Cost", true);
        SBCTATradeBudgetOptions.SetLoadFields("Skip During Adjust Cost");
        if SBCTATradeBudgetOptions.IsEmpty() then
            exit;
        if IsHandled then
            exit;
        // if (OrigValueEntry."Entry Type" <> "Cost Entry Type"::"Indirect Cost") or (DOrigValueEntry.Description = '') then
        //     exit;

        SBCTAIndirectCOGsLedgerVE.SetFilter("Value Entry No.", '%1', OrigValueEntry."Entry No.");
        SBCTAIndirectCOGsLedgerVE.SetLoadFields("Value Entry No.", "Document No.");
        // SBCTAIndirectCOGsLedger.FilterGroup(-1);
        // if SBCTAIndirectCOGsLedgerVE.IsEmpty() then
        //     exit;
        // IsHandled := (not SBCTAIndirectCOGsLedgerVE.IsEmpty());
        IsHandled := (OrigValueEntry."Entry Type" = "Cost Entry Type"::"Indirect Cost") and (not SBCTAIndirectCOGsLedgerVE.IsEmpty() or (OrigValueEntry."Document Type" = "Item Ledger Document Type"::"Purchase Return Shipment"));
        if IsHandled then
            exit;
        if OrigValueEntry.Description = '' then // The IC VE process sets a description. If one is not set, then it is not an IC VE Entry.
            exit;
        if not (OrigValueEntry."Entry Type" in ["Cost Entry Type"::"Indirect Cost", "Cost Entry Type"::"Direct Cost"]) then
            exit;
        // This secondary check determines if the IC Entry Belongs to the solution, but somehow does not have a IC Entry.
        SBCTAIndirectCOGsLedgerDocItem.SetRange("Document Type", OrigValueEntry."Document Type");
        SBCTAIndirectCOGsLedgerDocItem.SetFilter("Document No.", '%1', OrigValueEntry."Document No.");
        SBCTAIndirectCOGsLedgerDocItem.SetFilter("Item No.", '%1', OrigValueEntry."Item No.");
        // SBCTAIndirectCOGsLedgerDocItem.SetLoadFields("Document No.", "Item No.", "Document Type");
        SBCTATradeBudgetRateCodes.SetFilter(Description, '%1', OrigValueEntry.Description);
        IsHandled := (not SBCTAIndirectCOGsLedgerDocItem.IsEmpty() and not SBCTATradeBudgetRateCodes.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment", OnBeforeUpdateAdjmtBuf, '', false, false)]
    local procedure OnBeforeUpdateAdjmtBuf(OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; ItemLedgEntryPostingDate: Date; EntryType: Enum "Cost Entry Type"; var Result: Boolean; var IsHandled: Boolean)
    var
        SBCTAIndirectCOGsLedgerVE: Record "SBCTA Indirect COGs Ledger";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SBCTAActualCostBufferUpd: Codeunit "SBCTA - Actual Cost Buffer Upd";
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    // SignFactor : Integer;
    begin
        SBCTATradeBudgetOptions.SetRange("Exclude Sales Indirect Cost", true);
        if SBCTATradeBudgetOptions.IsEmpty() then
            exit;
        if IsHandled then
            exit;
        if NewAdjustedCost = 0 then
            exit;
        SBCTAIndirectCOGsLedgerVE.SetRange("Value Entry No.", OrigValueEntry."Entry No.");
        SBCTAIndirectCOGsLedgerVE.SetFilter("Trade Budget Amount", '<>%1', 0);
        if SBCTAIndirectCOGsLedgerVE.IsEmpty() then
            exit;
        SBCTAIndirectCOGsLedgerVE.CalcSums("Trade Budget Amount");
        GeneralLedgerSetup.SetLoadFields("Amount Rounding Precision");
        GeneralLedgerSetup.FindSet();
        // if NewAdjustedCost > 0 then 
        //     SignFactor := 1;
        NewAdjustedCost := NewAdjustedCost + Round(SBCTAIndirectCOGsLedgerVE."Trade Budget Amount", GeneralLedgerSetup."Amount Rounding Precision"); // Add a bind here for entries that are not zero so that a later event can subtract the new adjusted cost amount downstream. If zero, set to handled and set result to true.
        IsHandled := NewAdjustedCost = 0;
        Result := IsHandled;
        if IsHandled then
            exit;
        SBCTAActualCostBufferUpd.Bind(true);
        SBCTAActualCostBufferUpd.SetAdjustedCostAmount(NewAdjustedCost);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment", OnBeforeCalcInbndEntryAdjustedCost, '', false, false)]
    local procedure OnBeforeCalcInbndEntryAdjustedCost(var AdjustedCostElementBuf: Record "Cost Element Buffer"; ItemApplnEntry: Record "Item Application Entry"; OutbndItemLedgEntryNo: Integer; InbndItemLedgEntryNo: Integer; ExactCostReversing: Boolean; Recursion: Boolean; var CompletelyInvoiced: Boolean; var IsHandled: Boolean)
    var
        ValueEntry: Record "Value Entry";
        SBCTAIndirectCOGsLedgerVE: Record "SBCTA Indirect COGs Ledger";
        SBCTAInboundCostBuffer: Codeunit "SBCTA Inbound Cost Buffer";
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetRange("Exclude Purchase Indirect Cost", true);
        if SBCTATradeBudgetOptions.IsEmpty() then
            exit;
        ValueEntry.SetRange("Item Ledger Entry No.", InbndItemLedgEntryNo);
        ValueEntry.SetRange("Entry Type", "Cost Entry Type"::"Indirect Cost");
        if ValueEntry.IsEmpty() then
            exit;
        ValueEntry.SetLoadFields("Entry No.", "Document No.");
        ValueEntry.FindFirst();
        SBCTAIndirectCOGsLedgerVE.SetRange("Document No.", ValueEntry."Document No.");
        SBCTAIndirectCOGsLedgerVE.SetFilter("Trade Budget Amount", '<>%1', 0);
        if SBCTAIndirectCOGsLedgerVE.IsEmpty() then
            exit;
        SBCTAInboundCostBuffer.Bind(true);
        SBCTAInboundCostBuffer.SetInboundItemledgerEntryNo(InbndItemLedgEntryNo);
    end;

    #endregion AdjustCost

    #region Corrective Invoices

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", OnBeforeCreateCorrectiveSalesCrMemo, '', false, false)]
    local procedure OnBeforeCreateCorrectiveSalesCrMemo(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SBCTACorrectiveInvoiceEvent: Codeunit "SBCTA Corrective Invoice Event";
    begin
        SBCTACorrectiveInvoiceEvent.Bind(true);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Batch Post Sales Orders", OnBeforeSalesBatchPostMgt, '', false, false)]
    local procedure OnBeforeSalesBatchPostMgt(var SalesHeader: Record "Sales Header"; var ShipReq: Boolean; var InvReq: Boolean; var SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt."; var IsHandled: Boolean)
    var
        SBCTACorrectiveInvoiceEvent: Codeunit "SBCTA Corrective Invoice Event";
    begin
        SBCTACorrectiveInvoiceEvent.Bind(true);
    end;

    #endregion Corrective Invoices
}