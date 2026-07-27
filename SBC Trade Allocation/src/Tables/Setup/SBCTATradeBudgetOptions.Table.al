/// <summary>
/// Table SBCTA Trade Budget Options (ID 50208).
/// </summary>
table 50208 "SBCTA Trade Budget Options"
{
    Caption = 'Trade Options';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Key"; Code[1])
        {
            Caption = 'Key';
        }
        field(2; "Auto-Post Trade Accrual"; Boolean)
        {
            Caption = 'Auto-Post Trade';
            Description = 'When this is set, Trade Budget Ledger Entries will be created after each successful Sales Posting.';
            InitValue = true;
        }
        field(3; "Auto-Post Sales Credits"; Boolean)
        {
            Caption = 'Auto-Post Trade Reversals';
            Description = 'When this is set, Trade Budget Ledger Entries will be created after each successful Sales Credit Memo Posting.';
            InitValue = true;
        }
        field(4; "Summarize Accrual Postings"; Boolean)
        {
            Caption = 'Summarize Trade Accruals';
            Description = 'When this is set, Trade Budget Ledger Entries will be Budget Rate Code.';
            InitValue = true;
        }
        field(5; "Calculation Basis"; Enum "SBCTA Calc. Basis Type")
        {
            Caption = 'Calculation Basis';
            DataClassification = CustomerContent;
            Description = 'This is the source of the calculation for Trade Ledger entries. COGs is per item calculation and A/R is per invoice calculation.';
            InitValue = "COGs";
        }
        field(6; "Accrual Journal Template"; Code[10])
        {
            Caption = 'Trade Journal Template';
            Description = 'The Journal Template to use when creating Accrual Journal Lines.';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(7; "Accrual Batch Name"; Text[10])
        {
            Caption = 'Direct Trade Batch Name';
            Description = 'The Batch Name to use when creating Accrual Journal Lines.';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Accrual Journal Template"));

        }
        field(8; "Customer Type"; Enum "SBCTA Customer Type")
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            Description = 'Setting this will accrue trade spend from the selected customer type.';
            InitValue = "Sell-To";
        }
        field(9; "Credit Type"; Enum "SBCTA Credit Type")
        {
            Caption = 'Credit Type';
            DataClassification = CustomerContent;
            Description = 'This options determines if accrual credits are created against the Posting Account in the Trade Posting Setup and Indirect Cost Posting Setup or against the Customer the trade spend was generated for.';
            InitValue = "Customer";
        }
        field(10; "Create Indirect Credit"; Boolean)
        {
            Caption = 'Create Indirect Spend Credit';
            DataClassification = CustomerContent;
            Description = 'When this is set, Credits for Direct and Indirect Spend will be created. When this is not set, only Direct Spend credits will be created.';
            InitValue = false;
        }

        field(11; "Allow Direct Posting"; Boolean)
        {
            Caption = 'Allow Direct Posting';
            DataClassification = CustomerContent;
            Description = 'When this is set, direct posting is allowed in the General Journal for Trade Ledger Journal Entries.';
            InitValue = true;
        }

        field(12; "Swap Receivables Account"; Boolean)
        {
            Caption = 'Swap Receivables Account';
            DataClassification = CustomerContent;
            Description = 'When this is set, the Receivables Account will be swapped for the Posting Account when posting a trade accrual credit.';
            InitValue = true;
        }

        field(13; "Ignore Trade Target"; Boolean)
        {
            Caption = 'Ignore Trade Target';
            DataClassification = CustomerContent;
            Description = 'When this is set, the Trade Target will be ignored when calculating Trade Accruals.';
            InitValue = true;
        }

        field(14; "Use Dimension Matching"; Boolean)
        {
            Caption = 'Use Dimension Matching';
            DataClassification = CustomerContent;
            Description = 'When this is set, Indirect COGs will be matched based on the dimension value rather than the item category code.';
            InitValue = true;
        }

        field(15; "Indirect COGs Batch"; Code[10])
        {
            Caption = 'Indirect COGs Batch Name';
            Description = 'The Journal Batch to use when creating Indirect COGs Journals.';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Accrual Journal Template"));
        }

        field(16; "Burden Purchase Receipts"; Boolean)
        {
            Caption = 'Burden Purchase Receipts';
            Description = 'When this is set, Indirect COGs will be based on Purchase Receipts and Purchase Return Shipments rather than Invoices and Credits.';
        }
        field(17; "Skip Inbound IC Check"; Boolean)
        {
            Caption = 'Skip Inbound IC Check';
            Description = 'When this is set, a check for an appropriate inbound Indirect Cost Value Entry will not be checked for.';
        }
        field(18; "Auto-Post Indirect Cost"; Boolean)
        {
            Caption = 'Auto-Post Indirect Cost';
            Description = 'When this is set, Indirect Costs will be automatically posted to the G/L.';
            InitValue = true;
        }

        field(19; "Skip During Adjust Cost"; Boolean)
        {
            Caption = 'Skip During Adjust Cost';
            Description = 'When this is set, Indirect Cost Value Entries created by this solution will be skipped during the Adjust Cost process.';
            InitValue = true;
        }
        field(30; "Disable Solution"; Boolean)
        {
            Caption = 'Disable Solution';
            Description = 'When this is set, all event hooks will be disabled and the solution will not run. This is useful for testing and troubleshooting.';
            InitValue = true;
        }
        field(40; "Post Bracket Entries to GL"; Boolean)
        {
            Caption = 'Post Bracket Entries to GL';
            Description = 'When this is set, Bracket Entries will be posted to the G/L.';
            InitValue = true;
        }
        field(41; "Bracket Dimension Code"; Code[20])
        {
            Caption = 'Bracket Dimension Code';
            Description = 'This is the dimension code that will be used to post Bracket Entries to the G/L.';
            TableRelation = Dimension where(Blocked = const(false));
        }
        field(42;"Exclude Sales Indirect Cost"; Boolean)
        {
            Caption = 'Exclude Sales Indirect Cost';
            Description = 'When this is set, Sales Indirect Costs are excluded from Actual Cost during Adjust Cost.';
        }
        field(43;"Exclude Purchase Indirect Cost"; Boolean)
        {
            Caption = 'Exclude Purchase Indirect Cost';
            Description = 'When this is set, Purchase Indirect Costs are excluded from Actual Cost during Adjust Cost.';
        }

    }


    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }
    internal procedure AutoPostTradeAccrual() Enabled: Boolean;
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetRange("Auto-Post Trade Accrual", true);
        Enabled := not SBCTATradeBudgetOptions.IsEmpty();
    end;

    internal procedure AutoPostSalesCredits() Enabled: Boolean;
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetRange("Auto-Post Sales Credits", true);
        Enabled := not SBCTATradeBudgetOptions.IsEmpty();
    end;

    internal procedure SummarizeAccruals() Enabled: Boolean;
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetRange("Summarize Accrual Postings", true);
        Enabled := not SBCTATradeBudgetOptions.IsEmpty();
    end;

    internal procedure GetDirectTradeJournalBatch() GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(Rec."Accrual Journal Template", Rec."Accrual Batch Name");
    end;

    internal procedure GetOptions() SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetLoadFields(SystemModifiedAt);
        SBCTATradeBudgetOptions.FindFirst();
        if SBCTATradeBudgetOptions.SystemModifiedAt > Rec.SystemModifiedAt then
            Rec.Get();
        SBCTATradeBudgetOptions := Rec;
    end;

    internal procedure GetIndirectCogsJournalBatch() GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(Rec."Accrual Journal Template", Rec."Indirect COGs Batch");
    end;
}