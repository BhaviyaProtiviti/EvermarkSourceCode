codeunit 50104 "SBC Gen Journal Import Mgmt"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    procedure ImportLines(JnlTemplateName: Code[10]; JnlBatchName: Code[10])
    var
        FileManagement: Codeunit "File Management";
        Instream: InStream;
        FromFile: Text;
        FileName: Text;
        SheetName: Text;
    begin
        UploadIntoStream('Please choose the Excel file', '', '', FromFile, Instream);
        if FromFile <> '' then begin
            FileName := FileManagement.GetFileName(FromFile);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(Instream);
        end else
            Error('No file found');

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(Instream, SheetName);
        TempExcelBuffer.ReadSheet();

        ImportExcelData(JnlTemplateName, JnlBatchName);
    end;

    local procedure ImportExcelData(JnlTemplateName: Code[10]; JnlBatchName: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
        ShortcutDimCode: Code[20];
        DocNo: Code[20];
        Desc: Text;
        LineNo: Integer;
        RowNo: Integer;
        MaxRowNo: Integer;
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";
        if MaxRowNo = 1 then
            exit;

        for RowNo := 2 to MaxRowNo do begin
            if RowNo = 2 then
                DocNo := SetDocNo(JnlTemplateName,JnlBatchName);
            GenJournalLine.Init();
            GenJournalLine."Journal Template Name" := JnlTemplateName;
            GenJournalLine."Journal Batch Name" := JnlBatchName;
            GenJournalLine."Document No." := DocNo;
            LineNo := GetLastLineNo(JnlTemplateName, GenJournalLine."Journal Batch Name") + 10000;
            GenJournalLine."Line No." := LineNo;
            Evaluate(GenJournalLine."Posting Date", GetValueAtCell(RowNo, 1));
            Evaluate(GenJournalLine."Account Type", GetValueAtCell(RowNo, 2));
            GenJournalLine.Validate("Account No.", GetValueAtCell(RowNo, 3));
            Desc := GetValueAtCell(RowNo, 5);
            if Desc <> '' then
                GenJournalLine.Validate("Description", Desc);
            GenJournalLine.Validate("Amount (LCY)", SetAmount(RowNo));
            Evaluate(GenJournalLine."Bal. Account Type", GetValueAtCell(RowNo, 9));
            GenJournalLine.Validate("Bal. Account No.", GetValueAtCell(RowNo, 10));
            GenJournalLine.Validate("Bal. Account No.");
            ShortcutDimCode := GetValueAtCell(RowNo, 11);
            GenJournalLine.ValidateShortcutDimCode(3, ShortcutDimCode);
            GenJournalLine.Validate("Shortcut Dimension 1 Code", GetValueAtCell(RowNo, 12));
            GenJournalLine.Validate("Shortcut Dimension 2 Code", GetValueAtCell(RowNo, 13));
            GenJournalLine.Validate(Comment, GetValueAtCell(RowNo, 14));
            GenJournalLine.Insert(true);
        end;
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColumnNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure SetAmount(RowNo: Integer): Decimal
    var
        Amount: Decimal;
    begin
        Amount := GetDecValueAtCell(RowNo, 6);
        if Amount = 0 then
            Amount := GetDecValueAtCell(RowNo, 7);
        if Amount = 0 then
            Amount := -GetDecValueAtCell(RowNo, 8);
        exit(Amount);
    end;

    local procedure GetDecValueAtCell(RowNo: Integer; ColumnNo: Integer): Decimal
    var
        AmountTxt: Text;
        AmountDec: Decimal;
    begin
        AmountTxt := GetValueAtCell(RowNo, ColumnNo);
        if AmountTxt <> '' then
            Evaluate(AmountDec, AmountTxt);
        exit(AmountDec);
    end;

    local procedure SetDocNo(JnlTemplateName: Code[10]; JnlBatchName: Code[10]): Code[20]
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if GenJnlBatch.Get(JnlTemplateName, JnlBatchName) then
            if GenJnlBatch."No. Series" <> '' then begin
                Clear(NoSeriesMgt);
                exit(NoSeriesMgt.TryGetNextNo(GenJnlBatch."No. Series", Today));
            end;
    end;

    local procedure GetLastLineNo(JnlTemplateName: Code[10]; JnlBatchName: Code[10]): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJournalLine.FindLast() then;
        exit(GenJournalLine."Line No.");
    end;
}
