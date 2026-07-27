/// <summary>
/// This table is used to store a header that represents the budget allocation process so that the user can see the order in which budget allocations were created for which Trade Spend Ledger entries.
/// </summary>
table 50204 "SBCTA Trade Accrual Header"
{
    Caption = 'Trade Accrual Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Trade Accrual No."; Integer)
        {
            Caption = 'Trade Accrual No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Description = 'This is an autofill number that indicates the order in which trade accruals were created.';
        }

        field(2; "Trade Accrual DateTime"; DateTime)
        {
            Caption = 'Trade Accrual DateTime';
            DataClassification = SystemMetadata;
            Description = 'This is the date and time that the Trade Accrual was created.';

        }
        field(3; "Accrual Type"; Enum "SBCTA Accrual Type")
        {
            Caption = 'Accrual Type';
            DataClassification = CustomerContent;
            InitValue = "Trade Spend";
            Description = 'This is the type of accrual that was created.';

        }
    }
    keys
    {
        key(PK; "Trade Accrual No.")
        {
            Clustered = true;
        }
    }

    var
        BudgetDoesNotExistErrorLabel: Label 'This trade ledger entry could not be allocated. The budget and budget rate code combination of %1 and %2 either has no Target Amount set or does not exist. ';
        NoValidAccrualLinesLabel: Label 'No valid accrued amounts exist for the Accrual Record %1.';
        TradeAccrualCompleteMessageLabel: Label 'The Trade Credits Journal entries have been created.';
        DeletePostedEntriesLabel: Label 'You cannot delete an Accrual that has posted entries.';
        GlobalSuppressAlerts: Boolean;
        GlobalAccrualDateFilter: Text;
        GlobalJournalPostingDate: Date;


    internal procedure CreateTradeAccrualHeader() SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
    begin
        // SBCTATradeAccrualHeader.LockTable(true);
        SBCTATradeAccrualHeader.Init();
        SBCTATradeAccrualHeader."Trade Accrual DateTime" := CurrentDateTime();
        if not SBCTATradeAccrualHeader.Insert() then
            exit;
        // Commit();
    end;

    internal procedure CreateIndirectCogsAccrualHeader() SBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
    begin
        SBCTATradeAccrualHeader.LockTable(true);
        SBCTATradeAccrualHeader.Init();
        SBCTATradeAccrualHeader."Trade Accrual DateTime" := CurrentDateTime();
        SBCTATradeAccrualHeader."Accrual Type" := "SBCTA Accrual Type"::"Indirect COGs Spend";
        if not SBCTATradeAccrualHeader.Insert() then
            exit;
        // Commit();
    end;

    internal procedure SetSuppressAlerts(SuppressAlerts: Boolean)
    begin
        GlobalSuppressAlerts := SuppressAlerts;
    end;

    internal procedure AddTradeAccrualLine(var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry"; var SBCTATradeBudget: Record "SBCTA Trade Budget"; IgnoreTradeTarget: Boolean)
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
        TargetBudgetAmount: Decimal;
        ActualBudgetAmount: Decimal;
        UpdatedActualBudgetAmount: Decimal;
        AccruedAmount: Decimal;

    begin
        // if not AccrualRecordExists() then
        //     exit;
        SBCTATradeBudgetRates := SBCTATrBudgetLedgerEntry.GetBudgetRate();
        TargetBudgetAmount := SBCTATradeBudgetRates."Trade Budget Target";
        ActualBudgetAmount := SBCTATradeBudgetRates."Trade Budget Actual";
        UpdatedActualBudgetAmount := SBCTATradeBudgetRates.UpdateTradeBudgetActual(SBCTATrBudgetLedgerEntry, IgnoreTradeTarget);
        // if UpdatedActualBudgetAmount = 0 then begin

        //     // Error(ErrorInfo.Create(StrSubstNo(BudgetDoesNotExistErrorLabel, SBCTATrBudgetLedgerEntry."Trade Budget Code", SBCTATrBudgetLedgerEntry."Trade Budget Rate Code"), true, SBCTATrBudgetLedgerEntry));
        //     // Message(StrSubstNo(BudgetDoesNotExistErrorLabel, SBCTATrBudgetLedgerEntry."Trade Budget Code", SBCTATrBudgetLedgerEntry."Trade Budget Rate Code"));
        //     exit;
        // end;
        if UpdatedActualBudgetAmount = 0 then
            exit;

        AccruedAmount := UpdatedActualBudgetAmount - ActualBudgetAmount;
        // SBCTATradeBudget
        // AccruedAmount := SBCTATrBudgetLedgerEntry."Trade Budget Amount" - SBCTATrBudgetLedgerEntry."Accrued Amount";
        // We need code here  to look up the targets for the budget spend category and also to track with  a flowfield possibly how much of the category is used.
        SBCTATradeAccrualLine.Init();
        SBCTATradeAccrualLine."Trade Accrual Line No." := SBCTATradeAccrualLine.GetNewLineNo(Rec."Trade Accrual No.");
        SBCTATradeAccrualLine."Trade Accrual No." := Rec."Trade Accrual No.";
        SBCTATradeAccrualLine."T/L Ledger Entry No." := SBCTATrBudgetLedgerEntry."Entry No.";
        SBCTATradeAccrualLine."Dimension Set ID" := SBCTATrBudgetLedgerEntry."Dimension Set ID";
        SBCTATradeAccrualLine."T/L Amount" := SBCTATrBudgetLedgerEntry."Trade Budget Amount";
        SBCTATradeAccrualLine."T/L Posting Date" := SBCTATrBudgetLedgerEntry."Posting Date";
        SBCTATradeAccrualLine."Calculation Method" := SBCTATrBudgetLedgerEntry."Calculation Method";
        SBCTATradeAccrualLine."Accrued Amount" := SBCTATrBudgetLedgerEntry."Accrued Amount";
        SBCTATradeAccrualLine."Calculation Basis" := SBCTATrBudgetLedgerEntry."Calculation Basis";
        SBCTATradeAccrualLine."Over Budget" := SBCTATrBudgetLedgerEntry."Over Budget";
        SBCTATradeAccrualLine."Trade Budget Code" := SBCTATrBudgetLedgerEntry."Trade Budget Code";
        SBCTATradeAccrualLine."Trade Budget Rate Code" := SBCTATrBudgetLedgerEntry."Trade Budget Rate Code";
        SBCTATradeAccrualLine."Trade Budget Rate Code ID" := SBCTATrBudgetLedgerEntry."Trade Budget Rate Code ID";
        SBCTATradeAccrualLine."Account No." := SBCTATrBudgetLedgerEntry."Customer No.";
        if not SBCTATradeAccrualLine.Insert(true) then
            exit;
        SBCTATrBudgetLedgerEntry."Trade Accrual No." := SBCTATradeAccrualLine."Trade Accrual No.";
        SBCTATrBudgetLedgerEntry."Trade Accrual Line No." := SBCTATradeAccrualLine."Trade Accrual Line No.";
        SBCTATrBudgetLedgerEntry.Modify();
        // SBCTATrBudgetLedgerEntry."Accrued Amount" += AccruedAmount;
    end;

    internal procedure AddIndirectCOGsAccrualLine(var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger"; var SBCTATradeBudget: Record "SBCTA Trade Budget"; IgnoreTradeTarget: Boolean)
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
        TargetBudgetAmount: Decimal;
        ActualBudgetAmount: Decimal;
        UpdatedActualBudgetAmount: Decimal;
        AccruedAmount: Decimal;

    begin
        if not AccrualRecordExists() then
            exit;
        SBCTATradeBudgetRates := SBCTAIndirectCOGsLedger.GetBudgetRate();
        TargetBudgetAmount := SBCTATradeBudgetRates."Trade Budget Target";
        ActualBudgetAmount := SBCTATradeBudgetRates."Trade Budget Actual";
        UpdatedActualBudgetAmount := SBCTATradeBudgetRates.UpdateIndirectCOGsBudgetActual(SBCTAIndirectCOGsLedger, IgnoreTradeTarget);
        // if UpdatedActualBudgetAmount = 0 then begin

        //     // Error(ErrorInfo.Create(StrSubstNo(BudgetDoesNotExistErrorLabel, SBCTATrBudgetLedgerEntry."Trade Budget Code", SBCTATrBudgetLedgerEntry."Trade Budget Rate Code"), true, SBCTATrBudgetLedgerEntry));
        //     // Message(StrSubstNo(BudgetDoesNotExistErrorLabel, SBCTATrBudgetLedgerEntry."Trade Budget Code", SBCTATrBudgetLedgerEntry."Trade Budget Rate Code"));
        //     exit;
        // end;
        if UpdatedActualBudgetAmount = 0 then
            exit;

        AccruedAmount := UpdatedActualBudgetAmount - ActualBudgetAmount;
        // SBCTATradeBudget
        // AccruedAmount := SBCTATrBudgetLedgerEntry."Trade Budget Amount" - SBCTATrBudgetLedgerEntry."Accrued Amount";
        // We need code here  to look up the targets for the budget spend category and also to track with  a flowfield possibly how much of the category is used.
        SBCTATradeAccrualLine.Init();
        SBCTATradeAccrualLine."Trade Accrual Line No." := SBCTATradeAccrualLine.GetNewLineNo(Rec."Trade Accrual No.");
        SBCTATradeAccrualLine."Trade Accrual No." := Rec."Trade Accrual No.";
        SBCTATradeAccrualLine."T/L Ledger Entry No." := SBCTAIndirectCOGsLedger."Entry No.";
        SBCTATradeAccrualLine."Dimension Set ID" := SBCTAIndirectCOGsLedger."Dimension Set ID";
        SBCTATradeAccrualLine."T/L Amount" := SBCTAIndirectCOGsLedger."Trade Budget Amount";
        SBCTATradeAccrualLine."T/L Posting Date" := SBCTAIndirectCOGsLedger."Posting Date";
        SBCTATradeAccrualLine."Calculation Method" := SBCTAIndirectCOGsLedger."Calculation Method";
        SBCTATradeAccrualLine."Accrued Amount" := SBCTAIndirectCOGsLedger."Accrued Amount";
        SBCTATradeAccrualLine."Calculation Basis" := SBCTAIndirectCOGsLedger."Calculation Basis";
        SBCTATradeAccrualLine."Over Budget" := SBCTAIndirectCOGsLedger."Over Budget";
        SBCTATradeAccrualLine."Trade Budget Code" := SBCTAIndirectCOGsLedger."Trade Budget Code";
        SBCTATradeAccrualLine."Trade Budget Rate Code" := SBCTAIndirectCOGsLedger."Trade Budget Rate Code";
        SBCTATradeAccrualLine."Trade Budget Rate Code ID" := SBCTAIndirectCOGsLedger."Trade Budget Rate Code ID";
        SBCTATradeAccrualLine."Account No." := SBCTAIndirectCOGsLedger."Account No.";
        if not SBCTATradeAccrualLine.Insert(true) then
            exit;
        SBCTAIndirectCOGsLedger."Trade Accrual No." := SBCTATradeAccrualLine."Trade Accrual No.";
        SBCTAIndirectCOGsLedger."Trade Accrual Line No." := SBCTATradeAccrualLine."Trade Accrual Line No.";
        SBCTAIndirectCOGsLedger.Modify();
        // SBCTATrBudgetLedgerEntry."Accrued Amount" += AccruedAmount;
    end;
    /// <summary>
    /// This function is used to set the appropriate filters on the Accrual Line to Return Trade Ledger Entries and not Indirect Trade Ledger ENtries.
    /// </summary>
    /// <param name="SBCTATradeAccrualLine">VAR Record "SBCTA Trade Accrual Line".</param>
    /// <returns>Return variable Found of type Boolean.</returns>
    internal procedure GetTradeAccrualLines(var SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line") Found: Boolean
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeAccrualLine.SetRange("Trade Accrual No.", Rec."Trade Accrual No.");
        if not SBCTATradeBudgetOptions.GetOptions()."Create Indirect Credit" then
            SBCTATradeAccrualLine.SetFilter("Calculation Method", '%1|%2', "SBCTA COGs Calc Type"::"Gross Sale", "SBCTA COGs Calc Type"::"Discount Only");
        Found := not SBCTATradeAccrualLine.IsEmpty();
    end;

    internal procedure GetIndirectCOGSAccrualLines(var SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line") Found: Boolean
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeAccrualLine.SetRange("Trade Accrual No.", Rec."Trade Accrual No.");
        SBCTATradeAccrualLine.SetRange("Calculation Method", "SBCTA COGs Calc Type"::"Cost Only");
        Found := not SBCTATradeAccrualLine.IsEmpty();
    end;

    internal procedure SetDateFilter(DateAccrualFilter: Text)
    begin
        GlobalAccrualDateFilter := DateAccrualFilter;
    end;

    internal procedure SetJournalPostingDate(JournalPostingDate: Date)
    begin
        GlobalJournalPostingDate := JournalPostingDate;
    end;

    internal procedure CreateAccrualJournalEntries(var TempGenJournalLine: Record "Gen. Journal Line" temporary; AccrualType: enum "SBCTA Accrual Type")
    var
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        CurrentGroupCode: Code[20];
        LastGroupCode: Code[20];
        CurrentCustomerNo: Code[20];
        LastCustomerNo: Code[20];
        CurrentRateCode: Code[20];
        LastRateCode: Code[20];
        JournalLineNo: Integer;
        PostingAccount: Code[20];
        BalanceAccount: Code[20];
        SignFactor: Integer;
        BlankGuid: Guid;
        SBCTAIDGuid: Guid;
        PostingAccountGenJournalAccountType: Enum "Gen. Journal Account Type";
        CustomerCreditType: Boolean;
        JournalPostingDate: Date;
        AccrualLinesFound: Boolean;
    begin
        if not AccrualRecordExists() then
            exit;
        SBCTATradeAccrualLine.SetFilter("Accrual Journal Line", '%1', 0);
        SBCTATradeBudgetOptions := SBCTATradeBudgetOptions.GetOptions();
        SignFactor := -1;
        case AccrualType of
            "SBCTA Accrual Type"::"Trade Spend":
                begin
                    if SBCTATradeBudgetOptions."Disable Solution" then
                        Error('The Trade solution is DISABLED. Please ENABLE the solution in the Trade options page to proceed');
                    AccrualLinesFound := Rec.GetTradeAccrualLines(SBCTATradeAccrualLine);
                    GenJournalBatch := SBCTATradeBudgetOptions.GetDirectTradeJournalBatch();
                end;

            "SBCTA Accrual Type"::"Indirect COGs Spend":
                begin
                    AccrualLinesFound := Rec.GetIndirectCOGSAccrualLines(SBCTATradeAccrualLine);
                    GenJournalBatch := SBCTATradeBudgetOptions.GetIndirectCogsJournalBatch();
                end;
        end;
        if not AccrualLinesFound then
            if not GlobalSuppressAlerts then
                Error(ErrorInfo.Create(StrSubstNo(NoValidAccrualLinesLabel, Rec."Trade Accrual No."), true, Rec))
            else
                exit;

        JournalTemplateName := GenJournalBatch."Journal Template Name";
        JournalBatchName := GenJournalBatch.Name;
        SBCTATradeAccrualLine.SetCurrentKey("Account No.", "T/L Posting Date");
        if GlobalAccrualDateFilter <> '' then
            SBCTATradeAccrualLine.SetFilter("T/L Posting Date", GlobalAccrualDateFilter);
        if not SBCTATradeAccrualLine.FindSet() then
            exit;

        repeat
            CustomerCreditType := (SBCTATradeBudgetOptions."Credit Type" = SBCTATradeBudgetOptions."Credit Type"::Customer) and (AccrualType = "SBCTA Accrual Type"::"Trade Spend") and (SBCTATradeAccrualLine."Calculation Method" <> "SBCTA COGs Calc Type"::"Discount Only"); // This type is only allowed for Trade Spend;
            if CustomerCreditType then
                PostingAccountGenJournalAccountType := PostingAccountGenJournalAccountType::"Customer"
            else
                PostingAccountGenJournalAccountType := PostingAccountGenJournalAccountType::"G/L Account";

            TempGenJournalLine.Reset();
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            case true of
                not TempGenJournalLine.IsEmpty():
                    begin
                        TempGenJournalLine.FindLast();
                        JournalLineNo := TempGenJournalLine."Line No." + 10000
                    end;
                else
                    JournalLineNo := GenJournalLine.GetNewLineNo(JournalTemplateName, JournalBatchName);
            end;

            TempGenJournalLine.CopyFilters(GenJournalLine);
            // GenJournalLineTemp.Reset();
            case AccrualType of
                "SBCTA Accrual Type"::"Trade Spend":
                    begin
                        SBCTATrBudgetLedgerEntry := SBCTATradeAccrualLine.GetTradeLedgerEntry();
                        CurrentRateCode := SBCTATrBudgetLedgerEntry."Trade Budget Rate Code";
                        CurrentGroupCode := SBCTATrBudgetLedgerEntry."Group Code";
                        CurrentCustomerNo := SBCTATrBudgetLedgerEntry."Customer No.";
                    end;
                "SBCTA Accrual Type"::"Indirect COGs Spend":
                    begin
                        SBCTAIndirectCOGsLedger := SBCTATradeAccrualLine.GetIndirectCOGsLedgerEntry();
                        CurrentRateCode := SBCTAIndirectCOGsLedger."Trade Budget Rate Code";
                        CurrentGroupCode := SBCTAIndirectCOGsLedger."Group Code";
                    end;
            end;
            // SBCTATrBudgetLedgerEntry := SBCTATradeAccrualLine.GetTradeLedgerEntry();
            if GlobalJournalPostingDate <> 0D then begin

                JournalPostingDate := GlobalJournalPostingDate;
                TempGenJournalLine.SetFilter("Posting Date", '%1', JournalPostingDate); // Lock summarized entries to the same posting date
            end else
                JournalPostingDate := SBCTATrBudgetLedgerEntry."Posting Date";
            TempGenJournalLine.SetFilter("Account Type", '%1', PostingAccountGenJournalAccountType); // Lock summarized entries to the same posting type
            // if (LastGroupCode <> SBCTATrBudgetLedgerEntry."Group Code") or (LastRateCode <> SBCTATrBudgetLedgerEntry."Trade Budget Rate Code") or (CustomerCreditType and (LastCustomerNo <> SBCTATrBudgetLedgerEntry."Customer No.")) then
            if (LastGroupCode <> CurrentGroupCode) or (LastRateCode <> CurrentRateCode) or ((LastCustomerNo <> CurrentCustomerNo)) then
                case AccrualType of
                    "SBCTA Accrual Type"::"Trade Spend":
                        SBCTATrBudgetLedgerEntry.GetPostingGLAccounts(PostingAccount, BalanceAccount);
                    "SBCTA Accrual Type"::"Indirect COGs Spend":
                        SBCTAIndirectCOGsLedger.GetPostingGLAccounts(PostingAccount, BalanceAccount);
                end;
            // SBCTATrBudgetLedgerEntry.GetPostingGLAccounts(PostingAccount, BalanceAccount);
            if CustomerCreditType then begin
                PostingAccount := SBCTATrBudgetLedgerEntry.GetGroupingCustomer(); // Changed this to not pull the same data twice.
                if PostingAccount = '' then
                    PostingAccount := SBCTATradeAccrualLine."Account No.";
                TempGenJournalLine.SetFilter("Account No.", '%1', PostingAccount);
            end;
            if SBCTATradeBudgetOptions."Summarize Accrual Postings" then
                TempGenJournalLine.SetFilter(Description, '%1', SBCTATradeAccrualLine.GetPostingDescription());
            LastGroupCode := CurrentGroupCode;
            LastRateCode := CurrentRateCode;
            if CustomerCreditType then
                LastCustomerNo := CurrentCustomerNo;
            GenJournalLine.CopyFilters(TempGenJournalLine);
            // Use this as a buffer so we can do our consolidation before transfer.
            if TempGenJournalLine.IsEmpty() and GenJournalLine.IsEmpty() then begin
                TempGenJournalLine.SetRange(Description);
                // GenJournalLineTemp.InitNewLine(JournalPostingDate, WorkDate(), JournalPostingDate, SBCTATradeAccrualLine.GetPostingDescription(), SBCTATrBudgetLedgerEntry."Shortcut Dimension 1 Code", SBCTATrBudgetLedgerEntry."Shortcut Dimension 2 Code", SBCTATradeAccrualLine."Dimension Set ID", '');
                TempGenJournalLine.InitNewLine(JournalPostingDate, WorkDate(), JournalPostingDate, SBCTATradeAccrualLine.GetPostingDescription(), '', '', 0, '');
                TempGenJournalLine."Line No." := JournalLineNo;
                TempGenJournalLine."Journal Template Name" := JournalTemplateName;
                TempGenJournalLine."Journal Batch Name" := JournalBatchName;
                TempGenJournalLine."SBCTA ID" := CreateGuid();
                TempGenJournalLine."Account Type" := PostingAccountGenJournalAccountType;
                TempGenJournalLine."Account No." := PostingAccount;
                TempGenJournalLine."Bal. Account Type" := TempGenJournalLine."Account Type"::"G/L Account";
                TempGenJournalLine."Bal. Account No." := BalanceAccount;
                TempGenJournalLine.Amount += (SignFactor * SBCTATradeAccrualLine."Accrued Amount");
                TempGenJournalLine.Insert(true);
                // if (IsNullGuid(GenJournalLineTemp.SystemId)) then begin
                //     TempJournalLineToSystemIDDisctionary.Add(GenJournalLineTemp."Line No.", CreateGuid());
                //     // GenJournalLineTemp.Modify();
                // end else
                //     TempJournalLineToSystemIDDisctionary.Add(GenJournalLineTemp."Line No.", GenJournalLineTemp.SystemId);
                SBCTATradeAccrualLine."Accrual Journal Template" := JournalTemplateName;
                SBCTATradeAccrualLine."Accrual Journal Batch" := JournalBatchName;
                SBCTATradeAccrualLine."Journal Line Id" := TempGenJournalLine."SBCTA ID";
                SBCTATradeAccrualLine.Modify();
            end else begin

                if not TempGenJournalLine.FindFirst() then begin
                    GenJournalLine.FindFirst();

                    GenJournalLine.Validate(Amount, GenJournalLine.Amount + (SignFactor * SBCTATradeAccrualLine."Accrued Amount"));
                    GenJournalLine.Modify();

                    // SBCTATradeAccrualLine.UpdateAccrualFromJournalLine(GenJournalLine);
                    // SBCTATradeAccrualLine."Accrual Journal Template" := JournalTemplateName;
                    // SBCTATradeAccrualLine."Accrual Journal Batch" := JournalBatchName;
                    // SBCTATradeAccrualLine."Journal Line Id" := SBCTAIDGuid;
                    SBCTATradeAccrualLine."Accrual Journal Template" := JournalTemplateName;
                    SBCTATradeAccrualLine."Accrual Journal Batch" := JournalBatchName;
                    SBCTATradeAccrualLine."Journal Line Id" := GenJournalLine."SBCTA ID";
                    SBCTATradeAccrualLine."Accrual Document No." := GenJournalLine."Document No.";
                    SBCTATradeAccrualLine."Accrual Journal Line" := GenJournalLine."Line No.";
                    SBCTATradeAccrualLine.Modify();
                    // GenJournalLine.TransferFields(TempGenJournalLine);
                    // GenJournalLine.Delete();
                end else begin

                    TempGenJournalLine.Amount += (SignFactor * SBCTATradeAccrualLine."Accrued Amount");
                    TempGenJournalLine.Modify();
                    SBCTATradeAccrualLine."Accrual Journal Template" := JournalTemplateName;
                    SBCTATradeAccrualLine."Accrual Journal Batch" := JournalBatchName;
                    SBCTATradeAccrualLine."Journal Line Id" := TempGenJournalLine."SBCTA ID";
                    SBCTATradeAccrualLine.Modify();
                end;
            end;
        // SBCTATradeAccrualLine."Accrual Journal Template" := JournalTemplateName;
        // SBCTATradeAccrualLine."Accrual Journal Batch" := JournalBatchName;
        // SBCTATradeAccrualLine."Journal Line Id" := SBCTAIDGuid;

        until SBCTATradeAccrualLine.Next() = 0;

        TempGenJournalLine.Reset();
        // Commit();
        // CreateAccrualJournalFromTempBuffer(GenJournalLine, GenJournalLineTemp);
    end;

    trigger OnDelete()
    begin
        CheckPostedAccrualLines();
        DeleteTradeAccrualLines();
        DeleteIndirectCOGSAccrualLines();
    end;

    local procedure AccrualRecordExists() Exists: Boolean
    begin
        if Rec."Trade Accrual No." = 0 then
            exit;
        Rec.SetRecFilter();
        Exists := not Rec.IsEmpty();
    end;

    local procedure GetTradeAccrualJournalDocumentNo(GenJournalLine: Record "Gen. Journal Line") TradeAccrualDocumentNo: Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalBatch.SetRange("Name", GenJournalLine."Journal Batch Name");
        GenJournalBatch.SetFilter("No. Series", '<>%1', '');
        if GenJournalBatch.IsEmpty() then
            exit;
        GenJournalBatch.SetLoadFields("No. Series");
        GenJournalBatch.FindFirst();
        TradeAccrualDocumentNo := NoSeriesManagement.GetNextNo(GenJournalBatch."No. Series", WorkDate(), true);
    end;

    local procedure CheckPostedAccrualLines()
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        PostedLinesExist: Boolean;
    begin
        SBCTATradeAccrualLine.SetRange(Posted, true);
        // if not Rec.GetTradeAccrualLines(SBCTATradeAccrualLine) then
        //     exit;
        PostedLinesExist := Rec.GetTradeAccrualLines(SBCTATradeAccrualLine);
        if not PostedLinesExist then
            PostedLinesExist := Rec.GetIndirectCOGSAccrualLines(SBCTATradeAccrualLine);
        if not PostedLinesExist then
            exit;
        Error(ErrorInfo.Create(DeletePostedEntriesLabel, true, Rec));
    end;

    local procedure DeleteTradeAccrualLines()
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        if not Rec.GetTradeAccrualLines(SBCTATradeAccrualLine) then
            exit;
        SBCTATradeAccrualLine.DeleteAll(true);
    end;

    local procedure DeleteIndirectCOGSAccrualLines()
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        if not Rec.GetIndirectCOGsAccrualLines(SBCTATradeAccrualLine) then
            exit;
        SBCTATradeAccrualLine.DeleteAll(true);
    end;

    // [ErrorBehavior(ErrorBehavior::Collect)]
    // internal procedure CreateAccrualJournalFromTempBuffer(var GenJournalLineTemp: Record "Gen. Journal Line" temporary)
    // var
    //     GenJournalLine: Record "Gen. Journal Line";
    //     SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    //     TradeAccrualDocumentNo: Code[20];
    // begin
    //     if GenJournalLineTemp.IsEmpty() then
    //         Error(ErrorInfo.Create(StrSubstNo(NoValidAccrualLinesLabel, Rec."Trade Accrual No."), true, Rec));
    //     GenJournalLineTemp.FindSet();
    //     // GenJournalBatch.Get(GenJournalLineTemp."Journal Batch Name", GenJournalLineTemp."Journal Template Name");
    //     if GenJournalLineTemp."Account Type" = GenJournalLineTemp."Account Type"::"G/L Account" then
    //         TradeAccrualDocumentNo := GetTradeAccrualJournalDocumentNo(GenJournalLineTemp);
    //     repeat
    //         if GenJournalLineTemp."Account Type" = GenJournalLineTemp."Account Type"::Customer then
    //             TradeAccrualDocumentNo := GetTradeAccrualJournalDocumentNo(GenJournalLineTemp);
    //         GenJournalLine.InitNewLine(GenJournalLineTemp."Posting Date", GenJournalLineTemp."Document Date", GenJournalLineTemp."VAT Reporting Date", GenJournalLineTemp.Description, GenJournalLineTemp."Shortcut Dimension 1 Code", GenJournalLineTemp."Shortcut Dimension 2 Code", GenJournalLineTemp."Dimension Set ID", GenJournalLineTemp."Reason Code");
    //         GenJournalLine."Journal Template Name" := GenJournalLineTemp."Journal Template Name";
    //         GenJournalLine."Journal Batch Name" := GenJournalLineTemp."Journal Batch Name";
    //         GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GenJournalLineTemp."Journal Template Name", GenJournalLineTemp."Journal Batch Name");
    //         GenJournalLine."SBCTA ID" := GenJournalLineTemp."SBCTA ID";
    //         GenJournalLine."Account Type" := GenJournalLineTemp."Account Type";
    //         GenJournalLine."Account No." := GenJournalLineTemp."Account No.";
    //         GenJournalLine."Bal. Account Type" := GenJournalLineTemp."Bal. Account Type";
    //         GenJournalLine."Bal. Account No." := GenJournalLineTemp."Bal. Account No.";
    //         GenJournalLine.Validate(Amount, Round(GenJournalLineTemp.Amount));
    //         if GenJournalLine.Amount <= 0 then
    //             GenJournalLine."Document Type" := GenJournalLine."Document Type"::"Credit Memo"
    //         else
    //             GenJournalLine."Document Type" := GenJournalLine."Document Type"::"Invoice";
    //         GenJournalLine."Document No." := TradeAccrualDocumentNo;
    //         if GenJournalLine.Insert(true) then
    //             SBCTATradeAccrualLine.UpdateAccrualFromJournalLine(GenJournalLine);
    //     until GenJournalLineTemp.Next() = 0;
    //     if GlobalSuppressAlerts then
    //         exit;
    //     if not GuiAllowed() then
    //         exit;
    //     Message(TradeAccrualCompleteMessageLabel);
    // end;

    internal procedure CreateAccrualJournalFromTempBuffer(var GenJournalLineTemp: Record "Gen. Journal Line" temporary)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        TradeAccrualDocumentNo: Code[20];
    begin
        if GenJournalLineTemp.IsEmpty() then
            Error(ErrorInfo.Create(StrSubstNo(NoValidAccrualLinesLabel, Rec."Trade Accrual No."), true, Rec));
        //ProcessTempBuffer(GenJournalLineTemp);
        GenJournalLineTemp.Reset();
        if GenJournalLineTemp.IsEmpty() then
            exit;
        GenJournalLineTemp.FindSet();
        // GenJournalBatch.Get(GenJournalLineTemp."Journal Batch Name", GenJournalLineTemp."Journal Template Name");
        if GenJournalLineTemp."Account Type" = GenJournalLineTemp."Account Type"::"G/L Account" then
            TradeAccrualDocumentNo := GetTradeAccrualJournalDocumentNo(GenJournalLineTemp);
        repeat
            if GenJournalLineTemp."Account Type" = GenJournalLineTemp."Account Type"::Customer then
                TradeAccrualDocumentNo := GetTradeAccrualJournalDocumentNo(GenJournalLineTemp);
            GenJournalLine.InitNewLine(GenJournalLineTemp."Posting Date", GenJournalLineTemp."Document Date", GenJournalLineTemp."VAT Reporting Date", GenJournalLineTemp.Description, GenJournalLineTemp."Shortcut Dimension 1 Code", GenJournalLineTemp."Shortcut Dimension 2 Code", GenJournalLineTemp."Dimension Set ID", GenJournalLineTemp."Reason Code");
            GenJournalLine."Journal Template Name" := GenJournalLineTemp."Journal Template Name";
            GenJournalLine."Journal Batch Name" := GenJournalLineTemp."Journal Batch Name";
            GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GenJournalLineTemp."Journal Template Name", GenJournalLineTemp."Journal Batch Name");
            GenJournalLine."SBCTA ID" := GenJournalLineTemp."SBCTA ID";
            GenJournalLine."Account Type" := GenJournalLineTemp."Account Type";
            GenJournalLine."Account No." := GenJournalLineTemp."Account No.";
            GenJournalLine."Bal. Account Type" := GenJournalLineTemp."Bal. Account Type";
            GenJournalLine."Bal. Account No." := GenJournalLineTemp."Bal. Account No.";
            GenJournalLine.Validate(Amount, Round(GenJournalLineTemp.Amount));
            if GenJournalLine.Amount <= 0 then begin
                // GenJournalLine.Validate(Amount, GenJournalLine.Amount * -1);
                // GenJournalLine."Document Type" := GenJournalLine."Document Type"::"Credit Memo";
            end
            else
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::"Invoice";
            GenJournalLine."Document No." := TradeAccrualDocumentNo;
            if GenJournalLine.Insert(true) then
                SBCTATradeAccrualLine.UpdateAccrualFromJournalLine(GenJournalLine);
        until GenJournalLineTemp.Next() = 0;
        if GlobalSuppressAlerts then
            exit;
        if not GuiAllowed() then
            exit;
        Message(TradeAccrualCompleteMessageLabel);
    end;

    internal procedure AccrualLinesExist() Exist: Boolean
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        Exist := Rec.GetTradeAccrualLines(SBCTATradeAccrualLine) or Rec.GetIndirectCOGSAccrualLines(SBCTATradeAccrualLine);
    end;

}