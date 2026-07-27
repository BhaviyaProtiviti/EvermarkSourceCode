/// <summary>
/// Codeunit SBCEDI Unapply EDI Inv (ID 50086).
/// </summary>
codeunit 50086 "SBCEDI Correct Invoice Events"
{

    SingleInstance = true;
    EventSubscriberInstance = Manual;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostUnApplyCustomerCommit', '', false, false)]
    local procedure OnBeforePostUnApplyCustomerCommit(var HideProgressWindow: Boolean; PreviewMode: Boolean; DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry"; DocNo: Code[20]; PostingDate: Date; CommitChanges: Boolean; var IsHandled: Boolean);
    begin
        Unbind(true);
        HideProgressWindow := true;
        CommitChanges := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DimensionManagement", 'OnBeforeCheckDimValuePosting', '', false, false)]
    local procedure OnBeforeCheckDimValuePosting(TableID: array[10] of Integer; No: array[10] of Code[20]; DimSetID: Integer; var IsChecked: Boolean; var IsHandled: Boolean; var DimensionSetEntry: Record "Dimension Set Entry")
    begin
        IsHandled := true;
        IsChecked := true;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnBeforeTestSalesInvoiceHeaderAmount', '', false, false)]
    local procedure OnBeforeTestSalesInvoiceHeaderAmount(var SalesInvoiceHeader: Record "Sales Invoice Header"; Cancelling: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := GlobalOptionAllowZeroDollarAmount;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeCheckAllowMultiplePostingGroups', '', false, false)]
    local procedure OnBeforeCheckAllowMultiplePostingGroups(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocInvLineOnAfterSetFilters', '', false, false)]
    // local procedure OnCopySalesDocInvLineOnAfterSetFilters(var ToSalesHeader: Record "Sales Header"; var FromSalesInvoiceHeader: Record "Sales Invoice Header"; var FromSalesInvoiceLine: Record "Sales Invoice Line"; var RecalculateLines: Boolean)
    // var
    //     NewUnitPrice: Decimal;
    // begin
    //     // Unbind(true);
    //     if FromSalesInvoiceLine.Type <> FromSalesInvoiceLine.Type::"Item" then
    //         exit;
    //     NewUnitPrice := GetUoMUnitPrice(FromSalesInvoiceHeader."Currency Code", FromSalesInvoiceLine."No.", FromSalesInvoiceLine."Unit of Measure");
    //     if NewUnitPrice = 0 then
    //         exit;
    //     FromSalesInvoiceLine.Validate() "Unit Price" := NewUnitPrice;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeInsertToSalesLine', '', false, false)]
    local procedure OnBeforeInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; FromDocType: Option; RecalcLines: Boolean; var ToSalesHeader: Record "Sales Header"; DocLineNo: Integer; var NextLineNo: Integer; RecalculateAmount: Boolean)
    var
        NewUnitPrice: Decimal;
    begin
        if ToSalesHeader."Document Type" <> ToSalesHeader."Document Type"::Order then
            exit;
        if GlobalFromCorrection then
            exit;
        if ToSalesLine.Type <> ToSalesLine.Type::"Item" then
            exit;
        NewUnitPrice := GetUoMUnitPrice(ToSalesHeader."Currency Code", ToSalesLine."No.", ToSalesLine."Unit of Measure Code");
        if NewUnitPrice = 0 then
            exit;
        if NewUnitPrice = FromSalesLine."Unit Price" then
            exit;
        ToSalesLine.Validate("Unit Price", NewUnitPrice);
        ToSalesLine.Validate("Line Discount %", Round(100 * (1 - (FromSalesLine."Unit Price" / ToSalesLine."Unit Price")), SBCEDIEventHelper.GetCurrency(ToSalesHeader."Currency Code")."Unit-Amount Rounding Precision"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnAfterCreateCopyDocument', '', false, false)]
    local procedure OnAfterCreateCopyDocument(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        if GlobalOptionDocumentPostingDate = 0D then
            exit;
        SalesHeader."Posting Date" := GlobalOptionDocumentPostingDate;
        SalesHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeIsDateNotAllowed', '', false, false)]
    local procedure OnBeforeIsDateNotAllowed(PostingDate: Date; SetupRecordID: RecordId; GenJnlBatch: Record "Gen. Journal Batch"; var DateIsNotAllowed: Boolean; var IsHandled: Boolean)
    var 
        UserSetupManagement: Codeunit "User Setup Management";
    begin
        if GlobalOptionDocumentPostingDate = 0D then
            exit;
       IsHandled := UserSetupManagement.IsPostingDateValidWithSetup(GlobalOptionDocumentPostingDate, SetupRecordID);
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
        Clear(GlobalFromCorrection);
        Clear(GlobalOptionAllowZeroDollarAmount);
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

    internal procedure GetUoMUnitPrice(CurrencyCode: Code[10]; ItemNo: Code[20]; TargetUoM: Code[10]) NewUnitPrice: Decimal
    var
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
    // Currency: Record Currency;
    begin
        ItemUnitofMeasure.SetRange("Item No.", ItemNo);
        ItemUnitofMeasure.SetRange(Code, TargetUoM);
        if ItemUnitofMeasure.IsEmpty() then
            exit;

        Item.SetRange("No.", ItemNo);
        if item.IsEmpty() then
            exit;

        Item.SetLoadFields("Unit Price");
        Item.FindFirst();
        ItemUnitofMeasure.SetLoadFields("Qty. per Unit of Measure");
        ItemUnitofMeasure.FindFirst();

        NewUnitPrice := Round(Item."Unit Price" * ItemUnitofMeasure."Qty. per Unit of Measure", SBCEDIEventHelper.GetCurrency(CurrencyCode)."Unit-Amount Rounding Precision");
    end;

    // internal procedure GetCurrency(var CurrencyCode: Code[10]) Currency: Record Currency
    // begin
    //     if CurrencyCode = '' then
    //         Currency.InitRoundingPrecision()
    //     else begin
    //         Currency.SetRange("Code", CurrencyCode);
    //         Currency.SetLoadFields("Unit-Amount Rounding Precision");
    //         if not Currency.FindFirst() then
    //             Currency.InitRoundingPrecision();
    //     end;
    // end;

    internal procedure SetFromCorrection(FromCorrection: Boolean)
    begin
        GlobalFromCorrection := FromCorrection;
    end;

    internal procedure SetDocumentPostingDate(DocumentPostingDate: Date)
    begin
        GlobalOptionDocumentPostingDate := DocumentPostingDate;
    end;

    internal procedure SetAllowZeroDollarAmount(AllowZeroDollarAmount: Boolean)
    begin
        GlobalOptionAllowZeroDollarAmount := AllowZeroDollarAmount;
    end;


    var
        GlobalFromCorrection: Boolean;
        GlobalOptionAllowZeroDollarAmount: Boolean;
        GlobalCUInstance: Codeunit "SBCEDI Correct Invoice Events";
        GlobalBound: Boolean;
        SBCEDIEventHelper: Codeunit "SBCEDI Event Helper";
        GlobalOptionDocumentPostingDate: Date;
}