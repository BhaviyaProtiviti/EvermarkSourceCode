codeunit 50101 "SBC Post One Batch"
{

    TableNo = "Item Journal Batch";

    trigger OnRun()
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        GlobalItemJournalBatch := Rec;
        ItemJournalLine.SetRange("Journal Template Name", GlobalItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", GlobalItemJournalBatch.Name);
        if ItemJournalLine.IsEmpty() then
            exit;
        ItemJournalLine.SetFilter("SBC Processing Error Message", '<>%1', '');
        if not ItemJournalLine.IsEmpty() then begin
            ItemJournalLine.ModifyAll("SBC Processing Error Message", ''); // Clear Errors so they can be re-written.
            Commit();
        end;
        ItemJournalLine.SetRange("SBC Processing Error Message");
        ItemJournalLine.FindFirst();
        PostItemJournalLineWithCollectedErrors(ItemJournalLine);
    end;

    var
        GlobalItemJournalBatch: Record "Item Journal Batch";
        ErrorMessageDescriptionLabel: Label 'SBC Post EDI Batches';

    [Obsolete('This code is no longer relevant and should not be called.', 'zwr-2024-05-15')]

    local procedure PostBatchRecursive(var ItemJnlLine: Record "Item Journal Line"; var TemplateName: Code[10]; var BatchName: Code[10]; TableView: Text)
    var
        FirstLineNo: Integer;
        HalfCount: Integer;
        LastLineNo: Integer;
        MiddleLineNo: Integer;
        RecordCount: Integer;

    begin
        Commit();
        ItemJnlLine.SETVIEW(TableView);
        //ItemJnlLine.SETFILTER("SUA Processing Error Message", '%1', '');
        if not Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJnlLine) then begin
            if ItemJnlLine.Count = 1 then begin
                ItemJnlLine.FindFirst();
                ItemJnlLine."SBC Processing Error Message" := CopyStr(GETLASTERRORTEXT, 1, MAXSTRLEN(ItemJnlLine."SBC Processing Error Message"));
                ItemJnlLine.Modify();
                exit;
            end
            else begin
                RecordCount := ItemJnlLine.Count();
                HalfCount := Round(RecordCount / 2, 1, '<');

                ItemJnlLine.FindFirst();
                FirstLineNo := ItemJnlLine."Line No.";

                ItemJnlLine.Next(HalfCount - 1);
                MiddleLineNo := ItemJnlLine."Line No.";

                ItemJnlLine.FindLast();
                LastLineNo := ItemJnlLine."Line No.";

                ItemJnlLine.SetRange("Line No.", FirstLineNo, MiddleLineNo);
                ItemJnlLine.FindFirst();
                PostBatchRecursive(ItemJnlLine, TemplateName, BatchName, ItemJnlLine.GETVIEW());

                ItemJnlLine.SetRange("Line No.", MiddleLineNo + 1, LastLineNo);
                ItemJnlLine.FindFirst();
                PostBatchRecursive(ItemJnlLine, TemplateName, BatchName, ItemJnlLine.GETVIEW());
            end;
        end;
    end;

    local procedure LogTempError(var TempErrorMessage: Record "Error Message" temporary; ErrorCallStackText: Text; ErrorMessageText: Text)
    var
        ErrorMessageRegister: Record "Error Message Register";
    begin
        TempErrorMessage.Init();
        TempErrorMessage.ID := TempErrorMessage.ID + 1;
        TempErrorMessage."Context Table Number" := Database::"Item Journal Batch";
        TempErrorMessage.Validate("Context Record ID", GlobalItemJournalBatch.RecordId());
        TempErrorMessage."Additional Information" := CopyStr(ErrorMessageText,1, MaxStrLen(TempErrorMessage."Additional Information"));
        TempErrorMessage.SetErrorCallStack(ErrorCallStackText);
        TempErrorMessage."Register ID" := ErrorMessageRegister.New(ErrorMessageDescriptionLabel);
        TempErrorMessage.Insert(true);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    internal procedure PostItemJournalLineWithCollectedErrors(var ItemJournalLine: Record "Item Journal Line")
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
        CollectedErrorInfo: ErrorInfo;
        CollectedErrorList: List of [ErrorInfo];
    begin
        if Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine) then
            exit;
        // GlobalItemJournalBatch.SetRecFilter();
        // GlobalItemJournalBatch.Find();
        LogTempError(TempErrorMessage, GetLastErrorCallStack(), GetLastErrorText());
        if HasCollectedErrors() then begin
            CollectedErrorList := GetCollectedErrors(true);
            foreach CollectedErrorInfo in CollectedErrorList do begin
                LogTempError(TempErrorMessage, CollectedErrorInfo.Callstack(), CollectedErrorInfo.Message());
            end;
        end;
        if TempErrorMessage.FindSet() then
            repeat
                if TempErrorMessage."Error Call Stack".HasValue() then
                    TempErrorMessage.CalcFields("Error Call Stack");
                ErrorMessage.TransferFields(TempErrorMessage,false);
                // ErrorMessage.ID := TempErrorMessage.ID;
                ErrorMessage.Insert(true);
                ErrorMessage.Get(ErrorMessage.ID);
                if not ErrorMessage."Error Call Stack".HasValue() then 
                begin
                    ErrorMessage.SetErrorCallStack(TempErrorMessage.GetErrorCallStack());
                    ErrorMessage.Modify();
                end;
                
            until TempErrorMessage.Next() = 0;
        if ItemJournalLine.IsEmpty() then // Write the error message to the first line in the batch.
            exit;
        ItemJournalLine.FindFirst();
        ItemJournalLine."SBC Processing Error Message" := CopyStr(GetLastErrorText(), 1, MAXSTRLEN(ItemJournalLine."SBC Processing Error Message"));
        ItemJournalLine.Modify();
    end;
}