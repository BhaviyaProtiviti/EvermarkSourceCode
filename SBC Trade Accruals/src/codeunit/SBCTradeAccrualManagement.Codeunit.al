codeunit 50701 "SBC Trade Accrual Management"
{

    procedure ProcessSalesLine(SalesLine: Record "Sales Line")
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        GetSetupInformation(SalesLine);
    end;

    procedure ProcessJournalBatch(SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20])
    begin
        SalesRecSetup.Get();
        UpdateJournalLines(SalesInvHdrNo);
        if not ValidateAutoPost() then
            exit;
        PostJournalBatch();
    end;

    local procedure UpdateJournalLines(SalesInvHdrNo: Code[20])
    var
        SalesInvoiceHdr: Record "Sales Invoice Header";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if not SalesInvoiceHdr.Get(SalesInvHdrNo) then
            exit;
        GenJnlLine.SetRange("Journal Template Name", SalesRecSetup."TradeAccrualsPostingTemplate");
        GenJnlLine.SetRange("Journal Batch Name", SalesRecSetup."TradeAccrualsPostingBatch");
        GenJnlLine.SetRange("Document No.", SalesInvoiceHdr."Order No.");
        if GenJnlLine.IsEmpty() then
            exit;
        GenJnlLine.ModifyAll("Document No.", SalesInvoiceHdr."No.");
        Commit();
    end;

    local procedure PostJournalBatch()
    var
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", SalesRecSetup."TradeAccrualsPostingTemplate");
        GenJnlLine.SetRange("Journal Batch Name", SalesRecSetup."TradeAccrualsPostingBatch");
        if GenJnlLine.FindFirst() then
            GenJnlPostBatch.Run(GenJnlLine);
    end;

    local procedure ValidateAutoPost(): boolean
    begin
        if not ValidateSetupFields() then
            exit(false);
        if not SalesRecSetup."TradeAccrualsAutoPostJourLines" then
            exit(false);
        exit(true);
    end;

    local procedure GetSetupInformation(SalesLine: Record "Sales Line")
    begin
        if not ValidateSetupFields() then
            exit;
        If not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;
        SetCustomerPostingGroup(SalesLine."Sell-to Customer No.");
        SetupLineFound := CheckCustomerItemCombination(SalesLine, SalesHeader) or
                          CheckCustomerDimensionCombination(SalesLine, SalesHeader) or
                          CheckCustPostingGroupItemCombination(SalesLine, SalesHeader) or
                          CheckCustPostingGroupDimensionCombination(SalesLine, SalesHeader);
        if not SetupLineFound then
            exit;
        SetAndProcessEachSetupLine(SalesLine);
    end;

    local procedure ValidateSetupFields(): Boolean
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    BEGIN
        SalesRecSetup.Get();
        if not SalesRecSetup.TradeEnabled then
            exit;
        SalesRecSetup.TestField("TradeAccrualsPostingTemplate");
        SalesRecSetup.TestField("TradeAccrualsPostingBatch");
        GenJournalBatch.SetRange("Journal Template Name", SalesRecSetup."TradeAccrualsPostingTemplate");
        GenJournalBatch.SetRange(Name, SalesRecSetup."TradeAccrualsPostingBatch");
        if GenJournalBatch.IsEmpty() then
            Error('Trade Accruals - The journal batch %1 does not exist or is not set up correctly.', SalesRecSetup."TradeAccrualsPostingBatch");
        exit(true);
    END;

    local procedure CreateTradeAccrualLedger(SalesLine: Record "Sales Line")
    var
        LineNo: Integer;
    begin
        if not SBCTradeAccrualLedgerEntry.FindLast() then
            LineNo := 1
        else
            LineNo := SBCTradeAccrualLedgerEntry.LineNo + 1;
        SBCTradeAccrualLedgerEntry.Init();
        SBCTradeAccrualLedgerEntry.PostingDate := SalesHeader."Posting Date";
        SBCTradeAccrualLedgerEntry.orderNo := SalesLine."Document No.";
        SBCTradeAccrualLedgerEntry.ItemNo := SalesLine."No.";
        SBCTradeAccrualLedgerEntry.CustomerNo := SalesLine."Sell-to Customer No.";
        SBCTradeAccrualLedgerEntry.CustomerGroup := CustPostingGroup;
        SBCTradeAccrualLedgerEntry.OrderLineNo := SalesLine."Line No.";
        SBCTradeAccrualLedgerEntry."Quantity" := SalesLine."Quantity";
        SBCTradeAccrualLedgerEntry.GlobalDimension1 := SalesLine."Shortcut Dimension 1 Code";
        SBCTradeAccrualLedgerEntry.GlobalDimension2 := SalesLine."Shortcut Dimension 2 Code";
        SBCTradeAccrualLedgerEntry.GlobalDimension4 := GetShortcutDimension4(SalesLine);

        Case SBCTradeSetupLines.Type of
            SBCTradeSetupType::Percent:
                begin
                    SBCTradeAccrualLedgerEntry.Amount := GetPercentAmount(SalesLine);
                end;
            SBCTradeSetupType::"Per Unit":
                begin
                    SBCTradeAccrualLedgerEntry.Amount := CreatePerUnitAmount(SalesLine);
                end;
        end;
        SBCTradeAccrualLedgerEntry."Derived From Amount" := GetDerivedFromAmount(SalesLine);
        SBCTradeAccrualLedgerEntry.Description := SBCTradeSetupLines.Description;
        SBCTradeAccrualLedgerEntry.Type := SBCTradeSetupLines.Type;
        SBCTradeAccrualLedgerEntry.Base := SBCTradeSetupLines.Base;
        SBCTradeAccrualLedgerEntry.Rate := SBCTradeSetupLines.Rate;
        SBCTradeAccrualLedgerEntry.LineNo := LineNo;
        SBCTradeAccrualLedgerEntry.Insert();
    end;

    local procedure CreateGLJournalLine(SBCTradeAccrualLedgerEntry: Record SBCTradeAccrualLedgerEntry; SalesLine: Record "Sales Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        DimMgt: Codeunit DimensionManagement;
        NewDimSet: Record "Dimension Set Entry" temporary;
    begin
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := SalesRecSetup."TradeAccrualsPostingTemplate";
        GenJournalLine."Journal Batch Name" := SalesRecSetup."TradeAccrualsPostingBatch";
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        GenJournalLine."Posting Date" := SBCTradeAccrualLedgerEntry.PostingDate;
        GenJournalLine."Document No." := SalesHeader."No.";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine.Validate("Account No.", SBCTradeSetupLines."Expense Account");
        GenJournalLine.Validate(Amount, SBCTradeAccrualLedgerEntry.Amount);
        GenJournalLine.Validate("Bal. Account No.", SBCTradeSetupLines."Balancing Account");
        GenJournalLine.Validate("Dimension Set ID", SalesLine."Dimension Set ID");
        GenJournalLine.Insert(true);
    end;

    local procedure CreateDimensionSourceFromAccrualLedger(SBCTradeAccrualLedgerEntry: Record SBCTradeAccrualLedgerEntry): Integer;
    var
        DimensionSource: Record "Dimension Set Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;
        DimValue: Record "Dimension Value";
    begin
        GLSetup.Get();
        if DimValue.Get(GLSetup."Global Dimension 1 Code", SBCTradeAccrualLedgerEntry.GlobalDimension1) then begin
            DimensionSource.Init();
            DimensionSource."Dimension Code" := GLSetup."Global Dimension 1 Code";
            DimensionSource."Dimension Value Code" := SBCTradeAccrualLedgerEntry.GlobalDimension1;
            DimensionSource."Dimension Value ID" := DimValue."Dimension Value ID";
            DimensionSource.Insert(true);
        end;
        if DimValue.Get(GLSetup."Global Dimension 2 Code", SBCTradeAccrualLedgerEntry.GlobalDimension2) then begin
            DimensionSource.Init();
            DimensionSource."Dimension Code" := GLSetup."Global Dimension 2 Code";
            DimensionSource."Dimension Value Code" := SBCTradeAccrualLedgerEntry.GlobalDimension2;
            DimensionSource."Dimension Value ID" := DimValue."Dimension Value ID";
            DimensionSource.Insert(true);
        end;

        if DimValue.Get(GLSetup."Shortcut Dimension 4 Code", SBCTradeAccrualLedgerEntry.GlobalDimension4) then begin
            DimensionSource.Init();
            DimensionSource."Dimension Code" := GLSetup."Shortcut Dimension 4 Code";
            DimensionSource."Dimension Value Code" := SBCTradeAccrualLedgerEntry.GlobalDimension4;
            DimensionSource."Dimension Value ID" := DimValue."Dimension Value ID";
            DimensionSource.Insert(true);
        end;
        exit(DimMgt.GetDimensionSetID(DimensionSource));
    end;

    local procedure GetShortcutDimension4(SalesLine: Record "Sales Line"): Code[20]
    var

        DimMgt: Codeunit DimensionManagement;
        ShortcutDimensions: array[8] of Code[20];
    begin
        DimMgt.GetShortcutDimensions(SalesLine."Dimension Set ID", ShortcutDimensions);
        exit(ShortcutDimensions[4]); // Assuming 4 is the index for Shortcut Dimension 4
    end;

    local procedure GetPercentAmount(SalesLine: Record "Sales Line"): Decimal
    begin
        case SBCTradeSetupLines.Base of
            SBCTradeSetupBase::"Gross Sales":
                exit(SalesLine.Quantity * SalesLine."Unit Price" * (SBCTradeSetupLines.Rate / 100));
            SBCTradeSetupBase::"Net Sales":
                exit(SalesLine.Amount * (SBCTradeSetupLines.Rate / 100));
        end;
    end;

    local procedure GetDerivedFromAmount(salesLine: Record "Sales Line"): Decimal
    begin
        case SBCTradeSetupLines.Base of
            SBCTradeSetupBase::"Gross Sales":
                exit(salesLine.Quantity * salesLine."Unit Price");
            SBCTradeSetupBase::"Net Sales":
                exit(salesLine.Amount);
        end;
    end;

    local procedure CreatePerUnitAmount(SalesLine: Record "Sales Line"): Decimal
    begin
        exit(SalesLine."Quantity" * SBCTradeSetupLines.Rate);
    end;

    local procedure CheckCustomerItemCombination(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"): Boolean
    begin
        SBCTradeSetupCustItemLines.SetRange("Customer Group", CustPostingGroup);
        SBCTradeSetupCustItemLines.SetRange(CustomerNo, SalesLine."Sell-to Customer No.");
        SBCTradeSetupCustItemLines.SetRange("Item No.", SalesLine."No.");
        SBCTradeSetupCustItemLines.SetFilter("Start Date", '<=%1', SalesHeader."Posting Date");
        SBCTradeSetupCustItemLines.SetFilter("End Date", '>= %1', SalesHeader."Posting Date");
        if SBCTradeSetupCustItemLines.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure CheckCustomerDimensionCombination(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"): Boolean
    begin
        SBCTradeSetupCustDimLines.SetRange("Customer Group", CustPostingGroup);
        SBCTradeSetupCustDimLines.SetRange("Global Dimension 1", SalesLine."Shortcut Dimension 1 Code");
        SBCTradeSetupCustDimLines.SetRange(CustomerNo, SalesLine."Sell-to Customer No.");
        SBCTradeSetupCustDimLines.SetFilter("Start Date", '<=%1', SalesHeader."Posting Date");
        SBCTradeSetupCustDimLines.SetFilter("End Date", '>= %1', SalesHeader."Posting Date");
        SBCTradeSetupCustDimLines.SetFilter("Item No.", '%1', ' ');
        if SBCTradeSetupCustDimLines.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure CheckCustPostingGroupItemCombination(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"): Boolean
    begin
        SBCTradeSetupCustPostingGroupItemLines.SetRange("Customer Group", CustPostingGroup);
        SBCTradeSetupCustPostingGroupItemLines.SetRange("Item No.", SalesLine."No.");
        SBCTradeSetupCustPostingGroupItemLines.SetFilter("Start Date", '<=%1', SalesHeader."Posting Date");
        SBCTradeSetupCustPostingGroupItemLines.SetFilter("End Date", '>= %1', SalesHeader."Posting Date");
        SBCTradeSetupCustPostingGroupItemLines.SetFilter(CustomerNo, '%1', ' ');
        if SBCTradeSetupCustPostingGroupItemLines.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure CheckCustPostingGroupDimensionCombination(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"): Boolean
    begin
        SBCTradeSetupCustPostingGroupDimLines.SetRange("Customer Group", CustPostingGroup);
        SBCTradeSetupCustPostingGroupDimLines.SetRange("Global Dimension 1", SalesLine."Shortcut Dimension 1 Code");
        SBCTradeSetupCustPostingGroupDimLines.SetFilter("Start Date", '<=%1', SalesHeader."Posting Date");
        SBCTradeSetupCustPostingGroupDimLines.SetFilter("End Date", '>= %1', SalesHeader."Posting Date");
        SBCTradeSetupCustPostingGroupDimLines.SetFilter("Item No.", '%1', ' ');
        SBCTradeSetupCustPostingGroupDimLines.SetFilter(CustomerNo, '%1', ' ');
        if SBCTradeSetupCustPostingGroupDimLines.FindFirst() then
            exit(true);
        exit(false);
    end;

    local procedure SetVariables(SalesLine: Record "Sales Line"; SBCTradeSetupLines: Record SBCTradeSetupLines)
    begin
        Type := SBCTradeSetupLines."Type";
        Base := SBCTradeSetupLines."Base";
        Rate := SBCTradeSetupLines."Rate";
        ExpenseAccount := SBCTradeSetupLines."Expense Account";
    end;

    local procedure SetAndProcessEachSetupLine(SalesLine: Record "Sales Line")
    begin
        if ProcessCustItemLines(SalesLine) then
            exit;
        if ProcessCustDimLines(SalesLine) then
            exit;
        if ProcessCustPostingGroupItemLines(SalesLine) then
            exit;
        if ProcessCustPostingGroupDimLines(SalesLine) then
            exit;
    end;

    local procedure ProcessCustItemLines(SalesLine: Record "Sales Line"): Boolean
    var
        FoundSetupLine: Boolean;
    begin
        If not SBCTradeSetupCustItemLines.IsEmpty then begin
            FoundSetupLine := true;
            repeat
                SBCTradeSetupLines := SBCTradeSetupCustItemLines;
                ProcessSetupLines(SalesLine)
            until SBCTradeSetupCustItemLines.Next() = 0;
        end;
        exit(FoundSetupLine);
    end;

    local procedure ProcessCustDimLines(SalesLine: Record "Sales Line"): Boolean
    var
        FoundSetupLine: Boolean;
    begin
        If not SBCTradeSetupCustDimLines.IsEmpty then begin
            FoundSetupLine := true;
            repeat
                SBCTradeSetupLines := SBCTradeSetupCustDimLines;
                ProcessSetupLines(SalesLine)
            until SBCTradeSetupCustDimLines.Next() = 0;
        end;
        exit(FoundSetupLine);
    end;

    local procedure ProcessCustPostingGroupItemLines(SalesLine: Record "Sales Line"): Boolean
    var
        FoundSetupLine: Boolean;
    begin
        If not SBCTradeSetupCustPostingGroupItemLines.IsEmpty then begin
            FoundSetupLine := true;
            repeat
                SBCTradeSetupLines := SBCTradeSetupCustPostingGroupItemLines;
                ProcessSetupLines(SalesLine)
            until SBCTradeSetupCustPostingGroupItemLines.Next() = 0;
        end;
        exit(FoundSetupLine);
    end;

    local procedure ProcessCustPostingGroupDimLines(SalesLine: Record "Sales Line"): Boolean
    var
        FoundSetupLine: Boolean;
    begin
        If not SBCTradeSetupCustPostingGroupDimLines.IsEmpty then begin
            FoundSetupLine := true;
            repeat
                SBCTradeSetupLines := SBCTradeSetupCustPostingGroupDimLines;
                ProcessSetupLines(SalesLine)
            until SBCTradeSetupCustPostingGroupDimLines.Next() = 0;
        end;
        exit(FoundSetupLine);
    end;

    local procedure ProcessSetupLines(SalesLine: Record "Sales Line")
    begin
        CreateTradeAccrualLedger(SalesLine);
        CreateGLJournalLine(SBCTradeAccrualLedgerEntry, SalesLine);
    end;

    local procedure GetCustomerPostingGroup(SellToCustomerNo: Code[20]): Code[20]
    var
        Customer: Record Customer;
    begin
        if Customer.Get(SellToCustomerNo) then
            exit(Customer."Customer Posting Group");
        exit('');
    end;

    local procedure SetCustomerPostingGroup(SellToCustomerNo: Code[20])
    begin
        CustPostingGroup := GetCustomerPostingGroup(SellToCustomerNo);
    end;

    var
        Type: Enum SBCTradeSetupType;
        Base: Enum SBCTradeSetupBase;
        Rate: Decimal;
        ExpenseAccount: Code[20];
        AccrualAccount: Code[20];
        SBCTradeSetupLines: Record SBCTradeSetupLines;
        SetupLineFound: Boolean;
        SBCTradeAccrualLedgerEntry: Record SBCTradeAccrualLedgerEntry;
        SalesHeader: Record "Sales Header";
        SalesRecSetup: Record "Sales & Receivables Setup";
        SBCTradeSetupCustItemLines: Record SBCTradeSetupLines;
        SBCTradeSetupCustDimLines: Record SBCTradeSetupLines;
        SBCTradeSetupCustPostingGroupItemLines: Record SBCTradeSetupLines;
        SBCTradeSetupCustPostingGroupDimLines: Record SBCTradeSetupLines;
        CustPostingGroup: Code[20];
}