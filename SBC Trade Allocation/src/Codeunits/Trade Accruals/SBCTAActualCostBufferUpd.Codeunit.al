codeunit 50213 "SBCTA - Actual Cost Buffer Upd"
{
    EventSubscriberInstance = manual;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Adjustment Buffer", 'OnAddActualCostBufOnBeforeInsert', '', false, false)]
    local procedure OnAddActualCostBufOnBeforeInsert(var InventoryAdjustmentBuffer: Record "Inventory Adjustment Buffer"; ValueEntry: Record "Value Entry")
    begin
        InventoryAdjustmentBuffer."Cost Amount (Actual)" := GlobalAdjustedCostAmount;
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
        Clear(GlobalAdjustedCostAmount);
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

    internal procedure SetAdjustedCostAmount(AdjustedCostAmount: Decimal)
    begin
        GlobalAdjustedCostAmount := AdjustedCostAmount;
    end;
    #endregion InstanceMethods

    var
        GlobalBound: Boolean;
        GlobalCUInstance: Codeunit "SBCTA - Actual Cost Buffer Upd";
        GlobalAdjustedCostAmount: Decimal;
}