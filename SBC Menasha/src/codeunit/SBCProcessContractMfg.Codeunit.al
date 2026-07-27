/// <summary>
/// Codeunit SBC Process - Contract Mfg. (ID 50257).
/// </summary>
codeunit 50356 "SBC Process - Contract Mfg."
{
    TableNo = "SBC Contract Mfg. Header";

    trigger OnRun()
    begin
        Process(Rec);
    end;

    local procedure Process(ContractMfgHeader: Record "SBC Contract Mfg. Header")
    begin
        case ContractMfgHeader."SBC Contract Type" of
            "SBC Contract Type"::"SBC Inventory":
                CreateInvAdjustments(ContractMfgHeader);
            "SBC Contract Type"::"SBC Finished Goods":
                ProcessFinishedGoods(ContractMfgHeader);
            "SBC Contract Type"::"SBC Consumption":
                ProcessProdJournal(ContractMfgHeader);
            else
                ProcessOtherContract(ContractMfgHeader);
        end;
        ArchiveContract(ContractMfgHeader."SBC Import Document No.", ContractMfgHeader."SBC Contract Source", ContractMfgHeader."SBC Contract Type");
    end;

    local procedure filterContractLines(var ContractMfgLine: Record "SBC Contract Mfg. Line"; ContractMfgHeader: Record "SBC Contract Mfg. Header"; ProcessedFilter: Boolean)
    begin
        ContractMfgLine.Reset();
        ContractMfgLine.SetRange("SBC Import Document No.", ContractMfgHeader."SBC Import Document No.");
        ContractMfgLine.SetRange("SBC Contract Source", ContractMfgHeader."SBC Contract Source");
        ContractMfgLine.SetRange("SBC Contract Type", ContractMfgHeader."SBC Contract Type");
        ContractMfgLine.SetRange("SBC Line Processed", ProcessedFilter);
    end;

    local procedure GetPurchOrderList(ContractMfgHeader: Record "SBC Contract Mfg. Header"; var PurchOrderList: List of [Code[20]])
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        if ContractMfgLine.FindSet() then
            repeat
                if not PurchOrderList.Contains(ContractMfgLine."SBC Purchase Order No.") then
                    PurchOrderList.Add(ContractMfgLine."SBC Purchase Order No.");
            until ContractMfgLine.Next() = 0;
    end;

    #region archiveContract

    local procedure ArchiveContract(ImportDocNo: Code[20]; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"): Boolean
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        ContractMfgHeader.Get(ImportDocNo, ContractSource, ContractType);
        if CanArchive(ContractMfgHeader) then begin
            filterContractLines(ContractMfgLine, ContractMfgHeader, true);
            if ContractMfgLine.FindSet(true) then begin
                CreatePostedContractHdr(ContractMfgHeader);
                repeat
                    CreatePostedContractLine(ContractMfgLine);
                until ContractMfgLine.Next() = 0;
            end;
            ContractMfgHeader.Delete(true);
            exit(true);
        end;
    end;

    procedure CreatePostedContractHdr(var ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        PostedContractMfgHdr: Record "SBC Posted Contract Mfg Hdr";
        DocumentAttachmentMgmt: Codeunit "SBC Document Attachment Mgmt";
    begin
        PostedContractMfgHdr.Init();
        PostedContractMfgHdr.TransferFields(ContractMfgHeader);
        PostedContractMfgHdr.Insert(true);
        DocumentAttachmentMgmt.CopyAttachment(ContractMfgHeader, PostedContractMfgHdr);
    end;

    procedure CreatePostedContractLine(ContractMfgLine: Record "SBC Contract Mfg. Line")
    var
        PostedContractMfgLine: Record "SBC Posted Contract Mfg Line";
    begin
        PostedContractMfgLine.Init();
        PostedContractMfgLine.TransferFields(ContractMfgLine);
        PostedContractMfgLine.Insert(true);
    end;

    local procedure CanArchive(ContractMfgHeader: Record "SBC Contract Mfg. Header"): Boolean
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        ContractMfgLine.Reset();
        ContractMfgLine.SetRange("SBC Import Document No.", ContractMfgHeader."SBC Import Document No.");
        ContractMfgLine.SetRange("SBC Contract Source", ContractMfgHeader."SBC Contract Source");
        ContractMfgLine.SetRange("SBC Contract Type", ContractMfgHeader."SBC Contract Type");
        ContractMfgLine.SetRange("SBC Has Line Error", true);
        // ContractMfgLine.SetRange("SBC Line Processed", true);
        if ContractMfgLine.IsEmpty then
            exit(true);
    end;

    #endregion archiveContract

    #region processFinishedGoods

    local procedure ProcessFinishedGoods(ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        PurchaseHeader: Record "Purchase Header";
        PurchOrderNo: Code[20];
        PostingDate: Date;
        PurchOrderList: List of [Code[20]];
    begin
        ClearLineErrors(ContractMfgHeader);
        TestPostingDate(ContractMfgHeader);
        GetPurchOrderList(ContractMfgHeader, PurchOrderList);

        foreach PurchOrderNo in PurchOrderList do
            if GetPurchHeader(PurchaseHeader, PurchOrderNo, ContractMfgHeader) then begin
                PostingDate := GetPostingDate(ContractMfgHeader, PurchOrderNo);
                if ProcessContractLines(ContractMfgHeader, ContractMfgLine, PurchOrderNo) then
                    if PostPurchaseReceipt(ContractMfgHeader, PurchaseHeader, PostingDate) then
                        SetProcessedLines(ContractMfgHeader, PurchOrderNo);
            end;

        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Production Order No.", '');
        if ContractMfgLine.FindSet() then begin
            ContractMfgLine.ModifyAll("SBC Has Line Error", true);
            ContractMfgLine.ModifyAll("SBC Line Error", 'Production Order not found');
        end
    end;

    local procedure ProcessContractLines(ContractMfgHeader: Record "SBC Contract Mfg. Header"; ContractMfgLine: Record "SBC Contract Mfg. Line"; PurchOrderNo: Code[20]): Boolean
    var
        ProdOrderNo: Code[20];
        ProdOrderLineNo: Integer;
        ItemNo: Code[20];
        QtyToReceive, QtyPerUOM : Decimal;
        ReservationEntryList: list of [Integer];
    begin
        ClearQtyToReceive(PurchOrderNo);

        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetCurrentKey("SBC Item No.");
        ContractMfgLine.SetAscending("SBC Item No.", true);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractMfgLine.SetFilter("SBC Production Order No.", '<>%1', '');
        if ContractMfgLine.FindSet() then begin
            clear(ItemNo);
            repeat
                if ItemNo <> ContractMfgLine."SBC Item No." then begin
                    if ItemNo <> '' then
                        if not UpdatePurchOrderQtyToReceive(ContractMfgLine, PurchOrderNo, QtyToReceive, ProdOrderNo, ProdOrderLineNo) then begin
                            DeleteReservationEntries(ReservationEntryList);
                            exit(false);
                        end;
                    Clear(ProdOrderNo);
                    Clear(ProdOrderLineNo);
                    Clear(QtyToReceive);
                    Clear(QtyPerUOM);
                    Clear(ReservationEntryList);
                    ItemNo := ContractMfgLine."SBC Item No.";
                end;
                if not CreateReservationEntry(ContractMfgLine, ReservationEntryList, QtyPerUOM, QtyToReceive, ProdOrderNo, ProdOrderLineNo) then begin
                    AddLineError(ContractMfgLine, '');
                    DeleteReservationEntries(ReservationEntryList);
                    exit(false);
                end;
            until ContractMfgLine.Next() = 0;
            if not UpdatePurchOrderQtyToReceive(ContractMfgLine, PurchOrderNo, QtyToReceive, ProdOrderNo, ProdOrderLineNo) then begin
                DeleteReservationEntries(ReservationEntryList);
                exit(false);
            end;
            exit(true);
        end;
    end;

    local procedure UpdatePurchOrderQtyToReceive(ContractMfgLine: Record "SBC Contract Mfg. Line"; PurchOrderNo: Code[20]; QtyToReceive: Decimal; ProdOrderNo: Code[20]; ProdOrderLineNo: Integer): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if UpdatePurchaseOrder(PurchaseLine, PurchOrderNo, QtyToReceive, ProdOrderNo, ProdOrderLineNo) then
            if PurchaseLine.Modify(true) then
                exit(true);

        AddLineError(ContractMfgLine, '');
        exit(false);
    end;

    [TryFunction]
    local procedure UpdatePurchaseOrder(var PurchaseLine: Record "Purchase Line"; PurchOrderNo: Code[20]; QtyToReceive: Decimal; ProdOrderNo: Code[20]; ProdOrderLineNo: Integer)
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchOrderNo);
        PurchaseLine.SetRange("Prod. Order No.", ProdOrderNo);
        PurchaseLine.SetRange("Prod. Order Line No.", ProdOrderLineNo);
        if PurchaseLine.FindFirst() then
            PurchaseLine.Validate("Qty. to Receive", QtyToReceive)
        else
            error('Purchase Line not found');
    end;

    #region testRequiredFields

    local procedure TestPostingDate(ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Posting Date", 0D);
        ContractMfgLine.ModifyAll("SBC Has Line Error", true);
        ContractMfgLine.ModifyAll("SBC Line Error", 'Posting Date cannot be blank');
    end;

    local procedure GetPostingDate(ContractMfgHeader: Record "SBC Contract Mfg. Header"; PurchOrderNo: Code[20]): date
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractMfgLine.SetRange("SBC Has Line Error", false);
        if ContractMfgLine.FindFirst() then;
        exit(ContractMfgLine."SBC Posting Date");
    end;

    local procedure GetPurchHeader(var PurchaseHeader: Record "Purchase Header"; PurchOrderNo: Code[20]; ContractMfgHeader: Record "SBC Contract Mfg. Header"): Boolean
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        PurchaseHeader.Reset();
        if not GetPurchaseHeader(PurchaseHeader, PurchOrderNo) then begin
            filterContractLines(ContractMfgLine, ContractMfgHeader, false);
            ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
            ContractMfgLine.ModifyAll("SBC Has Line Error", true);
            ContractMfgLine.ModifyAll("SBC Line Error", CopyStr(GetLastErrorText(), 1, 250));
            exit;
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure GetPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; PurchOrderNo: Code[20])
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchOrderNo);
    end;

    local procedure ClearQtyToReceive(PurchOrderNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchOrderNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.ModifyAll("Qty. to Receive", 0);
    end;

    #endregion testRequiredFields

    #region createReservations

    local procedure CreateReservationEntry(ContractMfgLine: Record "SBC Contract Mfg. Line"; var ReservationEntryList: list of [Integer]; var QtyPerUOM: Decimal; var QtyToReceive: Decimal; var ProdOrderNo: Code[20]; var ProdOrderLineNo: Integer): boolean
    var
        ReservationEntry: Record "Reservation Entry";
        ProdOrderLine: Record "Prod. Order Line";
        LocationCode: Code[10];
    begin
        if ContractMfgLine."SBC Quantity" < 0 then
            ContractMfgLine."SBC Quantity" := -ContractMfgLine."SBC Quantity";
        QtyToReceive += ContractMfgLine."SBC Quantity";

        if ProdOrderNo = '' then begin
            GetProdOrderLine(ProdOrderLine, ContractMfgLine."SBC Production Order No.", ContractMfgLine."SBC Item No.");
            if ProdOrderLine.FindFirst() then begin
                ProdOrderNo := ProdOrderLine."Prod. Order No.";
                ProdOrderLineNo := ProdOrderLine."Line No.";
                LocationCode := ProdOrderLine."Location Code";
                if QtyPerUOM = 0 then
                    QtyPerUOM := GetQuanityPerUOM(ProdOrderLine."Item No.", ProdOrderLine."Unit of Measure Code");
            end;
        end else
            if ProdOrderLine.Get(ProdOrderLine.Status::Released, ProdOrderNo, ProdOrderLineNo) then
                LocationCode := ProdOrderLine."Location Code";
        // Skip lot tracking for items without Item Tracking Code or when no lot no. provided in import file
        if not IsItemLotTracked(ContractMfgLine."SBC Item No.") or (ContractMfgLine."SBC Lot No." = '') then
            exit(true);

        if InitReservationEntry(ReservationEntry, Database::"Prod. Order Line", 3, ProdOrderNo, ProdOrderLineNo, ContractMfgLine."SBC Item No.", (ContractMfgLine."SBC Quantity" * QtyPerUOM), LocationCode, ContractMfgLine."SBC Lot No.") then
            if ReservationEntry.Insert(true) then begin
                ReservationEntryList.Add(ReservationEntry."Entry No.");
                exit(true);
            end;
    end;

    [TryFunction]
    local procedure InitReservationEntry(var ReservationEntry: Record "Reservation Entry"; SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]; SourceLineNo: Integer; ItemNo: Code[20]; ReceiveQty: Decimal; LocationCode: Code[10]; LotNo: Code[50])
    begin
        ReservationEntry.Reset();
        ReservationEntry.Init();
        ReservationEntry."Entry No." := GetLastEntryNo() + 1;
        ReservationEntry."Source Type" := SourceType;
        ReservationEntry."Source Subtype" := SourceSubtype;
        ReservationEntry."Source ID" := SourceID;
        ReservationEntry."Source Prod. Order Line" := SourceLineNo;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry."Expected Receipt Date" := Today;
        ReservationEntry.Positive := true;
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Creation Date" := Today;
        ReservationEntry.Validate("Item No.", ItemNo);
        ReservationEntry.Validate("Quantity (Base)", ReceiveQty);
        ReservationEntry.Validate("Location Code", LocationCode);
        ReservationEntry.Validate("Lot No.", LotNo);
    end;

    local procedure GetProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; ProdOrderNo: Code[20]; ItemNo: Code[20])
    var
        ProductionOrder: Record "Production Order";
    begin
        if ProductionOrder.Get(ProductionOrder.Status::Released, ProdOrderNo) then begin
            ProdOrderLine.SetRange(Status, ProductionOrder.Status);
            ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
            ProdOrderLine.SetRange("Item No.", ItemNo);
        end;
    end;

    local procedure GetQuanityPerUOM(ItemNo: Code[20]; UOMCode: Code[10]): Decimal
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        if ItemUnitofMeasure.Get(ItemNo, UOMCode) then
            exit(ItemUnitofMeasure."Qty. per Unit of Measure")
        else
            exit(1);
    end;

    local procedure GetLastEntryNo(): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        if ReservationEntry.FindLast() then
            exit(ReservationEntry."Entry No.");
    end;

    #endregion createReservations

    #region deleteReservationEntries

    local procedure DeleteReservationEntries(ReservationEntryList: list of [Integer])
    var
        ReservationEntry: Record "Reservation Entry";
        EntryNo: Integer;
    begin
        foreach EntryNo in ReservationEntryList do
            if ReservationEntry.Get(EntryNo, true) then
                ReservationEntry.Delete();
    end;

    #endregion deleteReservationEntries

    #region postPurchReceipt

    local procedure PostPurchaseReceipt(ContractMfgHeader: Record "SBC Contract Mfg. Header"; PurchaseHeader: Record "Purchase Header"; PostingDate: Date): Boolean
    var
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := false;
        PurchaseHeader.Modify();
        Codeunit.Run(Codeunit::"Purch.-Post", PurchaseHeader);
        exit(true);
    end;

    #endregion postPurchReceipt

    #endregion processFinishedGoods

    #region processConsumption

    local procedure ProcessProdJournal(ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        ProductionOrder: Record "Production Order";
        PurchOrderNo: Code[20];
        PurchOrderList: List of [Code[20]];
    begin
        DeleteItemJnlLine();
        TestMenashaFGProcessed(ContractMfgHeader."SBC Import Name");
        TestPostingDate(ContractMfgHeader);

        ClearLineErrors(ContractMfgHeader);
        GetPurchOrderList(ContractMfgHeader, PurchOrderList);
        foreach PurchOrderNo in PurchOrderList do
            if hasProductionOrder(ProductionOrder, ContractMfgHeader, PurchOrderNo) then
                CreateConsumptionLines(ContractMfgHeader, ProductionOrder, PurchOrderNo);
    end;

    local procedure DeleteItemJnlLine()
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", '');
        ItemJournalLine.SetRange("Journal Batch Name", '');
        ItemJournalLine.DeleteAll();
    end;

    local procedure CreateConsumptionLines(ContractMfgHeader: Record "SBC Contract Mfg. Header"; ProductionOrder: Record "Production Order"; PurchOrderNo: Code[20])
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        ItemJournal: Record "Item Journal Line";
        TempItemJournalLine: Record "Item Journal Line" temporary;
        TemplateName: Code[10];
        BatchName: Code[10];
        LineNo: Integer;
        HasLineError: Boolean;
    begin
        HasLineError := false;
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        if ContractMfgLine.FindSet() then begin
            CreateConsumptionLines(ProductionOrder, TemplateName, BatchName);
            LineNo := GetLastLineNo(TemplateName, BatchName);
            repeat
                AddLotNo(ContractMfgLine, TempItemJournalLine, TemplateName, BatchName, LineNo);
                if ContractMfgLine."SBC Has Line Error" then
                    HasLineError := true;
            until ContractMfgLine.Next() = 0;
            if HasLineError then begin
                ItemJournal.SetRange("Journal Template Name", TemplateName);
                ItemJournal.SetRange("Journal Batch Name", BatchName);
                ItemJournal.DeleteAll();
            end else
                PostItemJournal(ContractMfgHeader, TempItemJournalLine, TemplateName, BatchName, PurchOrderNo);
        end;
    end;

    local procedure HasProductionOrder(var ProductionOrder: Record "Production Order"; ContractMfgHeader: Record "SBC Contract Mfg. Header"; PurchOrderNo: Code[20]): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        ProdOrderErrTxt: text;
        ProdOrderErr: Label 'Cannot find Released Production Order related to Purchase Order %1', Comment = '%1 Production Order No.';
    begin
        ProductionOrder.Reset();
        if not Format(ContractMfgHeader."SBC Import Document No.").Contains('REOPEN') then //ignore purchase order check if consumption is reopened
            if not GetPurchHeader(PurchaseHeader, PurchOrderNo, ContractMfgHeader) then
                exit;

        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractMfgLine.SetFilter("SBC Production Order No.", '<>%1', '');
        if ContractMfgLine.FindFirst() then
            if GetProductionOrder(ProductionOrder, ContractMfgLine."SBC Production Order No.") then
                exit(true);

        ProductionOrder.SetRange("SBC Subcontracting Purch.Order", PurchOrderNo);
        if ProductionOrder.FindFirst() then begin
            ContractMfgLine.ModifyAll("SBC Production Order No.", ProductionOrder."No.");
            exit(true);
        end else
            ProdOrderErrTxt := StrSubstNo(ProdOrderErr, PurchOrderNo);

        if ProdOrderErrTxt = '' then
            ProdOrderErrTxt := CopyStr(GetLastErrorText(), 1, 250);

        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractMfgLine.ModifyAll("SBC Has Line Error", true);
        ContractMfgLine.ModifyAll("SBC Line Error", ProdOrderErrTxt);
    end;

    local procedure TestMenashaFGProcessed(ImportName: Text)
    var
        FGContractMfgHeader: Record "SBC Contract Mfg. Header";
        FGErrorTxt: Label 'Finished Good Contract %1 must be processed first.', Comment = '%1 = Import Doc No.';
    begin
        FGContractMfgHeader.SetRange("SBC Contract Source", FGContractMfgHeader."SBC Contract Source"::"SBC Menasha");
        FGContractMfgHeader.SetRange("SBC Contract Type", FGContractMfgHeader."SBC Contract Type"::"SBC Finished Goods");
        FGContractMfgHeader.SetRange("SBC Import Name", ImportName);
        if FGContractMfgHeader.FindFirst() then
            Error(StrSubstNo(FGErrorTxt, FGContractMfgHeader."SBC Import Document No."));
    end;

    [TryFunction]
    local procedure GetProductionOrder(var ProductionOrder: Record "Production Order"; ProdOrderNo: Code[20])
    begin
        ProductionOrder.Reset();
        ProductionOrder.Get(ProductionOrder.Status::Released, ProdOrderNo);
    end;

    local procedure CreateConsumptionLines(ProductionOrder: Record "Production Order"; var TemplateName: Code[10]; var BatchName: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        ProductionJrnlMgt: Codeunit "Production Journal Mgt";
        LineNo: Integer;
    begin
        clear(TemplateName);
        clear(BatchName);
        ProductionJrnlMgt.SetTemplateAndBatchName();
        ProductionJrnlMgt.GetJnlTemplateAndBatchName(TemplateName, BatchName);
        ProductionJrnlMgt.InitSetupValues();

        ItemJournalBatch.SetRange("Journal Template Name", TemplateName);
        ItemJournalBatch.SetRange(Name, BatchName);
        ItemJournalBatch.SetRange("Item Tracking on Lines", false);
        if ItemJournalBatch.FindFirst() then begin
            ItemJournalBatch."Item Tracking on Lines" := true;
            ItemJournalBatch.Modify();
        end;

        ProductionJrnlMgt.DeleteJnlLines(TemplateName, BatchName, ProductionOrder."No.", LineNo);
        ProductionJrnlMgt.CreateJnlLines(ProductionOrder, LineNo);

        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.SetRange("Entry Type", ItemJournalLine."Entry Type"::Consumption);
        ItemJournalLine.ModifyAll(Quantity, 0);
    end;

    local procedure AddLotNo(var ContractMfgLine: Record "SBC Contract Mfg. Line"; var TempItemJournalLine: Record "Item Journal Line" temporary; TemplateName: Code[10]; BatchName: Code[10]; var LineNo: Integer)
    var
        ItemJournalLine: Record "Item Journal Line";
        NewItemJnlLine: Record "Item Journal Line";
        ReceiveQty: Decimal;
        NotFoundErrTxt: Label 'Item %1 not found for Consumption', Comment = '%1 = Item No.';
    begin
        // if ContractMfgLine."SBC Quantity" < 0 then
        //     ReceiveQty := -ContractMfgLine."SBC Quantity";
        ReceiveQty := ABS(ContractMfgLine."SBC Quantity");

        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.SetRange("Item No.", ContractMfgLine."SBC Item No.");
        if ItemJournalLine.IsEmpty then begin
            AddLineError(ContractMfgLine, StrSubstNo(NotFoundErrTxt, ContractMfgLine."SBC Item No."));
            exit;
        end;

        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.SetRange("Item No.", ContractMfgLine."SBC Item No.");
        ItemJournalLine.SetRange("Lot No.", ContractMfgLine."SBC Lot No.");
        if ItemJournalLine.FindLast() then begin
            ItemJournalLine."Posting Date" := ContractMfgLine."SBC Posting Date";
            if ValidateItemJnlQty(ItemJournalLine, TempItemJournalLine, ContractMfgLine."SBC Contract Source", (ItemJournalLine.Quantity + ReceiveQty), ContractMfgLine."SBC Lot No.", ContractMfgLine."SBC UOM Code") then
                if ItemJournalLine.Modify(true) then
                    exit;
        end else begin
            LineNo += 10000;
            ItemJournalLine.Reset();
            ItemJournalLine.SetRange("Journal Template Name", TemplateName);
            ItemJournalLine.SetRange("Journal Batch Name", BatchName);
            ItemJournalLine.SetRange("Item No.", ContractMfgLine."SBC Item No.");
            if ItemJournalLine.FindLast() then begin
                NewItemJnlLine.Init();
                NewItemJnlLine.TransferFields(ItemJournalLine);
                NewItemJnlLine."Posting Date" := ContractMfgLine."SBC Posting Date";
                NewItemJnlLine."Line No." := LineNo;
                NewItemJnlLine."Lot No." := '';
                if ValidateItemJnlQty(NewItemJnlLine, TempItemJournalLine, ContractMfgLine."SBC Contract Source", ReceiveQty, ContractMfgLine."SBC Lot No.", ContractMfgLine."SBC UOM Code") then
                    if NewItemJnlLine.Insert(true) then
                        exit;
            end;
        end;
        AddLineError(ContractMfgLine, '');
    end;

    [TryFunction]
    local procedure ValidateItemJnlQty(var ItemJournalLine: Record "Item Journal Line"; var TempItemJournalLine: Record "Item Journal Line" temporary; ContractSource: Enum "SBC Contract Source"; ReceiveQty: Decimal; LotNo: Code[50]; UOMCode: Code[10])
    var
        AvailableQty: Decimal;
    begin
        ItemJournalLine."Unit of Measure Code" := 'EA';
        ItemJournalLine."Qty. per Unit of Measure" := 1;
        ChangeReceiveQtyToBaseUOM(ReceiveQty, ItemJournalLine."Item No.", UOMCode);
        ItemJournalLine.Validate(Quantity, ReceiveQty);

        // Skip lot tracking for items without Item Tracking Code, or when no lot no. provided in import file
        if IsItemLotTracked(ItemJournalLine."Item No.") and (LotNo <> '') then begin
            ItemJournalLine.Validate("Lot No.", LotNo);
            AvailableQty := FindQuantityAvailableByLot(ItemJournalLine);
            if AvailableQty < ReceiveQty then
                AdjustInventory(TempItemJournalLine, ContractSource, ItemJournalLine, (ReceiveQty - AvailableQty));
        end else
            ItemJournalLine."Lot No." := ''; // Clear lot number when not tracking
    end;

    local procedure AdjustInventory(var TempItemJournalLine: Record "Item Journal Line" temporary; ContractSource: Enum "SBC Contract Source"; ItemJournalLine: Record "Item Journal Line"; AdjustQty: Decimal)
    var
        // ContractMfgSetup: Record "SBC Contract Mfg. Setup";
        LineNo: Integer;
        DocNo: Code[20];
        TemplateName: Code[10];
        BatchName: Code[10];
    begin
        TempItemJournalLine.Reset();
        TempItemJournalLine.SetRange("Item No.", ItemJournalLine."Item No.");
        TempItemJournalLine.SetRange("Lot No.", ItemJournalLine."Lot No.");
        if TempItemJournalLine.FindLast() then begin
            TempItemJournalLine.Validate(Quantity, AdjustQty);
            TempItemJournalLine.Modify();
            exit;
        end;

        if TempItemJournalLine."Document No." = '' then
            GetItemJnlDefault(ContractSource, TempItemJournalLine."Document No.", TemplateName, BatchName, DocNo)
        else begin
            TemplateName := TempItemJournalLine."Journal Template Name";
            BatchName := TempItemJournalLine."Journal Batch Name";
            DocNo := TempItemJournalLine."Document No.";
        end;

        TempItemJournalLine.Reset();
        LineNo := (TempItemJournalLine.Count + 1);
        LineNo := LineNo * 10000;

        TempItemJournalLine.Init();
        TempItemJournalLine."Journal Template Name" := TemplateName;
        TempItemJournalLine."Journal Batch Name" := BatchName;
        TempItemJournalLine."Entry Type" := TempItemJournalLine."Entry Type"::"Positive Adjmt.";
        TempItemJournalLine."Document No." := DocNo;
        TempItemJournalLine."Line No." := LineNo;
        TempItemJournalLine."Posting Date" := CalcDate('<-1D>', ItemJournalLine."Posting Date");
        TempItemJournalLine.Validate("Item No.", ItemJournalLine."Item No.");
        TempItemJournalLine.Validate("Location Code", ItemJournalLine."Location Code");
        TempItemJournalLine.Validate("Unit of Measure Code", ItemJournalLine."Unit of Measure Code");
        TempItemJournalLine.Validate(Quantity, AdjustQty);
        TempItemJournalLine."Lot No." := ItemJournalLine."Lot No.";
        TempItemJournalLine.Description := ItemJournalLine.Description;
        TempItemJournalLine.Insert(false);
    end;

    local procedure GetItemJnlDefault(ContractSource: Enum "SBC Contract Source"; TempDocNo: Code[20]; var TemplateName: Code[10]; var BatchName: Code[10]; var DocNo: Code[20])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LocationCode: Code[10];
    begin
        DocNo := TempDocNo;
        if DocNo = '' then begin
            GetSetup(ContractSource, TemplateName, BatchName, LocationCode);
            if (ItemJournalBatch.Get(TemplateName, BatchName)) and (ItemJournalBatch."No. Series" <> '') then
                DocNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", CalcDate('<-1D>', Today), false)
            else
                DocNo := 'Consumption Adjust.';
        end;
    end;

    local procedure GetLastLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindLast() then;
        exit(ItemJournalLine."Line No.");
    end;

    local procedure PostItemJournal(ContractMfgHeader: Record "SBC Contract Mfg. Header"; var TempItemJournalLine: Record "Item Journal Line" temporary; TemplateName: Code[10]; BatchName: Code[10]; PurchOrderNo: Code[20])
    var
        ItemJournalLine: Record "Item Journal Line";
        ContractMfgSetup: Record "SBC Contract Mfg. Setup";
    // ContractMfgLine: Record "SBC Contract Mfg. Line";
    // PostingError: Text;
    begin
        if HasLineErrors(ContractMfgHeader, TemplateName, BatchName, PurchOrderNo) then
            exit;

        ContractMfgSetup.Get();
        if (ContractMfgSetup."SBC Prod. Order Jnl Template" <> TemplateName) or (ContractMfgSetup."SBC Prod. Order Jnl. Batch" <> BatchName) then begin
            if ContractMfgSetup."SBC Prod. Order Jnl Template" <> TemplateName then
                ContractMfgSetup."SBC Prod. Order Jnl Template" := TemplateName;
            if ContractMfgSetup."SBC Prod. Order Jnl. Batch" <> BatchName then
                ContractMfgSetup."SBC Prod. Order Jnl. Batch" := BatchName;
            ContractMfgSetup.Modify();
        end;

        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.SetRange(Quantity, 0);
        ItemJournalLine.DeleteAll();

        PostAdjustInventory(TempItemJournalLine);
        PostItemJournal(TemplateName, BatchName);
        SetProcessedLines(ContractMfgHeader, PurchOrderNo);
    end;

    local procedure PostItemJournal(TemplateName: Code[10]; BatchName: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.Findfirst() then
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;

    local procedure PostAdjustInventory(var TempItemJournalLine: Record "Item Journal Line" temporary)
    var
        ItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        here: Boolean;
    begin
        TempItemJournalLine.Reset();
        if TempItemJournalLine.FindSet() then begin
            LineNo := GetLastLineNo(TempItemJournalLine."Journal Template Name", TempItemJournalLine."Journal Batch Name");
            repeat
                LineNo += 10000;
                ItemJournalLine.Init();
                ItemJournalLine.TransferFields(TempItemJournalLine);
                ItemJournalLine."Line No." := LineNo;
                ItemJournalLine.Insert();
            until TempItemJournalLine.Next() = 0;
            PostItemJournal(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
        end;
    end;

    local procedure HasLineErrors(ContractMfgHeader: Record "SBC Contract Mfg. Header"; TemplateName: Code[10]; BatchName: Code[10]; PurchOrderNo: Code[20]): Boolean
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        ItemJournalLine: Record "Item Journal Line";
    begin
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractMfgLine.SetRange("SBC Has Line Error", true);
        if ContractMfgLine.IsEmpty then
            exit(false);

        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.DeleteAll();
        exit(true);
    end;

    #endregion processConsumption

    #region createInventoryAdjustment   

    local procedure CreateInvAdjustments(ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        TemplateName: Code[10];
        BatchName: Code[10];
        LocationCode: Code[10];
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        ClearLineErrors(ContractMfgHeader);
        GetItemJnlDefault(TemplateName, BatchName, LocationCode, LineNo, ContractMfgHeader."SBC Contract Source");

        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        if ContractMfgLine.FindSet() then begin
            DocumentNo := GetDocumentNo(TemplateName, BatchName);
            repeat
                if not CreateItemJournal(TemplateName, BatchName, DocumentNo, ContractMfgLine."SBC Item No.",
                    LocationCode, ContractMfgLine."SBC Lot No.", ContractMfgLine."SBC Quantity", LineNo) then
                    AddLineError(ContractMfgLine, '');
            until ContractMfgLine.Next() = 0;
            SetProcessedLines(ContractMfgHeader, '');
            PostItemJournal(TemplateName, BatchName);
        end;
    end;

    local procedure GetItemJnlDefault(var TemplateName: Code[10]; var BatchName: Code[10]; var LocationCode: Code[10]; var LineNo: Integer; ContractSource: Enum "SBC Contract Source")
    begin
        GetSetup(ContractSource, TemplateName, BatchName, LocationCode);
        LineNo := GetLastJnlLineNo(TemplateName, BatchName);
    end;

    local procedure GetSetup(ContractSource: Enum "SBC Contract Source"; var TemplateName: Code[10]; var BatchName: Code[10]; var LocationCode: Code[10])
    var
        ContractMfgSetup: Record "SBC Contract Mfg. Setup";
    begin
        ContractMfgSetup.GetRecordOnce();
        case ContractSource of
            ContractSource::"SBC Menasha":
                begin
                    ContractMfgSetup.TestField("SBC Menasha Item Jnl. Template");
                    ContractMfgSetup.TestField("SBC Menasha Item Jnl. Batch");
                    ContractMfgSetup.TestField("SBC Menasha Item Jnl. Location");

                    TemplateName := ContractMfgSetup."SBC Menasha Item Jnl. Template";
                    BatchName := ContractMfgSetup."SBC Menasha Item Jnl. Batch";
                    LocationCode := ContractMfgSetup."SBC Menasha Item Jnl. Location";
                end;
            ContractSource::"SBC WestRock":
                begin
                    ContractMfgSetup.TestField("SBC WestRock Item Jnl Template");
                    ContractMfgSetup.TestField("SBC WestRock Item Jnl. Batch");
                    ContractMfgSetup.TestField("SBC WestRock Item Jnl Location");

                    TemplateName := ContractMfgSetup."SBC WestRock Item Jnl Template";
                    BatchName := ContractMfgSetup."SBC WestRock Item Jnl. Batch";
                    LocationCode := ContractMfgSetup."SBC WestRock Item Jnl Location";
                end;
        end;
    end;

    local procedure GetDocumentNo(TemplateName: Code[10]; BatchName: Code[10]): Code[20]
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindFirst() then
            exit(ItemJournalLine."Document No.")
        else begin
            ItemJournalBatch.Get(TemplateName, BatchName);
            exit(NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", Today, false));
        end;
    end;

    local procedure GetLastJnlLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
        ConfirmLbl: Label 'Item Journal batch %1 already has lines. Do you want to continue';
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindLast() then
            if GuiAllowed then
                if not Confirm(StrSubstNo(ConfirmLbl, BatchName)) then
                    Error('');

        exit(ItemJournalLine."Line No.");
    end;

    local procedure CreateItemJournal(TemplateName: Code[10]; BatchName: Code[10]; DocumentNo: Code[20]; ItemNo: Code[20]; LocationCode: Code[10]; LotNo: code[50]; TotalQty: Decimal; var LineNo: Integer): Boolean
    var
        ItemJournalLine: Record "Item Journal Line";
        EntryType: Enum "Item Journal Entry Type";
    begin
        CheckAdjustmentQty(EntryType, TotalQty, TemplateName, BatchName, DocumentNo, LocationCode, ItemNo, LotNo, LineNo);
        if TotalQty = 0 then
            exit(true);

        LineNo += 10000;
        ItemJournalLine.Init();
        ItemJournalLine."Journal Template Name" := TemplateName;
        ItemJournalLine."Journal Batch Name" := BatchName;
        ItemJournalLine."Entry Type" := EntryType;
        ItemJournalLine."Document No." := DocumentNo;
        ItemJournalLine."Posting Date" := Today;
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine.validate("Item No.", ItemNo);
        ItemJournalLine.validate("Location Code", LocationCode);
        ItemJournalLine.validate(Quantity, TotalQty);
        // Skip lot tracking for items without Item Tracking Code, or when no lot no. provided in import file
        if IsItemLotTracked(ItemNo) and (LotNo <> '') then
            ItemJournalLine.Validate("Lot No.", LotNo)
        else
            ItemJournalLine."Lot No." := ''; // Clear lot number when not tracking

        if ItemJournalLine.Insert(true) then
            exit(true);
    end;

    local procedure CheckAdjustmentQty(var EntryType: enum "Item Journal Entry Type"; var TotalQty: Decimal; TemplateName: Code[10]; BatchName: Code[10]; DocumentNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; LotNo: Code[50]; LineNo: Integer)
    var
        TempItemJournalLine: Record "Item Journal Line" temporary;
        QtyAvailableByLot: Decimal;
    begin        // Skip lot-based quantity check for non-lot-tracked items or when no lot no. provided in import file
        if (not IsItemLotTracked(ItemNo)) or (LotNo = '') then begin
            // For items without lot tracking in the import, post the quantity as is
            // Set EntryType based on whether quantity is positive or negative
            if TotalQty < 0 then
                EntryType := EntryType::"Negative Adjmt."
            else
                EntryType := EntryType::"Positive Adjmt.";
            TotalQty := Abs(TotalQty);
            exit;
        end;

        CreateTempItemJnlLine(TempItemJournalLine, TemplateName, BatchName, LineNo, ItemNo, LotNo, TotalQty, LocationCode, '', EntryType);
        QtyAvailableByLot := FindQuantityAvailableByLot(TempItemJournalLine);

        if QtyAvailableByLot = TotalQty then begin
            TotalQty := 0;
            exit;
        end;

        GetQtyAdjustment(EntryType, TotalQty, QtyAvailableByLot);
    end;

    local procedure GetQtyAdjustment(var EntryType: enum "Item Journal Entry Type"; var TotalQty: Decimal; QtyAvailableByLot: Decimal)
    var
        AdjustedQty: Decimal;
    begin
        AdjustedQty := TotalQty - QtyAvailableByLot;

        if AdjustedQty < 0 then
            EntryType := EntryType::"Negative Adjmt."
        else
            EntryType := EntryType::"Positive Adjmt.";

        TotalQty := Abs(AdjustedQty);
    end;

    local procedure CreateTempItemJnlLine(var TempItemJournalLine: Record "Item Journal Line" temporary; TemplateName: Code[10]; BatchName: Code[10]; var LineNo: Integer; ItemNo: Code[20]; LotNo: Code[50]; TotalQty: Decimal; LocationCode: Code[10]; LineDescription: Text; EntryType: Enum "Item Journal Entry Type")
    begin
        LineNo += 10000;
        TempItemJournalLine.Reset();
        TempItemJournalLine.Init();
        TempItemJournalLine."Journal Template Name" := TemplateName;
        TempItemJournalLine."Journal Batch Name" := BatchName;
        TempItemJournalLine."Line No." := LineNo;
        TempItemJournalLine."Entry Type" := EntryType;
        TempItemJournalLine."Posting Date" := CalcDate('<-1D>', Today);
        TempItemJournalLine."Location Code" := LocationCode;
        TempItemJournalLine.Description := LineDescription;
        TempItemJournalLine."Item No." := ItemNo;
        TempItemJournalLine.Quantity := TotalQty;
        TempItemJournalLine."Lot No." := LotNo;
        TempItemJournalLine.Insert(false);
    end;

    procedure FindQuantityAvailableByLot(var TempItemJournalLine: Record "Item Journal Line" temporary): Decimal
    var
        TempReservationEntry: Record "Tracking Specification" temporary;
    begin
        TempReservationEntry.Reset();
        TempReservationEntry.InitFromItemJnlLine(TempItemJournalLine);
        TempReservationEntry."Location Code" := TempItemJournalLine."Location Code";
        TempReservationEntry."Lot No." := TempItemJournalLine."Lot No.";
        exit(GetAvailableLotQty(TempReservationEntry))
    end;

    procedure GetAvailableLotQty(var TempReservationEntry: Record "Tracking Specification" temporary): Decimal
    var
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
        AvailableLotQty: Decimal;
    begin
        //check reservations
        if TempReservationEntry."Lot No." = '' then
            exit(0);

        ItemTrackingDataCollection.RetrieveLookupData(TempReservationEntry, true);
        AvailableLotQty := ItemTrackingDataCollection.GetAvailableLotQty(TempReservationEntry);
        exit(AvailableLotQty);
    end;

    local procedure QuantityOnHand(ItemNo: Code[20]; LotNo: Code[50]; LocationCode: Code[10]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange("Lot No.", LotNo);
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        ItemLedgerEntry.CalcSums(Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

    local procedure ReservedQty(ItemNo: Code[20]; LotNo: Code[50]; LocationCode: Code[10]): Decimal
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Item No.", ItemNo);
        ReservationEntry.SetRange("Lot No.", LotNo);
        ReservationEntry.SetRange("Location Code", LocationCode);
        ReservationEntry.CalcSums(Quantity);
        exit(ReservationEntry.Quantity);
    end;

    #endregion createInventoryAdjustment    

    #region addErrors   

    local procedure ClearLineErrors(var ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Has Line Error", true);
        ContractMfgLine.ModifyAll("SBC Has Line Error", false);

        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetFilter("SBC Line Error", '<>%1', '');
        ContractMfgLine.ModifyAll("SBC Line Error", '');
    end;

    local procedure AddLineError(var ContractMfgLine: Record "SBC Contract Mfg. Line"; ErrMessage: Text)
    begin
        ContractMfgLine."SBC Has Line Error" := true;
        ContractMfgLine."SBC Line Processed" := false;
        if ErrMessage <> '' then
            ContractMfgLine."SBC Line Error" := CopyStr(ErrMessage, 1, 250)
        else
            ContractMfgLine."SBC Line Error" := CopyStr(GetLastErrorText(), 1, 250);
        ContractMfgLine.Modify(true);

        AddHeaderErrors(ContractMfgLine."SBC Import Document No.", ContractMfgLine."SBC Contract Source", ContractMfgLine."SBC Contract Type", true);
    end;

    local procedure AddHeaderErrors(DocNo: Code[20]; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; LineError: Boolean)
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
    begin
        if (ContractMfgHeader.Get(DocNo, ContractSource, ContractType)) and (not ContractMfgHeader."SBC Has Line Errors") then begin
            if not LineError then
                ContractMfgHeader."SBC Error Message" := CopyStr(GetLastErrorText(), 1, 250);
            ContractMfgHeader."SBC Has Line Errors" := true;
            ContractMfgHeader.Modify();
        end;
    end;

    local procedure AddPostingError(ContractMfgHeader: Record "SBC Contract Mfg. Header"; PurchOrderNo: Code[20])
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        PostingErr: Text[250];
    begin
        PostingErr := CopyStr(GetLastErrorText(), 1, 250);
        filterContractLines(ContractMfgLine, ContractMfgHeader, false);
        ContractMfgLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractMfgLine.ModifyAll("SBC Line Error", PostingErr);
        ContractMfgLine.ModifyAll("SBC Has Line Error", true);
    end;

    local procedure SetProcessedLines(ContractMfgHeader: Record "SBC Contract Mfg. Header"; PurchOrderNo: Code[20])
    var
        ContractLine: Record "SBC Contract Mfg. Line";
    begin
        filterContractLines(ContractLine, ContractMfgHeader, false);
        ContractLine.SetRange("SBC Purchase Order No.", PurchOrderNo);
        ContractLine.SetRange("SBC Has Line Error", false);
        ContractLine.ModifyAll("SBC Line Processed", true);
        ContractLine.ModifyAll("SBC Line Error", '');
    end;

    #endregion addErrors    

    #region helperFunctions

    local procedure IsItemLotTracked(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit(false);
        exit(Item."Item Tracking Code" <> '');
    end;

    local procedure ChangeReceiveQtyToBaseUOM(var Qty: Decimal; ItemNo: Code[20]; UOMCode: Code[10])
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        if ItemUnitofMeasure.Get(ItemNo, UOMCode) then
            Qty *= ItemUnitofMeasure."Qty. per Unit of Measure";
    end;

    #endregion helperFunctions

    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure ProcessOtherContract(var ContractMfgHeader: Record "SBC Contract Mfg. Header")
    begin
    end;

    #endregion eventIntegration
}