codeunit 50359 "SBC Blind Receipt Import"
{

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    #region import

    procedure Import()
    var
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        FromFile: Text;
        SheetName: Text;
        MaxRowNo: Integer;
        RowNo: Integer;
        EntryNo: Integer;
    begin
        UploadIntoStream('Upload Excel', '', '', FromFile, InStream);
        if FromFile <> '' then begin
            SheetName := TempExcelBuffer.SelectSheetsNameStream(InStream);

            TempExcelBuffer.Reset();
            TempExcelBuffer.DeleteAll();
            TempExcelBuffer.OpenBookStream(InStream, SheetName);
            TempExcelBuffer.ReadSheet();

            if TempExcelBuffer.FindLast() then
                MaxRowNo := TempExcelBuffer."Row No.";

            TempExcelBuffer.Reset();
            for RowNo := 4 to MaxRowNo do
                Import(RowNo);
        end;
    end;

    local procedure Import(RowNo: Integer)
    var
        SBCBlindReceipt: Record "SBC Blind Receipt";
    begin
        SBCBlindReceipt.Init();
        SBCBlindReceipt.Validate("SBC Report Date", GetDateAtCell(RowNo, 1));
        SBCBlindReceipt.Validate("SBC Supplier ID", GetValueAtCell(RowNo, 2));
        SBCBlindReceipt.Validate("SBC Load ID", GetValueAtCell(RowNo, 3));
        SBCBlindReceipt.Validate("SBC BOL No.", GetValueAtCell(RowNo, 4));
        SBCBlindReceipt.Validate("SBC Purchase Order No.", GetValueAtCell(RowNo, 5));
        SBCBlindReceipt.Validate("SBC Item No.", GetValueAtCell(RowNo, 6));
        SBCBlindReceipt.Validate("SBC Lot No.", GetValueAtCell(RowNo, 7));
        SBCBlindReceipt.Validate("SBC Case Qty", GetDecimalAtCell(RowNo, 8));
        if RecordExists(RowNo, SBCBlindReceipt) then
            exit
        else begin
            SBCBlindReceipt.Insert(true);
            TestLinePosted(SBCBlindReceipt);
        end;
    end;

    local procedure RecordExists(StartEntryNo: Integer; NewBlindReceipt: Record "SBC Blind Receipt"): Boolean
    var
        SBCBlindReceipt: Record "SBC Blind Receipt";
    begin
        SBCBlindReceipt.SetFilter("SBC Entry No.", '..%1', StartEntryNo);
        SBCBlindReceipt.SetRange("SBC Purchase Order No.", NewBlindReceipt."SBC Purchase Order No.");
        SBCBlindReceipt.SetRange("SBC BOL No.", NewBlindReceipt."SBC BOL No.");
        SBCBlindReceipt.SetRange("SBC Report Date", NewBlindReceipt."SBC Report Date");
        SBCBlindReceipt.SetRange("SBC Load ID", NewBlindReceipt."SBC Load ID");
        SBCBlindReceipt.SetRange("SBC Lot No.", NewBlindReceipt."SBC Lot No.");
        SBCBlindReceipt.SetRange("SBC Case Qty", NewBlindReceipt."SBC Case Qty");
        if not SBCBlindReceipt.IsEmpty then
            exit(true);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, columnNo) then
            exit(TempExcelBuffer."Cell Value as Text");
    end;

    local procedure GetDateAtCell(RowNo: Integer; ColumnNo: Integer): Date
    var
        TxtVar: Text;
        Value: Date;
    begin
        TxtVar := GetValueAtCell(RowNo, ColumnNo);
        if TxtVar = '' then
            exit(0D);

        Evaluate(Value, TxtVar);
        exit(Value);
    end;

    local procedure GetDecimalAtCell(RowNo: Integer; ColumnNo: Integer): Decimal
    var
        TxtVar: Text;
        Value: Decimal;
    begin
        TxtVar := GetValueAtCell(RowNo, ColumnNo);
        if TxtVar = '' then
            exit(0);

        Evaluate(Value, TxtVar);
        exit(Value);
    end;

    local procedure TestLinePosted(BlindReceipt: Record "SBC Blind Receipt")
    var
        SBCBlindReceipt: Record "SBC Blind Receipt";
        LedgerExistLbl: Label 'An Item Ledger Line for Order %1 BOL %2 Item No. %3 Lot No. %4 and Quantity (Base) %5 already exists.', Comment = '%1 = Order No., %2 = BOL No., %3 = Item No., %4 = Lot No., %5 = Quantity';
    begin
        SBCBlindReceipt.SetRange("SBC Purchase Order No.", BlindReceipt."SBC Purchase Order No.");
        SBCBlindReceipt.SetRange("SBC BOL No.", BlindReceipt."SBC BOL No.");
        SBCBlindReceipt.SetRange("SBC Item No.", BlindReceipt."SBC Item No.");
        SBCBlindReceipt.SetRange("SBC Lot No.", BlindReceipt."SBC Lot No.");
        if SBCBlindReceipt.FindSet() then begin
            SBCBlindReceipt.CalcSums("SBC Quantity (Base)");
            if LedgerExists(SBCBlindReceipt) then begin
                SBCBlindReceipt.ModifyAll("SBC Do Not Process", true);
                SBCBlindReceipt.ModifyAll("SBC Error Message", StrSubstNo(LedgerExistLbl, BlindReceipt."SBC Purchase Order No.", BlindReceipt."SBC BOL No.", BlindReceipt."SBC Item No.", BlindReceipt."SBC Lot No.", SBCBlindReceipt."SBC Quantity (Base)"));
            end;
        end;
    end;

    #endregion import

    #region process

    procedure ProcessBlindReceipts()
    var
        BlindRecDict: Dictionary of [Code[20], list of [Code[35]]];
        BOLList: list of [Code[35]];
        BOL: Code[35];
        OrderNo: Code[20];
        i: Integer;
    begin
        GetBlindReceipts(BlindRecDict);
        foreach BOLList in BlindRecDict.Values do begin
            i += 1;
            BlindRecDict.Keys.Get(i, OrderNo);
            foreach BOL in BOLList do
                ProcessBlindReceipt(OrderNo, BOL);
        end;
        UpdatePosted();
    end;

    local procedure ProcessBlindReceipt(DocNo: Code[20]; BOLNo: Code[35])
    var
        SBCBlindReceipt: Record "SBC Blind Receipt";
        ErrorMsg: Text[500];
        HasError: Boolean;
    begin
        SBCBlindReceipt.Reset();
        SBCBlindReceipt.SetRange("SBC Purchase Order No.", DocNo);
        SBCBlindReceipt.SetRange("SBC BOL No.", BOLNo);
        SBCBlindReceipt.SetRange("SBC Processed", false);
        SBCBlindReceipt.SetRange("SBC Posted", false);
        SBCBlindReceipt.SetRange("SBC Do Not Process", false);
        if SBCBlindReceipt.FindSet(true) then begin
            if not OrderStatusReleased(DocNo) then begin
                SBCBlindReceipt.ModifyAll("SBC Error Message", CopyStr(GetLastErrorText(), 1, 500));
                exit;
            end;
            ClearQtyRcd(SBCBlindReceipt."SBC Purchase Order No.");
            repeat
                SBCBlindReceipt."SBC Error Message" := '';
                if SetItemTrackingLine(SBCBlindReceipt) then
                    SBCBlindReceipt."SBC Processed" := true
                else
                    SBCBlindReceipt."SBC Do Not Process" := true;
                SBCBlindReceipt.Modify();
            until SBCBlindReceipt.Next() = 0;
            PostOrders(SBCBlindReceipt."SBC Purchase Order No.", SBCBlindReceipt."SBC BOL No.", SBCBlindReceipt."SBC Report Date");
        end;
    end;

    local procedure GetBlindReceipts(var BlindRecDict: Dictionary of [Code[20], list of [Code[35]]])
    var
        SBCBlindReceipt: Query "SBC Blind Receipt";
        BOLList: list of [Code[35]];
    begin
        SBCBlindReceipt.SetRange(SBCPosted, false);
        SBCBlindReceipt.SetRange(SBCProcessed, false);
        SBCBlindReceipt.SetRange(SBCDoNotProcess, false);
        SBCBlindReceipt.Open();
        while SBCBlindReceipt.Read() do begin
            clear(BOLList);
            if not BlindRecDict.ContainsKey(SBCBlindReceipt.SBCPurchaseOrderNo) then
                BlindRecDict.Add(SBCBlindReceipt.SBCPurchaseOrderNo, BOLList);
            BOLList := BlindRecDict.Get(SBCBlindReceipt.SBCPurchaseOrderNo);
            if not BOLList.Contains(SBCBlindReceipt.SBCBOLNo) then
                BOLList.Add(SBCBlindReceipt.SBCBOLNo);
            BlindRecDict.Set(SBCBlindReceipt.SBCPurchaseOrderNo, BOLList);
        end;
        SBCBlindReceipt.Close();
    end;

    [TryFunction]
    local procedure OrderStatusReleased(DocNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocNo);
        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Released);
    end;

    local procedure ClearQtyRcd(DocNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", DocNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine.Validate("Qty. to Receive", 0);
                PurchaseLine.Modify(true);
            until PurchaseLine.Next() = 0;
    end;

    local procedure SetItemTrackingLine(var SBCBlindReceipt: Record "SBC Blind Receipt"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        QtyPerUOM: Decimal;
        QtyRcd: Decimal;
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", SBCBlindReceipt."SBC Purchase Order No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", SBCBlindReceipt."SBC Item No.");
        if PurchaseLine.FindFirst() then begin
            if SBCBlindReceipt.GetCaseUOMCode() <> PurchaseLine."Unit of Measure Code" then begin
                QtyPerUOM := GetItemPerUOM(PurchaseLine."No.", PurchaseLine."Unit of Measure Code");
                QtyRcd := (SBCBlindReceipt."SBC Quantity (Base)" / QtyPerUOM);
            end else begin
                QtyPerUOM := SBCBlindReceipt."SBC Qty Per UOM";
                QtyRcd := SBCBlindReceipt."SBC Case Qty";
            end;

            QtyRcd += PurchaseLine."Qty. to Receive";
            if OveragesAllowed(PurchaseLine, QtyRcd) then begin
                PurchaseLine.Validate("Qty. to Receive", QtyRcd);
                if CreateReservationEntry(ReservationEntry, PurchaseLine, SBCBlindReceipt."SBC Lot No.", QtyPerUOM, QtyRcd, SBCBlindReceipt."SBC Quantity (Base)") then
                    if ReservationEntry.Insert(true) then
                        if PurchaseLine.Modify(true) then
                            exit(true);
            end;
            SBCBlindReceipt."SBC Error Message" := CopyStr(GetLastErrorText(), 1, 500);
        end;
        exit(false);
    end;

    [TryFunction]
    local procedure OveragesAllowed(xPurchaseLine: Record "Purchase Line"; QtyRcd: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
    begin
        if (xPurchaseLine.Quantity - xPurchaseLine."Quantity Received") >= QtyRcd then
            exit;

        PurchaseLine := xPurchaseLine;
        PurchaseLine."Qty. to Receive" := QtyRcd;
        PurchaseLine."Over-Receipt Quantity" := Abs(QtyRcd - (xPurchaseLine.Quantity - xPurchaseLine."Quantity Received"));
        OverReceiptMgt.VerifyOverReceiptQuantity(PurchaseLine, xPurchaseLine);
    end;

    [TryFunction]
    local procedure CreateReservationEntry(var ReservationEntry: Record "Reservation Entry"; PurchaseLine: Record "Purchase Line"; LotNo: Code[50]; QtyPerUOM: Decimal; QtyRcd: Decimal; QtyBase: Decimal)
    begin
        ReservationEntry.Reset();
        ReservationEntry.Init();
        ReservationEntry."Entry No." := GetLastEntryNo() + 1;
        ReservationEntry."Source Type" := Database::"Purchase Line";
        ReservationEntry."Source ID" := PurchaseLine."Document No.";
        ReservationEntry."Source Ref. No." := PurchaseLine."Line No.";
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Creation Date" := Today;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry."Created By" := USERID;

        ReservationEntry.Validate("Item No.", PurchaseLine."No.");
        ReservationEntry.Validate("Location Code", PurchaseLine."Location Code");
        ReservationEntry.Validate("Lot No.", LotNo);
        ReservationEntry.Validate("Qty. per Unit of Measure", QtyPerUOM);

        ReservationEntry.Validate("Source Subtype", 1);
        ReservationEntry.Validate("Expected Receipt Date", PurchaseLine."Expected Receipt Date");
        ReservationEntry.Validate("Quantity", QtyRcd);
        ReservationEntry.Validate(Positive, true);
        ReservationEntry.Validate("Quantity (Base)", QtyBase);
    end;

    local procedure GetLastEntryNo(): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        if ReservationEntry.FindLast() then
            exit(ReservationEntry."Entry No.");
    end;

    local procedure GetItemPerUOM(ItemNo: Code[20]; PurchUOM: Code[10]): Decimal
    var
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        Item.Get(ItemNo);
        if Item."Base Unit of Measure" = PurchUOM then
            exit(1);

        ItemUnitofMeasure.Get(ItemNo, PurchUOM);
        exit(ItemUnitofMeasure."Qty. per Unit of Measure");
    end;

    #endregion process

    #region post

    local procedure PostOrders(DocNo: Code[20]; BOLNo: Code[35]; PostDate: Date)
    var
        PurchaseHeader: Record "Purchase Header";
        SBCBlindReceipt: Record "SBC Blind Receipt";
    begin
        SBCBlindReceipt.SetRange("SBC Purchase Order No.", DocNo);
        SBCBlindReceipt.SetRange("SBC BOL No.", BOLNo);
        SBCBlindReceipt.SetRange("SBC Processed", true);
        SBCBlindReceipt.SetRange("SBC Posted", false);
        if SBCBlindReceipt.IsEmpty then
            exit;

        PurchaseHeader.Reset();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocNo);
        PurchaseHeader.Validate("Vendor Shipment No.", BOLNo);
        PurchaseHeader.Validate("Posting Date", PostDate);
        PurchaseHeader.Invoice := false;
        PurchaseHeader.Receive := true;
        PurchaseHeader.Modify(true);

        Codeunit.Run(Codeunit::"Purch.-Post", PurchaseHeader);
    end;

    local procedure UpdatePosted()
    var
        SBCBlindReceipt: Record "SBC Blind Receipt";
        TempSBCBlindReceipt: Record "SBC Blind Receipt" temporary;
    begin
        SBCBlindReceipt.SetRange("SBC Posted", false);
        SBCBlindReceipt.SetRange("SBC Processed", true);
        if SBCBlindReceipt.FindSet() then
            repeat
                if LedgerExists(SBCBlindReceipt) then begin
                    SBCBlindReceipt."SBC Posted" := true;
                    SBCBlindReceipt.Modify();
                end;
            until SBCBlindReceipt.Next() = 0;

        SBCBlindReceipt.Reset();
        SBCBlindReceipt.SetRange("SBC Posted", false);
        SBCBlindReceipt.SetRange("SBC Processed", true);
        if not SBCBlindReceipt.FindSet() then
            exit
        else
            repeat
                TempSBCBlindReceipt.Reset();
                TempSBCBlindReceipt.SetRange("SBC Purchase Order No.", SBCBlindReceipt."SBC Purchase Order No.");
                TempSBCBlindReceipt.SetRange("SBC BOL No.", SBCBlindReceipt."SBC BOL No.");
                TempSBCBlindReceipt.SetRange("SBC Item No.", SBCBlindReceipt."SBC Item No.");
                TempSBCBlindReceipt.SetRange("SBC Lot No.", SBCBlindReceipt."SBC Lot No.");
                if TempSBCBlindReceipt.IsEmpty then begin
                    TempSBCBlindReceipt := SBCBlindReceipt;
                    TempSBCBlindReceipt.Insert(false);
                end;
            until SBCBlindReceipt.Next() = 0;

        TempSBCBlindReceipt.Reset();
        if TempSBCBlindReceipt.FindSet() then
            repeat
                SBCBlindReceipt.Reset();
                SBCBlindReceipt.SetRange("SBC Purchase Order No.", TempSBCBlindReceipt."SBC Purchase Order No.");
                SBCBlindReceipt.SetRange("SBC BOL No.", TempSBCBlindReceipt."SBC BOL No.");
                SBCBlindReceipt.SetRange("SBC Item No.", TempSBCBlindReceipt."SBC Item No.");
                SBCBlindReceipt.SetRange("SBC Lot No.", TempSBCBlindReceipt."SBC Lot No.");
                if SBCBlindReceipt.FindSet() then begin
                    SBCBlindReceipt.CalcSums("SBC Quantity (Base)");
                    TempSBCBlindReceipt."SBC Quantity (Base)" := SBCBlindReceipt."SBC Quantity (Base)";
                    if LedgerExists(tempSBCBlindReceipt) then begin
                        SBCBlindReceipt.ModifyAll("SBC Posted", true);
                    end;
                end;
            until tempSBCBlindReceipt.Next() = 0;
    end;

    procedure LedgerExists(var SBCBlindReceipt: Record "SBC Blind Receipt"): Boolean
    var
        SBCPostedReceipt: Query "SBC Posted Receipt";
    begin
        SBCPostedReceipt.SetRange(OrderNo, SBCBlindReceipt."SBC Purchase Order No.");
        SBCPostedReceipt.SetRange(VendorShipmentNo, SBCBlindReceipt."SBC BOL No.");
        SBCPostedReceipt.SetRange(ItemNo, SBCBlindReceipt."SBC Item No.");
        SBCPostedReceipt.SetRange(Lot_No_, SBCBlindReceipt."SBC Lot No.");
        SBCPostedReceipt.SetRange(Quantity, SBCBlindReceipt."SBC Quantity (Base)");
        SBCPostedReceipt.Open();
        while SBCPostedReceipt.Read() do
            exit(true);
        SBCPostedReceipt.Close();
    end;

    #endregion post

}
