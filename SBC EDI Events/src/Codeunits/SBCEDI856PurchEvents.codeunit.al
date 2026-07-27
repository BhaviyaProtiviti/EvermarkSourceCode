/// <summary>
/// Codeunit SBCEDI - 856 Insert PO Lines (ID 50084).
/// </summary>
codeunit 50084 "SBCEDI 856 Purch Events"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    #region EventSubscriber
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeRunMapPurchaseLine', '', false, false)]
    local procedure OnBeforeRunMapPurchaseLine(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var ExitProcess: Boolean)
    begin
        Unbind();
        CreatePurchaseLines(EDIRecDocHdr);
    end;
    #endregion

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
        Unbind(true);
        Bind();
    end;
    #endregion InstanceMethods

    #region CoreMethods

    local procedure CreatePurchaseLines(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        ItemTmp: Record "Item" temporary;
        ItemReference: Record "Item Reference";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        EDIDocument: Record "LAX EDI Document";
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        EDIRecDocFields2: Record "LAX EDI Receive Document Field";
        EDIRecDocFields3: Record "LAX EDI Receive Document Field";
        EDIRecDocFieldsExistCheck: Record "LAX EDI Receive Document Field";
        TradePartnerUnitofMeasure: Record "LAX EDI Trade Partner UOM";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseLineExistCheck: Record "Purchase Line";
        PurchaseLineTmp: Record "Purchase Line" temporary;
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        TableRef: RecordRef;
        FldRef: FieldRef;
        AllowCommit: Boolean;
        AllowLineUpdate: Boolean;
        ExitProcess: Boolean;
        Finished: Boolean;
        IsHandled: Boolean;
        LineUpdated: Boolean;
        MappedCost: Boolean;
        MappedEDICost: Boolean;
        PurchaseLineFound: Boolean;
        SummarizeQuantity: Boolean;
        LastEDIUOMCode: Code[10];
        LastUOMCode: Code[10];
        LastItemCrossRefNo: Code[20];
        LastItemNo: Code[20];
        LastEDIVariant: Code[40];
        LastExpRecDate: Date;
        ItemBaseQty: Decimal;
        LastDirUnitCost: Decimal;
        LastEDIUnitCost: Decimal;
        LastInvQty: Decimal;
        LastQty: Decimal;
        LastRecQty: Decimal;
        MultiplierQty: Decimal;
        OrderBaseQty: Decimal;
        PurchaseLineExistCheckDictionary: Dictionary of [Text, Boolean];
        PurchaseLineItemCountDictionary: Dictionary of [Text, Decimal];
        PurchaseLineIndexDictionary: Dictionary of [Integer, Text];
        EDIFileFirstIndexDictionary: Dictionary of [Text, Integer];
        EDIFileIndexCount: Integer;
        EDIFileIndex: Integer;
        CurrentEDIFileIndexCount: Integer;
        NextEDIFileIndex: Integer;
        CurrentEDIFileQuantity: Decimal;
        CurrentEDIFileLineIndex: Integer;
        NextEDIFileLineIndex: Integer;
        CurrentItemCountItemKey: Code[20];
        // i: Integer;
        LastLineNo: Integer;
        LastSegGroup: Integer;
        LineCount: Integer;
        ItemKey: Code[20];
        NextLineIndex: Integer;
        NextItemNo: Code[20];
        LastUOM: Text[50];
        LastVendItemNo: Text[50];
    begin

        // EDIRecDocFields.Reset;
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetRange("Table No.", Database::"Purchase Header");
        EDIRecDocFields.SetRange("Field No.", PurchaseHeader.FieldNo("No."));

        if not EDIRecDocFields.FindFirst() then
            exit;
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, CopyStr(EDIRecDocFields."Field Text Value", 1, MaxStrLen(PurchaseHeader."No."))) then
            exit;

        If PurchaseHeader.Status <> PurchaseHeader.Status::Open then
            exit;
        // ReleasePurchDoc.Reopen(PurchaseHeader);
        if PurchaseHeader.PurchLinesExist() then
            exit;
        PurchaseHeader.SetHideValidationDialog(true);

        Finished := false;

        EDIDocument.Get(EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.", EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        EDIRecDocFields.Reset;
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetRange("EDI Trigger", true);
        if not EDIRecDocFields.FindFirst() then
            Exit;

        EDIRecDocFields.Reset;
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");

        EDIRecDocFieldsExistCheck.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFieldsExistCheck.SetRange("Table No.", Database::"Purchase Line");
        EDIRecDocFieldsExistCheck.SetRange("Field No.", PurchaseLine.FieldNo("No."));
        If EDIRecDocFieldsExistCheck.IsEmpty() then
            exit;
        EDIRecDocFieldsExistCheck.FindSet();
        repeat
            // Build First Index Dictionary
            if not EDIFileFirstIndexDictionary.ContainsKey(EDIRecDocFieldsExistCheck."Field Text Value") then
                EDIFileFirstIndexDictionary.Add(EDIRecDocFieldsExistCheck."Field Text Value", EDIRecDocFieldsExistCheck."Line No.");
            // Build Exist Check Dictionary
            if not PurchaseLineExistCheckDictionary.ContainsKey(EDIRecDocFieldsExistCheck."Field Text Value") then
                PurchaseLineExistCheckDictionary.Add(EDIRecDocFieldsExistCheck."Field Text Value", false);
            // Build Count Tally Dictionary
            If not PurchaseLineItemCountDictionary.ContainsKey(EDIRecDocFieldsExistCheck."Field Text Value") then
                PurchaseLineItemCountDictionary.Add(EDIRecDocFieldsExistCheck."Field Text Value", 0);
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
            // If EDIRecDocFieldsExistCheck.IsEmpty() then
            //     exit;
            EDIRecDocFieldsExistCheck.FindSet();
            repeat
                case
                    EDIRecDocFieldsExistCheck."Field No." of
                    PurchaseLine.FieldNo("Qty. to Receive"):
                        begin
                            if PurchaseLineItemCountDictionary.ContainsKey(CurrentItemCountItemKey) then
                                PurchaseLineItemCountDictionary.Set(CurrentItemCountItemKey, PurchaseLineItemCountDictionary.Get(CurrentItemCountItemKey) + EDIRecDocFieldsExistCheck."Field Dec. Value");
                        end;
                end;

            until EDIRecDocFieldsExistCheck.Next() = 0;
        end;

        PurchaseLineExistCheck.Reset;
        PurchaseLineExistCheck.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLineExistCheck.SetRange("Document No.", PurchaseHeader."No.");
        ForEach ItemKey in PurchaseLineExistCheckDictionary.Keys() do begin
            PurchaseLineExistCheck.SetRange("No.", ItemKey);
            PurchaseLineExistCheckDictionary.Set(ItemKey, not PurchaseLineExistCheck.IsEmpty());
        end;

        // PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        // PurchaseLine."Document No." := PurchaseHeader."No.";
        // PurchaseLine.InitNewLine(PurchaseLine);
        // PurchaseLine."Line No." += 10000;
        LastItemNo := '';
        LastVendItemNo := '';
        LastQty := 0;
        LastInvQty := 0;
        LastRecQty := 0;
        // LastOutstandingQty := 0;
        LastExpRecDate := 0D;
        LastEDIUnitCost := 0;
        LastDirUnitCost := 0;
        LastSegGroup := 0;
        LastUOMCode := '';
        LastUOM := '';
        LastItemCrossRefNo := '';
        LastLineNo := 0;
        // LastEDICode := '';
        MappedCost := false;
        MappedEDICost := false;
        AllowLineUpdate := false;
        LineCount := PurchaseLineExistCheckDictionary.Count();
        ForEach ItemKey in EDIFileFirstIndexDictionary.Keys() do begin
            CurrentEDIFileLineIndex := EDIFileFirstIndexDictionary.Get(ItemKey);
            NextLineIndex := EDIFileFirstIndexDictionary.Keys().IndexOf(ItemKey) + 1;
            if NextLineIndex <= LineCount then
                NextEDIFileLineIndex := EDIFileFirstIndexDictionary.Values().Get(NextLineIndex)
            else
                NextEDIFileLineIndex := 0;

            if NextEDIFileLineIndex <> 0 then
                EDIRecDocFields.SetFilter("Line No.", '%1..%2', CurrentEDIFileLineIndex, NextEDIFileLineIndex - 1)
            else
                EDIRecDocFields.SetFilter("Line No.", '%1..', CurrentEDIFileLineIndex);

            // Returning a false here means the line wasn't found.
            If not PurchaseLineExistCheckDictionary.Get(ItemKey) and
            EDIRecDocFields.Findset() then
                repeat
                    if EDIRecDocFields."Table No." = Database::"Purchase Line" then begin
                        case EDIRecDocFields."Field No." of
                            PurchaseLine.FieldNo("Vendor Item No."):
                                begin
                                    LastVendItemNo := CopyStr(EDIRecDocFields."Field Text Value", 1, 50);
                                    LastItemCrossRefNo := '';
                                    // PurchaseLine."Vendor Item No." := LastVendItemNo;

                                end;
                            PurchaseLine.FieldNo("No."):
                                begin
                                    LastItemNo := CopyStr(EDIRecDocFields."Field Text Value", 1, 20);
                                    // PurchaseLine."No." := LastItemNo;

                                    LastItemCrossRefNo := '';
                                end;
                            PurchaseLine.FieldNo("Item Reference No."):
                                begin
                                    LastItemCrossRefNo := CopyStr(EDIRecDocFields."Field Text Value", 1, 50);
                                    // PurchaseLine."Item Reference No." := LastItemCrossRefNo;
                                    LastItemNo := '';
                                    LastVendItemNo := '';
                                end;
                            PurchaseLine.FieldNo(Quantity):
                                LastQty := EDIRecDocFields."Field Dec. Value";
                            // PurchaseLine.Quantity := LastQty;
                            PurchaseLine.FieldNo("Qty. to Invoice"):
                                LastInvQty := EDIRecDocFields."Field Dec. Value";
                            PurchaseLine.FieldNo("Qty. to Receive"):
                                LastRecQty := EDIRecDocFields."Field Dec. Value";
                            PurchaseLine.FieldNo("Expected Receipt Date"):
                                LastExpRecDate := EDIRecDocFields."Field Date Value";
                            PurchaseLine.FieldNo("Direct Unit Cost"):
                                begin
                                    MappedCost := true;
                                    LastDirUnitCost := EDIRecDocFields."Field Dec. Value";
                                end;
                            PurchaseLine.FieldNo("LAX EDI Unit Cost"):
                                begin
                                    MappedEDICost := true;
                                    LastEDIUnitCost := EDIRecDocFields."Field Dec. Value";
                                end;
                            PurchaseLine.FieldNo("LAX EDI Segment Group"):
                                LastSegGroup := EDIRecDocFields."Field Integer Value";
                            PurchaseLine.FieldNo("Unit of Measure"):
                                LastUOM := EDIRecDocFields."Field Text Value";
                            PurchaseLine.FieldNo("Unit of Measure Code"):
                                LastUOMCode := EDIRecDocFields."Field Text Value";
                            PurchaseLine.FieldNo("Line No."):
                                LastLineNo := EDIRecDocFields."Field Integer Value";
                        end;
                    end;
                    if EDIRecDocFields."Table No." = Database::"LAX EDI Trade Partner UOM" then
                        case EDIRecDocFields."Field No." of
                            TradePartnerUnitofMeasure.FieldNo("EDI Unit of Measure"):
                                LastEDIUOMCode := EDIRecDocFields."Field Text Value";
                            TradePartnerUnitofMeasure.FieldNo("EDI Variant Code"):
                                LastEDIVariant := EDIRecDocFields."Field Text Value";
                        end;

                // until (EDIRecDocFields.Next = 0) or (Finished);
                until EDIRecDocFields.Next = 0;

            PurchaseLine.Init();
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine.InitNewLine(PurchaseLine);
            PurchaseLine."Line No." := PurchaseLine."Line No." + 10000;
            PurchaseLine.Type := PurchaseLine.Type::Item;
            PurchaseLine.Validate("No.", ItemKey);
            if LastVendItemNo <> '' then
                PurchaseLine."Vendor Item No." := LastVendItemNo;
            if LastUOMCode <> '' then
                PurchaseLine."Unit of Measure" := LastUOM;
            if LastItemCrossRefNo <> '' then
                PurchaseLine."Item Reference No." := LastItemCrossRefNo;
            LastQty := PurchaseLineItemCountDictionary.Get(ItemKey);
            PurchaseLine.Validate(Quantity, LastQty);
            if LastExpRecDate <> 0D then
                PurchaseLine.Validate("Expected Receipt Date", LastExpRecDate);
            if LastEDIUnitCost <> 0 then
                PurchaseLine.Validate("LAX EDI Unit Cost", LastEDIUnitCost);
            PurchaseLine."LAX EDI Segment Group" := LastSegGroup;
            PurchaseLineExistCheckDictionary.Set(ItemKey, PurchaseLine.Insert(true));

        end;

        if PurchaseLineExistCheckDictionary.Values().Contains(false) then
            exit;
        if PurchaseHeader."LAX EDI Order" then
            exit;
        PurchaseHeader."LAX EDI Order" := true;
        PurchaseHeader.Modify();
    end;

    #endregion CoreMethods
    var
        GlobalBound: Boolean;
        GlobalCUInstance: Codeunit "SBCEDI 856 Purch Events";

}