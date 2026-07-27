/// <summary>
/// Report SBCTA Create Accrual Credits (ID 50201).
/// </summary>
report 50201 "SBCTA Create Accrual Credits"
{
    Caption = 'Create Trade Credits';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = true;
    dataset
    {
        dataitem(SBCTATradeAccrualHeader; "SBCTA Trade Accrual Header")
        {
            RequestFilterFields = "Trade Accrual No.", "Trade Accrual DateTime";

            // dataitem("SBCTA Trade Accrual Line";"SBCTA Trade Accrual Line")
            // {
            //     RequestFilterFields = "Trade Accrual No.","Trade Budget Code","Trade Budget Rate Code","Trade Accrual Type";
            //     DataItemTableView = where("Accrual Journal Batch"=const(''),"Accrual Journal Template"=const(''),"Accrual Journal Line"=const(0));
            //     DataItemLinkReference = SBCTATradeAccrualHeader;
            //     DataItemLink = "Trade Accrual No." = field("Trade Accrual No.");
            // }
            // trigger OnPreDataItem()
            // begin
            //     if not SBCTATradeAccrualHeader.HasFilter() then
            //         SBCTATradeAccrualHeader.SetFilter("Trade Accrual No.", '%1..', 0);
            // end;
            trigger OnPreDataItem()
            begin
                OpenDialogue();
            end;

            trigger OnAfterGetRecord()
            var
                CurrentSBCTATradeAccrualHeader: Record "SBCTA Trade Accrual Header";
            begin
                CurrentSBCTATradeAccrualHeader := SBCTATradeAccrualHeader;
                CurrentSBCTATradeAccrualHeader.SetSuppressAlerts(GlobalSuppressAlerts);

                if GlobalAccrualDateFilter <> '' then
                    CurrentSBCTATradeAccrualHeader.SetDateFilter(GlobalAccrualDateFilter);
                if GlobalJournalPostingDate <> 0D then
                    CurrentSBCTATradeAccrualHeader.SetJournalPostingDate(GlobalJournalPostingDate);
                case true of
                    GlobalCreateTradeCredits and (CurrentSBCTATradeAccrualHeader."Accrual Type" = "SBCTA Accrual Type"::"Trade Spend"):
                        CurrentSBCTATradeAccrualHeader.CreateAccrualJournalEntries(GlobalGenJournalLineTemp, "SBCTA Accrual Type"::"Trade Spend");
                    GlobalCreateIndirectCogsCredits and (CurrentSBCTATradeAccrualHeader."Accrual Type" = "SBCTA Accrual Type"::"Indirect COGs Spend"):
                        CurrentSBCTATradeAccrualHeader.CreateAccrualJournalEntries(GlobalGenJournalLineTemp, "SBCTA Accrual Type"::"Indirect COGs Spend");
                end;
            end;

            trigger OnPostDataItem()
            begin
                CloseDialog();
            end;


        }


    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnPostReport()
    begin
        SBCTATradeAccrualHeader.SetSuppressAlerts(GlobalSuppressAlerts);
        // if GlobalAccrualDateFilter <> '' then
        //     SBCTATradeAccrualHeader.SetDateFilter(GlobalAccrualDateFilter);
        // if GlobalJournalPostingDate <> 0D then
        //     SBCTATradeAccrualHeader.SetJournalPostingDate(GlobalJournalPostingDate);
        if GlobalGenJournalLineTemp.IsEmpty() then
            exit;
        SBCTATradeAccrualHeader.CreateAccrualJournalFromTempBuffer(GlobalGenJournalLineTemp);
    end;

    internal procedure SetSuppressAlerts(SuppressAlerts: Boolean)
    begin
        GlobalSuppressAlerts := SuppressAlerts;
    end;

    local procedure OpenDialogue()
    begin
        if not GuiAllowed() then
            exit;
        GlobalDialog.Open(ProcessingDialogTextLabel);
    end;

    local procedure CloseDialog()
    begin
        if not GuiAllowed() then
            exit;
        GlobalDialog.Close();
    end;

    internal procedure SetDateFilter(DateAccrualFilter: Text)
    begin
        GlobalAccrualDateFilter := DateAccrualFilter;
    end;

    internal procedure SetJournalPostingDate(JournalPostingDate: Date)
    begin
        GlobalJournalPostingDate := JournalPostingDate;
    end;

    internal procedure SetCreateTradeCredits(CreateTradeCredits: Boolean)
    begin
        GlobalCreateTradeCredits := CreateTradeCredits;
    end;

    internal procedure SetCreateIndirectCogsCredits(CreateIndirectCogsCredits: Boolean)
    begin
        GlobalCreateIndirectCogsCredits := CreateIndirectCogsCredits;
    end;

    var
        GlobalSuppressAlerts: Boolean;
        GlobalGenJournalLineTemp: Record "Gen. Journal Line" temporary;
        ProcessingDialogTextLabel: Label 'Creating Journal Entries.';
        GlobalDialog: Dialog;
        GlobalAccrualDateFilter: Text;
        GlobalCreateTradeCredits: Boolean;
        GlobalCreateIndirectCogsCredits: Boolean;
        GlobalJournalPostingDate: Date;
}