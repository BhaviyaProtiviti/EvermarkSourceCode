/// <summary>
/// Codeunit SBCTA Trade Accrual Mgmt. (ID 50203).
/// </summary>
codeunit 50203 "SBCTA Trade Accrual Mgmt."
{

    var
        GlobalSTABracketPriceLedger: Record "STA Bracket Price Ledger";

    [ErrorBehavior(ErrorBehavior::Collect)]
    internal procedure CreateAccrualAndCredit()
    var
        SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
        SBCTACreateAccrualCredits: Report "SBCTA Create Accrual Credits";
        SBCTACreateTradeAccruals: Report "SBCTA Create Trade Accruals";
    begin
        SBCTACreateTradeAccruals.UseRequestPage(false);
        SBCTACreateTradeAccruals.RunModal();
        SBCTATradeAccrualHeader := SBCTACreateTradeAccruals.GetTradeAccrualHeader();
        if SBCTATradeAccrualHeader.AccrualLinesExist() then begin
            SBCTATradeAccrualHeader.SetRecFilter();
            SBCTACreateAccrualCredits.SetTableView(SBCTATradeAccrualHeader);
        end;
        SBCTACreateAccrualCredits.UseRequestPage(false);
        SBCTACreateAccrualCredits.SetSuppressAlerts(true);
        SBCTACreateAccrualCredits.Run();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteCreditEntry(var Rec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        if Rec.IsTemporary() then
            exit;
        if IsNullGuid(Rec."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(Rec."SBCTA ID") then
            exit;
        SBCTATradeAccrualLine.ClearAccrualFromJournalLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyCreditEntry(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; RunTrigger: Boolean)
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        if Rec.IsTemporary() then
            exit;
        if IsNullGuid(Rec."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(Rec."SBCTA ID") then
            exit;
        if (Rec."Line No." <> xRec."Line No.") or (Rec."Document No." <> xRec."Document No.") then
            SBCTATradeAccrualLine.UpdateAccrualFromJournalLine(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterGLFinishPosting, '', false, false)]
    local procedure SBCTAOnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line"; var IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; var GLRegister: Record "G/L Register"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        if GenJnlLine.IsTemporary() then
            exit;
        if IsNullGuid(GenJnlLine."SBCTA ID") then
            exit;
        SBCTATradeAccrualLine.SetPostedFromJournalLine(GenJnlLine);
    end;

}