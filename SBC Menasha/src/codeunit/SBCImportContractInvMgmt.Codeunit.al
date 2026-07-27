codeunit 50352 "SBC Import Contract Inv Mgmt"
{
    procedure ImportInventorySummary(var TempExcelBuffer: Record "Excel Buffer" temporary; ContractSource: Enum "SBC Contract Source"; ImportDocNo: Code[20]; MaxRowNo: Integer): Boolean
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        StartRowNo: Integer;
        MatGroupDescColumnNo: Integer;
        ItemNoColumnNo: Integer;
        DescriptionColumnNo: Integer;
        QtyColumnNo: Integer;
        LotNoColumnNo: Integer;        
        RowNo: Integer;
        LineNo: Integer;
        ItemNo: Code[20];
        LotNo: Code[50];
        Description: Text[100];
        MatGroupDesc: Text[100];
        AltTotalQty: Decimal;
    begin
        case ContractSource of
            ContractSource::"SBC Menasha":
                InvMappingMenasha(StartRowNo, MatGroupDescColumnNo, ItemNoColumnNo, DescriptionColumnNo, QtyColumnNo, LotNoColumnNo);
            ContractSource::"SBC WestRock":
                InvMappingWestRock(StartRowNo, MatGroupDescColumnNo, ItemNoColumnNo, DescriptionColumnNo, QtyColumnNo, LotNoColumnNo);
        end;
        for RowNo := StartRowNo to MaxRowNo do begin
            MatGroupDesc := GetValueAtCell(TempExcelBuffer, RowNo, MatGroupDescColumnNo);
            if not matGroupDesc.Contains('Labor') then begin
                ItemNo := GetValueAtCell(TempExcelBuffer, RowNo, ItemNoColumnNo);
                Description := GetValueAtCell(TempExcelBuffer, RowNo, DescriptionColumnNo);
                AltTotalQty := EvaluateDecimal(TempExcelBuffer, RowNo, QtyColumnNo);
                LotNo := GetValueAtCell(TempExcelBuffer, RowNo, LotNoColumnNo);
                UpdateInventorySummaryLine(ContractMfgLine, ContractSource, ImportDocNo, LineNo, ItemNo, Description, MatGroupDesc, LotNo, AltTotalQty);
            end;
        end;

        ContractMfgLine.Reset();
        ContractMfgLine.SetRange("SBC Import Document No.", ImportDocNo);
        ContractMfgLine.SetRange("SBC Has Line Error", true);
        exit(not ContractMfgLine.IsEmpty);
    end;

    // procedure ImportInventorySummary(var TempExcelBuffer: Record "Excel Buffer" temporary; ImportTemplateCode: Code[20]; ImportDocNo: Code[20]; MaxRowNo: Integer): Boolean
    // var
    //     ContractMfgLine: Record "SBC Contract Mfg. Line";
    //     RowNo: Integer;
    //     LineNo: Integer;
    //     ItemNo: Code[20];
    //     LotNo: Code[50];
    //     Description: Text[100];
    //     MatGroupDesc: Text[100];
    //     AltTotalQty: Decimal;
    // begin
    //     for RowNo := 2 to MaxRowNo do begin
    //         MatGroupDesc := GetValueAtCell(TempExcelBuffer, RowNo, 7);
    //         if not matGroupDesc.Contains('Labor') then begin
    //             ItemNo := GetValueAtCell(TempExcelBuffer, RowNo, 5);
    //             Description := GetValueAtCell(TempExcelBuffer, RowNo, 6);
    //             AltTotalQty := EvaluateDecimal(TempExcelBuffer, RowNo, 15);
    //             LotNo := GetValueAtCell(TempExcelBuffer, RowNo, 26);
    //             UpdateInventorySummaryLine(ContractMfgLine, ImportDocNo, LineNo, ItemNo, Description, MatGroupDesc, LotNo, AltTotalQty);
    //         end;
    //     end;

    //     ContractMfgLine.Reset();
    //     ContractMfgLine.SetRange("SBC Import Document No.", ImportDocNo);
    //     ContractMfgLine.SetRange("SBC Has Line Error", true);
    //     exit(not ContractMfgLine.IsEmpty);
    // end;


    #region importInventorySummary

    local procedure UpdateInventorySummaryLine(var ContractMfgLine: Record "SBC Contract Mfg. Line"; ContractSource: Enum "SBC Contract Source"; ImportDocNo: Code[20]; var LineNo: Integer; ItemNo: Code[20]; Description: Text[100]; MatGroupDesc: Text[100]; LotNo: Code[50]; AltTotalQty: Decimal)
    begin
        ContractMfgLine.Reset();
        ContractMfgLine.SetRange("SBC Import Document No.", ImportDocNo);
        ContractMfgLine.SetRange("SBC Contract Source", ContractSource);
        ContractMfgLine.SetRange("SBC Contract Type", ContractMfgLine."SBC Contract Type"::"SBC Inventory");
        ContractMfgLine.SetRange("SBC Item No.", ItemNo);
        ContractMfgLine.SetRange("SBC Lot No.", LotNo);
        if ContractMfgLine.FindLast() then begin
            ContractMfgLine."SBC Count of Handling Unit" += 1;
            ContractMfgLine."SBC Quantity" += AltTotalQty;
            ContractMfgLine.Modify(true);
        end else
            InsertInventorySummary(ContractMfgLine, ContractSource, ImportDocNo, LineNo, ItemNo, Description, MatGroupDesc, LotNo, AltTotalQty);
    end;

    // local procedure UpdateInventorySummaryLine(var ContractMfgLine: Record "SBC Contract Mfg. Line"; ContractMfgCode: Code[20]; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; ImportDocNo: Code[20]; var LineNo: Integer; ItemNo: Code[20]; Description: Text[100]; MatGroupDesc: Text[100]; LotNo: Code[50]; AltTotalQty: Decimal)
    // begin
    //     ContractMfgLine.Reset();
    //     ContractMfgLine.SetRange("SBC Import Document No.", ImportDocNo);
    //     ContractMfgLine.SetRange("SBC Contract Source", ContractSource);
    //     ContractMfgLine.SetRange("SBC Contract Type", ContractType);
    //     ContractMfgLine.SetRange("SBC Item No.", ItemNo);
    //     ContractMfgLine.SetRange("SBC Lot No.", LotNo);
    //     if ContractMfgLine.FindLast() then begin
    //         ContractMfgLine."SBC Count of Handling Unit" += 1;
    //         ContractMfgLine."SBC Quantity" += AltTotalQty;
    //         ContractMfgLine.Modify(true);
    //     end else
    //         InsertInventorySummary(ContractMfgLine, ContractSource, ImportDocNo, LineNo, ItemNo, Description, MatGroupDesc, LotNo, AltTotalQty);
    // end;

    local procedure InsertInventorySummary(var ContractMfgLine: Record "SBC Contract Mfg. Line"; ContractSource: Enum "SBC Contract Source"; ImportDocNo: Code[20]; var LineNo: Integer; ItemNo: Code[20]; Description: Text[100]; MatGroupDesc: Text[100]; LotNo: Code[50]; AltTotalQty: Decimal)
    begin
        LineNo += 10000;
        ContractMfgLine.Reset();
        ContractMfgLine.Init();
        ContractMfgLine."SBC Import Document No." := ImportDocNo;
        ContractMfgLine."SBC Line No." := LineNo;
        ContractMfgLine."SBC Contract Source" := ContractSource;
        ContractMfgLine."SBC Contract Type" := ContractMfgLine."SBC Contract Type"::"SBC Inventory";
        ContractMfgLine."SBC Item No." := ItemNo;
        ContractMfgLine."SBC Description" := Description;
        ContractMfgLine."SBC Matl. Group Desc." := MatGroupDesc;
        ContractMfgLine."SBC Count of Handling Unit" := 1;
        ContractMfgLine."SBC Quantity" := AltTotalQty;
        ContractMfgLine."SBC Lot No." := LotNo;
        if not HasLineError(ItemNo) then begin
            ContractMfgLine."SBC Line Error" := CopyStr(GetLastErrorText(), 1, 250);
            ContractMfgLine."SBC Has Line Error" := true;
        end;
        ContractMfgLine.Insert(true);
    end;

    [TryFunction]
    local procedure HasLineError(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
    end;

    #endregion importInventorySummary

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
        Datetxt := GetValueAtCell(TempExcelBuffer, RowNo, ColumnNo);
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

    #endregion getCellValue   

    #region mappingImport

    local procedure InvMappingMenasha(var StartRowNo: Integer; var MapGroupDescColumnNo: Integer; var ItemNoColumnNo: Integer; var DescriptionColumnNo: Integer; var QtyColumnNo: Integer; var LotNoColumnNo: Integer)
    begin
        startRowNo := 2;
        MapGroupDescColumnNo := 7;
        ItemNoColumnNo := 5;
        DescriptionColumnNo := 6;
        QtyColumnNo := 15;
        LotNoColumnNo := 26;
    end;

    local procedure InvMappingWestRock(var StartRowNo: Integer; var MapGroupDescColumnNo: Integer; var ItemNoColumnNo: Integer; var DescriptionColumnNo: Integer; var QtyColumnNo: Integer; var LotNoColumnNo: Integer)
    begin
        startRowNo := 2;
        MapGroupDescColumnNo := 0;
        ItemNoColumnNo := 2;
        DescriptionColumnNo := 3;
        QtyColumnNo := 10;
        LotNoColumnNo := 7;
    end;

    #endregion mappingImport

}
