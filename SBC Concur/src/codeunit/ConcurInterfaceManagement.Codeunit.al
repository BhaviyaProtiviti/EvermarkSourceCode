codeunit 50113 "Concur Interface Management"
{
    trigger OnRun()
    begin
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempRemitAddress: Record "Remit Address" temporary;
        TempVendor: Record Vendor temporary;
        InvoicesCreatedCount: Integer;
        LinesCreatedCount: Integer;
        Text001Lbl: Label '%1 Invoices Created', comment = '%1 is the total number of invoices created';
        Text002Lbl: Label '%1 Lines added to existing invoices', comment = '%1 total number of lines added';
        CashTxt: Label 'CASH';
        IBCPTxt: Label 'IBCP';
        CBCPTxt: Label 'CBCP';
        Window: Dialog;
        FromEntryNo: Integer;
        ToEntryNo: Integer;

    procedure CreatePurchInvoices(var ConcurImportEntry2: Record "Concur Import Entry")
    var
        ConcurImportEntry: Record "Concur Import Entry";
        PurchDocType: Enum "Purchase Document Type";
        PurchDocNo: Code[20];
    begin
        ConcurImportEntry2.reset();
        ConcurImportEntry2.setrange("Purchase Invoice Line No.", 0);
        if not ConcurImportEntry2.findfirst() then
            exit;

        FromEntryNo := ConcurImportEntry2."Entry No.";
        if ConcurImportEntry2.findlast() then
            toentryno := ConcurImportEntry2."Entry No.";
        ConcurImportEntry.setrange("Entry No.", FromEntryNo, ToEntryNo);

        PurchSetup.GET();
        PurchSetup.TESTFIELD("American Express Vendor No.");
        TempVendor."No." := PurchSetup."American Express Vendor No.";
        TempVendor.insert();

        ConcurImportEntry.find('-');
        repeat
            vendor.setrange("Employee ID", ConcurImportEntry."Employee ID");
            Vendor.findfirst();
            if not TempVendor.get(vendor."No.") then begin
                TempVendor := Vendor;
                TempVendor.Insert();
            end;

            //Suave only uses AMEX or cash reimbursement
            case
                ConcurImportEntry."Payment Code" of
                CashTxt:
                    if not TempRemitAddress.get(CashTxt, Vendor."No.") then begin
                        TempRemitAddress.code := CashTxt;
                        TempRemitAddress."Vendor No." := Vendor."No.";
                        TempRemitAddress.insert();
                    end;
                IBCPTxt, CBCPTxt:
                    //IBCP is individual billed company paid
                    //CBCP is company billed company paid
                    if not TempRemitAddress.get(ConcurImportEntry."Payment Code", PurchSetup."American Express Vendor No.") then begin
                        TempRemitAddress.Code := ConcurImportEntry."Payment Code";
                        TempRemitAddress."Vendor No." := PurchSetup."American Express Vendor No.";
                        TempRemitAddress.insert();
                    end;
            end;
        until ConcurImportEntry.next() = 0;

        window.open('Processing...');
        TempRemitAddress.find('-');
        repeat
            TempVendor.setrange("No.", TempRemitAddress."Vendor No.");
            TempVendor.find('-');
            repeat
                ConcurImportEntry.setrange("Payment Code", TempRemitAddress.Code);
                if TempVendor."Employee ID" <> '' then
                    ConcurImportEntry.setrange("Employee ID", TempVendor."Employee ID")
                else
                    ConcurImportEntry.setrange("Employee ID");
                if ConcurImportEntry.FIND('-') then
                    repeat
                        if ConcurImportEntry."Journal Debit Or Credit" = ConcurImportEntry."Journal Debit Or Credit"::DR then
                            PurchDocType := PurchDocType::Invoice
                        else
                            PurchDocType := PurchDocType::"Credit Memo";
                        if ConcurImportEntry."Purchase Invoice No." = '' then begin
                            PurchDocNo := FindPurchInvHeader(ConcurImportEntry, PurchDocType);
                            if PurchDocNo = '' then
                                PurchDocNo := CreatePurchInvHeader(ConcurImportEntry, PurchDocType);
                            CreatePurchInvLine(ConcurImportEntry, PurchDocType, PurchDocNo);
                        end;
                    until ConcurImportEntry.NEXT() = 0;
            until TempVendor.next() = 0;
        until TempRemitAddress.Next() = 0;

        RemoveDupVendorInvoiceNos();

        if InvoicesCreatedCount <> 0 then
            Message(Text001Lbl, InvoicesCreatedCount)
        else
            message(Text002Lbl, LinesCreatedCount);
    end;

    local procedure CreatePurchInvHeader(var ConcurImportEntry: Record "Concur Import Entry"; PurchDocType: Enum "Purchase Document Type"): Code[20]
    var
        PurchaseHeader: Record 38;
        NoSeriesMgt: Codeunit 396;
    begin
        PurchSetup.TESTFIELD("Invoice Nos.");
        PurchaseHeader.INIT();
        PurchaseHeader.VALIDATE("Document Type", PurchDocType);
        PurchaseHeader.VALIDATE("No.", NoSeriesMgt.GetNextNo(PurchSetup."Invoice Nos.", ConcurImportEntry."Report Submit Date", true));
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", TempRemitAddress."Vendor No.");
        PurchaseHeader.VALIDATE("Posting Date", ConcurImportEntry."Report Submit Date");
        PurchaseHeader."Pay-to Contact No." := ConcurImportEntry."Employee ID";
        PurchaseHeader."SBC Employee ID" := ConcurImportEntry."Employee ID";
        PurchaseHeader."SBC Employee Name" := ConcurImportEntry."Employee First Name" + ' ' + ConcurImportEntry."Employee Last Name";
        PurchaseHeader.Validate("Vendor Invoice No.", ConcurImportEntry."Report ID");
        if ConcurImportEntry."Payment Code" in [IBCPTxt, CBCPTxt] then
            PurchaseHeader.Validate("Payment Reference", ConcurImportEntry."Billed Credit Card Account No.");
        PurchaseHeader.INSERT();
        TempPurchaseHeader := PurchaseHeader;
        TempPurchaseHeader.insert();
        InvoicesCreatedCount += 1;
        exit(PurchaseHeader."No.");
    end;

    local procedure CreatePurchInvLine(var ConcurImportEntry: Record "Concur Import Entry"; PurchDocType: Enum "Purchase Document Type"; PurchDocNo: Code[20])
    var
        PurchLine: Record 39;
        LineNo: Integer;
    begin
        PurchLine.RESET();
        PurchLine.SETRANGE("Document Type", PurchDocType);
        PurchLine.SETRANGE("Document No.", PurchDocNo);
        if PurchLine.FINDLAST() then
            LineNo := PurchLine."Line No." + 10000
        else
            LineNo := 10000;

        PurchLine.INIT();
        PurchLine.validate("Document Type", PurchDocType);
        PurchLine.validate("Document No.", PurchDocNo);
        PurchLine."Line No." := LineNo;
        PurchLine.INSERT(true);
        LinesCreatedCount += 1;

        PurchLine.Type := PurchLine.Type::"G/L Account";
        PurchLine.VALIDATE("No.", ConcurImportEntry."Journal Account Code");
        PurchLine.VALIDATE(Quantity, 1);
        PurchLine.VALIDATE("Direct Unit Cost", ConcurImportEntry."Journal Amount");
        PurchLine.Validate(Description, copystr(ConcurImportEntry.Description + ' ' + ConcurImportEntry."Vendor Name" + ' ' + ConcurImportEntry."Vendor Description", 1, MaxStrLen(PurchLine.Description)));
        PurchLine.Validate("Description 2", ConcurImportEntry."Employee ID" + ' ' +
                                          ConcurImportEntry."Employee First Name" + ' ' +
                                          ConcurImportEntry."Employee Last Name");
        purchline.ValidateShortcutDimCode(3, ConcurImportEntry.Department);
        PurchLine.Modify(true);

        ConcurImportEntry."Purchase Invoice No." := PurchDocNo;
        ConcurImportEntry."Purchase Invoice Line No." := LineNo;
        ConcurImportEntry.MODIFY(true);
    end;

    local procedure FindPurchInvHeader(var ConcurImportEntry: Record "Concur Import Entry"; PurchDocType: Enum "Purchase Document Type"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.RESET();
        PurchaseHeader.SETRANGE("Document Type", PurchDocType);
        PurchaseHeader.SetRange("Buy-from Vendor No.", TempRemitAddress."Vendor No.");
        PurchaseHeader.SETRANGE("Posting Date", ConcurImportEntry."Report Submit Date");
        PurchaseHeader.setrange("Pay-to Contact No.", ConcurImportEntry."Employee ID");
        PurchaseHeader.setrange("Vendor Invoice No.", ConcurImportEntry."Report ID");
        PurchaseHeader.setrange("Payment Reference", ConcurImportEntry."Billed Credit Card Account No.");
        if PurchaseHeader.FINDFIRST() then
            if PurchaseHeader.Status = PurchaseHeader.Status::Open then begin
                TempPurchaseHeader := PurchaseHeader;
                if TempPurchaseHeader.insert() then;
                exit(PurchaseHeader."No.");
            end;
        exit('');
    end;

    local procedure RemoveDupVendorInvoiceNos()
    var
        PurchHeader: Record "Purchase Header";
        PurchHeader2: Record "Purchase Header";
        StartInvNo: Code[20];
        EndInvNo: Code[20];
        Suffix: Code[10];
    begin
        if TempPurchaseHeader.find('-') then begin
            StartInvNo := TempPurchaseHeader."No.";
            repeat
                EndInvNo := TempPurchaseHeader."No.";
            until TempPurchaseHeader.Next() = 0;

            TempPurchaseHeader.find('-');
            repeat
                PurchHeader.setrange("Document Type", TempPurchaseHeader."Document Type");
                PurchHeader.SetRange("No.", StartInvNo, EndInvNo);
                PurchHeader.SetRange("Buy-from Vendor No.", TempPurchaseHeader."Buy-from Vendor No.");
                PurchHeader.setrange("Vendor Invoice No.", TempPurchaseHeader."Vendor Invoice No.");
                if PurchHeader.count > 1 then begin
                    Suffix := '-01';
                    PurchHeader.Next();
                    repeat
                        PurchHeader2 := PurchHeader;
                        PurchHeader2.Validate("Vendor Invoice No.", PurchHeader2."Vendor Invoice No." + suffix);
                        PurchHeader2.modify();
                        suffix := IncStr(suffix);
                    until PurchHeader.Next() = 0;
                end;
            until TempPurchaseHeader.Next() = 0;
        end;
    end;
}
