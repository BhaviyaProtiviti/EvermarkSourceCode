/// <summary>
/// Table SBCTA Tr. Budget Ledger Entry (ID 50206).
/// </summary>
table 50206 "SBCTA Tr. Budget Ledger Entry"
{
    Caption = 'Trade Ledger Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            BlankZero = true;
        }
        field(2; "G/L Entry No."; Integer)
        {
            Caption = 'G/L Entry No.';
            DataClassification = CustomerContent;
            Description = 'This is the G/L Entry No. that this entry is associated with. This will only be set for A/R entries.';
            BlankZero = true;
        }
        field(3; "Value Entry No."; Integer)
        {
            Caption = 'Value Entry No.';
            DataClassification = CustomerContent;
            Description = 'This is the Value Entry that this entry is associated with. This will only be set for COGS entries.';
            BlankZero = true;
        }

        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Description = 'This is the Posting Date of the G/L Entry that this entry is associated with.';
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
            Description = 'This code identifies the particular Trade Budget Rate Code associated with the Trade Budget and further instructions on how it should be applied.';

        }
        field(13; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'This is the document number that this entry is associated with.';
        }
        field(14; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Description = 'This is the type of document that this entry is associated with.';
        }
        field(15; "Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Group that the Trade Budget Rate applies to.';

            TableRelation = IF ("Group Type" = CONST(Customer)) "Customer Posting Group"
            ELSE
            IF ("Group Type" = CONST(Item)) "Item Category";
        }
        field(16; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'If a customer-specific Trade Budget Rate was used, the Customer No. will be listed here.';
            TableRelation = Customer."No.";

        }

        field(17; "Trade Budget Amount"; Decimal)
        {
            Caption = 'Trade Amount';
            DataClassification = CustomerContent;
            Description = 'This is the total amount of the Trade Budget that was used for this entry.';
            BlankZero = true;
        }


        field(18; "Source Entry Amount"; Decimal)
        {
            Caption = 'Source Entry Amount';
            DataClassification = CustomerContent;
            Description = 'This is the Amount of the basis entry that was used for Trade Ledger entry.';
            BlankZero = true;
        }

        field(19; "Trade Accrual No."; Integer)
        {
            Caption = 'Trade Header No.';
            DataClassification = SystemMetadata;

            Description = 'This is the Trade Accrual that this Trade Accrual Line was produced for.';
            TableRelation = "SBCTA Trade Accrual Header"."Trade Accrual No.";
            BlankZero = true;
        }
        field(20; "Trade Accrual Line No."; Integer)
        {
            Caption = 'Trade Line No.';
            DataClassification = SystemMetadata;
            BlankZero = true;
            Description = 'This is the line number of this Trade Accrual Line.';
        }
        field(21; "Accrued Amount"; Decimal)
        {
            Caption = 'Accrued Amount';
            DataClassification = CustomerContent;
            Description = 'This is the amount that was transferred to the accrual entry.';
            BlankZero = true;
        }
        field(22; "Over Budget"; Boolean)
        {
            Caption = 'Over Budget';
            DataClassification = CustomerContent;
            Description = 'This is a flag that indicates if the entry was over budget and either partially accrued or not accrued.';
        }
        field(23; "Calculation Basis"; Enum "SBCTA Calc. Basis Type")
        {
            Caption = 'Calculation Basis';
            DataClassification = CustomerContent;
            Description = 'This is the calculation type for this record.';
        }
        field(24; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));


        }
        field(25; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

        }

        field(26; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            BlankZero = true;
        }
        field(27; "Group Type"; Enum "SBCTA Budget Group Type")
        {
            Caption = 'Group Type';
            DataClassification = CustomerContent;
            Description = 'This is the type of Group that this Trade Ledger Entry was produced for.';
        }

        field(28; "Calculation Method"; Enum "SBCTA COGs Calc Type")
        {
            Caption = 'Calculation Method';
            DataClassification = CustomerContent;
            Description = 'The calculation method used to calculate the COGs for the trade budget rate code.';

        }
        field(29; "Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Sales Amount (Actual)';
            BlankZero = true;
        }
        field(30; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount (Actual)';
            BlankZero = true;
        }

        field(31; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount Amount';
            BlankZero = true;
        }

        field(32; "Trade Budget Rate ID"; Guid)
        {
            Caption = 'Trade Rate ID';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';

        }

        field(33; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Description = 'This is the Item number that this entry is associated with.';
            TableRelation = Item."No.";
            Caption = 'Item No.';
        }

        field(34; "Shortcut Dimension 1 Name"; Text[50])
        {
            CaptionClass = '1,2,1, , Name';
            Caption = 'Shortcut Dimension 1 Name';
            TableRelation = "Dimension Value".Name WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));


        }
        field(35; "Shortcut Dimension 2 Name"; Text[50])
        {
            CaptionClass = '1,2,2,, Name';
            Caption = 'Shortcut Dimension 2 Name';
            TableRelation = "Dimension Value".Name WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

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
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(BudgetCode; "Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.")
        {
            Description = 'Search key';
            MaintainSqlIndex = true;
            Unique = true;

        }
        // key(Customer; "Customer No.")
        // {
        //     Description = 'Search key';
        // }
        // key(CustomerPostingGroup; "Group Code")
        // {
        //     Description = 'Search key';
        // }
    }


    var
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GlobalFromValueEntry: Boolean;
        GlobalReprocessEntry: Boolean;
        GlobalGroupCode: Code[20];
        GlobalSBCTABudgetGroupType: Enum "SBCTA Budget Group Type";

    // internal procedure CreateLedgerEntry(TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; TradeBudgetRateCodeGuid: Guid; TradeBudgetRateGuid: Guid; LedgerEntryNo: Integer; DocumentNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date; CustomerNo: Code[20]; TradeBudgetAmount: Decimal; GlEntryAmount: Decimal; DimensionSetID: Integer; ShortcutDimensionCode1: Code[20]; ShortcutDimensionCode2: Code[20]; DocumentLineNo: Integer; SalesAmount: Decimal; CostAmount: Decimal; DiscountAmount: Decimal; ItemNo: Code[20]) Created: Boolean
    internal procedure CreateLedgerEntry(SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates"; ValueEntry: Record "Value Entry"; TradeBudgetAmount: Decimal; LedgerAmount: Decimal; SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes") Created: Boolean
    var
        // GLEntry: Record "G/L Entry";
        // ValueEntry: Record "Value Entry";
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
        SignFactor: Integer;
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
    begin
        // SBCTATrBudgetLedgerEntry.Init();
        // if GlobalReprocessEntry and GlobalFromValueEntry then begin
        //     case true of
        //         TradeBudgetEntryExistsForValueEntry(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCode):
        //             SetTradeEntryFiltersForVE(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCode, SBCTATrBudgetLedgerEntry);
        //         TradeBudgetEntryExistsForValueEntry(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCodeGuid):
        //             SetTradeEntryFiltersForVE(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCodeGuid, SBCTATrBudgetLedgerEntry);
        //     end;
        //     SBCTATrBudgetLedgerEntry.FindFirst();
        // end;

        // if not GlobalFromValueEntry then begin
        //     SBCTATrBudgetLedgerEntry."G/L Entry No." := LedgerEntryNo
        // else
        //     SBCTATrBudgetLedgerEntry."Value Entry No." := LedgerEntryNo;
        // if GlobalReprocessEntry and GlobalFromValueEntry then
        //     SBCTATrBudgetLedgerEntry := Rec;

        // SBCTATrBudgetLedgerEntry."Value Entry No." := ValueEntry."Entry No.";
        // SignFactor := -1;

        // case GlobalFromValueEntry of
        //     true:
        //         begin
        //             SBCTATrBudgetLedgerEntry."Value Entry No." := ValueEntry."Entry No.";
        //             SignFactor := -1;
        //         end;
        // false:
        //     begin
        //         SBCTATrBudgetLedgerEntry."G/L Entry No." := LedgerEntryNo;
        //         SignFactor := 1;
        //     end;
        // end;
        if GlobalReprocessEntry and GlobalFromValueEntry then
            SBCTATrBudgetLedgerEntry := Rec
        else
            SBCTATrBudgetLedgerEntry.Init();

        SBCTATrBudgetLedgerEntry."Value Entry No." := ValueEntry."Entry No.";
        SignFactor := -1;
        case ValueEntry."Document Type" of
            ValueEntry."Document Type"::"Sales Invoice", ValueEntry."Document Type"::"Purchase Invoice":
                GenJournalDocumentType := GenJournalDocumentType::Invoice;
            ValueEntry."Document Type"::"Sales Credit Memo", ValueEntry."Document Type"::"Purchase Credit Memo":
                GenJournalDocumentType := GenJournalDocumentType::"Credit Memo";
        end;
        SBCTATrBudgetLedgerEntry."Trade Budget Code" := SBCTATradeBudgetRates."Trade Budget Code";
        SBCTATrBudgetLedgerEntry."Trade Budget Rate Code" := SBCTATradeBudgetRates."Trade Budget Rate Code";
        SBCTATrBudgetLedgerEntry."Trade Budget Rate Code ID" := SBCTATradeBudgetRateCodes.SystemId;
        SBCTATrBudgetLedgerEntry."Trade Budget Rate ID" := SBCTATradeBudgetRates.SystemId;
        SBCTATrBudgetLedgerEntry."Document No." := ValueEntry."Document No.";
        SBCTATrBudgetLedgerEntry."Document Line No." := ValueEntry."Document Line No.";
        SBCTATrBudgetLedgerEntry."Document Type" := GenJournalDocumentType;
        SBCTATrBudgetLedgerEntry."Posting Date" := ValueEntry."Posting Date";
        SBCTATrBudgetLedgerEntry."Group Type" := GlobalSBCTABudgetGroupType;
        SBCTATrBudgetLedgerEntry."Group Code" := GlobalGroupCode;
        SBCTATrBudgetLedgerEntry."Customer No." := ValueEntry."Source No.";
        SBCTATrBudgetLedgerEntry."Calculation Basis" := GlobalSBCTATradeBudgetOptions."Calculation Basis";
        SBCTATrBudgetLedgerEntry."Calculation Method" := SBCTATradeBudgetRateCodes."Calculation Method";
        SBCTATrBudgetLedgerEntry."Trade Budget Amount" := TradeBudgetAmount;
        SBCTATrBudgetLedgerEntry."Source Entry Amount" := SignFactor * LedgerAmount;
        SBCTATrBudgetLedgerEntry."Sales Amount" := ValueEntry."Sales Amount (Actual)";
        SBCTATrBudgetLedgerEntry."Cost Amount" := SignFactor * ValueEntry."Cost Amount (Actual)";
        SBCTATrBudgetLedgerEntry."Discount Amount" := SignFactor * ValueEntry."Discount Amount";
        // if GlobalFromValueEntry then
        //     SBCTATrBudgetLedgerEntry."Source Entry Amount" *= -1;
        SBCTATrBudgetLedgerEntry."Dimension Set ID" := ValueEntry."Dimension Set ID";
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 1 Code" := ValueEntry."Global Dimension 1 Code";
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 2 Code" := ValueEntry."Global Dimension 2 Code";
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 1 Name" := GetDimensionValueName(ValueEntry."Global Dimension 1 Code", 1);
        SBCTATrBudgetLedgerEntry."Shortcut Dimension 2 Name" := GetDimensionValueName(ValueEntry."Global Dimension 2 Code", 2);
        SBCTATrBudgetLedgerEntry."Item No." := ValueEntry."Item No.";
        if GlobalReprocessEntry then
            Created := SBCTATrBudgetLedgerEntry.Modify(true)
        else
            Created := SBCTATrBudgetLedgerEntry.Insert(true);
    end;

    // internal procedure CreateLedgerEntryFromGLEntry(SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates"; GLEntry: Record "G/L Entry"; TradeBudgetAmount: Decimal) Created: Boolean
    // begin
    //     Created := CreateLedgerEntry(SBCTATradeBudgetRates."Trade Budget Code", SBCTATradeBudgetRates."Trade Budget Rate Code", SBCTATradeBudgetRates.GetRateCode()."SystemId", SBCTATradeBudgetRates.SystemId, GLEntry."Entry No.", GLEntry."Document No.", GLEntry."Document Type", GLEntry."Posting Date", GLEntry."Source No.", TradeBudgetAmount, GLEntry.Amount, GLEntry."Dimension Set ID", GLEntry."Global Dimension 1 Code", GLEntry."Global Dimension 2 Code", 0, GLEntry."Amount", 0, 0, '');
    // end;

    local procedure GetDimensionValueName(DimensionCode: Code[20]; ShortcutDimensionNumber: Integer) DimensionValueName: Text[50]
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetRange("Global Dimension No.", ShortcutDimensionNumber);
        DimensionValue.SetFilter("Code", '%1', DimensionCode);
        if DimensionValue.IsEmpty() then
            exit;
        DimensionValue.SetLoadFields(Name);
        DimensionValue.FindFirst();
        DimensionValueName := DimensionValue.Name;
    end;

    internal procedure CreateLedgerEntryFromValueEntry(SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates"; ValueEntry: Record "Value Entry"; TradeBudgetAmount: Decimal; LedgerAmount: Decimal; SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes") Created: Boolean
    var
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
    begin
        // Change(Purchase Document Types)
        // Change(Clone this table to COGs ledger)
        // todo(Replace this long method parameter list with a method on this object called GetValueEntry that returns the value entry for this record so we can set these values directly in the procedural method CreateLedgerEntry.)
        // case ValueEntry."Document Type" of
        //     ValueEntry."Document Type"::"Sales Invoice", ValueEntry."Document Type"::"Purchase Invoice":
        //         GenJournalDocumentType := GenJournalDocumentType::Invoice;
        //     ValueEntry."Document Type"::"Sales Credit Memo", ValueEntry."Document Type"::"Purchase Credit Memo":
        //         GenJournalDocumentType := GenJournalDocumentType::"Credit Memo";
        // end;
        GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        GlobalFromValueEntry := true;
        // Created := CreateLedgerEntry(SBCTATradeBudgetRates."Trade Budget Code", SBCTATradeBudgetRates."Trade Budget Rate Code", SBCTATradeBudgetRateCodes."SystemId", SBCTATradeBudgetRates.SystemId, ValueEntry."Entry No.", ValueEntry."Document No.", GenJournalDocumentType, ValueEntry."Posting Date", ValueEntry."Source No.", TradeBudgetAmount, LedgerAmount, ValueEntry."Dimension Set ID", ValueEntry."Global Dimension 1 Code", ValueEntry."Global Dimension 2 Code", ValueEntry."Document Line No.", ValueEntry."Sales Amount (Actual)", ValueEntry."Cost Amount (Actual)", ValueEntry."Discount Amount", ValueEntry."Item No.");
        Created := CreateLedgerEntry(SBCTATradeBudgetRates, ValueEntry, TradeBudgetAmount, LedgerAmount, SBCTATradeBudgetRateCodes);
        Clear(GlobalFromValueEntry);
    end;

    internal procedure TradeBudgetEntryExistsForGLEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: Guid) Exists: Boolean
    var
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        SetTradeEntryFiltersForGL(EntryNo, TradeBudgetCode, TradeBudgetRateCodeID, SBCTATrBudgetLedgerEntry);
        Exists := not SBCTATrBudgetLedgerEntry.IsEmpty();
    end;

    internal procedure TradeBudgetEntryExistsForValueEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: Guid) Exists: Boolean
    var
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        SetTradeEntryFiltersForVE(EntryNo, TradeBudgetCode, TradeBudgetRateCodeID, SBCTATrBudgetLedgerEntry);
        Exists := not SBCTATrBudgetLedgerEntry.IsEmpty();
    end;

    internal procedure TradeBudgetEntryExistsForGLEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]) Exists: Boolean
    var
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        SetTradeEntryFiltersForGL(EntryNo, TradeBudgetCode, TradeBudgetRateCode, SBCTATrBudgetLedgerEntry);
        Exists := not SBCTATrBudgetLedgerEntry.IsEmpty();
    end;

    internal procedure TradeBudgetEntryExistsForValueEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]) Exists: Boolean
    var
        SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry";
    begin
        SetTradeEntryFiltersForVE(EntryNo, TradeBudgetCode, TradeBudgetRateCode, SBCTATrBudgetLedgerEntry);
        Exists := not SBCTATrBudgetLedgerEntry.IsEmpty();
    end;

    internal procedure GetBudget() SBCTATradeBudget: Record "SBCTA Trade Budget";
    begin
        if Rec."Trade Budget Code" = '' then
            exit;
        if not SBCTATradeBudget.Get(Rec."Trade Budget Code") then
            exit;
    end;

    internal procedure GetItemLedgerEntry() ItemLedgerEntry: Record "Item Ledger Entry"
    begin
        if not ItemLedgerEntry.Get(Rec.GetValueEntry()."Item Ledger Entry No.") then
            exit;
    end;


    internal procedure GetValueEntry() ValueEntry: Record "Value Entry";
    begin
        if Rec."Value Entry No." = 0 then
            exit;
        if not ValueEntry.Get(Rec."Value Entry No.") then
            exit;
    end;

    internal procedure GetGLEntry() GLEntry: Record "G/L Entry";
    begin
        if Rec."G/L Entry No." = 0 then
            exit;
        if not GLEntry.Get(Rec."G/L Entry No.") then
            exit;
    end;

    internal procedure GetBudgetRate() SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        if IsNullGuid(Rec."Trade Budget Rate ID") then
            exit;
        if not SBCTATradeBudgetRates.GetBySystemId(Rec."Trade Budget Rate ID") then
            exit;
    end;

    internal procedure SetGroupCode(GroupType: Enum "SBCTA Budget Group Type"; GroupCode: Code[20])
    begin
        GlobalSBCTABudgetGroupType := GroupType;
        GlobalGroupCode := GroupCode;
    end;

    internal procedure RecreateEntry(Recreate: Boolean)
    begin
        GlobalReprocessEntry := Recreate;
        if not GlobalReprocessEntry then
            exit;
        Rec.FindFirst();
    end;

    internal procedure GetPostingGLAccounts(var PostingAccount: Code[20]; var BalanceAccount: Code[20])
    var
        SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        case Rec."Group Type" of
            "SBCTA Budget Group Type"::Customer:
                begin
                    if SBCTATradeBudgetSetup.GetCustomerSetup(Rec."Group Code", Rec."Customer No.",Rec."Shortcut Dimension 1 Code", Rec."Trade Budget Rate Code", SBCTATradeBudgetSetup) then begin //This is forcing me to use Shortcut Dimension 1 because it's already in the table.
                        SBCTATradeBudgetSetup.SetLoadFields("Posting Account", "Balance Account");
                        SBCTATradeBudgetSetup.FindFirst();
                    end;
                    PostingAccount := SBCTATradeBudgetSetup."Posting Account";
                    BalanceAccount := SBCTATradeBudgetSetup."Balance Account";
                end;
            "SBCTA Budget Group Type"::Item: // This is obsolete and should never be used.
                begin
                    if SBCTAIndirectPostingSetup.GetItemSetup(Rec."Group Code", Rec.GetItemLedgerEntry()."Item No.", Rec."Trade Budget Rate Code", SBCTAIndirectPostingSetup,'') then begin
                        SBCTAIndirectPostingSetup.SetLoadFields("Posting Account", "Balance Account");
                        SBCTAIndirectPostingSetup.FindFirst();
                    end;
                    PostingAccount := SBCTAIndirectPostingSetup."Posting Account";
                    BalanceAccount := SBCTAIndirectPostingSetup."Balance Account";
                end;
        end;
    end;


    internal procedure GetGroupingCustomer() CustomerNo: Code[20]
    var
        SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        SBCTATradeBudgetSetup.SetFilter("Grouping Customer No.", '<>%1', '');
        case Rec."Group Type" of
            "SBCTA Budget Group Type"::Customer:
                begin
                    if SBCTATradeBudgetSetup.GetCustomerSetup(Rec."Group Code", Rec."Customer No.", Rec."Trade Budget Rate Code", SBCTATradeBudgetSetup) then begin
                        SBCTATradeBudgetSetup.SetLoadFields("Grouping Customer No.");
                        SBCTATradeBudgetSetup.FindFirst();
                        CustomerNo := SBCTATradeBudgetSetup."Grouping Customer No.";
                    end;
                end;
            "SBCTA Budget Group Type"::Item: // This is obsolete and should never be used.
                begin
                    if SBCTAIndirectPostingSetup.GetItemSetup(Rec."Group Code", Rec.GetItemLedgerEntry()."Item No.", Rec."Trade Budget Rate Code", SBCTAIndirectPostingSetup,'') then begin
                        SBCTATradeBudgetSetup.SetLoadFields("Grouping Customer No.");
                        SBCTAIndirectPostingSetup.FindFirst();
                        CustomerNo := SBCTATradeBudgetSetup."Grouping Customer No.";
                    end;
                end;
        end;
    end;

    local procedure SetTradeEntryFiltersForGL(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: GUID; var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry")
    begin
        SBCTATrBudgetLedgerEntry.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.");
        SBCTATrBudgetLedgerEntry.SetRange("G/L Entry No.", EntryNo);
        SBCTATrBudgetLedgerEntry.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTATrBudgetLedgerEntry.SetFilter("Trade Budget Rate Code ID", '%1', TradeBudgetRateCodeID);
    end;

    local procedure SetTradeEntryFiltersForVE(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: GUID; var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry")
    begin
        SBCTATrBudgetLedgerEntry.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.");
        SBCTATrBudgetLedgerEntry.SetRange("Value Entry No.", EntryNo);
        SBCTATrBudgetLedgerEntry.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTATrBudgetLedgerEntry.SetFilter("Trade Budget Rate Code ID", '%1', TradeBudgetRateCodeID);
    end;

    local procedure SetTradeEntryFiltersForGL(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry")
    begin
        SBCTATrBudgetLedgerEntry.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.");
        SBCTATrBudgetLedgerEntry.SetRange("G/L Entry No.", EntryNo);
        SBCTATrBudgetLedgerEntry.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTATrBudgetLedgerEntry.SetFilter("Trade Budget Rate Code", '%1', TradeBudgetRateCode);
    end;

    internal procedure SetTradeEntryFiltersForVE(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; var SBCTATrBudgetLedgerEntry: Record "SBCTA Tr. Budget Ledger Entry")
    begin
        SBCTATrBudgetLedgerEntry.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Customer No.");
        SBCTATrBudgetLedgerEntry.SetRange("Value Entry No.", EntryNo);
        SBCTATrBudgetLedgerEntry.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTATrBudgetLedgerEntry.SetFilter("Trade Budget Rate Code", '%1', TradeBudgetRateCode);
    end;
}