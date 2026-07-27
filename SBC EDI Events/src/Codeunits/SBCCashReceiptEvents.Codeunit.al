codeunit 50144 "SBC Cash Receipt Events"
{
    // SingleInstance is required: Event 1 (OnBeforePostGenJnlLine) computes the short-pay
    // tolerance and stores it in ShortPayTolerance. Event 2 (OnBeforeCalcPmtTolerancePossible)
    // reads it from the global — the applies-to fields on GenJnlLine are cleared by BC
    // before Event 2 fires, so a CLE lookup in Event 2 would always fail.
    SingleInstance = true;

    var
        ShortPayTolerance: Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure OnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        ShortPay: Decimal;
    begin
        ShortPayTolerance := 0;

        if not IsEligibleCashReceiptPayment(GenJournalLine) then
            exit;

        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            if not FindCustLedgEntryByDoc(GenJournalLine, CustLedgEntry) then
                exit;
            ShortPay := CalcShortPay(CustLedgEntry, GenJournalLine."Posting Date", Abs(GenJournalLine.Amount));
            ApplyShortPayTolerance(CustLedgEntry, ShortPay);
            ShortPayTolerance := ShortPay;
            exit;
        end;

        if GenJournalLine."Applies-to ID" <> '' then begin
            CustLedgEntry.SetRange("Customer No.", GenJournalLine."Account No.");
            CustLedgEntry.SetRange(Open, true);
            CustLedgEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            CustLedgEntry.SetFilter("Amount to Apply", '<>%1', 0);
            if CustLedgEntry.FindSet(true) then
                repeat
                    CustLedgEntry.CalcFields("Remaining Amount");
                    ShortPay := CalcShortPay(CustLedgEntry, GenJournalLine."Posting Date", Abs(CustLedgEntry."Amount to Apply"));
                    ApplyShortPayTolerance(CustLedgEntry, ShortPay);
                    if ShortPay > ShortPayTolerance then
                        ShortPayTolerance := ShortPay;
                until CustLedgEntry.Next() = 0;
        end;
    end;

    // By the time this fires, GenJnlLine applies-to fields are cleared by BC — CLE lookup
    // would fail. Instead read ShortPayTolerance stored by OnBeforePostGenJnlLine.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCalcPmtTolerancePossible', '', false, false)]
    local procedure OnBeforeCalcPmtTolerancePossible(GenJnlLine: Record "Gen. Journal Line"; PmtDiscountDate: Date; var PmtDiscToleranceDate: Date; var MaxPaymentTolerance: Decimal; var IsHandled: Boolean)
    begin
        if ShortPayTolerance <= 0 then
            exit;

        if not IsEligibleCashReceiptPayment(GenJnlLine) then
            exit;

        if ShortPayTolerance <= MaxPaymentTolerance then
            exit;

        MaxPaymentTolerance := ShortPayTolerance;
        PmtDiscToleranceDate := PmtDiscountDate;
        IsHandled := true;
    end;

    local procedure FindCustLedgEntryByDoc(GenJnlLine: Record "Gen. Journal Line"; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        CustLedgEntry.SetRange("Customer No.", GenJnlLine."Account No.");
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
        CustLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
        if not CustLedgEntry.FindFirst() then
            exit(false);
        CustLedgEntry.CalcFields("Remaining Amount");
        exit(true);
    end;

    local procedure CalcShortPay(CustLedgEntry: Record "Cust. Ledger Entry"; PostingDate: Date; ApplyAmount: Decimal): Decimal
    var
        InvoiceRemaining: Decimal;
        ShortPay: Decimal;
    begin
        if CustLedgEntry."Remaining Pmt. Disc. Possible" = 0 then
            exit(0);
        if (CustLedgEntry."Pmt. Discount Date" = 0D) or (PostingDate > CustLedgEntry."Pmt. Discount Date") then
            exit(0);

        InvoiceRemaining := Abs(CustLedgEntry."Remaining Amount");
        if (InvoiceRemaining = 0) or (ApplyAmount = 0) then
            exit(0);

        ShortPay := InvoiceRemaining - ApplyAmount;
        if ShortPay <= 0 then
            exit(0);

        exit(ShortPay);
    end;

    local procedure ApplyShortPayTolerance(var CustLedgEntry: Record "Cust. Ledger Entry"; ShortPay: Decimal)
    begin
        if ShortPay <= CustLedgEntry."Max. Payment Tolerance" then
            exit;

        CustLedgEntry."Max. Payment Tolerance" := ShortPay;
        CustLedgEntry.Modify(true);
    end;

    local procedure IsEligibleCashReceiptPayment(GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::Customer then
            exit(false);

        exit(GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment);
    end;
}
