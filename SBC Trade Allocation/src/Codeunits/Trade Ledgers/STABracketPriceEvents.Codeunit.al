/// <summary>
/// Codeunit STA Bracket Price Events (ID 50205).
/// </summary>
codeunit 50205 "STA Bracket Price Events"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    #region "Event Subscriptions"
    /// <summary>
    /// Bracket pricing should only create a single entry per value entry.
    /// </summary>
    /// <param name="ValueEntry">VAR Record "Value Entry".</param>

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnPostInvtPostBufferOnAfterPostInvtPostBuf, '', false, false)]
    local procedure OnPostInvtPostBufferOnAfterPostInvtPostBuf(var ValueEntry: Record "Value Entry");
    begin
        if ValueEntry."Sales Amount (Actual)" = 0 then
            exit;
        WriteBracketPriceLedgerEntry(ValueEntry);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInsertGlobalGLEntry, '', false, false)]
    local procedure OnAfterInsertGlobalGLEntry(var GLEntry: Record "G/L Entry"; var TempGLEntryBuf: Record "G/L Entry"; var NextEntryNo: Integer; GenJnlLine: Record "Gen. Journal Line")
    var
        STABracketPriceLedger: Record "STA Bracket Price Ledger";
        StartCount: Integer;
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionBufferManagement: Codeunit "Dimension Buffer Management";
    // GeneralPostingSetup: Record "General Posting Setup";
    begin
        if TempGLEntryBuf."G/L Account No." <> GlobalBalanceAccount then // The global balance account should be the discount account in this case. This can also be set to pick up the discount account from the posting group used. Currently, We only care about balancing this for a specific discount account. If other posting setups use other accounts, we exclude them by only looking for the global balance account.
            exit;
        STABracketPriceLedger.SetRange("Document No.", GLEntry."Document No.");
        STABracketPriceLedger.SetRange("Shortcut Dimension 1 Code", GLEntry."Global Dimension 1 Code");
        STABracketPriceLedger.SetRange("Shortcut Dimension 2 Code", GLEntry."Global Dimension 2 Code");
        STABracketPriceLedger.SetFilter("G/L Entry No.", '%1', 0);
        if STABracketPriceLedger.IsEmpty() then
            exit;

        // Unbind();
        // Create Clearing Entry.
        StartCount := TempGLEntryBuf.Count();
        STABracketPriceLedger.FindSet();
        repeat
            // Balancing Entry
            TempGLEntryBuf."Entry No." := NextEntryNo;
            TempGLEntryBuf."G/L Account No." := GlobalBalanceAccount; // This should be the same account.
            TempGLEntryBuf.Amount := -1 * STABracketPriceLedger."Bracket Amount";
            if TempGLEntryBuf.Amount <= 0 then begin
                TempGLEntryBuf."Debit Amount" := 0;
                TempGLEntryBuf."Credit Amount" := Abs(STABracketPriceLedger."Bracket Amount");
            end
            else begin
                TempGLEntryBuf."Credit Amount" := 0;
                TempGLEntryBuf."Debit Amount" := Abs(STABracketPriceLedger."Bracket Amount");
            end; // If Credit  
            TempGLEntryBuf.Description := StrSubstNo('%1 - %2 - %3 - %4', GLEntry.Description, STABracketPriceLedger."Item No.", STABracketPriceLedger."Document Line No.", STABracketPriceLedger."Bracket Price Code");
            TempGLEntryBuf."Global Dimension 1 Code" := STABracketPriceLedger."Shortcut Dimension 1 Code";
            TempGLEntryBuf."Global Dimension 2 Code" := STABracketPriceLedger."Shortcut Dimension 2 Code";

            TempGLEntryBuf."Dimension Set ID" := STABracketPriceLedger."Dimension Set ID";
            TempGLEntryBuf.Insert();
            NextEntryNo += 1;
            // Posting Entry
            TempGLEntryBuf."Entry No." := NextEntryNo;
            TempGLEntryBuf."G/L Account No." := GlobalPostingAccount; // This should be the same account.
            TempGLEntryBuf.Amount := STABracketPriceLedger."Bracket Amount";
            if TempGLEntryBuf."Debit Amount" <> 0 then begin
                TempGLEntryBuf."Credit Amount" := TempGLEntryBuf."Debit Amount";
                TempGLEntryBuf."Debit Amount" := 0;
            end else begin
                TempGLEntryBuf."Debit Amount" := TempGLEntryBuf."Credit Amount";
                TempGLEntryBuf."Credit Amount" := 0;
            end;
            TempGLEntryBuf.Insert();
            NextEntryNo += 1;
            GlobalItemList.Remove(STABracketPriceLedger."Item No.");
        until STABracketPriceLedger.Next() = 0;
        // Reset the buffer position.
        TempGLEntryBuf.FindSet();
        if StartCount > 1 then
            TempGLEntryBuf.Next(StartCount - 1);

        STABracketPriceLedger.ModifyAll("G/L Entry No.", GLEntry."Entry No.");
        if GlobalItemList.Count() <> 0 then
            exit;
        Unbind(true);
    end;


    [EventSubscriber(ObjectType::Report, Report::"STA Create Bracket Ledger", PassValueEntryToHandler, '', false, false)]
    local procedure PassValueEntryToHandler(var ValueEntry: Record "Value Entry")
    begin
        WriteBracketPriceLedgerEntry(ValueEntry);
    end;


    [EventSubscriber(ObjectType::Report, Report::"STA Create Bracket Ledger", Finish, '', false, false)]
    local procedure Finish(ValueEntry: Record "Value Entry")
    begin
        Unbind(true);
    end;
    /// <summary>
    /// This event is subscribed to so that the data bound in the Single Instance CU is cleared after the Sales Document is posted.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="GenJnlPostLine">VAR Codeunit "Gen. Jnl.-Post Line".</param>
    /// <param name="SalesShptHdrNo">Code[20].</param>
    /// <param name="RetRcpHdrNo">Code[20].</param>
    /// <param name="SalesInvHdrNo">Code[20].</param>
    /// <param name="SalesCrMemoHdrNo">Code[20].</param>
    /// <param name="CommitIsSuppressed">Boolean.</param>
    /// <param name="InvtPickPutaway">Boolean.</param>
    /// <param name="CustLedgerEntry">VAR Record "Cust. Ledger Entry".</param>
    /// <param name="WhseShip">Boolean.</param>
    /// <param name="WhseReceiv">Boolean.</param>
    /// <param name="PreviewMode">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    begin
        Unbind(true);
    end;

    #endregion "Event Subscriptions"
    #region "Event Binding"

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
        case true of
            not force and not IsBound():
                exit;
            not force:
                GlobalBound := UnbindSubscription(GlobalCUInstance);
            force:
                begin
                    UnbindSubscription(GlobalCUInstance);
                    ClearGlobals();
                end;
        end;
    end;


    internal procedure Bind(): Boolean
    begin
        if IsBound() then
            exit;
        GlobalBound := BindSubscription(GlobalCUInstance);
        exit(IsBound());
    end;



    local procedure ClearGlobals()
    begin
        GlobalBound := false;
        GlobalRecreateEntry := false;
        Clear(GlobalPostingAccount);
        Clear(GlobalBalanceAccount);
        Clear(GlobalDocumentNo);
        Clear(GlobalEntryCreated);
        Clear(GlobalItemList);

        InitializeTextBuilder(GlobalSellToCustomerNoTextBuilder, 20);

        InitializeBracketPriceBuffer(GlobalTempSTABracketPrice);
    end;

    /// <summary>
    /// If a Bracket Price Buffer exists with at least one entry, then activate returns true.
    /// </summary>
    /// <param name="SalesRecordRef">RecordRef.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure BindEventCU(SalesRecordRef: RecordRef; TableNo: Integer) EventCUBound: Boolean
    var
        STABracketPriceCode: Record "STA Bracket Price Code";
        CustomerBracketPriceCode: Code[20];
        BracketPriceCode: Code[20];
    begin
        BracketPriceCode := GetCustomerBracketPriceCode(SalesRecordRef, TableNo, GlobalSellToCustomerNoTextBuilder);
        if BracketPriceCode = '' then // There is no need to generate an item list if the Bracket Price Code is empty.
            exit;
        GlobalItemList := GetItemListForDocument(SalesRecordRef, TableNo);
        if GlobalItemList.Count() = 0 then
            exit;
        if not GetBracketPriceBuffer(BracketPriceCode, GlobalItemList, GlobalTempSTABracketPrice) then
            exit;
        EventCUBound := Bind();
        STABracketPriceCode.GetPostingAccountsForBracketCode(BracketPriceCode, GlobalPostingAccount, GlobalBalanceAccount);
        GlobalDocumentNo := SalesRecordRef.Field(3).Value(); // Sales header Document No.
    end;

    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnAfterValidateEvent, "Context Record ID", false, false)]
    local procedure OnAfterValidateContextRecordId(CurrFieldNo: Integer; var Rec: Record "Error Message"; var xRec: Record "Error Message")
    begin
        if (xRec."Context Table Number" = Rec."Context Table Number") and not (Rec."Additional Information" in ['Preview mode.', 'Batch processing of Sales Header records.', 'Post document lines.']) then
            Unbind(true); // If this is reached, the transaction is over and the regular unbound pathway could not be reached.
    end;
    #endregion "Event Binding"
    /// <summary>
    /// Returns a bracket price buffer for the Bracket Price Code and Item List given.
    /// </summary>
    /// <param name="BracketPriceCode">Code[20].</param>
    /// <param name="ItemList">List of [Code[20]].</param>
    /// <returns>Return variable TempSTABracketPrice of type Record "STA Bracket Price" temporary.</returns>
    local procedure GetBracketPriceBuffer(BracketPriceCode: Code[20]; var ItemList: List of [Code[20]]; var TempSTABracketPrice: Record "STA Bracket Price" temporary) HasEntries: Boolean
    var
        STABracketPrice: Record "STA Bracket Price";
        ItemNoCode: Code[20];

        ItemNoFilterText: TextBuilder;
    begin
        InitializeBracketPriceBuffer(TempSTABracketPrice);
        // if ItemList.Count() = 0 then
        //     exit;
        STABracketPrice.SetRange(Active, true);
        STABracketPrice.SetRange("Bracket Price Code", BracketPriceCode);
        STABracketPrice.SetLoadFields("Item No.", "Bracket Unit Price", "Item Unit Price", "Units per Case", SystemId);
        if STABracketPrice.IsEmpty() then
            exit;

        foreach ItemNoCode in ItemList do begin
            ItemNoFilterText.Append(ItemNoCode);
            ItemNoFilterText.Append(JoinCharacterLabel);
        end;
        Clear(ItemList); // We will re-build this list later after we have returned bracket prices.
        ItemNoFilterText.Remove(ItemNoFilterText.Length(), 1); // Remove the last join character label. (This is the last character in the text builder.)
        STABracketPrice.SetFilter("Item No.", ItemNoFilterText.ToText());
        STABracketPrice.SetFilter("Bracket Unit Price", '<>%1', 0);
        HasEntries := STABracketPrice.FindSet(false);
        if not HasEntries then
            exit;

        repeat
            TempSTABracketPrice := STABracketPrice;
            TempSTABracketPrice.Insert();
            if not ItemList.Contains(TempSTABracketPrice."Item No.") then
                ItemList.Add(TempSTABracketPrice."Item No.");
        until STABracketPrice.Next() = 0;

        if not IsBound() then // Under normal circumstances, the procedure should exit here. If the event CU is recovering from an error state, this will ensure that the event CU is bound and GlobalBound from the previous transaction is set to false.
            exit;
        GlobalBound := false;
    end;

    local procedure GetCustomerBracketPriceCode(SalesRecordRef: RecordRef; TableNo: Integer; var SellToCustomerNoTextBuilder: TextBuilder) BracketPriceCode: Code[20]
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        STABracketPriceCode: Record "STA Bracket Price Code";
    begin
        InitializeTextBuilder(SellToCustomerNoTextBuilder, 20);
        case TableNo of
            Database::"Sales Header":
                begin
                    SellToCustomerNoTextBuilder.Append(Format(SalesRecordRef.Field(2).Value())); // Sell-to Customer No.
                                                                                                 // if GlobalRecreateEntry then
                                                                                                 //     GlobalRecreateEntry := false;
                    Customer.SetRange("No.", SellToCustomerNoTextBuilder.ToText()); // A text builder is used so that the Customer Code is not copied to a new address between runs when its value is reset. //TODO: Add Customers by bracket build up to prevent this table from being read repeatedly. Pass this into the function.
                    Customer.SetFilter("SBC Bracket Price Code", '<>%1', '');
                    Customer.SetLoadFields("SBC Bracket Price Code");
                    if not Customer.FindFirst() then
                        exit;
                    BracketPriceCode := Customer."SBC Bracket Price Code";
                end;
            Database::"Value Entry": // This is for rebuilding entries.
                begin
                    // CustLedgerEntry.SetRange("Customer No.", SalesRecordRef.Field(5).Value()); // Source No. | Important(Only Value Entry records with Source Type of Customer should be allowed. We are not concerned with other Source Types for Bracket Pricing.)
                    // CustLedgerEntry.SetRange("Document No.", SalesRecordRef.Field(6).Value()); // Document No.
                    // CustLedgerEntry.SetLoadFields("Sell-to Customer No.");
                    // if not CustLedgerEntry.FindFirst() then
                    //     exit;
                    // if not GlobalBracketDictionary.Get(CustLedgerEntry."Sell-to Customer No.", BracketPriceCode) then
                    //     exit;
                    SellToCustomerNoTextBuilder.Append(GlobalCustomerNo);
                    BracketPriceCode := GlobalBracketPriceCode;

                    // if not GlobalRecreateEntry then
                    //     GlobalRecreateEntry := true;
                end;
            else
                exit;
        end;
        // if SellToCustomerNoTextBuilder.Length() = 0 then // This should never occur. 
        //     exit;
        if BracketPriceCode = '' then
            exit;

        STABracketPriceCode.SetRange("Bracket Price Code", BracketPriceCode);
        STABracketPriceCode.SetRange(Blocked, true);
        if STABracketPriceCode.IsEmpty() then
            exit;

        BracketPriceCode := '';
    end;


    local procedure GetBracketPriceRecord(ItemNo: Code[20]) TempSTABracketPrice: Record "STA Bracket Price" temporary;
    begin
        GlobalTempSTABracketPrice.SetRange("Item No.", ItemNo);
        if GlobalTempSTABracketPrice.IsEmpty() then
            exit;
        GlobalTempSTABracketPrice.FindFirst();
        TempSTABracketPrice := GlobalTempSTABracketPrice;
    end;


    internal procedure WriteBracketPriceLedgerEntry(ValueEntry: Record "Value Entry") Created: Boolean;
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        TempSTABracketPrice: Record "STA Bracket Price" temporary;
        STABracketPriceLedger: Record "STA Bracket Price Ledger";
        EntryExists: Boolean;
        RecreateEntry: Boolean;
        STABracketPriceCode: Record "STA Bracket Price Code";
    begin
        STABracketPriceLedger.SetFiltersForValueEntry(ValueEntry, STABracketPriceLedger);
        EntryExists := not STABracketPriceLedger.IsEmpty();
        if (EntryExists and not GlobalRecreateEntry) then
            exit;
        TempSTABracketPrice := GetBracketPriceRecord(ValueEntry."Item No.");
        if (TempSTABracketPrice."Bracket Unit Price" = 0) or (EntryExists and not GlobalRecreateEntry) then
            exit;
        STABracketPriceCode.SetRange("Bracket Price Code", TempSTABracketPrice."Bracket Price Code");
        STABracketPriceCode.SetLoadFields("Bracket Dimension Value");
        if STABracketPriceCode.FindFirst() then;
        STABracketPriceLedger.RecreateEntry(GlobalRecreateEntry);
        STABracketPriceLedger := STABracketPriceLedger.CreateLedgerEntry(TempSTABracketPrice, ValueEntry, GlobalSellToCustomerNoTextBuilder.ToText(), STABracketPriceCode."Bracket Dimension Value");
        STABracketPriceLedger.SetRecFilter();
        GlobalEntryCreated := not STABracketPriceLedger.IsEmpty();
        SBCTATradeBudgetOptions.SetRange("Post Bracket Entries to GL", true);
        case true of
            GlobalRecreateEntry, not GlobalEntryCreated, SBCTATradeBudgetOptions.IsEmpty():
                Unbind(true);
        end;
    end;

    local procedure InsertBracketPriceValueEntry(var ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer; var ValueEntryAmount: Decimal; PostingDescrcription: Text[100]; PostingAccount: Code[20]; BalanceAccount: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        BracketPricingValueEntry: Record "Value Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        SBCTALedgerEntryHandler: Codeunit "SBCTA Ledger Entry Handler";
    begin
        BracketPricingValueEntry := ValueEntry;
        if ValueEntryNo = 0 then
            ValueEntryNo := BracketPricingValueEntry."Entry No.";
        SBCTALedgerEntryHandler.GetLastValueEntryNo(ValueEntryNo);
        ValueEntryNo := ValueEntryNo + 1;
        BracketPricingValueEntry."Entry No." := ValueEntryNo;

        BracketPricingValueEntry."Item Charge No." := '';

        BracketPricingValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        case BracketPricingValueEntry."Document Type" of
            "Item Ledger Document Type"::"Sales Invoice":
                BracketPricingValueEntry."Document Type" := "Item Ledger Document Type"::"Sales Shipment";
            "Item Ledger Document Type"::"Sales Credit Memo":
                BracketPricingValueEntry."Document Type" := "Item Ledger Document Type"::"Sales Return Receipt";
        end;
        // The sourcing line in the value entry still contains all the information being zeroed out here.
        BracketPricingValueEntry.Description := PostingDescrcription;
        BracketPricingValueEntry."Cost per Unit" := 0;
        BracketPricingValueEntry."Cost per Unit (ACY)" := 0;
        BracketPricingValueEntry."Cost Posted to G/L" := 0;
        BracketPricingValueEntry."Cost Posted to G/L (ACY)" := 0;
        BracketPricingValueEntry."Invoiced Quantity" := 0;
        BracketPricingValueEntry."Sales Amount (Actual)" := ValueEntryAmount;
        BracketPricingValueEntry."Sales Amount (Expected)" := 0;
        BracketPricingValueEntry."Purchase Amount (Actual)" := 0;
        BracketPricingValueEntry."Purchase Amount (Expected)" := 0;
        BracketPricingValueEntry."Discount Amount" := 0;
        BracketPricingValueEntry."Cost Amount (Actual)" := 0; //Check
        BracketPricingValueEntry."Cost Amount (Expected)" := 0;
        BracketPricingValueEntry."Cost Amount (Expected) (ACY)" := 0;
        BracketPricingValueEntry."Expected Cost Posted to G/L" := 0;
        BracketPricingValueEntry."Exp. Cost Posted to G/L (ACY)" := 0;

        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        SBCTALedgerEntryHandler.Bind();
        // SBCTALedgerEntryHandler.SetIndirectRate(IndirectTradeRate);
        SBCTALedgerEntryHandler.SetPostingAccounts(PostingAccount, BalanceAccount);
        SBCTALedgerEntryHandler.SetIndirectDescription(PostingDescrcription);
        ItemJnlPostLine.SetCalledFromAdjustment(false, true);
        ItemJnlPostLine.InsertValueEntry(BracketPricingValueEntry, ItemLedgerEntry, false);
    end;

    #region "Item List Building"

    internal procedure GetItemListForDocument(SalesRecordRef: RecordRef; TableNo: Integer) ItemList: List of [Code[20]];
    begin
        case TableNo of
            Database::"Sales Header":
                BuildSalesLineItemList(SalesRecordRef, ItemList);
            Database::"Value Entry": // This is for rebuilding entries.
                BuildValueEntryItemList(SalesRecordRef, ItemList);
            else
                exit;
        end;
    end;

    local procedure BuildSalesLineItemList(var SalesRecordRef: RecordRef; var ItemList: List of [Code[20]])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetLoadFields("No.");
        SalesLine.SetRange("Document No.", SalesRecordRef.Field(3).Value()); // Document No.
        SalesLine.SetRange(Type, "Sales Line Type"::Item);
        if not SalesLine.FindSet() then
            exit;
        repeat
            if not ItemList.Contains(SalesLine."No.") then
                ItemList.Add(SalesLine."No.");
        until SalesLine.Next() = 0;
    end;

    local procedure BuildValueEntryItemList(var SalesRecordRef: RecordRef; var ItemList: List of [Code[20]])
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetLoadFields("Item No.");
        ValueEntry.SetRange("Document No.", SalesRecordRef.Field(6).Value()); // Document No.
        ValueEntry.SetRange("Source Type", "Analysis Source Type"::Customer);
        if not ValueEntry.FindSet() then
            exit;
        repeat
            if not ItemList.Contains(ValueEntry."Item No.") then
                ItemList.Add(ValueEntry."Item No.");
        until ValueEntry.Next() = 0;
    end;

    local procedure InitializeTextBuilder(var TextBuilder: TextBuilder; Capacity: Integer)
    begin
        if Capacity < 1 then
            Capacity := 20;
        if TextBuilder.Length() <> 0 then
            TextBuilder.Clear();
        if TextBuilder.MaxCapacity() <> Capacity then
            TextBuilder.Capacity(Capacity);
    end;

    local procedure InitializeBracketPriceBuffer(var TempSTABracketPrice: Record "STA Bracket Price" temporary)
    begin
        TempSTABracketPrice.Reset();
        if TempSTABracketPrice.IsEmpty() then
            exit;
        TempSTABracketPrice.DeleteAll();
    end;

    local procedure GetDimensionSetID(BracketDimensionValueCode: Code[20]; ExistingDimensionSetId: Integer; ShortcutDimensionValueCode1: Code[20]; ShortDimensionValueCode2: Code[20]) DimSetID: Integer
    var
        DimensionManagement: Codeunit DimensionManagement;
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GLSetupShortcutDimCode: array[8] of Code[20];
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimensionManagement.GetGLSetup(GLSetupShortcutDimCode);
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, ExistingDimensionSetId);
        if TempDimensionSetEntry.IsEmpty() then begin
            TempDimensionSetEntry.Validate("Dimension Code", GLSetupShortcutDimCode[1]);
            TempDimensionSetEntry.Validate("Dimension Value Code", ShortcutDimensionValueCode1);
            TempDimensionSetEntry.Insert(true);
            TempDimensionSetEntry.Validate("Dimension Code", GLSetupShortcutDimCode[2]);
            TempDimensionSetEntry.Validate("Dimension Value Code", ShortDimensionValueCode2);
            TempDimensionSetEntry.Insert(true);
        end else
            TempDimensionSetEntry.ModifyAll("Dimension Set ID", 0);
        SBCTATradeBudgetOptions.SetLoadFields("Bracket Dimension Code");
        SBCTATradeBudgetOptions.FindFirst();
        TempDimensionSetEntry.Validate("Dimension Code", SBCTATradeBudgetOptions."Bracket Dimension Code");
        TempDimensionSetEntry.Validate("Dimension Value Code", BracketDimensionValueCode);
        TempDimensionSetEntry.Insert(true);
        DimSetID := TempDimensionSetEntry.GetDimensionSetID(TempDimensionSetEntry);
    end;

    internal procedure SetGlobalBracketValues(CustomerNo: Code[20]; BracketPriceCode: Code[20])
    begin
        GlobalCustomerNo := CustomerNo;
        GlobalBracketPriceCode := BracketPriceCode;
    end;

    internal procedure ClearGlobalBracketValues()
    begin
        Clear(GlobalCustomerNo);
        Clear(GlobalBracketPriceCode);
    end;
    #endregion "Item List Building"
    internal procedure SetRecreateValueEntry(RecreateValueEntry: Boolean)
    begin
        GlobalRecreateEntry := RecreateValueEntry;
    end;

    var
        GlobalTempSTABracketPrice: Record "STA Bracket Price" temporary;
        GlobalCUInstance: Codeunit "STA Bracket Price Events";
        GlobalItemList: List of [Code[20]];
        GlobalPostingAccount: Code[20];
        GlobalBalanceAccount: Code[20];
        GlobalDocumentNo: Code[20];
        GlobalCustomerNo: Code[20];
        GlobalBracketPriceCode: Code[20];
        GlobalSellToCustomerNoTextBuilder: TextBuilder; // This is used so that the Sell-to Customer No. is not created and reallocated in memory between runs.
        GlobalBound: Boolean;

        GlobalRecreateEntry: Boolean;
        GlobalEntryCreated: Boolean;
        JoinCharacterLabel: Label '|';
}