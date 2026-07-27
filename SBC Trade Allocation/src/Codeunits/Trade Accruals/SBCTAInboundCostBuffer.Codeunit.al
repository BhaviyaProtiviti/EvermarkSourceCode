/// <summary>
/// Codeunit SBCTA InboundCostBuffer (ID 50215).
/// </summary>
codeunit 50215 "SBCTA Inbound Cost Buffer"
{
    EventSubscriberInstance = manual;
    SingleInstance = true;


    [EventSubscriber(ObjectType::Table, Database::"Cost Element Buffer", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsert(var Rec: Record "Cost Element Buffer"; RunTrigger: Boolean)
    begin
        UpdateCostElementBuffer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cost Element Buffer", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModify(var Rec: Record "Cost Element Buffer"; RunTrigger: Boolean)
    begin
        UpdateCostElementBuffer(Rec);
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
        Clear(GlobalInboundItemLedgerEntryNo);
        Clear(GlobalTotalIndirectCost);
        Clear(GlobalTotalIndirectCostACY);
     
    end;

    /// <summary>
    /// This procedure removes the total cost from the start rather than trying to catch each entry.
    /// </summary>
    local procedure UpdateCostElementBuffer(var Rec: Record "Cost Element Buffer")
    begin
            Rec."Actual Cost" := Rec."Actual Cost" - GlobalTotalIndirectCost;
            Rec."Actual Cost (ACY)" := Rec."Actual Cost (ACY)" - GlobalTotalIndirectCostACY;
            Unbind(true);
            Rec.Modify();
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

    internal procedure SetInboundItemledgerEntryNo(InboundItemLedgerEntryNo: Integer)
    var
        InboundValueEntry: Record "Value Entry";
    begin
        GlobalInboundItemLedgerEntryNo := InboundItemLedgerEntryNo;
        InboundValueEntry.SetCurrentKey("Item Ledger Entry No.");
        InboundValueEntry.SetRange("Item Ledger Entry No.", GlobalInboundItemLedgerEntryNo);
        InboundValueEntry.SetLoadFields("Entry No.", "Entry Type", "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
        InboundValueEntry.SetRange("Entry Type","Cost Entry Type"::"Indirect Cost");
        if not InboundValueEntry.FindSet(false) then begin
            Unbind(true);
            exit;
        end;
        InboundValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
        GlobalTotalIndirectCost := InboundValueEntry."Cost Amount (Actual)";
        GlobalTotalIndirectCostACY := InboundValueEntry."Cost Amount (Actual) (ACY)";
    end;
    #endregion InstanceMethods

    var
        GlobalBound: Boolean;
        GlobalCUInstance: Codeunit "SBCTA Inbound Cost Buffer";
        GlobalInboundItemLedgerEntryNo: Integer;


        GlobalTotalIndirectCost: Decimal;
        GlobalTotalIndirectCostACY: Decimal;
}
