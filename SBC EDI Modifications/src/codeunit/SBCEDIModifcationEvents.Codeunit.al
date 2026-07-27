codeunit 50154 "SBC EDI Modifcation Events"
{

    #region processDocumentHeader

    // use for 945/810
    [EventSubscriber(ObjectType::Table, Database::"LAX EDI Receive Document Hdr.", 'OnBeforeProcessReceiveDoc', '', false, false)]
    local procedure LAXEDIReceiveDocHdrOnBeforeProcessReceiveDoc(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; Batch: Boolean; var IsHandled: Boolean)
    var
        SBCEDI945Helper: Codeunit "SBCEDI 945 Helper";
        SBCEDI810Helper: Codeunit "SBC EDI 810 Helper";
    begin
        if EDIRecDocHdr."EDI Document No." = '945' then
            SBCEDI945Helper.GetOrderLineInfo(EDIRecDocHdr."Internal Doc. No.");

        // if EDIRecDocHdr."EDI Document No." = '810' then
        //     SBCEDI810Helper.Run(EDIRecDocHdr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Sales Order", OnAfterMapSalesHdrFields, '', false, false)]
    local procedure LAXEDIUpdateSalesOrder_OnAfterMapSalesHdrFields(var SalesHeader: Record "Sales Header"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDITradePartner: Record "LAX EDI Trade Partner";
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        PostingDate: Date;
    begin
        if EDIRecDocHdr."EDI Document No." <> '810' then
            exit;

        LAXEDITradePartner.Reset();
        if not LAXEDITradePartner.Get(EDIRecDocHdr."Trade Partner No.") then
            exit;

        if LAXEDITradePartner."SBC RecDoc PostDate Field Name" = '' then
            PostingDate := WorkDate()
        else begin
            LAXEDIReceiveDocumentField.Reset();
            LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            LAXEDIReceiveDocumentField.SetRange("Field Name", LAXEDITradePartner."SBC RecDoc PostDate Field Name");
            if LAXEDIReceiveDocumentField.FindFirst() then
                if LAXEDIReceiveDocumentField."Field Date Value" <> 0D then
                    PostingDate := LAXEDIReceiveDocumentField."Field Date Value"
                else
                    if LAXEDIReceiveDocumentField."Field Text Value" <> '' then
                        if not Evaluate(PostingDate, LAXEDIReceiveDocumentField."Field Text Value") then
                            exit;
        end;

        if PostingDate <> 0D then begin
            SalesHeader."Posting Date" := PostingDate;
            SalesHeader."VAT Reporting Date" := PostingDate;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", OnAfterMapPurchaseHdrFields, '', false, false)]
    local procedure LAXEDIUpdatePurchaseOrder_OnAfterMapSalesHdrFields(var PurchaseHeader: Record "Purchase Header"; EDIRecDocHdr: Record "LAX EDI Receive Document Field")
    var
        LAXEDITradePartner: Record "LAX EDI Trade Partner";
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        EDIRecDocHdrActual: Record "LAX EDI Receive Document Hdr.";
        PostingDate: Date;
    begin
        if not EDIRecDocHdrActual.Get(EDIRecDocHdr."Internal Doc. No.") then
            exit;

        if EDIRecDocHdrActual."EDI Document No." <> '810' then
            exit;

        LAXEDITradePartner.Reset();
        if not LAXEDITradePartner.Get(EDIRecDocHdrActual."Trade Partner No.") then
            exit;

        if LAXEDITradePartner."SBC RecDoc PostDate Field Name" = '' then
            PostingDate := WorkDate()
        else begin
            LAXEDIReceiveDocumentField.Reset();
            LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", EDIRecDocHdrActual."Internal Doc. No.");
            LAXEDIReceiveDocumentField.SetRange("Field Name", LAXEDITradePartner."SBC RecDoc PostDate Field Name");
            if LAXEDIReceiveDocumentField.FindFirst() then
                if LAXEDIReceiveDocumentField."Field Date Value" <> 0D then
                    PostingDate := LAXEDIReceiveDocumentField."Field Date Value"
                else
                    if LAXEDIReceiveDocumentField."Field Text Value" <> '' then
                        if not Evaluate(PostingDate, LAXEDIReceiveDocumentField."Field Text Value") then
                            exit;
        end;

        if PostingDate <> 0D then begin
            PurchaseHeader."Posting Date" := PostingDate;
            PurchaseHeader."VAT Reporting Date" := PostingDate;
        end;
    end;

    // use for 846
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeCreateJournalLine', '', false, false)]
    local procedure LAXEDIReceiveInvtAdviceOnBeforeCreateJournalLine(EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line"; var ItemJnlLine: Record "Item Journal Line"; var Quantity: Decimal; var PositiveAdj: Boolean; var Location: Code[10]; var IsHandled: Boolean)
    var
        SBCEDI846Helper: Codeunit "SBC EDI 846 Helper";
    begin
        //If available qty = 0 then will not allow create jnl entry
        //Function will update Quantity to not allow available qty to be less than 0;
        IsHandled := SBCEDI846Helper.NotAllowCreateJnlLine(EDIInventoryAdviceLine, Quantity, Location, PositiveAdj);
    end;

    #endregion processDocumentHeader

    #region postingItemJournal

    // use for 945/810
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure ItemJnlPostOnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean)
    var
        SBCEDICreateItemJnlHelper: Codeunit "SBC EDI Create Item Jnl Helper";
    begin
        HideDialog := SBCEDICreateItemJnlHelper.ItemJnlHideDialog(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name", ItemJournalLine."Document No.");
    end;

    #endregion postingItemJournal

    #region postingSalesShipment



    #endregion postingSalesShipment

    #region purchaseLine

    // Populate Original Order Qty when a new Purchase Line is created
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure PurchaseLineOnAfterInsert(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if RunTrigger then
            UpdateOriginalOrderQty(Rec);
    end;

    // Populate Original Order Qty when Quantity is validated for the first time
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure PurchaseLineOnAfterValidateQuantity(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchLineCheck: Record "Purchase Line";
    begin
        if Rec.IsTemporary() then
            exit;

        // Only set Original Order Qty if it's currently 0 and Quantity is being set
        // Also verify the record exists in the database (it may not during Req. Wksh.-Make Order line creation)
        if (Rec."SBC Original Order Qty." = 0) and (Rec.Quantity <> 0) then
            if PurchLineCheck.Get(Rec."Document Type", Rec."Document No.", Rec."Line No.") then
                UpdateOriginalOrderQty(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterFinalizeOrderHeader', '', true, true)]
    local procedure ReqWkshMakeOrder_OnAfterFinalizeOrderHeader(var PurchHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine."SBC Original Order Qty." = 0 then begin
                    PurchaseLine."SBC Original Order Qty." := PurchaseLine.Quantity;
                    if not PurchaseLine.Modify() then;
                end;
            until PurchaseLine.Next() = 0;
    end;

    // Populate Original Approved Qty when Purchase Order is Approved for the first time (status changes from Pending Approval to Released)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure OnBeforeReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
        if PreviewMode then
            exit;

        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;

        // Only populate on first approval (when status is currently Pending Approval and will change to Released)
        if PurchaseHeader.Status <> PurchaseHeader.Status::"Pending Approval" then
            exit;

        PopulateOriginalApprovedQty(PurchaseHeader);
    end;

    local procedure PopulateOriginalApprovedQty(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        // Update all lines that don't have Original Approved Qty set yet
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("SBC Original Approved Qty.", 0);
        PurchaseLine.SetFilter(Quantity, '<>%1', 0);

        if PurchaseLine.FindSet(true) then
            repeat
                PurchaseLine."SBC Original Approved Qty." := PurchaseLine.Quantity;
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;

    local procedure UpdateOriginalOrderQty(var PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseLine.Type <> PurchaseLine.Type::Item then
            exit;

        if PurchaseLine.Quantity = 0 then
            exit;

        PurchaseLine."SBC Original Order Qty." := PurchaseLine.Quantity;
        PurchaseLine.Modify(false);
    end;

    #endregion purchaseLine

    #region CustomFieldMapping

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnAfterMapPurchaseLineFields', '', false, false)]
    procedure OnAfterMapPurchaseLineFields(var PurchaseLine: Record "Purchase Line"; EDIRecDocField: Record "LAX EDI Receive Document Field")
    var
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
    begin
        EDIRecDocFields.Reset();
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocField."Internal Doc. No.");
        EDIRecDocFields.SetRange(EDIRecDocFields."Table No.", Database::"Purchase Line");
        EDIRecDocFields.SetRange(EDIRecDocFields."Field No.", PurchaseLine.FieldNo("SBC EDI Received Qty"));
        if EDIRecDocFields.FindFirst() then
            PurchaseLine."SBC EDI Received Qty" := EDIRecDocFields."Field Dec. Value";
    end;
    #endregion CustomFieldMapping
}
