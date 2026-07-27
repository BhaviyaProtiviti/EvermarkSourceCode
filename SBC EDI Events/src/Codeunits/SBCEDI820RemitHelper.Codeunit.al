/// <summary>
/// Codeunit SBCEDI Remit Advice Helper (ID 50082).
/// </summary>
codeunit 50082 "SBCEDI 820 Remit Helper"
{

    internal procedure CreateCashReceiptJournal(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; EDIDocument: Record "LAX EDI Document")
    var
        EDICreatePaymentAdvice: Codeunit "LAX EDI Create Pmt Remit Adv.";
    begin
        SetGlobals(LAXEDIPaymentRemitAdvice);
        CreateNAVSuggestedPayment(EDIRecDocHdr, LAXEDIPaymentRemitAdvice, EDIDocument);
    end;

    internal procedure ConfirmSelectAll() Result: Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        Result := ConfirmManagement.GetResponseOrDefault(SelectAllQstLabel, true);
    end;

    local procedure SetBalanceAccountOnLine(InternalDocNo: Code[10]; var EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var GenJnlLine: Record "Gen. Journal Line")
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        CheckBillToPayToAlertSettings();
        GenJnlLine.Validate("Bal. Account No.", LAXEDIPmtRemitAdviceLine."G/L Bal. Account No.");
        if GenJnlLine."Bal. Account No." <> '' then
            exit;


        LAXEDIReceiveDocumentField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", InternalDocNo);
        LAXEDIReceiveDocumentField.SetRange("Table No.", DATABASE::"Gen. Journal Line");
        LAXEDIReceiveDocumentField.SetRange("Field No.", GenJnlLine.FieldNo("Account No."));
        if LAXEDIReceiveDocumentField.FindFirst() then
            GenJnlLine.Validate("Bal. Account No.", LAXEDIReceiveDocumentField."Field Text Value")
        else begin
            GenJnlLine.Validate("Bal. Account Type", "Gen. Journal Account Type"::"Bank Account");
            GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Bank Account No.");
        end;
    end;

    local procedure CreateBankAccountDepositLine(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; var GenJnlLine: Record "Gen. Journal Line"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var LastDocumentNo: Code[20]; var LineNo: Integer; var GenJnlBatchName: Code[10]; var GenJnlTemplate: Record "Gen. Journal Template")
    begin
        GenJnlLine.InitNewLine(GenJnlLine."Posting Date", GenJnlLine."Document Date", GenJnlLine."VAT Reporting Date", '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code", GenJnlLine."Dimension Set ID", GenJnlLine."Reason Code");
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
        GenJnlLine."Journal Batch Name" := GenJnlBatchName;
        GenJnlLine."Line No." := LineNo;
        LAXEDIReceiveDocumentField.Reset;
        LAXEDIReceiveDocumentField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        LAXEDIReceiveDocumentField.SetRange("Table No.", DATABASE::"Gen. Journal Line");
        LAXEDIReceiveDocumentField.SetRange("Field No.", GenJnlLine.FieldNo("Account Type"));
        if LAXEDIReceiveDocumentField.Find('-') then
            case UpperCase(LAXEDIReceiveDocumentField."Field Text Value") of
                UpperCase('G/L ACCOUNT'):
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                UpperCase('BANK Account'):
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
            end
        else
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
        if EDIPaymentAdvice."Payer Account Type" =
          EDIPaymentAdvice."Payer Account Type"::Customer
        then
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment
        else
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
        LAXEDIReceiveDocumentField.Reset;
        LAXEDIReceiveDocumentField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        LAXEDIReceiveDocumentField.SetRange("Table No.", DATABASE::"Gen. Journal Line");
        LAXEDIReceiveDocumentField.SetRange("Field No.", GenJnlLine.FieldNo("Account No."));
        if LAXEDIReceiveDocumentField.Find('-') then
            GenJnlLine.Validate("Account No.", LAXEDIReceiveDocumentField."Field Text Value")
        else
            GenJnlLine.Validate("Account No.", EDIPaymentAdvice."Bank Account No.");

        if EDIPaymentAdvice."Currency Code" <> '' then
            GenJnlLine.Validate("Currency Code", EDIPaymentAdvice."Currency Code");
        GenJnlLine.Validate("Bal. Account Type", EDIPaymentAdvice."Payer Account Type");
        CheckBillToPayToAlertSettings();
        if GlobalSetBalanceAccountOnPayments then
            GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Payer Account No.");
        // #275
        // adjust bank amount by the deductions and refunds not originally intended to push to the cash receipt journal
        //GenJnlLine.Validate(Amount, EDIPaymentAdvice."Payment Amount");
        GenJnlLine.Validate(Amount, EDIPaymentAdvice."Payment Amount" + AdjAmt);
        // #275
        GenJnlLine.Validate("Posting Date", GLobalPostingDate);
        GenJnlLine."Document Date" := EDIPaymentAdvice."Document Date";
        GenJnlLine."Document No." := LastDocumentNo;
        GenJnlLine."External Document No." := EDIPaymentAdvice."Payment No.";
        GenJnlLine."LAX EDI Payment" := true;
        GenJnlLine."LAX EDI Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
        GenJnlLine."Applies-to ID" := EDIPaymentAdvice."Payment No.";
        GenJnlLine."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";
        if GenJnlLine.Insert(true) then
            LineNo += 10000;
    end;

    local procedure CheckBillToPayToAlertSettings()
    begin
        if not GlobalAllowDifferentBilltoPayto then
            exit;
        GlobalSBCEDIJournalCreationEvents.Unbind(true);
        GlobalSBCEDIJournalCreationEvents.Bind();
    end;

    local procedure GetCustomerName(CustomerAccountNo: Code[20]; CharacterLimit: Integer) CustomerName: Text
    var
        Customer: Record Customer;
    begin
        if CharacterLimit < 1 then
            exit;
        Customer.SetRange("No.", CustomerAccountNo);
        if Customer.IsEmpty() then
            exit;
        Customer.SetLoadFields(Name);
        Customer.FindFirst();
        CustomerName := Customer.Name;
        if StrLen(CustomerName) < CharacterLimit then
            exit;
        CustomerName := CustomerName.Substring(1, CharacterLimit);
    end;

    local procedure GetCustomerPostingGroup(CustomerAccountNo: Code[20]) CustomerPostingGroup: Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("No.", CustomerAccountNo);
        if Customer.IsEmpty() then
            exit;
        Customer.SetLoadFields("Customer Posting Group");
        Customer.FindFirst();
        CustomerPostingGroup := Customer."Customer Posting Group";
    end;

    local procedure GetExtDocNo(JournalAppliestoDocNo: Text[20]): Code[20]
    var
        DocTxt: Text;
    begin
        DocTxt := GetCleanAppliesToDocNo(JournalAppliestoDocNo);
        exit(DelChr(JournalAppliestoDocNo, '=', (DocTxt + '-')));
    end;

    local procedure GetCleanAppliesToDocNo(JournalAppliestoDocNo: Text[20]): Code[20]
    var
        DocTxt: Text;
        DocTxtList: list of [Text];
    begin
        DocTxtList := JournalAppliestoDocNo.Split('-');
        foreach DocTxt in DocTxtList do
            exit(format(copystr(DocTxt, 1, 20)));
    end;

    // local procedure GetCleanAppliesToDocNo(JournalAppliestoDocNo: Code[20]) AppliesToDocNoTextBuilder: TextBuilder;
    // var
    //     TempMatches: Record Matches temporary;
    //     TempGroups: Record Groups temporary;
    // begin
    //     AppliesToDocNoTextBuilder.Capacity(MaxStrLen(JournalAppliestoDocNo));
    //     AppliesToDocNoTextBuilder.Append(JournalAppliestoDocNo);
    //     GlobalRegex.Match(JournalAppliestoDocNo, TempMatches);
    //     if TempMatches.IsEmpty() then
    //         exit;
    //     GlobalRegex.Groups(TempMatches, TempGroups);
    //     TempGroups.SetRange(Name, SBCGroupNameLabel);
    //     if not TempGroups.FindFirst() then
    //         exit;
    //     AppliesToDocNoTextBuilder.Clear();
    //     AppliesToDocNoTextBuilder.Append(TempGroups.ReadValue());
    // end;

    local procedure SetJournalDescription(PayerName: Text[100]; PayerAccountNo: Code[20]; LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var GenJnlLine: Record "Gen. Journal Line")
    var
        PayerAccountDescriptionTextBuilder: TextBuilder;
    begin
        if PayerAccountDescriptionTextBuilder.Length > 0 then
            PayerAccountDescriptionTextBuilder.Clear();
        PayerAccountDescriptionTextBuilder.Capacity(MaxStrLen(GenJnlLine.Description));
        PayerAccountDescriptionTextBuilder.Append(PayerName);
        if (LAXEDIPmtRemitAdviceLine."Journal Account Type" = "LAX EDI Journal Account Type"::"Customer") and (PayerAccountNo <> LAXEDIPmtRemitAdviceLine."Journal Account No.") then begin
            PayerAccountDescriptionTextBuilder.Append(DescriptionSpaceCharacter);
            PayerAccountDescriptionTextBuilder.Append(GetCustomerName(LAXEDIPmtRemitAdviceLine."Journal Account No.", PayerAccountDescriptionTextBuilder.MaxCapacity - PayerAccountDescriptionTextBuilder.Length));
        end;
        // if (LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-to Doc. Type"::Refund) and (LAXEDIPmtRemitAdviceLine.Description <> '') then begin
        if (LAXEDIPmtRemitAdviceLine.Description <> '') then begin
            PayerAccountDescriptionTextBuilder.Append(DescriptionSpaceCharacter);
            PayerAccountDescriptionTextBuilder.Append(LAXEDIPmtRemitAdviceLine.Description);
        end;
        GenJnlLine.Description := PayerAccountDescriptionTextBuilder.ToText().Trim();
    end;

    local procedure SetGlobals(LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        SBCEDIECRSettings: Record "SBCEDI ECR Settings";
    begin
        SBCEDIECRSettings := GetSBCEDISettings();
        GlobalAllowDifferentBilltoPayto := SBCEDIECRSettings."Allow Different Bill-to/Pay-to";
        GlobalUsePayerAccount := SBCEDIECRSettings."Use Payer Account";
        GlobalPaymentGLAccount := SBCEDIECRSettings."Payment GL Account";
        GlobalCreateAdjustmentEntries := SBCEDIECRSettings."Create Adjustment Entries";
        GlobalDefaultTradeRefundAccount := SBCEDIECRSettings."Default Trade Customer";
        GlobalBankAccountNo := SBCEDIECRSettings."Bank Account No.";
        GlobalSummarizeDefaultTradeRefund := SBCEDIECRSettings."Summarize Default Trade";
        GlobalSetBalanceAccountOnPayments := SBCEDIECRSettings."Set. Bal Account on Payments";
        GlobalDefaultTradeRefundAccountName := GetCustomerName(GlobalDefaultTradeRefundAccount, MaxStrLen(GlobalDefaultTradeRefundAccount));
        GlobalDefaultCustomerGroup := GetCustomerPostingGroup(GlobalDefaultTradeRefundAccount);
        SetGlobalPostingDate(LAXEDIPaymentRemitAdvice);
        GlobalRegex.Regex(StrSubstNo(SBCDocumentNoPatternLabel, SBCGroupNameLabel));
        if not IsNullGuid(SBCEDIECRSettings."Payment Journal Batch ID") then
            GlobalRefundGenJournalBatch.GetBySystemId(SBCEDIECRSettings."Payment Journal Batch ID");
        GlobalStartTimeStamp := CurrentDateTime();
    end;

    local procedure SetGlobalPostingDate(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        Dates: Dictionary of [Date, Integer];
        DateKey: Date;
    begin
        if LAXEDIPaymentRemitAdvice."Document Date" <> 0D then
            if Dates.Add(LAXEDIPaymentRemitAdvice."Document Date", 0) then;
        if LAXEDIPaymentRemitAdvice."Posting Date" <> 0D then
            if Dates.Add(LAXEDIPaymentRemitAdvice."Posting Date", 0) then;
        if Dates.Add(WorkDate(), 0) then;
        while GLobalPostingDate = 0D do begin
            DateKey := Dates.Keys().Get(1);
            GLobalPostingDate := DateKey;
            Dates.Remove(DateKey);
        end;
    end;

    procedure CreateNAVSuggestedPayment(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIDocument: Record "LAX EDI Document")
    var
        EDIRecDocHdr2: Record "LAX EDI Receive Document Hdr.";
        EDITemplate: Record "LAX EDI Template";
        GenJournalTemplate: Record "Gen. Journal Template";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        // #275
        // Allow refunds to go to the cash receipts journal instead of the payment journal
        //if EDIPaymentAdvice."Remittance Type" <> EDIPaymentAdvice."Remittance Type"::Payment then
        //    exit;
        // #275

        EDIRecDocHdr2.Get(EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocHdr2."Data Error" := true;
        EDIRecDocHdr2."Error Message Text" := '';
        EDIRecDocHdr2.Modify;

        if EDIPaymentAdvice.Released = false then
            Error(Text013 + Text023);
        // EDIDocument.Get(
        //   EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
        //   EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);
        // EDITemplate.Get(EDIRecDocHdr."EDI Template Code");
        EDIDocument.TestField("Journal Template Name");
        EDIDocument.TestField("Gen. Journal Batch Name");

        GetPaymentAccountType(EDIRecDocHdr, EDIDocument, Customer, Vendor);

        GenJournalTemplate.Get(EDIDocument."Journal Template Name");
        case GenJournalTemplate.Type of
            GenJournalTemplate.Type::"Cash Receipts":
                CreateBankAccountJnlLine(EDIDocument, EDIRecDocHdr, EDIPaymentAdvice, Customer, Vendor); // This is the function that is responsible for creating the journal lines.
            // GenJournalTemplate.Type::Deposits:
            //     CreateDepositHeader(EDIRecDocHdr, EDIPaymentAdvice);
            else
                Error(
                  Text014,
                  EDIDocument."Journal Template Name");
        end;
        // if GuiAllowed then
        //     DispWindow.Close;

        EDIRecDocHdr2."Data Error" := false;
        EDIRecDocHdr2.Modify;
    end;

    procedure GetPaymentAccountType(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIDocument: Record "LAX EDI Document"; Customer: Record Customer; Vendor: Record Vendor)
    var
        EDITradePartner: Record "LAX EDI Trade Partner";
        EDIRecDocField: Record "LAX EDI Receive Document Field";
        EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice";

        EDICustCrossRef: Record "LAX EDI Cust. Cross Reference";
        EDIVendCrossRef: Record "LAX EDI Vend. Cross Reference";

    begin
        EDITradePartner.Get(EDIRecDocHdr."Trade Partner No.");

        EDIRecDocField.Reset;
        EDIRecDocField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"LAX EDI Payment Remit Advice");
        EDIRecDocField.SetRange("Field No.", EDIPaymentAdvice.FieldNo("Payer Account No."));
        if EDIRecDocField.FindFirst() then
            case EDIDocument."Payer Account Type" of
                EDIDocument."Payer Account Type"::Customer:
                    begin
                        if EDIRecDocField.Substitution then
                            Customer.Get(EDIRecDocField."Field Text Value")
                        else begin
                            if EDITradePartner."Customer No." <> '' then
                                Customer.Get(EDITradePartner."Customer No.")
                            else begin
                                EDICustCrossRef.Reset;
                                EDICustCrossRef.SetRange(
                                  "Trade Partner No.", EDIRecDocField."Trade Partner No.");
                                EDICustCrossRef.SetRange(
                                  "EDI Sell To Code", CopyStr(EDIRecDocField."Field Text Value", 1, 20));
                                EDICustCrossRef.FindFirst();
                                Customer.Get(EDICustCrossRef."Sell To Code");
                            end;
                        end;
                    end;
                EDIDocument."Payer Account Type"::Vendor:
                    begin
                        if EDIRecDocField.Substitution then
                            Vendor.Get(EDIRecDocField."Field Text Value")
                        else begin
                            if EDITradePartner."Vendor No." <> '' then
                                Vendor.Get(EDITradePartner."Vendor No.")
                            else begin
                                EDIVendCrossRef.Reset;
                                EDIVendCrossRef.SetRange(
                                  "Trade Partner No.", EDIRecDocField."Trade Partner No.");
                                EDIVendCrossRef.SetRange(
                                "EDI Buy-from Code", CopyStr(EDIRecDocField."Field Text Value", 1, 20));
                                EDIVendCrossRef.FindFirst();
                                Vendor.Get(EDIVendCrossRef."Buy-from Code");
                            end;
                        end;
                    end;
            end
        else
            Error(Text008);
        if Customer."Bill-to Customer No." <> '' then
            Customer.Get(Customer."Bill-to Customer No.");
    end;

    procedure CreateBankAccountJnlLine(EDIDocument: Record "LAX EDI Document"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; Customer: Record Customer; Vendor: Record Vendor)
    var

        EDIPaymentAdvice2: Record "LAX EDI Payment Remit Advice";
        LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlBatch2: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        ExistingGenJnlLine: Record "Gen. Journal Line";
        NoSeriesLine: Record "No. Series Line";
        // EDIPaymentNo: Integer;
        OpenBatchFound: Boolean;
        UsePayerAccount: Boolean;
        FullRefund: Boolean;
        Sign: Integer;
        TradeRefund: Boolean;
        CustomerNotFound: Boolean;
        SummarizeDefaultTradeRefund: Boolean;
        LineAccountNo: Code[20];
        LineAppliesToDocNo: Code[20];
        BatchSequence: Code[10];
        NoSeries: Code[10];
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        CreateEDIAlert: Codeunit "LAX EDI Create Alert";
        LastDocumentNo: Code[20];
        LineNo: Integer;
        GenJnlBatchName: Code[10];
        GenJnlTemplate: Record "Gen. Journal Template";
        InsertNewLine: Boolean;
        GenJnlLine3: Record "Gen. Journal Line";
    begin
        if EDIPaymentAdvice."Suggested Deposit Created" then
            Error(Text024, EDIPaymentAdvice."No.");

        // EDIDocument.Get(
        //   EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
        //   EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        if EDIPaymentAdvice."Suggested Cash Receipt Journal" then
            if GuiAllowed then begin
                if not Confirm(
                  StrSubstNo(
                    Text016, EDIPaymentAdvice."No.") +
                  Text017)
                then
                    Error(Text018);
            end else
                Error(Text016, EDIPaymentAdvice."No.");

        if GuiAllowed then begin
            GlobalDispWindow.Open(
              Text019 + '\' +
              PadStr('Payer Name', 25, ' ') + '#1###########################\' +
              PadStr('Batch Name', 25, ' ') + '#2###########################\' +
              PadStr('Total Payment Amount', 25, ' ') + '#3###########################\' +
              PadStr('Account Type', 25, ' ') + '#4###########################\' +
              PadStr('Account No.', 25, ' ') + '#5###########################\' +
              PadStr('Amount', 25, ' ') + '#6###########################\' +
              PadStr('Applies-To Doc. Type', 25, ' ') + '#7###########################\' +
              PadStr('Applies-To Doc. No.', 25, ' ') + '#8###########################');
            GlobalDispWindow.Update(1, EDIPaymentAdvice."Payer Name");
            GlobalDispWindow.Update(2, GenJnlBatchName);
            GlobalDispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        end;

        LastDocumentNo := '';
        GenJnlBatchName := '';
        GenJnlBatchName := EDIDocument."Gen. Journal Batch Name";

        GenJnlTemplate.Get(EDIDocument."Journal Template Name");
        GenJnlBatch.Get(GenJnlTemplate.Name, GenJnlBatchName);

        GenJnlLine.Reset;
        GenJnlLine.SetCurrentKey("LAX EDI Internal Doc. No.");
        GenJnlLine.SetRange("LAX EDI Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        GenJnlLine.SetFilter(SystemCreatedAt, '<%1', GlobalStartTimeStamp);
        if GenJnlLine.FindFirst() then
            GenJnlLine.DeleteAll(true);

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
        if GenJnlLine.FindFirst() then begin
            OpenBatchFound := false;
            BatchSequence := '00';
            repeat
                BatchSequence := IncStr(BatchSequence);
                GenJnlBatchName := EDIDocument."Gen. Journal Batch Name";
                GenJnlBatchName := GenJnlBatchName + BatchSequence;
                GenJnlLine2.Reset;
                GenJnlLine2.SetRange("Journal Template Name", GenJnlTemplate.Name);
                GenJnlLine2.SetRange("Journal Batch Name", GenJnlBatchName);
                if not GenJnlLine2.FindFirst() then begin
                    GenJnlBatch2.Reset;
                    GenJnlBatch2.SetRange(
                      "Journal Template Name", GenJnlTemplate.Name);
                    GenJnlBatch2.SetRange(Name, GenJnlBatchName);
                    if GenJnlBatch2.FindFirst() then
                        OpenBatchFound := true
                    else begin
                        GenJnlBatch2.Init;
                        GenJnlBatch2.Copy(GenJnlBatch);
                        GenJnlBatch2.Name := GenJnlBatchName;
                        GenJnlBatch2.Description := GenJnlBatch2.Description + ' ' + EDIPaymentAdvice."Payment No.";
                        GenJnlBatch2.Insert(true);
                        if GlobalRefundGenJournalBatch."Journal Template Name" <> '' then begin
                            GenJnlBatch2.Init();
                            GenJnlBatch2.Copy(GlobalRefundGenJournalBatch);
                            GenJnlBatch2.Name := GlobalRefundGenJournalBatch.Name + BatchSequence;
                            GenJnlBatch2.Description := GenJnlBatch2.Description + ' ' + EDIPaymentAdvice."Payment No.";
                            if GenJnlBatch2.Insert(true) then
                                GlobalRefundGenJournalBatch := GenJnlBatch2;
                        end;

                        OpenBatchFound := true;
                    end;
                end;
            until OpenBatchFound = true;
        end;
        GlobalCashReceiptJournalBatchName := GenJnlBatchName;
        EDIPaymentAdvice2.Get(EDIPaymentAdvice."No.");
        EDIPaymentAdvice2.Validate("Journal Template Name", GenJnlTemplate.Name);
        EDIPaymentAdvice2.Validate("Journal Batch Name", GenJnlBatchName);
        if (EDIPaymentAdvice2."Bank Account No." <> GlobalBankAccountNo) and (GlobalBankAccountNo <> '') then
            EDIPaymentAdvice2."Bank Account No." := GlobalBankAccountNo;
        EDIPaymentAdvice2.Modify;

        NoSeriesLine.LockTable(true);
        if GenJnlBatch."No. Series" <> '' then begin
            NoSeries := GenJnlBatch."No. Series";
            LastDocumentNo := GetNoSeries(NoSeries);
        end else
            if EDIPaymentAdvice."Payment No." = '' then
                Error(Text020, GenJnlBatchName);

        Commit;

        if GuiAllowed then begin
            GlobalDispWindow.Update(2, GenJnlBatchName);
            GlobalDispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        end;

        // GenJnlLine.Reset;
        // GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
        // GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
        // if GenJnlLine.FindLast() then
        //     LineNo := GenJnlLine."Line No." + 10000
        // else
        //     LineNo := 10000;

        GenJnlLine.Reset;
        LineNo := GenJnlLine.GetNewLineNo(GenJnlTemplate.Name, GenJnlBatchName);

        LAXEDIPmtRemitAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        // #275
        //LAXEDIPmtRemitAdviceLine.SetRange(Adjustment, false);
        // #275
        if LAXEDIPmtRemitAdviceLine.IsEmpty() then
            exit;


        //DeductionAmt := EDIPaymentAdvice."Payment Amount";
        //LAXEDIPmtRemitAdviceLine.SetRange("Journal Account Type", "LAX EDI Journal Account Type"::"G/L Account");
        LAXEDIPmtRemitAdviceLine.FindSet();
        repeat
            case true of
                LAXEDIPmtRemitAdviceLine."Document Type" = LAXEDIPmtRemitAdviceLine."Document Type"::Refund:
                    RefundAmt += (-LAXEDIPmtRemitAdviceLine.Amount);
                LAXEDIPmtRemitAdviceLine."Journal Account Type" = "LAX EDI Journal Account Type"::"G/L Account":
                    DeductionAmt += (LAXEDIPmtRemitAdviceLine.Amount);
            end;
            Totamt += (-LAXEDIPmtRemitAdviceLine.Amount);
        until LAXEDIPmtRemitAdviceLine.next = 0;
        // Deductions were already included in the cash amount in the 820. Only need to allow for refunds.
        //Adjamt += Deductionamt + RefundAmt;
        Adjamt += RefundAmt;

        CreateBankAccountDepositLine(EDIRecDocHdr, EDIPaymentAdvice, GenJnlLine, LAXEDIReceiveDocumentField, LastDocumentNo, LineNo, GenJnlBatchName, GenJnlTemplate);

        LAXEDIPmtRemitAdviceLine.SetRange("Journal Account Type");
        LAXEDIPmtRemitAdviceLine.FindSet();
        repeat
            //yyy 456 >>
            // We have to summarize the CR Journal Lines for all payments against a given invoice in order for the related changes for the g/l to hit 
            // the discount account during posting if the net payment is less than gross payment less pmt. discount. We have new events to handle
            // this during posting
            sign := -1;
            InsertNewLine := false;

            if GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.") <> '' then begin
                GenJnlLine3.Reset();
                GenJnlLine3.SetRange("Journal Template Name", GenJnlTemplate.Name);
                GenJnlLine3.SetRange("Journal Batch Name", GenJnlBatchName);
                GenJnlLine3.SetRange("Account Type", GenJnlLine3."Account Type"::Customer);
                GenJnlLine3.SetRange("Account No.", EDIPaymentAdvice."Payer Account No."); // yyy 456 - must match payer account written to journal line, not sell-to from remit advice line
                GenJnlLine3.SetRange("Applies-to Doc. Type", LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type");
                GenJnlLine3.SetRange("Applies-to Doc. No.", GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No."));
                if not GenJnlLine3.FindFirst() then
                    InsertNewLine := true;
            end else
                InsertNewLine := true;

            if InsertNewLine then begin
                //yyy 456 <<
                // if not (LAXEDIPmtRemitAdviceLine.Amount - LAXEDIPmtRemitAdviceLine."Discount Amount" = 0) then begin
                GenJnlLine.InitNewLine(GLobalPostingDate, GenJnlLine."Document Date", GenJnlLine."VAT Reporting Date", '', GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code", GenJnlLine."Dimension Set ID", GenJnlLine."Reason Code");
                // UsePayerAccount := (LAXEDIPmtRemitAdviceLine."Journal Account Type" in ["LAX EDI Journal Account Type"::Customer, "LAX EDI Journal Account Type"::"G/L Account"]) and ((LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-To Doc. Type"::Payment) /**or ((LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-To Doc. Type"::Refund) and (LAXEDIPmtRemitAdviceLine."Discount Amount" <> 0))**/) and GlobalUsePayerAccount; // Payments
                UsePayerAccount := (LAXEDIPmtRemitAdviceLine."Journal Account Type" in ["LAX EDI Journal Account Type"::Customer, "LAX EDI Journal Account Type"::"G/L Account"]) and (LAXEDIPmtRemitAdviceLine.Description = '') and GlobalUsePayerAccount; // Non-Allowance
                                                                                                                                                                                                                                                             // FullRefund := (LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-To Doc. Type"::Refund) and (LAXEDIPmtRemitAdviceLine.Amount = 0) and (LAXEDIPmtRemitAdviceLine."Discount Amount" <> 0); // Full Refunds
                                                                                                                                                                                                                                                             // TradeRefund := not FullRefund and (LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-To Doc. Type"::Refund) and (LAXEDIPmtRemitAdviceLine.Description <> '');
                                                                                                                                                                                                                                                             // TradeRefund := not FullRefund and (LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-To Doc. Type"::Refund);
                TradeRefund := (LAXEDIPmtRemitAdviceLine.Description <> ''); //Allowance Type is always set in the description.
                CustomerNotFound := LAXEDIPmtRemitAdviceLine."Journal Account Type" = "LAX EDI Journal Account Type"::"G/L Account";
                if (LAXEDIPmtRemitAdviceLine."Journal Account Type" = "LAX EDI Journal Account Type"::Customer) then
                    SummarizeDefaultTradeRefund := GlobalSummarizeDefaultTradeRefund and (GlobalDefaultCustomerGroup = GetCustomerPostingGroup(LAXEDIPmtRemitAdviceLine."Journal Account No."));

                // #275
                // all entries go to the cash receipt journal
                //case true of
                //    UsePayerAccount, (GlobalRefundGenJournalBatch.Name = ''):
                //        begin
                //            GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlTemplate.Name, GenJnlBatchName);
                //            GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
                //            GenJnlLine."Journal Batch Name" := GenJnlBatchName;
                //        end;
                //    else begin
                //        GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GlobalRefundGenJournalBatch."Journal Template Name", GlobalRefundGenJournalBatch.Name);
                //        GenJnlLine."Journal Template Name" := GlobalRefundGenJournalBatch."Journal Template Name";
                //        GenJnlLine."Journal Batch Name" := GlobalRefundGenJournalBatch.Name;
                //    end;
                //end;
                GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlTemplate.Name, GenJnlBatchName);
                GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
                GenJnlLine."Journal Batch Name" := GenJnlBatchName;
                // #275

                // GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                LAXEDIReceiveDocumentField.Reset;
                LAXEDIReceiveDocumentField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
                LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
                LAXEDIReceiveDocumentField.SetRange("Table No.", DATABASE::"Gen. Journal Line");
                LAXEDIReceiveDocumentField.SetRange("Field No.", GenJnlLine.FieldNo("Account Type"));
                if LAXEDIReceiveDocumentField.Findfirst() then
                    case UpperCase(LAXEDIReceiveDocumentField."Field Text Value") of
                        UpperCase('G/L ACCOUNT'):
                            GenJnlLine."Bal. Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        UpperCase('BANK Account'):
                            GenJnlLine."Bal. Account Type" := GenJnlLine."Account Type"::"Bank Account";
                    end
                else
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
                // if EDIPaymentAdvice."Payer Account Type" =
                //   EDIPaymentAdvice."Payer Account Type"::Customer
                // then
                //     GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment
                // else
                //     GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
                GenJnlLine."Document Type" := LAXEDIPmtRemitAdviceLine."Document Type";
                // #275
                // we fixed the account type in the Remit Advice Lines, so leave it alone
                //if CustomerNotFound and (GlobalPaymentGLAccount = '') then //If an account type is GL Account, it means the customer could not be found.
                //    GenJnlLine.Validate("Account Type", "LAX EDI Journal Account Type"::Customer)
                //else
                // #275
                GenJnlLine.Validate("Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type");

                // #275            
                // change document type from payment in the remit advice line to blank in the cash receipts journal line
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                if (LAXEDIPmtRemitAdviceLine."Document Type" = LAXEDIPmtRemitAdviceLine."Document Type"::Payment) and (LAXEDIPmtRemitAdviceLine."Journal Account Type" = LAXEDIPmtRemitAdviceLine."Journal Account Type"::"G/L Account") then begin
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                end;
                // #275

                CheckBillToPayToAlertSettings();
                case true of
                    UsePayerAccount, FullRefund:
                        LineAccountNo := EDIPaymentAdvice."Payer Account No."; // Emerson
                    (TradeRefund and CustomerNotFound), SummarizeDefaultTradeRefund:
                        if GlobalPaymentGLAccount = '' then
                            LineAccountNo := GlobalDefaultTradeRefundAccount // Default Customer
                        else begin
                            GenJnlLine.Validate("Account Type", "Gen. Journal Account Type"::"G/L Account");
                            LineAccountNo := GlobalPaymentGLAccount;
                        end;
                    else
                        LineAccountNo := LAXEDIPmtRemitAdviceLine."Journal Account No."; // Sell-To Customer
                end;
                // #275
                // Always use the bill-to customer for payments and keep the g/l account no. from the remit advice line for deductions and refunds
                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account" then
                    LineAccountNo := LAXEDIPmtRemitAdviceLine."Journal Account No."
                else
                    LineAccountNo := EDIPaymentAdvice."Payer Account No.";
                // #275

                GenJnlLine.Validate("Account No.", LineAccountNo);

                // 456
                // Handle refunds appropriately
                if LAXEDIPmtRemitAdviceLine."Document Type" = LAXEDIPmtRemitAdviceLine."Document Type"::Refund then
                    ConvertCustRefundToGLPaymentLine(GenJnlLine, LAXEDIPmtRemitAdviceLine."SBC Customer No.");
                // 456

                if GlobalSetBalanceAccountOnPayments and (GenJnlLine."Bal. Account No." = '') then
                    SetBalanceAccountOnLine(EDIRecDocHdr."Internal Doc. No.", EDIPaymentAdvice, LAXEDIPmtRemitAdviceLine, GenJnlLine); // This sets the cross reference gl account on the journal line.
                if EDIPaymentAdvice."Currency Code" <> '' then
                    GenJnlLine.Validate("Currency Code", EDIPaymentAdvice."Currency Code");
                // GenJnlLine.Validate("Bal. Account Type", EDIPaymentAdvice."Payer Account Type");
                // GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Payer Account No.");
                // case true of
                //     GenJnlLine."Document Type" = "Gen. Journal Document Type"::Payment:
                //         Sign := -1
                //     else
                //         Sign := 1;
                // end;
                // GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Payer Account No.");
                // yyy 456 >>
                // we force sign to -1 at beginning of repeat...until so insert or modify path works the same
                //case true of
                //    UsePayerAccount:
                //        Sign := -1
                //    else
                //        Sign := 1;
                //end;
                // yyy 456 <<

                // #275
                // Always post deductions as positive amounts in the cash receipts journal.
                // yyy 456 >>
                // we force sign to -1 at beginning of repeat...until so insert or modify path works the same
                //if LAXEDIPmtRemitAdviceLine."Journal Account Type" = LAXEDIPmtRemitAdviceLine."Journal Account Type"::"G/L Account" then
                //    Sign := -1;
                //sign := -1;
                // yyy 456 <<
                // #275

                if FullRefund then
                    GenJnlLine.Validate(Amount, Sign * LAXEDIPmtRemitAdviceLine."Discount Amount")
                else
                    GenJnlLine.Validate(Amount, Sign * LAXEDIPmtRemitAdviceLine.Amount);
                if GenJnlLine."Posting Date" <> GLobalPostingDate then
                    GenJnlLine.Validate("Posting Date", GLobalPostingDate);
                GenJnlLine."Document Date" := LAXEDIPmtRemitAdviceLine."Document Date";
                // GenJnlLine."Due Date" := WorkDate();
                // GenJnlLine."Pmt. Discount Date" := WorkDate();
                GenJnlLine."Document No." := LastDocumentNo;
                GenJnlLine."LAX EDI Payment" := true;
                GenJnlLine."LAX EDI Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
                if EDIDocument."Set Applies-to Doc. No." then
                    case true of
                        TradeRefund:
                            begin
                                GenJnlLine.Validate("Applies-to Doc. Type", "Gen. Journal Document Type"::"Credit Memo");
                                // GenJnlLine."External Document No." := GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.").ToText();
                                GenJnlLine."External Document No." := GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.");
                            end;
                        (UsePayerAccount or FullRefund):
                            begin
                                GenJnlLine.Validate("Applies-to Doc. Type", LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type");
                                // GenJnlLine.Validate("Applies-to Doc. No.", GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.").ToText());
                                GenJnlLine.Validate("Applies-to Doc. No.", GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No."));
                            end;
                        else
                            GenJnlLine."Applies-to ID" := EDIPaymentAdvice."Payment No.";
                    end;


                If GenJnlLine."External Document No." = '' then
                    GenJnlLine."External Document No." := EDIPaymentAdvice."Payment No.";
                GenJnlLine."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";

                // #275
                // keep g/l account description for g/l lines
                if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"G/L Account" then begin
                    // #275
                    case true of
                        UsePayerAccount, FullRefund:
                            SetJournalDescription(EDIPaymentAdvice."Payer Name", EDIPaymentAdvice."Payer Account No.", LAXEDIPmtRemitAdviceLine, GenJnlLine);
                        TradeRefund and CustomerNotFound:
                            SetJournalDescription(GlobalDefaultTradeRefundAccountName, GlobalDefaultTradeRefundAccount, LAXEDIPmtRemitAdviceLine, GenJnlLine);
                        (LAXEDIPmtRemitAdviceLine.Description <> ''):
                            // GenJnlLine.Description := LAXEDIPmtRemitAdviceLine.Description;
                            SetJournalDescription(GenJnlLine.Description, GenJnlLine."Account No.", LAXEDIPmtRemitAdviceLine, GenJnlLine);
                    end;
                end;
                // #275
                /*
                            ExistingGenJnlLine.Reset();
                            ExistingGenJnlLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                            ExistingGenJnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                            // ExistingGenJnlLine.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.");
                            // if FullRefund or TradeRefund then
                            if GenJnlLine."External Document No." <> '' then
                                ExistingGenJnlLine.SetFilter("External Document No.", '%1', GenJnlLine."External Document No.");
                            if GenJnlLine."Applies-to Doc. No." <> '' then
                                ExistingGenJnlLine.SetFilter("Applies-to Doc. No.", '%1', GenJnlLine."Applies-to Doc. No.");
                            ExistingGenJnlLine.SetRange("Account No.", GenJnlLine."Account No.");
                            ExistingGenJnlLine.SetFilter(Amount, '<>%1', 0);
                            ExistingGenJnlLine.SetFilter("Line No.", '<>%1', GenJnlLine."Line No.");
                            ExistingGenJnlLine.SetRange(Description, GenJnlLine.Description);
                            // if (LAXEDIPmtRemitAdviceLine.Description = '') and ExistingGenJnlLine.FindFirst() then begin
                            if ExistingGenJnlLine.FindFirst() then begin
                                if (ExistingGenJnlLine."Document Type" <> GenJnlLine."Document Type") and (abs(GenJnlLine.Amount) > abs(ExistingGenJnlLine.Amount)) then
                                    ExistingGenJnlLine."Document Type" := GenJnlLine."Document Type";
                                ExistingGenJnlLine.Validate(Amount, ExistingGenJnlLine.Amount + GenJnlLine.Amount); // Sign should already be properly adjusted here.
                                ExistingGenJnlLine.Modify();
                            end else begin
                */

                // Simply force the transfer of the applies to info to the journal line. 
                // We also disabled the ApplyEntries() call below as it wipes out what we just did here.
                if (LAXEDIPmtRemitAdviceLine."Journal Account Type" = LAXEDIPmtRemitAdviceLine."Journal Account Type"::Customer) and (LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No." <> '') then begin
                    GenJnlLine.Validate("Applies-to Doc. Type", LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type");
                    GenJnlLine.Validate("Applies-to Doc. No.", GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No."));
                end;
                // #275
                // Store customer dimension for reporting 
                //if GenJnlLine.Insert(true) then;
                //if GenJnlLine.Insert(true) then
                GenJnlLine.Validate(Description, LAXEDIPmtRemitAdviceLine.Description);

                // 456
                // We had setup Refund lines to handle the debit payment effect, and set Document Type above as
                // blank to keep jnl in balance. With the other changes related to this new functionality, we can 
                // just keep all the lines payment lines, as blank Doc Types do not hit the g/l discount account
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                // 456

                GenJnlLine.Insert(true);
                InsertCustomerDim(GenJnlLine, EDIPaymentAdvice, LAXEDIPmtRemitAdviceLine);
                // yyy 456 >>
            end else begin
                // yyy 456 - clear Applies-to Doc. No. before Validate(Amount) to prevent BC's
                // CheckPaymentTolerance from adjusting the accumulated amount when it matches the
                // invoice net-of-discount amount (which makes the journal balance off by the discount).
                // Restore the field directly (no validate) before Modify so posting still applies correctly.
                LineAppliesToDocNo := GenJnlLine3."Applies-to Doc. No.";
                GenJnlLine3."Applies-to Doc. No." := '';
                if FullRefund then
                    GenJnlLine3.Validate(Amount, GenJnlLine3.Amount + (Sign * LAXEDIPmtRemitAdviceLine."Discount Amount"))
                else
                    GenJnlLine3.Validate(Amount, GenJnlLine3.Amount + (Sign * LAXEDIPmtRemitAdviceLine.Amount));
                GenJnlLine3."Applies-to Doc. No." := LineAppliesToDocNo;
                GenJnlLine3.Modify(true);
            end;
        // yyy 456 <<
        //          end;
        // #275
        // end;
        until LAXEDIPmtRemitAdviceLine.Next() = 0;

        //#275      ApplyEntries(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName, GenJnlLine, LastDocumentNo, Customer, Vendor, EDIDocument);

        EDIPaymentAdvice2.Get(EDIPaymentAdvice."No.");
        EDIPaymentAdvice2."Suggested Cash Receipt Journal" := true;
        EDIPaymentAdvice2.Modify;

        CreateEDIAlert.UpdateAlertStatus(EDIRecDocHdr);
    end;

    procedure ApplyEntries(EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice";
        EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.";
        GenJnlBatchName: Code[10];
        GenJnlLine: Record "Gen. Journal Line";
        LastDocumentNo: Code[20];
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDIDocument: Record "LAX EDI Document")
    var

        EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        // EDIPaymentAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
        // GLAccountTmp: Record "G/L Account" temporary;
        GenJournalTemplate: Record "Gen. Journal Template";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        // LineNo: Integer;
        // TotalAdjustment: Decimal;
        // CreateJnlLine: Boolean;
        // SummarizeAdjustments: Boolean;
        IsHandled: Boolean;
    begin
        // EDIDocument.Get(
        //   EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
        //   EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        EDIPaymentAdviceLine.SetRange("Document Type", "LAX EDI Jnl Apply-to Doc. Type"::Payment);
        EDIPaymentAdviceLine.SetRange(Adjustment, false);
        EDIPaymentAdviceLine.SetCurrentKey("Document Type", Amount);
        EDIPaymentAdviceLine.SetAscending(Amount, false);

        if EDIPaymentAdviceLine.FindSet() then
            repeat
                if GuiAllowed then begin
                    GlobalDispWindow.Update(4, EDIPaymentAdviceLine."Journal Account Type");
                    GlobalDispWindow.Update(5, EDIPaymentAdviceLine."Journal Account No.");
                    GlobalDispWindow.Update(6, EDIPaymentAdviceLine.Amount);
                    GlobalDispWindow.Update(7, EDIPaymentAdviceLine."Journal Applies-to Doc. Type");
                    GlobalDispWindow.Update(8, EDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                end;
                case EDIPaymentAdvice."Payer Account Type" of
                    EDIPaymentAdvice."Payer Account Type"::Customer:
                        // if (EDIPaymentAdviceLine.Amount - EDIPaymentAdviceLine."Discount Amount" <> 0) then //TODO(Follow up with SBC/Emerson on what these types of entries are.)
                        GetCustLedgEntry(EDIPaymentAdviceLine, EDIPaymentAdvice, EDIDocument);
                    EDIPaymentAdvice."Payer Account Type"::Vendor:
                        SetVendLedgerEntry(EDIPaymentAdviceLine, EDIPaymentAdvice);
                end;
            until EDIPaymentAdviceLine.Next = 0;
        IsHandled := false;
        // OnBeforeCheckPmtTolerance(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName, GenJnlLine, IsHandled);
        if not IsHandled then
            PaymentToleranceMgt.PmtTolGenJnl(GenJnlLine);
        if not GlobalCreateAdjustmentEntries then
            exit;
        GenJournalTemplate.Get(EDIDocument."Journal Template Name");
        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        EDIPaymentAdviceLine.SetRange(Adjustment, true);
        EDIPaymentAdviceLine.SetRange("Journal Applies-to Doc. Type", "LAX EDI Jnl Apply-To Doc. Type"::" ");
        if EDIPaymentAdviceLine.FindFirst() then
            case GenJournalTemplate.Type of
                // GenJournalTemplate.Type::Deposits:
                //     begin
                //         EDIPaymentAdviceLine.Reset;
                //         EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
                //         EDIPaymentAdviceLine.SetRange(Adjustment, true);
                //         EDIPaymentAdviceLine.SetFilter("Journal Applies-to Doc. No.", '<>%1', '');
                //         if EDIPaymentAdviceLine.FindFirst() then
                //             repeat
                //                 GetCustLedgEntry(EDIPaymentAdviceLine, EDIPaymentAdvice);
                //             until EDIPaymentAdviceLine.Next = 0;
                //     end;
                GenJournalTemplate.Type::"Cash Receipts":
                    ApplyAdjustmentEntries(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName, GenJournalTemplate, LastDocumentNo, Customer, Vendor, EDIDocument);
            end;
    end;

    procedure GetNoSeries(NoSeries: Code[10]) NoSeriesCode: Code[20]
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostingDate: Date;
    begin
        PostingDate := WorkDate;
        Clear(NoSeriesMgt);

        NoSeriesCode := NoSeriesMgt.GetNextNo(NoSeries, PostingDate, false);
        exit(NoSeriesCode);
    end;

    procedure GetCustLedgEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIDocument: Record "LAX EDI Document")
    var
        CustLedgerDocNo: Code[20];
        DocFound: Boolean;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        DocFound := false;
        CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := false;
        CurrEDIPaymentAdviceLine.Modify;

        CustLedgerEntry.Locktable(true);
        CustLedgerEntry.Reset;
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", Open);
        CustLedgerEntry.SetRange("Customer No.", CurrEDIPaymentAdvice."Payer Account No.");
        CustLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.FindSet() then begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end else begin
            case EDIDocument."Apply-to  Doc. No. Format Rule" of
                EDIDocument."Apply-to  Doc. No. Format Rule"::" ":
                    begin
                        if GuiAllowed then
                            GlobalDispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                        SetCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice, CustLedgerEntry);
                    end;
                else
                    if CurrEDIPaymentAdviceLine."Received Applies-to Doc. No." = '' then begin
                        if CurrEDIPaymentAdviceLine."Document External Doc. No." <> '' then
                            CustLedgerEntry.SetRange(
                              "External Document No.", CurrEDIPaymentAdviceLine."Document External Doc. No.");
                        repeat
                            DocFound := false;
                            CustLedgerDocNo := '';
                            if FormatDocumentNo(
                              CustLedgerEntry, CurrEDIPaymentAdviceLine, DocFound, CustLedgerDocNo, EDIDocument)
                            then begin
                                CurrEDIPaymentAdviceLine."Received Applies-to Doc. No." :=
                                  CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.";
                                CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No." := CustLedgerDocNo;
                            end else
                                CurrEDIPaymentAdviceLine."Received Applies-to Doc. No." :=
                                  CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.";
                            CurrEDIPaymentAdviceLine.Modify;
                        until (DocFound) or (CustLedgerEntry.Next = 0);
                        if GuiAllowed then
                            GlobalDispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                        SetCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice, CustLedgerEntry)
                    end else begin
                        if GuiAllowed then
                            GlobalDispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                        SetCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice, CustLedgerEntry);
                    end;
            end;
        end;
    end;

    procedure FormatDocumentNo(CustLedgerEntry: Record "Cust. Ledger Entry"; CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var DocFound: Boolean; var LedgerDocNo: Code[20]; EDIDocument: Record "LAX EDI Document"): Boolean
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        CurrentApplytoDocNo: Code[20];
        Char: Char;
        TextValue: Text[250];
        Position: Integer;
        Length: Integer;
        NumericValue: Text[250];
        AlphaNumericValue: Text[250];
    begin
        CurrentApplytoDocNo := CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.";
        LedgerDocNo := CustLedgerEntry."Document No.";
        case EDIDocument."Apply-to  Doc. No. Format Rule" of
            EDIDocument."Apply-to  Doc. No. Format Rule"::AlphaNumeric:
                begin
                    Position := 1;
                    Length := StrLen(LedgerDocNo);
                    AlphaNumericValue := '';
                    repeat
                        TextValue := CopyStr(LedgerDocNo, Position, 1);
                        Evaluate(Char, TextValue);
                        if (((Char >= 48) and (Char <= 57)) or
                           ((Char >= 65) and (Char <= 90)) or
                            ((Char >= 97) and (Char <= 122)))
                        then
                            AlphaNumericValue := AlphaNumericValue + TextValue;
                        Position := Position + 1;
                    until Position = Length + 1;
                    LedgerDocNo := AlphaNumericValue;
                    if LedgerDocNo = CurrentApplytoDocNo then begin
                        DocFound := true;
                        LedgerDocNo := CustLedgerEntry."Document No.";
                    end;
                end;
            EDIDocument."Apply-to  Doc. No. Format Rule"::Numeric:
                begin
                    Position := 1;
                    Length := StrLen(LedgerDocNo);
                    NumericValue := '';
                    repeat
                        TextValue := CopyStr(LedgerDocNo, Position, 1);
                        Evaluate(Char, TextValue);
                        if (Char >= 48) and (Char <= 57) then
                            NumericValue := NumericValue + TextValue;
                        Position := Position + 1;
                    until Position = Length + 1;
                    LedgerDocNo := NumericValue;
                    if LedgerDocNo = CurrentApplytoDocNo then begin
                        DocFound := true;
                        LedgerDocNo := CustLedgerEntry."Document No.";
                    end;
                end;
        end;

        exit(DocFound);
    end;

    procedure SetVendLedgerEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        ApplicationAmount: Decimal;
        IsHandled: Boolean;
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendEntryEdit: Codeunit "Vend. Entry-Edit";
    begin
        CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := false;

        VendLedgerEntry.Reset;
        VendLedgerEntry.SetCurrentKey("Document Type", "Vendor No.", "Posting Date", "Currency Code");
        VendLedgerEntry.SetRange("Buy-from Vendor No.", CurrEDIPaymentAdvice."Payer Account No.");
        VendLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        // VendLedgerEntry.SetRange("Document No.", GetCleanAppliesToDocNo(CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.").ToText());
        VendLedgerEntry.SetRange("Document No.", GetCleanAppliesToDocNo(CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No."));
        if CurrEDIPaymentAdviceLine."Document Posting Date" <> 0D then
            VendLedgerEntry.SetRange("Posting Date", CurrEDIPaymentAdviceLine."Document Posting Date");
        VendLedgerEntry.SetRange(Open, true);
        if VendLedgerEntry.FindFirst() then begin
            VendLedgerEntry.Validate("Applies-to ID", CurrEDIPaymentAdvice."Payment No.");
            VendLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            ApplicationAmount := CurrEDIPaymentAdviceLine.Amount;
            if ABS(CurrEDIPaymentAdviceLine.Amount) > ABS(VendLedgerEntry."Remaining Amount") then
                ApplicationAmount := VendLedgerEntry."Remaining Amount"
            else
                ApplicationAmount := CurrEDIPaymentAdviceLine.Amount;
            // OnBeforeValidateVendorLedgerAppInAmount(VendLedgerEntry, CurrEDIPaymentAdviceLine, ApplicationAmount);
            VendLedgerEntry.Validate("Amount to Apply", ApplicationAmount);
            VendLedgerEntry."LAX EDI Payment" := true;
            VendLedgerEntry."LAX EDI Internal Doc. No." := CurrEDIPaymentAdvice."Internal Doc. No.";
            IsHandled := false;
            // OnBeforeEditVendLedgerEntry(VendLedgerEntry, CurrEDIPaymentAdvice, CurrEDIPaymentAdviceLine, IsHandled);
            if not IsHandled then
                VendEntryEdit.Run(VendLedgerEntry);
        end else begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end;
    end;

    procedure SetCustLedgerEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        CustEntryEdit: Codeunit "Cust. Entry-Edit";
        ApplicationAmount: Decimal;
        DiscountAmount: Decimal;
        IsHandled: Boolean;
        GenJournalLine: Record "Gen. Journal Line";
        AppliesToDocNoCode: Code[20];
        RemainingAmount: Decimal;
    begin
        CustLedgerEntry.Reset;
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", Open);
        if CurrEDIPaymentAdviceLine."Document External Doc. No." <> '' then
            CustLedgerEntry.SetRange(
              "External Document No.", CurrEDIPaymentAdviceLine."Document External Doc. No.");
        CustLedgerEntry.SetRange("Customer No.", CurrEDIPaymentAdvice."Payer Account No.");
        CustLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        // AppliesToDocNoCode := GetCleanAppliesToDocNo(CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.").ToText();
        AppliesToDocNoCode := GetCleanAppliesToDocNo(CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
        if CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No." <> '' then
            CustLedgerEntry.SetRange("Document No.", AppliesToDocNoCode);
        if CurrEDIPaymentAdviceLine."Document Posting Date" <> 0D then
            CustLedgerEntry.SetRange("Posting Date", CurrEDIPaymentAdviceLine."Document Posting Date");
        CustLedgerEntry.SetRange(Open, true);
        // CustLedgerEntry.SetFilter("Amount to Apply", '%1', 0); // This should only work when the amount to apply is not set.
        GenJournalLine.SetRange("Account No.", CurrEDIPaymentAdvice."Payer Account No.");
        GenJournalLine.SetFilter(SystemCreatedAt, '%1..', GlobalStartTimeStamp);
        GenJournalLine.SetRange("Journal Batch Name", GlobalCashReceiptJournalBatchName);
        GenJournalLine.SetRange("Applies-to Doc. Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        GenJournalLine.SetRange("Applies-to Doc. No.", AppliesToDocNoCode);
        if CustLedgerEntry.FindFirst() then begin
            GenJournalLine.SetLoadFields(Amount);
            if GenJournalLine.FindFirst() then
                ApplicationAmount := ABS(GenJournalLine.Amount);

            if CurrEDIPaymentAdviceLine.Adjustment = false then begin
                CustLedgerEntry.Validate("Applies-to ID", CurrEDIPaymentAdvice."Payment No.");
                CustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                RemainingAmount := CustLedgerEntry."Remaining Amount";

                if ApplicationAmount = 0 then
                    ApplicationAmount := ABS(CurrEDIPaymentAdviceLine.Amount);
                if ABS(ApplicationAmount) > ABS(RemainingAmount) then
                    ApplicationAmount := ABS(RemainingAmount);
                DiscountAmount := RemainingAmount - ApplicationAmount;

                if CustLedgerEntry."Due Date" < GenJournalLine."Posting Date" then
                    CustLedgerEntry."Due Date" := GenJournalLine."Posting Date";
                if CustLedgerEntry."Pmt. Discount Date" < GenJournalLine."Posting Date" then
                    CustLedgerEntry."Pmt. Discount Date" := GenJournalLine."Posting Date";

                if (DiscountAmount) < abs(GenJournalLine.Amount) then begin
                    CustLedgerEntry.Validate("Remaining Pmt. Disc. Possible", DiscountAmount);
                    CustLedgerEntry.Validate("Amount to Apply", ApplicationAmount + DiscountAmount);
                end
                else begin
                    CustLedgerEntry.Validate("Amount to Apply", ApplicationAmount);
                    CustLedgerEntry.Validate("Remaining Pmt. Disc. Possible", 0); // This is set so that we can automatically apply the discount.
                end;

                CustLedgerEntry."LAX EDI Payment" := true;
                CustLedgerEntry."LAX EDI Internal Doc. No." := CurrEDIPaymentAdvice."Internal Doc. No.";
                IsHandled := false;
                // OnBeforeEditCustLedgerEntry(CustLedgerEntry, CurrEDIPaymentAdvice, CurrEDIPaymentAdviceLine, IsHandled);
                if not IsHandled then
                    CustEntryEdit.Run(CustLedgerEntry);
            end;
        end else begin
            if GenJournalLine.FindFirst() then begin
                GenJournalLine.Description := StrSubstNo(GenJournalLine.Description + '- %1', GenJournalLine."Applies-to Doc. No.");
                GenJournalLine.Validate("Applies-to Doc. No.", '');
                if GlobalPaymentGLAccount <> '' then begin // when the applies-to doc. no. is not found, we set the account type to G/L Account and the account no. to the payment GL account.
                    GenJournalLine."Account Type" := "Gen. Journal Account Type"::"G/L Account";
                    GenJournalLine."Account No." := GlobalPaymentGLAccount;
                end;
                GenJournalLine.Modify();
            end;
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end;
    end;

    procedure ApplyAdjustmentEntries(EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; GenJnlBatchName: Code[10]; GenJnlTemplate: Record "Gen. Journal Template"; LastDocumentNo: Code[20]; Customer: Record Customer; Vendor: Record Vendor; EDIDocument: Record "LAX EDI Document")
    var

        LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        EDIPaymentAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
        GLAccountTmp: Record "G/L Account" temporary;
        LineNo: Integer;
        TotalAdjustment: Decimal;
        CreateJnlLine: Boolean;
        SummarizeAdjustments: Boolean;
        GenJnlLine: Record "Gen. Journal Line";
        PayerAccountDescriptionTextBuilder: TextBuilder;
        UsePayerAccount: Boolean;
    begin
        // EDIDocument.Get(
        //   EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
        //   EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        GLAccountTmp.Reset;
        GLAccountTmp.DeleteAll;

        LAXEDIPmtRemitAdviceLine.Reset;
        LAXEDIPmtRemitAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        LAXEDIPmtRemitAdviceLine.SetRange(Adjustment, true);
        LAXEDIPmtRemitAdviceLine.SetFilter(Amount, '<>%1', 0);
        LAXEDIPmtRemitAdviceLine.SetRange(
          "Journal Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type"::"G/L Account");
        LAXEDIPmtRemitAdviceLine.SetRange("Journal Applies-to Doc. Type", "LAX EDI Jnl Apply-To Doc. Type"::" ");
        if LAXEDIPmtRemitAdviceLine.FindSet() then
            repeat
                UsePayerAccount := (LAXEDIPmtRemitAdviceLine."Journal Account Type" = "LAX EDI Journal Account Type"::Customer) and (LAXEDIPmtRemitAdviceLine."Document Type" = "LAX EDI Jnl Apply-To Doc. Type"::Payment) and GlobalUsePayerAccount;
                LAXEDIPmtRemitAdviceLine.TestField("Journal Account No.");
                TotalAdjustment := 0;
                CreateJnlLine := false;
                SummarizeAdjustments := false;
                if EDIDocument."Summarize G/L Account Entry" then begin
                    GLAccountTmp.Reset;
                    GLAccountTmp.SetRange("No.", LAXEDIPmtRemitAdviceLine."Journal Account No.");
                    if GLAccountTmp.FindFirst() then
                        SummarizeAdjustments := false
                    else begin
                        GLAccountTmp."No." := LAXEDIPmtRemitAdviceLine."Journal Account No.";
                        GLAccountTmp.Insert;
                        SummarizeAdjustments := true;
                    end;
                    if SummarizeAdjustments then begin
                        EDIPaymentAdviceLine2.Reset;
                        EDIPaymentAdviceLine2.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
                        EDIPaymentAdviceLine2.SetRange(Adjustment, true);
                        EDIPaymentAdviceLine2.SetRange("Journal Applies-to Doc. Type", "LAX EDI Jnl Apply-To Doc. Type"::" ");
                        EDIPaymentAdviceLine2.SetRange("Journal Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type");
                        EDIPaymentAdviceLine2.SetRange("Journal Account No.", LAXEDIPmtRemitAdviceLine."Journal Account No.");
                        EDIPaymentAdviceLine2.FindSet();
                        repeat
                            case true of
                                EDIPaymentAdviceLine2."Credit Amount" <> 0:
                                    TotalAdjustment := EDIPaymentAdviceLine2."Credit Amount" + TotalAdjustment;
                                EDIPaymentAdviceLine2."Debit Amount" <> 0:
                                    TotalAdjustment := EDIPaymentAdviceLine2."Debit Amount" + TotalAdjustment;
                                else
                                    if EDIPaymentAdviceLine2.Amount <> 0 then
                                        TotalAdjustment := EDIPaymentAdviceLine2.Amount + TotalAdjustment;
                            end;
                        until EDIPaymentAdviceLine2.Next = 0;
                        CreateJnlLine := true;
                    end;
                end else
                    CreateJnlLine := true;
                if CreateJnlLine then begin
                    GenJnlLine.Reset;

                    // case true of
                    //     UsePayerAccount, (GlobalRefundGenJournalBatch.Name = ''):
                    //         begin
                    //             GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
                    //             GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
                    //         end;
                    //     else begin
                    //         GenJnlLine.SetRange("Journal Template Name", GlobalRefundGenJournalBatch."Journal Template Name");
                    //         GenJnlLine.SetRange("Journal Batch Name", GlobalRefundGenJournalBatch.Name);
                    //     end;
                    // end;
                    // // GenJnlLine.SetRange("Applies-to Doc. No.", EDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                    // // GenJnlLine.SetRange("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                    // // if GenJnlLine.FindFirst() then begin
                    // //     GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdviceLine."Journal Account No.");
                    // //     GenJnlLine.Modify();
                    // //     // exit;
                    // // end else begin
                    // //     GenJnlLine.SetRange("Applies-to Doc. No.");
                    // //     GenJnlLine.SetRange("Bal. Account Type");

                    // if GenJnlLine.FindLast() then
                    //     LineNo := GenJnlLine."Line No." + 10000
                    // else
                    //     LineNo := 10000;

                    GenJnlLine.Init;
                    case true of
                        UsePayerAccount, (GlobalRefundGenJournalBatch.Name = ''):
                            begin
                                GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GenJnlTemplate.Name, GenJnlBatchName);
                                GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
                                GenJnlLine."Journal Batch Name" := GenJnlBatchName;
                            end;
                        else begin
                            GenJnlLine."Line No." := GenJnlLine.GetNewLineNo(GlobalRefundGenJournalBatch."Journal Template Name", GlobalRefundGenJournalBatch.Name);
                            GenJnlLine."Journal Template Name" := GlobalRefundGenJournalBatch."Journal Template Name";
                            GenJnlLine."Journal Batch Name" := GlobalRefundGenJournalBatch.Name;
                        end;
                    end;
                    // GenJnlLine."Line No." := LineNo;
                    case EDIDocument."Payer Account Type" of
                        EDIDocument."Payer Account Type"::Customer:
                            begin
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                                // GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                                GenJnlLine."Document Type" := LAXEDIPmtRemitAdviceLine."Journal Account Type";
                                CheckBillToPayToAlertSettings();
                                if UsePayerAccount then
                                    GenJnlLine.Validate("Account No.", EDIPaymentAdvice."Payer Account No.")
                                else
                                    GenJnlLine.Validate("Account No.", LAXEDIPmtRemitAdviceLine."Journal Account No.");

                                if GuiAllowed then
                                    GlobalDispWindow.Update(1, Customer.Name);
                            end;
                        EDIDocument."Payer Account Type"::Vendor:
                            begin
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                                // GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
                                GenJnlLine."Document Type" := LAXEDIPmtRemitAdviceLine."Journal Account Type";
                                CheckBillToPayToAlertSettings();
                                GenJnlLine.Validate("Account No.", Vendor."No.");
                                if GuiAllowed then
                                    GlobalDispWindow.Update(1, Vendor.Name);
                            end
                    end;
                    GenJnlLine.Validate("Posting Date", GLobalPostingDate);
                    GenJnlLine."Document Date" := EDIPaymentAdvice."Document Date";
                    GenJnlLine."Document No." := LastDocumentNo;
                    if EDIDocument."Summarize G/L Account Entry" then
                        case true of
                            TotalAdjustment > 0:
                                GenJnlLine.Validate("Debit Amount", TotalAdjustment);
                            TotalAdjustment < 0:
                                GenJnlLine.Validate("Credit Amount", TotalAdjustment);
                        end
                    else
                        if LAXEDIPmtRemitAdviceLine.Amount <> 0 then
                            GenJnlLine.Validate(Amount, LAXEDIPmtRemitAdviceLine.Amount)
                        else
                            case true of
                                LAXEDIPmtRemitAdviceLine."Credit Amount" <> 0:
                                    GenJnlLine.Validate("Credit Amount", abs(LAXEDIPmtRemitAdviceLine."Credit Amount"));
                                LAXEDIPmtRemitAdviceLine."Debit Amount" <> 0:
                                    GenJnlLine.Validate("Debit Amount", abs(LAXEDIPmtRemitAdviceLine."Debit Amount"))
                                else
                            end;
                    if GuiAllowed then begin
                        GlobalDispWindow.Update(4, LAXEDIPmtRemitAdviceLine."Journal Account Type");
                        GlobalDispWindow.Update(5, LAXEDIPmtRemitAdviceLine."Journal Account No.");
                        GlobalDispWindow.Update(6, LAXEDIPmtRemitAdviceLine.Amount);
                        GlobalDispWindow.Update(7, LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type");
                        GlobalDispWindow.Update(8, LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.");
                    end;
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    GenJnlLine.Validate("Account No.", LAXEDIPmtRemitAdviceLine."Journal Account No.");
                    GenJnlLine."Document No." := LastDocumentNo;
                    if LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No." <> '' then
                        GetCustLedgEntry(LAXEDIPmtRemitAdviceLine, EDIPaymentAdvice, EDIDocument);
                    if EDIDocument."Balance Account is G/L" <> '' then begin
                        GenJnlLine.Validate("Bal. Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type");
                        GenJnlLine.Validate("Bal. Account No.", LAXEDIPmtRemitAdviceLine."G/L Bal. Account No.");
                        GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::" ");
                        GenJnlLine."Applies-to Doc. No." := '';
                    end else begin
                        GenJnlLine.Validate("Bal. Account Type", EDIPaymentAdvice."Payer Account Type");
                        CheckBillToPayToAlertSettings();
                        GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Payer Account No.");
                        if (EDIDocument."Set Applies-to Doc. No.") and (SummarizeAdjustments = false) then begin
                            GenJnlLine.Validate("Applies-to Doc. Type", LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type");
                            // GenJnlLine.Validate("Applies-to Doc. No.", GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.").ToText());
                            GenJnlLine.Validate("Applies-to Doc. No.", GetCleanAppliesToDocNo(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No."));
                        end else begin
                            GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::" ");
                            GenJnlLine."Applies-to Doc. No." := '';
                        end;
                    end;
                    GenJnlLine."External Document No." := EDIPaymentAdvice."Payment No.";
                    GenJnlLine."LAX EDI Payment" := true;
                    if EDIPaymentAdvice."Currency Code" <> '' then
                        GenJnlLine.Validate("Currency Code", EDIPaymentAdvice."Currency Code");
                    GenJnlLine."LAX EDI Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
                    GenJnlLine.Validate("Reason Code", LAXEDIPmtRemitAdviceLine."Reason Code");
                    case true of
                        UsePayerAccount:
                            SetJournalDescription(EDIPaymentAdvice."Payer Name", EDIPaymentAdvice."Payer Account No.", LAXEDIPmtRemitAdviceLine, GenJnlLine);
                        (LAXEDIPmtRemitAdviceLine.Description <> ''):
                            SetJournalDescription(GenJnlLine.Description, GenJnlLine."Account No.", LAXEDIPmtRemitAdviceLine, GenJnlLine);
                    end;
                    GenJnlLine."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";
                    GenJnlLine.Insert(true);
                end;
            // end;
            until LAXEDIPmtRemitAdviceLine.Next = 0;

        GLAccountTmp.Reset;
        GLAccountTmp.DeleteAll;
    end;

    internal procedure GetSBCEDISettings() SBCEDIECRSettings: Record "SBCEDI ECR Settings"
    begin
        SBCEDIECRSettings.Get();
        SBCEDIECRSettings.TestField("Emerson Trade Partner");
    end;

    // #275
    procedure InsertCustomerDim(var GenJnlLine2: Record "Gen. Journal Line"; EDIPaymentAdvice2: Record "LAX EDI Payment Remit Advice"; EDIPaymentAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line")
    var
        Customer: Record Customer;
    begin
        if Customer.Get(EDIPaymentAdviceLine2."SBC Customer No.") then begin
            GenJnlLine2.ValidateShortcutDimCode(4, EDIPaymentAdviceLine2."SBC Customer No.");
            GenJnlLine2.modify(true);
        end;
    end;
    // #275

    // 456
    procedure ConvertCustRefundToGLPaymentLine(var GenJnlLine2: Record "Gen. Journal Line"; SBCustomerNo: Code[20])
    var
        CustPostingGroup: Record "Customer Posting Group";
        Cust: Record Customer;
    begin
        if not Cust.Get(SBCustomerNo) then
            exit;
        CustPostingGroup.get(Cust."Customer Posting Group");
        CustPostingGroup.Testfield("Payment Disc. Debit Acc.");
        GenJnlLine2.Validate("Account Type", GenJnlLine2."Account Type"::"G/L Account");
        GenJnlLine2.Validate("Account No.", CustPostingGroup."Payment Disc. Debit Acc.");
    end;
    // 456

    var
        GlobalRefundGenJournalBatch: Record "Gen. Journal Batch";
        Text001: Label 'Document %1 does not match this function.';
        Text002: Label 'The receive document %1 is for company %2. You are currently in company %3.';
        Text003: Label 'EDI Payment Remit Advice for Receive Document %1 has already been created.\';
        Text004: Label 'Do you wish to re-create it?';
        Text005: Label 'EDI Payment Remit Advice not created.';
        Text006: Label 'EDI Payment Remit Advice has been created for Receive Document %1';
        Text007: Label 'EDI Cross references are not setup. \Check Receive Document Unassigned Cross References tab for details.';
        Text008: Label 'Payer account not found';
        Text009: Label 'Check No. must be mapped to the Payment No. field in the EDI Payment Remit Advice table';
        Text010: Label 'Creating EDI Payment Remit Advice';
        Text011: Label 'Values must be mapped to the EDI Payment Advice table';
        Text012: Label 'Values must be mapped to the EDI Payment Advice Line table';
        Text013: Label 'EDI Payment Remit Advice must be released prior to creating the Suggested Payment.';
        Text014: Label 'Journal Template Name %1 is not supported for this process. Selection options include types of Cash Receipts and Deposits';
        Text015: Label 'Payment Remit Advice %1 has been used to create a Deposit. A new Payment Advice will be needed to create a Suggested Cash Receipt.';
        Text016: Label 'Suggested Cash Receipt Journal for Payment Remit Advice %1 has been created.\';
        Text017: Label 'Do you wish to delete and re-create it?';
        Text018: Label 'Suggested deposit not created.';
        Text019: Label 'Creating Suggested Remittance Advice Entries';
        Text020: Label 'Gen. Jnl Batch %1 must have a no. series assigned or the Payment No. field on the Payment must have a value. ';
        Text021: Label 'Payment Remit Advice %1 has been used to create a Suggested Cash Receipt. A new Payment Advice will be needed to create a Depo';
        Text022: Label 'Suggested Deposit for Payment Remit Advice %1 has been created.\';
        Text023: Label '\This can be set as an automatic process on the EDI Template';
        Text024: Label 'Payment Remit Advice %1 has been used to create a Deposit.\A new Payment Advice will be needed to create a Suggested Cash Receipt.';
        Text025: Label 'Payment Remit Advice %1 has been used to create a Suggested Cash Receipt.\A new Payment Advice will be needed to create a Deposit.';
        SelectAllQstLabel: Label 'Are you sure you want to do this for all valid remittance advices?';
        SBCDocumentNoPatternLabel: Label '^(?<%1>\d{7}[\d\w]{0,13})(?<Separator>\-)[\d\w]{2,11}\k<Separator>*.*$', Locked = true;
        SBCGroupNameLabel: Label 'SBCDocNo', Locked = true;
        DescriptionSpaceCharacter: Label ' - ', Locked = true;
        GlobalRegex: Codeunit "Regex";
        GlobalStartTimeStamp: DateTime;
        GlobalDispWindow: Dialog;
        GlobalSBCEDIJournalCreationEvents: Codeunit "SBCEDI 820 Journal Events";
        GlobalDefaultTradeRefundAccountName: Text[100];
        GlobalDefaultTradeRefundAccount: Code[20];
        GlobalDefaultCustomerGroup: Code[20];
        GlobalBankAccountNo: Code[20];
        GlobalCashReceiptJournalBatchName: Code[10];
        GlobalPaymentGLAccount: Code[20];
        GlobalUsePayerAccount: Boolean;
        GlobalAllowDifferentBilltoPayto: Boolean;
        GlobalCreateAdjustmentEntries: Boolean;
        GlobalSummarizeDefaultTradeRefund: Boolean;
        GlobalSetBalanceAccountOnPayments: Boolean;
        GLobalPostingDate: Date;
        Deductionamt: Decimal;
        RefundAmt: Decimal;
        AdjAmt: decimal;
        TotAmt: Decimal;

}
