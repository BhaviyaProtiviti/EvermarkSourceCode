/// <summary>
/// This table contains the lines of the Budget Allocation run. This table will be used to provide a link between the Trade Budget Ledger Entry and the Budget Allocation Job.
/// </summary>
table 50205 "SBCTA Trade Accrual Line"
{
    Caption = 'Trade Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Trade Accrual No."; Integer)
        {
            Caption = 'Trade Accrual No.';
            DataClassification = SystemMetadata;

            Description = 'This is the Trade Accrual that this Trade Accrual Line was produced for.';
            BlankZero = true;
            TableRelation = "SBCTA Trade Accrual Header"."Trade Accrual No.";
        }
        field(2; "Trade Accrual Line No."; Integer)
        {
            Caption = 'Trade Accrual Line No.';
            DataClassification = SystemMetadata;

            Description = 'This is the line number of this Trade Accrual Line.';
            BlankZero = true;
        }
        field(3; "Calculation Basis"; Enum "SBCTA Calc. Basis Type")
        {
            Caption = 'Calculation Basis';
            DataClassification = CustomerContent;
            Description = 'This is the calculation type for this record.';
        }
        field(4; "T/L Ledger Entry No."; Integer)
        {
            Caption = 'T/L Ledger Entry No.';
            DataClassification = SystemMetadata;

            Description = 'This is the Trade Ledger Entry that this Trade Accrual Line was produced for.';
            TableRelation = "SBCTA Tr. Budget Ledger Entry"."Entry No.";
            BlankZero = true;

        }
        field(10; "Trade Budget Code"; Code[20])
        {
            Caption = 'Trade Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Trade Budget and set of rates associated with it.';
        }
        field(11; "Trade Budget Rate Code"; Code[20])
        {
            Caption = 'Trade Rate Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';

        }
        field(12; "Trade Budget Rate Code ID"; Guid)
        {
            Caption = 'Trade Rate Code ID';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';

        }
        field(19; "Accrued Amount"; Decimal)
        {
            Caption = 'Accrued Amount';
            DataClassification = CustomerContent;
            Description = 'This is the amount that was transferred to the accrual entry.';
            BlankZero = true;
        }
        field(20; "T/L Amount"; Decimal)
        {
            Caption = 'T/L Amount';
            DataClassification = CustomerContent;
            Description = 'This is the trade ledger amount associated with the accrual.';
            BlankZero = true;
        }
        field(21; "Over Budget"; Boolean)
        {
            Caption = 'Over Budget';
            DataClassification = CustomerContent;
            Description = 'This is a flag that indicates if the entry was over budget and either partially accrued or not accrued.';
        }
        field(22; "Accrual Document No."; Code[20])
        {
            Caption = 'Accrual Document No';
            DataClassification = CustomerContent;
            Description = 'This is the document number of the accrual.';
        }
        field(23; "Accrual Journal Template"; Code[10])
        {
            Caption = 'Trade Journal Template';
            DataClassification = CustomerContent;
            Description = 'This is the journal template that was used to create the accrual.';
        }
        field(24; "Accrual Journal Batch"; Code[10])
        {
            Caption = 'Trade Journal Batch';
            DataClassification = CustomerContent;
            Description = 'This is the journal batch that was used to create the accrual.';
        }
        field(25; "Accrual Journal Line"; Integer)
        {
            Caption = 'Trade Journal Line';
            DataClassification = CustomerContent;
            Description = 'This is the journal line that was used to create the accrual.';
            BlankZero = true;
        }
        field(26; "Journal Line Id"; Guid)
        {
            Caption = 'Journal Line Id';
            DataClassification = CustomerContent;
            Description = 'This is the journal line id that was used to create the accrual.';
        }
        field(30; "Posted"; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
            Description = 'This is a flag that indicates if the accrual was posted.';
            // Set this with a trigger event on post.
        }

        field(31; "Account No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'If a customer-specific Trade Budget Rate was used, the Customer No. will be listed here.';
            TableRelation = Customer."No.";

        }
        field(32; "T/L Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Description = 'This is the Posting Date of the T/L Entry that this accrual entry is associated with.';
        }
        field(33; "Calculation Method"; Enum "SBCTA COGs Calc Type")
        {
            Caption = 'Calculation Method';
            DataClassification = CustomerContent;
            Description = 'The calculation method used to calculate the COGs for the trade budget rate code.';

        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            BlankZero = true;
        }

    }
    keys
    {
        key(PK; "Trade Accrual No.", "Trade Accrual Line No.")
        {
            Clustered = true;
        }

        key(Customer; "Account No.", "T/L Posting Date")
        {
            Description = 'Sorting filter';
            MaintainSqlIndex = true;
        }

        key(DimSetId; "Dimension Set ID")
        {
            Description = 'Sorting filter';
            MaintainSqlIndex = true;
        }
        // key(PostingDate; "T/L Posting Date")
        // {
        //        Description = 'Sorting filter';
        // }
    }

    trigger OnDelete()
    begin
        CheckPostedStatus();
        ReverseUnpostedTradeAccrual();
        ReverseUnpostedIndirectCOGsAccrual();
    end;

    var
        PostingDescriptionLabel: Label '%1 - %2', Locked = true;
        PostedTradeAccrualLineError: Label 'You cannot delete a posted Trade Accrual Line.';

    internal procedure GetTradeLedgerEntry() SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        SBCTATrBudgetLedgerEntry.SetRange("Entry No.", "T/L Ledger Entry No.");
        SBCTATrBudgetLedgerEntry.SetFilter("Calculation Method",'%1|%2',"SBCTA COGs Calc Type"::"Gross Sale","SBCTA COGs Calc Type"::"Discount Only");
        if SBCTATrBudgetLedgerEntry.IsEmpty then
            exit;
        SBCTATrBudgetLedgerEntry.FindFirst();
    end;

    internal procedure GetIndirectCOGsLedgerEntry() SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
    begin
        SBCTAIndirectCOGsLedger.SetRange("Entry No.", "T/L Ledger Entry No.");
        SBCTAIndirectCOGsLedger.SetRange("Calculation Method","SBCTA COGs Calc Type"::"Cost Only");
        if SBCTAIndirectCOGsLedger.IsEmpty then
            exit;
        SBCTAIndirectCOGsLedger.FindFirst();
    end;

    internal procedure GetPostingDescription() PostingDescription: Text[100]
    begin
        if Rec."Trade Budget Code" = '' then
            exit;
        if Rec."Trade Budget Rate Code" = '' then
            exit;
        PostingDescription := StrSubstNo(PostingDescriptionLabel, Rec."Trade Budget Code", Rec."Trade Budget Rate Code");
    end;

    internal procedure UpdateAccrualFromJournalLine(GenJournalLine: Record "Gen. Journal Line")
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        SBCTATradeAccrualLine.SetFilter("Journal Line Id", '%1', GenJournalLine."SBCTA ID");
        if SBCTATradeAccrualLine.IsEmpty() then
            exit;
        SBCTATradeAccrualLine.ModifyAll("Accrual Journal Line", GenJournalLine."Line No.");
        SBCTATradeAccrualLine.ModifyAll("Accrual Document No.", GenJournalLine."Document No.");
    end;

    internal procedure ClearAccrualFromJournalLine(GenJournalLine: Record "Gen. Journal Line")
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        BlankGuid: Guid;
    begin
        SBCTATradeAccrualLine.SetFilter("Journal Line Id", '%1', GenJournalLine."SBCTA ID");
        SBCTATradeAccrualLine.SetRange(Posted, false);
        if SBCTATradeAccrualLine.IsEmpty() then
            exit;
        SBCTATradeAccrualLine.ModifyAll("Accrual Journal Template", '');
        SBCTATradeAccrualLine.ModifyAll("Accrual Journal Batch", '');
        SBCTATradeAccrualLine.ModifyAll("Accrual Journal Line", 0);
        SBCTATradeAccrualLine.ModifyAll("Accrual Document No.", '');
        SBCTATradeAccrualLine.ModifyAll("Journal Line Id", BlankGuid);
    end;

    internal procedure SetPostedFromJournalLine(GenJournalLine: Record "Gen. Journal Line")
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
        BlankGuid: Guid;
    begin
        SBCTATradeAccrualLine.SetFilter("Journal Line Id", '%1', GenJournalLine."SBCTA ID");
        if SBCTATradeAccrualLine.IsEmpty() then
            exit;
        SBCTATradeAccrualLine.ModifyAll(Posted, true);
    end;

    internal procedure GetNewLineNo(TradeAccrualNo: Integer): Integer
    var
        SBCTATradeAccrualLine: Record "SBCTA Trade Accrual Line";
    begin
        SBCTATradeAccrualLine.SetRange("Trade Accrual No.", TradeAccrualNo);
        if SBCTATradeAccrualLine.FindLast() then
            exit(SBCTATradeAccrualLine."Trade Accrual Line No." + 10);
        exit(10);
    end;

    local procedure CheckPostedStatus()
    begin
        if not Rec.Posted then
            exit;
        error(ErrorInfo.Create(PostedTradeAccrualLineError, true, Rec));
    end;

    local procedure ReverseUnpostedTradeAccrual()
    var
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        SBCTATrBudgetLedgerEntry := Rec.GetTradeLedgerEntry();
        if SBCTATrBudgetLedgerEntry."Entry No." = 0 then
            exit;
        SBCTATradeBudgetRates := SBCTATrBudgetLedgerEntry.GetBudgetRate();
        SBCTATradeBudgetRates.ReverseTradeBudgetActual(SBCTATrBudgetLedgerEntry);
        SBCTATrBudgetLedgerEntry."Trade Accrual No." := 0;
        SBCTATrBudgetLedgerEntry."Trade Accrual Line No." := 0;
        SBCTATrBudgetLedgerEntry.Modify();
    end;

    local procedure ReverseUnpostedIndirectCOGsAccrual()
    var
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        SBCTAIndirectCOGsLedger := Rec.GetIndirectCOGsLedgerEntry();
        if SBCTAIndirectCOGsLedger."Entry No." = 0 then
            exit;
        SBCTATradeBudgetRates := SBCTAIndirectCOGsLedger.GetBudgetRate();
        SBCTATradeBudgetRates.ReverseIndirectCOGsBudgetActual(SBCTAIndirectCOGsLedger);
        SBCTAIndirectCOGsLedger."Trade Accrual No." := 0;
        SBCTAIndirectCOGsLedger."Trade Accrual Line No." := 0;
        SBCTAIndirectCOGsLedger.Modify();
    end;

    internal procedure GetTradePostingSetup() SBCTATradePostingSetup: Record "SBCTA Trade Budget Setup"
    begin

    end;
}