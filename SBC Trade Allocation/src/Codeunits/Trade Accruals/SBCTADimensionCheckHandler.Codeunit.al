/// <summary>
/// Codeunit SBCTA Dimension Check Handler (ID 50207).
/// </summary>
codeunit 50207 "SBCTA Dimension Check Handler"
{
    EventSubscriberInstance = manual;

    SingleInstance = true;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DimensionManagement", 'OnBeforeCheckDimValuePosting', '', false, false)]
    local procedure OnBeforeCheckDimValuePosting(TableID: array[10] of Integer; No: array[10] of Code[20]; DimSetID: Integer; var IsChecked: Boolean; var IsHandled: Boolean; var DimensionSetEntry: Record "Dimension Set Entry")
    begin
        Unbind(true);
        IsChecked := true;
        IsHandled := true;
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



    [EventSubscriber(ObjectType::Table, Database::"Error Message", OnAfterValidateEvent, "Context Record ID", false, false)]
    local procedure OnAfterValidateContextRecordId(CurrFieldNo: Integer; var Rec: Record "Error Message"; var xRec: Record "Error Message")
    begin
        if (xRec."Context Table Number" = Rec."Context Table Number") and not (Rec."Additional Information" in ['Preview mode.', 'Batch processing of Sales Header records.', 'Post document lines.']) then
            Unbind(true); // If this is reached, the transaction is over and the regular unbound pathway could not be reached.


    end;
    #endregion InstanceMethods

    var
        GlobalBound: Boolean;

        GlobalCUInstance: Codeunit "SBCTA Dimension Check Handler";

}