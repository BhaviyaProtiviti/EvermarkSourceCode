/// <summary>
/// Codeunit SBCEDI EDI 820 Helper (ID 50081).
/// </summary>
codeunit 50081 "SBCEDI 820 Helper"
{
    var
        GlobalLAXEDIDocument: Record "LAX EDI Document";
        GlobalLAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
        GlobalSBCEDIECRUpdateHelper: Codeunit "SBCEDI Event Helper";
        GlobalIgnoreAdjustmentFlag: Boolean;
        GlobalPaymentAdviceSegment: Code[15];
        GlobalBankAccountNo: Code[50];
        GlobalDocumentList: Dictionary of [Integer, Integer];

    internal procedure CreateDocument(StartLineNo: Integer; StopLine: Integer)
    var
        LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
    begin
        CreatePaymentAdviceHeader(StartLineNo, StopLine, LAXEDIPaymentRemitAdvice);
        if LAXEDIPaymentRemitAdvice."Internal Doc. No." = '' then
            exit;
        CreateEDIPaymentAdviceLine(StartLineNo, StopLine, LAXEDIPaymentRemitAdvice);
    end;

    internal procedure CreateDocuments(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var EDIDocument: Record "LAX EDI Document")
    var
        DocumentCount: Integer;
        Index: Integer;
        StartLineNo: Integer;
        StopLineNo: Integer;
        SBCEDIECRSettings: Record "SBCEDI ECR Settings";
    begin
        SBCEDIECRSettings := GlobalSBCEDIECRUpdateHelper.GetSBCEDISettings();
        if SBCEDIECRSettings."Payment Advice Segment" = '' then
            exit;
        SetGlobals(EDIRecDocHdr, EDIDocument, SBCEDIECRSettings);
        DocumentCount := GlobalDocumentList.Count();
        if DocumentCount = 0 then
            exit;
        Index := 1;
        while Index <= DocumentCount do begin
            StartLineNo := 0;
            StopLineNo := 0;
            GlobalDocumentList.Keys().Get(Index, StartLineNo);
            if DocumentCount > Index then
                GlobalDocumentList.Keys().Get(Index + 1, StopLineNo);
            CreateDocument(StartLineNo, StopLineNo);
            Index += 1;
        end;
    end;

    internal procedure CreateEDIPaymentAdviceLine(StartLineNo: Integer; StopLine: Integer; var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        LAXEDIPmtRemitAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
        Cust: Record Customer;
    begin
        if not SetFilteredReceiveDocumentLine(StartLineNo, StopLine, LAXEDIReceiveDocumentField) then
            exit;

        LAXEDIReceiveDocumentField.SetRange("Table No.", Database::"LAX EDI Pmt. Remit Advice Line");
        if LAXEDIReceiveDocumentField.IsEmpty() then
            exit;
        // ExistingLineFound(LAXEDIPaymentRemitAdvice, LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);

        LAXEDIPmtRemitAdviceLine."Payment Advice No." := LAXEDIPaymentRemitAdvice."No.";
        LAXEDIPmtRemitAdviceLine."Line No." := GetPaymentAdviceLineNo(LAXEDIPaymentRemitAdvice);
        LAXEDIPmtRemitAdviceLine.Validate("Document Type", LAXEDIPmtRemitAdviceLine."Document Type"::Payment);
        LAXEDIReceiveDocumentField.FindSet();
        repeat
            SetEDIPaymentAdviceLineValues(LAXEDIReceiveDocumentField, LAXEDIPmtRemitAdviceLine);
        until LAXEDIReceiveDocumentField.Next() = 0;
        SetAccountValuesOnLine(LAXEDIPaymentRemitAdvice, LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);
        SetPaymentValuesOnLine(LAXEDIPmtRemitAdviceLine);
        // #275
        // Don't insert a deduction/refund line to a customer in this CU
        // just keep the original, correct one created by Lanham to a g/l account
        // Only insert a payment line for a customer if a line was not already
        // created for a g/l account with the sma applies to doc. no. and amount
        //LAXEDIPmtRemitAdviceLine.Insert();
        if ((LAXEDIPmtRemitAdviceLine."Document Type" = LAXEDIPmtRemitAdviceLine."Document Type"::Payment) and (LAXEDIPmtRemitAdviceLine."Journal Account Type" = LAXEDIPmtRemitAdviceLine."Journal Account Type"::Customer))
        then begin
            if LAXEDIPmtRemitAdviceLine.Amount <> 0 then begin
                LAXEDIPmtRemitAdviceLine2.SetRange("Payment Advice No.", LAXEDIPaymentRemitAdvice."No.");
                LAXEDIPmtRemitAdviceLine2.SetFilter("Line No.", '<>%1', LAXEDIPmtRemitAdviceLine."Line No.");
                LAXEDIPmtRemitAdviceLine2.SetRange("Journal Account Type", LAXEDIPmtRemitAdviceLine2."Journal Account Type"::"G/L Account");
                LAXEDIPmtRemitAdviceLine2.SetRange("Amount", LAXEDIPmtRemitAdviceLine.Amount);
                LAXEDIPmtRemitAdviceLine2.SetRange("Journal Applies-to Doc. Type", LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type");
                LAXEDIPmtRemitAdviceLine2.SetRange("Journal Applies-to Doc. No.", LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No.");
                if not LAXEDIPmtRemitAdviceLine2.FindFirst() then begin
                    LAXEDIPmtRemitAdviceLine.Insert();
                end;
            end;
        end;
        // #275

        UpdatePaymentValuesOnHeader(LAXEDIPaymentRemitAdvice, LAXEDIPmtRemitAdviceLine);
        SetAdjustmentValuesOnAdviceLine(LAXEDIPaymentRemitAdvice, LAXEDIPmtRemitAdviceLine);
    end;

    internal procedure CreatePmtAdviceLine(var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr."; LAXEDIDocument: Record "LAX EDI Document")
    begin
    end;

    [TryFunction()]
    internal procedure TryGetCustomerCrossReference(LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var Customer: Record Customer)
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    begin
        LAXEDICustCrossReference.SetRange(
          "Trade Partner No.", LAXEDIReceiveDocumentField."Trade Partner No.");
        LAXEDICustCrossReference.SetRange(
          "EDI Sell To Code", CopyStr(LAXEDIReceiveDocumentField."Field Text Value", 1, 20));
        LAXEDICustCrossReference.FindFirst();
        Customer.Get(LAXEDICustCrossReference."Sell To Code");
    end;

    [TryFunction()]
    internal procedure TryGetVendorCrossReference(LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var Vendor: Record Vendor)
    var
        LAXEDIVendCrossReference: Record "LAX EDI Vend. Cross Reference";
    begin
        LAXEDIVendCrossReference.SetRange(
          "Trade Partner No.", LAXEDIReceiveDocumentField."Trade Partner No.");
        LAXEDIVendCrossReference.SetRange(
          "EDI Buy-from Code", CopyStr(LAXEDIReceiveDocumentField."Field Text Value", 1, 20));
        LAXEDIVendCrossReference.FindFirst();
        Vendor.Get(LAXEDIVendCrossReference."Buy-from Code");
    end;

    local procedure CreateGlobalDocumentLineList(var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", LAXEDIReceiveDocumentHdr."Internal Doc. No.");
        LAXEDIReceiveDocumentField.SetFilter(Segment, '%1', GlobalPaymentAdviceSegment);
        LAXEDIReceiveDocumentField.SetRange("New Segment", true);
        if LAXEDIReceiveDocumentField.IsEmpty() then
            exit;

        LAXEDIReceiveDocumentField.FindSet();
        repeat
            if GlobalDocumentList.Add(LAXEDIReceiveDocumentField."Line No.", LAXEDIReceiveDocumentField."Line No.") then;
        until LAXEDIReceiveDocumentField.Next() = 0;
    end;

    local procedure CreatePaymentAdviceHeader(var StartLineNo: Integer; var StopLine: Integer; var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        if not SetFilteredReceiveDocumentLine(StartLineNo, StopLine, LAXEDIReceiveDocumentField) then
            exit;
        LAXEDIReceiveDocumentField.SetRange("Table No.", Database::"LAX EDI Payment Remit Advice");
        if LAXEDIReceiveDocumentField.IsEmpty() then
            exit;
        LAXEDIPaymentRemitAdvice.SetFilter("Internal Doc. No.", '%1', GlobalLAXEDIReceiveDocumentHdr."Internal Doc. No.");
        LAXEDIPaymentRemitAdvice.SetFilter("Trade Partner No.", '%1', GlobalLAXEDIReceiveDocumentHdr."Trade Partner No.");
        if LAXEDIPaymentRemitAdvice.FindFirst() then
            exit;
        LAXEDIPaymentRemitAdvice."Internal Doc. No." := GlobalLAXEDIReceiveDocumentHdr."Internal Doc. No.";
        LAXEDIPaymentRemitAdvice."Trade Partner No." := GlobalLAXEDIReceiveDocumentHdr."Trade Partner No.";
        LAXEDIPaymentRemitAdvice.Insert(true);

        LAXEDIReceiveDocumentField.FindSet();
        repeat
            case LAXEDIReceiveDocumentField."Field No." of
                LAXEDIPaymentRemitAdvice.FieldNo("Document Date"):
                    LAXEDIPaymentRemitAdvice."Document Date" := LAXEDIReceiveDocumentField."Field Date Value";
                LAXEDIPaymentRemitAdvice.FieldNo("Payment Amount"):
                    LAXEDIPaymentRemitAdvice."Payment Amount" := LAXEDIReceiveDocumentField."Field Dec. Value";
                LAXEDIPaymentRemitAdvice.FieldNo("Document No."):
                    LAXEDIPaymentRemitAdvice."Document No." := LAXEDIReceiveDocumentField."Field Text Value";
                LAXEDIPaymentRemitAdvice.FieldNo("Payment No."):
                    LAXEDIPaymentRemitAdvice."Payment No." := LAXEDIReceiveDocumentField."Field Text Value";
                LAXEDIPaymentRemitAdvice.FieldNo("Bank Account No."):
                    begin
                        if LAXEDIReceiveDocumentField."Cross Ref. Value-1" = '' then
                            LAXEDIPaymentRemitAdvice.Validate("Bank Account No.", CopyStr(LAXEDIReceiveDocumentField."Field Text Value", 1, 20))
                        else
                            LAXEDIPaymentRemitAdvice.Validate("Bank Account No.", LAXEDIReceiveDocumentField."Cross Ref. Value-1");
                    end;
                LAXEDIPaymentRemitAdvice.FieldNo("Currency Code"):
                    begin
                        if LAXEDIReceiveDocumentField."General EDI Cross Reference" then
                            LAXEDIPaymentRemitAdvice.Validate("Currency Code", LAXEDIReceiveDocumentField."Cross Ref. Value-1")
                        else
                            LAXEDIPaymentRemitAdvice.Validate("Currency Code", CopyStr(LAXEDIReceiveDocumentField."Field Text Value", 1, 3));
                    end;
                LAXEDIPaymentRemitAdvice.FieldNo("Remittance Type"):
                    begin
                        if LAXEDIReceiveDocumentField.Substitution then
                            case LAXEDIReceiveDocumentField."Field Text Value" of
                                'Payment', 'PAYMENT':
                                    LAXEDIPaymentRemitAdvice.Validate(
                                      "Remittance Type", LAXEDIPaymentRemitAdvice."Remittance Type"::Payment);
                                'Information', 'INFORMATION':
                                    LAXEDIPaymentRemitAdvice.Validate(
                                      "Remittance Type", LAXEDIPaymentRemitAdvice."Remittance Type"::Information);
                                else
                                    LAXEDIPaymentRemitAdvice.Validate(
                                 "Remittance Type", LAXEDIPaymentRemitAdvice."Remittance Type"::Payment);
                            end;
                    end;
                LAXEDIPaymentRemitAdvice.FieldNo("Payer Account No."):
                    case GlobalLAXEDIDocument."Payer Account Type" of
                        GlobalLAXEDIDocument."Payer Account Type"::Customer:
                            SetCustomerValuesOnHeader(LAXEDIPaymentRemitAdvice, LAXEDIReceiveDocumentField);
                        GlobalLAXEDIDocument."Payer Account Type"::Vendor:
                            SetVendorValuesOnHeader(LAXEDIPaymentRemitAdvice, LAXEDIReceiveDocumentField);
                    end;
                else
                    OnAfterMapPaymentAdviceFields(LAXEDIPaymentRemitAdvice, LAXEDIReceiveDocumentField);
            end;
        until LAXEDIReceiveDocumentField.Next() = 0;
        if LAXEDIPaymentRemitAdvice."Bank Account No." = '' then
            LAXEDIPaymentRemitAdvice."Bank Account No." := GlobalBankAccountNo;
        LAXEDIPaymentRemitAdvice.Modify();

        SetDocumentDate(LAXEDIReceiveDocumentField, LAXEDIPaymentRemitAdvice);
        SetReleased(LAXEDIPaymentRemitAdvice);
    end;

    local procedure GetPaymentAdviceLineNo(LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice") LineNo: Integer
    var
        LAXEDIPmtRemitAdviceLine2: Record "LAX EDI Pmt. Remit Advice Line";
    begin
        LineNo := 10000;
        LAXEDIPmtRemitAdviceLine2.SetRange("Payment Advice No.", LAXEDIPaymentRemitAdvice."No.");
        if LAXEDIPmtRemitAdviceLine2.FindLast() then
            LineNo := LAXEDIPmtRemitAdviceLine2."Line No." + LineNo;
    end;

    local procedure SetAdjustmentValuesOnAdviceLine(LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line")
    var
        LAXEDIPmtRemitAdviceLine3: Record "LAX EDI Pmt. Remit Advice Line";
    begin
        if not ((LAXEDIPmtRemitAdviceLine.Adjustment) and
           (LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No." = '')) then
            exit;
        LAXEDIPmtRemitAdviceLine3.Reset();
        LAXEDIPmtRemitAdviceLine3.SetRange("Payment Advice No.", LAXEDIPaymentRemitAdvice."No.");
        LAXEDIPmtRemitAdviceLine3.SetFilter("Line No.", '<%1', LAXEDIPmtRemitAdviceLine."Line No.");
        LAXEDIPmtRemitAdviceLine3.SetRange(Adjustment, false);
        if not LAXEDIPmtRemitAdviceLine3.FindFirst() then
            exit;

        LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type" :=
        LAXEDIPmtRemitAdviceLine3."Journal Applies-to Doc. Type";
        LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No." :=
        LAXEDIPmtRemitAdviceLine3."Journal Applies-to Doc. No.";
        LAXEDIPmtRemitAdviceLine.Modify();
    end;

    local procedure SetCustomerValuesOnHeader(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field")
    var
        Customer: Record Customer;
    begin
        if not TryGetCustomerCrossReference(LAXEDIReceiveDocumentField, Customer) then
            exit;
        LAXEDIPaymentRemitAdvice.Validate("Payer Account Type", LAXEDIPaymentRemitAdvice."Payer Account Type"::Customer);
        LAXEDIPaymentRemitAdvice.Validate("Payer Account No.", Customer."No.");
        LAXEDIPaymentRemitAdvice.Modify();
    end;

    local procedure SetCustomerValuesOnLine(var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field")
    var
        Customer: Record Customer;
    begin
        //if not TryGetCustomerCrossReference(LAXEDIReceiveDocumentField, Customer) then
        //    exit;

        LAXEDIPmtRemitAdviceLine.Validate("Journal Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type"::Customer);
        LAXEDIPmtRemitAdviceLine.Validate("Journal Account No.", Customer."No.");
        // #275
        //don't change it here. keep cust for dimension use when creating journal lines
        //LAXEDIPaymentRemitAdvice.get(LAXEDIPmtRemitAdviceLine."Payment Advice No.");
        //LAXEDIPmtRemitAdviceLine.Validate("Journal Account No.", LAXEDIPaymentRemitAdvice."Payer Account No.");
        LAXEDIPmtRemitAdviceLine.Validate("G/L Bal. Account No.", '');
        LAXEDIPmtRemitAdviceLine.Description := Customer.Name;
        // #275
        // LAXEDIPmtRemitAdviceLine.Modify();
    end;

    local procedure SetCustomerValuesOnLine(var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        Customer: Record Customer;
    begin
        if not TryGetCustomerCrossReference(LAXEDIReceiveDocumentField, Customer) then
            exit;

        LAXEDIPmtRemitAdviceLine.Validate(
          "Journal Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type"::Customer);
        LAXEDIPmtRemitAdviceLine.Validate("Journal Account No.", Customer."No.");
        LAXEDIPmtRemitAdviceLine.Validate("SBC Customer No.", Customer."No.");
        LAXEDIPmtRemitAdviceLine.Description := Customer.Name;
    end;

    local procedure SetDocumentDate(var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        LAXEDIReceiveDocumentField2: Record "LAX EDI Receive Document Field";
    begin
        if not (LAXEDIPaymentRemitAdvice."Document Date" in [WorkDate(), 0D]) then
            exit;
        LAXEDIReceiveDocumentField2.CopyFilters(LAXEDIReceiveDocumentField);
        LAXEDIReceiveDocumentField2.SetRange("Table No.");
        LAXEDIReceiveDocumentField2.SetFilter("Field Date Value", '<>%1&<>%2', 0D, WorkDate());

        if LAXEDIReceiveDocumentField2.FindFirst() then
            LAXEDIPaymentRemitAdvice."Document Date" := LAXEDIReceiveDocumentField2."Field Date Value"
        else
            LAXEDIPaymentRemitAdvice."Document Date" := WorkDate();
        LAXEDIPaymentRemitAdvice.Modify();
    end;

    local procedure SetEDIPaymentAdviceLineValues(var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line")
    var
        GLAccount: Record "G/L Account";
        LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
        AmountFieldValue: Decimal;
    begin
        case LAXEDIReceiveDocumentField."Field No." of
            LAXEDIPmtRemitAdviceLine.FieldNo(Amount):
                LAXEDIPmtRemitAdviceLine.Amount := LAXEDIReceiveDocumentField."Field Dec. Value";
            LAXEDIPmtRemitAdviceLine.FieldNo(LAXEDIPmtRemitAdviceLine."Document Amount"):
                LAXEDIPmtRemitAdviceLine."Document Amount" := LAXEDIReceiveDocumentField."Field Dec. Value";
            LAXEDIPmtRemitAdviceLine.FieldNo("Credit Amount"):
                begin
                    AmountFieldValue := LAXEDIReceiveDocumentField."Field Dec. Value";
                    if AmountFieldValue > 0 then
                        LAXEDIPmtRemitAdviceLine."Credit Amount" := Abs(AmountFieldValue)
                    else
                        LAXEDIPmtRemitAdviceLine."Debit Amount" := Abs(AmountFieldValue);
                end;

            LAXEDIPmtRemitAdviceLine.FieldNo("Debit Amount"):
                begin
                    AmountFieldValue := LAXEDIReceiveDocumentField."Field Dec. Value";
                    if AmountFieldValue > 0 then
                        LAXEDIPmtRemitAdviceLine."Credit Amount" := Abs(AmountFieldValue)
                    else
                        LAXEDIPmtRemitAdviceLine."Debit Amount" := Abs(AmountFieldValue);
                end;

            LAXEDIPmtRemitAdviceLine.FieldNo("Discount Amount"):
                LAXEDIPmtRemitAdviceLine."Discount Amount" := LAXEDIReceiveDocumentField."Field Dec. Value";
            LAXEDIPmtRemitAdviceLine.FieldNo("Journal Applies-to Doc. No."):
                LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. No." := LAXEDIReceiveDocumentField."Field Text Value";
            LAXEDIPmtRemitAdviceLine.FieldNo("Journal Account No."):
                if LAXEDIReceiveDocumentField."Line Type" <> LAXEDIReceiveDocumentField."Line Type"::" " then
                    case LAXEDIReceiveDocumentField."Line Type" of
                        LAXEDIReceiveDocumentField."Line Type"::"G/L Account":
                            begin
                                LAXEDIPmtRemitAdviceLine."Journal Account No." := LAXEDIReceiveDocumentField."Cross Ref. Value-1";
                                if LAXEDIReceiveDocumentField."Sub Cross Ref. Value-1" <> '' then
                                    LAXEDIPmtRemitAdviceLine."G/L Bal. Account No." := LAXEDIReceiveDocumentField."Sub Cross Ref. Value-1";
                                if GLAccount.Get(LAXEDIPmtRemitAdviceLine."Journal Account No.") then begin
                                    LAXEDIPmtRemitAdviceLine.Description := GLAccount.Name;
                                    LAXEDIPmtRemitAdviceLine.Validate("G/L Bal. Account No.", GLAccount."No.");
                                    // if LAXEDIPmtRemitAdviceLine."G/L Bal. Account No." <> '' then
                                    //     LAXEDIPmtRemitAdviceLine.Validate("G/L Bal. Account No.", LAXEDIPmtRemitAdviceLine."G/L Bal. Account No.");
                                end;
                                // #275
                                if LAXEDIPmtRemitAdviceLine."G/L Bal. Account No." = LAXEDIPmtRemitAdviceLine."Journal Account No." then
                                    LAXEDIPmtRemitAdviceLine."G/L Bal. Account No." := '';
                                // #275
                            end;
                    end;
            LAXEDIPaymentRemitAdvice.FieldNo("Payer Account No."):
                case GlobalLAXEDIDocument."Payer Account Type" of
                    GlobalLAXEDIDocument."Payer Account Type"::Customer:
                        SetCustomerValuesOnLine(LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);
                    GlobalLAXEDIDocument."Payer Account Type"::Vendor:
                        SetVendorValuesOnLine(LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);
                end;
            LAXEDIPmtRemitAdviceLine.FieldNo("Journal Applies-to Doc. Type"):
                if LAXEDIReceiveDocumentField."Cross Ref. Value-1" = '' then
                    Evaluate(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type", LAXEDIReceiveDocumentField."Field Text Value")
                else
                    Evaluate(LAXEDIPmtRemitAdviceLine."Journal Applies-to Doc. Type", LAXEDIReceiveDocumentField."Cross Ref. Value-1");
            LAXEDIPmtRemitAdviceLine.FieldNo("Document External Doc. No."):
                LAXEDIPmtRemitAdviceLine."Document External Doc. No." := LAXEDIReceiveDocumentField."Field Text Value";
            LAXEDIPmtRemitAdviceLine.FieldNo("Document Posting Date"):
                LAXEDIPmtRemitAdviceLine."Document Posting Date" := LAXEDIReceiveDocumentField."Field Date Value";
            LAXEDIPmtRemitAdviceLine.FieldNo("Reason Code"):
                if LAXEDIReceiveDocumentField."General EDI Cross Reference" then
                    LAXEDIPmtRemitAdviceLine."Reason Code" := LAXEDIReceiveDocumentField."Cross Ref. Value-1"
                else
                    LAXEDIPmtRemitAdviceLine."Reason Code" := LAXEDIReceiveDocumentField."Field Text Value";
            LAXEDIPmtRemitAdviceLine.FieldNo(Adjustment):
                case UpperCase(LAXEDIReceiveDocumentField."Field Text Value") of
                    'TRUE':
                        LAXEDIPmtRemitAdviceLine.Adjustment := not GlobalIgnoreAdjustmentFlag;
                    'FALSE':
                        LAXEDIPmtRemitAdviceLine.Adjustment := false;
                end;
            LAXEDIPmtRemitAdviceLine.FieldNo("EDI Reference ID"):
                LAXEDIPmtRemitAdviceLine."EDI Reference ID" := LAXEDIReceiveDocumentField."Field Text Value";
            LAXEDIPmtRemitAdviceLine.FieldNo(Description):
                LAXEDIPmtRemitAdviceLine.Description := LAXEDIReceiveDocumentField."Field Text Value";
            else
                OnAfterMapPaymentAdviceLineFields(LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);
        end;

        if LAXEDIReceiveDocumentField."EDI Trigger" then
            LAXEDIPmtRemitAdviceLine."Segment Group" := LAXEDIReceiveDocumentField."Segment Group";
    end;

    local procedure SetFilteredReceiveDocumentLine(StartLineNo: Integer; StopLine: Integer; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field") Found: Boolean
    begin
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", GlobalLAXEDIReceiveDocumentHdr."Internal Doc. No.");
        if StopLine <> 0 then
            LAXEDIReceiveDocumentField.SetFilter("Line No.", '%1..%2', StartLineNo + 1, StopLine - 1)
        else
            LAXEDIReceiveDocumentField.SetFilter("Line No.", '%1..', StartLineNo + 1);
        Found := not LAXEDIReceiveDocumentField.IsEmpty();
    end;

    local procedure SetGlobals(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var EDIDocument: Record "LAX EDI Document"; SBCEDIECRSettings: Record "SBCEDI ECR Settings")
    var
        LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
    begin
        GlobalPaymentAdviceSegment := SBCEDIECRSettings."Payment Advice Segment";
        GlobalBankAccountNo := SBCEDIECRSettings."Bank Account No.";
        GlobalIgnoreAdjustmentFlag := SBCEDIECRSettings."Ignore Adjustment Flag";
        GlobalLAXEDIReceiveDocumentHdr := EDIRecDocHdr;
        GlobalLAXEDIDocument := EDIDocument;
        CreateGlobalDocumentLineList(EDIRecDocHdr);
    end;

    local procedure SetPaymentValuesOnLine(var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line")
    begin
        if LAXEDIPmtRemitAdviceLine.Amount = 0 then
            LAXEDIPmtRemitAdviceLine.Amount := LAXEDIPmtRemitAdviceLine."Debit Amount" - LAXEDIPmtRemitAdviceLine."Credit Amount";
        // if (LAXEDIPmtRemitAdviceLine.Amount = 0) and (LAXEDIPmtRemitAdviceLine."Discount Amount" <> 0) then
        //     LAXEDIPmtRemitAdviceLine.Amount := LAXEDIPmtRemitAdviceLine."Discount Amount";
        if LAXEDIPmtRemitAdviceLine."Document Amount" = 0 then
            LAXEDIPmtRemitAdviceLine."Document Amount" := LAXEDIPmtRemitAdviceLine.Amount;
        if LAXEDIPmtRemitAdviceLine.Amount > 0 then
            exit;

        LAXEDIPmtRemitAdviceLine.Validate("Document Type", LAXEDIPmtRemitAdviceLine."Document Type"::Refund);
    end;

    local procedure SetReleased(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        LAXEDITemplate: Record "LAX EDI Template";
    begin
        if not LAXEDITemplate.Get(GlobalLAXEDIReceiveDocumentHdr."EDI Template Code") then
            exit;
        if not LAXEDITemplate."Release Pmt. Advice On Receipt" then
            exit;
        LAXEDIPaymentRemitAdvice.Validate(Released, LAXEDITemplate."Release Pmt. Advice On Receipt");
        LAXEDIPaymentRemitAdvice.Modify();
    end;

    local procedure SetVendorValuesOnHeader(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field")
    var
        Vendor: Record Vendor;
    begin
        if not TryGetVendorCrossReference(LAXEDIReceiveDocumentField, Vendor) then
            exit;
        LAXEDIPaymentRemitAdvice.Validate("Payer Account Type", LAXEDIPaymentRemitAdvice."Payer Account Type"::Vendor);
        LAXEDIPaymentRemitAdvice.Validate("Payer Account No.", Vendor."No.");
        // LAXEDIPaymentRemitAdvice.Modify();
    end;

    local procedure SetVendorValuesOnLine(var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field")
    var
        Vendor: Record Vendor;
    begin
        if not TryGetVendorCrossReference(LAXEDIReceiveDocumentField, Vendor) then
            exit;
        LAXEDIPmtRemitAdviceLine.Validate("Journal Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type"::Vendor);
        LAXEDIPmtRemitAdviceLine.Validate("Journal Account No.", Vendor."No.");
        LAXEDIPmtRemitAdviceLine.Modify();
    end;

    local procedure SetVendorValuesOnLine(var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice")
    var
        Vendor: Record Vendor;
    begin
        // if not TryGetVendorCrossReference(LAXEDIReceiveDocumentField, Vendor) then
        //     exit;
        if not Vendor.Get(LAXEDIPaymentRemitAdvice."Payer Account No.") then
            exit;
        LAXEDIPmtRemitAdviceLine.Validate(
          "Journal Account Type", LAXEDIPmtRemitAdviceLine."Journal Account Type"::Vendor);
        LAXEDIPmtRemitAdviceLine.Validate("Journal Account No.", Vendor."No.");
        LAXEDIPmtRemitAdviceLine.Description := Vendor.Name;
    end;

    local procedure UpdatePaymentValuesOnHeader(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line")
    begin
        if LAXEDIPaymentRemitAdvice."Payment Amount" = 0 then
            LAXEDIPaymentRemitAdvice."Payment Amount" := LAXEDIPmtRemitAdviceLine.Amount;
        if LAXEDIPaymentRemitAdvice."Payment Amount" < 0 then
            LAXEDIPaymentRemitAdvice."Remittance Type" := "LAX EDI Remittance Type"::Information
        else
            LAXEDIPaymentRemitAdvice."Remittance Type" := "LAX EDI Remittance Type"::Payment;
        LAXEDIPaymentRemitAdvice.Modify();
    end;

    local procedure ExistingLineFound(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field")
    var
        LAXReceiveDocAppliesToDocNo: Record "LAX EDI Receive Document Field";
    begin
        LAXReceiveDocAppliesToDocNo.CopyFilters(LAXEDIReceiveDocumentField);
        LAXReceiveDocAppliesToDocNo.SetRange("Field No.", LAXEDIPmtRemitAdviceLine.FieldNo("Journal Applies-to Doc. No."));
        LAXReceiveDocAppliesToDocNo.SetLoadFields("Field Text Value");
        if not LAXReceiveDocAppliesToDocNo.FindFirst() then
            exit;
        LAXEDIPmtRemitAdviceLine.SetRange("Payment Advice No.", LAXEDIPaymentRemitAdvice."No.");
        LAXEDIPmtRemitAdviceLine.SetFilter("Journal Applies-to Doc. No.", LAXReceiveDocAppliesToDocNo."Field Text Value");
        if not LAXEDIPmtRemitAdviceLine.FindFirst() then
            exit;
        LAXEDIPmtRemitAdviceLine.Delete();
    end;

    local procedure SetAccountValuesOnLine(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; var LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field")
    begin
        LAXEDIReceiveDocumentField.SetRange("Table No.", Database::"LAX EDI Payment Remit Advice");
        LAXEDIReceiveDocumentField.SetRange("Field No.", LAXEDIPaymentRemitAdvice.FieldNo("Payer Account No."));
        if LAXEDIReceiveDocumentField.FindFirst() then
            case GlobalLAXEDIDocument."Payer Account Type" of
                GlobalLAXEDIDocument."Payer Account Type"::Customer:
                    SetCustomerValuesOnLine(LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);
                GlobalLAXEDIDocument."Payer Account Type"::Vendor:
                    SetVendorValuesOnLine(LAXEDIPmtRemitAdviceLine, LAXEDIReceiveDocumentField);
            end;
        if LAXEDIPmtRemitAdviceLine."Journal Account No." = '' then
            case GlobalLAXEDIDocument."Payer Account Type" of
                GlobalLAXEDIDocument."Payer Account Type"::Customer:
                    SetCustomerValuesOnLine(LAXEDIReceiveDocumentField, LAXEDIPmtRemitAdviceLine, LAXEDIPaymentRemitAdvice);
                GlobalLAXEDIDocument."Payer Account Type"::Vendor:
                    SetVendorValuesOnLine(LAXEDIReceiveDocumentField, LAXEDIPmtRemitAdviceLine, LAXEDIPaymentRemitAdvice);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBC LAXEDICreatePmtRemitAdv", OnAfterEvaluateCrossReference, '', false, false)]
    local procedure OnAfterEvaluateCrossReference(var MapGenCrossRef: Boolean; var CrossReferenceError: Boolean; EvaluateGenCrossRef: Boolean; EDISetup: Record "LAX EDI Setup"; EDITradePartner: Record "LAX EDI Trade Partner"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        LAXEDIReceiveDocumentField.SetFilter("Copy String Position", '<>%1', 0);
        LAXEDIReceiveDocumentField.SetFilter("Copy String Length", '<>%1', 0);
        if LAXEDIReceiveDocumentField.IsEmpty() then
            exit;
        LAXEDIReceiveDocumentField.FindSet();
        repeat
            if StrLen(LAXEDIReceiveDocumentField."Field Text Value") > LAXEDIReceiveDocumentField."Copy String Length" then begin
                LAXEDIReceiveDocumentField."Field Text Value" := CopyStr(LAXEDIReceiveDocumentField."Field Text Value", LAXEDIReceiveDocumentField."Copy String Position", LAXEDIReceiveDocumentField."Copy String Length");
                LAXEDIReceiveDocumentField.Modify();
            end;

        until LAXEDIReceiveDocumentField.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBC LAXEDICreatePmtRemitAdv", OnBeforeExitCreatePaymentAdviceLine, '', false, false)]
    local procedure OnAfterCreatePaymentAdvice(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; EDIDocument: Record "LAX EDI Document")
    begin
        CreateDocuments(EDIRecDocHdr, EDIDocument);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMapPaymentAdviceFields(var LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice"; LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterMapPaymentAdviceLineFields(var LAXEDIPmtRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line"; LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field");
    begin
    end;

    // #275
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SBC LAXEDICreatePmtRemitAdv", OnAfterEvaluateCrossReference, '', false, false)]
    local procedure "LAX EDI Create Pmt Remit Adv._OnAfterEvaluateCrossReference"(var MapGenCrossRef: Boolean; var CrossReferenceError: Boolean; EvaluateGenCrossRef: Boolean; EDISetup: Record "LAX EDI Setup"; EDITradePartner: Record "LAX EDI Trade Partner"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
        RemitAdviceExistsErr: Label 'Remit Advice %1 already exists for this 820 document.';
    begin
        // Only 1 remit advice per 820 is allowed at a time
        LAXEDIPaymentRemitAdvice.SetFilter("Internal Doc. No.", '%1', EDIRecDocHdr."Internal Doc. No.");
        LAXEDIPaymentRemitAdvice.SetFilter("Trade Partner No.", '%1', EDIRecDocHdr."Trade Partner No.");
        if LAXEDIPaymentRemitAdvice.FindFirst() then
            Error(RemitAdviceExistsErr, LAXEDIPaymentRemitAdvice."No.");
    end;

    // Avoid duplication of remit advice for a given 820 document
    [EventSubscriber(ObjectType::Table, Database::"LAX EDI Receive Document Hdr.", OnBeforeProcessReceiveDoc, '', false, false)]
    local procedure "LAX EDI Receive Document Hdr._OnBeforeProcessReceiveDoc"(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; Batch: Boolean; var IsHandled: Boolean)
    var
        EDIRecDocHdr2: Record "LAX EDI Receive Document Hdr.";
        EDICreatePaymentAdvice: Codeunit "SBC LAXEDICreatePmtRemitAdv";
    begin
        if EDIRecDocHdr.Document = 'I_PMTADV' then begin
            ClearLastError;
            Clear(EDICreatePaymentAdvice);
            if Batch then begin
                if not EDICreatePaymentAdvice.Run(EDIRecDocHdr) then begin
                    EDIRecDocHdr2.Get(EDIRecDocHdr."Internal Doc. No.");
                    EDIRecDocHdr2."Error Message Text" := CopyStr(GetLastErrorText, 1, 250);
                    EDIRecDocHdr2.Modify;
                    Commit;
                end;
            end else
                if not EDICreatePaymentAdvice.Run(EDIRecDocHdr) then begin
                    EDIRecDocHdr2.Get(EDIRecDocHdr."Internal Doc. No.");
                    EDIRecDocHdr2."Error Message Text" := CopyStr(GetLastErrorText, 1, 250);
                    EDIRecDocHdr2.Modify;
                    Commit;
                    Error(GetLastErrorText);
                end;
            IsHandled := true;
        end;
    end;
    // #275
}