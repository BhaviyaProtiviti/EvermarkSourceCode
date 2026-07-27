/// <summary>
/// Codeunit SBCTA Preview Posting Events (ID 50202).
/// </summary>
codeunit 50202 "SBCTA Preview Posting Events"
{
    EventSubscriberInstance = manual;
    // TableNo = "SBCTA Tr. Budget Ledger Entry";
    SingleInstance = true;

    // trigger OnRun()
    // begin
    //     // SetGlobals(Rec);
    //     if (GlobalSBCTATrBudgetLedgerEntry."Accrued Amount" <> 0) and not GlobalProcessRemainingLedgerEntry then
    //         exit;
    // end;

    // local procedure SetGlobals(var Rec: Record "SBCTA Tr. Budget Ledger Entry")
    // begin
    //     GlobalSBCTATrBudgetLedgerEntry := Rec;
    // end;

    internal procedure SetProcessRemainingLedgerEntry(var ProcessRemaining: Boolean)
    begin
        GlobalProcessRemainingLedgerEntry := ProcessRemaining;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure OnAfterBindSubscription(var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    begin
        GlobalPostingPreviewEventHandler := PostingPreviewEventHandler;
    end;

    [EventSubscriber(ObjectType::Table, Database::"SBCTA Tr. Budget Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertTradeLedgerEntry(var Rec: Record "SBCTA Tr. Budget Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        // GlobalPostingPreviewEventHandler.PreventCommit();
        GlobalTempSBCTATrBudgetLedgerEntry := Rec;
        // if not ShowDocNo then
        //      GlobalTempSBCTATrBudgetLedgerEntry."Document No." := '***';
        GlobalTempSBCTATrBudgetLedgerEntry.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"SBCTA Tr. Budget Ledger Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyTradeLedgerEntry(var Rec: Record "SBCTA Tr. Budget Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        GlobalTempSBCTATrBudgetLedgerEntry := Rec;
        // if not ShowDocNo then
        //     TempGLEntry."Document No." := '***';

        // OnBeforeModifyTempGLEntry(Rec, TempGLEntry);

        if GlobalTempSBCTATrBudgetLedgerEntry.Modify() then;
        // GlobalPostingPreviewEventHandler.PreventCommit();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterFillDocumentEntry', '', false, false)]
    local procedure OnAfterFillDocumentEntry(var DocumentEntry: Record "Document Entry")
    begin
        if GlobalTempSBCTATrBudgetLedgerEntry.IsEmpty() then
            exit;
        GlobalPostingPreviewEventHandler.InsertDocumentEntry(GlobalTempSBCTATrBudgetLedgerEntry, DocumentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnGetEntries', '', false, false)]
    local procedure OnGetEntries(TableNo: Integer; var RecRef: RecordRef)
    begin
        if TableNo <> Database::"SBCTA Tr. Budget Ledger Entry" then
            exit;

        RecRef.GetTable(GlobalTempSBCTATrBudgetLedgerEntry);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterShowAllEntries', '', false, false)]
    // local procedure OnAfterShowAllEntries()
    // begin
    //     Unbind(true);
    // end;

    [EventSubscriber(ObjectType::Page, Page::"Extended G/L Posting Preview", 'OnQueryClosePageEvent', '', false, false)]
    local procedure DeleteTempEntries()
    begin
        Unbind(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Preview Event Handler", 'OnAfterShowEntries', '', false, false)]
    local procedure OnAfterShowEntries(TableNo: Integer)
    begin
        if TableNo <> Database::"SBCTA Tr. Budget Ledger Entry" then
            exit;
        // Clear(GlobalBound);
        Page.Run(Page::"SBCTA Trade Ledger Preview", GlobalTempSBCTATrBudgetLedgerEntry);
        //Show preview page here.
        // GlobalCUInstance.Unbind(true);
        // if GlobalTempSBCTATrBudgetLedgerEntry.IsEmpty() then
        //     exit;
        // GlobalTempSBCTATrBudgetLedgerEntry.DeleteAll();
    end;

    #region InstanceMethods
    internal procedure IsBound(): Boolean
    begin
        exit(GlobalBound);
    end;

    internal procedure Unbind()
    begin
        Unbind(false);
    end;

    // internal procedure Unbind(Force: Boolean)
    // begin
    //     if not Force then
    //         if not IsBound() then
    //             exit;

    //     if not UnbindSubscription(GlobalCUInstance) then
    //         if not Force then
    //             exit;
    //     if not Force then
    //         exit;
    //     ClearGlobals();
    // end;

    internal procedure Unbind(Force: Boolean)
    begin
        // case true of
        //     not force and not IsBound():
        //         exit;
        //      not force and UnbindSubscription(GlobalCUInstance):
        //         GlobalBound := false;
        //     force and UnbindSubscription(GlobalCUInstance):
        //         ClearGlobals();
        // end;
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

    local procedure ClearGlobals()
    begin
        Clear(GlobalBound);
        if GlobalTempSBCTATrBudgetLedgerEntry.IsEmpty() then
            exit;
        GlobalTempSBCTATrBudgetLedgerEntry.DeleteAll();
        Clear(GlobalTempSBCTATrBudgetLedgerEntry);
        // Clear(GlobalCustomerPostingGroup);
        // Clear(GlobalGLAccount);
        // Clear(GlobalSellToCustomer);
        // Clear(GlobalBillToCustomer);
        // Clear(GlobalSBCTATradeBudgetSetup);
        // Clear(GlobalSBCTATradeBudget);
    end;

    // internal procedure InitializeGlobals(BillToCustomerNo: Code[20]; SellToCustomerNo: Code[20]; CustomerPostingGroup: Record "Customer Posting Group"; GlAccount: Code[20])
    // begin
    //     GlobalGLAccount := GlAccount;
    //     GlobalCustomerPostingGroup := CustomerPostingGroup;
    //     GlobalSellToCustomer := SellToCustomerNo;
    //     GlobalBillToCustomer := BillToCustomerNo;
    // end;

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

    var
        GlobalBound: Boolean;



        GlobalCUInstance: Codeunit "SBCTA Preview Posting Events";
        GlobalPostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        GlobalTempSBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry" temporary;

        // GlobalSBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
        GlobalProcessRemainingLedgerEntry: Boolean;

}