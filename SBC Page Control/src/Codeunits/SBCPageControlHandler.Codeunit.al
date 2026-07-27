/// <summary>
/// Codeunit SBC Page Control Handler (ID 50204).
/// </summary>
codeunit 50250 "SBC Page Control Handler"
{

    trigger OnRun()
    begin

    end;

    local procedure SetFiltersForUserId(var FilterRecordRef: RecordRef) FiltersFound: Boolean
    var
        SBCPCPageControl: Record "SBCPC Page Control";
    begin
        SBCPCPageControl.SetRange("User ID", UserId());
        SBCPCPageControl.SetRange("Table Number", FilterRecordRef.RecordId().TableNo());
        SBCPCPageControl.SetFilter("Field Number", '<>%1', 0);
        SBCPCPageControl.SetFilter("Field Filter", '<>%1', '');
        FiltersFound := not SBCPCPageControl.IsEmpty();
        if not FiltersFound then
            exit;

        FilterRecordRef.FilterGroup(-1);
        SBCPCPageControl.FindSet();
        repeat
            FilterRecordRef.Field(SBCPCPageControl."Field Number").SetFilter(SBCPCPageControl."Field Filter");
        until SBCPCPageControl.Next() = 0;
    end;

    internal procedure GetPurchaseHeaderFilters(var Rec: Record "Purchase Header")
    var
        FilterRecordRef: RecordRef;
    begin
        FilterRecordRef.GetTable(Rec);
        if not SetFiltersForUserId(FilterRecordRef) then
            exit;
        FilterRecordRef.SetTable(Rec);
        Rec.FilterGroup(FilterRecordRef.FilterGroup());
    end;


    local procedure GetPurchInvHeaderFilters(var Rec: Record "Purch. Inv. Header")
    var
        FilterRecordRef: RecordRef;
    begin
        FilterRecordRef.GetTable(Rec);
        if not SetFiltersForUserId(FilterRecordRef) then
            exit;
        FilterRecordRef.SetTable(Rec);
        Rec.FilterGroup(FilterRecordRef.FilterGroup());
    end;

    local procedure GetVendorFilters(var Rec: Record "Vendor")
    var
        FilterRecordRef: RecordRef;
    begin
        FilterRecordRef.GetTable(Rec);
        if not SetFiltersForUserId(FilterRecordRef) then
            exit;
        FilterRecordRef.SetTable(Rec);
        Rec.FilterGroup(FilterRecordRef.FilterGroup());
    end;

    #region Purchase Header Events 

    [EventSubscriber(ObjectType::Page, Page::"Purchase Document Entity", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseDocumentEntity(var Rec: Record "Purchase Header")
    var
        UserManagement: Codeunit "User Management";
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order Stats.", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseOrderStats(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Stats.", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseStats(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Purchase Order", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenBlanketPurchaseOrder(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Purchase Orders", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenBlanketPurchaseOrders(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Credit Memo", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseCreditMemo(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Credit Memos", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseCreditMemos(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseInvoice(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoices", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseInvoices(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase List", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseList(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseOrder(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseOrderList(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;


    [EventSubscriber(ObjectType::Page, Page::"Purchase Order Statistics", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseOrderStatistics(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quote", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseQuote(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quotes", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseQuotes(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Return Order", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseReturnOrder(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Return Order List", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseReturnOrderList(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Statistics", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseStatistics(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Doc. Check Factbox", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchDocCheckFactbox(var Rec: Record "Purchase Header")
    begin
        GetPurchaseHeaderFilters(Rec);
    end;


    #endregion Purchase Header Events

    #region Purchase Invoice Events

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice Stats.", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseInvoiceStats(var Rec: Record "Purch. Inv. Header")
    begin
        GetPurchInvHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Invoice API", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPostedPurchaseInvoiceAPI(var Rec: Record "Purch. Inv. Header")
    begin
        GetPurchInvHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Invoice", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPostedPurchaseInvoice(var Rec: Record "Purch. Inv. Header")
    begin
        GetPurchInvHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Invoices", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPostedPurchaseInvoices(var Rec: Record "Purch. Inv. Header")
    begin
        GetPurchInvHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purch. Invoice - Update", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPostedPurchInvoiceUpdate(var Rec: Record "Purch. Inv. Header")
    begin
        GetPurchInvHeaderFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice Statistics", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPurchaseInvoiceStatistics(var Rec: Record "Purch. Inv. Header")
    begin
        GetPurchInvHeaderFilters(Rec);
    end;

    #endregion Purchase Invoice Events 

    #region Vendor Events

    [EventSubscriber(ObjectType::Page, Page::"Office Vendor Details", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenOfficeVendorDetails(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor 1099 Statistics", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendor1099Statistics(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Workflow - Vendor Entity", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenWorkflowVendorEntity(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Aged Acc. Payable Chart", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenAgedAccPayableChart(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Purchase Document Lines", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenPostedPurchaseDocumentLines(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorCard(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Details FactBox", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorDetailsFactBox(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Entry Statistics", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorEntryStatistics(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Hist. Buy-from FactBox", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorHistBuyfromFactBox(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Hist. Pay-to FactBox", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorHistPaytoFactBox(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorList(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Lookup", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorLookup(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Picture", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorPicture(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Purchases", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorPurchases(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Statistics", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorStatistics(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Statistics FactBox", 'OnAfterGetRecordEvent', '', false, false)]
    local procedure OnOpenVendorStatisticsFactBox(var Rec: Record "Vendor")
    begin
        GetVendorFilters(Rec);
    end;

    #endregion Vendor Events
}