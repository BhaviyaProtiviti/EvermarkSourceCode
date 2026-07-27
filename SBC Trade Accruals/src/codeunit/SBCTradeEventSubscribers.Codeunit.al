codeunit 50700 SBCTradeEventSubscribers
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", OnAfterInitFromSalesLine, '', false, false)]
    local procedure "Sales Invoice Line_OnAfterInitFromSalesLine"(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    begin
        SBCTradeAccrualManagement.ProcessSalesLine(SalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    begin
        SBCTradeAccrualManagement.ProcessJournalBatch(SalesHeader, SalesInvHdrNo);
        SBCInboundCostManagement.ProcessJournalBatch();
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesShptLineInsert, '', false, false)]
    // local procedure "Sales-Post_OnAfterSalesShptLineInsert"(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line"; ItemShptLedEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; SalesInvoiceHeader: Record "Sales Invoice Header"; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header")
    // begin
    //     SBCInboundCostManagement.ProcessShipmentLine(SalesShipmentLine, ItemShptLedEntryNo);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesInvLineInsert, '', false, false)]
    local procedure "Sales-Post_OnAfterSalesInvLineInsert"(var SalesInvLine: Record "Sales Invoice Line"; ItemLedgShptEntryNo: Integer)
    begin
        SBCInboundCostManagement.ProcessInvoiceLine(SalesInvLine, ItemLedgShptEntryNo);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesCrMemoLineInsert, '', false, false)]
    // local procedure "Sales-Post_OnAfterSalesCrMemoLineInsert"(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; ItemLedgShptEntryNo: Integer)
    // begin
    //     SBCInboundCostManagement.ProcessCrMemoLine(SalesCrMemoLine, ItemLedgShptEntryNo);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchRcptLineInsert, '', false, false)]
    local procedure "Purch.-Post_OnAfterPurchRcptLineInsert"(PurchaseLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchInvHeader: Record "Purch. Inv. Header"; var TempTrackingSpecification: Record "Tracking Specification" temporary; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header"; xPurchLine: Record "Purchase Line"; var TempPurchLineGlobal: Record "Purchase Line" temporary)
    begin
        SBCInboundCostManagement.ProcessReceiptLine(PurchRcptLine, ItemLedgShptEntryNo);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchCrMemoLineInsert, '', false, false)]
    // local procedure "Purch.-Post_OnAfterPurchCrMemoLineInsert"(var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; ItemLedgEntryNo: Integer)
    // begin
    //     SBCInboundCostManagement.ProcessCrMemoLine(PurchCrMemoLine, ItemLedgEntryNo);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure "Purch.-Post_OnAfterPostPurchaseDoc"(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    begin
        SBCInboundCostManagement.ProcessJournalBatch();
    end;

    var
        SBCTradeAccrualManagement: Codeunit "SBC Trade Accrual Management";
        SBCInboundCostManagement: Codeunit SBCInboundCostManagement;

}