/// <summary>
/// This single instance codeunit will be used with an event manager that toggles it on or off if certain criteria are met. This toggling allows for further events in the sales process to be handled by the activated codeunit.
/// </summary>
codeunit 50087 "SBCEDI Sales Event Handler"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", 'OnBeforeModifySalesHeader', '', false, false)]
    local procedure OnBeforeModifySalesHeader(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        SetSellToPostingGroups(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeRecreateSalesLinesHandler', '', false, false)]
    local procedure OnBeforeRecreateSalesLinesHandler(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; ChangedFieldName: Text[100]; var IsHandled: Boolean)
    begin
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
        Clear(GlobalSellToCustomer)
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
        if (xRec."Context Table Number" = Rec."Context Table Number") and (Rec."Additional Information" <> 'Preview mode.') then
            Unbind(true); // If this is reached, the transaction is over and the regular unbound pathway could not be reached.
    end;
    #endregion InstanceMethods

    #region Setters

    internal procedure SetSellToCustomerNo(SellToCustomerNo: Code[20])
    begin
        // Search against the Customer No. and the Emerson Customer No.
        GlobalSellToCustomer.FilterGroup(-1);
        GlobalSellToCustomer.SetRange("No.", SellToCustomerNo);
        GlobalSellToCustomer.SetRange("SBC Emerson Customer No.", SellToCustomerNo);
        GlobalSellToCustomer.SetLoadFields("No.", "Gen. Bus. Posting Group", "Customer Posting Group");
        if GlobalSellToCustomer.FindFirst() then
            exit;

        Unbind(true); // If the customer cannot be found, then Clear Globals and unbind.
    end;

    /// <summary>
    /// Set the SellToCustomerPostingGroup on the Sales Header. This is used to set the Gen. Bus. Posting Group and Customer Posting Group on the Sales Header.
    /// </summary>
    /// <param name="SalesHeader"></param>
    internal procedure SetSellToPostingGroups(var SalesHeader: Record "Sales Header")
    var
        PreviousHideValidationDialog: Boolean;
        GBPMatch: Boolean;
        CPGMatch: Boolean;
    begin
        Unbind();
        if GlobalSellToCustomer."No." = '' then
            exit;
        GBPMatch := SalesHeader."Gen. Bus. Posting Group" = GlobalSellToCustomer."Gen. Bus. Posting Group";
        CPGMatch := SalesHeader."Customer Posting Group" = GlobalSellToCustomer."Customer Posting Group";
        if GBPMatch and CPGMatch then
            exit;

        PreviousHideValidationDialog := SalesHeader.GetHideValidationDialog();
        Bind(); // This bind is added so that when the logic in this event is called outside of an event subscription, it does not allow the sales lines to be overwitten to change the posting groups on the header.
        if not PreviousHideValidationDialog then
            SalesHeader.SetHideValidationDialog(true);
        if not GBPMatch then
            SalesHeader.Validate("Gen. Bus. Posting Group", GlobalSellToCustomer."Gen. Bus. Posting Group");
        if not CPGMatch then
            SalesHeader.Validate("Customer Posting Group", GlobalSellToCustomer."Customer Posting Group");
        if not PreviousHideValidationDialog then
            SalesHeader.SetHideValidationDialog(false);
        Unbind();
        ClearGlobals();
    end;

    /// <summary>
    /// This procedure is used to set the GlobalSellToCustomerValue outside of the event binding logic.
    /// </summary>
    /// <param name="Customer"></param>
    internal procedure SetSellToCustomer(Customer: Record Customer)
    begin
        GlobalSellToCustomer := Customer;
    end;

    #endregion Setters
    var
        GlobalBound: Boolean;
        GlobalSellToCustomer: Record Customer;
        GlobalCUInstance: Codeunit "SBCEDI Sales Event Handler";
}