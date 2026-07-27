/// <summary>
/// Codeunit SBCTA Buffer Expansion (ID 50206).
/// </summary>
codeunit 50206 "SBCTA Buffer Expansion"
{

    var
        GlobalCurrency: Record Currency;
        GlobalSTABracketPriceLedger: Record "STA Bracket Price Ledger";

    local procedure ExpandDimensionPostingBuffer(var TempDimPostingBuffer: Record "Dimension Posting Buffer" temporary; var GenJournalLine: Record "Gen. Journal Line")
    var
        DimensionPostingBufferDictionary: Dictionary of [Integer, Decimal];
        AccruedAmount: Decimal;
        DimensionSetId: Integer;
        SignFactor: Integer;
    begin
        if IsNullGuid(GenJournalLine."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(GenJournalLine."SBCTA ID") then
            exit;


        GlobalCurrency.InitRoundingPrecision();
        FillBufferDictionary(GenJournalLine, DimensionPostingBufferDictionary);
        if DimensionPostingBufferDictionary.Count = 0 then
            exit;

        TempDimPostingBuffer.SetRange(Amount, GenJournalLine.Amount);
        TempDimPostingBuffer.SetRange("Dimension Set ID", GenJournalLine."Dimension Set ID");
        TempDimPostingBuffer.FindFirst();
        SignFactor := -1; //Should always flip.


        TempDimPostingBuffer.SetRange(Amount);
        TempDimPostingBuffer.SetRange("Dimension Set ID");
        DimensionSetId := DimensionPostingBufferDictionary.Keys().Get(1);
        if TempDimPostingBuffer."Dimension Set ID" <> DimensionSetId then
            TempDimPostingBuffer.Rename(DimensionSetId, TempDimPostingBuffer."Group ID");

        // Expand Dimension Posting Buffer
        foreach DimensionSetId in DimensionPostingBufferDictionary.Keys() do begin
            AccruedAmount := SignFactor * DimensionPostingBufferDictionary.Get(DimensionSetId);
            if DimensionSetId = TempDimPostingBuffer."Dimension Set ID" then begin
                TempDimPostingBuffer.Amount := AccruedAmount;
                TempDimPostingBuffer."Amount (ACY)" := AccruedAmount;
                TempDimPostingBuffer.Modify();
            end
            else begin
                TempDimPostingBuffer."Dimension Set ID" := DimensionSetId;
                TempDimPostingBuffer.Amount := AccruedAmount;
                TempDimPostingBuffer."Amount (ACY)" := AccruedAmount;
                TempDimPostingBuffer.Insert();
            end;
        end;
    end;

    local procedure ExpandGLPostingBuffer(var TempGLEntryBuf: Record "G/L Entry" temporary; var GenJournalLine: Record "Gen. Journal Line")
    var
        DimensionPostingBufferDictionary: Dictionary of [Integer, Decimal];
        DimensionCodeArray: array[8] of Code[20];
        DimensionManagement: Codeunit DimensionManagement;
        AccruedAmount: Decimal;
        DimensionSetId: Integer;
        SignFactor: Integer;
    begin
        if IsNullGuid(GenJournalLine."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(GenJournalLine."SBCTA ID") then
            exit;
        FillBufferDictionary(GenJournalLine, DimensionPostingBufferDictionary);
        if DimensionPostingBufferDictionary.Count = 0 then
            exit;

        TempGLEntryBuf.SetRange(Amount, -GenJournalLine.Amount);
        TempGLEntryBuf.SetRange("Dimension Set ID", GenJournalLine."Dimension Set ID");
        TempGLEntryBuf.SetRange("Document No.", GenJournalLine."Document No.");
        TempGLEntryBuf.FindFirst();
        if TempGLEntryBuf.Amount < 0 then
            SignFactor := -1
        else
            SignFactor := 1;

        TempGLEntryBuf.SetRange(Amount);
        TempGLEntryBuf.SetRange("Dimension Set ID");
        TempGLEntryBuf.SetRange("Document No.");
        DimensionSetId := DimensionPostingBufferDictionary.Keys().Get(1);
        if TempGLEntryBuf."Dimension Set ID" <> DimensionSetId then
            TempGLEntryBuf."Dimension Set ID" := DimensionSetId;

        // Expand Dimension Posting Buffer
        foreach DimensionSetId in DimensionPostingBufferDictionary.Keys() do begin
            AccruedAmount := SignFactor * DimensionPostingBufferDictionary.Get(DimensionSetId);
            DimensionManagement.GetShortcutDimensions(DimensionSetId, DimensionCodeArray);
            if DimensionSetId = TempGLEntryBuf."Dimension Set ID" then begin
                TempGLEntryBuf."Global Dimension 1 Code" := DimensionCodeArray[1];
                TempGLEntryBuf."Global Dimension 2 Code" := DimensionCodeArray[2];
                SetGLEntryBufferAmounts(TempGLEntryBuf, AccruedAmount);
                TempGLEntryBuf.Modify();
            end
            else begin
                TempGLEntryBuf."Entry No." := TempGLEntryBuf.GetLastEntryNo() + 1;
                TempGLEntryBuf."Global Dimension 1 Code" := DimensionCodeArray[1];
                TempGLEntryBuf."Global Dimension 2 Code" := DimensionCodeArray[2];
                TempGLEntryBuf."Dimension Set ID" := DimensionSetId;
                SetGLEntryBufferAmounts(TempGLEntryBuf, AccruedAmount);
                TempGLEntryBuf.Insert();
            end;
        end;
    end;

    local procedure FillBufferDictionary(var GenJournalLine: Record "Gen. Journal Line"; var DimensionPostingBufferDictionary: Dictionary of [Integer, Decimal])
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        CurrentlyAccruedAmount: Decimal;
        TotalAccruedAmount: Decimal;
        JournalLineAmount: Decimal;
        DimensionSetId: Integer;
    begin
        SBCTATradeAccrualLine.SetCurrentKey("Dimension Set ID");
        SBCTATradeAccrualLine.SetRange("Journal Line Id", GenJournalLine."SBCTA ID");
        if SBCTATradeAccrualLine.IsEmpty() then
            exit;
        SBCTATradeAccrualLine.SetLoadFields("Dimension Set ID", "Accrued Amount");
        SBCTATradeAccrualLine.FindSet();
        // Create Dimension Posting Buffer
        repeat
            if DimensionPostingBufferDictionary.Get(SBCTATradeAccrualLine."Dimension Set ID", CurrentlyAccruedAmount) then
                DimensionPostingBufferDictionary.Set(SBCTATradeAccrualLine."Dimension Set ID", CurrentlyAccruedAmount + SBCTATradeAccrualLine."Accrued Amount")
            else
                DimensionPostingBufferDictionary.Add(SBCTATradeAccrualLine."Dimension Set ID", SBCTATradeAccrualLine."Accrued Amount");
        until SBCTATradeAccrualLine.Next() = 0;

        foreach DimensionSetId in DimensionPostingBufferDictionary.Keys() do begin
            if DimensionPostingBufferDictionary.Get(DimensionSetId, CurrentlyAccruedAmount) then
                DimensionPostingBufferDictionary.Set(DimensionSetId, Round(CurrentlyAccruedAmount, GlobalCurrency."Amount Rounding Precision"));
            TotalAccruedAmount += DimensionPostingBufferDictionary.Get(DimensionSetId);
        end;
        JournalLineAmount := -GenJournalLine.Amount; //The journal line amount will always have a sign opposite the accrued amount because the transactions offset.
        if TotalAccruedAmount = JournalLineAmount then
            exit;
        DimensionPostingBufferDictionary.Set(DimensionSetId, DimensionPostingBufferDictionary.Get(DimensionSetId) + (JournalLineAmount - TotalAccruedAmount)); // Adjust the last dimension set to true up the difference
    end;

    local procedure SetGLEntryBufferAmounts(var TempGLEntryBuf: Record "G/L Entry" temporary; var AccruedAmount: Decimal)
    begin
        if TempGLEntryBuf."VAT Amount" <> 0 then
            TempGLEntryBuf."VAT Amount" := Round(AccruedAmount * (TempGLEntryBuf."VAT Amount" / TempGLEntryBuf.Amount), GlobalCurrency."Amount Rounding Precision");
        if TempGLEntryBuf."Additional-Currency Amount" <> 0 then
            TempGLEntryBuf."Additional-Currency Amount" := Round(AccruedAmount * (TempGLEntryBuf."Additional-Currency Amount" / TempGLEntryBuf.Amount), GlobalCurrency."Amount Rounding Precision");
        if TempGLEntryBuf."Add.-Currency Debit Amount" <> 0 then
            TempGLEntryBuf."Add.-Currency Debit Amount" := Round(Abs(AccruedAmount) * (TempGLEntryBuf."Add.-Currency Debit Amount" / TempGLEntryBuf."Debit Amount"), GlobalCurrency."Amount Rounding Precision");
        if TempGLEntryBuf."Add.-Currency Credit Amount" <> 0 then
            TempGLEntryBuf."Add.-Currency Credit Amount" := Round(Abs(AccruedAmount) * (TempGLEntryBuf."Add.-Currency Credit Amount" / TempGLEntryBuf."Credit Amount"), GlobalCurrency."Amount Rounding Precision");
        TempGLEntryBuf.Amount := AccruedAmount;
        if TempGLEntryBuf."Credit Amount" <> 0 then begin
            TempGLEntryBuf.Amount := -AccruedAmount;
            TempGLEntryBuf."Credit Amount" := Abs(AccruedAmount);
        end;
        If TempGLEntryBuf."Debit Amount" <> 0 then
            TempGLEntryBuf."Debit Amount" := Abs(AccruedAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCreateGLEntriesForTotalAmountsV19', '', false, false)]
    local procedure OnBeforeCreateGLEntriesForTotalAmountsV19(var TempDimPostingBuffer: Record "Dimension Posting Buffer" temporary; GenJournalLine: Record "Gen. Journal Line"; var GLAccNo: Code[20]; var IsHandled: Boolean; AdjAmountBuf: array[4] of Decimal; SavedEntryNo: Integer; LedgEntryInserted: Boolean)
    begin
        ExpandDimensionPostingBuffer(TempDimPostingBuffer, GenJournalLine);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeFinishPosting', '', false, false)]
    local procedure OnBeforeFinishPosting(var GenJournalLine: Record "Gen. Journal Line"; var TempGLEntryBuf: Record "G/L Entry" temporary)
    begin
        ExpandGLPostingBuffer(TempGLEntryBuf, GenJournalLine);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInsertGlobalGLEntry, '', false, false)]
    local procedure OnAfterInsertGlobalGLEntry(var GLEntry: Record "G/L Entry"; var TempGLEntryBuf: Record "G/L Entry"; var NextEntryNo: Integer; GenJnlLine: Record "Gen. Journal Line")
    var
        STABracketPriceLedger: Record "STA Bracket Price Ledger";
    begin
        if not STABracketPriceLedger.IsBracketPriceEntry(GenJnlLine."SBCTA ID") then
            exit;
        STABracketPriceLedger.GetBySystemId(GenJnlLine."SBCTA ID");
        STABracketPriceLedger."G/L Entry No." := TempGLEntryBuf."Entry No.";
        STABracketPriceLedger.Modify();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeContinuePosting', '', false, false)]
    local procedure OnBeforeContinuePosting(var GenJournalLine: Record "Gen. Journal Line"; var GLRegister: Record "G/L Register"; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    begin
        if IsNullGuid(GenJournalLine."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(GenJournalLine."SBCTA ID") then
            exit;
        if GLRegister."To Entry No." < NextEntryNo then
            exit;
        NextEntryNo := GLRegister."To Entry No." + 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckDimensions', '', false, false)]
    local procedure OnBeforeCheckDimensions(var GenJnlLine: Record "Gen. Journal Line"; var CheckDone: Boolean)
    var
        SBCTADimensionCheckHandler: codeunit "SBCTA Dimension Check Handler";
    begin
        if IsNullGuid(GenJnlLine."SBCTA ID") then
            exit;
        if GlobalSTABracketPriceLedger.IsBracketPriceEntry(GenJnlLine."SBCTA ID") then
            exit;
        SBCTADimensionCheckHandler.Bind(true);
    end;
}