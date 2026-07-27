codeunit 50115 "SBC AmEx Payment Mgmt"
{

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure GenJournalLineOnAfterCopyGenJnlLineFromPurchHeader(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
        GenJournalLine."SBC Employee ID" := PurchaseHeader."SBC Employee ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVendLedgEntry', '', false, false)]
    local procedure GenJnlPostLineOnAfterInitVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; var GLRegister: Record "G/L Register")
    begin
        GenJournalLine."SBC Employee ID" := VendorLedgerEntry."SBC Employee ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeVendLedgEntryInsert', '', false, false)]
    local procedure GenJnlPostLineOnBeforeVendLedgEntryInsert(GenJournalLine: Record "Gen. Journal Line"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; GLRegister: Record "G/L Register")
    begin
        if (GenJournalLine."SBC Employee ID" <> '') and (vendorLedgerEntry."SBC Employee ID" = '') then
            VendorLedgerEntry."SBC Employee ID" := GenJournalLine."SBC Employee ID";
    end;

    #region createPmts  

    procedure CreatePayments(PostingDate: Date)
    var
        SBCAmExRemittanceImport: Record "SBC AmEx Remittance Import";
        GenJournalTemplate: Record "Gen. Journal Template";
        PurchSetup: Record "Purchases & Payables Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        PmtDocNo: Code[20];
        JnlTempName: Code[10];
        OffsettingAmt: Decimal;
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
        if not GenJournalTemplate.FindFirst() then
            error('No payment journal template found')
        else
            JnlTempName := GenJournalTemplate."Name";

        PurchSetup.Get();
        PurchSetup.TestField("SBC AmEx Pmt Jnl Batch Name");

        SBCAmExRemittanceImport.SetRange("SBC Payment Created", false);
        if SBCAmExRemittanceImport.FindSet() then begin
            PmtDocNo := GenerateLineDocNo(PurchSetup."SBC AmEx Pmt Jnl Batch Name", Today, JnlTempName);
            GenJournalBatch.Get(JnlTempName, PurchSetup."SBC AmEx Pmt Jnl Batch Name");
            repeat
                if SBCAmExRemittanceImport."SBC AmEx Payment Due" <> 0 then
                    CreatePaymentLine(SBCAmExRemittanceImport, GenJournalBatch, PmtDocNo, JnlTempName, PurchSetup."SBC AmEx Pmt Jnl Batch Name", PurchSetup."American Express Vendor No.", PostingDate);                    
                SBCAmExRemittanceImport."SBC Payment Created" := true;
                SBCAmExRemittanceImport.Modify(true);
                OffsettingAmt += SBCAmExRemittanceImport."SBC AmEx Payment Due";
            until SBCAmExRemittanceImport.Next() = 0;
            CreateOffSettingLine(SBCAmExRemittanceImport, PmtDocNo, JnlTempName, PurchSetup."SBC AmEx Pmt Jnl Batch Name", PurchSetup."SBC AmEx Offsetting Account No", PostingDate, OffsettingAmt);
            SendForApproval(JnlTempName, GenJournalBatch.Name);
            OpenPmtJournal(JnlTempName, PurchSetup."SBC AmEx Pmt Jnl Batch Name");
        end;
    end;

    local procedure CreatePaymentLine(SBCAmExRemittanceImport: Record "SBC AmEx Remittance Import"; GenJournalBatch: Record "Gen. Journal Batch"; var PmtDocNo: Code[20]; JnlTempName: Code[10]; JnlBatchName: Code[10]; AmexVendorNo: Code[20]; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JnlTempName);
        GenJournalLine.Validate("Journal Batch Name", JnlBatchName);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(JnlTempName, JnlBatchName);
        GenJournalLine.Validate("Document No.", PmtDocNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Document Date", SBCAmExRemittanceImport."SBC AmEx Report Date");
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.Validate("Account No.", AmexVendorNo);
        GenJournalLine."SBC Employee ID" := SBCAmExRemittanceImport."SBC AmEx Employee ID";
        GenJournalLine.Description := CopyStr(SBCAmExRemittanceImport."SBC AmEx Employee Name", 1, 100);
        GenJournalLine.Validate(Amount, SBCAmExRemittanceImport."SBC AmEx Payment Due");
        if GenJournalBatch."Bal. Account No." <> '' then begin
            GenJournalLine.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type");
            GenJournalLine.Validate("Bal. Account No.", GenJournalBatch."Bal. Account No.");
        end;
        GenJournalLine.Insert(true);

        if ApplyEntries(GenJournalLine) then begin
            GenJournalLine."Applies-to ID" := GenJournalLine."Document No.";
            GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Invoice;
            GenJournalLine.Modify(true);
        end;
    end;

    local procedure CreateOffSettingLine(SBCAmExRemittanceImport: Record "SBC AmEx Remittance Import"; var PmtDocNo: Code[20]; JnlTempName: Code[10]; JnlBatchName: Code[10]; AmexVendorNo: Code[20]; PostingDate: Date; OffsettingAmt: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", JnlTempName);
        GenJournalLine.Validate("Journal Batch Name", JnlBatchName);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(JnlTempName, JnlBatchName);
        GenJournalLine.Validate("Document No.", PmtDocNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Document Date", SBCAmExRemittanceImport."SBC AmEx Report Date");
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
        GenJournalLine.Validate("Account No.", AmexVendorNo);
        GenJournalLine.Validate(Amount, -OffsettingAmt);        
        GenJournalLine.Insert(true);
    end;

    local procedure ApplyEntries(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        RemainingPmtAmt: Decimal;
    begin
        VendorLedgerEntry.SetCurrentKey("Posting Date");
        VendorLedgerEntry.SetAscending("Posting Date", true);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange("SBC Employee ID", GenJournalLine."SBC Employee ID");
        VendorLedgerEntry.SetRange("Applies-to ID", '');
        VendorLedgerEntry.SetRange(Open, true);
        if VendorLedgerEntry.FindSet() then begin
            RemainingPmtAmt := GenJournalLine.Amount;
            repeat
                VendorLedgerEntry.Validate("Applies-to ID", GenJournalLine."Document No.");
                VendorLedgerEntry.CalcFields("Remaining Amount");
                if RemainingPmtAmt < -VendorLedgerEntry."Remaining Amount" then begin
                    VendorLedgerEntry.Validate("Amount to Apply", -RemainingPmtAmt);
                    RemainingPmtAmt := 0;
                end else begin
                    VendorLedgerEntry.Validate("Amount to Apply", VendorLedgerEntry."Remaining Amount");
                    RemainingPmtAmt += VendorLedgerEntry."Remaining Amount";
                end;
                VendorLedgerEntry.Modify(true);
            until (VendorLedgerEntry.Next() = 0) or (RemainingPmtAmt <= 0);
            exit(true);
        end;
    end;

    local procedure GenerateLineDocNo(BatchName: Code[10]; PostingDate: Date; TemplateName: Code[20]) DocumentNo: Code[20]
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GenJournalBatch.Get(TemplateName, BatchName);
        if GenJournalBatch."No. Series" <> '' then
            DocumentNo := NoSeriesManagement.TryGetNextNo(GenJournalBatch."No. Series", PostingDate);
    end;

    #endregion createPmts    

    #region sendforApproval

    local procedure SendForApproval(JnlTempName: Code[10]; JnlBatchName: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        GenJournalLine.SetRange("Journal Template Name", JnlTempName);
        GenJournalLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJournalLine.FindSet() then
            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(GenJournalLine);
    end;

    #endregion sendforApproval

    #region openPmtJournal

    local procedure OpenPmtJournal(TemplateName: Code[20]; BatchName: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
        ConfirmLbl: Label 'Payments created successfully. Do you want to open the Payment Journal?', Comment = '%1';
    begin
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        if GenJournalLine.FindSet() then
            if Confirm(ConfirmLbl) then
                page.Run(page::"Payment Journal", GenJournalLine);
    end;

    #endregion openPmtJournal


}
