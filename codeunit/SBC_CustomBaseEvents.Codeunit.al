Codeunit 50103 "Custom Base Events"
{
    Permissions = tabledata "Posted Approval Entry" = RM, tabledata "G/L Entry" = RM, tabledata "Approval Entry" = RM, tabledata "Item Ledger Entry" = RMID, tabledata "Purchases & Payables Setup" = R;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterValidateItemCategoryCode, '', false, false)]
    local procedure SBC_UpdateDimensionsFromItemCategory(xItem: Record Item; var Item: Record Item)
    var
        defaultDimension: Record "Default Dimension";
        GenLedgSetup: Record "General Ledger Setup";
        ItemCategory: Record "Item Category";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        TransferLine: Record "Transfer Line";
        UpdateLine: Boolean;
    begin

        if ItemCategory.get(Item."Item Category Code") and (ItemCategory."SBC Default Brand Dimension" <> '') then begin
            GenLedgSetup.get();
            GenLedgSetup.TestField("Shortcut Dimension 1 Code");
            if defaultDimension.get(27, Item."No.", GenLedgSetup."Shortcut Dimension 1 Code") then begin
                if defaultDimension."Dimension Value Code" <> ItemCategory."SBC Default Brand Dimension" then begin
                    defaultDimension.Validate("Dimension Value Code", ItemCategory."SBC Default Brand Dimension");
                    defaultDimension.Validate("Value Posting", defaultDimension."Value Posting"::"Code Mandatory");
                    defaultDimension.modify();
                end
            end else begin
                defaultDimension.init();
                defaultDimension."Table ID" := 27;
                defaultDimension.Validate("No.", Item."No.");
                defaultDimension.Validate("Dimension Code", GenLedgSetup."Shortcut Dimension 1 Code");
                defaultDimension.Validate("Dimension Value Code", ItemCategory."SBC Default Brand Dimension");
                defaultDimension.Validate("Value Posting", defaultDimension."Value Posting"::"Code Mandatory");
                defaultDimension.insert();
            end;

            SalesLine.SetFilter("Document Type", '%1|%2', SalesLine."Document Type"::Order, SalesLine."Document Type"::Quote);
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            Salesline.SetRange("No.", Item."No.");
            Salesline.SetRange("Quantity Shipped", 0);
            if SalesLine.findset() then
                repeat
                    UpdateLine := false;
                    if SalesLine."Shortcut Dimension 1 Code" = '' then begin
                        SalesLine.Validate("Shortcut Dimension 1 Code", ItemCategory."SBC Default Brand Dimension");
                        UpdateLine := true;
                    end;
                    if SalesLine."Shortcut Dimension 2 Code" = '' then begin
                        SalesLine.Validate("Shortcut Dimension 2 Code", 'USA');
                        UpdateLine := true;
                    end;
                    if SalesLine."Item Category Code" = '' then begin
                        SalesLine.Validate("Item Category Code", Item."Item Category Code");
                        UpdateLine := true;
                    end;
                    if UpdateLine then
                        SalesLine.modify(false);
                    UpdateLine := false;
                until SalesLine.Next() = 0;

            PurchLine.SetFilter("Document Type", '%1|%2', PurchLine."Document Type"::Order, PurchLine."Document Type"::Quote);
            PurchLine.SetRange(Type, SalesLine.Type::Item);
            PurchLine.SetRange("No.", Item."No.");
            Purchline.SetRange("Quantity Received", 0);
            if PurchLine.findset() then
                repeat
                    UpdateLine := false;
                    if PurchLine."Shortcut Dimension 1 Code" = '' then begin
                        PurchLine.Validate("Shortcut Dimension 1 Code", ItemCategory."SBC Default Brand Dimension");
                        UpdateLine := true;
                    end;
                    if PurchLine."Shortcut Dimension 2 Code" = '' then begin
                        PurchLine.Validate("Shortcut Dimension 2 Code", 'USA');
                        UpdateLine := true;
                    end;
                    if PurchLine."Item Category Code" = '' then begin
                        PurchLine.Validate("Item Category Code", Item."Item Category Code");
                        UpdateLine := true;
                    end;
                    if UpdateLine then
                        PurchLine.modify(false);
                    UpdateLine := false;
                until PurchLine.Next() = 0;

            TransferLine.SetRange("Item No.", Item."No.");
            if TransferLine.findset() then
                repeat
                    UpdateLine := false;
                    if TransferLine."Shortcut Dimension 1 Code" = '' then begin
                        TransferLine.Validate("Shortcut Dimension 1 Code", ItemCategory."SBC Default Brand Dimension");
                        UpdateLine := true;
                    end;
                    if TransferLine."Shortcut Dimension 2 Code" = '' then begin
                        TransferLine.Validate("Shortcut Dimension 2 Code", 'USA');
                        UpdateLine := true;
                    end;
                    if TransferLine."Item Category Code" = '' then begin
                        TransferLine.Validate("Item Category Code", Item."Item Category Code");
                        UpdateLine := true;
                    end;
                    if UpdateLine then
                        TransferLine.modify(false);
                    UpdateLine := false;
                until TransferLine.Next() = 0;

            ItemJnlLine.SetRange("Item No.", Item."No.");
            if ItemJnlLine.findset() then
                repeat
                    UpdateLine := false;
                    if ItemJnlLine."Shortcut Dimension 1 Code" = '' then begin
                        ItemJnlLine.Validate("Shortcut Dimension 1 Code", ItemCategory."SBC Default Brand Dimension");
                        UpdateLine := true;
                    end;
                    if ItemJnlLine."Shortcut Dimension 2 Code" = '' then begin
                        ItemJnlLine.Validate("Shortcut Dimension 2 Code", 'USA');
                        UpdateLine := true;
                    end;
                    if ItemJnlLine."Item Category Code" = '' then begin
                        ItemJnlLine.Validate("Item Category Code", Item."Item Category Code");
                        UpdateLine := true;
                    end;
                    if UpdateLine then
                        ItemJnlLine.modify(false);
                    UpdateLine := false;
                until ItemJnlLine.Next() = 0;
        end;

        GenLedgSetup.get();
        GenLedgSetup.TestField("Shortcut Dimension 2 Code");

        if defaultDimension.get(27, Item."No.", GenLedgSetup."Shortcut Dimension 2 Code") then begin
            defaultDimension.Validate("Dimension Value Code", 'USA');
            defaultDimension.modify();
        end else begin
            defaultDimension.init();
            defaultDimension."Table ID" := 27;
            defaultDimension.Validate("No.", Item."No.");
            defaultDimension.Validate("Dimension Code", GenLedgSetup."Shortcut Dimension 2 Code");
            defaultDimension.Validate("Dimension Value Code", 'USA');
            defaultDimension.insert();
        end;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", OnAfterInsertEvent, '', false, false)]
    // local procedure ILEOnAfterInsert(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    // var
    //     SalesShipHeader: Record "Sales Shipment Header";
    //     PurchRcptHeader: Record "Purch. Rcpt. Header";
    // begin
    //     if NOT RunTrigger then
    //         exit;

    //     if Rec."Document Type" = Rec."Document Type"::"Sales Shipment" then begin
    //         SalesShipHeader.Get(rec."Document No.");
    //         rec."Order No." := SalesShipHeader."Order No.";
    //         rec.Modify(false)
    //     end else
    //         if Rec."Document Type" = Rec."Document Type"::"Purchase Receipt" then begin
    //             PurchRcptHeader.Get(Rec."Document No.");
    //             Rec."Order No." := PurchRcptHeader."Order No.";
    //             Rec.Modify(false);
    //         end;
    // end;

    /// <summary>
    /// ItemLedgerAddOrderNo.
    /// </summary>
    // procedure ItemLedgerAddOrderNo()
    // var
    //     ItemLedgerEntry: Record "Item Ledger Entry";
    // begin
    //     ItemLedgerEntry.SetRange("Order No.", '');
    //     ItemLedgerEntry.SetFilter("Entry Type", '%1|%2', ItemLedgerEntry."Entry Type"::Sale, ItemLedgerEntry."Entry Type"::Purchase);
    //     ItemLedgerEntry.SetFilter("Document Type", '%1|%2', ItemLedgerEntry."Document Type"::"Sales Shipment", ItemLedgerEntry."Document Type"::"Purchase Receipt");
    //     if ItemLedgerEntry.FindSet(true) then
    //         repeat
    //             ILEOnAfterInsert(ItemLedgerEntry, true);
    //         until ItemLedgerEntry.Next() = 0
    //     else
    //         Message('Nothing to update');
    // end;    
    #region purchPost

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnAfterPostInvoice', '', false, false)]
    local procedure PurchPostOnRunOnAfterPostInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var ReturnShipmentHeader: Record "Return Shipment Header"; GenJnlLineDocNo: Code[20]; GenJnlLineDocType: Enum "Gen. Journal Document Type"; SrcCode: Code[10]; var PreviewMode: Boolean; var Window: Dialog)
    begin
        if (PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order) or (PurchInvHeader."No." = '') then
            exit;

        UpdateProdOrder(PurchaseHeader."No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeFinalizePosting', '', false, false)]
    local procedure KeepPurchOrdersAfterInvoiced(var EverythingInvoiced: Boolean; var PurchaseHeader: Record "Purchase Header")
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;

        PurchSetup.Get();
        if not PurchSetup."SBC Never Delete PO's" then
            exit;

        // Check if PO contains any lines of type ITEM
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);

        if not PurchaseLine.IsEmpty() then
            EverythingInvoiced := false;
    end;

    #endregion purchPost

    #region purchVendorGroup

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateBuyFromVendorNo, '', false, false)]
    local procedure PurchaseHeader(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; CallingFieldNo: Integer; var SkipBuyFromContact: Boolean)
    begin
        PurchaseHeader."SBC Vendor Group Code" := GetVendorGroupCode(PurchaseHeader."Buy-from Vendor No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Buy-from Vendor No.", false, false)]
    local procedure PurchaseLineOnBeforeValidateEventBuyFromVendorNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        Rec."Buy-from Vendor No." := GetVendorGroupCode(Rec."Buy-from Vendor No.");
    end;

    local procedure GetVendorGroupCode(VendorNo: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then
            exit(Vendor."SBC Vendor Group Code");
    end;

    #endregion purchVendorGroup

    #region transferPost

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterTransferOrderPostShipment', '', false, false)]
    local procedure TransferOrderPostShipmentOnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; InvtPickPutaway: Boolean; CommitIsSuppressed: Boolean)
    begin
        UpdateProdOrder('', TransferHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterTransferOrderPostReceipt', '', false, false)]
    local procedure TransferOrderPostReceiptOnAfterTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header"; var TransferReceiptHeader: Record "Transfer Receipt Header"; CommitIsSuppressed: Boolean)
    begin
        UpdateProdOrder('', TransferHeader."No.");
    end;

    local procedure UpdateProdOrder(PurchOrderNo: Code[20]; TransferOrderNo: Code[20])
    var
        ProductionOrder: Record "Production Order";
    begin
        if PurchOrderNo <> '' then begin
            ProductionOrder.SetRange("SBC Subcontracting Purch.Order", PurchOrderNo);
            if ProductionOrder.FindFirst() then begin
                ProductionOrder."SBC Original Purch Order No." := PurchOrderNo;
                ProductionOrder.Modify(false);
                exit;
            end;
        end;

        if TransferOrderNo <> '' then begin
            ProductionOrder.SetRange("SBC Subcontracting Trans.Order", TransferOrderNo);
            ProductionOrder.SetRange("SBC Original Trans. Order No.", '');
            if ProductionOrder.FindFirst() then begin
                ProductionOrder."SBC Original Trans. Order No." := TransferOrderNo;
                ProductionOrder.Modify(false);
                exit;
            end;
        end;
    end;

    #endregion transferPost

    #region transferRelease

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Transfer Document", OnBeforeReleaseTransferDoc, '', false, false)]
    local procedure ReleaseTransferDocumentOnBeforeReleaseTransferDoc(var TransferHeader: Record "Transfer Header")
    var
        SBCSubcontracting: Codeunit "SBC Subcontracting";
    begin
        SBCSubcontracting.SplitTransferOrder(TransferHeader);
    end;

    #endregion transferRelease

    #region transferHeader

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", OnBeforeValidateEvent, 'Transfer-from Code', false, false)]
    local procedure TransferHeaderOnBeforeValidateEventTransferFromCode(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header"; CurrFieldNo: Integer)
    var
        Location: Record Location;
        IsHandled: Boolean;
    begin
        OnBeforeTransferHeaderOnBeforeValidateEventTransferFromCode(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        if Location.Get(Rec."Transfer-from Code") and (Location."SBC Has Max Weight Req.") then begin
            Rec."SBC Max Weight Req." := Location."SBC Has Max Weight Req.";
            Rec."SBC Max Weight Allowed" := Location."SBC Transfer Max Weight Allow";
        end;
    end;

    #endregion transferHeader

    #region transferLine

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnValidateQuantityOnBeforeTransLineVerifyChange, '', false, false)]
    local procedure TransferLineOnValidateQuantityOnBeforeTransLineVerifyChange(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    var
        SBCSubcontracting: Codeunit "SBC Subcontracting";
        SkipCalcMaxWeight: Boolean;
    begin
        OnBeforeTransferLinenValidateQuantityOnBeforeTransLineVerifyChange(TransferLine, xTransferLine, SkipCalcMaxWeight);
        if SkipCalcMaxWeight then
            exit;

        SBCSubcontracting.SetTransferLineWeight(TransferLine);
    end;

    #endregion transferLine

    #region releasedProdOrder

    // [EventSubscriber(ObjectType::Page, Page::"Released Production Order", OnAfterCreateTransferOrders, '', false, false)]
    // local procedure ReleasedProductionOrderOnAfterCreateTransferOrders(TransferHeader: Record "Transfer Header")
    // var
    //     SBCSubcontracting: Codeunit "SBC Subcontracting";
    //     TotalWeight: Decimal;
    //     IsHandled: Boolean;
    // begin
    //     OnBeforeReleasedProductionOrderOnAfterCreateTransferOrders(TransferHeader, IsHandled);
    //     if IsHandled then
    //         exit;

    //     if (TransferHeader."SBC Max Weight Req.") then begin
    //         TransferHeader.CalcFields("SBC Total Order Weight");
    //         if TransferHeader."SBC Total Order Weight" > TransferHeader."SBC Max Weight Allowed" then
    //             SBCSubcontracting.SplitTransferOrderByWeight(TransferHeader);
    //     end;
    // end;

    #endregion releasedProdOrder

    #region purchaseHeader

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnPrintRecordsOnBeforeTrySendToPrinterVendor, '', false, false)]
    local procedure PurchaseHeaderOnPrintRecordsOnBeforeTrySendToPrinterVendor(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        TestOrderStatus(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeSendRecords, '', false, false)]
    local procedure PurchaseHeaderOnBeforeSendRecords(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        TestOrderStatus(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", OnBeforeActionEvent, AttachAsPDF, false, false)]
    local procedure PurchaseOrderListOnBeforeActionEventAttachAsPDF(var Rec: Record "Purchase Header")
    begin
        TestOrderStatus(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", OnBeforeActionEvent, AttachAsPDF, false, false)]
    local procedure PurchaseOrderOnBeforeActionEventAttachAsPDF(var Rec: Record "Purchase Header")
    begin
        TestOrderStatus(Rec);
    end;

    local procedure TestOrderStatus(PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
            PurchaseHeader.TestField(Status, PurchaseHeader.Status::Released);
    end;

    #endregion purchaseHeader

    #region purchaseLine

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, 'Unit of Measure Code', false, false)]
    local procedure PurchaseLineOnBeforeValidateEventUnitofMeasureCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        SBCSubcontracting: Codeunit "SBC Subcontracting";
        IsHandled: Boolean;
    begin
        OnBeforeOnBeforeValidateEventUnitofMeasureCode(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;
        if (xRec."Unit of Measure Code" <> Rec."Unit of Measure Code") and (xRec."Unit of Measure Code" <> '') and (CurrFieldNo = Rec.FieldNo("Unit of Measure Code")) then
            SBCSubcontracting.UpdateReleasedProdOrder(Rec."Document No.", Rec."Prod. Order No.", Rec."Prod. Order Line No.", Rec."Unit of Measure Code");
    end;

    #endregion purchaseLine

    #region vendorPricing

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Price Calc. Mgt.", OnBeforePurchLinePriceExists, '', false, false)]
    local procedure PurchPriceCalcMgtOnBeforePurchLinePriceExists(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var TempPurchasePrice: Record "Purchase Price" temporary; ShowAll: Boolean; var DateCaption: Text[30]; var IsHandled: Boolean)
    var
        PurchasePrice: Record "Purchase Price";
        ParentVendor: Record Vendor;
    begin
        if PurchaseHeader."Pay-to Vendor No." = PurchaseHeader."Buy-from Vendor No." then
            exit;

        if ParentVendor.Get(PurchaseHeader."Pay-to Vendor No.") and ParentVendor."SBC Use Buy-From Pricing" then begin
            IsHandled := true;
            PurchasePrice.SetRange("Vendor No.", PurchaseHeader."Buy-from Vendor No.");
            PurchasePrice.SetRange("Item No.", PurchaseLine."No.");
            PurchasePrice.SetFilter("Ending Date", '%1|>=%2', 0D, PurchaseHeader."Posting Date");
            PurchasePrice.SetFilter("Variant Code", '%1|%2', '', PurchaseLine."Variant Code");
            if not ShowAll then begin
                PurchasePrice.SetFilter("Starting Date", '<=%1', PurchaseHeader."Posting Date");
                PurchasePrice.SetFilter("Currency Code", '%1|%2', PurchaseHeader."Currency Code", '');
                PurchasePrice.SetFilter("Unit of Measure Code", '%1|%2', PurchaseLine."Unit of Measure Code", '');
            end;

            if PurchasePrice.FindSet() then
                repeat
                    TempPurchasePrice := PurchasePrice;
                    TempPurchasePrice.Insert();
                until PurchasePrice.Next() = 0;
        end;
    end;

    #endregion vendorPricing

    #region salesHeader

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterInitDefaultDimensionSources, '', false, false)]
    local procedure SalesHeaderOnAfterInitDefaultDimensionSources(var SalesHeader: Record "Sales Header"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        if SalesHeader."Sell-to Customer No." <> SalesHeader."Bill-to Customer No." then begin
            OnBeforeSalesHeaderOnAfterInitDefaultDimensionSources(SalesHeader, IsHandled);
            if IsHandled then
                exit;

            Clear(DefaultDimSource);
            if FieldNo = SalesHeader.FieldNo("Bill-to Customer No.") then
                FieldNo := SalesHeader.FieldNo("Sell-to Customer No.");
            InitDefaultDimensionSources(SalesHeader, DefaultDimSource, FieldNo);
        end;
    end;

    local procedure InitDefaultDimensionSources(SalesHeader: Record "Sales Header"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    var
        DimMgt: Codeunit "DimensionManagement";
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::Customer, SalesHeader."Sell-to Customer No.", FieldNo = SalesHeader.FieldNo("Sell-to Customer No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", SalesHeader."Salesperson Code", FieldNo = SalesHeader.FieldNo("Salesperson Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Campaign, SalesHeader."Campaign No.", FieldNo = SalesHeader.FieldNo("Campaign No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", SalesHeader."Responsibility Center", FieldNo = SalesHeader.FieldNo("Responsibility Center"));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Customer Templ.", SalesHeader."Bill-to Customer Templ. Code", FieldNo = SalesHeader.FieldNo("Bill-to Customer Templ. Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, SalesHeader."Location Code", FieldNo = SalesHeader.FieldNo("Location Code"));
    end;



    #endregion salesHeader

    #region genJournal  

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeInsertEvent, '', false, false)]
    local procedure GenJournalLineOnAfterInsertEvent(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        IncomingDocAttachFactBox: page "Incoming Doc. Attach. FactBox";
    begin
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        GenJournalLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
        GenJournalLine.SetFilter("Incoming Document Entry No.", '<>%1', 0);
        if GenJournalLine.FindFirst() then
            Rec."Incoming Document Entry No." := GenJournalLine."Incoming Document Entry No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeOnDelete, '', false, false)]
    local procedure GenJournalLineOnBeforeOnDelete(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
        IncomingDocument: Record "Incoming Document";
    begin
        if GenJournalLine."Incoming Document Entry No." <> 0 then begin
            GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            GenJnlLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
            GenJnlLine.SetFilter("Incoming Document Entry No.", '<>%1', 0);
            if GenJnlLine.IsEmpty() then begin
                if (IncomingDocument.Get(GenJournalLine."Incoming Document Entry No.")) and (incomingDocument.Status <> IncomingDocument.Status::Posted) then
                    IncomingDocument.Delete(true);
            end;
        end
    end;

    #endregion genJournal    

    #region incomingDocument

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", OnBeforeModifyEvent, '', false, false)]
    local procedure IncomingDocumentOnBeforeModifyEvent(var Rec: Record "Incoming Document"; var xRec: Record "Incoming Document"; RunTrigger: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if (Rec."Document Type" = Rec."Document Type"::Journal) and (Rec.Status = Rec.Status::Created) and (Rec."Related Record ID".TableNo = 81) then
            if GenJournalLine.Get(Rec."Related Record ID") then
                if GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name") then
                    Rec."Related Record ID" := GenJournalBatch.RecordId;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Import Attachment - Inc. Doc.", OnAfterImportAttachment, '', false, false)]
    local procedure ImportAttachmentIncDocOnAfterImportAttachment(var IncomingDocumentAttachment: Record "Incoming Document Attachment")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        IncomingDocument: Record "Incoming Document";
        IsHandled: Boolean;
    begin
        OnBeforeImportAttachmentIncDocOnAfterImportAttachment(IncomingDocumentAttachment, IsHandled);
        if IsHandled then
            exit;

        if (IncomingDocument.Get(IncomingDocumentAttachment."Incoming Document Entry No.")) and (IncomingDocument."Related Record ID".TableNo = Database::"Gen. Journal Batch") then begin
            GenJournalBatch.Get(IncomingDocument."Related Record ID");
            GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
            GenJournalLine.SetRange("Incoming Document Entry No.", 0);
            GenJournalLine.ModifyAll("Incoming Document Entry No.", IncomingDocument."Entry No.", false);
        end;
    end;

    #endregion incomingDocument

    #region genPost

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInsertGlobalGLEntry, '', false, false)]
    local procedure GenJnlPostLineOnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register")
    begin
        GlobalGLEntry."SBC Incoming Doc No." := genJournalLine."Incoming Document Entry No.";
    end;

    #endregion genPost  

    #region lotcodeparsing

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", OnAfterValidateEvent, "Lot No.", false, false)]
    local procedure "Tracking Specification_OnAfterValidate"(var Rec: Record "Tracking Specification")
    var
        ELBLotCodeparsingManagement: Codeunit ELBLotCodeparsingManagement;
    begin
        ELBLotCodeparsingManagement.ProcessTrackingSpecification(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterValidateEvent, "SBC Shelf Life (Days)", false, false)]
    local procedure "Item_SBC Shelf Life (Days)_OnAfterValidate"(var Rec: Record Item)
    var
        ELBLotCodeparsingManagement: Codeunit ELBLotCodeparsingManagement;
    begin
        ELBLotCodeparsingManagement.ProcessAjustmentItemJournalLines(Rec."No.", Rec."SBC Shelf Life (Days)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", OnAfterValidateEvent, "Lot No.", false, false)]
    local procedure "Item Jounral Line_OnAfterValidate"(var Rec: Record "Item Journal Line")
    var
        ELBLotCodeparsingManagement: Codeunit ELBLotCodeparsingManagement;
    begin
        ELBLotCodeparsingManagement.ProcessTrackingSpecification(Rec);
    end;

    #endregion lotcodeparsing

    #region Customer

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, Name, false, false)]
    local procedure Customer_OnAfterValidate_Name(var Rec: Record Customer)
    begin
        SetCustomerDimension(Rec."No.", Rec.Name);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterRenameEvent, '', false, false)]
    local procedure Customer_OnAfterRename(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."No." <> xRec."No." then
            SetCustomerDimension(Rec."No.", Rec.Name);
    end;

    local procedure SetCustomerDimension(CustomerNo: Code[20]; CustomerName: Text[100])
    var
        SalesSetup: Record "Sales & Receivables Setup";
        CustomerDimensionCode: Code[20];
    begin
        SalesSetup.Get();

        CustomerDimensionCode := SalesSetup."SBC Customer Dimension Code";

        if InsertCustomerDimVal(CustomerNo, CustomerName, CustomerDimensionCode) then
            SetCustomerDefaultDim(CustomerNo, CustomerDimensionCode);
    end;

    local procedure InsertCustomerDimVal(CustomerNo: Code[20]; CustomerName: Text[100]; CustDim: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        if not DimensionValue.Get(CustDim, CustomerNo) then begin
            DimensionValue.Init();
            DimensionValue.Validate("Dimension Code", CustDim);
            DimensionValue.Validate(Code, CustomerNo);
            DimensionValue.Validate(Name, CustomerName);
            DimensionValue.Insert();
            exit(true);
        end
        else begin
            if DimensionValue.Name <> CustomerName then begin
                DimensionValue.Validate(Name, CustomerName);
                DimensionValue.Modify();
            end;
        end;

        exit(false);
    end;

    local procedure SetCustomerDefaultDim(CustomerNo: Code[20]; CustDim: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DefaultDimension.Get(Database::Customer, CustomerNo, CustDim) then begin
            if DefaultDimension."Dimension Value Code" <> CustomerNo then begin
                DefaultDimension.Validate("Dimension Value Code", CustomerNo);
                DefaultDimension.Modify();
            end;
        end
        else begin
            DefaultDimension.Init();
            DefaultDimension.Validate("Table ID", Database::Customer);
            DefaultDimension.Validate("No.", CustomerNo);
            DefaultDimension.Validate("Dimension Code", CustDim);
            DefaultDimension.Validate("Dimension Value Code", CustomerNo);
            DefaultDimension.Insert();
        end;
    end;

    #endregion Customer

    procedure CheckPO(var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        PurchasesSetup: Record "Purchases & Payables Setup";
    begin
        if not PurchasesSetup.Get() then
            exit;

        if not PurchasesSetup."SBC Require Purch. Price" then
            exit;

        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        if PurchLine.IsEmpty() then
            exit;
        PurchLine.FindSet();
        repeat
            CheckPOLines(PurchLine);
        until PurchLine.Next() = 0;
    end;

    procedure CheckPOLines(var PurchLine: Record "Purchase Line")
    var
        PurchPrice: Record "Purchase Price";
    begin
        PurchPrice.SetFilter("Vendor No.", PurchLine."Buy-from Vendor No.");
        PurchPrice.SetFilter("Item No.", PurchLine."No.");
        PurchPrice.SetAscending("Starting Date", false);
        if PurchPrice.IsEmpty then
            Error('No Purchase Price for Item %1', PurchLine."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", OnBeforeReleasePurchaseDoc, '', false, false)]
    local procedure "Release Purchase Document_OnBeforeReleasePurchaseDoc"(var PurchaseHeader: Record "Purchase Header")
    begin
        CheckPO(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateEvent, "No.", false, false)]
    local procedure "Purchase Line_OnAfterValidateNoPurchaseLine"(var Rec: Record "Purchase Line")
    begin
        GetHeaderForPurchPriceCheck(Rec, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateLocationCode, '', false, false)]
    local procedure PurchaseLine_OnAfterValidateLocationCode(var PurchaseLine: Record "Purchase Line")
    begin
        GetHeaderForPurchPriceCheck(PurchaseLine, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateEvent, Quantity, false, false)]
    local procedure PurchaseLine_OnAfterValidate_Quantity(var Rec: Record "Purchase Line")
    begin
        GetHeaderForPurchPriceCheck(Rec, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnAfterValidateEvent, "Shipment Method Code", false, false)]
    local procedure PurchaseHeader_OnAfterValidate_ShipmentMethodCode(var Rec: Record "Purchase Header")
    begin
        GetLinesForPurchPriceCheck(Rec, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Price", OnAfterRenameEvent, '', false, false)]
    local procedure PurchasePrice_OnAfterModify(var xRec: Record "Purchase Price")
    begin
        DeleteLocShipMethodLines(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Price", OnBeforeDeleteEvent, '', false, false)]
    local procedure PurchasePrice_OnBeforeDelete(var Rec: Record "Purchase Price")
    begin
        DeleteLocShipMethodLines(Rec);
    end;

    local procedure GetHeaderForPurchPriceCheck(var PurchaseLine: Record "Purchase Line"; ModifyRec: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        DocReleaseHolder: List of [Code[20]];
    begin
        if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            CheckPurchPriceFromFilters(PurchaseLine, PurchaseHeader, DocReleaseHolder, ModifyRec);
    end;

    local procedure GetLinesForPurchPriceCheck(PurchaseHeader: Record "Purchase Header"; ModifyRec: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        DocReleaseHolder: List of [Code[20]];
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");

        if PurchaseLine.FindSet() then
            repeat
                CheckPurchPriceFromFilters(PurchaseLine, PurchaseHeader, DocReleaseHolder, ModifyRec);
            until PurchaseLine.Next() = 0;
    end;

    local procedure CheckPurchPriceFromFilters(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; DocsToRelease: List of [Code[20]]; ModifyRec: Boolean)
    var
        SBCPurchPriceLocShipmMethod: Record "SBCPurchPriceLoc/ShipmMethod";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasePrice: Record "Purchase Price";
    begin
        if PurchaseLine.Type <> PurchaseLine.Type::Item then
            exit;

        GetPurchPriceRec(PurchasePrice, PurchaseLine);
        if not PurchasePrice.FindFirst() then
            exit;

        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."SBC Use Location Pricing" then begin
            SetLocationAndShipMethodFilters(SBCPurchPriceLocShipmMethod, PurchaseLine, PurchaseLine."Location Code", PurchaseHeader."Shipment Method Code", PurchasePrice."Starting Date", PurchasePrice."Minimum Quantity");
            if SBCPurchPriceLocShipmMethod.IsEmpty then begin
                SetLocationAndShipMethodFilters(SBCPurchPriceLocShipmMethod, PurchaseLine, PurchaseLine."Location Code", '', PurchasePrice."Starting Date", PurchasePrice."Minimum Quantity");
                if SBCPurchPriceLocShipmMethod.IsEmpty then
                    SetLocationAndShipMethodFilters(SBCPurchPriceLocShipmMethod, PurchaseLine, '', PurchaseHeader."Shipment Method Code", PurchasePrice."Starting Date", PurchasePrice."Minimum Quantity");
            end;

            if SBCPurchPriceLocShipmMethod.FindFirst() then
                SetUnitCostFromVendorPurchPrice(PurchaseLine, SBCPurchPriceLocShipmMethod."Direct Unit Cost", DocsToRelease, ModifyRec)
            else
                UseDefaultVendorPurchPrice(PurchaseLine, DocsToRelease, ModifyRec);

        end else
            UseDefaultVendorPurchPrice(PurchaseLine, DocsToRelease, ModifyRec);
    end;

    local procedure UseDefaultVendorPurchPrice(var PurchaseLine: Record "Purchase Line"; DocsToRelease: List of [Code[20]]; ModifyRec: Boolean)
    var
        PurchPrice: Record "Purchase Price";
    begin
        GetPurchPriceRec(PurchPrice, PurchaseLine);
        if PurchPrice.FindFirst() then begin
            SetUnitCostFromVendorPurchPrice(PurchaseLine, PurchPrice."Direct Unit Cost", DocsToRelease, ModifyRec);
        end;
    end;

    local procedure OpenPurchaseHeader(PurchaseLine: Record "Purchase Line"; DocsToRelease: List of [Code[20]])
    var
        PurchaseHeader: Record "Purchase Header";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        if DocsToRelease.Contains(PurchaseLine."Document No.") then
            exit;

        PurchaseHeader.Reset();
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if PurchaseHeader.Status = PurchaseHeader.Status::Released then begin
            ReleasePurchaseDocument.PerformManualReopen(PurchaseHeader);
            DocsToRelease.Add(PurchaseHeader."No.");
        end

    end;

    local procedure SetUnitCostFromVendorPurchPrice(var PurchaseLine: Record "Purchase Line"; DirectUnitCost: Decimal; DocsToRelease: List of [Code[20]]; ModifyRec: Boolean)
    begin
        OpenPurchaseHeader(PurchaseLine, DocsToRelease);
        PurchaseLine.Validate("Unit Cost", DirectUnitCost);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);

        if not ModifyRec then
            exit;

        if not PurchaseLine.Modify() then
            exit;
    end;

    local procedure GetPurchPriceRec(var PurchPrice: Record "Purchase Price"; PurchaseLine: Record "Purchase Line")
    begin
        PurchPrice.SetRange("Item No.", PurchaseLine."No.");
        PurchPrice.SetRange("Vendor No.", PurchaseLine."Buy-from Vendor No.");
        PurchPrice.SetRange("Currency Code", PurchaseLine."Currency Code");
        PurchPrice.SetFilter("Minimum Quantity", '<=%1', PurchaseLine.Quantity);
        PurchPrice.SetRange("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        PurchPrice.SetRange("Variant Code", PurchaseLine."Variant Code");
        PurchPrice.SetCurrentKey("Starting Date", "Minimum Quantity");
        PurchPrice.SetAscending("Starting Date", false);
        PurchPrice.SetAscending("Minimum Quantity", false);
    end;

    local procedure SetLocationAndShipMethodFilters(var SBCPurchPriceLocShipmMethod: Record "SBCPurchPriceLoc/ShipmMethod"; PurchaseLine: Record "Purchase Line"; LocationCode: Code[10]; ShipmentMethodCode: Code[10]; PurchPriceDateFilter: Date; MinQty: Decimal)
    begin
        SBCPurchPriceLocShipmMethod.SetRange("Item No.", PurchaseLine."No.");
        SBCPurchPriceLocShipmMethod.SetRange("Vendor No.", PurchaseLine."Buy-from Vendor No.");
        SBCPurchPriceLocShipmMethod.SetRange("Currency Code", PurchaseLine."Currency Code");
        SBCPurchPriceLocShipmMethod.SetRange("Minimum Quantity", MinQty);
        SBCPurchPriceLocShipmMethod.SetRange("Starting Date", PurchPriceDateFilter);
        SBCPurchPriceLocShipmMethod.SetRange("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
        SBCPurchPriceLocShipmMethod.SetRange("Variant Code", PurchaseLine."Variant Code");
        SBCPurchPriceLocShipmMethod.SetRange("Location Code", LocationCode);
        SBCPurchPriceLocShipmMethod.SetRange("Shipment Method Code", ShipmentMethodCode);
    end;

    local procedure DeleteLocShipMethodLines(xRec: Record "Purchase Price")
    var
        SBCPurchPriceLocShipmMethod: Record "SBCPurchPriceLoc/ShipmMethod";
    begin
        SBCPurchPriceLocShipmMethod.SetRange("Item No.", xRec."Item No.");
        SBCPurchPriceLocShipmMethod.SetRange("Vendor No.", xRec."Vendor No.");
        SBCPurchPriceLocShipmMethod.SetRange("Currency Code", xRec."Currency Code");
        SBCPurchPriceLocShipmMethod.SetRange("Starting Date", xRec."Starting Date");
        SBCPurchPriceLocShipmMethod.SetRange("Minimum Quantity", xRec."Minimum Quantity");
        SBCPurchPriceLocShipmMethod.SetRange("Unit of Measure Code", xRec."Unit of Measure Code");
        SBCPurchPriceLocShipmMethod.SetRange("Variant Code", xRec."Variant Code");

        if not SBCPurchPriceLocShipmMethod.IsEmpty then
            SBCPurchPriceLocShipmMethod.DeleteAll();
    end;

    procedure UpdatePurchasePricesOnOpenPurchaseOrders(PurchasePrice: Record "Purchase Price")
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        Progress: Dialog;
        ProgressText: Label 'Updating purchase prices on open purchase orders...#1######### of #2#########';
        RecordCount: Integer;
        StartCount: Integer;
        DocsToRelease: List of [Code[20]];
    begin
        PurchaseHeader.SetRange("Buy-from Vendor No.", PurchasePrice."Vendor No.");

        RecordCount := PurchaseHeader.Count;
        StartCount := 1;

        if PurchaseHeader.FindSet() then begin
            Progress.Open(ProgressText, StartCount, RecordCount);
            repeat
                Progress.Update(1, StartCount);
                PurchaseLine.Reset();
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                if PurchaseLine.FindSet() then
                    repeat
                        if PurchaseLine."Quantity Invoiced" < PurchaseLine.Quantity then begin
                            PurchasePrice.Reset();
                            PurchasePrice.SetRange("Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                            PurchasePrice.SetRange("Item No.", PurchaseLine."No.");
                            PurchasePrice.SetFilter("Minimum Quantity", '<=%1', PurchaseLine.Quantity);
                            PurchasePrice.SetCurrentKey("Starting Date", "Minimum Quantity");
                            PurchasePrice.SetAscending("Starting Date", false);
                            PurchasePrice.SetAscending("Minimum Quantity", false);
                            if PurchasePrice.FindFirst() then
                                CheckPurchPriceFromFilters(PurchaseLine, PurchaseHeader, DocsToRelease, true);
                        end;
                    until PurchaseLine.Next() = 0;
                StartCount += 1;
            until PurchaseHeader.Next() = 0;
            ReleaseReopenedPurchaseHeaders(DocsToRelease);
            Progress.Close();
        end;
    end;

    local procedure ReleaseReopenedPurchaseHeaders(var DocsToRelease: List of [Code[20]])
    var
        PurchaseHeader: Record "Purchase Header";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        DocNo: Code[20];
    begin
        foreach DocNo in DocsToRelease do begin
            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocNo) then
                ReleasePurchaseDocument.PerformManualRelease(PurchaseHeader);
        end;
    end;
    #region Unit of Measure

    [EventSubscriber(ObjectType::Table, Database::"Unit of Measure", OnAfterValidateEvent, "SBC Measurement System", false, false)]
    local procedure UnitOfMeasure_OnAfterValidate_SBCMeasurementSystem(var Rec: Record "Unit of Measure")
    begin
        UpdateMeasurementSystem(Rec);
    end;

    local procedure UpdateMeasurementSystem(UOM: Record "Unit of Measure")
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.SetRange(Code, UOM.Code);
        if ItemUnitofMeasure.IsEmpty then
            exit;

        ItemUnitofMeasure.ModifyAll("SBC Measurement System", UOM."SBC Measurement System");
    end;

    #endregion Unit of Measure

    #region Item Unit of Measure

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", OnAfterInsertEvent, '', false, false)]
    local procedure ItemUnitOfMeasure_OnAfterInsert(var Rec: Record "Item Unit of Measure")
    begin
        SetMeasurementSystem(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", OnAfterRenameEvent, '', false, false)]
    local procedure ItemUnitOfMeasure_OnAfterRename(var Rec: Record "Item Unit of Measure")
    begin
        SetMeasurementSystem(Rec);
    end;

    local procedure SetMeasurementSystem(var ItemUOM: Record "Item Unit of Measure")
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UnitOfMeasure.Get(ItemUOM.Code) then begin
            ItemUOM.Validate("SBC Measurement System", UnitOfMeasure."SBC Measurement System");
            ItemUOM.Modify();
        end;
    end;

    #endregion Item Unit of Measure

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterFinalizeOrderHeader', '', true, true)]
    local procedure ReqWkshMakeOrder_OnAfterFinalizeOrderHeader(var PurchHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        DocReleaseHolder: List of [Code[20]];
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                CheckPurchPriceFromFilters(PurchaseLine, PurchHeader, DocReleaseHolder, true);
            until PurchaseLine.Next() = 0;
    end;
    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesHeaderOnAfterInitDefaultDimensionSources(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnBeforeValidateEventUnitofMeasureCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeImportAttachmentIncDocOnAfterImportAttachment(var IncomingDocumentAttachment: Record "Incoming Document Attachment"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferHeaderOnBeforeValidateEventTransferFromCode(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferLinenValidateQuantityOnBeforeTransLineVerifyChange(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; var SkipCalcMaxWeight: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleasedProductionOrderOnAfterCreateTransferOrders(TransferHeader: Record "Transfer Header"; var IsHandled: Boolean)
    begin
    end;

    #endregion eventIntegration
}