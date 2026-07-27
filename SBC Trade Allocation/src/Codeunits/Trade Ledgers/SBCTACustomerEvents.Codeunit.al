/// <summary>
/// Codeunit SBCTA Trade Ledger Events (ID 50201).
/// </summary>
codeunit 50201 "SBCTA Customer Events"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    #region AR
    #region AREventSubscriber

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostCustOnAfterAssignReceivablesAccount, '', false, false)]
    local procedure SBCTAOnPostCustOnAfterAssignReceivablesAccount(GenJnlLine: Record "Gen. Journal Line"; CustomerPostingGroup: Record "Customer Posting Group"; var ReceivablesAccount: Code[20])
    begin
        Unbind();
        if GlobalTempValueEntry.IsEmpty() then
            exit;
        ProcessValueEntryBuffer(GlobalTempValueEntry, GlobalSBCTATradeBudgetSetup);
        ClearGlobals();
    end;

    #endregion AREventSubscriber



    #endregion AR
    #region COGS
    #region COGSEventSubscriber

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnPostInvtPostBufferOnAfterPostInvtPostBuf, '', false, false)]
    local procedure OnPostInvtPostBufferOnAfterPostInvtPostBuf(GlobalInvtPostBuf: Record "Invt. Posting Buffer" temporary; var ValueEntry: Record "Value Entry"; CalledFromItemPosting: Boolean; CalledFromTestReport: Boolean; RunOnlyCheck: Boolean; PostPerPostGrp: Boolean);
    begin
        if not GlobalTempValueEntry.IsEmpty() then
            exit;
        Unbind();
        CreateEntriesFromValueEntry(ValueEntry, GlobalSBCTATradeBudgetSetup);
        ClearGlobals();
    end;

    #endregion COGSEventSubscriber
    internal procedure ActivateCOGsPosting(ValueEntry: Record "Value Entry") Activate: Boolean
    var
        InvtPostingBuffer: Record "Invt. Posting Buffer" temporary;
    begin
        Activate := ActivateCOGsPosting(ValueEntry, InvtPostingBuffer);
    end;

    internal procedure ActivateCOGsPosting(ValueEntry: Record "Value Entry"; InvtPostingBuffer: Record "Invt. Posting Buffer" temporary) Activate: Boolean
    var

        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        if ValueEntry."Applies-to Entry" <> 0 then //Adjustments
            exit;
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        if not GlobalRunFromBatch then begin
            if not GlobalSBCTATradeBudgetOptions."Auto-Post Trade Accrual" then
                exit;
            if ValueEntry."Source Type" <> ValueEntry."Source Type"::Customer then
                exit;
            if (ValueEntry."Document Type" = "Item Ledger Document Type"::"Sales Credit Memo") and not GlobalSBCTATradeBudgetOptions."Auto-Post Sales Credits" then // We can add a similar exit condition here for shipment costs.
                exit;
            if not (ValueEntry."Document Type" in ["Item Ledger Document Type"::"Sales Invoice", "Item Ledger Document Type"::"Sales Credit Memo"]) then // If we are to capture any shipping related costs, then we would need to add a condition here.
                exit;
            SetSellToCustomerValues(ValueEntry); // If we change the value entry here, we will add it to the buffer.
        end;

        GlobalSBCTATradeBudget.SetFilter("Start Date", '<=%1', ValueEntry."Posting Date");
        GlobalSBCTATradeBudget.SetFilter("End Date", '>=%1', ValueEntry."Posting Date");
        GlobalSBCTATradeBudget.SetRange("Group Type", "SBCTA Budget Group Type"::Customer);
        GlobalSBCTATradeBudget.SetRange("Group Code", ValueEntry."Source Posting Group");
        GlobalSBCTATradeBudget.SetRange(Enabled, true);
        GlobalSBCTATradeBudget.SetRange("Shortcut Dimension 1 Code", ValueEntry."Global Dimension 1 Code");
        if GlobalSBCTATradeBudget.IsEmpty() then
            GlobalSBCTATradeBudget.SetFilter("Shortcut Dimension 1 Code",'%1',''); // This is to find the general budget record for the Customer Posting Group.
        if GlobalSBCTATradeBudget.IsEmpty() then
            exit;
        GlobalSBCTATradeBudget.FindFirst();

        Activate := GlobalSBCTATradeBudgetSetup.GetCustomerSetup(ValueEntry."Source Posting Group", ValueEntry."Source No.", ValueEntry."Global Dimension 1 Code", GlobalSBCTATradeBudgetSetup); // todo(Change this so that it takes item category or item dimension into account.) Change this to take the Trade Budget Code.
        if not Activate then
            exit;
        if GlobalRateCodeFilterText <> '' then
            GlobalSBCTATradeBudgetSetup.SetFilter("Trade Budget Rate Code", GlobalRateCodeFilterText);
        Activate := not GlobalSBCTATradeBudgetSetup.IsEmpty();
        if not Activate then
            exit;
        if GlobalRunFromBatch then
            exit;
        if PopulateValueEntryBuffer(ValueEntry, GlobalSBCTATradeBudget, GlobalSBCTATradeBudgetSetup) then // We don't need to fill the buffer if we aren't modifying the value entry.
            exit;
    end;

    internal procedure ProcessValueEntry(ValueEntry: Record "Value Entry")
    begin
        CreateEntriesFromValueEntry(ValueEntry, GlobalSBCTATradeBudgetSetup);
    end;

    local procedure ProcessValueEntryBuffer(var TempValueEntryBuffer: Record "Value Entry" temporary; var FilteredSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup")
    var
        IterationCount: Integer;
    begin

        TempValueEntryBuffer.FindSet();
        repeat
            IterationCount += 1;
            GlobalSBCTATradeBudget.GetBySystemId(GlobalTradeBudgetGUIDDictionary.Get(IterationCount));
            FilteredSBCTATradeBudgetSetup.SetView(GlobalTradeBudgetSetupFilterDictionary.Get(IterationCount));
            CreateEntriesFromValueEntry(TempValueEntryBuffer, FilteredSBCTATradeBudgetSetup);
            GlobalTradeBudgetGUIDDictionary.Remove(IterationCount);
            GlobalTradeBudgetSetupFilterDictionary.Remove(IterationCount); // This should efficiently remove entries from the dictionary.
        until TempValueEntryBuffer.Next() = 0;
    end;

    internal procedure CreateEntriesFromValueEntry(ValueEntry: Record "Value Entry"; var FilteredSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup")
    begin

        FilteredSBCTATradeBudgetSetup.FindSet();
        repeat
            CreateEntryFromValueEntry(ValueEntry, FilteredSBCTATradeBudgetSetup, GlobalSBCTATradeBudget."Trade Budget Code");
        until FilteredSBCTATradeBudgetSetup.Next() = 0;
    end;


    local procedure PopulateValueEntryBuffer(ValueEntry: Record "Value Entry"; GlobalSBCTATradeBudget: Record "SBCTA Trade Budget"; var GlobalSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup") Populated: Boolean
    var
        TempValueEntryCount: Integer;
    begin
        if GlobalSBCTATradeBudgetOptions."Customer Type" = "SBCTA Customer Type"::"Bill-To" then
            exit;

        GlobalTempValueEntry := ValueEntry;
        TempValueEntryCount := GlobalTempValueEntry.Count();
        GlobalTradeBudgetGUIDDictionary.Add(TempValueEntryCount + 1, GlobalSBCTATradeBudget.SystemId);  // This is being done so that the correct budget record and setup record are matched.
        GlobalTradeBudgetSetupFilterDictionary.Add(TempValueEntryCount + 1, GlobalSBCTATradeBudgetSetup.GetView());
        Populated := GlobalTempValueEntry.Insert();
    end;

    local procedure SetSellToCustomerValues(var ValueEntry: Record "Value Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
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
        // This is to prevent the preview posting job from not getting the correct document number.
        if CustLedgerEntry.IsEmpty() and (Format(GlobalSalesRecordRef) <> '') then begin
            CustLedgerEntry.SetRange("Document No.", GlobalSalesRecordRef.Field(SalesHeader.FieldNo("No.")).Value());
        end;
        if CustLedgerEntry.IsEmpty() and (Format(GlobalSalesRecordRef) = '') then
            exit;
        if CustLedgerEntry.FindFirst() then
            Customer.SetRange("No.", CustLedgerEntry."Sell-to Customer No.")
        else
            Customer.SetRange("No.", GlobalSalesRecordRef.Field(SalesHeader.FieldNo("Sell-to Customer No.")).Value());
        Customer.SetLoadFields("No.", "Customer Posting Group");
        if Customer.IsEmpty() then
            exit;
        Customer.FindFirst();
        ValueEntry."Source No." := Customer."No.";
        ValueEntry."Source Posting Group" := Customer."Customer Posting Group";
    end;

    internal procedure ValueEntryBufferHasEntries() HasEntries: Boolean
    begin
        HasEntries := not GlobalTempValueEntry.IsEmpty();
    end;

    internal procedure CreateEntryFromValueEntry(ValueEntry: Record "Value Entry"; var FilteredSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup"; TradeBudgetCode: Code[20])
    var
        SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes";
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
        EntryExists: Boolean;
        RecreateEntry: Boolean;
        TradeBudgetAmount: Decimal;
        TradeBudgetBasis: Decimal;
    begin
        SBCTATradeBudgetRateCodes.SetRange("Trade Budget Rate Code", FilteredSBCTATradeBudgetSetup."Trade Budget Rate Code");
        SBCTATradeBudgetRateCodes.SetRange(Blocked, false);
        if SBCTATradeBudgetRateCodes.IsEmpty() then
            exit;
        SBCTATradeBudgetRateCodes.FindFirst();

        SBCTATradeBudgetRates.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTATradeBudgetRates.SetRange("Trade Budget Rate Code", FilteredSBCTATradeBudgetSetup."Trade Budget Rate Code");
        SBCTATradeBudgetRates.SetFilter("Trade Budget Rate", '<>%1', 0);
        // if GlobalRateCodeFilterText <> '' then
        //     SBCTATradeBudgetRates.SetFilter("Trade Budget Rate Code", GlobalRateCodeFilterText);
        if SBCTATradeBudgetRates.IsEmpty() then
            exit;
        SBCTATradeBudgetRates.FindFirst();

        SBCTATrBudgetLedgerEntry.SetTradeEntryFiltersForVE(ValueEntry."Entry No.", SBCTATradeBudgetRates."Trade Budget Code", SBCTATradeBudgetRateCodes."Trade Budget Rate Code", SBCTATrBudgetLedgerEntry);
        EntryExists := not SBCTATrBudgetLedgerEntry.IsEmpty();

        if EntryExists and not GlobalRecreateValueEntry then
            exit;
        // TradeBudgetBasis := ValueEntry."Cost Amount (Actual)";
        case SBCTATradeBudgetRateCodes."Calculation Method" of
            "SBCTA COGs Calc Type"::"Gross Sale":
                TradeBudgetBasis := -1 * ValueEntry."Sales Amount (Actual)" + ValueEntry."Discount Amount"; // Adds the discount amount back in.
            "SBCTA COGs Calc Type"::"Net Sale":
                TradeBudgetBasis := -1 * ValueEntry."Sales Amount (Actual)";
            "SBCTA COGs Calc Type"::"Cost Only":
                TradeBudgetBasis := ValueEntry."Cost Amount (Actual)";
            "SBCTA COGs Calc Type"::"Discount Only":
                TradeBudgetBasis := -ValueEntry."Discount Amount";
        end;
        TradeBudgetAmount := SBCTATradeBudgetRates.GetAmount(TradeBudgetBasis, 1, 1, GlobalSBCTATradeBudgetOptions."Calculation Basis"); // 1 is fine because this already takes into account the quantity.
        if TradeBudgetAmount = 0 then
            exit;
        SBCTATrBudgetLedgerEntry.SetGroupCode("SBCTA Budget Group Type"::Customer, ValueEntry."Source Posting Group");
        SBCTATrBudgetLedgerEntry.RecreateEntry(EntryExists);
        SBCTATrBudgetLedgerEntry.CreateLedgerEntryFromValueEntry(SBCTATradeBudgetRates, ValueEntry, TradeBudgetAmount, TradeBudgetBasis, SBCTATradeBudgetRateCodes);
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


    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnAfterValidateEvent, "Context Record ID", false, false)]
    local procedure OnAfterValidateContextRecordId(CurrFieldNo: Integer; var Rec: Record "Error Message"; var xRec: Record "Error Message")
    begin
        if (xRec."Context Table Number" = Rec."Context Table Number") and not (Rec."Additional Information" in ['Preview mode.', 'Batch processing of Sales Header records.', 'Post document lines.']) then
            Unbind(true); // If this is reached, the transaction is over and the regular unbound pathway could not be reached.


    end;

    internal procedure ClearGlobals()
    begin
        Clear(GlobalBound);
        Clear(GlobalRunFromBatch);

        Clear(GlobalSBCTATradeBudgetSetup);
        Clear(GlobalSBCTATradeBudget);

        if not GlobalTempValueEntry.IsEmpty() then
            GlobalTempValueEntry.DeleteAll();
        Clear(GlobalTempValueEntry);
        Clear(GlobalRecreateValueEntry);
        Clear(GlobalRateCodeFilterText);
        Clear(GlobalTradeBudgetGUIDDictionary);
        Clear(GlobalTradeBudgetSetupFilterDictionary);
        Clear(GlobalSalesRecordRef);
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

    internal procedure SetSalesDocRecordRef(SalesRecordRef: RecordRef)
    begin
        GlobalSalesRecordRef := SalesRecordRef;
    end;

    var
        GlobalSBCTATradeBudget: Record "SBCTA Trade Budget";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        GlobalTempValueEntry: Record "Value Entry" temporary;
        GlobalSalesRecordRef: RecordRef;
        GlobalCUInstance: Codeunit "SBCTA Customer Events";
        GlobalBound: Boolean;
        GlobalRecreateValueEntry: Boolean;
        GlobalRunFromBatch: Boolean;
        GlobalTradeBudgetGUIDDictionary: Dictionary of [Integer, Guid];
        GlobalTradeBudgetSetupFilterDictionary: Dictionary of [Integer, Text];
        GlobalRateCodeFilterText: Text;



}