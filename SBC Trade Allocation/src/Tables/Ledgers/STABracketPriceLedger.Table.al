/// <summary>
/// Table SBCTA Indirect COGs Ledger (ID 50206).
/// </summary>
table 50213 "STA Bracket Price Ledger"
{
    Caption = 'Bracket Price Ledger';
    DataClassification = CustomerContent;
    DrillDownPageId = "STA Bracket Price Ledger";
    LookupPageId = "STA Bracket Price Ledger";


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
            Description = 'This is the Value Entry that this entry is associated with. This will only be set for COGS entries.';
            BlankZero = true;
        }

        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Description = 'This is the Posting Date of the G/L Entry that this entry is associated with.';
        }

        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'This is the document number that this entry is associated with.';
        }
        field(7; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Description = 'This is the type of document that this entry is associated with.';
        }

        field(8; "Account No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'The Account No. used for the entry.';
            TableRelation = Customer."No.";

        }
        field(9; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            BlankZero = true;
        }
        field(10; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Description = 'This is the Item number that this entry is associated with.';
            TableRelation = Item."No.";
            Caption = 'Item No.';
        }

        field(11; "Quantity"; Decimal)
        {

            Caption = 'Quantity';
            BlankZero = true;
        }
        field(12; "Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'ERP Sales Amount (Actual)';
            BlankZero = true;
        }
        field(13; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'ERP Cost Amount (Actual)';
            BlankZero = true;
        }

        field(14; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'ERP Discount Amount';
            BlankZero = true;
        }

        field(40; "Bracket Price Code"; Code[20])
        {
            Caption = 'Bracket Price Code';
            DataClassification = CustomerContent;
            Description = 'This code identifies the Bracket Price associated with this entry.';

        }

        field(41; "Bracket Price Code ID"; Guid)
        {
            Caption = 'Bracket Price Code ID';
            DataClassification = CustomerContent;
            Description = 'This code identifies the particular Bracket Price Code associated with the Trade Budget and further instructions on how it should be applied.';

        }

        field(42; "Bracket Unit Price"; Decimal)
        {
            AutoFormatType = 1;
            DecimalPlaces = 2 : 5;
            Caption = 'Bracket Unit Price';
            Description = 'This code identifies the particular Bracket Price associated with Customer and Item.';
        }

        field(43; "Bracket List Unit Price"; Decimal)
        {
            Caption = 'Bracket List Unit Price';
            DecimalPlaces = 2 : 5;
            AutoFormatType = 1;
            Description = 'This code identifies the particular Bracket List Price associated with Customer and Item.';

        }

        field(44; "Bracket Amount"; Decimal)
        {
            Caption = 'Bracket Amount';
            DecimalPlaces = 2 : 5;
            AutoFormatType = 1;
            Description = 'This is the Bracket List Unit Price less the Bracket Unit Price.';

        }

        field(45; "Value Entry No."; Integer)
        {
            Caption = 'Value Entry No.';
            DataClassification = CustomerContent;
            Description = 'This is the Value Entry that this entry is associated with. This will only be set for COGS entries.';
            BlankZero = true;
        }

        field(100; "Bracket Dimension Value"; Code[20])
        {
            Caption = 'Bracket Dimension Value';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            BlankZero = true;
        }
        field(481; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));


        }
        field(482; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

        }
        field(483; "Shortcut Dimension 1 Name"; Text[50])
        {
            CaptionClass = '1,2,1, , Name';
            Caption = 'Shortcut Dimension 1 Name';
            TableRelation = "Dimension Value".Name WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));


        }
        field(484; "Shortcut Dimension 2 Name"; Text[50])
        {
            CaptionClass = '1,2,2,, Name';
            Caption = 'Shortcut Dimension 2 Name';
            TableRelation = "Dimension Value".Name WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

        }


    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(ExistingEntry; "Document No.", "Document Line No.")
        {
            Description = 'Search key';
            MaintainSqlIndex = true;
        }

        key(UniqueConstraint; "Document No.", "Document Line No.", "Value Entry No.")
        {
            MaintainSqlIndex = true;
            Unique = true;
        }

    }


    var
        GlobalFromValueEntry: Boolean;
        GlobalReprocessEntry: Boolean;
        GlobalGroupCode: Code[20];
        GlobalSBCTABudgetGroupType: Enum "SBCTA Budget Group Type";
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";

    // internal procedure CreateLedgerEntry(TradeBudgetCode: Code[20]; TradeBudgetRateCode: Code[20]; TradeBudgetRateCodeGuid: Guid; TradeBudgetRateGuid: Guid; LedgerEntryNo: Integer; DocumentNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date; CustomerNo: Code[20]; TradeBudgetAmount: Decimal; GlEntryAmount: Decimal; DimensionSetID: Integer; ShortcutDimensionCode1: Code[20]; ShortcutDimensionCode2: Code[20]; DocumentLineNo: Integer; SalesAmount: Decimal; CostAmount: Decimal; DiscountAmount: Decimal; ItemNo: Code[20]) Created: Boolean
    internal procedure CreateLedgerEntry(TempSTABracketPrice: Record "STA Bracket Price" temporary; ValueEntry: Record "Value Entry"; SellToCustomerNo: Code[20]; BracketDimensionValue: Code[20]) BracketPriceLedgerEntry: Record "STA Bracket Price Ledger";
    var
        STABracketPriceLedger: Record "STA Bracket Price Ledger";
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        SignFactor: Integer;
        Created: Boolean;
    begin
        if GlobalReprocessEntry then
            STABracketPriceLedger := Rec
        else
            STABracketPriceLedger.Init();

        // STABracketPriceLedger."Value Entry No." := ValueEntry."Entry No.";
        SignFactor := -1;

        STABracketPriceLedger."Bracket Price Code" := TempSTABracketPrice."Bracket Price Code";
        STABracketPriceLedger."Bracket Price Code ID" := TempSTABracketPrice.SystemId; // Debug(Ensure that this is set without needing to add a field to the table to store the value.)
        STABracketPriceLedger."Document No." := ValueEntry."Document No.";
        STABracketPriceLedger."Document Line No." := ValueEntry."Document Line No.";
        STABracketPriceLedger."Document Type" := ValueEntry."Document Type";
        STABracketPriceLedger."Posting Date" := ValueEntry."Posting Date";
        STABracketPriceLedger."Account No." := SellToCustomerNo;
        STABracketPriceLedger."Quantity" := SignFactor * ValueEntry."Valued Quantity";
        STABracketPriceLedger."Sales Amount" := ValueEntry."Sales Amount (Actual)";
        STABracketPriceLedger."Cost Amount" := SignFactor * ValueEntry."Cost Amount (Actual)";
        STABracketPriceLedger."Discount Amount" := SignFactor * ValueEntry."Discount Amount";
        STABracketPriceLedger."Bracket Unit Price" := TempSTABracketPrice."Bracket Unit Price";
        STABracketPriceLedger."Bracket List Unit Price" := TempSTABracketPrice."Item Unit Price";
        STABracketPriceLedger."Value Entry No." := ValueEntry."Entry No.";
        // STABracketPriceLedger."Bracket Amount" := Round(ValueEntry."Valued Quantity" * TempSTABracketPrice."Units per Case" *(TempSTABracketPrice."Bracket List Unit Price" - TempSTABracketPrice."Bracket Unit Price"), 0.00001); //Units per case is not needed because the unit prices are already in cases.
        STABracketPriceLedger."Bracket Amount" := SignFactor * Round(ValueEntry."Valued Quantity" * (TempSTABracketPrice."Item Unit Price" - TempSTABracketPrice."Bracket Unit Price"), 0.00001); //TODO(Update this if bracket list unit is no longer being used.)
        // STABracketPriceLedger."Dimension Set ID" := ValueEntry."Dimension Set ID";
        STABracketPriceLedger."Dimension Set ID" := GetDimensionSetID(BracketDimensionValue, ValueEntry."Dimension Set ID", ValueEntry."Global Dimension 1 Code", ValueEntry."Global Dimension 2 Code");
        STABracketPriceLedger."Shortcut Dimension 1 Code" := ValueEntry."Global Dimension 1 Code";
        STABracketPriceLedger."Shortcut Dimension 2 Code" := ValueEntry."Global Dimension 2 Code";
        STABracketPriceLedger."Shortcut Dimension 1 Name" := GetDimensionValueName(ValueEntry."Global Dimension 1 Code", 1);
        STABracketPriceLedger."Shortcut Dimension 2 Name" := GetDimensionValueName(ValueEntry."Global Dimension 2 Code", 2);
        STABracketPriceLedger."Bracket Dimension Value" := BracketDimensionValue;
        STABracketPriceLedger."Item No." := ValueEntry."Item No.";
        if GlobalReprocessEntry then
            Created := STABracketPriceLedger.Modify(true)
        else
            Created := STABracketPriceLedger.Insert(true);

        BracketPriceLedgerEntry := STABracketPriceLedger;
    end;

    local procedure GetDimensionSetID(BracketDimensionValueCode: Code[20]; ExistingDimensionSetId: Integer; ShortcutDimensionValueCode1: Code[20]; ShortDimensionValueCode2: Code[20]) DimSetID: Integer
    var
        DimensionManagement: Codeunit DimensionManagement;
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
        GLSetupShortcutDimCode: array[8] of Code[20];
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        TempDimensionSetEntry2: Record "Dimension Set Entry" temporary;
        DimensionBufferManagement: Codeunit "Dimension Buffer Management";
        DimensionBuffer: Record "Dimension Buffer";
        DimensionValue: Record "Dimension Value";
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry2, ExistingDimensionSetId);
        // DimensionBufferManagement.InsertDimensions()
        // DimensionBufferManagement.GetDimensions()
        if TempDimensionSetEntry2.IsEmpty() then begin

            TempDimensionSetEntry.Validate("Dimension Code", GLSetupShortcutDimCode[1]);
            TempDimensionSetEntry.Validate("Dimension Value Code", ShortcutDimensionValueCode1);
            DimensionValue.Get(GLSetupShortcutDimCode[1], ShortcutDimensionValueCode1);
            TempDimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";
            TempDimensionSetEntry.Insert(true);
            TempDimensionSetEntry.Validate("Dimension Code", GLSetupShortcutDimCode[2]);
            TempDimensionSetEntry.Validate("Dimension Value Code", ShortDimensionValueCode2);
            DimensionValue.Get(GLSetupShortcutDimCode[2], ShortDimensionValueCode2);
            TempDimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";
            TempDimensionSetEntry.Insert(true);
        end else begin
            TempDimensionSetEntry2.FindSet(false);
            repeat
                TempDimensionSetEntry := TempDimensionSetEntry2;
                TempDimensionSetEntry."Dimension Set ID" := 0;
                TempDimensionSetEntry."Dimension Value ID" := TempDimensionSetEntry2."Dimension Value ID";
                TempDimensionSetEntry.Insert(true);
            until TempDimensionSetEntry2.Next() = 0;
        end;

        // TempDimensionSetEntry.ModifyAll("Dimension Set ID", 0);
        SBCTATradeBudgetOptions.SetLoadFields("Bracket Dimension Code");
        SBCTATradeBudgetOptions.FindFirst();
        TempDimensionSetEntry.Validate("Dimension Code", SBCTATradeBudgetOptions."Bracket Dimension Code");
        TempDimensionSetEntry.Validate("Dimension Value Code", BracketDimensionValueCode);
        DimensionValue.Get(SBCTATradeBudgetOptions."Bracket Dimension Code", BracketDimensionValueCode);
        TempDimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";
        TempDimensionSetEntry.Insert(true);
        DimSetID := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
    end;



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



    // internal procedure TradeBudgetEntryExistsForValueEntry(EntryNo: Integer) Exists: Boolean
    // var
    //     STABracketPriceLedger: Record "STA Bracket Price Ledger";
    // begin
    //     SetFiltersForValueEntry(EntryNo, STABracketPriceLedger);
    //     Exists := not STABracketPriceLedger.IsEmpty();
    // end;


    internal procedure GetItemLedgerEntry() ItemLedgerEntry: Record "Item Ledger Entry"
    begin
        if not ItemLedgerEntry.Get(Rec.GetValueEntry()."Item Ledger Entry No.") then
            exit;
    end;


    internal procedure GetValueEntry() ValueEntry: Record "Value Entry";
    begin
        if Rec."G/L Entry No." = 0 then
            exit;
        if not ValueEntry.Get(Rec."G/L Entry No.") then
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

    /// <summary>
    /// One entry per Document Line No.
    /// </summary>
    /// <param name="ValueEntry">Record "Value Entry".</param>
    /// <param name="STABracketPriceLedger">VAR Record "STA Bracket Price Ledger".</param>
    internal procedure SetFiltersForValueEntry(ValueEntry: Record "Value Entry"; var STABracketPriceLedger: Record "STA Bracket Price Ledger")
    begin
        STABracketPriceLedger.SetCurrentKey("Document No.", "Document Line No.");
        STABracketPriceLedger.SetRange("Document No.", ValueEntry."Document No.");
        STABracketPriceLedger.SetRange("Document Line No.", ValueEntry."Document Line No.");
    end;

    internal procedure IsBracketPriceEntry(SBCTAID: Guid) Found: Boolean
    var
        STABracketPriceLedger: Record "STA Bracket Price Ledger";
    begin
        if IsNullGuid(SBCTAID) then
            exit;
        STABracketPriceLedger.SetRange(SystemId, SBCTAID);
        Found := not STABracketPriceLedger.IsEmpty();
    end;
}