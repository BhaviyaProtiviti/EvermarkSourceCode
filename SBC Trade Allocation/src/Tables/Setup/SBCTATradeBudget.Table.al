/// <summary>
/// This table is where Trade Budgets will be defined so that Trade Budget Rates can be applied to them.
/// </summary>
table 50201 "SBCTA Trade Budget"
{
    Caption = 'Trade Budget';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Trade Budget Code"; Code[20])
        {
            Caption = 'Trade Budget Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Trade Budget and set of rates associated with it.';
        }
        field(2; "Description"; Text[200])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'A brief description of the purpose of the trade budget.';
        }
        field(3; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
            Description = 'The date that the budget is first active.';
        }
        field(4; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
            Description = 'The date that the budget is last allowed to be active.';
        }
        field(5; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            Description = 'If this is set, the budget can be used for the specified date range.';
        }
        field(6; "Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Group that the Trade Budget Rate applies to.';
            TableRelation = IF ("Group Type" = CONST(Customer)) "Customer Posting Group"
            ELSE
            IF ("Group Type" = CONST(Item)) "Item Category";
        }
        field(7; "Group Type"; Enum "SBCTA Budget Group Type")
        {
            Caption = 'Group Type';
            DataClassification = CustomerContent;
            Description = 'This is the type of Group that the budget is for.';
        }
        field(8; "Archived"; Boolean)
        {
            Caption = 'Archived';
            DataClassification = CustomerContent;
            Description = 'If this is set, the budget is no longer active and cannot be used.';
        }

        field(9; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            Description = 'This dimension value can be used to match instead of the Group Code.';

        }

        field(10; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code WHERE("SBC Enable Indirect Cost" = Const(true));
            Description = 'When this is set, a specfic budget for a location can be used. If this is not set, then the budget can be used for all locations.';
        }

        field(11; "Item Ledger Entry Type"; Text[1024])
        {
            Caption = 'Item Ledger Entry Type Filter';
            Description = 'This is used to make the application of this budget more granular.';
            trigger OnValidate()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                ValidateFieldFilter(ItemLedgerEntry.FieldNo("Entry Type"), Rec."Item Ledger Entry Type");
            end;
        }

        field(12; "Item Ledger Document Type"; Text[1024])
        {
            Caption = 'Item Ledger Document Type Filter';
            Description = 'This is used in combination with the Item Ledger Entry Type to make the application of this budget more granular.';
            trigger OnValidate()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                ValidateFieldFilter(ItemLedgerEntry.FieldNo("Document Type"), Rec."Item Ledger Document Type");
            end;
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure".Code;
            Description = 'This is used in combination with the other Item Ledger Entry granularity fields to apply this budget only when the item ledger matches the values set in these fields.';
        }

        field(14; "Use Item Category Matching"; Boolean)
        {
            Caption = 'Use Item Category Matching';
            Description = 'When this is set, the Item Category will also be used with Dimension Matching, if enabled, to further narrow down budget usage.';
        }

    }
    keys
    {
        key(PK; "Trade Budget Code")
        {
            Clustered = true;
        }
        key(Sorting; "Group Type", "Shortcut Dimension 1 Code")
        {
            Description = 'Sorting Key';
        }
    }
    trigger OnInsert()
    begin
        CheckBudgetDateOverlap(true, Rec);
    end;

    trigger OnModify()
    begin
        CheckBudgetDateOverlap(true, Rec);
    end;

    trigger OnDelete()
    begin
        CheckActualAmount();
        DeleteRates();
    end;

    trigger OnRename()
    begin
        RenameRates();
    end;

    internal procedure CheckBudgetDateOverlap(Enabled: Boolean; CheckBudget: Record "SBCTA Trade Budget")
    var
        SBCTATradeBudget: Record "SBCTA Trade Budget";
    begin
        if CheckBudget.Archived then
            exit;
        SBCTATradeBudget.SetFilter("Trade Budget Code", '<>%1', CheckBudget."Trade Budget Code");
        SBCTATradeBudget.SetRange("Group Type", CheckBudget."Group Type");
        SBCTATradeBudget.SetRange("Group Code", CheckBudget."Group Code");
        SBCTATradeBudget.SetRange("Shortcut Dimension 1 Code", CheckBudget."Shortcut Dimension 1 Code");
        SBCTATradeBudget.SetRange(Enabled, Enabled);
        SBCTATradeBudget.SetFilter("End Date", '>=%1', CheckBudget."Start Date");
        SBCTATradeBudget.SetFilter("Start Date", '<=%1', CheckBudget."End Date");
        // May need to add additional conditions here to prevent overlap.
        if (CheckBudget."Group Type" = "SBCTA Budget Group Type"::Item) and (CheckBudget."Location Code" <> '') then begin
            SBCTATradeBudget.SetRange("Location Code", CheckBudget."Location Code");
            SBCTATradeBudget.SetRange("Unit of Measure Code", CheckBudget."Unit of Measure Code");
            SBCTATradeBudget.SetRange("Item Ledger Document Type", CheckBudget."Item Ledger Document Type");
            SBCTATradeBudget.SetRange("Item Ledger Entry Type", CheckBudget."Item Ledger Entry Type");
        end;
        if SBCTATradeBudget.IsEmpty() then
            exit;

        Error(TradeBudgetOverlapErrorLabel);
    end;

    local procedure GetTradeBudgetRates(var SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates"; TradeBudgetCode: Code[20]) Found: Boolean
    begin
        if TradeBudgetCode = '' then
            exit;
        SBCTATradeBudgetRates.SetRange("Trade Budget Code", TradeBudgetCode);
        Found := not SBCTATradeBudgetRates.IsEmpty();
    end;

    local procedure RenameRates()
    var
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        if not GetTradeBudgetRates(SBCTATradeBudgetRates, xRec."Trade Budget Code") then
            exit;
        SBCTATradeBudgetRates.FindSet(true);
        repeat
            SBCTATradeBudgetRates.Rename(Rec."Trade Budget Code", SBCTATradeBudgetRates."Trade Budget Rate Code");
        until SBCTATradeBudgetRates.Next() = 0;
    end;

    local procedure DeleteRates()
    var
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponse(DeleteBudgetandRatesQST, false) then
            exit;
        if not GetTradeBudgetRates(SBCTATradeBudgetRates, Rec."Trade Budget Code") then
            exit;
        SBCTATradeBudgetRates.DeleteAll();
    end;

    local procedure CheckActualAmount()
    var
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        SBCTATradeBudgetRates.SetFilter("Trade Budget Actual", '<>%1', 0);
        if not GetTradeBudgetRates(SBCTATradeBudgetRates, Rec."Trade Budget Code") then
            exit;
        Error(ErrorInfo.Create(AmountsAllocatedError, true, Rec));
    end;

    local procedure ValidateFieldFilter(FieldNo: Integer; FieldFilter: Text[1024])
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open(Database::"Item Ledger Entry");
        if FieldFilter <> '' then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.SetFilter(FieldFilter);
        end;
    end;
    // internal procedure UpdateActualAmount(TradeBudgetRateCode : Code[20]; UpdateAmount : Decimal) NewActualTotal : Decimal
    // var 
    //      SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    // begin
    //        if Rec."Trade Budget Code" = '' then
    //            exit;
    //        if TradeBudgetRateCode = '' then
    //            exit;
    //        SBCTATradeBudgetRates.SetRange("Trade Budget Code", Rec."Trade Budget Code");
    //        SBCTATradeBudgetRates.SetRange("Trade Budget Rate Code",TradeBudgetRateCode);
    // end;
    var
        TradeBudgetOverlapErrorLabel: Label 'The date range overlaps with another Enabled Trade Budget.';
        DeleteBudgetandRatesQST: Label 'Are you sure you want to delete this Trade Budget and its Trade Budget Rates?';
        AmountsAllocatedError: Label 'This Budget has accrued amounts posted against it and cannot be deleted.';

}