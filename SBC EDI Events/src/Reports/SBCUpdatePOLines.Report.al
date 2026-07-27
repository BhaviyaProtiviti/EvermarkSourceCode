/// <summary>
/// Report SBC - Update PO Lines (ID 50081).
/// </summary>
report 50081 "SBC - Update PO Lines"
{
    ApplicationArea = All;
    Caption = 'SBC - Update PO Lines';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            DataItemTableView = where("Document Type" = const("Purchase Document Type"::Order));
            RequestFilterFields = "SBC Block Order", "No.", "LAX EDI Update Int. Doc. No.";


            dataitem(PurchaseLine; "Purchase Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = PurchaseHeader;
                DataItemTableView = where("Document Type" = const("Purchase Document Type"::Order), Type = const("Purchase Line Type"::Item));

                trigger OnAfterGetRecord()
                begin
                    ProcessLine();
                end;

                trigger OnPostDataItem()
                begin
                    CheckGlobalResetEDIPoUpdate();
                    CheckGlobalEDICorrectQtyMapping();
                end;
            }


            trigger OnAfterGetRecord()

            begin
                CheckGlobalLeaveOpen();
                // EDIRecDocFields.Reset;
                InitializeGlobalDictionary();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'GroupName';
                    field(OptionLeaveOrderOpen; GlobalLeaveOrderOpen)
                    {
                        ApplicationArea = All;
                        Caption = 'GlobalLeaveOrderOpen';
                        ToolTip = 'Select this to leave the order open after the update.';
                    }
                    field(OptionDeleteLines; GlobalDeleteLines)
                    {
                        ApplicationArea = All;
                        Caption = 'GlobalDeleteLines';
                        ToolTip = 'Select this to try and delete purchase order lines.';
                    }
                    field(OptionResetEDIPoUpdate; GlobalResetEDIPoUpdate)
                    {
                        ApplicationArea = All;
                        Caption = 'GlobalResetEDIPoUpdate';
                        ToolTip = 'Select this to reset the EDI PO Update field.';
                    }
                    field(OptionRemoveEDIQuantityMapping; GlobalRemoveEDIQuantityMapping)
                    {
                        ApplicationArea = All;
                        Caption = 'GlobalRemoveEDIQuantityMapping';
                        ToolTip = 'Select this to remove the EDI Quantity Mapping.';
                    }
                }
            }
        }

        trigger OnAfterGetRecord()
        begin
            PurchaseHeader.SetRange("SBC Block Order", true);
        end;
    }

    var
        GlobalDeleteLines: Boolean;
        GlobalLeaveOrderOpen: Boolean;
        GlobalRemoveEDIQuantityMapping: Boolean;
        GlobalResetEDIPoUpdate: Boolean;
        GlobalPurchaseLineItemCountDictionary: Dictionary of [Text, Decimal];

    local procedure CheckGlobalDeleteLines()
    var
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        TrackingSpecification: Record "Tracking Specification";
        ReservationManagement: Codeunit "Reservation Management";
        ItemTracingMgt: Codeunit "Item Tracing Mgt.";
        ReservEntry: Record "Reservation Entry";
        DownToQty: Decimal;
    begin
        if not GlobalDeleteLines then
            exit;
        // TrackingSpecification.SetRange("Source Type", Database::"Purchase Line");
        // TrackingSpecification.SetRange("Source Subtype", TrackingSpecification."Source Subtype"::"1");
        // TrackingSpecification.SetRange("Source Id", PurchaseLine."Document No.");
        // TrackingSpecification.SetRange("Source Ref. No.", PurchaseLine."Line No.");
        // if TrackingSpecification.FindFirst() then begin
        //     TrackingSpecification.Validate("Lot No.", '');
        //     TrackingSpecification.Modify(true);
        // end;
        ReservEntry.SetRange("Source ID", PurchaseLine."Document No.");
        ReservEntry.SetRange("Source Ref. No.", PurchaseLine."Line No.");
        ReservEntry.SetRange("Source Subtype", ReservEntry."Source Subtype"::"1");
        if not ReservEntry.IsEmpty() then
            ReservEntry.DeleteAll();
        ItemTrackingManagement.DeleteInvoiceSpecFromLine(Database::"Purchase Line", TrackingSpecification."Source Subtype"::"1", PurchaseLine."Document No.", PurchaseLine."Line No.");
        // end;
        PurchaseLine.Delete(true);
    end;

    local procedure CheckGlobalEDICorrectQtyMapping()
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        if not GlobalRemoveEDIQuantityMapping then
            exit;
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", PurchaseHeader."LAX EDI Update Int. Doc. No.");
        LAXEDIReceiveDocumentField.SetRange("Table No.", Database::"Purchase Line");
        LAXEDIReceiveDocumentField.SetRange("Field No.", PurchaseLine.FieldNo(Quantity));
        if LAXEDIReceiveDocumentField.IsEmpty() then
            exit;
        LAXEDIReceiveDocumentField.DeleteAll();
    end;

    local procedure CheckGlobalLeaveOpen()
    var
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        if GlobalDeleteLines then
            GlobalLeaveOrderOpen := true;
        if not GlobalLeaveOrderOpen then
            exit;
        ReleasePurchaseDocument.PerformManualReopen(PurchaseHeader);
    end;

    local procedure CheckGlobalResetEDIPoUpdate()
    var
        LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
    begin
        if not GlobalResetEDIPoUpdate then
            exit;
        if not LAXEDIReceiveDocumentHdr.Get(PurchaseHeader."LAX EDI Update Int. Doc. No.") then
            exit;
        if not LAXEDIReceiveDocumentHdr."Purchase Order Updated" then
            exit;
        LAXEDIReceiveDocumentHdr."Purchase Order Updated" := false;
        LAXEDIReceiveDocumentHdr.Modify();
    end;

    local procedure CorrectPurchaseLineQuantity() Corrected: Boolean
    var
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        Released: Boolean;
        TrackingQuantity: Decimal;
    begin

        // QuantityPerUnitOfMeasure := TrackingSpecification."Qty. per Unit of Measure";
        // if QuantityPerUnitOfMeasure = 1 then
        //     GetQuantityPer(QuantityPerUnitOfMeasure);
        // TrackingSpecification.CalcSums("Quantity (Base)");
        // TrackingQuantity := TrackingSpecification."Quantity (Base)" / QuantityPerUnitOfMeasure;
        if not GlobalPurchaseLineItemCountDictionary.Get(PurchaseLine."No.", TrackingQuantity) then
            exit;
        Corrected := PurchaseLine.Quantity = TrackingQuantity;
        if Corrected then
            exit;
        Released := PurchaseHeader.Status = PurchaseHeader.Status::Released;
        PurchaseHeader.SetHideValidationDialog(true);
        if Released then
            ReleasePurchaseDocument.PerformManualReopen(PurchaseHeader);

        PurchaseLine.Validate(Quantity, TrackingQuantity);
        Corrected := PurchaseLine.Modify();
        if not Released then
            exit;

        if GlobalLeaveOrderOpen then
            exit;

        ReleasePurchaseDocument.PerformManualRelease(PurchaseHeader);
    end;

    local procedure GetQuantityPer(var QuantityPerUnitOfMeasure: Integer)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.SetRange("Item No.", PurchaseLine."No.");
        ItemUnitofMeasure.SetRange(Code, PurchaseLine."Unit of Measure Code");
        ItemUnitofMeasure.SetFilter("Qty. per Unit of Measure", '>%1', 1);
        if ItemUnitofMeasure.IsEmpty() then
            exit;
        ItemUnitofMeasure.SetLoadFields("Qty. per Unit of Measure");
        ItemUnitofMeasure.FindFirst();
        QuantityPerUnitOfMeasure := ItemUnitofMeasure."Qty. per Unit of Measure";
    end;

    local procedure InitializeGlobalDictionary()
    var
        EDIDocument: Record "LAX EDI Document";
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        EDIRecDocFieldsExistCheck: Record "LAX EDI Receive Document Field";
        EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.";
        CurrentItemCountItemKey: Code[20];
        CurrentEDIFileQuantity: Decimal;
        PurchaseLineIndexDictionary: Dictionary of [Integer, Text];
        CurrentEDIFileIndexCount: Integer;
        EDIFileIndex: Integer;
        EDIFileIndexCount: Integer;
        NextEDIFileIndex: Integer;
    begin
        Clear(GlobalPurchaseLineItemCountDictionary);
        if not EDIRecDocHdr.Get(PurchaseHeader."LAX EDI Update Int. Doc. No.") then
            exit;
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetRange("Table No.", Database::"Purchase Header");
        EDIRecDocFields.SetRange("Field No.", PurchaseHeader.FieldNo("No."));

        if not EDIRecDocFields.FindFirst() then
            exit;

        // PurchaseHeader.SetHideValidationDialog(true);
        // // if PurchaseHeader.Status <> PurchaseHeader.Status::Open then
        // //     ReleasePurchDoc.Reopen(PurchaseHeader);

        EDIDocument.Get(EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.", EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        EDIRecDocFields.Reset();
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");

        EDIRecDocFieldsExistCheck.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFieldsExistCheck.SetRange("Table No.", Database::"Purchase Line");
        EDIRecDocFieldsExistCheck.SetRange("Field No.", PurchaseLine.FieldNo("No."));
        if EDIRecDocFieldsExistCheck.IsEmpty() then
            exit;

        EDIRecDocFieldsExistCheck.FindSet();
        repeat

            // Build Count Tally Dictionary
            if not GlobalPurchaseLineItemCountDictionary.ContainsKey(EDIRecDocFieldsExistCheck."Field Text Value") then
                GlobalPurchaseLineItemCountDictionary.Add(EDIRecDocFieldsExistCheck."Field Text Value", 0);
            // Build Index Dictionary
            if not PurchaseLineIndexDictionary.ContainsKey(EDIRecDocFieldsExistCheck."Line No.") then
                PurchaseLineIndexDictionary.Add(EDIRecDocFieldsExistCheck."Line No.", EDIRecDocFieldsExistCheck."Field Text Value");
        until EDIRecDocFieldsExistCheck.Next() = 0;

        EDIRecDocFieldsExistCheck.Reset();
        EDIRecDocFieldsExistCheck.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFieldsExistCheck.SetRange("Table No.", Database::"Purchase Line");
        EDIFileIndexCount := PurchaseLineIndexDictionary.Count();
        foreach EDIFileIndex in PurchaseLineIndexDictionary.Keys() do begin
            CurrentItemCountItemKey := PurchaseLineIndexDictionary.Get(EDIFileIndex);
            NextEDIFileIndex := 0;
            CurrentEDIFileQuantity := 0;
            CurrentEDIFileIndexCount := PurchaseLineIndexDictionary.Keys().IndexOf(EDIFileIndex);
            if CurrentEDIFileIndexCount < EDIFileIndexCount then
                NextEDIFileIndex := PurchaseLineIndexDictionary.Keys.Get(PurchaseLineIndexDictionary.Keys().IndexOf(EDIFileIndex) + 1);
            if NextEDIFileIndex <> 0 then
                EDIRecDocFieldsExistCheck.SetRange("Line No.", EDIFileIndex, NextEDIFileIndex - 1)
            else
                EDIRecDocFieldsExistCheck.SetFilter("Line No.", '%1..', EDIFileIndex);

            EDIRecDocFieldsExistCheck.FindSet();
            repeat
                case
                    EDIRecDocFieldsExistCheck."Field No." of
                    PurchaseLine.FieldNo("Qty. to Receive"):
                        begin
                            if GlobalPurchaseLineItemCountDictionary.ContainsKey(CurrentItemCountItemKey) then
                                GlobalPurchaseLineItemCountDictionary.Set(CurrentItemCountItemKey, GlobalPurchaseLineItemCountDictionary.Get(CurrentItemCountItemKey) + EDIRecDocFieldsExistCheck."Field Dec. Value");
                        end;
                end;
            until EDIRecDocFieldsExistCheck.Next() = 0;
        end;
    end;

    local procedure UndoPurchaseReceipt() Updated: Boolean
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        Updated := true;
        PurchRcptLine.SetRange("Order No.", PurchaseLine."Document No.");
        PurchRcptLine.SetRange("Order Line No.", PurchaseLine."Line No.");
        PurchRcptLine.SetRange(Correction, false);
        if PurchRcptLine.IsEmpty() then
            exit;
        // Commit();
        PurchRcptLine.FindSet(true);
        repeat
            Updated := UndoReceiptLine(PurchRcptLine) and Updated;
        until PurchRcptLine.Next() = 0;
        // if not updated then
        //     exit;
        // // Commit();
    end;

    local procedure UndoReceiptLine(var PurchRcptLine: Record "Purch. Rcpt. Line") Updated: Boolean
    var
        UndoPurchaseReceiptLine: Codeunit "Undo Purchase Receipt Line";
    begin
        UndoPurchaseReceiptLine.SetHideDialog(true);
        UndoPurchaseReceiptLine.Run(PurchRcptLine);
        Updated := true;
    end;

    local procedure ProcessLine()
    begin
        if not CorrectPurchaseLineQuantity() then
            exit;

        if not UndoPurchaseReceipt() then
            exit;

        CheckGlobalDeleteLines();
    end;
}