codeunit 50214 "SBCTA Corrective Invoice Event"
{

    EventSubscriberInstance = manual;
    SingleInstance = true;

    /// <summary>
    /// Activating this codeunit causes the document date to be used during indirect cost posting instead of the document date.
    /// </summary>
    /// <param name="GlobalUseDocumentDate">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBCTA Item Events", OnBeforeSetBudgetDate, '', false, false)]
    local procedure OnBeforeSetBudgetDate(var GlobalUseDocumentDate: Boolean)
    begin
        GlobalUseDocumentDate := true;
        // Unbind(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", OnOnRunOnAfterUpdateSalesOrderLinesFromCancelledInvoice, '', false, false)]

    local procedure OnOnRunOnAfterUpdateSalesOrderLinesFromCancelledInvoice(var Rec: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header")
    begin
        Unbind(true);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Batch Post Sales Orders", OnAfterSalesBatchPostMgt, '', false, false)]
    local procedure OnAfterSalesBatchPostMgt(var SalesHeader: Record "Sales Header"; var SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.")
    begin
        Unbind(true);
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

    internal procedure Unbind(Force: Boolean)
    begin
        if not Force then
            if not IsBound() then
                exit;

        if not UnbindSubscription(GlobalCUInstance) then
            if not Force then
                exit;
        if not Force then
            exit;
        ClearGlobals();
    end;

    local procedure ClearGlobals()
    begin
        Clear(GlobalBound);
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

    var
        GlobalBound: Boolean;
        GlobalCUInstance: Codeunit "SBCTA Corrective Invoice Event";

}