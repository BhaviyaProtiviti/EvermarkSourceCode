report 50001 "SBC Adjust Cost"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    // dataset
    // {

    // }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(GeneralJournalTemplateName; GeneralJournalTemplateName)
                    {
                        ApplicationArea = All;
                        Caption = 'Gen. Journal Template';
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GeneralJournalTemplate: Record "Gen. Journal Template";
                        begin
                            GeneralJournalTemplate.Reset();
                            if Page.RunModal(Page::"General Journal Templates", GeneralJournalTemplate) = Action::LookupOK then
                                GeneralJournalTemplateName := GeneralJournalTemplate.Name;
                        end;
                    }
                    field(GenralJournalBatchName; GenralJournalBatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Gen. Journal Batch';
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenralJournalBatch: Record "Gen. Journal Batch";
                        begin
                            if GeneralJournalTemplateName <> '' then begin
                                GenralJournalBatch.Reset();
                                GenralJournalBatch.SetFilter("Journal Template Name", '%1', GeneralJournalTemplateName);
                                if Page.RunModal(Page::"General Journal Batches", GenralJournalBatch) = Action::LookupOK then
                                    GenralJournalBatchName := GenralJournalBatch.Name;
                            end
                            else begin
                                Error('User must select Journal Template first');
                            end;
                        end;
                    }
                    field(DebitToAccountNo; DebitToAccountNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Debit To Account No';
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccounts: Record "G/L Account";
                        begin
                            GLAccounts.Reset();
                            if Page.RunModal(Page::"Chart of Accounts", GLAccounts) = Action::LookupOK then
                                DebitToAccountNo := GLAccounts."No.";
                        end;
                    }
                    field(CreditToAccountNo; CreditToAccountNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Credit To Account No';
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccounts: Record "G/L Account";
                        begin
                            GLAccounts.Reset();
                            if Page.RunModal(Page::"Chart of Accounts", GLAccounts) = Action::LookupOK then
                                CreditToAccountNo := GLAccounts."No.";
                        end;
                    }
                    field(RequestDescription; RequestDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Line Description';
                    }
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    var
        StartTime: DateTime;
        EndTime: DateTime;
        StartTime2: Time;
        EndTime2: Time;
    begin
        // ValueEntry1 is used for filtering for actual sales document transaction to capture item number and document number 
        xGeneralJournalLine.Reset();
        ValueEntry1.SetFilter("Entry Type", '%1', Enum::"Cost Entry Type"::"Direct Cost");
        ValueEntry1.SetFilter("Item Ledger Entry Type", '%1', Enum::"Item Ledger Entry Type"::Sale);
        ValueEntry1.SetFilter("Document Type", '%1', Enum::"Item Ledger Document Type"::"Sales Invoice");
        ValueEntry1.SetFilter(Adjustment, '%1', false);
        ValueEntry1.SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
        //CostSum := 0;
        if ValueEntry1.FindFirst() then begin
            repeat
                GeneralJournalLine.Reset();
                GeneralJournalLine.SetFilter(Comment, '%1', ValueEntry1."Document No.");
                if NOT GeneralJournalLine.FindFirst() then begin
                    // ValueEntry2 is used for filtering for posted in direct coast amount for filtered item and document
                    ValueEntry2.SetFilter("Posting Date", '%1', ValueEntry1."Posting Date");
                    ValueEntry2.SetFilter("Document No.", '%1', ValueEntry1."Document No.");
                    //ValueEntry2.SetFilter("Item No.", '%1', ValueEntry1."Item No.");
                    ValueEntry2.SetFilter("Item Ledger Entry Type", '%1', Enum::"Item Ledger Entry Type"::Sale);
                    ValueEntry2.SetFilter("Entry Type", '%1', Enum::"Cost Entry Type"::"Indirect Cost");

                    if ValueEntry2.FindSet() then begin
                        // Get sum of indirect cost
                        ValueEntry2.CalcSums("Cost Amount (Actual)");
                        CostSum := ValueEntry2."Cost Amount (Actual)";
                        InsertDebitLine();
                        InsertCreditLine();
                    end;
                end;
            until ValueEntry1.Next() = 0;
        end;
    end;

    local procedure InsertDebitLine()
    begin
        GeneralJournalLine.Reset();
        GeneralJournalLine.init();
        GeneralJournalLine."Journal Template Name" := GeneralJournalTemplateName;
        GeneralJournalLine."Journal Batch Name" := GenralJournalBatchName;
        GeneralJournalLine.SetUpNewLine(xGeneralJournalLine, 0, false);
        GeneralJournalLine."Line No." := GeneralJournalLine.GetNewLineNo(GeneralJournalTemplateName, GenralJournalBatchName);

        GeneralJournalLine."Account No." := DebitToAccountNo;
        GeneralJournalLine.Description := RequestDescription;
        //GeneralJournalLine.Comment := 'Item No: ' + ValueEntry1."Item No." + ', Item Ledger Entry: ' + Format(ValueEntry1."Item Ledger Entry No.");
        GeneralJournalLine.Comment := ValueEntry1."Document No.";
        GeneralJournalLine."Shortcut Dimension 1 Code" := ValueEntry1."Global Dimension 1 Code";
        GeneralJournalLine."Shortcut Dimension 2 Code" := ValueEntry1."Global Dimension 2 Code";

        GeneralJournalLine.Validate(Amount, -1 * CostSum);

        GeneralJournalLine.Insert();
        xGeneralJournalLine := GeneralJournalLine;
    end;

    local procedure InsertCreditLine()
    begin
        GeneralJournalLine.Reset();
        GeneralJournalLine.init();
        GeneralJournalLine."Journal Template Name" := GeneralJournalTemplateName;
        GeneralJournalLine."Journal Batch Name" := GenralJournalBatchName;
        GeneralJournalLine.SetUpNewLine(xGeneralJournalLine, 0, false);
        GeneralJournalLine."Line No." := GeneralJournalLine.GetNewLineNo(GeneralJournalTemplateName, GenralJournalBatchName);

        GeneralJournalLine."Account No." := CreditToAccountNo;
        GeneralJournalLine.Description := RequestDescription;
        //GeneralJournalLine.Comment := 'Item No: ' + ValueEntry1."Item No." + ', Item Ledger Entry: ' + Format(ValueEntry1."Item Ledger Entry No.");
        GeneralJournalLine.Comment := ValueEntry1."Document No.";

        GeneralJournalLine."Shortcut Dimension 1 Code" := ValueEntry1."Global Dimension 1 Code";
        GeneralJournalLine."Shortcut Dimension 2 Code" := ValueEntry1."Global Dimension 2 Code";

        GeneralJournalLine.Validate(Amount, CostSum);

        GeneralJournalLine.Insert();
        xGeneralJournalLine := GeneralJournalLine;
    end;

    var
        ValueEntry1: Record "Value Entry";
        ValueEntry2: Record "Value Entry";
        ValueEntry3: Record "Value Entry";
        GeneralJournalLine: Record "Gen. Journal Line";
        xGeneralJournalLine: Record "Gen. Journal Line";
        StartDate: Date;
        EndDate: Date;
        GeneralJournalTemplateName: Code[10];
        GenralJournalBatchName: Code[10];
        DebitToAccountNo: Code[20];
        CreditToAccountNo: Code[20];
        RequestDescription: Text[100];
        CostSum: Decimal;
        CostSumRounded: Decimal;
        CostAll: Decimal;
}