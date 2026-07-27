/// <summary>
/// Codeunit SBCTA Ledger Entry Handler (ID 50211).
/// </summary>
codeunit 50211 "SBCTA Ledger Entry Handler"
{
    EventSubscriberInstance = manual;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeStartOrContinuePosting, '', false, false)]
    local procedure OnBeforeStartOrContinuePosting(var GenJnlLine: Record "Gen. Journal Line"; LastDocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder; LastDocNo: Code[20]; LastDate: Date; var NextEntryNo: Integer)
    var
        LastEntryNo: Integer;
        PreviousLastEntryNo: Integer;
    begin
        if GlobalEntryNoDictionary.Count() = 0 then // If nextentryno = 0
            exit;
        LastEntryNo := NextEntryNo;
        if 0 = LastEntryNo then
            LastEntryNo := GetLastGLEntryNo()
        else begin
            if not GlobalEntryNoDictionary.ContainsKey(NextEntryNo) then begin
                GlobalEntryNoDictionary.Add(NextEntryNo, 0);
                exit;
            end;
        end;

        LastEntryNo := LastEntryNo + 1;
        while GlobalEntryNoDictionary.ContainsKey(LastEntryNo) and (PreviousLastEntryNo <> LastEntryNo) do begin
            PreviousLastEntryNo := LastEntryNo;
            LastEntryNo := GetLastGLEntryNo() + 1;
        end;

        if not GlobalEntryNoDictionary.ContainsKey(LastEntryNo) then
            GlobalEntryNoDictionary.Add(LastEntryNo, 0);
        // end;
        NextEntryNo := LastEntryNo;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnInsertItemRegOnBeforeItemRegInsert, '', false, false)]
    local procedure OnInsertItemRegOnBeforeItemRegInsert(var ItemRegister: Record "Item Register"; var ItemJournalLine: Record "Item Journal Line")
    begin
        GlobalLastItemRegNo := ItemRegister."No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInsertGLEntry, '', false, false)]
    local procedure OnAfterInsertGLEntry(GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; TempGLEntryBuf: Record "G/L Entry" temporary; CalcAddCurrResiduals: Boolean)
    begin
        if GlobalEntryNoDictionary.ContainsKey(GLEntry."Entry No.") then
            exit;
        GlobalEntryNoDictionary.Add(GLEntry."Entry No.", 0); // This should only occur on the first entry.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnInsertValueEntryOnBeforeCalcExpectedCost, '', false, false)]
    local procedure OnInsertValueEntryOnBeforeCalcExpectedCost(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry"; var ValueEntry: Record "Value Entry"; TransferItemPBln: Boolean; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; var ShouldCalcExpectedCost: Boolean)
    begin
        // Unbind();
        if (ValueEntry.Description <> GlobalIndirectDescription) then
            exit;
        if ValueEntry."Item Ledger Entry Quantity" <> 0 then
            ValueEntry."Item Ledger Entry Quantity" := 0;
        ValueEntry."Dimension Set ID" := ItemLedgEntry."Dimension Set ID";
        ValueEntry."Global Dimension 1 Code" := ItemLedgEntry."Global Dimension 1 Code";
        ValueEntry."Global Dimension 2 Code" := ItemLedgEntry."Global Dimension 2 Code";
        ItemJnlLine."Indirect Cost %" := GlobalIndirectRate;
        // if (ValueEntry."Entry Type" = "Cost Entry Type"::"Direct Cost") and (ValueEntry."Item Ledger Entry Type" = "Item Ledger Entry Type"::Sale)  then //This enables OnSetAccNoOnBeforeCheckAccNo for Sales Posting Types.
        //     ValueEntry."Entry Type" := "Cost Entry Type"::"Indirect Cost";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterIsPostToGL, '', false, false)]
    local procedure OnAfterIsPostToGL(ValueEntry: Record "Value Entry"; var Result: Boolean)
    begin
        if Result then
            exit;
        If ValueEntry."Source Code" <> GetReclassSourceCode() then
            exit;
        Result := true;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInitValueEntry, '', false, false)]
    local procedure OnBeforeInitValueEntry(var ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer; var ItemJournalLine: Record "Item Journal Line")
    begin
        GetLastValueEntryNo(ValueEntryNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnBeforePostInvtPostBuf, '', false, false)]
    // local procedure OnBeforeBufferAdjmtPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    local procedure OnBeforePostInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        InventoryPostingToGL: Codeunit "Inventory Posting To G/L";
        LocalInventoryPostBuf: Record "Invt. Posting Buffer" temporary;
        InventorySetup: Record "Inventory Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalSBCTAPurchItemEvents: Codeunit "SBCTA Purch Item Events";
    begin
        // IsHandled := (ValueEntry."Item Ledger Entry Type" in [ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.", ValueEntry."Item Ledger Entry Type"::"Negative Adjmt."]); // if this is not handled, we will get an invalid combination exception.
        // if not IsHandled then
        //     exit;
        if not (ValueEntry."Item Ledger Entry Type" in [ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.", ValueEntry."Item Ledger Entry Type"::"Negative Adjmt."]) then
            exit;
        if not GlobalSBCTAPurchItemEvents.ActivateCOGsPosting(ValueEntry) then
            exit;
        GlobalSBCTAPurchItemEvents.CreateEntriesFromValueEntry(ValueEntry);
        GlobalSBCTAPurchItemEvents.ClearGlobals();
        // if not InventoryPostingToGL.BufferInvtPosting(ValueEntry) then
        //     exit;
        // InventorySetup.SetLoadFields("Invt. Cost Jnl. Template Name", "Invt. Cost Jnl. Batch Name");
        // InventorySetup.Get();
        // GeneralLedgerSetup.SetLoadFields("Journal Templ. Name Mandatory");
        // GeneralLedgerSetup.Get();
        // if GeneralLedgerSetup."Journal Templ. Name Mandatory" then
        //     InventoryPostingToGL.SetGenJnlBatch(
        //         InventorySetup."Invt. Cost Jnl. Template Name", InventorySetup."Invt. Cost Jnl. Batch Name");
        // InventoryPostingToGL.GetInvtPostBuf(LocalInventoryPostBuf);
        // // InventoryPostingToGL.PostInvtPostBufPerEntry(ValueEntry);

        // InventoryPostingToGL.PostInvtPostBufPerEntry(ValueEntry);
        // InventoryPostingToGL.InitInvtPostBuf(ValueEntry, "Invt. Posting Buffer Account Type"::Inventory, "Invt. Posting Buffer Account Type"::"Overhead Applied", CostToPost, CostToPostACY, false);
        // InventoryPostingToGL.GetInvtPostBuf(LocalInventoryPostBuf);
        // LocalInventoryPostBuf.Reset();
        // if LocalInventoryPostBuf.IsEmpty() then begin
        // IsHandled := false;
        //     exit;
        // end;

        // if LocalInventoryPostBuf.FindSet() then
        //     repeat
        //         GlobalInvtPostBuf := LocalInventoryPostBuf;
        //         GlobalInvtPostBuf.Insert();
        //     until LocalInventoryPostBuf.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInsertCorrValueEntry, '', false, false)]
    local procedure OnBeforeInsertCorrValueEntry(var NewValueEntry: Record "Value Entry"; OldValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line"; Sign: Integer; CalledFromAdjustment: Boolean; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L")
    begin
        GetLastValueEntryNo(ValueEntryNo); // This code is necessary during purchase receipt corrections so that the value entry does not use an entry no that has been used but not yet written to the database.
        if NewValueEntry."Entry No." <= ValueEntryNo then
            NewValueEntry."Entry No." := ValueEntryNo + 1
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; CalledFromAdjustment: Boolean; var OldItemLedgEntry: Record "Item Ledger Entry"; var Item: Record Item; TransferItem: Boolean; var GlobalValueEntry: Record "Value Entry")
    begin
    end;
    /// <summary>
    /// This event is used to swap out the standard Overhead Applied account with a different one that we have passed in to the function.
    /// </summary>
    /// <param name="InvtPostBuf">VAR Record "Invt. Posting Buffer".</param>
    /// <param name="InvtPostingSetup">Record "Inventory Posting Setup".</param>
    /// <param name="GenPostingSetup">Record "General Posting Setup".</param>
    /// <param name="CalledFromItemPosting">Boolean.</param>
    /// <param name="ValueEntry">VAR Record "Value Entry".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting to G/L", OnSetAccNoOnBeforeCheckAccNo, '', false, false)]
    local procedure OnSetAccNoOnBeforeCheckAccNo(var InvtPostBuf: Record "Invt. Posting Buffer"; InvtPostingSetup: Record "Inventory Posting Setup"; GenPostingSetup: Record "General Posting Setup"; CalledFromItemPosting: Boolean; var ValueEntry: Record "Value Entry")
    begin
        // if not (InvtPostBuf."Account Type" in ["Invt. Posting Buffer Account Type"::"Overhead Applied", "Invt. Posting Buffer Account Type"::COGS]) then
        //     exit;
        if (ValueEntry.Description <> GlobalIndirectDescription) then
            exit;

        case InvtPostBuf."Account Type" of
            "Invt. Posting Buffer Account Type"::"Overhead Applied":
                InvtPostBuf."Account No." := GlobalIndirectAccount;
            "Invt. Posting Buffer Account Type"::"COGS":
                InvtPostBuf."Account No." := GlobalIndirectAccount;
            "Invt. Posting Buffer Account Type"::Inventory:
                InvtPostBuf."Account No." := GlobalBalanceAccount;
        end;
    end;

    /// <summary>
    /// This event is used to replace the posting description on the line.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record "Gen. Journal Line".</param>
    /// <param name="ValueEntry">VAR Record "Value Entry".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting to G/L", OnPostInvtPostBufOnAfterInitGenJnlLine, '', false, false)]
    local procedure OnPostInvtPostBufOnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var ValueEntry: Record "Value Entry")
    begin
        // if (ValueEntry."Entry Type" <> "Cost Entry Type"::"Indirect Cost") or (ValueEntry.Description <> GlobalIndirectDescription) then
        //     exit;
        if (ValueEntry.Description <> GlobalIndirectDescription) then
            exit;

        GenJournalLine.Description := CopyStr(
            StrSubstNo(DescriptionTextLabel, GlobalIndirectDescription, ValueEntry."Source No.", ValueEntry."Posting Date"),
            1, MaxStrLen(GenJournalLine.Description));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeUpdateGLReg, '', false, false)]
    local procedure OnBeforeUpdateGLReg(IsTransactionConsistent: Boolean; var IsGLRegInserted: Boolean; var GLReg: Record "G/L Register"; var IsHandled: Boolean; var GenJnlLine: Record "Gen. Journal Line"; GlobalGLEntry: Record "G/L Entry")
    begin
        IsHandled := (GLReg."No." = 0)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnRunOnAfterPostPurchLine, '', false, false)]
    local procedure OnRunOnAfterPostPurchLine(var TempPurchLineGlobal: Record "Purchase Line" temporary)
    begin
        // Unbind(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterProcessPurchLines, '', false, false)]
    local procedure OnAfterProcessPurchLines(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShipmentHeader: Record "Return Shipment Header"; WhseShip: Boolean; WhseReceive: Boolean; var PurchLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean)
    begin
        Unbind(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", OnAfterPostLines, '', false, false)]
    local procedure OnAfterPostLines(var ItemJournalLine: Record "Item Journal Line"; var ItemRegNo: Integer)
    begin
        GlobalOriginalItemRegNo := ItemRegNo; // This code swaps the itemregno to a future entry no. that was created during the original posting process that was interrupted so that code that follows this event can pass a check.
        if ItemRegNo <> GlobalLastItemRegNo then
            ItemRegNo := GlobalLastItemRegNo;
        // Unbind(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", OnAfterCopyRegNos, '', false, false)]
    local procedure OnAfterCopyRegNos(var ItemJournalLine: Record "Item Journal Line"; var ItemRegNo: Integer; var WhseRegNo: Integer)
    begin
        if ItemRegNo = GlobalLastItemRegNo then //After the check is passed, we return the original itemregno.
            ItemRegNo := GlobalOriginalItemRegNo;
        Unbind(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesLines, '', false, false)]
    // local procedure OnAfterPostSalesLines(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; WhseShip: Boolean; WhseReceive: Boolean; var SalesLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)
    local procedure OnAfterPostSalesLines()
    begin
        Unbind(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnBeforeBufferSalesPosting, '', false, false)]
    local procedure OnBeforeBufferSalesPosting(var ValueEntry: Record "Value Entry"; var GlobalInvtPostBuf: Record "Invt. Posting Buffer"; CostToPost: Decimal; CostToPostACY: Decimal; ExpCostToPost: Decimal; ExpCostToPostACY: Decimal; var IsHandled: Boolean)
    var 
     InventoryPostingToGL: Codeunit "Inventory Posting To G/L";
    begin
        if IsHandled then
            exit;
        // IsHandled := ValueEntry."Entry Type" = "Cost Entry Type"::"Indirect Cost";
        // if not IsHandled then
        //     exit;

        ValueEntry."Entry Type" := "Cost Entry Type"::"Direct Cost"; //Swap so that it posts to the buffer

    end;
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", OnBeforeInitInvtPostBuf, '', false, false)]
      local procedure OnBeforeInitInvtPostBuf(var ValueEntry: Record "Value Entry")
    begin
         ValueEntry."Entry Type" := "Cost Entry Type"::"Indirect Cost"; //Swap back so that it posts as indirect cost.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnAfterTransferOrderPostReceipt, '', false, false)]
    local procedure OnAfterTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean; var TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
        Unbind(true);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Posting Management", OnPostItemJnlLineOnBeforePostJobConsumption, '', false, false)]
    // local procedure OnPostItemJnlLineOnBeforePostJobConsumption(var ItemJnlLine2: Record "Item Journal Line"; var IsHandled: Boolean)
    // begin 
    //     Unbind(true);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Purchase Receipt Line", OnAfterCode, '', false, false)]
    local procedure OnAfterCode(var PurchRcptLine: Record "Purch. Rcpt. Line"; var UndoPostingManagement: Codeunit "Undo Posting Management")
    begin
        Unbind(true);
    end;

    local procedure GetLastGLEntryNo() LastEntryNo: Integer;
    var
        GLEntry: Record "G/L Entry";
        LastTransactionNo: Integer;
    begin
        GLEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        GLEntry.SetLoadFields("Entry No.");
        GLEntry.SetAscending("Entry No.", false);
        GLEntry.FindSet(false);
        LastEntryNo := GLEntry."Entry No.";
        // GLEntry.GetLastEntry(LastEntryNo, LastTransactionNo);
    end;

    internal procedure GetReclassSourceCode() SourceCode: Code[10];
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.SetLoadFields("Item Reclass. Journal");
        SourceCodeSetup.FindFirst();
        SourceCode := SourceCodeSetup."Item Reclass. Journal";
    end;

    #region InstanceMethods


    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnAfterValidateEvent, "Context Record ID", false, false)]
    local procedure OnAfterValidateContextRecordId(CurrFieldNo: Integer; var Rec: Record "Error Message"; var xRec: Record "Error Message")
    begin
        if (xRec."Context Table Number" = Rec."Context Table Number") and not (Rec."Additional Information" in ['Preview mode.', 'Batch processing of Sales Header records.']) then
            Unbind(true); // If this is reached, the transaction is over and the regular unbound pathway could not be reached.


    end;

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
        Clear(GlobalEntryNoDictionary);
        Clear(GlobalIndirectRate);
        Clear(GlobalIndirectAccount);
        Clear(GlobalIndirectDescription);
        Clear(GlobalBalanceAccount);
        Clear(GlobalLastItemRegNo);
        // Clear(GlobalRecreateValueEntry);
        // Clear(GlobalSBCTATradeBudget);
        // Clear(GlobalSBCTATradeBudgetOptions);
        // if not GlobalTempValueEntry.IsEmpty() then
        //     GlobalTempValueEntry.DeleteAll();
        // Clear(GlobalTempValueEntry);
        // Clear(GlobalRateCodeFilterText);
        // Clear(GlobalIndirectRate);
        // Clear(GlobalLastEntryNo);
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

    internal procedure SetIndirectRate(IndirectRate: Decimal)
    begin
        GlobalIndirectRate := IndirectRate;
    end;

    internal procedure SetPostingAccounts(IndirectAccount: Code[20]; BalanceAccount: Code[20])
    begin
        GlobalIndirectAccount := IndirectAccount;
        GlobalBalanceAccount := BalanceAccount;
    end;

    internal procedure GetLastValueEntryNo(var ValueEntryNo: Integer)
    var
        EntryNoValueEntry: Record "Value Entry";
    begin
        EntryNoValueEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        if EntryNoValueEntry.FindLast() and (EntryNoValueEntry."Entry No." > ValueEntryNo) then
            ValueEntryNo := EntryNoValueEntry."Entry No.";
    end;

    internal procedure SetIndirectDescription(IndirectDescription: Text)
    begin
        GlobalIndirectDescription := CopyStr(IndirectDescription, 1, MaxStrLen(GlobalIndirectDescription));
    end;
    #endregion InstanceMethods

    var
        GlobalCUInstance: Codeunit "SBCTA Ledger Entry Handler";
        GlobalBound: Boolean;

        GlobalLastItemRegNo: Integer;
        GlobalOriginalItemRegNo: Integer;
        GlobalIndirectRate: Decimal;
        GlobalIndirectAccount: Code[20];
        GlobalBalanceAccount: Code[20];
        GlobalIndirectDescription: Text[100];
        GlobalEntryNoDictionary: Dictionary of [Integer, Integer];
        DescriptionTextLabel: Label '%1 %2 on %3';
}