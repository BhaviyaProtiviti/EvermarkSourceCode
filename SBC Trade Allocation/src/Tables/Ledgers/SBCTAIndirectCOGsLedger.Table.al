/// <summary>
/// Table SBCTA Indirect COGs Ledger (ID 50206).
/// </summary>
table 50210 "SBCTA Indirect COGs Ledger"
{
    Caption = 'Indirect COGs Ledger';
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
        field(14; "Document Type"; Enum "Item Ledger Document Type")
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
        field(16; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            Description = 'The Account No. used for the entry.';
            TableRelation = if ("Document Type" = const(" ")) Vendor."No." else
            if ("Document Type" = const("Purchase Invoice")) Vendor."No." else
            if ("Document Type" = const("Purchase Credit Memo")) Vendor."No." else
            Customer."No.";

        }

        field(17; "Trade Budget Amount"; Decimal)
        {
            Caption = 'Indirect Cost Amount';
            DataClassification = CustomerContent;
            Description = 'This is the total amount of the Trade Budget that was used for this entry.';
            BlankZero = true;
        }


        field(18; "Source Entry Amount"; Decimal)
        {
            Caption = 'Total Standard Cost';
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
            Caption = 'Sales Amount';
            BlankZero = true;
        }
        field(30; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount';
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

        field(40; "Value Entry Quantity"; Decimal)
        {
            Caption = 'Value Entry Quantity';
            DataClassification = CustomerContent;
            Description = 'This is the quantity of the Value Entry that this entry is associated with.';
            BlankZero = true;
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

        key(BudgetCode; "Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.")
        {
            Description = 'Search key';
            MaintainSqlIndex = true;

        }
        key(SumCalc; "Value Entry No.")
        {
            SumIndexFields = "Trade Budget Amount";
            MaintainSiftIndex = true;
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
        GlobalFromValueEntry: Boolean;
        GlobalReprocessEntry: Boolean;
        GlobalGroupCode: Code[20];
        GlobalSBCTABudgetGroupType: Enum "SBCTA Budget Group Type";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";

    // internal procedure CreateLedgerEntry(TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; TradeBudgetRateCodeGuid: Guid; TradeBudgetRateGuid: Guid; LedgerEntryNo: Integer; DocumentNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date; CustomerNo: Code[20]; TradeBudgetAmount: Decimal; GlEntryAmount: Decimal; DimensionSetID: Integer; ShortcutDimensionCode1: Code[20]; ShortcutDimensionCode2: Code[20]; DocumentLineNo: Integer; SalesAmount: Decimal; CostAmount: Decimal; DiscountAmount: Decimal; ItemNo: Code[20]) Created: Boolean
    internal procedure CreateLedgerEntry(SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates"; ValueEntry: Record "Value Entry"; TradeBudgetAmount: Decimal; LedgerAmount: Decimal; SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes") Created: Boolean
    var
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        // ValueEntry: Record "Value Entry";
        SignFactor: Integer;
    // GLEntry: Record "G/L Entry";
    begin
        // SBCTAIndirectCOGsLedger.Init();
        // if GlobalReprocessEntry and GlobalFromValueEntry then begin
        //     case true of
        //         TradeBudgetEntryExistsForValueEntry(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCodeGuid):
        //             SetCogsEntryFiltersForVE(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCodeGuid, SBCTAIndirectCOGsLedger);
        //         TradeBudgetEntryExistsForValueEntry(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCode):
        //             SetCogsEntryFiltersForVE(LedgerEntryNo, TradeBudgetCode, TradeBudgetRateCode, SBCTAIndirectCOGsLedger);
        //     end;
        //     SBCTAIndirectCOGsLedger.FindFirst();
        // end;

        // if not GlobalFromValueEntry then begin
        //     SBCTAIndirectCOGsLedger."G/L Entry No." := LedgerEntryNo
        // else
        //     SBCTAIndirectCOGsLedger."Value Entry No." := LedgerEntryNo;
        // case GlobalFromValueEntry of
        //     true:
        //         begin
        //             SBCTAIndirectCOGsLedger."Value Entry No." := LedgerEntryNo;
        //             SignFactor := -1;
        //         end;
        //     false:
        //         begin
        //             SBCTAIndirectCOGsLedger."G/L Entry No." := LedgerEntryNo;
        //             SignFactor := 1;
        //         end;
        if GlobalReprocessEntry and GlobalFromValueEntry then
            SBCTAIndirectCOGsLedger := Rec
        else
            SBCTAIndirectCOGsLedger.Init();


        SBCTAIndirectCOGsLedger."Value Entry No." := ValueEntry."Entry No.";
        SignFactor := -1;


        SBCTAIndirectCOGsLedger."Trade Budget Code" := SBCTATradeBudgetRates."Trade Budget Code";
        SBCTAIndirectCOGsLedger."Trade Budget Rate Code" := SBCTATradeBudgetRates."Trade Budget Rate Code";
        SBCTAIndirectCOGsLedger."Trade Budget Rate Code ID" := SBCTATradeBudgetRateCodes.SystemId;
        SBCTAIndirectCOGsLedger."Trade Budget Rate ID" := SBCTATradeBudgetRates.SystemId;
        SBCTAIndirectCOGsLedger."Document No." := ValueEntry."Document No.";
        SBCTAIndirectCOGsLedger."Document Line No." := ValueEntry."Document Line No.";
        SBCTAIndirectCOGsLedger."Document Type" := ValueEntry."Document Type";
        SBCTAIndirectCOGsLedger."Posting Date" := ValueEntry."Posting Date";
        SBCTAIndirectCOGsLedger."Group Type" := GlobalSBCTABudgetGroupType;
        SBCTAIndirectCOGsLedger."Group Code" := GlobalGroupCode;
        SBCTAIndirectCOGsLedger."Account No." := ValueEntry."Source No.";
        SBCTAIndirectCOGsLedger."Calculation Basis" := GlobalSBCTATradeBudgetOptions."Calculation Basis";
        SBCTAIndirectCOGsLedger."Calculation Method" := SBCTATradeBudgetRateCodes."Calculation Method";
        SBCTAIndirectCOGsLedger."Trade Budget Amount" := TradeBudgetAmount;
        SBCTAIndirectCOGsLedger."Value Entry Quantity" := ValueEntry."Valued Quantity";
        SBCTAIndirectCOGsLedger."Source Entry Amount" := SignFactor * LedgerAmount;
        SBCTAIndirectCOGsLedger."Sales Amount" := ValueEntry."Sales Amount (Actual)";
        SBCTAIndirectCOGsLedger."Cost Amount" := SignFactor * ValueEntry."Cost Amount (Expected)";
        if SBCTAIndirectCOGsLedger."Cost Amount" = 0 then
            SBCTAIndirectCOGsLedger."Cost Amount" := SignFactor * ValueEntry."Cost Amount (Actual)";
        SBCTAIndirectCOGsLedger."Discount Amount" := SignFactor * ValueEntry."Discount Amount";
        // if GlobalFromValueEntry then
        //     SBCTAIndirectCOGsLedger."Source Entry Amount" *= -1;
        SBCTAIndirectCOGsLedger."Dimension Set ID" := ValueEntry."Dimension Set ID";
        SBCTAIndirectCOGsLedger."Shortcut Dimension 1 Code" := ValueEntry."Global Dimension 1 Code";
        SBCTAIndirectCOGsLedger."Shortcut Dimension 2 Code" := ValueEntry."Global Dimension 2 Code";
        SBCTAIndirectCOGsLedger."Shortcut Dimension 1 Name" := GetDimensionValueName(ValueEntry."Global Dimension 1 Code", 1);
        SBCTAIndirectCOGsLedger."Shortcut Dimension 2 Name" := GetDimensionValueName(ValueEntry."Global Dimension 2 Code", 2);
        SBCTAIndirectCOGsLedger."Item No." := ValueEntry."Item No.";
        if GlobalReprocessEntry then
            Created := SBCTAIndirectCOGsLedger.Modify(true)
        else
            Created := SBCTAIndirectCOGsLedger.Insert(true);
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
        // Created := CreateLedgerEntry(SBCTATradeBudgetRates."Trade Budget Code", SBCTATradeBudgetRates."Trade Budget Rate Code", SBCTATradeBudgetRates.GetRateCode()."SystemId", SBCTATradeBudgetRates.SystemId, ValueEntry."Entry No.", ValueEntry."Document No.", ValueEntry."Document Type", ValueEntry."Posting Date", ValueEntry."Source No.", TradeBudgetAmount, LedgerAmount, ValueEntry."Dimension Set ID", ValueEntry."Global Dimension 1 Code", ValueEntry."Global Dimension 2 Code", ValueEntry."Document Line No.", ValueEntry."Sales Amount (Actual)", ValueEntry."Cost Amount (Actual)", ValueEntry."Discount Amount", ValueEntry."Item No.");
        Created := CreateLedgerEntry(SBCTATradeBudgetRates, ValueEntry, TradeBudgetAmount, LedgerAmount, SBCTATradeBudgetRateCodes);
        Clear(GlobalFromValueEntry);
    end;

    internal procedure TradeBudgetEntryExistsForGLEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: Guid) Exists: Boolean
    var
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
    begin
        SetCogsEntryFiltersForGL(EntryNo, TradeBudgetCode, TradeBudgetRateCodeID, SBCTAIndirectCOGsLedger);
        Exists := not SBCTAIndirectCOGsLedger.IsEmpty();
    end;

    internal procedure TradeBudgetEntryExistsForValueEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: Guid) Exists: Boolean
    var
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
    begin
        SetCogsEntryFiltersForVE(EntryNo, TradeBudgetCode, TradeBudgetRateCodeID, SBCTAIndirectCOGsLedger);
        Exists := not SBCTAIndirectCOGsLedger.IsEmpty();
    end;

    internal procedure TradeBudgetEntryExistsForGLEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]) Exists: Boolean
    var
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
    begin
        SetCogsFiltersForGL(EntryNo, TradeBudgetCode, TradeBudgetRateCode, SBCTAIndirectCOGsLedger);
        Exists := not SBCTAIndirectCOGsLedger.IsEmpty();
    end;

    internal procedure TradeBudgetEntryExistsForValueEntry(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]) Exists: Boolean
    var
        SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger";
    begin
        SetCogsEntryFiltersForVE(EntryNo, TradeBudgetCode, TradeBudgetRateCode, SBCTAIndirectCOGsLedger);
        Exists := not SBCTAIndirectCOGsLedger.IsEmpty();
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

    internal procedure GetCustomerPostingGroupCode() CustomerPostingGroupCode: Code[20]
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document No.", Rec."Document No.");
        CustLedgerEntry.SetRange("Sell-to Customer No.", Rec."Account No.");
        CustLedgerEntry.SetFilter("Customer Posting Group", '<>%1', '');
        if CustLedgerEntry.IsEmpty() then
            exit;
        CustLedgerEntry.FindFirst();
        CustomerPostingGroupCode := CustLedgerEntry."Customer Posting Group";
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

    // This procedure should never be called if Indirect Cost is being posted automatically.
    internal procedure GetPostingGLAccounts(var PostingAccount: Code[20]; var BalanceAccount: Code[20])
    var
        SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
        SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    begin
        case Rec."Group Type" of
            "SBCTA Budget Group Type"::Customer:
                begin
                    if SBCTATradeBudgetSetup.GetCustomerSetup(Rec."Group Code", Rec."Account No.", Rec."Shortcut Dimension 1 Code", Rec."Trade Budget Rate Code", SBCTATradeBudgetSetup) then begin
                        SBCTATradeBudgetSetup.SetLoadFields("Posting Account", "Balance Account");
                        SBCTATradeBudgetSetup.FindFirst();
                    end;
                    PostingAccount := SBCTATradeBudgetSetup."Posting Account";
                    BalanceAccount := SBCTATradeBudgetSetup."Balance Account";
                end;
            "SBCTA Budget Group Type"::Item:
                begin
                    if Rec."Document Type" in ["Item Ledger Document Type"::"Sales Credit Memo", "Item Ledger Document Type"::"Sales Invoice", "Item Ledger Document Type"::"Sales Return Receipt", "Item Ledger Document Type"::"Sales Shipment"] then begin
                        if SBCTAIndirectPostingSetup.GetItemSetup(Rec."Group Code", Rec.GetItemLedgerEntry()."Item No.", Rec."Trade Budget Rate Code", SBCTAIndirectPostingSetup, Rec.GetCustomerPostingGroupCode()) then begin
                            SBCTAIndirectPostingSetup.SetLoadFields("Posting Account", "Balance Account");
                            SBCTAIndirectPostingSetup.FindFirst();
                        end;
                    end else
                        if SBCTAIndirectPostingSetup.GetItemSetup(Rec."Group Code", Rec.GetItemLedgerEntry()."Item No.", Rec."Trade Budget Rate Code", SBCTAIndirectPostingSetup, '') then begin
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
                    if SBCTATradeBudgetSetup.GetCustomerSetup(Rec."Group Code", Rec."Account No.", Rec."Trade Budget Rate Code", SBCTATradeBudgetSetup) then begin
                        SBCTATradeBudgetSetup.SetLoadFields("Grouping Customer No.");
                        SBCTATradeBudgetSetup.FindFirst();
                        CustomerNo := SBCTATradeBudgetSetup."Grouping Customer No.";
                    end;
                end;
            "SBCTA Budget Group Type"::Item:
                begin
                    // if SBCTAIndirectPostingSetup.GetItemSetup(Rec."Group Code", Rec.GetItemLedgerEntry()."Item No.", Rec."Trade Budget Rate Code", SBCTAIndirectPostingSetup) then begin
                    //     SBCTATradeBudgetSetup.SetLoadFields("Grouping Customer No.");
                    //     SBCTAIndirectPostingSetup.FindFirst();
                    //     CustomerNo := SBCTATradeBudgetSetup."Grouping Customer No.";
                    // end;
                    // This is not allowed to happen.
                end;

        end;
    end;

    local procedure SetCogsEntryFiltersForGL(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: GUID; var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger")
    begin
        SBCTAIndirectCOGsLedger.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.");
        SBCTAIndirectCOGsLedger.SetRange("G/L Entry No.", EntryNo);
        SBCTAIndirectCOGsLedger.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTAIndirectCOGsLedger.SetFilter("Trade Budget Rate Code ID", '%1', TradeBudgetRateCodeID);
    end;

    local procedure SetCogsEntryFiltersForVE(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCodeID: GUID; var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger")
    begin
        SBCTAIndirectCOGsLedger.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.");
        SBCTAIndirectCOGsLedger.SetRange("Value Entry No.", EntryNo);
        SBCTAIndirectCOGsLedger.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTAIndirectCOGsLedger.SetFilter("Trade Budget Rate Code ID", '%1', TradeBudgetRateCodeID);
    end;

    local procedure SetCogsFiltersForGL(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger")
    begin
        SBCTAIndirectCOGsLedger.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.");
        SBCTAIndirectCOGsLedger.SetRange("G/L Entry No.", EntryNo);
        SBCTAIndirectCOGsLedger.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTAIndirectCOGsLedger.SetFilter("Trade Budget Rate Code", '%1', TradeBudgetRateCode);
    end;

    internal procedure SetCogsEntryFiltersForVE(EntryNo: Integer; TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; var SBCTAIndirectCOGsLedger: Record "SBCTA Indirect COGs Ledger")
    begin
        SBCTAIndirectCOGsLedger.SetCurrentKey("Trade Budget Code", "Trade Budget Rate Code", "Trade Budget Rate Code ID", "Value Entry No.", "G/L Entry No.", "Account No.");
        SBCTAIndirectCOGsLedger.SetRange("Value Entry No.", EntryNo);
        SBCTAIndirectCOGsLedger.SetRange("Trade Budget Code", TradeBudgetCode);
        SBCTAIndirectCOGsLedger.SetFilter("Trade Budget Rate Code", '%1', TradeBudgetRateCode);
    end;
}