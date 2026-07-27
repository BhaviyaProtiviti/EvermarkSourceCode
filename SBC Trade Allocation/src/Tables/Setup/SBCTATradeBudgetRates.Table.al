/// <summary>
/// This table 
/// </summary>
table 50202 "SBCTA Trade Budget Rates"
{
    Caption = 'Trade Rates';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Trade Budget Code"; Code[20])
        {
            Caption = 'Trade Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Trade Budget and set of rates associated with it.';
            TableRelation = "SBCTA Trade Budget"."Trade Budget Code";
        }
        field(2; "Trade Budget Rate Code"; Code[20])
        {
            Caption = 'Trade Rate Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';
            TableRelation = "SBCTA Trade Budget Rate Codes"."Trade Budget Rate Code";
        }
        field(3; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
            TableRelation = "Customer Posting Group"."Code";
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'This field allows for granular rates to be set for a particular customer within a Customer Posting Group.';
            TableRelation = Customer."No.";
        }
        field(5; "Trade Budget Rate Type"; Enum "SBCTA Tr. Budget Rate Type")
        {
            Caption = 'Trade Rate Type';
            InitValue = Percent;
            DataClassification = CustomerContent;
            Description = 'This code identifies the type of Trade Budget Rate.';
        }
        field(6; "Trade Budget Rate"; Decimal)
        {
            Caption = 'Trade Rate';
            DataClassification = CustomerContent;
            Description = 'This is the rate that will be applied to the Customer Price Group.';
            DecimalPlaces = 2 : 5;
        }
        field(7; "Trade Budget Target"; Decimal)
        {
            Caption = 'Trade Target Amount';
            DataClassification = CustomerContent;
            Description = 'The dollar amount that this budget is not to be allocated beyond.';
        }
        field(8; "Trade Budget Actual"; Decimal)
        {
            Caption = 'Trade Actual Amount';
            DataClassification = CustomerContent;
            Description = 'The actual dollar value allocated against this budget.';
        }
        field(9; "Calculation Basis"; Enum "SBCTA Calc. Basis Type")
        {
            Caption = 'Calculation Basis';
            DataClassification = CustomerContent;
            Description = 'This is the calculation type for this record.';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Description = 'This field allows for granular rates to be set for a particular Item.';
            TableRelation = Item."No.";
        }
    }
    keys
    {
        key(PK; "Trade Budget Code", "Trade Budget Rate Code", "Item No.")
        {
            Clustered = true;
        }
    }


    trigger OnDelete()
    begin
        CheckActualAmount();
    end;

    var
        CannotDeleteAllocatedRateError: Label 'Trade Budget Codes that have been allocated against this budget cannot be deleted.';

    internal procedure GetAmount(ValueAmount: Decimal; ValuedQuantity: Decimal; AmountConversionFactor: Decimal; SBCTACalcBasisType: Enum "SBCTA Calc. Basis Type") TradeBudgetAmount: Decimal
    var
        Currency: Record Currency;
        SignFactor: Integer;
        ExtendedAmount: Decimal;
    begin
        ExtendedAmount := ValueAmount * ValuedQuantity;
        if ExtendedAmount = 0 then
            exit;
        // Currency.InitRoundingPrecision();
        if ExtendedAmount < 0 then
            SignFactor := -1
        else
            SignFactor := 1;

        case "Trade Budget Rate Type" of
            "Trade Budget Rate Type"::Percent:
                TradeBudgetAmount := Round((ExtendedAmount * Rec."Trade Budget Rate") / 100, 0.00001);
            "Trade Budget Rate Type"::Amount:
                // TradeBudgetAmount := Round((SignFactor * (ValuedQuantity / AmountConversionFactor) * Rec."Trade Budget Rate"), 0.00001); // This is done so that base quantity can be converted to the same unit of measure as the trade budget rate.
                TradeBudgetAmount := Round(((ValuedQuantity / AmountConversionFactor) * Rec."Trade Budget Rate"), 0.00001); // This is done so that base quantity can be converted to the same unit of measure as the trade budget rate.
        end;
        if SBCTACalcBasisType <> SBCTACalcBasisType::COGS then
            exit;
        TradeBudgetAmount *= -1;
    end;

    internal procedure GetRateCode() SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes"
    begin
        if Rec."Trade Budget Rate Code" = '' then
            exit;
        if not SBCTATradeBudgetRateCodes.Get(Rec."Trade Budget Rate Code") then
            exit;
    end;

    // local procedure GetTradeBudgetRates(var SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates") Found: Boolean
    // begin
    //     if Rec."Trade Budget Code" = '' then
    //         exit;
    //     SBCTATradeBudgetRates.SetRange("Trade Budget Code", Rec."Trade Budget Code");
    //     Found := not SBCTATradeBudgetRates.IsEmpty();
    // end;

    // local procedure RenameRates()
    // var
    //     SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    // begin
    //     if not GetTradeBudgetRates(SBCTATradeBudgetRates) then
    //         exit;
    //     SBCTATradeBudgetRates.FindSet(true);
    //     repeat
    //         SBCTATradeBudgetRates.Rename(Rec."Trade Budget Code");
    //     until SBCTATradeBudgetRates.Next() = 0;
    // end;

    // local procedure DeleteRates()
    // var
    //     SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    //     ConfirmManagement: Codeunit "Confirm Management";
    // begin
    //     if not ConfirmManagement.GetResponse(DeleteBudgetandRatesQST, false) then
    //         exit;
    //     if not GetTradeBudgetRates(SBCTATradeBudgetRates) then
    //         exit;
    //     SBCTATradeBudgetRates.DeleteAll(true);
    // end;

    local procedure CheckActualAmount()
    var
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        If Rec."Trade Budget Actual" = 0 then
            exit;
        Error(ErrorInfo.Create(CannotDeleteAllocatedRateError, true, Rec));
    end;

    internal procedure UpdateTradeBudgetActual(var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry"; IgnoreTradeTarget: Boolean) NewBudgetActual: Decimal
    var
        RemainingBudgetAmount: Decimal;
        TradeBudgetRateAmount: Decimal;
        UpdateAmount: Decimal;
    begin
        // Rec.SetRecFilter();
        // if Rec.IsEmpty() then
        //     if Rec."Trade Budget Code" = '' then
        //         exit;
        // if Rec."Trade Budget Rate Code" = '' then
        //     exit;
        // // exit;
        // Rec.Find();
        TradeBudgetRateAmount := SBCTATrBudgetLedgerEntry."Trade Budget Amount";
        if not IgnoreTradeTarget then begin
            RemainingBudgetAmount := Rec."Trade Budget Target" - Rec."Trade Budget Actual";
            if RemainingBudgetAmount <= 0 then begin
                NewBudgetActual := Rec."Trade Budget Actual";
                SBCTATrBudgetLedgerEntry."Over Budget" := true;
                SBCTATrBudgetLedgerEntry.Modify();
                exit;
            end;
        end;

        // if RemainingBudgetAmount >= TradeBudgetRateAmount then
        //     UpdateAmount := TradeBudgetRateAmount
        // else
        //     UpdateAmount := RemainingBudgetAmount;

        case true of
            IgnoreTradeTarget:
                UpdateAmount := TradeBudgetRateAmount;
            (RemainingBudgetAmount >= TradeBudgetRateAmount):
                UpdateAmount := TradeBudgetRateAmount;
            else
                UpdateAmount := RemainingBudgetAmount;
        end;

        SBCTATrBudgetLedgerEntry."Accrued Amount" := UpdateAmount;
        // if UpdateAmount <> TradeBudgetRateAmount then
        SBCTATrBudgetLedgerEntry."Over Budget" := UpdateAmount <> TradeBudgetRateAmount;

        SBCTATrBudgetLedgerEntry.Modify();

        Rec."Trade Budget Actual" += UpdateAmount;
        Rec.Modify();
        NewBudgetActual := Rec."Trade Budget Actual";
    end;

    internal procedure UpdateIndirectCogsBudgetActual(var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger"; IgnoreTradeTarget: Boolean) NewBudgetActual: Decimal
    var
        RemainingBudgetAmount: Decimal;
        TradeBudgetRateAmount: Decimal;
        UpdateAmount: Decimal;
    begin
        Rec.SetRecFilter();
        if Rec.IsEmpty() then
            if Rec."Trade Budget Code" = '' then
                exit;
        if Rec."Trade Budget Rate Code" = '' then
            exit;
        // exit;
        Rec.Find();
        TradeBudgetRateAmount := -SBCTAIndirectCOGsLedger."Trade Budget Amount"; // Reverse these entries show they are show as positives against the budget. It's is a credit budget, not a debit budget.
        RemainingBudgetAmount := Rec."Trade Budget Target" - Rec."Trade Budget Actual";
        if RemainingBudgetAmount <= 0 then begin
            NewBudgetActual := Rec."Trade Budget Actual";
            SBCTAIndirectCOGsLedger."Over Budget" := true;
            SBCTAIndirectCOGsLedger.Modify();
            if not IgnoreTradeTarget then
                exit;
        end;

        // if IgnoreTradeTarget or (RemainingBudgetAmount >= TradeBudgetRateAmount) then
        //     UpdateAmount := TradeBudgetRateAmount
        // else
        //     UpdateAmount := RemainingBudgetAmount;

        case true of
            IgnoreTradeTarget, (RemainingBudgetAmount >= TradeBudgetRateAmount):
                UpdateAmount := TradeBudgetRateAmount;
            else
                UpdateAmount := RemainingBudgetAmount;
        end;

        SBCTAIndirectCOGsLedger."Accrued Amount" := -UpdateAmount; //flip it going back in, as well
        if UpdateAmount <> TradeBudgetRateAmount then
            SBCTAIndirectCOGsLedger."Over Budget" := true;

        SBCTAIndirectCOGsLedger.Modify();

        Rec."Trade Budget Actual" += UpdateAmount;
        Rec.Modify();
        NewBudgetActual := Rec."Trade Budget Actual";
    end;

    internal procedure ReverseTradeBudgetActual(var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry") NewBudgetActual: Decimal
    var
        RemainingBudgetAmount: Decimal;
        TradeBudgetRateAmount: Decimal;
    begin
        Rec.SetRecFilter();
        if Rec.IsEmpty() then
            // if Rec."Trade Budget Code" = '' then
                exit;
        // if Rec."Trade Budget Rate Code" = '' then
        //     exit;
        // exit;
        // Rec.Find();
        TradeBudgetRateAmount := SBCTATrBudgetLedgerEntry."Accrued Amount";
        RemainingBudgetAmount := Rec."Trade Budget Actual" - TradeBudgetRateAmount;
        // if RemainingBudgetAmount <= 0 then begin
        // NewBudgetActual := Rec."Trade Budget Actual";
        // SBCTATrBudgetLedgerEntry."Over Budget" := true;
        // SBCTATrBudgetLedgerEntry.Modify();
        // exit;
        // end;
        if RemainingBudgetAmount <= 0 then
            RemainingBudgetAmount := 0;

        // if RemainingBudgetAmount >= TradeBudgetRateAmount then
        //     UpdateAmount := TradeBudgetRateAmount
        // else
        //     UpdateAmount := RemainingBudgetAmount;

        SBCTATrBudgetLedgerEntry."Accrued Amount" -= TradeBudgetRateAmount;
        SBCTATrBudgetLedgerEntry."Over Budget" := false;
        SBCTATrBudgetLedgerEntry.Modify();

        Rec."Trade Budget Actual" := RemainingBudgetAmount;
        Rec.Modify();
        NewBudgetActual := Rec."Trade Budget Actual";
    end;

    internal procedure ReverseIndirectCOGsBudgetActual(var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger") NewBudgetActual: Decimal
    var
        RemainingBudgetAmount: Decimal;
        TradeBudgetRateAmount: Decimal;
    begin
        Rec.SetRecFilter();
        if Rec.IsEmpty() then
            // if Rec."Trade Budget Code" = '' then
                exit;
        // if Rec."Trade Budget Rate Code" = '' then
        //     exit;
        // exit;
        // Rec.Find();
        TradeBudgetRateAmount := -SBCTAIndirectCOGsLedger."Accrued Amount"; //Flip coming out of the ledger

        RemainingBudgetAmount := Rec."Trade Budget Actual" - TradeBudgetRateAmount;
        // if RemainingBudgetAmount <= 0 then begin
        // NewBudgetActual := Rec."Trade Budget Actual";
        // SBCTATrBudgetLedgerEntry."Over Budget" := true;
        // SBCTATrBudgetLedgerEntry.Modify();
        // exit;
        // end;
        // if RemainingBudgetAmount <= 0 then
        //     RemainingBudgetAmount := 0;

        // if RemainingBudgetAmount >= TradeBudgetRateAmount then
        //     UpdateAmount := TradeBudgetRateAmount
        // else
        //     UpdateAmount := RemainingBudgetAmount;

        SBCTAIndirectCOGsLedger."Accrued Amount" += TradeBudgetRateAmount; // Flipped when zeroing out accrual.
        SBCTAIndirectCOGsLedger."Over Budget" := false;
        SBCTAIndirectCOGsLedger.Modify();

        Rec."Trade Budget Actual" := RemainingBudgetAmount;
        Rec.Modify();
        NewBudgetActual := Rec."Trade Budget Actual";
    end;
}