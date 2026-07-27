codeunit 50351 "SBC Import Contract ProdMgmt."
{
    procedure ImportProductionConsumption(var TempExcelBuffer: Record "Excel Buffer" temporary; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; ImportDocNo: Code[20]; SheetName: Text; MaxRowNo: Integer): Boolean
    var
        HasLineErrors: Boolean;
    begin
        if ContractType = ContractType::"SBC Consumption" then
            ImportConsumptionSummary(TempExcelBuffer, ContractSource, ContractType, ImportDocNo, MaxRowNo, HasLineErrors)
        else
            ImportFGSummary(TempExcelBuffer, ContractSource, ContractType, ImportDocNo, MaxRowNo, HasLineErrors);

        exit(HasLineErrors);
    end;

    #region importProductionConsumption 

    #region importConsumptionSummary

    local procedure ImportConsumptionSummary(var TempExcelBuffer: Record "Excel Buffer" temporary; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; ImportDocNo: Code[20]; MaxRowNo: Integer; var HasLineErrors: Boolean)
    var
        ConContractMfgLine: Record "SBC Contract Mfg. Line";
        StartRow: Integer;
        POColumnNo: Integer;
        PostingDateColumnNo: Integer;
        ItemNoColumnNo: Integer;
        LocationCodeColumnNo: Integer;
        QuantityColumnNo: Integer;
        UOMCodeColumnNo: Integer;
        LotNoColumnNo: Integer;
        PurchOrderNo: Code[20];
        ProdOrderNo: Code[20];
        RowNo: Integer;
        LineNo: Integer;
    begin
        case ContractSource of
            ContractSource::"SBC Menasha":
                ConsumptionMappingMenasha(StartRow, POColumnNo, PostingDateColumnNo, ItemNoColumnNo, LocationCodeColumnNo, QuantityColumnNo, UOMCodeColumnNo, LotNoColumnNo);
            ContractSource::"SBC WestRock":
                ConsumptionMappingWestRock(StartRow, POColumnNo, PostingDateColumnNo, ItemNoColumnNo, LocationCodeColumnNo, QuantityColumnNo, UOMCodeColumnNo, LotNoColumnNo);
        end;

        for RowNo := StartRow to MaxRowNo do begin
            InitContractMfgLine(ConContractMfgLine, ContractSource, ContractType, LineNo, ImportDocNo);
            ConContractMfgLine."SBC Purchase Order No." := GetValueAtCell(TempExcelBuffer, RowNo, POColumnNo);
            ConContractMfgLine."SBC Posting Date" := EvaluateDate(TempExcelBuffer, RowNo, PostingDateColumnNo);
            ConContractMfgLine."SBC Item No." := GetValueAtCell(TempExcelBuffer, RowNo, ItemNoColumnNo);
            ConContractMfgLine."SBC Location Code" := GetValueAtCell(TempExcelBuffer, RowNo, LocationCodeColumnNo);
            ConContractMfgLine."SBC Quantity" := EvaluateDecimal(TempExcelBuffer, RowNo, QuantityColumnNo);
            ConContractMfgLine."SBC UOM Code" := GetValueAtCell(TempExcelBuffer, RowNo, UOMCodeColumnNo);
            ConContractMfgLine."SBC UOM Code" := GetValueAtCell(TempExcelBuffer, RowNo, UOMCodeColumnNo);
            ConContractMfgLine."SBC Lot No." := GetValueAtCell(TempExcelBuffer, RowNo, LotNoColumnNo);
            UpdateLineByContractSourceBeforeInsert(ConContractMfgLine);
            if not ValidateTableRelatedValues(ConContractMfgLine) then begin
                ConContractMfgLine."SBC Line Error" := CopyStr(GetLastErrorText(), 1, 250);
                ConContractMfgLine."SBC Has Line Error" := true;
                HasLineErrors := true;
            end;
            ConContractMfgLine."SBC Production Order No." := GetProdOrderNo(ConContractMfgLine."SBC Purchase Order No.", PurchOrderNo, ProdOrderNo);
            ConContractMfgLine.Insert(true);
        end;
    end;

    // local procedure ImportConsumptionSummary(var TempExcelBuffer: Record "Excel Buffer" temporary; ContractType: Enum "SBC Contract Type"; ImportDocNo: Code[20]; MaxRowNo: Integer; var HasLineErrors: Boolean)
    // var
    //     ConContractMfgLine: Record "SBC Contract Mfg. Line";
    //     PurchOrderNo: Code[20];
    //     ProdOrderNo: Code[20];
    //     RowNo: Integer;
    //     LineNo: Integer;
    // begin
    //     for RowNo := 9 to MaxRowNo do begin
    //         InitContractMfgLine(ConContractMfgLine, ContractType, LineNo, ImportDocNo);
    //         ConContractMfgLine."SBC Purchase Order No." := GetValueAtCell(TempExcelBuffer, RowNo, 1);
    //         ConContractMfgLine."SBC Posting Date" := EvaluateDate(TempExcelBuffer, RowNo, 2);
    //         ConContractMfgLine."SBC Item No." := GetValueAtCell(TempExcelBuffer, RowNo, 3);
    //         ConContractMfgLine."SBC Location Code" := GetValueAtCell(TempExcelBuffer, RowNo, 4);
    //         ConContractMfgLine."SBC Quantity" := EvaluateDecimal(TempExcelBuffer, RowNo, 5);
    //         ConContractMfgLine."SBC UOM Code" := GetValueAtCell(TempExcelBuffer, RowNo, 6);
    //         ConContractMfgLine."SBC Lot No." := GetValueAtCell(TempExcelBuffer, RowNo, 7);
    //         if not ValidateTableRelatedValues(ConContractMfgLine) then begin
    //             ConContractMfgLine."SBC Line Error" := CopyStr(GetLastErrorText(), 1, 250);
    //             ConContractMfgLine."SBC Has Line Error" := true;
    //             HasLineErrors := true;
    //         end;
    //         ConContractMfgLine."SBC Production Order No." := GetProdOrderNo(ConContractMfgLine."SBC Purchase Order No.", PurchOrderNo, ProdOrderNo);
    //         ConContractMfgLine.Insert(true);
    //     end;
    // end;

    local procedure GetProdOrderNo(NewPurchOrderNo: Code[20]; var PurchOrderNo: Code[20]; var ProdOrderNo: Code[20]): Code[20]
    var
        ProductionOrder: Record "Production Order";
    begin
        if NewPurchOrderNo <> PurchOrderNo then begin
            PurchOrderNo := NewPurchOrderNo;

            ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
            ProductionOrder.SetRange("SBC Subcontracting Purch.Order", PurchOrderNo);
            if ProductionOrder.FindFirst() then;
            ProdOrderNo := ProductionOrder."No.";
        end;
        exit(ProdOrderNo)
    end;

    [TryFunction]
    local procedure ValidateTableRelatedValues(var ConContractMfgLine: Record "SBC Contract Mfg. Line")
    var
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, ConContractMfgLine."SBC Purchase Order No.");
        Item.Get(ConContractMfgLine."SBC Item No.");
    end;

    local procedure InitContractMfgLine(var ContractMfgLine: Record "SBC Contract Mfg. Line"; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; var LineNo: Integer; ImportDocNo: Code[20])
    begin
        LineNo += 10000;
        ContractMfgLine.Reset();
        ContractMfgLine.Init();
        ContractMfgLine."SBC Import Document No." := ImportDocNo;
        ContractMfgLine."SBC Contract Source" := ContractSource;
        ContractMfgLine."SBC Contract Type" := ContractType;
        ContractMfgLine."SBC Line No." := LineNo;
    end;

    #endregion importConsumptionSummary

    #region importFGSummary

    local procedure ImportFGSummary(var TempExcelBuffer: Record "Excel Buffer" temporary; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; ImportDocNo: Code[20]; MaxRowNo: Integer; var HasLineErrors: Boolean): Boolean
    var
        FGContractMfgLine: Record "SBC Contract Mfg. Line";
        startRow: Integer;
        POColumnNo: Integer;
        ItemColumnNo: Integer;
        DescColumnNo: Integer;
        QuantityColumnNo: Integer;
        MatTypeColumnNo: Integer;
        SLEDBBDColumnNo: Integer;
        LotNoColumnNo: Integer;
        PostingDateColumnNo: Integer;
        CustomerRef: Text[50];
        ItemNo: Text[20];
        MatDescription: Text[100];
        PurchOrderNo: Code[20];
        ProdOrderNo: Code[20];
        RowNo: Integer;
        LineNo: Integer;
    begin
        case ContractSource of
            ContractSource::"SBC Menasha":
                FGMappingMenasha(RowNo, POColumnNo, ItemColumnNo, DescColumnNo, QuantityColumnNo, MatTypeColumnNo, SLEDBBDColumnNo, LotNoColumnNo, PostingDateColumnNo);
        end;
        for RowNo := 11 to MaxRowNo do begin
            InitContractMfgLine(FGContractMfgLine, ContractSource, ContractType, LineNo, ImportDocNo);
            FGContractMfgLine."SBC Purchase Order No." := SetFieldValue(TempExcelBuffer, CustomerRef, RowNo, POColumnNo);
            FGContractMfgLine."SBC Item No." := SetFieldValue(TempExcelBuffer, ItemNo, RowNo, ItemColumnNo);
            FGContractMfgLine."SBC Description" := SetFieldValue(TempExcelBuffer, MatDescription, RowNo, DescColumnNo);
            FGContractMfgLine."SBC Quantity" := EvaluateDecimal(TempExcelBuffer, RowNo, QuantityColumnNo);
            FGContractMfgLine."SBC Material Type" := GetValueAtCell(TempExcelBuffer, RowNo, MatTypeColumnNo);
            FGContractMfgLine."SBC SLED/BBD" := EvaluateDate(TempExcelBuffer, RowNo, SLEDBBDColumnNo);
            FGContractMfgLine."SBC Lot No." := GetValueAtCell(TempExcelBuffer, RowNo, LotNoColumnNo);
            FGContractMfgLine."SBC Posting Date" := EvaluateDate(TempExcelBuffer, RowNo, PostingDateColumnNo);
            if not ValidateTableRelatedValues(FGContractMfgLine) then begin
                FGContractMfgLine."SBC Line Error" := CopyStr(GetLastErrorText(), 1, 250);
                FGContractMfgLine."SBC Has Line Error" := true;
                HasLineErrors := true;
            end;
            FGContractMfgLine."SBC Production Order No." := GetProdOrderNo(FGContractMfgLine."SBC Purchase Order No.", PurchOrderNo, ProdOrderNo);
            if ProdOrderNo = '' then begin
                FGContractMfgLine."SBC Line Error" := 'Production Order not found';
                FGContractMfgLine."SBC Has Line Error" := true;
            end;
            FGContractMfgLine.Insert(true);
        end;
    end;

    // local procedure ImportFGSummary(var TempExcelBuffer: Record "Excel Buffer" temporary; ContractType: Enum "SBC Contract Type"; ImportDocNo: Code[20]; MaxRowNo: Integer; var HasLineErrors: Boolean): Boolean
    // var
    //     FGContractMfgLine: Record "SBC Contract Mfg. Line";
    //     CustomerRef: Text[50];
    //     ItemNo: Text[20];
    //     MatDescription: Text[100];
    //     PurchOrderNo: Code[20];
    //     ProdOrderNo: Code[20];
    //     RowNo: Integer;
    //     LineNo: Integer;
    // begin
    //     for RowNo := 11 to MaxRowNo do begin
    //         InitContractMfgLine(FGContractMfgLine, ContractType, LineNo, ImportDocNo);
    //         FGContractMfgLine."SBC Purchase Order No." := SetFieldValue(TempExcelBuffer, CustomerRef, RowNo, 1);
    //         FGContractMfgLine."SBC Item No." := SetFieldValue(TempExcelBuffer, ItemNo, RowNo, 2);
    //         FGContractMfgLine."SBC Description" := SetFieldValue(TempExcelBuffer, MatDescription, RowNo, 3);
    //         FGContractMfgLine."SBC Quantity" := EvaluateDecimal(TempExcelBuffer, RowNo, 4);
    //         FGContractMfgLine."SBC Material Type" := GetValueAtCell(TempExcelBuffer, RowNo, 5);
    //         FGContractMfgLine."SBC SLED/BBD" := EvaluateDate(TempExcelBuffer, RowNo, 6);
    //         FGContractMfgLine."SBC Lot No." := GetValueAtCell(TempExcelBuffer, RowNo, 7);
    //         FGContractMfgLine."SBC Posting Date" := EvaluateDate(TempExcelBuffer, RowNo, 8);
    //         if not ValidateTableRelatedValues(FGContractMfgLine) then begin
    //             FGContractMfgLine."SBC Line Error" := CopyStr(GetLastErrorText(), 1, 250);
    //             FGContractMfgLine."SBC Has Line Error" := true;
    //             HasLineErrors := true;
    //         end;
    //         FGContractMfgLine."SBC Production Order No." := GetProdOrderNo(FGContractMfgLine."SBC Purchase Order No.", PurchOrderNo, ProdOrderNo);
    //         FGContractMfgLine.Insert(true);
    //     end;
    // end;

    #endregion importFGSummary

    #region getCellValue

    local procedure GetValueAtCell(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColumnNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure EvaluateDate(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Date
    var
        DateTxt: Text;
        DateVar: Date;
    begin
        DateTxt := GetValueAtCell(TempExcelBuffer, RowNo, ColumnNo);
        Evaluate(DateVar, DateTxt);
        exit(DateVar);
    end;

    local procedure EvaluateDecimal(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Decimal
    var
        DecimalTxt: Text;
        DecVar: Decimal;
    begin
        DecimalTxt := GetValueAtCell(TempExcelBuffer, RowNo, ColumnNo);
        Evaluate(DecVar, DecimalTxt);
        exit(DecVar);
    end;

    local procedure SetFieldValue(var TempExcelBuffer: Record "Excel Buffer" temporary; var LastRowValue: Text; RowNo: Integer; ColumnNo: Integer): Text
    var
        CellValue: Text;
    begin
        CellValue := GetValueAtCell(TempExcelBuffer, RowNo, ColumnNo);
        if CellValue <> '' then
            LastRowValue := CellValue;
        exit(LastRowValue);
    end;

    #endregion getCellValue

    #endregion importProductionConsumption  

    #region mappingImport

    local procedure ConsumptionMappingMenasha(var StartRow: Integer; var POColumnNo: Integer; var PostingDateColumnNo: Integer; var ItemNoColumnNo: Integer; var LocationCodeColumnNo: Integer; var QuantityColumnNo: Integer; var UOMCodeColumnNo: Integer; var LotNoColumnNo: Integer)
    begin
        StartRow := 9;
        POColumnNo := 1;
        PostingDateColumnNo := 2;
        ItemNoColumnNo := 3;
        LocationCodeColumnNo := 4;
        QuantityColumnNo := 5;
        UOMCodeColumnNo := 6;
        LotNoColumnNo := 7;
    end;

    local procedure ConsumptionMappingWestRock(var StartRow: Integer; var POColumnNo: Integer; var PostingDateColumnNo: Integer; var ItemNoColumnNo: Integer; var LocationCodeColumnNo: Integer; var QuantityColumnNo: Integer; var UOMCodeColumnNo: Integer; var LotNoColumnNo: Integer)
    begin
        StartRow := 8;
        POColumnNo := 10;
        PostingDateColumnNo := 2;
        ItemNoColumnNo := 4;
        LocationCodeColumnNo := 0;
        QuantityColumnNo := 9;
        UOMCodeColumnNo := 0;
        LotNoColumnNo := 6;
    end;

    local procedure FGMappingMenasha(var StartRow: Integer; var POColumnNo: Integer; var ItemColumnNo: Integer; var DescColumnNo: Integer; var QuantityColumnNo: Integer; var MatTypeColumnNo: Integer; var SLEDBBDColumnNo: Integer; var LotNoColumnNo: Integer; var PostingDateColumnNo: Integer)
    begin
        StartRow := 11;
        POColumnNo := 1;
        ItemColumnNo := 2;
        DescColumnNo := 3;
        QuantityColumnNo := 4;
        MatTypeColumnNo := 5;
        SLEDBBDColumnNo := 6;
        LotNoColumnNo := 7;
        PostingDateColumnNo := 8;
    end;

    local procedure UpdateLineByContractSourceBeforeInsert(var ContractMfgLine: Record "SBC Contract Mfg. Line")
    var
        ContractMfgSetup: Record "SBC Contract Mfg. Setup";
        TxtVar: Text;
        TextList: List of [Text];
    begin
        ContractMfgSetup.GetRecordOnce();
        case ContractMfgLine."SBC Contract Source" of
            ContractMfgLine."SBC Contract Source"::"SBC WestRock":
                begin
                    TxtVar := ContractMfgLine."SBC Purchase Order No.";
                    TextList := TxtVar.Split('-');
                    ContractMfgLine."SBC Purchase Order No." := TextList.Get(1);
                    ContractMfgLine."SBC Location Code" := ContractMfgSetup."SBC WR Consumption Location";
                    ContractMfgLine."SBC UOM Code" := 'EA';
                end;
        end;
    end;

    #endregion mappingImport

    #region testingOnly

    procedure TestingOnly(ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        ItemJournalLine: Record "Item Journal Line";
        ContractMfgSetup: Record "SBC Contract Mfg. Setup";
        LineNo: Integer;
    begin
        ContractMfgSetup.Get();

        ContractMfgLine.SetRange("SBC Import Document No.", ContractMfgHeader."SBC Import Document No.");
        ContractMfgLine.SetRange("SBC Contract Type", ContractMfgHeader."SBC Contract Type");
        if ContractMfgLine.FindSet() then begin
            repeat
                LineNo += 10000;
                ItemJournalLine.Reset();
                ItemJournalLine.Init();
                ItemJournalLine."Journal Template Name" := ContractMfgSetup."SBC Menasha Item Jnl. Template";
                ItemJournalLine."Journal Batch Name" := ContractMfgSetup."SBC Menasha Item Jnl. Batch";
                ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::"Positive Adjmt.";
                ItemJournalLine."Document No." := 'MEN10070';
                ItemJournalLine."Line No." := LineNo;
                ItemJournalLine."Posting Date" := Today;
                ItemJournalLine.Validate("Item No.", ContractMfgLine."SBC Item No.");
                ItemJournalLine.Validate("Location Code", 'MENASHA');
                ItemJournalLine.Validate(Quantity, -ContractMfgLine."SBC Quantity");
                ItemJournalLine.Validate("Lot No.", ContractMfgLine."SBC Lot No.");
                ItemJournalLine.Insert(true);
            until ContractMfgLine.Next() = 0;
            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", ItemJournalLine);
        end;
    end;

    #endregion testingOnly    
}