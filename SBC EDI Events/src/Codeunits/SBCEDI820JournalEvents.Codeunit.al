/// <summary>
/// Codeunit SBCEDI Journal Creation Events (ID 50083).
/// </summary>
codeunit 50083 "SBCEDI 820 Journal Events"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeCheckConfirmDifferentCustomerAndBillToCustomer', '', false, false)]
    local procedure OnBeforeCheckConfirmDifferentCustomerAndBillToCustomer(var GenJorunalLine: Record "Gen. Journal Line"; Customer: Record Customer; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
        Unbind();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeCheckConfirmDifferentVendorAndPayToVendor', '', false, false)]
    local procedure OnBeforeCheckConfirmDifferentVendorAndPayToVendor(var GenJorunalLine: Record "Gen. Journal Line"; Vendor: Record Vendor; CallingFieldNo: Integer; var IsHandled: Boolean)
    begin
        Unbind();
        IsHandled := true;
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

        if not UnbindSubscription(GlobalSBCEDIJournalCreationEvents) then
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
        GlobalBound := BindSubscription(GlobalSBCEDIJournalCreationEvents);
    end;

    var
        GlobalBound: Boolean;
        GlobalSBCEDIJournalCreationEvents: Codeunit "SBCEDI 820 Journal Events";

}