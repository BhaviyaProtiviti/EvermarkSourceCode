XMLport 50100 "Import Concur Entries"
{
    Caption = 'Import Concur Entries';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    TableSeparator = '';
    schema
    {
        textelement(Root)
        {
            tableelement("Concur Import Entry"; "Concur Import Entry")
            {
                XmlName = 'ConcurImporEntry';
                textelement(EntryDate)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        "Concur Import Entry"."Entry Date" := GetDateFromText(EntryDate);
                    END;
                }

                fieldelement(EmployeeID; "Concur Import Entry"."Employee ID")
                {

                }

                fieldelement(EmployeeLastName; "Concur Import Entry"."Employee Last Name")
                {

                }

                fieldelement(EmployeeFirstName; "Concur Import Entry"."Employee First Name")
                {

                }

                fieldelement(ReportID; "Concur Import Entry"."Report ID")
                {

                }

                fieldelement(EmployeeDefaultCurrency; "Concur Import Entry"."Employee Default Currency")
                {

                }

                textelement(ReportSubmitDate)
                {
                    trigger OnAfterAssignVariable()
                    BEGIN
                        evaluate("Concur Import Entry"."Report Submit Date", ReportSubmitDate);// := GetDateFromText(ReportSubmitDate);
                    END;
                }

                textelement(ReportProcessingPaymentDate)
                {
                    trigger OnAfterAssignVariable()
                    BEGIN
                        evaluate("Concur Import Entry"."Report Processing Payment Date", ReportProcessingPaymentDate); // := GetDateFromText(ReportProcessingPaymentDate);
                    END;
                }

                fieldelement(ReportName; "Concur Import Entry"."Report Name")
                {

                }

                fieldelement(ExpenseTypeName; "Concur Import Entry"."Expense Type Name")
                {

                }

                textelement(TransactionDate)
                {
                    trigger OnAfterAssignVariable()
                    BEGIN
                        Evaluate("Concur Import Entry"."Transaction Date", TransactionDate); // := GetDateFromText(TransactionDate);
                    END;
                }

                fieldelement(IsPersonalFlag; "Concur Import Entry"."Is Personal Flag")
                {

                }

                fieldelement(Description; "Concur Import Entry".Description)
                {

                }

                fieldelement(VendorName; "Concur Import Entry"."Vendor Name")
                {

                }

                fieldelement(VendorDescription; "Concur Import Entry"."Vendor Description")
                {

                }

                fieldelement(PaymentCode; "Concur Import Entry"."Payment Code")
                {

                }

                fieldelement(PaymentName; "Concur Import Entry"."Payment Name")
                {

                }

                fieldelement(PaymentReimbursementType; "Concur Import Entry"."Payment Reimbursement Type")
                {

                }

                fieldelement(BilledCreditCardAccountNo; "Concur Import Entry"."Billed Credit Card Account No.")
                {

                }

                fieldelement(BilledCreditCardAccountDescr; "Concur Import Entry"."Billed Credit Card Acc. Descr.")
                {

                }

                fieldelement(JournalPayerPaymentName; "Concur Import Entry"."Journal Payer Payment Name")
                {

                }

                fieldelement(JournalPayeePaymentType; "Concur Import Entry"."Journal Payee Payment Type")
                {

                }

                fieldelement(JournalAmount; "Concur Import Entry"."Journal Amount")
                {

                }
                textelement(IsBillable)
                {
                    trigger OnAfterAssignVariable()
                    BEGIN
                        if (UpperCase(isbillable) = 'N') or (IsBillable = '') then
                            "Concur Import Entry"."Is Billable" := false
                        else
                            "Concur Import Entry"."Is Billable" := true;
                    END;

                }

                fieldelement(JournalAccountCode; "Concur Import Entry"."Journal Account Code")
                {

                }

                fieldelement(JournalDebitOrCredit; "Concur Import Entry"."Journal Debit Or Credit")
                {

                }

                fieldelement(DemandCompCashAcc; "Concur Import Entry"."Demand Comp. Cash Acc.")
                {

                }

                fieldelement(DemantCompLiabilityAcc; "Concur Import Entry"."Demand Comp. Liability Acc.")
                {

                }

                textelement(EstimatedPaymentDate)
                {
                    trigger OnAfterAssignVariable()
                    BEGIN
                        "Concur Import Entry"."Estimated Payment Date" := GetDateFromText(EstimatedPaymentDate);
                    END;
                }

                fieldelement(Department; "Concur Import Entry".Department)
                {
                    MinOccurs = Once;
                }

                trigger OnBeforeInsertRecord()
                begin
                    "Concur Import Entry"."Entry No." := EntryNo;
                    EntryNo += 1;
                    TempConcurImportEntry.RESET();
                    TempConcurImportEntry.SETCURRENTKEY("Report ID");
                    TempConcurImportEntry.SETRANGE("Report ID", "Concur Import Entry"."Report ID");
                    IF NOT TempConcurImportEntry.FINDFIRST() THEN BEGIN
                        ConcurImportEntry2.RESET();
                        ConcurImportEntry2.SETCURRENTKEY("Report ID");
                        ConcurImportEntry2.SETRANGE("Report ID", "Concur Import Entry"."Report ID");
                        IF ConcurImportEntry2.FINDFIRST() THEN
                            IF NOT CONFIRM(STRSUBSTNO(Text001Msg, "Concur Import Entry"."Report ID")) THEN
                                ERROR(Err001Err);
                    END;
                END;

                trigger OnAfterInsertRecord()
                begin

                    TempConcurImportEntry.INIT();
                    TempConcurImportEntry := "Concur Import Entry";
                    TempConcurImportEntry.INSERT();
                END;

                trigger OnafterInitRecord()
                begin
                    IF FirstLine THEN BEGIN
                        FirstLine := FALSE;
                        currXMLport.SKIP();
                    END;
                END;
            }
        }
    }
    trigger OnPreXMLport()
    BEGIN
        FirstLine := TRUE;

        ConcurImportEntry2.RESET();
        IF ConcurImportEntry2.FINDLAST() THEN
            EntryNo := ConcurImportEntry2."Entry No." + 1
        ELSE
            EntryNo := 1;
    END;

    trigger OnPostXMLport()
    BEGIN
        MESSAGE(Text002Msg);
    END;

    VAR
        ConcurImportEntry2: Record "Concur Import Entry";
        TempConcurImportEntry: Record "Concur Import Entry" temporary;
        EntryNo: Integer;
        FirstLine: Boolean;
        Text001Msg: Label 'Report ID %1 already exists in imported entries.\This may duplicate your entries.\Do you want to continue?', comment = 'just a msg %1';
        Text002Msg: Label 'Import completed';
        Err001Err: Label 'Canceled by the user';

    LOCAL PROCEDURE GetDateFromText(EntryDateText2: Text): Date
    VAR
        YearText: Text;
        MonthText: Text;
        DayText: Text;
        Year: Integer;
        Month: Integer;
        Day: Integer;
    BEGIN
        IF EntryDateText2 = '' THEN
            EXIT(0D);

        YearText := COPYSTR(EntryDateText2, 1, 4);
        MonthText := COPYSTR(EntryDateText2, 6, 2);
        DayText := COPYSTR(EntryDateText2, 9, 2);

        IF NOT EVALUATE(Year, YearText) THEN
            EXIT(0D);

        IF NOT EVALUATE(Month, MonthText) THEN
            EXIT(0D);

        IF NOT EVALUATE(Day, DayText) THEN
            EXIT(0D);

        EXIT(DMY2DATE(Day, Month, Year));
    END;

}
