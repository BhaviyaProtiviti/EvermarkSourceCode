report 50100 "SBC Post EDI Batches"
{
    Caption = 'SBC Post EDI Batches';
    ProcessingOnly = true;
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Journal Template"; "Item Journal Template")
        {
            trigger OnAfterGetRecord()
            begin
                if (NOT Process947) and (NOT process846) then
                    CurrReport.Skip();

                ItemJournalBatch.SETRANGE("Journal Template Name", Name);
                if Process846 and (NOT process947) then
                    ItemJournalBatch.SETFILTER(Name, 'EDI-INV*');
                if Process947 and (NOT process846) then
                    ItemJournalBatch.SETFILTER(Name, 'EDIAD*');
                if Process846 and process947 then
                    ItemJournalBatch.SETFILTER(Name, 'EDI-INV*|EDIAD*');
                IF ItemJournalBatch.FINDFIRST() THEN
                    REPEAT
                        ItemJournalLine.SETRANGE("Journal Template Name", ItemJournalBatch."Journal Template Name");
                        ItemJournalLine.SETRANGE("Journal Batch Name", ItemJournalBatch.Name);
                        ItemJournalLine.SETFILTER("Item No.", '<>%1', '');
                        ItemJournalLine.SETFILTER(Quantity, '<>%1', 0);
                        IF ItemJournalLine.FINDFIRST() THEN BEGIN
                            COMMIT();
                            IF GUIALLOWED THEN
                                Wind.UPDATE(1, STRSUBSTNO('Posting %1 journal in %2 template\%3 Journal lines', ItemJournalBatch.Name, ItemJournalBatch."Journal Template Name", ItemJournalLine.COUNT));
                            IF CODEUNIT.RUN(CODEUNIT::"SBC Post One Batch", ItemJournalBatch) THEN;
                        END ELSE
                            if (ItemJournalBatch.Name <> 'EDI-INV') and (ItemJournalBatch.Name <> 'EDIAD') then
                                ItemJournalBatch.DELETE();
                    UNTIL ItemJournalBatch.NEXT() = 0;
            end;

            trigger OnPostDataItem()
            begin
            end;

            trigger OnPreDataItem()
            begin
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Process947; Process947)
                    {
                        ApplicationArea = All;
                        Caption = 'Process 947';
                    }
                    field(Process846; Process846)
                    {
                        ApplicationArea = All;
                        Caption = 'Process 846';
                    }
                }
            }
        }
    }

    var
        Process947: Boolean;
        Process846: Boolean;

    trigger OnPreReport()
    begin
        IF GUIALLOWED THEN
            Wind.OPEN('@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    end;

    trigger OnPostReport()
    begin
        IF GUIALLOWED THEN
            Wind.CLOSE();
    end;

    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        Wind: Dialog;
}

