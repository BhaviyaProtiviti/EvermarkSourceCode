codeunit 50037 "SBC Sell-To Posting Handler"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    #region InstanceMethods
    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnAfterValidateEvent, "Context Field Number", false, false)]
    local procedure OnAfterValidateContextRecordId(CurrFieldNo: Integer; var Rec: Record "Error Message"; var xRec: Record "Error Message")
    begin
        if Rec."Context Field Number" = 0 then
            exit;
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
        Clear(GlobalSellToCustomer);
        // Clear(GlobalIndirectRate);
        // Clear(GlobalIndirectAccount);
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
    #endregion InstanceMethods
    internal procedure SetSellToCustomer(SellToCustomer: Record Customer)
    begin
        GlobalSellToCustomer := SellToCustomer;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostSalesLineOnBeforePostSalesLine, '', false, false)]
    local procedure OnPostSalesLineOnBeforePostSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; GenJnlLineDocNo: Code[20]; GenJnlLineExtDocNo: Code[35]; GenJnlLineDocType: Enum "Gen. Journal Document Type"; SrcCode: Code[10]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean)
    begin
        UseSellToPosting(GlobalSellToCustomer, SalesLine);
    end;

    internal procedure UseSellToPosting(SellToCustomer: Record "Customer"; var SalesLine: Record "Sales Line")
    begin
        SalesLine."Gen. Bus. Posting Group" := SellToCustomer."Gen. Bus. Posting Group"; // This does not need to modify the line, we only need to change the value in memory for this to work.S
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterFinalizePostingOnBeforeCommit, '', false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var EverythingInvoiced: Boolean)
    begin
        Unbind(true);
    end;

    var
        GlobalCUInstance: Codeunit "SBC Sell-To Posting Handler";
        GlobalSellToCustomer: Record Customer;
        GlobalBound: Boolean;
}