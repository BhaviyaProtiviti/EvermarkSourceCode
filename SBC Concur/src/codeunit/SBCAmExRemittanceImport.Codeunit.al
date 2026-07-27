codeunit 50114 "SBC AmEx Remittance Import"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    procedure ImportAmExRemittance()
    var
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        BlankLine: Text;
        FromFile: Text;
        FileName: Text;
        SheetName: Text;
        MaxRowNo: Integer;
        RowNo: Integer;
        EntryNo: Integer;
    begin
        UploadIntoStream('Please choose the file to import', '', '', FromFile, InStream);
        if FromFile = '' then
            Error('No file selected');

        FileName := FileManagement.GetFileName(FromFile);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(InStream);

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(InStream, SheetName);
        TempExcelBuffer.ReadSheet();

        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No."
        else
            Error('No data found in the file');

        for RowNo := 17 to MaxRowNo do begin
            BlankLine := GetValueAtCell(RowNo, 1);
            if BlankLine = '' then
                exit;
            ImportData(EntryNo, RowNo);
        end;
    end;

    local procedure ImportData(var EntryNo: Integer; RowNo: Integer)
    var
        SBCAmExRemittanceImport: Record "SBC AmEx Remittance Import";
    begin
        if EntryNo = 0 then
            EntryNo := SBCAmExRemittanceImport.GetNextEntryNo();

        SBCAmExRemittanceImport.Init();
        SBCAmExRemittanceImport."SBC Entry No." := EntryNo;
        SBCAmExRemittanceImport."SBC Line No." := RowNo;
        SBCAmExRemittanceImport."SBC Import Date" := Today;
        SBCAmExRemittanceImport."SBC AmEx Employee Name" := CopyStr(GetValueAtCell(RowNo, 6),1, 250);
        SBCAmExRemittanceImport."SBC AmEx Card Member Status" := CopyStr(GetValueAtCell(RowNo, 8), 1, 20);
        SBCAmExRemittanceImport."SBC AmEx Employee ID" := CopyStr(GetValueAtCell(RowNo, 9), 1, 30);
        SBCAmExRemittanceImport."SBC AmEx Control Acct Name" := CopyStr(GetValueAtCell(RowNo, 10), 1, 150);
        SBCAmExRemittanceImport."SBC AmEx Control Acct No." := CopyStr(GetValueAtCell(RowNo, 11), 1, 20);
        SBCAmExRemittanceImport."SBC Amex Cost Center" := CopyStr(GetValueAtCell(RowNo, 12), 1, 20);
        SBCAmExRemittanceImport."SBC AmEx Billed Currency" := CopyStr(GetValueAtCell(RowNo, 14), 1, 5);
        SBCAmExRemittanceImport."SBC AmEx Balance Due" := GetDecimalValueAtCell(RowNo, 15);
        SBCAmExRemittanceImport."SBC AmEx Payment Due" := GetDecimalValueAtCell(RowNo, 16);
        SBCAmExRemittanceImport."SBC AmEx Report Date" := GetDateValueAtCell(RowNo, 19);
        SBCAmExRemittanceImport.Insert(true);
    end;

    #region getCellValue

    local procedure GetValueAtCell(RowNo: Integer; ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColumnNo) then
            exit(TempExcelBuffer."Cell Value as Text");
    end;

    local procedure GetDecimalValueAtCell(RowNo: Integer; ColumnNo: Integer): Decimal
    var
        DecTxt: Text;
        DecVar: Decimal;
    begin
        DecTxt := GetValueAtCell(RowNo, ColumnNo);
        if DecTxt = '' then
            exit(0);

        Evaluate(DecVar, DecTxt);
        exit(DecVar);
    end;

    local procedure GetDateValueAtCell(RowNo: Integer; ColumnNo: Integer): Date
    var
        DateTxt: Text;
        DateVar: Date;
    begin
        DateTxt := GetValueAtCell(RowNo, ColumnNo);
        if DateTxt = '' then
            exit(0D);

        Evaluate(DateVar, DateTxt);
        exit(DateVar);
    end;

    #endregion getCellValue
}
