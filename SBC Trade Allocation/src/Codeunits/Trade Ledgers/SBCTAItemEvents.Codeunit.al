/// <summary>
/// Codeunit SBCTA Trade Ledger Events (ID 50201).
/// Sales Item Events
/// </summary>
codeunit 50204 "SBCTA Item Events"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    // #region AR
    // #region AREventSubscriber
    /// <summary>
    /// SBCTAOnPostCustOnAfterAssignReceivablesAccount.
    /// </summary>
    /// <param name="GenJnlLine">Record "Gen. Journal Line".</param>
    /// <param name="CustomerPostingGroup">Record "Customer Posting Group".</param>
    /// <param name="ReceivablesAccount">VAR Code[20].</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostCustOnAfterAssignReceivablesAccount, '', false, false)]
    local procedure SBCTAOnPostCustOnAfterAssignReceivablesAccount(GenJnlLine: Record "Gen. Journal Line"; CustomerPostingGroup: Record "Customer Posting Group"; var ReceivablesAccount: Code[20])

    begin
        Unbind();
        if not GlobalTempValueEntry.IsEmpty() then
            ProcessValueEntryBuffer(GlobalTempValueEntry);
        ClearGlobals();
    end;

    local procedure ProcessValueEntryBuffer(var TempValueEntryBuffer: Record "Value Entry" temporary)
    var
        ValueEntryNo: Integer;
    begin
        ProcessValueEntryBuffer(TempValueEntryBuffer, ValueEntryNo);
    end;

    local procedure ProcessValueEntryBuffer(var TempValueEntryBuffer: Record "Value Entry" temporary; var ValueEntryNo: Integer)
    var
        IterationCount: Integer;
        FilteredSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        TempValueEntryBuffer.FindSet();
        repeat
            IterationCount += 1;
            GlobalSBCTATradeBudget.GetBySystemId(GlobalTradeBudgetGUIDDictionary.Get(IterationCount));
            FilteredSBCTAIndirectPostingSetup.SetView(GlobalTradeBudgetSetupFilterDictionary.Get(IterationCount));
            CreateEntriesFromValueEntry(TempValueEntryBuffer, ValueEntryNo, FilteredSBCTAIndirectPostingSetup);
            GlobalTradeBudgetGUIDDictionary.Remove(IterationCount);
            GlobalTradeBudgetSetupFilterDictionary.Remove(IterationCount); // This should efficiently remove entries from the dictionary.
        until TempValueEntryBuffer.Next() = 0;
    end;



    local procedure SetSellToCustomerValues(var ValueEntry: Record "Value Entry") //Unique
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
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
    // #endregion AREventSubscriber




    // #endregion AR
    #region COGS
    #region COGSEventSubscriber

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterInsertValueEntry, '', false, false)]
    local procedure OnAfterInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer)
    begin
        if ValueEntryNo <= 1 then
            exit;
        Unbind();
        if not GlobalSBCTATradeBudgetOptions."Skip Inbound IC Check" then
            GlobalCheckForICCogsEntry := (ItemJournalLine."Document Type" in ["Item Ledger Document Type"::"Sales Invoice", "Item Ledger Document Type"::"Sales Credit Memo", "Item Ledger Document Type"::" "]); // If we wanted to make this check more robust, we would check the item tracking lines associated with the entry to determine if they had indirect cost associated BEFORE allowing Indirect Cost transactions to be created. 

        if not GlobalTempValueEntry.IsEmpty() then
            ProcessValueEntryBuffer(GlobalTempValueEntry, ValueEntryNo);
        ClearGlobals();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnPostInvtPostBufferOnAfterPostInvtPostBuf, '', false, false)]
    local procedure OnPostInvtPostBufferOnAfterPostInvtPostBuf(GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var ValueEntry: Record "Value Entry"; CalledFromItemPosting: Boolean; CalledFromTestReport: Boolean; RunOnlyCheck: Boolean; PostPerPostGrp: Boolean);
    begin
        if not GlobalTempValueEntry.IsEmpty() then
            exit;
        Unbind();
        CreateEntriesFromValueEntry(ValueEntry);
        ClearGlobals();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnBeforePostInvtPostBuf, '', false, false)] // This was added specifically to catch negative adjustments
    local procedure OnBeforePostInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if not (ValueEntry."Item Ledger Entry Type" in [ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.", ValueEntry."Item Ledger Entry Type"::"Negative Adjmt."]) then
            exit;
        if not GlobalTempValueEntry.IsEmpty() then
            exit;
        Unbind();
        CreateEntriesFromValueEntry(ValueEntry);
        ClearGlobals();
    end;

    #endregion COGSEventSubscriber
    internal procedure ValueEntryBufferHasEntries() HasEntries: Boolean
    begin
        HasEntries := not GlobalTempValueEntry.IsEmpty();
    end;

    // internal procedure ActivateCOGsPosting(ValueEntry: Record "Value Entry") Activate: Boolean
    // var
    //     InvtPostingBuffer: Record "Invt. Posting Buffer" temporary;
    // begin
    //     Activate := ActivateCOGsPosting(ValueEntry, InvtPostingBuffer);
    // end;

    internal procedure ActivateCOGsPosting(ValueEntry: Record "Value Entry") Activate: Boolean // Unique
    var
        ItemCategory: Record "Item Category";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
        ItemCategoryGroupCode: Code[20];
        BudgetDate: Date;
    begin
        if ValueEntry."Applies-to Entry" <> 0 then //Adjustments
            exit;
        // if (GlobalLastEntryNo <> 0) or ((GlobalLastEntryNo = 0) and (GlobalSBCTATradeBudgetOptions.SystemCreatedAt <> 0DT)) then // The second conditon ensures that the options are refreshed on each run if the auto post settings are off.
        //     ClearGlobals(); //If this code is entered, we should be recovering from an error.
        if (GlobalLastEntryNo <> 0) then
            ClearGlobals(); //If this code is entered, we should be recovering from an error.
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();

        if not GlobalRunFromBatch then begin
            if not GlobalSBCTATradeBudgetOptions."Auto-Post Indirect Cost" then
                exit;
            if ValueEntry."Source Type" <> ValueEntry."Source Type"::Customer then
                exit;
            // if (not GlobalSBCTATradeBudgetOptions."Burden Purchase Receipts") or (ValueEntry."Invoiced Quantity" <> 0) then begin
            if not (ValueEntry."Document Type" in ["Item Ledger Document Type"::"Sales Invoice", "Item Ledger Document Type"::"Sales Credit Memo"]) then // If we are to capture any shipping related costs, then we would need to add a condition here.
                exit;
            // end;
            // if GlobalSBCTATradeBudgetOptions."Burden Purchase Receipts" and (ValueEntry."Invoiced Quantity" = 0) then begin
            if (ValueEntry."Document Type" = "Item Ledger Document Type"::"Sales Credit Memo") and not GlobalSBCTATradeBudgetOptions."Auto-Post Sales Credits" then // We can add a similar exit condition here for shipment costs.
                exit;
            // end;
            SetSellToCustomerValues(ValueEntry); // If we change the value entry here, we will add it to the buffer.
        end;

        // if not GlobalSBCTATradeBudgetOptions."Use Dimension Matching" then begin
        //     ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
        //     ItemLedgerEntry.SetLoadFields("Item Category Code");
        //     if not ItemLedgerEntry.FindFirst() then
        //         exit;
        //     ItemCategory.SetRange("Code", ItemLedgerEntry."Item Category Code");
        //     ItemCategory.SetLoadFields("Code");
        //     if not ItemCategory.FindFirst() then
        //         exit;
        // end;
        ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
        ItemLedgerEntry.SetLoadFields("Item Category Code", "Unit of Measure Code", "Entry Type", "Document Type");
        ItemLedgerEntry.FindFirst(); //This is being retrieved because it is needed for the unit of measure check.
        if ItemLedgerEntry."Unit of Measure Code" = '' then // This was added to exclude 945 true up entries.
            exit;

        GlobalSBCTATradeBudget.Reset();
        OnBeforeSetBudgetDate(GlobalUseDocumentDate);
        if not GlobalUseDocumentDate then
            BudgetDate := ValueEntry."Posting Date"
        else
            BudgetDate := ValueEntry."Document Date";

        GlobalSBCTATradeBudget.SetFilter("Start Date", '<=%1', BudgetDate);
        GlobalSBCTATradeBudget.SetFilter("End Date", '>=%1', BudgetDate);
        GlobalSBCTATradeBudget.SetRange("Group Type", "SBCTA Budget Group Type"::Item);
        GlobalSBCTATradeBudget.SetRange(Enabled, true);
        // Search For Specific controls here.
        GlobalItemCategoryMatchingEnabled := true; // This can be set to false if a granular budget is retrieved.
        GetGranularBudget(ValueEntry, ItemLedgerEntry);
        if GlobalItemCategoryMatchingEnabled then begin
            if GlobalSBCTATradeBudgetOptions."Use Dimension Matching" then
                GlobalSBCTATradeBudget.SetRange("Shortcut Dimension 1 Code", ValueEntry."Global Dimension 1 Code")
            else
                GlobalSBCTATradeBudget.SetRange("Group Code", ItemLedgerEntry."Item Category Code");
        end;
        if GlobalSBCTATradeBudget.IsEmpty() then
            exit;

        GlobalSBCTATradeBudget.FindFirst();
        ItemCategoryGroupCode := GlobalSBCTATradeBudget."Group Code";
        if ItemCategoryGroupCode = '' then
            ItemCategoryGroupCode := ItemLedgerEntry."Item Category Code";

        Activate := SBCTAIndirectPostingSetup.GetItemSetup(ItemCategoryGroupCode, ValueEntry."Item No.", SBCTAIndirectPostingSetup, ValueEntry."Source Posting Group");
        if not Activate then
            exit;

        if GlobalRateCodeFilterText <> '' then
            SBCTAIndirectPostingSetup.SetFilter("Trade Budget Rate Code", GlobalRateCodeFilterText);
        Activate := not SBCTAIndirectPostingSetup.IsEmpty();
        if not Activate then
            exit;

        Location.SetRange(Code, ValueEntry."Location Code");
        Location.SetRange("SBC Enable Indirect Cost", true);
        GlobalLocationAllowsIndirectCostTracking := not Location.IsEmpty();

        if GlobalRunFromBatch then
            exit;
        if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
            exit;

        PopulateValueEntryBuffer(ValueEntry, SBCTAIndirectPostingSetup, GlobalSBCTATradeBudget); // We don't need to fill the buffer if we aren't modifying the value entry.
    end;

    local procedure PopulateValueEntryBuffer(var ValueEntry: Record "Value Entry"; var SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup"; SBCTATradeBudget: Record "SBCTA Trade Budget") Populated: Boolean
    var
        TempValueEntryCount: Integer;
    begin
        GlobalTempValueEntry := ValueEntry;
        TempValueEntryCount := GlobalTempValueEntry.Count();
        GlobalTradeBudgetGUIDDictionary.Add(TempValueEntryCount + 1, SBCTATradeBudget.SystemId);  // This is being done so that the correct budget record and setup record are matched.
        GlobalTradeBudgetSetupFilterDictionary.Add(TempValueEntryCount + 1, SBCTAIndirectPostingSetup.GetView());
        Populated := GlobalTempValueEntry.Insert();
    end;

    internal procedure CreateEntriesFromValueEntry(ValueEntry: Record "Value Entry")
    var
        ValueEntryNo: Integer;
        FilteredSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        ValueEntryNo := ValueEntry."Entry No.";
        FilteredSBCTAIndirectPostingSetup.GetItemSetup(GlobalSBCTATradeBudget."Group Code", ValueEntry."Item No.", FilteredSBCTAIndirectPostingSetup, ValueEntry."Source Posting Group");
        CreateEntriesFromValueEntry(ValueEntry, ValueEntryNo, FilteredSBCTAIndirectPostingSetup);
    end;

    internal procedure CreateEntriesFromValueEntry(ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer; var FilteredSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup")
    var
        ItemCategory: Record "Item Category";
        ItemLedgerEntry: Record "Item Ledger Entry";
    // FilteredSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        if not GlobalSBCTATradeBudgetOptions."Use Dimension Matching" then begin
            ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
            ItemLedgerEntry.SetLoadFields("Item Category Code");
            if not ItemLedgerEntry.FindFirst() then
                exit;
            ItemCategory.SetRange("Code", ItemLedgerEntry."Item Category Code");
            ItemCategory.SetLoadFields("Code");
            if not ItemCategory.FindFirst() then
                exit;
        end;
        // FilteredSBCTAIndirectPostingSetup.GetItemSetup(GlobalSBCTATradeBudget."Group Code", ValueEntry."Item No.", FilteredSBCTAIndirectPostingSetup);
        if GlobalRateCodeFilterText <> '' then
            FilteredSBCTAIndirectPostingSetup.SetFilter("Trade Budget Rate Code", GlobalRateCodeFilterText);
        FilteredSBCTAIndirectPostingSetup.FindSet();

        repeat
            CreateEntryFromValueEntry(ValueEntry, FilteredSBCTAIndirectPostingSetup, ValueEntryNo);
        until FilteredSBCTAIndirectPostingSetup.Next() = 0;
    end;

    // local procedure CreateEntryFromValueEntry(ValueEntry: Record "Value Entry"; SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup")
    // var
    //     ValueEntryNo: Integer;
    // begin
    //     CreateEntryFromValueEntry(ValueEntry, SBCTAIndirectPostingSetup, ValueEntryNo);
    // end;

    local procedure CreateEntryFromValueEntry(ValueEntry: Record "Value Entry"; SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup"; var ValueEntryNo: Integer)
    var
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        // ItemLedgerEntry: Record "Item Ledger Entry";
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
        SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes";
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
        SBCTATradeLedgerMgmt: Codeunit "SBCTA Trade Ledger Mgmt.";
        UnitofMeasureManagement: Codeunit "Unit of Measure Management";
        EntryExists: Boolean;
        ReprocessEntry: Boolean;
        CostAmount: Decimal;
        ValueAmount: Decimal;
        TradeBudgetAmount: Decimal;
        ValuedQuantity: Decimal;
        // ValuedQuantity: Decimal;
        BudgetQtyPerUOM: Decimal;
        ConversionFactor: Decimal;
    begin
        SBCTATradeBudgetRateCodes.SetRange("Trade Budget Rate Code", SBCTAIndirectPostingSetup."Trade Budget Rate Code");
        SBCTATradeBudgetRateCodes.SetRange(Blocked, false);
        if SBCTATradeBudgetRateCodes.IsEmpty() then
            exit;
        SBCTATradeBudgetRateCodes.FindFirst();

        SBCTATradeBudgetRates.SetRange("Trade Budget Code", GlobalSBCTATradeBudget."Trade Budget Code");
        SBCTATradeBudgetRates.SetRange("Trade Budget Rate Code", SBCTAIndirectPostingSetup."Trade Budget Rate Code");
        SBCTATradeBudgetRates.SetFilter("Trade Budget Rate", '<>%1', 0);
        // if not GlobalSBCTATradeBudget."Use Item Category Matching" then // If we aren't matching by item category, then we are assuming that a specific rate has to exist.
        //     SBCTATradeBudgetRates.SetRange("Item No.", ValueEntry."Item No.")
        // else
        //     SBCTATradeBudgetRates.SetFilter("Item No.", '%1', ''); // Use the generic condition.
        // if SBCTATradeBudgetRates.IsEmpty() then
        // exit;
        SBCTATradeBudgetRates.SetRange("Item No.", ValueEntry."Item No.");
        if SBCTATradeBudgetRates.IsEmpty() then
            SBCTATradeBudgetRates.SetFilter("Item No.", '%1', '');
        if SBCTATradeBudgetRates.IsEmpty() then
            exit;

        SBCTATradeBudgetRates.FindFirst();

        SBCTAIndirectCOGsLedger.SetCogsEntryFiltersForVE(ValueEntry."Entry No.", SBCTATradeBudgetRates."Trade Budget Code", SBCTATradeBudgetRates."Trade Budget Rate Code", SBCTAIndirectCOGsLedger);
        EntryExists := not SBCTAIndirectCOGsLedger.IsEmpty();
        if EntryExists and not GlobalRecreateValueEntry then
            exit;

        Item.SetRange("No.", ValueEntry."Item No.");
        Item.SetLoadFields("No.", "Standard Cost", "Base Unit of Measure", "Purch. Unit of Measure");
        if Item.FindFirst() then
            ValueAmount := Item."Standard Cost"
        else
            ValueAmount := ValueEntry."Cost per Unit";

        ValuedQuantity := ValueEntry."Valued Quantity";
        CostAmount := -1 * ValuedQuantity * ValueAmount;
        ConversionFactor := 1; // We do not need to convert the quantity and can leave it in the ledger unit.
        TradeBudgetAmount := SBCTATradeBudgetRates.GetAmount(ValueAmount, -1 * ValuedQuantity, ConversionFactor, GlobalSBCTATradeBudgetOptions."Calculation Basis");
        if TradeBudgetAmount = 0 then
            exit;

        SBCTAIndirectCOGsLedger.SetGroupCode("SBCTA Budget Group Type"::Item, GlobalSBCTATradeBudget."Group Code");
        SBCTAIndirectCOGsLedger.RecreateEntry(EntryExists);
        if not SBCTAIndirectCOGsLedger.CreateLedgerEntryFromValueEntry(SBCTATradeBudgetRates, ValueEntry, TradeBudgetAmount, CostAmount, SBCTATradeBudgetRateCodes) then
            exit;
        if not GlobalSBCTATradeBudgetOptions."Burden Purchase Receipts" then
            exit;

        if not GlobalLocationAllowsIndirectCostTracking then
            exit;

        if GlobalCheckForICCogsEntry then
            if SBCTATradeLedgerMgmt.GetIndirectCostValueEntry(ValueEntry."Item Ledger Entry No.", SBCTATradeBudgetRateCodes.Description, ValueEntry."Document Type").IsEmpty() then // This checks for an existing indirect cogs ledger entry for Invoice Types. If the indirect cogs entry does not exist for the receipt, the code below is not entered.
                exit;
        InsertIndirectCogsValueEntry(ValueEntry, ValueEntryNo, TradeBudgetAmount, SBCTATradeBudgetRateCodes, SBCTATradeBudgetRates."Trade Budget Rate", SBCTAIndirectPostingSetup."Sales Posting Account", SBCTAIndirectPostingSetup."Balance Account");
    end;

    local procedure InsertIndirectCogsValueEntry(var ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer; var TradeBudgetAmount: Decimal; SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes"; IndirectTradeRate: Decimal; IndirectSalesAccount: Code[20]; IndirectBalanceAccount: Code[20])
    var
        IndirectCogsItemLedgerEntry: Record "Item Ledger Entry";
        IndirectCogsValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        SBCTALedgerEntryHandler: Codeunit "SBCTA Ledger Entry Handler";
    begin
        IndirectCogsValueEntry := ValueEntry;
        if ValueEntryNo = 0 then
            ValueEntryNo := IndirectCogsValueEntry."Entry No.";
        SBCTALedgerEntryHandler.GetLastValueEntryNo(ValueEntryNo);
        ValueEntryNo := ValueEntryNo + 1;
        IndirectCogsValueEntry."Entry No." := ValueEntryNo;

        IndirectCogsValueEntry."Item Charge No." := '';
        // case IndirectCogsValueEntry."Item Ledger Entry Type" of
        //     "Item Ledger Entry Type"::Sale:
        //         begin
        //             // if IndirectCogsValueEntry."Expected Cost" then
        //             //     IndirectCogsValueEntry."Expected Cost" := false;
        //             IndirectCogsValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost"
        //         end;
        //     else
        //         IndirectCogsValueEntry."Entry Type" := ValueEntry."Entry Type"::"Indirect Cost";
        // end;
        // IndirectCogsValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost"; //2024-11-07 Testing Error
        IndirectCogsValueEntry."Entry Type" := ValueEntry."Entry Type"::"Indirect Cost";
        case IndirectCogsValueEntry."Document Type" of
            "Item Ledger Document Type"::"Sales Invoice":
                IndirectCogsValueEntry."Document Type" := "Item Ledger Document Type"::"Sales Shipment";
            "Item Ledger Document Type"::"Sales Credit Memo":
                IndirectCogsValueEntry."Document Type" := "Item Ledger Document Type"::"Sales Return Receipt";
        end;
        // case IndirectCogsValueEntry."Item Ledger Entry Type" of
        //     "Item Ledger Entry Type"::"Positive Adjmt.", "Item Ledger Entry Type"::"Negative Adjmt.":
        //         begin
        //             IndirectCogsValueEntry."Item Ledger Entry Type" := "Item Ledger Entry Type"::Purchase;
        //             IndirectCogsValueEntry."Item Ledger Entry Quantity" := 0;
        //         end;
        // end;
        IndirectCogsValueEntry.Description := CopyStr(SBCTATradeBudgetRateCodes.Description, 1, MaxStrLen(IndirectCogsValueEntry.Description)); //TODO(Set 100 Character limit here.)
        IndirectCogsValueEntry."Cost per Unit" := 0;
        IndirectCogsValueEntry."Cost per Unit (ACY)" := 0;
        IndirectCogsValueEntry."Cost Posted to G/L" := 0;
        IndirectCogsValueEntry."Cost Posted to G/L (ACY)" := 0;
        IndirectCogsValueEntry."Invoiced Quantity" := 0;
        IndirectCogsValueEntry."Sales Amount (Actual)" := 0;
        IndirectCogsValueEntry."Sales Amount (Expected)" := 0;
        IndirectCogsValueEntry."Purchase Amount (Actual)" := 0;
        IndirectCogsValueEntry."Purchase Amount (Expected)" := 0;
        IndirectCogsValueEntry."Discount Amount" := 0;
        IndirectCogsValueEntry."Cost Amount (Actual)" := TradeBudgetAmount; //Check
        IndirectCogsValueEntry."Cost Amount (Expected)" := 0;
        IndirectCogsValueEntry."Cost Amount (Expected) (ACY)" := 0;
        IndirectCogsValueEntry."Expected Cost Posted to G/L" := 0;
        IndirectCogsValueEntry."Exp. Cost Posted to G/L (ACY)" := 0;

        IndirectCogsItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        SBCTALedgerEntryHandler.Bind();
        SBCTALedgerEntryHandler.SetIndirectRate(IndirectTradeRate);
        SBCTALedgerEntryHandler.SetPostingAccounts(IndirectSalesAccount, IndirectBalanceAccount);
        SBCTALedgerEntryHandler.SetIndirectDescription(SBCTATradeBudgetRateCodes.Description);
        ItemJnlPostLine.SetCalledFromAdjustment(false, true);
        ItemJnlPostLine.InsertValueEntry(IndirectCogsValueEntry, IndirectCogsItemLedgerEntry, false);
    end;

    local procedure GetGranularBudget(ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        GranularSBCTATradeBudget: Record "SBCTA Trade Budget";
        ItemLedgerMatch: Boolean;
        EntriesExhausted: Boolean;
    begin
        GranularSBCTATradeBudget.CopyFilters(GlobalSBCTATradeBudget);
        GranularSBCTATradeBudget.SetRange("Location Code", ValueEntry."Location Code");
        GranularSBCTATradeBudget.SetRange("Unit of Measure Code", ItemLedgerEntry."Unit of Measure Code"); // This should likely be a filter, too. Sometimes CS is used. Sometimes EA is used. Sometimes '' is used. If no unit of measure is found, Item category matching is the fallback.
        if GranularSBCTATradeBudget.IsEmpty() then
            exit;

        GranularSBCTATradeBudget.FilterGroup(-1);
        GranularSBCTATradeBudget.SetFilter("Item Ledger Entry Type", '<>%1', '');
        GranularSBCTATradeBudget.SetFilter("Item Ledger Document Type", '<>%1', '');
        if GranularSBCTATradeBudget.IsEmpty() then begin //If no advanced filtering is set
            GranularSBCTATradeBudget.SetRange("Item Ledger Entry Type");
            GranularSBCTATradeBudget.SetRange("Item Ledger Document Type");
            GlobalSBCTATradeBudget.CopyFilters(GranularSBCTATradeBudget);
            GlobalItemCategoryMatchingEnabled := not GranularSBCTATradeBudget.IsEmpty();
            exit;
        end
        else // If advanced filtering is set, find the first budget that matches the current item ledger entry.
            if GranularSBCTATradeBudget.FindSet() then
                while not EntriesExhausted do begin
                    ItemLedgerEntry.SetRecFilter();
                    if GranularSBCTATradeBudget."Item Ledger Entry Type" <> '' then
                        ItemLedgerEntry.SetFilter("Entry Type", GranularSBCTATradeBudget."Item Ledger Entry Type");
                    if GranularSBCTATradeBudget."Item Ledger Document Type" <> '' then
                        ItemLedgerEntry.SetFilter("Document Type", GranularSBCTATradeBudget."Item Ledger Document Type");
                    ItemLedgerMatch := not ItemLedgerEntry.IsEmpty();
                    if not ItemLedgerMatch then
                        EntriesExhausted := (GranularSBCTATradeBudget.Next() = 0) or (ItemLedgerMatch)
                    else
                        EntriesExhausted := true;
                end;
        // until  ItemLedgerMatch or (GranularSBCTATradeBudget.Next() = 0);
        GranularSBCTATradeBudget.SetRange("Item Ledger Entry Type");
        GranularSBCTATradeBudget.SetRange("Item Ledger Document Type");
        GranularSBCTATradeBudget.FilterGroup(0);
        if ItemLedgerMatch then begin // If a matching item ledger is found, then set the explicit filters on the budget.
            if GranularSBCTATradeBudget."Item Ledger Entry Type" <> '' then
                GranularSBCTATradeBudget.SetRange("Item Ledger Entry Type", GranularSBCTATradeBudget."Item Ledger Entry Type");
            if GranularSBCTATradeBudget."Item Ledger Document Type" <> '' then
                GranularSBCTATradeBudget.SetRange("Item Ledger Document Type", GranularSBCTATradeBudget."Item Ledger Document Type");
            GlobalSBCTATradeBudget.CopyFilters(GranularSBCTATradeBudget);
        end else begin
            // Check for final condition: Explicit Location and unit only filtering

            GranularSBCTATradeBudget.SetFilter("Item Ledger Entry Type", '%1', '');
            GranularSBCTATradeBudget.SetFilter("Item Ledger Document Type", '%1', '');
            GlobalSBCTATradeBudget.CopyFilters(GranularSBCTATradeBudget);
            if GranularSBCTATradeBudget.IsEmpty() then
                exit;
        end;
        GranularSBCTATradeBudget.SetRange("Use Item Category Matching", true);
        GlobalItemCategoryMatchingEnabled := not GranularSBCTATradeBudget.IsEmpty();
    end;

    #endregion COGS


    #region InstanceMethods
    internal procedure IsBound(): Boolean
    begin
        exit(GlobalBound);
    end;

    internal procedure Unbind()
    begin
        Unbind(false);
    end;

    internal procedure Unbind(Force: Boolean)
    begin
        if not Force then
            if not IsBound() then
                exit;
        GlobalBound := not UnbindSubscription(GlobalCUInstance);
        if not GlobalBound then
            if not Force then
                exit;
        if not Force then
            exit;
        ClearGlobals();
    end;

    internal procedure ClearGlobals()
    begin
        Clear(GlobalBound);
        Clear(GlobalRunFromBatch);
        Clear(GlobalRecreateValueEntry);
        Clear(GlobalUseDocumentDate);
        Clear(GlobalSBCTATradeBudget);
        Clear(GlobalSBCTATradeBudgetOptions);
        if not GlobalTempValueEntry.IsEmpty() then
            GlobalTempValueEntry.DeleteAll();
        Clear(GlobalTempValueEntry);
        Clear(GlobalRateCodeFilterText);
        Clear(GlobalLastEntryNo);
        Clear(GlobalCheckForICCogsEntry);
        Clear(GlobalLocationAllowsIndirectCostTracking);

        Clear(GlobalTradeBudgetGUIDDictionary);
        Clear(GlobalTradeBudgetSetupFilterDictionary);
        Clear(GlobalSBCTATradeBudgetSetup);
    end;


    internal procedure Bind()
    begin
        if IsBound() then
            exit;
        GlobalBound := BindSubscription(GlobalCUInstance);
    end;

    internal procedure Bind(force: Boolean)
    begin
        Unbind(force);
        Bind();
    end;



    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnAfterValidateEvent, "Context Record ID", false, false)]
    local procedure OnAfterValidateContextRecordId(CurrFieldNo: Integer; var Rec: Record "Error Message"; var xRec: Record "Error Message")
    begin
        if (xRec."Context Table Number" = Rec."Context Table Number") and not (Rec."Additional Information" in ['Preview mode.', 'Batch processing of Sales Header records.', 'Post document lines.']) then
            Unbind(true); // If this is reached, the transaction is over and the regular unbound pathway could not be reached.


    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetBudgetDate(var GlobalUseDocumentDate: Boolean)
    begin
    end;

    #endregion InstanceMethods
    internal procedure SetRunFromBatch(RunFromBatch: Boolean)
    begin
        GlobalRunFromBatch := RunFromBatch;
    end;

    internal procedure SetGLobalUseDocumentDate(UseDocumentDate: Boolean)
    begin
        GlobalUseDocumentDate := UseDocumentDate;
    end;


    internal procedure SetRecreateValueEntry(RecreateValueEntry: Boolean)
    begin
        GlobalRecreateValueEntry := RecreateValueEntry;
    end;

    internal procedure SetRateCodeFilter(RateCodeFilterText: Text)
    begin
        GlobalRateCodeFilterText := RateCodeFilterText;
    end;

    var
        GlobalSBCTATradeBudget: Record "SBCTA Trade Budget";

        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalTempValueEntry: Record "Value Entry" temporary;


        GlobalCUInstance: Codeunit "SBCTA Item Events";
        GlobalBound: Boolean;
        GlobalSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        GlobalTradeBudgetGUIDDictionary: Dictionary of [Integer, Guid];
        GlobalTradeBudgetSetupFilterDictionary: Dictionary of [Integer, Text];
        GlobalItemCategoryMatchingEnabled: Boolean;
        GlobalCheckForICCogsEntry: Boolean;
        GlobalLocationAllowsIndirectCostTracking: Boolean;
        GlobalRecreateValueEntry: Boolean;
        GlobalRunFromBatch: Boolean;
        GlobalLastEntryNo: Integer;
        GlobalRateCodeFilterText: Text;
        GlobalUseDocumentDate: Boolean;
}