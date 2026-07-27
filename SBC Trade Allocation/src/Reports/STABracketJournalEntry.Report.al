/// <summary>
/// Report STA Bracket Journal Entry (ID 50211).
/// </summary>
report 50211 "STA Bracket Journal Entry"
{
    ApplicationArea = All;
    Caption = 'SBC Create Bracket Journal Entry';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem("BracketJournalBatch"; "Gen. Journal Batch")
        {
            DataItemTableView = where("Journal Template Name" = const('GENERAL'));
            // RequestFilterFields = Name;
            // RequestFilterHeading = 'Journal Batch Name';
            MaxIteration = 1;


            dataitem(STABracketPriceLedger; "STA Bracket Price Ledger")
            {
                DataItemTableView = where("G/L Entry No." = filter('0'));
                trigger OnPreDataItem()
                var
                    STABracketPriceCode: Record "STA Bracket Price Code";
                begin
                    STABracketPriceCode.SetFilter("Posting Account", '<>%1', '');
                    STABracketPriceCode.SetFilter("Balance Account", '<>%1', '');
                    STABracketPriceCode.FindSet(false);
                    repeat
                        GlobalPostingAccountDictionary.Add(STABracketPriceCode."Bracket Price Code", STABracketPriceCode."Posting Account");
                        GlobalBalanceAccountDictionary.Add(STABracketPriceCode."Bracket Price Code", STABracketPriceCode."Balance Account");
                    until STABracketPriceCode.Next() = 0;
                end;

                trigger OnAfterGetRecord()
                var
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine.SetRange("SBCTA ID", STABracketPriceLedger.SystemId);
                    if not GenJournalLine.IsEmpty() then 
                        CurrReport.Skip();
                    GenJournalLine.InitNewLine(GlobalOptionJournalPostingDate, WorkDate(), WorkDate(), StrSubstNo('%1 %2 - %3 - %4 - %5', STABracketPriceLedger."Document Type", STABracketPriceLedger."Document No.", STABracketPriceLedger."Item No.", STABracketPriceLedger."Document Line No.", STABracketPriceLedger."Bracket Price Code"), STABracketPriceLedger."Shortcut Dimension 1 Code", STABracketPriceLedger."Shortcut Dimension 2 Code", STABracketPriceLedger."Dimension Set ID", '');
                    GenJournalLine."Line No." := GlobalLastJournalLineNo;
                    GenJournalLine."Journal Template Name" := BracketJournalBatch."Journal Template Name";
                    GenJournalLine."Journal Batch Name" := BracketJournalBatch."Name";
                    GenJournalLine."SBCTA ID" := STABracketPriceLedger.SystemId;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := GlobalPostingAccountDictionary.Get(STABracketPriceLedger."Bracket Price Code");
                    GenJournalLine."Bal. Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Bal. Account No." := GlobalBalanceAccountDictionary.Get(STABracketPriceLedger."Bracket Price Code");
                    GenJournalLine.Validate(Amount, STABracketPriceLedger."Bracket Amount"); //No need to reverse here. We want to credit the posting account on the income statement and debit the balance account which is the bracket account. 
                    GenJournalLine."Document No." := GetJournalDocumentNo(GenJournalLine);
                    GenJournalLine.Insert(true);
                    GlobalLastJournalLineNo := GenJournalLine."Line No." + 10;
                end;
            }
            trigger OnPreDataItem()
            begin
                BracketJournalBatch.SetRange("Journal Template Name", 'GENERAL');
                BracketJournalBatch.SetRange("Name", GlobalBracketJournalBatchName);
            end;

            trigger OnAfterGetRecord()
            var
                GenJournalLine: Record "Gen. Journal Line";
            begin
                GenJournalLine.SetRange("Journal Template Name", BracketJournalBatch."Journal Template Name");
                GenJournalLine.SetRange("Journal Batch Name", BracketJournalBatch."Name");
                if GenJournalLine.FindLast() then
                    GlobalLastJournalLineNo := GenJournalLine."Line No." + 10;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(Option_JournalPostingDate; GlobalOptionJournalPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Posting Date';
                        ToolTip = 'The date that the journal will be posted to the general ledger.';
                    }
                    field(Option_BracketJournalBatch; GlobalBracketJournalBatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Bracket Journal Batch';
                        ToolTip = 'The journal batch that the journal lines will be posted to.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJournalBatch: Record "Gen. Journal Batch";
                            GeneralJournalBatches: Page "General Journal Batches";
                        begin
                            GenJournalBatch.SetRange("Journal Template Name", 'GENERAL');
                            GeneralJournalBatches.LookupMode(true);
                            GeneralJournalBatches.SetTableView(GenJournalBatch);
                            if GeneralJournalBatches.RunModal() <> Action::LookupOK then
                                exit;
                            GeneralJournalBatches.GetRecord(GenJournalBatch);
                            GlobalBracketJournalBatchName := GenJournalBatch."Name";
                        end;
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    var
        GlobalPostingAccountDictionary: Dictionary of [Code[20], Code[20]];
        GlobalBalanceAccountDictionary: Dictionary of [Code[20], Code[20]];
        GlobalLastJournalLineNo: Integer;
        GlobalOptionJournalPostingDate: Date;
        GlobalBracketJournalBatchName: Code[10];


    local procedure GetJournalDocumentNo(GenJournalLine: Record "Gen. Journal Line") JournalDocumentNo: Code[20]
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
        // Commit();
        JournalDocumentNo := NoSeriesManagement.GetNextNo(GenJournalBatch."No. Series", WorkDate(), true);
    end;
}