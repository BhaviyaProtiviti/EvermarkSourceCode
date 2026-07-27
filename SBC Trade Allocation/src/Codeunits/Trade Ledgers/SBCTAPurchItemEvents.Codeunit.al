/// <summary>
/// Codeunit SBCTA Trade Ledger Events (ID 50201).
/// </summary>
codeunit 50208 "SBCTA Purch Item Events"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    // #region AR
    // #region AREventSubscriber

    /// <summary>
    /// This event will never be called in a Purchase Receipt Only Posting.
    /// </summary>
    /// <param name="GenJnlLine">Record "Gen. Journal Line".</param>
    /// <param name="VendorPostingGroup">Record "Vendor Posting Group".</param>
    /// <param name="PayablesAccount">VAR Code[20].</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostVendOnAfterAssignPayablesAccount, '', false, false)]
    local procedure OnPostVendOnAfterAssignPayablesAccount(GenJnlLine: Record "Gen. Journal Line"; VendorPostingGroup: Record "Vendor Posting Group"; var PayablesAccount: Code[20])

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


    local procedure SetVendorValues(var ValueEntry: Record "Value Entry") //Unique
    var
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryDocumentType: Enum "Gen. Journal Document Type";
    begin
        if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
            exit;
        VendorLedgerEntry.SetRange("Vendor No.", ValueEntry."Source No.");
        VendorLedgerEntry.SetRange("Document No.", ValueEntry."Document No.");
        // if ValueEntry."Document Type" = ValueEntry."Document Type"::"Purchase Invoice" then
        //     VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice)
        // else
        //     VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
        case
            ValueEntry."Document Type" of
            "Item Ledger Document Type"::"Purchase Invoice":
                VendorLedgerEntryDocumentType := VendorLedgerEntryDocumentType::Invoice;
            "Item Ledger Document Type"::"Purchase Receipt":
                ;
            "Item Ledger Document Type"::"Purchase Return Shipment":
                ;
            "Item Ledger Document Type"::"Purchase Credit Memo":
                VendorLedgerEntryDocumentType := VendorLedgerEntryDocumentType::"Credit Memo";
        end;
        VendorLedgerEntry.SetLoadFields("Buy-from Vendor No.");
        if VendorLedgerEntry.IsEmpty() then
            exit;
        VendorLedgerEntry.FindFirst();
        Vendor.SetRange("No.", VendorLedgerEntry."Buy-from Vendor No.");
        Vendor.SetLoadFields("No.", "Vendor Posting Group");
        if Vendor.IsEmpty() then
            exit;
        Vendor.FindFirst();
        ValueEntry."Source No." := Vendor."No.";
        ValueEntry."Source Posting Group" := Vendor."Vendor Posting Group";
    end;

    // #endregion AREventSubscriber

    // #endregion AR
    #region COGS
    #region COGSEventSubscriber

    /// <summary>
    /// This event allows us to record additional value entries that burden the source value entry as added cost.
    /// </summary>
    /// <param name="ValueEntry">VAR Record "Value Entry".</param>
    /// <param name="ItemJournalLine">Record "Item Journal Line".</param>
    /// <param name="ItemLedgerEntry">VAR Record "Item Ledger Entry".</param>
    /// <param name="ValueEntryNo">VAR Integer.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterInsertValueEntry, '', false, false)]
    local procedure OnAfterInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer)
    begin
        if ValueEntryNo <= 1 then
            exit;
        Unbind();
        if not GlobalSBCTATradeBudgetOptions."Skip Inbound IC Check" then
            GlobalCheckForICCogsEntry := (ItemJournalLine."Document Type" in ["Item Ledger Document Type"::"Purchase Invoice", "Item Ledger Document Type"::"Sales Invoice", "Item Ledger Document Type"::"Sales Credit Memo", "Item Ledger Document Type"::"Purchase Credit Memo", "Item Ledger Document Type"::" "]);
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
    // begint
    //     Activate := ActivateCOGsPosting(ValueEntry, InvtPostingBuffer);
    // end;

    internal procedure ActivateCOGsPosting(ValueEntry: Record "Value Entry") Activate: Boolean //Unique
    var
        ItemCategory: Record "Item Category";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
        ItemCategoryGroupCode: Code[20];
        Reversal: Boolean;
    begin
        if ValueEntry."Applies-to Entry" <> 0 then //Adjustments
            exit;
        // if not (InvtPostingBuffer."Account Type" in [InvtPostingBuffer."Account Type"::COGS,InvtPostingBuffer."Account Type"::"COGS (Interim)"]) then
        //     exit;
        // if (GlobalLastEntryNo <> 0) or ((GlobalLastEntryNo = 0) and (GlobalSBCTATradeBudgetOptions.SystemCreatedAt <> 0DT)) then // The second conditon ensures that the options are refreshed on each run if the auto post settings are off.
        //     ClearGlobals(); //If this code is entered, we should be recovering from an error.
        if (GlobalLastEntryNo <> 0) then
            ClearGlobals(); //If this code is entered, we should be recovering from an error.
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        if not GlobalRunFromBatch then begin
            if not GlobalSBCTATradeBudgetOptions."Auto-Post Indirect Cost" then
                exit;
            if not (ValueEntry."Source Type" in [ValueEntry."Source Type"::Vendor, ValueEntry."Source Type"::" "]) then
                exit;
            if (not GlobalSBCTATradeBudgetOptions."Burden Purchase Receipts") or ((ValueEntry."Invoiced Quantity" <> 0) and (ValueEntry."Document Type" <> "Item Ledger Document Type"::"Purchase Receipt")) then begin // This code only runs in situations where receipts and invoices are posted together.
                // if (ValueEntry."Cost Amount (Actual)" <> 0) and (ValueEntry."Cost Amount (Expected)" <> 0) then // This is an invoice clearing expected cost. When a receipt and invoice are posted together, only actual costs are recoginized. When a receipt is posted by itself, only expected, when the invoice is posted by itself, it will reverse expected.
                //     exit;
                // if ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)" = 0 then // This exit condition is true only during separate Purchase Invoice posting. If a Post Receive and Invoice occurs, this code makes sure that only the receiving portion is recorded.
                //     exit;
                if (ValueEntry."Cost Amount (Expected)" < 0) and (ValueEntry."Document Type" = "Item Ledger Document Type"::"Purchase Invoice") then
                    exit;

                if not (ValueEntry."Document Type" in ["Item Ledger Document Type"::"Purchase Invoice", "Item Ledger Document Type"::"Purchase Credit Memo", "Item Ledger Document Type"::" ", "Item Ledger Document Type"::"Transfer Receipt"]) then // The blank document type allows positive and negative adjustments from item journals. // Transfers Condition can be added here. Should also check location. we could also add an additional unit check here.
                    exit;
                if (ValueEntry."Document Type" = "Item Ledger Document Type"::"Transfer Receipt") and (ValueEntry.Type <> "Capacity Type Journal"::"Work Center") then // Add A check here that will enable or disable this type of indirect cost tracking. 
                    exit;
                // if (ValueEntry."Document Type" = "Item Ledger Document Type"::"Purchase Credit Memo") and not GlobalSBCTATradeBudgetOptions."Auto-Post Sales Credits" then // We can add a similar exit condition here for shipment costs. 
                //     exit;
            end;
            if GlobalSBCTATradeBudgetOptions."Burden Purchase Receipts" and (ValueEntry."Invoiced Quantity" = 0) then begin // Postive and Negative Adjustments will always bypass this check because they have a non-zero invoiced quantity.
                if not (ValueEntry."Document Type" in ["Item Ledger Document Type"::" ", "Item Ledger Document Type"::"Purchase Receipt", "Item Ledger Document Type"::"Purchase Return Shipment"]) then // 03/01/24 10:43:19-8 - Blank allows item reclass journal documents.
                    exit;
                // if (ValueEntry."Document Type" = "Item Ledger Document Type"::"Purchase Return Shipment") and not GlobalSBCTATradeBudgetOptions."Auto-Post Sales Credits" then // We can add a similar exit condition here for shipment costs. 03/01/24 10:43:19-8 This isn't needed. We always include reversals.
                // exit;
            end;
            SetVendorValues(ValueEntry); // If we change the value entry here, we will add it to the buffer.
        end;
        case true of
            (ValueEntry."Document Type" = "Item Ledger Document Type"::"Purchase Receipt") and ((ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)") = 0): // Step one and three of PR Reversal
                exit;
            (ValueEntry."Document Type" = "Item Ledger Document Type"::"Purchase Receipt") and ((ValueEntry."Cost Amount (Actual)" = ValueEntry."Cost Amount (Expected)")) and (ValueEntry."Cost Amount (Actual)" < 0): // This is the entry we want to keep
                Reversal := true;
        end;

        ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
        ItemLedgerEntry.SetLoadFields("Item Category Code", "Unit of Measure Code", "Entry Type", "Document Type");
        ItemLedgerEntry.FindFirst(); //This is being retrieved because it is needed for the unit of measure check.
        if ItemLedgerEntry."Unit of Measure Code" = '' then
            exit;

        GlobalSBCTATradeBudget.Reset();
        GlobalSBCTATradeBudget.SetFilter("Start Date", '<=%1', ValueEntry."Posting Date"); // If we do add conditions to limit the type of either source codes or cost types allowed, we can also consider doing it here. We could control the rates and codes applied by adding a location parameter, and a transaction type parameter.
        GlobalSBCTATradeBudget.SetFilter("End Date", '>=%1', ValueEntry."Posting Date");
        GlobalSBCTATradeBudget.SetRange("Group Type", "SBCTA Budget Group Type"::Item);
        GlobalSBCTATradeBudget.SetRange(Enabled, true);
        // Search For Specific controls here.
        GlobalItemCategoryMatchingEnabled := true; // This can be set to false if a granular budget is retrieved.
        GetGranularBudget(ValueEntry, ItemLedgerEntry);
        if GlobalItemCategoryMatchingEnabled then begin
            // if not GlobalSBCTATradeBudgetOptions."Use Dimension Matching" then begin
            //     ItemCategory.SetRange("Code", ItemLedgerEntry."Item Category Code");
            //     ItemCategory.SetLoadFields("Code");
            //     if not ItemCategory.FindFirst() then
            //         exit;
            // end;
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
        Activate := SBCTAIndirectPostingSetup.GetItemSetup(ItemCategoryGroupCode, ValueEntry."Item No.", SBCTAIndirectPostingSetup, ''); // IF we need to change the posting setup per location or cost type, we can do that here. Add parameters here for location and the indirect cost tracking type.  
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
        if ValueEntry."Source Type" = ValueEntry."Source Type"::" " then //Item Journals like reclass and adjustments only operate on a single Item Ledger Entry per Journal Line. Because of this, we don't need to worry about the Value Entry Buffer.
            exit;
        if Reversal then // During reversals, we don't need to fill the buffer.
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
        FilteredSBCTAIndirectPostingSetup.GetItemSetup(GlobalSBCTATradeBudget."Group Code", ValueEntry."Item No.", FilteredSBCTAIndirectPostingSetup, '');
        CreateEntriesFromValueEntry(ValueEntry, ValueEntryNo, FilteredSBCTAIndirectPostingSetup);
    end;

    internal procedure CreateEntriesFromValueEntry(ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer; var FilteredSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup")
    var
        ItemCategory: Record "Item Category";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SBCTALedgerEntryHandler: Codeunit "SBCTA Ledger Entry Handler";
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
        if not GlobalSBCTATradeBudgetOptions."Skip Inbound IC Check" then
            if not GlobalCheckForICCogsEntry and ((ValueEntry."Item Ledger Entry Type" = "Item Ledger Entry Type"::"Negative Adjmt.") or ((ValueEntry."Source Code" = SBCTALedgerEntryHandler.GetReclassSourceCode()) and (ValueEntry."Valued Quantity" <= 0))) then // The Reclass Journal Check here exists so that Indirect Costs can be added when they do not exist on the original transaction. If they do exist on the original transaction, then this will allow them to be properly reversed out.
                GlobalCheckForICCogsEntry := true;
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
        ItemLedgerEntry: Record "Item Ledger Entry";
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
        CostAmount := ValuedQuantity * ValueAmount;
        ConversionFactor := 1; // We do not need to convert the quantity and can leave it in the ledger unit.
        TradeBudgetAmount := SBCTATradeBudgetRates.GetAmount(ValueAmount, ValuedQuantity, ConversionFactor, GlobalSBCTATradeBudgetOptions."Calculation Basis");
        if TradeBudgetAmount = 0 then
            exit;

        SBCTAIndirectCOGsLedger.SetGroupCode("SBCTA Budget Group Type"::Item, GlobalSBCTATradeBudget."Group Code");
        SBCTAIndirectCOGsLedger.RecreateEntry(EntryExists);
        case ValueEntry."Document Type" of
            "Item Ledger Document Type"::"Purchase Invoice":
                Begin //Swap to Purchase Receipt Document Number for the resulting sub-ledger entries.
                    ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
                    ItemLedgerEntry.SetRange("Document Type", "Item Ledger Document Type"::"Purchase Receipt");
                    ItemLedgerEntry.SetLoadFields("Document No.");
                    if ItemLedgerEntry.FindFirst() then begin
                        ValueEntry."Document No." := ItemLedgerEntry."Document No.";
                        ValueEntry."Document Type" := "Item Ledger Document Type"::"Purchase Receipt"; // This is set so that when receipts and invoices are posted together, this shows that the receipt side of the transaction is where costs are recognized, not the invoicing side.
                    end;
                end;
            "Item Ledger Document Type"::"Purchase Credit Memo":
                begin
                    ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
                    ItemLedgerEntry.SetRange("Document Type", "Item Ledger Document Type"::"Purchase Return Shipment");
                    ItemLedgerEntry.SetLoadFields("Document No.");
                    if ItemLedgerEntry.FindFirst() then begin
                        ValueEntry."Document No." := ItemLedgerEntry."Document No.";
                        ValueEntry."Document Type" := "Item Ledger Document Type"::"Purchase Return Shipment";
                    end;
                end;
        end;
        if not SBCTAIndirectCOGsLedger.CreateLedgerEntryFromValueEntry(SBCTATradeBudgetRates, ValueEntry, TradeBudgetAmount, CostAmount, SBCTATradeBudgetRateCodes) then
            exit;
        if not GlobalSBCTATradeBudgetOptions."Burden Purchase Receipts" then
            exit;
        if not GlobalLocationAllowsIndirectCostTracking then
            exit;
        if GlobalCheckForICCogsEntry then
            if SBCTATradeLedgerMgmt.GetIndirectCostValueEntry(ValueEntry."Item Ledger Entry No.", SBCTATradeBudgetRateCodes.Description, ValueEntry."Document Type").IsEmpty() then // This checks for an existing indirect cogs ledger entry for Invoice Types. If the indirect cogs entry does not exist for the receipt, the code below is not entered.
                exit;

        InsertIndirectCogsValueEntry(ValueEntry, ValueEntryNo, TradeBudgetAmount, SBCTATradeBudgetRateCodes, SBCTATradeBudgetRates."Trade Budget Rate", SBCTAIndirectPostingSetup."Posting Account", SBCTAIndirectPostingSetup."Balance Account");
    end;

    local procedure InsertIndirectCogsValueEntry(var ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer; var TradeBudgetAmount: Decimal; SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes"; IndirectTradeRate: Decimal; IndirectTradeAccount: Code[20]; IndirectBalanceAccount: Code[20])
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
        IndirectCogsValueEntry."Entry Type" := ValueEntry."Entry Type"::"Indirect Cost";
        case IndirectCogsValueEntry."Document Type" of
            "Item Ledger Document Type"::"Purchase Invoice":
                IndirectCogsValueEntry."Document Type" := "Item Ledger Document Type"::"Purchase Receipt";
            "Item Ledger Document Type"::"Purchase Credit Memo":
                IndirectCogsValueEntry."Document Type" := "Item Ledger Document Type"::"Purchase Return Shipment";
        end;
        case IndirectCogsValueEntry."Item Ledger Entry Type" of
            "Item Ledger Entry Type"::"Positive Adjmt.", "Item Ledger Entry Type"::"Negative Adjmt.":
                begin
                    IndirectCogsValueEntry."Item Ledger Entry Type" := "Item Ledger Entry Type"::Purchase;
                    IndirectCogsValueEntry."Item Ledger Entry Quantity" := 0;
                end;
            "Item Ledger Entry Type"::Transfer:
                IndirectCogsValueEntry."Item Ledger Entry Type" := "Item Ledger Entry Type"::Purchase;
            "Item Ledger Entry Type"::Output:
                begin
                    IndirectCogsValueEntry."Item Ledger Entry Type" := "Item Ledger Entry Type"::Purchase;
                    IndirectCogsValueEntry."Document Type" := "Item Ledger Document Type"::"Purchase Receipt";
                    IndirectCogsValueEntry."Expected Cost" := false;
                end;
        end;
        IndirectCogsValueEntry.Description := CopyStr(SBCTATradeBudgetRateCodes.Description, 1, MaxStrLen(IndirectCogsValueEntry.Description)); // Set 100 character limit here.
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
        IndirectCogsValueEntry."Cost Amount (Actual)" := -TradeBudgetAmount;
        IndirectCogsValueEntry."Cost Amount (Expected)" := 0;
        IndirectCogsValueEntry."Cost Amount (Expected) (ACY)" := 0;

        IndirectCogsItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        SBCTALedgerEntryHandler.Bind();
        SBCTALedgerEntryHandler.SetIndirectRate(IndirectTradeRate);
        SBCTALedgerEntryHandler.SetPostingAccounts(IndirectTradeAccount, IndirectBalanceAccount);
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

    // internal procedure GetLastValueEntryNo(var ValueEntryNo: Integer)
    // var
    //     EntryNoValueEntry: Record "Value Entry";
    // begin
    //     EntryNoValueEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
    //     if EntryNoValueEntry.FindLast() and (EntryNoValueEntry."Entry No." > ValueEntryNo) then
    //         ValueEntryNo := EntryNoValueEntry."Entry No.";
    // end;


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
        Clear(GlobalRecreateValueEntry);
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
    #endregion InstanceMethods
    internal procedure SetRunFromBatch(RunFromBatch: Boolean)
    begin
        GlobalRunFromBatch := RunFromBatch;
    end;

    internal procedure SetRateCodeFilter(RateCodeFilterText: Text)
    begin
        GlobalRateCodeFilterText := RateCodeFilterText;
    end;

    internal procedure SetRecreateValueEntry(RecreateValueEntry: Boolean)
    begin
        GlobalRecreateValueEntry := RecreateValueEntry;
    end;

    var
        GlobalSBCTATradeBudget: Record "SBCTA Trade Budget";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalTempValueEntry: Record "Value Entry" temporary;
        GlobalCUInstance: Codeunit "SBCTA Purch Item Events";
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


}