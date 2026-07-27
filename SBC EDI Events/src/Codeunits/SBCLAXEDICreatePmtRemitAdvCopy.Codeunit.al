codeunit 50147 "SBC LAXEDICreatePmtRemitAdv"
{
    TableNo = "LAX EDI Receive Document Hdr.";

    trigger OnRun()
    begin
        FeatureNo := 5;
        EDIRegFeature.RegistrationCheck(FeatureNo);

        if Rec.Document <> 'I_PMTADV' then
            Error(Text001, Rec.Document);

        EDITemplate.Get(Rec."EDI Template Code");
        InterfaceFileType := EDITemplate."Interface File Type";

        EDIRecDocHdr.Get(Rec."Internal Doc. No.");
        if EDIRecDocHdr."Company Name" <> CompanyName then
            Error(
              Text002,
              EDIRecDocHdr."Internal Doc. No.", EDIRecDocHdr."Company Name", CompanyName);
        if Rec."Payment Remit Advice Created" then
            if GuiAllowed then begin
                if not Confirm(StrSubstNo(
                    Text003, EDIRecDocHdr."Internal Doc. No.") +
                  Text004)
                then
                    Error(Text005);
            end else
                Error(Text006, EDIRecDocHdr."Internal Doc. No.");

        EDITradePartner.Get(EDIRecDocHdr."Trade Partner No.");

        EDIDocument.Get(
          Rec."Trade Partner No.", Rec.Document, Rec."EDI Document No.",
          Rec."EDI Version", EDIDocument.Type::Import);
        EDIDocument.TestField("Journal Template Name");
        EDIDocument.TestField("Gen. Journal Batch Name");

        EvaluateStdCrossRef := false;
        EvaluateGenCrossRef := false;
        MapGenCrossRef := false;

        EDISetup.Get;
        if (EDISetup."Enable General Cross Ref.") then begin
            if (EDITradePartner."Disable General Cross Ref.") then
                EvaluateGenCrossRef := false
            else begin
                MapGenCrossRef := true;
                if (EDISetup."Eval. XRef at Doc. Import") then begin
                    if EDIRecDocHdr."Gen. XRef Processed On Import" = false then
                        EvaluateGenCrossRef := true
                end else
                    EvaluateGenCrossRef := true;
                if EvaluateGenCrossRef then begin
                    Clear(EvaluateCrossReference);
                    // #275
                    //EvaluateCrossReference.AssignNAVCrossReference(EDIRecDocHdr);
                    Clear(DispWindow);
                    DispWindow.Open('Evaluating General Cross References...');
                    EvaluateCrossReference.AssignNAVCrossReference(EDIRecDocHdr);
                    Clear(DispWindow);
                    // #275
                end;
            end;
        end else
            EvaluateGenCrossRef := false;

        if (EDISetup."Pre-evaluate Std. Cross Ref.") then begin
            if (EDITradePartner."Disable Pre-evaluation") or
               (EDIRecDocHdr."Disable Pre-evaluation")
            then
                EvaluateStdCrossRef := false
            else
                EvaluateStdCrossRef := true;
            if EvaluateStdCrossRef = false then begin
                if (EDISetup."Eval. XRef at Doc. Import") and
                   (EDITradePartner."Disable Eval XRef at DocImport" = false)
                then begin
                    if EDIRecDocHdr."Std. XRef Processed On Import" = false then
                        EvaluateStdCrossRef := true;
                end else
                    EvaluateStdCrossRef := true;
            end;
            if EvaluateStdCrossRef then begin
                Clear(EvaluateCrossReference);
                // #275
                //EvaluateCrossReference.EvaluateCustomerCrossReference(EDIRecDocHdr);
                Clear(DispWindow);
                DispWindow.Open('Evaluating Cust. Cross References...');
                EvaluateCrossReference.EvaluateCustomerCrossReference(EDIRecDocHdr);
                Clear(DispWindow);
                // #275
            end;
        end else
            EvaluateStdCrossRef := false;

        CrossReferenceError := false;
        if EvaluateGenCrossRef then begin
            EDIRecDocHdr.CalcFields("General Cross Reference Error");
            if EDIRecDocHdr."General Cross Reference Error" then
                CrossReferenceError := true;
        end;
        OnAfterEvaluateCrossReference(MapGenCrossRef, CrossReferenceError, EvaluateGenCrossRef, EDISetup, EDITradePartner, EDIRecDocHdr);
        if CrossReferenceError then
            Error(Text007);

        GetPaymentAccountType(EDIRecDocHdr, EDIDocument);

        CreateEDIPaymentAdvice;
        CreateEDIPaymentAdviceLine;

        EDIRecDocHdr."Payment Remit Advice Created" := true;
        EDIRecDocHdr."Pmt. Remit Advice Created Date" := Today;
        EDIRecDocHdr."Pmt. Remit Advice Created Time" := EDIManagement.GetTypeHelper();
        EDIRecDocHdr."Pmt. Remit Advice Created At" := EDIManagement.SetCurrentDateTime();
        EDIRecDocHdr."Data Error" := false;
        EDIRecDocHdr."Document Processed" := true;
        EDIRecDocHdr.Modify;

        Commit;

        CreateEDIAlert.UpdateAlertStatus(EDIRecDocHdr);

        if EDITemplate."Create Suggested Journal Lines" then begin
            if EDITemplate."Cancel Jnl. Creation on Error" then begin
                SetDocFindError(EDIPaymentAdviceLine, EDIPaymentAdvice);
                EDIPaymentAdvice.CalcFields("Apply Entry Error");
                if EDIPaymentAdvice."Apply Entry Error" then
                    exit
                else
                    CreateNAVSuggestedPayment(EDIRecDocHdr, EDIPaymentAdvice);
            end else
                CreateNAVSuggestedPayment(EDIRecDocHdr, EDIPaymentAdvice);
        end;
    end;

    var
        EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.";
        EDIRecDocField: Record "LAX EDI Receive Document Field";
        EDICustCrossRef: Record "LAX EDI Cust. Cross Reference";
        EDIVendCrossRef: Record "LAX EDI Vend. Cross Reference";
        EDIDocument: Record "LAX EDI Document";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        BankAcccount: Record "Bank Account";
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice";
        EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        //xxxDepositHeader: Record "Bank Deposit Header";
        CompanyInformation: Record "Company Information";
        EDITemplate: Record "LAX EDI Template";
        EDITradePartner: Record "LAX EDI Trade Partner";
        EDISendDocHdr: Record "LAX EDI Send Document Hdr.";
        EDISetup: Record "LAX EDI Setup";
        PaytoVendor: Record Vendor;
        VendLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustEntryEdit: Codeunit "Cust. Entry-Edit";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        VendEntryEdit: Codeunit "Vend. Entry-Edit";
        EDIFormat: Codeunit "LAX EDI Format";
        EDISend: Codeunit "LAX EDI WS Send";
        CreateEDIAlert: Codeunit "LAX EDI Create Alert";
        EvaluateCrossReference: Codeunit "LAX EDI Evaluate Cross Ref.";
        EDIRegFeature: Codeunit "LAX EDI Reg. Feature Enabled";
        EDIManagement: Codeunit "LAX EDI Management";
        FeatureNo: Integer;
        DispWindow: Dialog;
        LastGLAccountNo: Code[20];
        LastGLBalAcctNo: Code[20];
        LastExternalDocNo: Code[50];
        LastAmount: Decimal;
        LastDocAmount: Decimal;
        LastPmtAmount: Decimal;
        LastDebitAmount: Decimal;
        LastCreditAmount: Decimal;
        LastAmounttoApply: Decimal;
        LastApplyToDocNo: Code[20];
        DateVariable: Date;
        PaymentDate: Date;
        LastNAVDocPostingDate: Date;
        DecimalVariable: Decimal;
        AppliedAmount: Decimal;
        TotalAppliedAmount: Decimal;
        InvoiceAmount: Decimal;
        LastDiscAmount: Decimal;
        i: Integer;
        IntegerVariable: Integer;
        EntryNo: Integer;
        Version: Integer;
        LineNo: Integer;
        NewSegment: Boolean;
        BooleanVariable: Boolean;
        BypassSegment: Boolean;
        FirstSegment: Boolean;
        TradePartnerFound: Boolean;
        TradePartner: Code[20];
        NavisionDocumentNo: Code[10];
        LastNAVDocExternalDocNo: Code[50];
        LastReasonCode: Code[10];
        EvaluateGenCrossRef: Boolean;
        EvaluateStdCrossRef: Boolean;
        CrossReferenceError: Boolean;
        PostDocument: Boolean;
        LastApplyToDocType: Enum "LAX EDI Jnl Apply-to Doc. Type";
        GenJnlBatchName: Code[10];
        LastReferenceNo: Code[50];
        AdviceNo: Code[10];
        LastDocumentNo: Code[50];
        LastEDIRefID: Code[30];
        MapGenCrossRef: Boolean;
        Adjustment: Boolean;
        LastSegmentGroup: Integer;
        InterfaceFileType: Enum "LAX EDI Interface File Type";
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
        LastDescription: Text[50];
        LastSBCCustNo: Code[50];

    procedure GetPaymentAccountType(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIDocument: Record "LAX EDI Document")
    var
        EDITradePartner: Record "LAX EDI Trade Partner";
    begin
        EDITradePartner.Get(EDIRecDocHdr."Trade Partner No.");

        EDIRecDocField.Reset;
        EDIRecDocField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"LAX EDI Payment Remit Advice");
        EDIRecDocField.SetRange("Field No.", EDIPaymentAdvice.FieldNo("Payer Account No."));
        if EDIRecDocField.Find('-') then
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
                                EDICustCrossRef.Find('-');
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
                                EDIVendCrossRef.Find('-');
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

    procedure CreateEDIPaymentAdvice(): Code[20]
    var
        GenJnlBatch2: Record "Gen. Journal Batch";
        GenJnlLine2: Record "Gen. Journal Line";
        NoSeriesLine: Record "No. Series Line";
        OpenBatchFound: Boolean;
        BatchSequence: Code[10];
        NoSeries: Code[10];
    begin
        EDISetup.Get;

        EDIRecDocField.Reset;
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"LAX EDI Payment Remit Advice");
        EDIRecDocField.SetRange("Field No.", EDIPaymentAdvice.FieldNo("Payment No."));
        if EDIRecDocField.Find('+') then begin
            if EDIRecDocField."Field Text Value" = '' then
                Error(Text009)
        end else
            Error(Text009);

        if GuiAllowed then begin
            DispWindow.Open(
              Text010 + '\' +
              PadStr('Payer Name', 25, ' ') + '#1###########################\' +
              PadStr('Batch Name', 25, ' ') + '#2###########################\' +
              PadStr('Total Payment Amount', 25, ' ') + '#3###########################\' +
              PadStr('Account Type', 25, ' ') + '#4###########################\' +
              PadStr('Account No.', 25, ' ') + '#5###########################\' +
              PadStr('Amount', 25, ' ') + '#6###########################\' +
              PadStr('Applies-To Doc. Type', 25, ' ') + '#7###########################\' +
              PadStr('Applies-To Doc. No.', 25, ' ') + '#8###########################');
            case EDIDocument."Payer Account Type" of
                EDIDocument."Payer Account Type"::Customer:
                    DispWindow.Update(1, Customer.Name);
                EDIDocument."Payer Account Type"::Vendor:
                    DispWindow.Update(1, Vendor.Name);
            end;
        end;

        EDIPaymentAdvice.Reset;
        EDIPaymentAdvice."Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
        EDIPaymentAdvice.Validate("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        EDIPaymentAdvice.Insert(true);

        EDIRecDocField.Reset;
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"LAX EDI Payment Remit Advice");
        if EDIRecDocField.Find('-') then begin
            repeat
                case EDIRecDocField."Field No." of
                    EDIPaymentAdvice.FieldNo("Document Date"):
                        EDIPaymentAdvice."Document Date" := EDIRecDocField."Field Date Value";
                    EDIPaymentAdvice.FieldNo("Payment Amount"):
                        EDIPaymentAdvice."Payment Amount" := EDIRecDocField."Field Dec. Value";
                    EDIPaymentAdvice.FieldNo("Document No."):
                        EDIPaymentAdvice."Document No." := EDIRecDocField."Field Text Value";
                    EDIPaymentAdvice.FieldNo("Payment No."):
                        EDIPaymentAdvice."Payment No." := EDIRecDocField."Field Text Value";
                    EDIPaymentAdvice.FieldNo("Bank Account No."):
                        begin
                            if EDIRecDocField."Cross Ref. Value-1" = '' then
                                EDIPaymentAdvice.Validate("Bank Account No.", CopyStr(EDIRecDocField."Field Text Value", 1, 20))
                            else
                                EDIPaymentAdvice.Validate("Bank Account No.", EDIRecDocField."Cross Ref. Value-1");
                        end;
                    EDIPaymentAdvice.FieldNo("Currency Code"):
                        begin
                            if EDIRecDocField."General EDI Cross Reference" then
                                EDIPaymentAdvice.Validate("Currency Code", EDIRecDocField."Cross Ref. Value-1")
                            else
                                EDIPaymentAdvice.Validate("Currency Code", CopyStr(EDIRecDocField."Field Text Value", 1, 3));
                        end;
                    EDIPaymentAdvice.FieldNo("Remittance Type"):
                        begin
                            if EDIRecDocField.Substitution then
                                case EDIRecDocField."Field Text Value" of
                                    'Payment', 'PAYMENT':
                                        EDIPaymentAdvice.Validate(
                                          "Remittance Type", EDIPaymentAdvice."Remittance Type"::Payment);
                                    'Information', 'INFORMATION':
                                        EDIPaymentAdvice.Validate(
                                          "Remittance Type", EDIPaymentAdvice."Remittance Type"::Information);
                                end;
                        end;
                    else
                        OnAfterMapPaymentAdviceFields(EDIPaymentAdvice, EDIRecDocField);
                end;
            until EDIRecDocField.Next = 0;
        end else
            Error(Text011);

        if GuiAllowed then
            DispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        case EDIDocument."Payer Account Type" of
            EDIDocument."Payer Account Type"::Customer:
                begin
                    EDIPaymentAdvice.Validate("Payer Account Type", EDIPaymentAdvice."Payer Account Type"::Customer);
                    EDIPaymentAdvice.Validate("Payer Account No.", Customer."No.");
                end;
            EDIDocument."Payer Account Type"::Vendor:
                begin
                    EDIPaymentAdvice.Validate("Payer Account Type", EDIPaymentAdvice."Payer Account Type"::Vendor);
                    EDIPaymentAdvice.Validate("Payer Account No.", Vendor."No.");
                end;
        end;
        if EDIPaymentAdvice."Document Date" = 0D then
            EDIPaymentAdvice."Document Date" := WorkDate;
        if EDITemplate."Release Pmt. Advice On Receipt" then
            EDIPaymentAdvice.Validate(Released, true);
        EDIPaymentAdvice.Modify;
    end;

    procedure CreateEDIPaymentAdviceLine()
    var
        GenJnlBatch2: Record "Gen. Journal Batch";
        GenJnlLine2: Record "Gen. Journal Line";
        NoSeriesLine: Record "No. Series Line";
        OpenBatchFound: Boolean;
        BatchSequence: Code[10];
        NoSeries: Code[10];
    begin
        LastDocAmount := 0;
        LastPmtAmount := 0;
        LastCreditAmount := 0;
        LastDebitAmount := 0;
        LastSegmentGroup := 0;
        LastDiscAmount := 0;
        LastExternalDocNo := '';
        LastGLAccountNo := '';
        LastGLBalAcctNo := '';
        LastReasonCode := '';
        LastApplyToDocNo := '';
        LastEDIRefID := '';
        LastNAVDocExternalDocNo := '';
        LastNAVDocPostingDate := 0D;
        Clear(LastApplyToDocType);
        Adjustment := false;
        LastDescription := '';
        // #275
        LastSBCCustNo := '';
        // #275

        LastGLBalAcctNo := EDIDocument."Balance Account is G/L";

        EDIRecDocField.Reset;
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"LAX EDI Pmt. Remit Advice Line");
        if EDIRecDocField.Find('-') then begin
            repeat
                case EDIRecDocField."Field No." of
                    EDIPaymentAdviceLine.FieldNo(Amount):
                        LastPmtAmount := EDIRecDocField."Field Dec. Value";
                    EDIPaymentAdviceLine.FieldNo(EDIPaymentAdviceLine."Document Amount"):
                        LastDocAmount := EDIRecDocField."Field Dec. Value";
                    EDIPaymentAdviceLine.FieldNo("Credit Amount"):
                        begin
                            LastCreditAmount := EDIRecDocField."Field Dec. Value";
                            LastPmtAmount := LastCreditAmount;
                            LastDebitAmount := 0;
                        end;
                    EDIPaymentAdviceLine.FieldNo("Debit Amount"):
                        begin
                            LastDebitAmount := EDIRecDocField."Field Dec. Value";
                            LastPmtAmount := LastDebitAmount;
                            LastCreditAmount := 0;
                        end;
                    EDIPaymentAdviceLine.FieldNo("Discount Amount"):
                        LastDiscAmount := EDIRecDocField."Field Dec. Value";
                    EDIPaymentAdviceLine.FieldNo("Journal Applies-to Doc. No."):
                        LastApplyToDocNo := EDIRecDocField."Field Text Value";
                    EDIPaymentAdviceLine.FieldNo("Journal Account No."):
                        begin
                            if EDIRecDocField."Line Type" <> EDIRecDocField."Line Type"::" " then
                                case EDIRecDocField."Line Type" of
                                    EDIRecDocField."Line Type"::"G/L Account":
                                        begin
                                            LastGLAccountNo := EDIRecDocField."Cross Ref. Value-1";
                                            if EDIRecDocField."Sub Cross Ref. Value-1" <> '' then
                                                LastGLBalAcctNo := EDIRecDocField."Sub Cross Ref. Value-1";
                                        end;
                                    else
                                        LastGLAccountNo := EDIRecDocField."Field Text Value";
                                end;
                        end;
                    EDIPaymentAdviceLine.FieldNo("Journal Applies-to Doc. Type"):
                        begin
                            if EDIRecDocField."Cross Ref. Value-1" = '' then
                                Evaluate(LastApplyToDocType, EDIRecDocField."Field Text Value")
                            else
                                Evaluate(LastApplyToDocType, EDIRecDocField."Cross Ref. Value-1");
                        end;
                    EDIPaymentAdviceLine.FieldNo("Document External Doc. No."):
                        LastNAVDocExternalDocNo := EDIRecDocField."Field Text Value";
                    EDIPaymentAdviceLine.FieldNo("Document Posting Date"):
                        LastNAVDocPostingDate := EDIRecDocField."Field Date Value";
                    EDIPaymentAdviceLine.FieldNo("Reason Code"):
                        begin
                            if EDIRecDocField."General EDI Cross Reference" then
                                LastReasonCode := EDIRecDocField."Cross Ref. Value-1"
                            else
                                LastReasonCode := EDIRecDocField."Field Text Value";
                        end;
                    EDIPaymentAdviceLine.FieldNo(Adjustment):
                        begin
                            case EDIRecDocField."Field Text Value" of
                                'TRUE':
                                    Adjustment := true;
                                'FALSE':
                                    Adjustment := false;
                            end;
                        end;
                    EDIPaymentAdviceLine.FieldNo("EDI Reference ID"):
                        LastEDIRefID := EDIRecDocField."Field Text Value";
                    EDIPaymentAdviceLine.FieldNo(Description):
                        LastDescription := EDIRecDocField."Field Text Value";
                    // #275
                    EDIPaymentAdviceLine.FieldNo("SBC Customer No."):
                        LastSBCCustNo := EDIRecDocField."Field Text Value";
                    // #275
                    else
                        OnAfterMapPaymentAdviceLineFields(EDIPaymentAdviceLine, EDIRecDocField);
                end;
                //
                // Add Custom EDI Payment Advice Line fields here
                //
                // End of custom EDI Payment Advice Line fields

                OnBeforeTrigger(EDIRecDocField);
                if EDIRecDocField."EDI Trigger" then begin
                    LastSegmentGroup := EDIRecDocField."Segment Group";
                    CreLine;
                    LastGLBalAcctNo := EDIDocument."Balance Account is G/L";
                end;
            until EDIRecDocField.Next = 0;
        end else
            Error(Text012);
        OnBeforeExitCreatePaymentAdviceLine(EDIRecDocHdr, EDIDocument);

        if GuiAllowed then
            DispWindow.Close;
    end;

    procedure CreLine()
    var
        EDIPaymentAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
        GLAccount: Record "G/L Account";
        LineNo: Integer;
        // #275
        Cust: Record Customer;
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    // #275
    begin
        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        if EDIPaymentAdviceLine.Find('+') then
            LineNo := EDIPaymentAdviceLine."Line No." + 10000
        else
            LineNo := 10000;

        EDIPaymentAdviceLine."Payment Advice No." := EDIPaymentAdvice."No.";
        EDIPaymentAdviceLine."Line No." := LineNo;
        EDIPaymentAdviceLine.Validate("Document Type", EDIPaymentAdviceLine."Document Type"::Payment);
        if LastGLAccountNo <> '' then begin
            if GuiAllowed then begin
                DispWindow.Update(4, 'G/L Account');
                DispWindow.Update(5, LastGLAccountNo);
            end;
            EDIPaymentAdviceLine."Journal Account No." := LastGLAccountNo;
            EDIPaymentAdviceLine.Validate(
              "Journal Account Type", EDIPaymentAdviceLine."Journal Account Type"::"G/L Account");
            if GLAccount.Get(LastGLAccountNo) then begin
                EDIPaymentAdviceLine.Description := GLAccount.Name;
                if LastGLBalAcctNo <> '' then
                    EDIPaymentAdviceLine.Validate("G/L Bal. Account No.", LastGLBalAcctNo);
            end;
        end else begin
            case EDIDocument."Payer Account Type" of
                EDIDocument."Payer Account Type"::Customer:
                    begin
                        if GuiAllowed then begin
                            DispWindow.Update(4, 'Customer');
                            DispWindow.Update(5, Customer."No.");
                        end;
                        EDIPaymentAdviceLine.Validate(
                          "Journal Account Type", EDIPaymentAdviceLine."Journal Account Type"::Customer);
                        EDIPaymentAdviceLine.Validate("Journal Account No.", Customer."No.");
                        EDIPaymentAdviceLine.Description := Customer.Name;
                    end;
                EDIDocument."Payer Account Type"::Vendor:
                    begin
                        if GuiAllowed then begin
                            DispWindow.Update(4, 'Vendor');
                            DispWindow.Update(5, Vendor."No.");
                        end;
                        EDIPaymentAdviceLine.Validate(
                          "Journal Account Type", EDIPaymentAdviceLine."Journal Account Type"::Vendor);
                        EDIPaymentAdviceLine.Validate("Journal Account No.", Vendor."No.");
                        EDIPaymentAdviceLine.Description := Vendor.Name;
                    end;
            end;
            EDIPaymentAdviceLine.Validate("G/L Bal. Account No.", '');
        end;

        if GuiAllowed then begin
            DispWindow.Update(6, LastPmtAmount);
            DispWindow.Update(7, LastApplyToDocType);
            DispWindow.Update(8, LastApplyToDocNo);
        end;

        EDIPaymentAdviceLine.Validate("Journal Applies-to Doc. Type", LastApplyToDocType);
        EDIPaymentAdviceLine."Journal Applies-to Doc. No." := LastApplyToDocNo;
        EDIPaymentAdviceLine.Amount := LastPmtAmount;
        EDIPaymentAdviceLine."Credit Amount" := LastCreditAmount;
        EDIPaymentAdviceLine."Debit Amount" := LastDebitAmount;
        EDIPaymentAdviceLine."Discount Amount" := LastDiscAmount;
        EDIPaymentAdviceLine."Document External Doc. No." := LastNAVDocExternalDocNo;
        EDIPaymentAdviceLine."Document Posting Date" := LastNAVDocPostingDate;
        EDIPaymentAdviceLine.Validate("Reason Code", LastReasonCode);
        EDIPaymentAdviceLine.Validate(Adjustment, Adjustment);
        EDIPaymentAdviceLine."Segment Group" := LastSegmentGroup;
        EDIPaymentAdviceLine."EDI Reference ID" := LastEDIRefID;
        EDIPaymentAdviceLine."Document Amount" := LastDocAmount;
        if LastDescription <> '' then
            EDIPaymentAdviceLine.Description := LastDescription;

        // #275
        if LastSBCCustNo <> '' then begin
            Clear(Cust);
            if EDIRecDocField."Field Text Value" <> '' then begin
                LAXEDICustCrossReference.SetRange(
                  "Trade Partner No.", EDIRecDocField."Trade Partner No.");
                LAXEDICustCrossReference.SetRange(
                  "EDI Sell To Code", CopyStr(LastSBCCustNo, 1, 20));
                if LAXEDICustCrossReference.FindFirst() then begin
                    Cust.Get(LAXEDICustCrossReference."Sell To Code");
                    EDIPaymentAdviceLine."SBC Customer No." := Cust."No.";
                    EDIPaymentAdviceLine.Description := Cust.Name;
                end else begin
                    EDIPaymentAdviceLine."SBC Customer No." := LastSBCCustNo;
                    EDIPaymentAdviceLine.Description := 'Cross Reference not found';
                end;
            end;
        end;
        // #275

        OnBeforeInsertPaymentAdviceLine(EDIPaymentAdviceLine, EDIPaymentAdvice);
        EDIPaymentAdviceLine.Insert;
        if (EDIPaymentAdviceLine.Adjustment) and
           (EDIPaymentAdviceLine."Journal Applies-to Doc. No." = '')
        then begin
            EDIPaymentAdviceLine2.Reset;
            EDIPaymentAdviceLine2.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
            EDIPaymentAdviceLine2.SetFilter("Line No.", '<%1', EDIPaymentAdviceLine."Line No.");
            EDIPaymentAdviceLine2.SetRange(Adjustment, false);
            if EDIPaymentAdviceLine2.Find('+') then begin
                EDIPaymentAdviceLine."Journal Applies-to Doc. Type" :=
                EDIPaymentAdviceLine2."Journal Applies-to Doc. Type";
                EDIPaymentAdviceLine."Journal Applies-to Doc. No." :=
                EDIPaymentAdviceLine2."Journal Applies-to Doc. No.";
                EDIPaymentAdviceLine.Modify;
            end;
        end;

        OnAfterInsertPaymentAdviceLine(EDIPaymentAdviceLine, EDIPaymentAdvice);

        LastDocAmount := 0;
        LastPmtAmount := 0;
        LastCreditAmount := 0;
        LastDebitAmount := 0;
        LastSegmentGroup := 0;
        LastDiscAmount := 0;
        LastExternalDocNo := '';
        LastGLAccountNo := '';
        LastGLBalAcctNo := '';
        LastReasonCode := '';
        LastApplyToDocNo := '';
        LastEDIRefID := '';
        LastNAVDocExternalDocNo := '';
        LastNAVDocPostingDate := 0D;
        Clear(LastApplyToDocType);
        Adjustment := false;
        LastDescription := '';
        // #275
        LastSBCCustNo := '';
        // #275
    end;

    procedure CreateNAVSuggestedPayment(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        EDIRecDocHdr2: Record "LAX EDI Receive Document Hdr.";
        EDITemplate: Record "LAX EDI Template";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        if EDIPaymentAdvice."Remittance Type" <> EDIPaymentAdvice."Remittance Type"::Payment then
            exit;

        EDIRecDocHdr2.Get(EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocHdr2."Data Error" := true;
        EDIRecDocHdr2."Error Message Text" := '';
        EDIRecDocHdr2.Modify;

        if EDIPaymentAdvice.Released = false then
            Error(Text013 + Text023);
        EDIDocument.Get(
          EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
          EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);
        EDITemplate.Get(EDIRecDocHdr."EDI Template Code");
        EDIDocument.TestField("Journal Template Name");
        EDIDocument.TestField("Gen. Journal Batch Name");

        GetPaymentAccountType(EDIRecDocHdr, EDIDocument);

        GenJournalTemplate.Get(EDIDocument."Journal Template Name");
        case GenJournalTemplate.Type of
            GenJournalTemplate.Type::"Cash Receipts":
                CreateBankAccountJnlLine(EDIRecDocHdr, EDIPaymentAdvice);
            /*
            GenJournalTemplate.Type::"Bank Deposits":
                CreateDepositHeader(EDIRecDocHdr, EDIPaymentAdvice);
            */
            else
                Error(
                  Text014,
                  EDIDocument."Journal Template Name");
        end;
        if GuiAllowed then
            DispWindow.Close;

        EDIRecDocHdr2."Data Error" := false;
        EDIRecDocHdr2.Modify;
    end;

    procedure CreateBankAccountJnlLine(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        EDIDocument: Record "LAX EDI Document";
        EDIPaymentAdvice2: Record "LAX EDI Payment Remit Advice";
        GenJnlBatch2: Record "Gen. Journal Batch";
        GenJnlLine2: Record "Gen. Journal Line";
        NoSeriesLine: Record "No. Series Line";
        EDIPaymentNo: Integer;
        OpenBatchFound: Boolean;
        BatchSequence: Code[10];
        NoSeries: Code[10];
    begin
        if EDIPaymentAdvice."Suggested Deposit Created" then
            Error(Text024, EDIPaymentAdvice."No.");

        EDIDocument.Get(
          EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
          EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

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
            DispWindow.Open(
              Text019 + '\' +
              PadStr('Payer Name', 25, ' ') + '#1###########################\' +
              PadStr('Batch Name', 25, ' ') + '#2###########################\' +
              PadStr('Total Payment Amount', 25, ' ') + '#3###########################\' +
              PadStr('Account Type', 25, ' ') + '#4###########################\' +
              PadStr('Account No.', 25, ' ') + '#5###########################\' +
              PadStr('Amount', 25, ' ') + '#6###########################\' +
              PadStr('Applies-To Doc. Type', 25, ' ') + '#7###########################\' +
              PadStr('Applies-To Doc. No.', 25, ' ') + '#8###########################');
            DispWindow.Update(1, EDIPaymentAdvice."Payer Name");
            DispWindow.Update(2, GenJnlBatchName);
            DispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        end;

        LastDocumentNo := '';
        GenJnlBatchName := '';
        GenJnlBatchName := EDIDocument."Gen. Journal Batch Name";

        GenJnlTemplate.Get(EDIDocument."Journal Template Name");
        GenJnlBatch.Get(GenJnlTemplate.Name, GenJnlBatchName);

        GenJnlLine.Reset;
        GenJnlLine.SetCurrentKey("LAX EDI Internal Doc. No.");
        GenJnlLine.SetRange("LAX EDI Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        if GenJnlLine.Find('-') then
            GenJnlLine.DeleteAll(true);

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
        if GenJnlLine.Find('-') then begin
            OpenBatchFound := false;
            /*
            if GenJnlTemplate.Type = GenJnlTemplate.Type::"Bank Deposits" then
                BatchSequence := '0'
            else
            */
            BatchSequence := '00';
            repeat
                BatchSequence := IncStr(BatchSequence);
                GenJnlBatchName := EDIDocument."Gen. Journal Batch Name";
                GenJnlBatchName := GenJnlBatchName + BatchSequence;
                GenJnlLine2.Reset;
                GenJnlLine2.SetRange("Journal Template Name", GenJnlTemplate.Name);
                GenJnlLine2.SetRange("Journal Batch Name", GenJnlBatchName);
                if not GenJnlLine2.Find('-') then begin
                    GenJnlBatch2.Reset;
                    GenJnlBatch2.SetRange(
                      "Journal Template Name", GenJnlTemplate.Name);
                    GenJnlBatch2.SetRange(Name, GenJnlBatchName);
                    if GenJnlBatch2.Find('-') then
                        OpenBatchFound := true
                    else begin
                        GenJnlBatch2.Init;
                        GenJnlBatch2.Copy(GenJnlBatch);
                        GenJnlBatch2.Name := GenJnlBatchName;
                        GenJnlBatch2.Insert(true);
                        OpenBatchFound := true;
                    end;
                end;
            until OpenBatchFound = true;
        end;

        EDIPaymentAdvice2.Get(EDIPaymentAdvice."No.");
        EDIPaymentAdvice2.Validate("Journal Template Name", GenJnlTemplate.Name);
        EDIPaymentAdvice2.Validate("Journal Batch Name", GenJnlBatchName);
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
            DispWindow.Update(2, GenJnlBatchName);
            DispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        end;

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
        if GenJnlLine.Find('+') then
            LineNo := GenJnlLine."Line No." + 10000
        else
            LineNo := 10000;
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
        GenJnlLine."Journal Batch Name" := GenJnlBatchName;
        GenJnlLine."Line No." := LineNo;
        EDIRecDocField.Reset;
        EDIRecDocField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"Gen. Journal Line");
        EDIRecDocField.SetRange("Field No.", GenJnlLine.FieldNo("Account Type"));
        if EDIRecDocField.Find('-') then
            case UpperCase(EDIRecDocField."Field Text Value") of
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
        EDIRecDocField.Reset;
        EDIRecDocField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetRange("Table No.", DATABASE::"Gen. Journal Line");
        EDIRecDocField.SetRange("Field No.", GenJnlLine.FieldNo("Account No."));
        if EDIRecDocField.Find('-') then
            GenJnlLine.Validate("Account No.", EDIRecDocField."Field Text Value")
        else
            GenJnlLine.Validate("Account No.", EDIPaymentAdvice."Bank Account No.");
        if EDIPaymentAdvice."Currency Code" <> '' then
            GenJnlLine.Validate("Currency Code", EDIPaymentAdvice."Currency Code");
        GenJnlLine.Validate("Bal. Account Type", EDIPaymentAdvice."Payer Account Type");
        GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Payer Account No.");
        GenJnlLine.Validate(Amount, EDIPaymentAdvice."Payment Amount");
        GenJnlLine.Validate("Posting Date", WorkDate);
        GenJnlLine."Document Date" := EDIPaymentAdvice."Document Date";
        GenJnlLine."Document No." := LastDocumentNo;
        GenJnlLine."External Document No." := EDIPaymentAdvice."Payment No.";
        GenJnlLine."LAX EDI Payment" := true;
        GenJnlLine."LAX EDI Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
        GenJnlLine."Applies-to ID" := EDIPaymentAdvice."Payment No.";
        GenJnlLine."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";
        GenJnlLine.Insert(true);

        ApplyEntries(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName);

        EDIPaymentAdvice2.Get(EDIPaymentAdvice."No.");
        EDIPaymentAdvice2."Suggested Cash Receipt Journal" := true;
        EDIPaymentAdvice2.Modify;

        CreateEDIAlert.UpdateAlertStatus(EDIRecDocHdr);
    end;

    procedure CreateDepositHeader(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        EDIDocument: Record "LAX EDI Document";
        EDIRecDocField: Record "LAX EDI Receive Document Field";
        EDIPaymentAdvice2: Record "LAX EDI Payment Remit Advice";
        GenJnlBatch2: Record "Gen. Journal Batch";
        GenJnlLine2: Record "Gen. Journal Line";
        NoSeriesLine: Record "No. Series Line";
        EDIPaymentNo: Integer;
        OpenBatchFound: Boolean;
        BatchSequence: Code[10];
        NoSeries: Code[10];
    begin
        /*xxx
        if EDIPaymentAdvice."Suggested Cash Receipt Journal" then
            Error(Text025, EDIPaymentAdvice."No.");

        EDIDocument.Get(
          EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
          EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        if EDIPaymentAdvice."Suggested Deposit Created" then
            if GuiAllowed then begin
                if not Confirm(
                  StrSubstNo(
                    Text022, EDIPaymentAdvice."No.") +
                  Text017)
                then
                    Error(Text018);
            end else
                Error(Text022, EDIPaymentAdvice."No.");

        if GuiAllowed then begin
            DispWindow.Open(
              Text019 + '\' +
              PadStr('Payer Name', 25, ' ') + '#1###########################\' +
              PadStr('Deposit', 25, ' ') + '#2###########################\' +
              PadStr('Total Payment Amount', 25, ' ') + '#3###########################\' +
              PadStr('Account Type', 25, ' ') + '#4###########################\' +
              PadStr('Account No.', 25, ' ') + '#5###########################\' +
              PadStr('Amount', 25, ' ') + '#6###########################\' +
              PadStr('Applies-To Doc. Type', 25, ' ') + '#7###########################\' +
              PadStr('Applies-To Doc. No.', 25, ' ') + '#8###########################');
            DispWindow.Update(1, EDIPaymentAdvice."Payer Name");
            DispWindow.Update(2, GenJnlBatchName);
            DispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        end;

        LastDocumentNo := '';
        GenJnlBatchName := '';
        GenJnlBatchName := EDIDocument."Gen. Journal Batch Name";

        GenJnlTemplate.Get(EDIDocument."Journal Template Name");
        GenJnlBatch.Get(GenJnlTemplate.Name, GenJnlBatchName);

        DepositHeader.Reset;
        DepositHeader."LAX EDI Deposit" := true;
        DepositHeader.SetRange("LAX EDI Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        if DepositHeader.Find('-') then
            DepositHeader.DeleteAll(true);

        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
        if GenJnlLine.Find('-') then begin
            OpenBatchFound := false;
            BatchSequence := '00';
            repeat
                BatchSequence := IncStr(BatchSequence);
                GenJnlBatchName := EDIDocument."Gen. Journal Batch Name";
                GenJnlBatchName := GenJnlBatchName + BatchSequence;
                GenJnlLine2.Reset;
                GenJnlLine2.SetRange("Journal Template Name", GenJnlTemplate.Name);
                GenJnlLine2.SetRange("Journal Batch Name", GenJnlBatchName);
                if not GenJnlLine2.Find('-') then begin
                    GenJnlBatch2.Reset;
                    GenJnlBatch2.SetRange(
                      "Journal Template Name", GenJnlTemplate.Name);
                    GenJnlBatch2.SetRange(Name, GenJnlBatchName);
                    if GenJnlBatch2.Find('-') then
                        OpenBatchFound := true
                    else begin
                        GenJnlBatch2.Init;
                        GenJnlBatch2.Copy(GenJnlBatch);
                        GenJnlBatch2.Name := GenJnlBatchName;
                        GenJnlBatch2."Journal Template Name" := GenJnlTemplate.Name;
                        GenJnlBatch2.Insert(true);
                        OpenBatchFound := true;
                    end;
                end;
            until OpenBatchFound = true;
        end;

        if GuiAllowed then begin
            DispWindow.Update(2, GenJnlBatchName);
            DispWindow.Update(3, EDIPaymentAdvice."Payment Amount");
        end;
        EDIPaymentAdvice2.Get(EDIPaymentAdvice."No.");
        EDIPaymentAdvice2.Validate("Journal Template Name", GenJnlTemplate.Name);
        EDIPaymentAdvice2.Validate("Journal Batch Name", GenJnlBatchName);
        EDIPaymentAdvice2.Modify;

        DepositHeader.Locktable(true);

        Clear(DepositHeader);
        DepositHeader.Reset;
        DepositHeader.SetFilter("Journal Template Name", GenJnlTemplate.Name);
        DepositHeader.SetFilter("Journal Batch Name", GenJnlBatchName);
        DepositHeader."LAX EDI Deposit" := true;
        DepositHeader.Insert;
        if GuiAllowed then
            DispWindow.Update(2, DepositHeader."No.");
        DepositHeader.Validate("Document Date", EDIPaymentAdvice."Document Date");
        DepositHeader.Validate("Currency Code", EDIPaymentAdvice."Currency Code");
        DepositHeader."Total Deposit Amount" := EDIPaymentAdvice."Payment Amount";
        if GuiAllowed then
            DispWindow.Update(3, DepositHeader."Total Deposit Amount");
        DepositHeader.Validate("Bank Account No.", EDIPaymentAdvice."Bank Account No.");
        DepositHeader."LAX EDI Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
        DepositHeader."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";
        DepositHeader."LAX EDI Deposit Created Date" := Today;
        DepositHeader."LAX EDI Deposit Created Time" := EDIManagement.GetTypeHelper();
        DepositHeader."LAX EDI Deposit Created At" := EDIManagement.SetCurrentDateTime();
        DepositHeader.Modify;

        CreateApplicationLine(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName);
        */
    end;

    procedure CreateApplicationLine(EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; GenJnlBatchName: Code[10])
    var
        EDIPaymentAdvice2: Record "LAX EDI Payment Remit Advice";
        EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        LineNo: Integer;
    begin
        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
        if GenJnlLine.Find('+') then
            LineNo := GenJnlLine."Line No." + 10000
        else
            LineNo := 10000;
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
        GenJnlLine."Journal Batch Name" := GenJnlBatchName;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine.Validate("Account Type", EDIPaymentAdvice."Payer Account Type");
        GenJnlLine.Validate("Account No.", EDIPaymentAdvice."Payer Account No.");
        case EDIPaymentAdvice."Payer Account Type" of
            EDIPaymentAdvice."Payer Account Type"::Customer:
                begin
                    if GuiAllowed then
                        DispWindow.Update(1, EDIPaymentAdvice."Payer Name");
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                end;
            EDIPaymentAdvice."Payer Account Type"::Vendor:
                begin
                    if GuiAllowed then
                        DispWindow.Update(1, EDIPaymentAdvice."Payer Name");
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
                end;
        end;
        GenJnlLine.Validate("Posting Date", WorkDate);
        GenJnlLine."Document Date" := EDIPaymentAdvice."Document Date";
        GenJnlLine."Document No." := EDIPaymentAdvice."Payment No.";
        GenJnlLine.Validate("Credit Amount", EDIPaymentAdvice."Payment Amount");
        if GuiAllowed then begin
            DispWindow.Update(4, GenJnlLine."Account Type");
            DispWindow.Update(5, GenJnlLine."Account No.");
            DispWindow.Update(6, EDIPaymentAdvice."Payment Amount");
        end;
        //xxxGenJnlLine."External Document No." := DepositHeader."No.";
        GenJnlLine."LAX EDI Payment" := true;
        if EDIPaymentAdvice."Currency Code" <> '' then
            GenJnlLine.Validate("Currency Code", EDIPaymentAdvice."Currency Code");
        GenJnlLine."LAX EDI Internal Doc. No." := EDIRecDocHdr."Internal Doc. No.";
        GenJnlLine."Applies-to ID" := EDIPaymentAdvice."Payment No.";
        GenJnlLine."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";
        GenJnlLine.Insert(true);

        ApplyEntries(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName);

        EDIPaymentAdvice2.Get(EDIPaymentAdvice."No.");
        EDIPaymentAdvice2."Suggested Deposit Created" := true;
        //xxxEDIPaymentAdvice2."Deposit No." := DepositHeader."No.";
        EDIPaymentAdvice2.Modify;

        CreateEDIAlert.UpdateAlertStatus(EDIRecDocHdr);
    end;

    procedure ApplyEntries(EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; GenJnlBatchName: Code[10])
    var
        EDIDocument: Record "LAX EDI Document";
        EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        EDIPaymentAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
        GLAccountTmp: Record "G/L Account" temporary;
        GenJournalTemplate: Record "Gen. Journal Template";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        LineNo: Integer;
        TotalAdjustment: Decimal;
        CreateJnlLine: Boolean;
        SummarizeAdjustments: Boolean;
        IsHandled: Boolean;
    begin
        EDIDocument.Get(
          EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
          EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        EDIPaymentAdviceLine.SetRange(Adjustment, false);
        EDIPaymentAdviceLine.Find('-');
        repeat
            if GuiAllowed then begin
                DispWindow.Update(4, EDIPaymentAdviceLine."Journal Account Type");
                DispWindow.Update(5, EDIPaymentAdviceLine."Journal Account No.");
                DispWindow.Update(6, EDIPaymentAdviceLine.Amount);
                DispWindow.Update(7, EDIPaymentAdviceLine."Journal Applies-to Doc. Type");
                DispWindow.Update(8, EDIPaymentAdviceLine."Journal Applies-to Doc. No.");
            end;
            case EDIPaymentAdvice."Payer Account Type" of
                EDIPaymentAdvice."Payer Account Type"::Customer:
                    GetCustLedgEntry(EDIPaymentAdviceLine, EDIPaymentAdvice);
                EDIPaymentAdvice."Payer Account Type"::Vendor:
                    SetVendLedgerEntry(EDIPaymentAdviceLine, EDIPaymentAdvice);
            end;
        until EDIPaymentAdviceLine.Next = 0;
        IsHandled := false;
        OnBeforeCheckPmtTolerance(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName, GenJnlLine, IsHandled);
        if not IsHandled then
            PaymentToleranceMgt.PmtTolGenJnl(GenJnlLine);

        GenJournalTemplate.Get(EDIDocument."Journal Template Name");
        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        EDIPaymentAdviceLine.SetRange(Adjustment, true);
        if EDIPaymentAdviceLine.Find('-') then
            case GenJournalTemplate.Type of
                /*xxx
                    GenJournalTemplate.Type::"Bank Deposits":
                        begin
                            EDIPaymentAdviceLine.Reset;
                            EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
                            EDIPaymentAdviceLine.SetRange(Adjustment, true);
                            EDIPaymentAdviceLine.SetFilter("Journal Applies-to Doc. No.", '<>%1', '');
                            if EDIPaymentAdviceLine.Find('-') then
                                repeat
                                    GetCustLedgEntry(EDIPaymentAdviceLine, EDIPaymentAdvice);
                                until EDIPaymentAdviceLine.Next = 0;
                        end;
                        */
                GenJournalTemplate.Type::"Cash Receipts":
                    ApplyAdjustmentEntries(EDIPaymentAdvice, EDIRecDocHdr, GenJnlBatchName);
            end;
    end;

    procedure ApplyAdjustmentEntries(EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; GenJnlBatchName: Code[10])
    var
        EDIDocument: Record "LAX EDI Document";
        EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        EDIPaymentAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
        GLAccountTmp: Record "G/L Account" temporary;
        LineNo: Integer;
        TotalAdjustment: Decimal;
        CreateJnlLine: Boolean;
        SummarizeAdjustments: Boolean;
    begin
        EDIDocument.Get(
          EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
          EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);

        GLAccountTmp.Reset;
        GLAccountTmp.DeleteAll;

        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
        EDIPaymentAdviceLine.SetRange(Adjustment, true);
        EDIPaymentAdviceLine.SetRange(
          "Journal Account Type", EDIPaymentAdviceLine."Journal Account Type"::"G/L Account");
        if EDIPaymentAdviceLine.Find('-') then
            repeat
                EDIPaymentAdviceLine.TestField("Journal Account No.");
                TotalAdjustment := 0;
                CreateJnlLine := false;
                SummarizeAdjustments := false;
                if EDIDocument."Summarize G/L Account Entry" then begin
                    GLAccountTmp.Reset;
                    GLAccountTmp.SetRange("No.", EDIPaymentAdviceLine."Journal Account No.");
                    if GLAccountTmp.Find('-') then
                        SummarizeAdjustments := false
                    else begin
                        GLAccountTmp."No." := EDIPaymentAdviceLine."Journal Account No.";
                        GLAccountTmp.Insert;
                        SummarizeAdjustments := true;
                    end;
                    if SummarizeAdjustments then begin
                        EDIPaymentAdviceLine2.Reset;
                        EDIPaymentAdviceLine2.SetRange("Payment Advice No.", EDIPaymentAdvice."No.");
                        EDIPaymentAdviceLine2.SetRange(Adjustment, true);
                        EDIPaymentAdviceLine2.SetRange("Journal Account Type", EDIPaymentAdviceLine."Journal Account Type");
                        EDIPaymentAdviceLine2.SetRange("Journal Account No.", EDIPaymentAdviceLine."Journal Account No.");
                        EDIPaymentAdviceLine2.Find('-');
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
                    GenJnlLine.SetRange("Journal Template Name", GenJnlTemplate.Name);
                    GenJnlLine.SetRange("Journal Batch Name", GenJnlBatchName);
                    if GenJnlLine.Find('+') then
                        LineNo := GenJnlLine."Line No." + 10000
                    else
                        LineNo := 10000;
                    GenJnlLine.Init;
                    GenJnlLine."Journal Template Name" := GenJnlTemplate.Name;
                    GenJnlLine."Journal Batch Name" := GenJnlBatchName;
                    GenJnlLine."Line No." := LineNo;
                    case EDIDocument."Payer Account Type" of
                        EDIDocument."Payer Account Type"::Customer:
                            begin
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
                                GenJnlLine.Validate("Account No.", Customer."No.");
                                if GuiAllowed then
                                    DispWindow.Update(1, Customer.Name);
                            end;
                        EDIDocument."Payer Account Type"::Vendor:
                            begin
                                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
                                GenJnlLine.Validate("Account No.", Vendor."No.");
                                if GuiAllowed then
                                    DispWindow.Update(1, Vendor.Name);
                            end
                    end;
                    GenJnlLine.Validate("Posting Date", WorkDate);
                    GenJnlLine."Document Date" := EDIPaymentAdvice."Document Date";
                    GenJnlLine."Document No." := LastDocumentNo;
                    if EDIDocument."Summarize G/L Account Entry" then
                        case true of
                            TotalAdjustment > 0:
                                GenJnlLine.Validate("Debit Amount", TotalAdjustment);
                            TotalAdjustment < 0:
                                GenJnlLine.Validate("Debit Amount", TotalAdjustment);
                        end
                    else
                        case true of
                            EDIPaymentAdviceLine."Credit Amount" <> 0:
                                GenJnlLine.Validate("Credit Amount", EDIPaymentAdviceLine."Credit Amount");
                            EDIPaymentAdviceLine."Debit Amount" <> 0:
                                GenJnlLine.Validate("Debit Amount", EDIPaymentAdviceLine."Debit Amount")
                            else
                                if EDIPaymentAdviceLine.Amount <> 0 then
                                    GenJnlLine.Validate(Amount, EDIPaymentAdviceLine.Amount);
                        end;
                    if GuiAllowed then begin
                        DispWindow.Update(4, EDIPaymentAdviceLine."Journal Account Type");
                        DispWindow.Update(5, EDIPaymentAdviceLine."Journal Account No.");
                        DispWindow.Update(6, EDIPaymentAdviceLine.Amount);
                        DispWindow.Update(7, EDIPaymentAdviceLine."Journal Applies-to Doc. Type");
                        DispWindow.Update(8, EDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                    end;
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    GenJnlLine.Validate("Account No.", EDIPaymentAdviceLine."Journal Account No.");
                    GenJnlLine."Document No." := LastDocumentNo;
                    if EDIPaymentAdviceLine."Journal Applies-to Doc. No." <> '' then
                        GetCustLedgEntry(EDIPaymentAdviceLine, EDIPaymentAdvice);
                    if EDIDocument."Balance Account is G/L" <> '' then begin
                        GenJnlLine.Validate("Bal. Account Type", EDIPaymentAdviceLine."Journal Account Type");
                        GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdviceLine."G/L Bal. Account No.");
                        GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::" ");
                        GenJnlLine."Applies-to Doc. No." := '';
                    end else begin
                        GenJnlLine.Validate("Bal. Account Type", EDIPaymentAdvice."Payer Account Type");
                        GenJnlLine.Validate("Bal. Account No.", EDIPaymentAdvice."Payer Account No.");
                        if (EDIDocument."Set Applies-to Doc. No.") and (SummarizeAdjustments = false) then begin
                            GenJnlLine.Validate("Applies-to Doc. Type", EDIPaymentAdviceLine."Journal Applies-to Doc. Type");
                            GenJnlLine.Validate("Applies-to Doc. No.", EDIPaymentAdviceLine."Journal Applies-to Doc. No.");
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
                    GenJnlLine.Validate("Reason Code", EDIPaymentAdviceLine."Reason Code");
                    if EDIPaymentAdviceLine.Description <> '' then
                        GenJnlLine.Description := EDIPaymentAdviceLine.Description;
                    GenJnlLine."LAX EDI Trade Partner" := EDIPaymentAdvice."Trade Partner No.";
                    GenJnlLine.Insert(true);
                end;
            until EDIPaymentAdviceLine.Next = 0;

        GLAccountTmp.Reset;
        GLAccountTmp.DeleteAll;
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

    procedure SetDocFindError(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        CustLedgerDocNo: Code[20];
        DocFound: Boolean;
    begin
        if GuiAllowed then begin
            DispWindow.Open(
              Text010 + '\' +
              PadStr('Payer Name', 25, ' ') + '#1###########################\' +
              PadStr('Batch Name', 25, ' ') + '#2###########################\' +
              PadStr('Total Payment Amount', 25, ' ') + '#3###########################\' +
              PadStr('Account Type', 25, ' ') + '#4###########################\' +
              PadStr('Account No.', 25, ' ') + '#5###########################\' +
              PadStr('Amount', 25, ' ') + '#6###########################\' +
              PadStr('Applies-To Doc. Type', 25, ' ') + '#7###########################\' +
              PadStr('Applies-To Doc. No.', 25, ' ') + '#8###########################');
            case EDIDocument."Payer Account Type" of
                EDIDocument."Payer Account Type"::Customer:
                    DispWindow.Update(1, Customer.Name);
                EDIDocument."Payer Account Type"::Vendor:
                    DispWindow.Update(1, Vendor.Name);
            end;
        end;

        EDIPaymentAdviceLine.Reset;
        EDIPaymentAdviceLine.SetRange("Payment Advice No.", CurrEDIPaymentAdviceLine."Payment Advice No.");
        EDIPaymentAdviceLine.Find('-');
        repeat
            CurrEDIPaymentAdviceLine.Get(
              EDIPaymentAdviceLine."Payment Advice No.", EDIPaymentAdviceLine."Line No.");
            DocFound := false;
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := false;
            CurrEDIPaymentAdviceLine.Modify;

            case CurrEDIPaymentAdvice."Payer Account Type" of
                CurrEDIPaymentAdvice."Payer Account Type"::Customer:
                    begin
                        CustLedgerEntry.Locktable(true);
                        CustLedgerEntry.Reset;
                        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", Open);
                        CustLedgerEntry.SetRange("Customer No.", CurrEDIPaymentAdvice."Payer Account No.");
                        CustLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
                        CustLedgerEntry.SetRange(Open, true);
                        if not CustLedgerEntry.Find('-') then begin
                            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
                            CurrEDIPaymentAdviceLine.Modify;
                        end else begin
                            case EDIDocument."Apply-to  Doc. No. Format Rule" of
                                EDIDocument."Apply-to  Doc. No. Format Rule"::" ":
                                    begin
                                        CheckCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice);
                                        if GuiAllowed then
                                            DispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
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
                                              CustLedgerEntry, CurrEDIPaymentAdviceLine, DocFound, CustLedgerDocNo)
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
                                            DispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                                        CheckCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice);
                                    end else begin
                                        if GuiAllowed then
                                            DispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                                        CheckCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice);
                                    end;
                            end;
                        end;
                    end;
                CurrEDIPaymentAdvice."Payer Account Type"::Vendor:
                    begin
                        GetVendLedgEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice);
                    end;
            end;
        until EDIPaymentAdviceLine.Next = 0;
        if GuiAllowed then
            DispWindow.Close;
    end;

    procedure CheckCustLedgerEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    begin
        CustLedgerEntry.Reset;
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", Open);
        if CurrEDIPaymentAdviceLine."Document External Doc. No." <> '' then
            CustLedgerEntry.SetRange(
              "External Document No.", CurrEDIPaymentAdviceLine."Document External Doc. No.");
        CustLedgerEntry.SetRange("Customer No.", CurrEDIPaymentAdvice."Payer Account No.");
        CustLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        if CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No." <> '' then
            CustLedgerEntry.SetRange("Document No.", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
        if CurrEDIPaymentAdviceLine."Document Posting Date" <> 0D then
            CustLedgerEntry.SetRange("Posting Date", CurrEDIPaymentAdviceLine."Document Posting Date");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.Find('-') then begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end;
    end;

    procedure GetCustLedgEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        CustLedgerDocNo: Code[20];
        DocFound: Boolean;
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
        if not CustLedgerEntry.Find('-') then begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end else begin
            case EDIDocument."Apply-to  Doc. No. Format Rule" of
                EDIDocument."Apply-to  Doc. No. Format Rule"::" ":
                    begin
                        if GuiAllowed then
                            DispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                        SetCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice);
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
                              CustLedgerEntry, CurrEDIPaymentAdviceLine, DocFound, CustLedgerDocNo)
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
                            DispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                        SetCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice)
                    end else begin
                        if GuiAllowed then
                            DispWindow.Update(8, CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
                        SetCustLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice);
                    end;
            end;
        end;
    end;

    procedure FormatDocumentNo(CustLedgerEntry: Record "Cust. Ledger Entry"; CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var DocFound: Boolean; var LedgerDocNo: Code[20]): Boolean
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

    procedure SetCustLedgerEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        CustEntryEdit: Codeunit "Cust. Entry-Edit";
        ApplicationAmount: Decimal;
        IsHandled: Boolean;
    begin
        CustLedgerEntry.Reset;
        CustLedgerEntry.SetCurrentKey("Document Type", "Customer No.", Open);
        if CurrEDIPaymentAdviceLine."Document External Doc. No." <> '' then
            CustLedgerEntry.SetRange(
              "External Document No.", CurrEDIPaymentAdviceLine."Document External Doc. No.");
        CustLedgerEntry.SetRange("Customer No.", CurrEDIPaymentAdvice."Payer Account No.");
        CustLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        if CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No." <> '' then
            CustLedgerEntry.SetRange("Document No.", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
        if CurrEDIPaymentAdviceLine."Document Posting Date" <> 0D then
            CustLedgerEntry.SetRange("Posting Date", CurrEDIPaymentAdviceLine."Document Posting Date");
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.Find('-') then begin
            if CurrEDIPaymentAdviceLine.Adjustment = false then begin
                CustLedgerEntry.Validate("Applies-to ID", CurrEDIPaymentAdvice."Payment No.");
                CustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                if ABS(CurrEDIPaymentAdviceLine.Amount) > ABS(CustLedgerEntry."Remaining Amount") then
                    ApplicationAmount := CustLedgerEntry."Remaining Amount"
                else
                    ApplicationAmount := CurrEDIPaymentAdviceLine.Amount;
                OnBeforeValidateCustLedgerAppInAmount(CustLedgerEntry, CurrEDIPaymentAdviceLine, ApplicationAmount);
                CustLedgerEntry.Validate("Amount to Apply", ApplicationAmount);
                if CurrEDIPaymentAdviceLine."Discount Amount" <> 0 then
                    CustLedgerEntry.Validate(
                      "Remaining Pmt. Disc. Possible", CurrEDIPaymentAdviceLine."Discount Amount");
                CustLedgerEntry."LAX EDI Payment" := true;
                CustLedgerEntry."LAX EDI Internal Doc. No." := CurrEDIPaymentAdvice."Internal Doc. No.";
                CustLedgerEntry."LAX EDI Internal Doc. No." := CurrEDIPaymentAdvice."Internal Doc. No.";
                IsHandled := false;
                OnBeforeEditCustLedgerEntry(CustLedgerEntry, CurrEDIPaymentAdvice, CurrEDIPaymentAdviceLine, IsHandled);
                if not IsHandled then
                    CustEntryEdit.Run(CustLedgerEntry);
            end;
        end else begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end;
    end;

    procedure GetVendLedgEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        VendLedgerDocNo: Code[20];
    begin
        VendLedgerEntry.Locktable(true);
        VendLedgerEntry.Reset;
        VendLedgerEntry.SetCurrentKey("Document Type", "Vendor No.", "Posting Date", "Currency Code");
        VendLedgerEntry.SetRange("Buy-from Vendor No.", CurrEDIPaymentAdvice."Payer Account No.");
        VendLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        VendLedgerEntry.SetRange("Document No.", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
        VendLedgerEntry.SetRange(Open, true);
        if VendLedgerEntry.Find('-') then
            SetVendLedgerEntry(CurrEDIPaymentAdviceLine, CurrEDIPaymentAdvice)
        else begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end;
    end;

    procedure SetVendLedgerEntry(var CurrEDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; CurrEDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        ApplicationAmount: Decimal;
        IsHandled: Boolean;
    begin
        CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := false;

        VendLedgerEntry.Reset;
        VendLedgerEntry.SetCurrentKey("Document Type", "Vendor No.", "Posting Date", "Currency Code");
        VendLedgerEntry.SetRange("Buy-from Vendor No.", CurrEDIPaymentAdvice."Payer Account No.");
        VendLedgerEntry.SetRange("Document Type", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. Type");
        VendLedgerEntry.SetRange("Document No.", CurrEDIPaymentAdviceLine."Journal Applies-to Doc. No.");
        if CurrEDIPaymentAdviceLine."Document Posting Date" <> 0D then
            VendLedgerEntry.SetRange("Posting Date", CurrEDIPaymentAdviceLine."Document Posting Date");
        VendLedgerEntry.SetRange(Open, true);
        if VendLedgerEntry.Find('-') then begin
            VendLedgerEntry.Validate("Applies-to ID", CurrEDIPaymentAdvice."Payment No.");
            VendLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            ApplicationAmount := CurrEDIPaymentAdviceLine.Amount;
            if ABS(CurrEDIPaymentAdviceLine.Amount) > ABS(VendLedgerEntry."Remaining Amount") then
                ApplicationAmount := VendLedgerEntry."Remaining Amount"
            else
                ApplicationAmount := CurrEDIPaymentAdviceLine.Amount;
            OnBeforeValidateVendorLedgerAppInAmount(VendLedgerEntry, CurrEDIPaymentAdviceLine, ApplicationAmount);
            VendLedgerEntry.Validate("Amount to Apply", ApplicationAmount);
            VendLedgerEntry."LAX EDI Payment" := true;
            VendLedgerEntry."LAX EDI Internal Doc. No." := CurrEDIPaymentAdvice."Internal Doc. No.";
            IsHandled := false;
            OnBeforeEditVendLedgerEntry(VendLedgerEntry, CurrEDIPaymentAdvice, CurrEDIPaymentAdviceLine, IsHandled);
            if not IsHandled then
                VendEntryEdit.Run(VendLedgerEntry);
        end else begin
            CurrEDIPaymentAdviceLine."EDI Doc. Find Error" := true;
            CurrEDIPaymentAdviceLine.Modify;
        end;
    end;

    procedure ReleasePaymentAdvice(var CurrentPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    begin
        CurrentPaymentAdvice.TestField(Released, false);
        CurrentPaymentAdvice.TestField("Trade Partner No.");
        CurrentPaymentAdvice.TestField("Document Date");
        CurrentPaymentAdvice.Released := true;
        CurrentPaymentAdvice.Modify;
    end;

    procedure ReopenPaymentAdvice(var CurrentPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        PaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        WasPosted: Boolean;
    begin
        WasPosted := false;
        CurrentPaymentAdvice.TestField(Released, true);
        CurrentPaymentAdvice.Released := false;
        if CurrentPaymentAdvice.Posted then begin
            WasPosted := true;
            CurrentPaymentAdvice.Posted := false;
        end;
        CurrentPaymentAdvice.Modify;
        if WasPosted then begin
            PaymentAdviceLine.Reset;
            PaymentAdviceLine.SetRange("Payment Advice No.", CurrentPaymentAdvice."No.");
            PaymentAdviceLine.ModifyAll(Closed, false, true);
        end;
    end;

    procedure PostPaymentAdvice(var CurrentPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    var
        PaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        PostedPaymentAdvice: Record "LAX EDI Posted PmtRemit Advice";
        PostedPaymentAdviceLine: Record "LAX EDI Posted PmtRemitAdvLine";
    begin
        CurrentPaymentAdvice.TestField(Released, true);

        PostedPaymentAdvice.TransferFields(CurrentPaymentAdvice);
        PostedPaymentAdvice."Posting Date" := WorkDate;
        PostedPaymentAdvice.Insert;

        PaymentAdviceLine.Reset;
        PaymentAdviceLine.SetRange("Payment Advice No.", CurrentPaymentAdvice."No.");
        PaymentAdviceLine.Find('-');
        repeat
            PostedPaymentAdviceLine.TransferFields(PaymentAdviceLine);
            PostedPaymentAdviceLine.Insert(true);
            PaymentAdviceLine.Delete;
        until PaymentAdviceLine.Next = 0;
        CurrentPaymentAdvice.Delete;
    end;

    [BusinessEvent(false)]
    procedure OnBeforeInsertPaymentAdviceLine(var EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeTrigger(EDIRecDocField: Record "LAX EDI Receive Document Field")
    begin
    end;

    [BusinessEvent(false)]
    procedure OnAfterMapPaymentAdviceFields(var EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIRecDocField: Record "LAX EDI Receive Document Field");
    begin
    end;

    [BusinessEvent(false)]
    procedure OnAfterMapPaymentAdviceLineFields(var EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; EDIRecDocField: Record "LAX EDI Receive Document Field");
    begin
    end;

    // #275
    [BusinessEvent(false)]
    procedure OnAfterMapPaymentAdviceLineFields2(var EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; EDIRecDocField: Record "LAX EDI Receive Document Field");
    begin
    end;
    // #275

    [BusinessEvent(false)]
    procedure OnAfterInsertPaymentAdviceLine(var EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice")
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeValidateVendorLedgerAppInAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var ApplicationAmount: Decimal)
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeValidateCustLedgerAppInAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var ApplicationAmount: Decimal)
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeCheckPmtTolerance(EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; GenJnlBatchName: Code[10]; var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeEditVendLedgerEntry(var VendLedgerEntry: Record "Vendor Ledger Entry"; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var IsHandled: Boolean)
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeEditCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; EDIPaymentAdvice: Record "LAX EDI Payment Remit Advice"; EDIPaymentAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var IsHandled: Boolean)
    begin
    end;

    [BusinessEvent(false)]
    procedure OnAfterEvaluateCrossReference(var MapGenCrossRef: Boolean; var CrossReferenceError: Boolean; EvaluateGenCrossRef: Boolean; EDISetup: Record "LAX EDI Setup"; EDITradePartner: Record "LAX EDI Trade Partner"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    begin
    end;

    [BusinessEvent(false)]
    procedure OnBeforeExitCreatePaymentAdviceLine(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIDocument: Record "LAX EDI Document")
    begin
    end;
}
