/// <summary>
/// Report SBCTA Copy and Archive Budget (ID 50208).
/// </summary>
report 50208 "SBCTA Copy & Archive Budget"
{
    ApplicationArea = All;
    Caption = 'Copy & Archive Trade Budget';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(DataItemSBCTATradeBudget; "SBCTA Trade Budget")
        {
            DataItemTableView = where(Archived = const(false));
            // RequestFilterFields = "Trade Budget Code";
            RequestFilterFields = "Start Date", "End Date", Enabled, "Group Code", "Group Type";
            RequestFilterHeading = 'Additional Budget Filters';


            dataitem(DataItemSBCTATradeBudgetRates; "SBCTA Trade Budget Rates")
            {
                DataItemLinkReference = DataItemSBCTATradeBudget;
                DataItemLink = "Trade Budget Code" = field("Trade Budget Code");

                trigger OnAfterGetRecord()
                begin
                    TempGlobalSBCTATradeBudgetRates.TransferFields(DataItemSBCTATradeBudgetRates);
                    TempGlobalSBCTATradeBudgetRates."Trade Budget Code" := GlobalUpdatedTradeBudgetCodeText;
                    TempGlobalSBCTATradeBudgetRates."Trade Budget Actual" := 0;
                    TempGlobalSBCTATradeBudgetRates.Insert();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                GlobalUpdatedTradeBudgetCodeText := DataItemSBCTATradeBudget."Trade Budget Code";
                GlobalUpdatedTradeBudgetCodeText := GlobalUpdatedTradeBudgetCodeText.Replace(GlobalOptionSearchText, GlobalOptionReplaceText);
                UpdateTradeBudgetCodeWithSuffix();
                if GuiAllowed then
                    GlobalStatusDialog.Update();
                TempGlobalSBCTATradeBudget.TransferFields(DataItemSBCTATradeBudget);
                TempGlobalSBCTATradeBudget."Trade Budget Code" := GlobalUpdatedTradeBudgetCodeText;
                TempGlobalSBCTATradeBudget."Start Date" := GlobalOptionStartDate;
                TempGlobalSBCTATradeBudget."End Date" := GlobalOptionEndDate;
                TempGlobalSBCTATradeBudget.Insert();
                DataItemSBCTATradeBudget.Archived := GlobalOptionCopyAndArchive;
                if DataItemSBCTATradeBudget.Archived then
                    DataItemSBCTATradeBudget.Modify();
            end;

            trigger OnPreDataItem()
            begin
                if GlobalOptionTradeBudgetFilterText <> '' then
                    DataItemSBCTATradeBudget.SetFilter("Trade Budget Code", GlobalOptionTradeBudgetFilterText);
                if GuiAllowed then
                    GlobalStatusDialog.Open(CopyingStatusLabel, DataItemSBCTATradeBudget."Trade Budget Code", GlobalUpdatedTradeBudgetCodeText);
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    GlobalStatusDialog.Close();
            end;
        }
    }


    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {

                group(CopyAndReplaceOptions)

                {
                    Caption = 'Copy and Replace Options';
                    
                    field(GlobalOptionCopyAndArchive; GlobalOptionCopyAndArchive)
                    {
                        ApplicationArea = All;
                        Caption = 'Copy and Archive';
                        ToolTip = 'This option will copy and then archive each budget processed by the report.';
                    }
                    field(GlobalOptionSearchText; GlobalOptionSearchText)
                    {
                        ApplicationArea = All;
                        Caption = 'Search Text';
                        ToolTip = 'This text will be searched for in the copied budget and replaced with the text in the Replace Text field.';
                    }
                    field(GlobalOptionReplaceText; GlobalOptionReplaceText)
                    {
                        ApplicationArea = All;
                        Caption = 'Replace Text';
                        ToolTip = 'This text will replace the text in the Search Text field in the copied budget.';
                    }
                    field(GlobalOptionStartDate; GlobalOptionStartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'New Start Date';
                        ToolTip = 'This date will be used as the start date for the copied budget.';
                    }
                    field(GlobalOptionEndDate; GlobalOptionEndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'New End Date';
                        ToolTip = 'This date will be used as the end date for the copied budget.';
                    }
                    field(GlobalOptionUseReplacementSuffix; GlobalOptionUseReplacementSuffix)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Replacement Suffix';
                        ToolTip = 'This option will append the Replacement Suffix to the end of the text in the Replace Text field in the copied budget.';
                    }
                    field(GlobalOptionReplacementSuffix; GlobalOptionReplacementSuffix)
                    {
                        ApplicationArea = All;
                        Caption = 'Replacement Suffix';
                        ToolTip = 'This text will be appended to the end of the text in the Replace Text field in the copied budget.';
                        Enabled = GlobalOptionUseReplacementSuffix;
                        Editable = GlobalOptionUseReplacementSuffix;
                    }
                    field(GlobalOptionTradeBudgetFilterText; GlobalOptionTradeBudgetFilterText)
                    {
                        ApplicationArea = All;
                        Caption = 'Trade Budget Filter Text';
                        ToolTip = 'This text will be used to filter the Trade Budgets to be copied.';
                        Editable = false;
                        Visible = GlobalTradeBudgetFilterTextVisible;
                        AssistEdit = true;
                        // trigger OnLookup(var Text: Text): Boolean
                        // begin
                        //     SetSelectionFilterText();
                        // end;

                        trigger OnAssistEdit()
                        begin
                            SetSelectionFilterText();
                        end;
                    }
                    field(GlobalOptionIgnoreOverlapCheck;GlobalOptionIgnoreOverlapCheck)
                    {
                        ApplicationArea = All;
                        Caption = 'Ignore Budget Overlap Check';
                        ToolTip = ' When this is set, budgets that have date overlaps will be allowed. Useful for budgets that will have more granularity added later.';
                    }
                }
            }
        }
        // actions
        // {
        //     area(processing)
        //     {
        //     }
        // }

        trigger OnOpenPage()
        var
            viewText: TExt;
        begin
            GlobalOptionCopyAndArchive := true;
            GlobalOptionReplacementSuffix := GenericReplaceLabel;
            viewText := DataItemSBCTATradeBudget.GetView();
            viewText := DataItemSBCTATradeBudget.Getview(true);
            GlobalTradeBudgetFilterTextVisible := not (DataItemSBCTATradeBudget.HasFilter() or DataItemSBCTATradeBudget.MarkedOnly());
            if GlobalTradeBudgetFilterTextVisible then
                DataItemSBCTATradeBudget.SetRange(Archived, false);
        end;

    }

    trigger OnPostReport()
    var
        NewSBCTATradeBudget: Record "SBCTA Trade Budget";
        NewSBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        if TempGlobalSBCTATradeBudget.IsEmpty() then
            exit;
        if GuiAllowed then
            GlobalStatusDialog.Open(ProcessingStatusLabel, TempGlobalSBCTATradeBudget."Trade Budget Code");

        TempGlobalSBCTATradeBudget.FindSet();
        repeat
            if GuiAllowed then
                GlobalStatusDialog.Update();
            NewSBCTATradeBudget.TransferFields(TempGlobalSBCTATradeBudget);
            NewSBCTATradeBudget.Insert(not GlobalOptionIgnoreOverlapCheck);
        until TempGlobalSBCTATradeBudget.Next() = 0;

        if TempGlobalSBCTATradeBudgetRates.IsEmpty() then
            exit;

        TempGlobalSBCTATradeBudgetRates.FindSet();
        repeat
            NewSBCTATradeBudgetRates.TransferFields(TempGlobalSBCTATradeBudgetRates);
            NewSBCTATradeBudgetRates.Insert(true);
        until TempGlobalSBCTATradeBudgetRates.Next() = 0;

        if GuiAllowed then
            GlobalStatusDialog.Close();
    end;

    local procedure UpdateTradeBudgetCodeWithSuffix()
    begin
        case true of
            not GlobalOptionUseReplacementSuffix:
                exit;
            StrLen(GlobalUpdatedTradeBudgetCodeText) <= 15:
                GlobalUpdatedTradeBudgetCodeText := GlobalUpdatedTradeBudgetCodeText + GlobalOptionReplacementSuffix;
            else
                GlobalUpdatedTradeBudgetCodeText := GlobalUpdatedTradeBudgetCodeText.Substring(1, MaxStrLen(GlobalUpdatedTradeBudgetCodeText) - StrLen(GlobalOptionReplacementSuffix)) + GlobalOptionReplacementSuffix;
        end;
    end;

    local procedure SetSelectionFilterText()
    var
        SBCTATradeBudget: Page "SBCTA Trade Budget";
        SelectionFilterManagement: Codeunit "SelectionFilterManagement";
        SelectionFilterRecord: Record "SBCTA Trade Budget";
        SelctionFilterRef: RecordRef;
        LookupAction: Action;
    begin
        SBCTATradeBudget.SetTableView(DataItemSBCTATradeBudget);
        SBCTATradeBudget.LookupMode(true);
        if not (SBCTATradeBudget.RunModal() = LookupAction::LookupOK) then
            exit;
        SBCTATradeBudget.SetSelectionFilter(SelectionFilterRecord);
        SelctionFilterRef.GetTable(SelectionFilterRecord);
        GlobalOptionTradeBudgetFilterText := SelectionFilterManagement.GetSelectionFilter(SelctionFilterRef, SelectionFilterRecord.FieldNo("Trade Budget Code"));
    end;

    var
        GlobalOptionCopyAndArchive: Boolean;
        GlobalOptionUseReplacementSuffix: Boolean;
        GlobalTradeBudgetFilterTextVisible: Boolean;
        GlobalOptionIgnoreOverlapCheck : Boolean;
        GlobalOptionStartDate: Date;
        GlobalOptionEndDate: Date;
        GlobalOptionSearchText: Code[20];
        GlobalOptionReplaceText: Code[20];
        GlobalOptionReplacementSuffix: Code[5];
        GenericReplaceLabel: Label '_COPY', locked = true;
        ProcessingStatusLabel: Label 'Processing #1#####', Locked = true;
        CopyingStatusLabel: Label 'Copying #1##### to #2##### in copy buffer', Locked = true;
        GlobalOptionTradeBudgetFilterText: Text;
        TempGlobalSBCTATradeBudget: Record "SBCTA Trade Budget" temporary;
        TempGlobalSBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates" temporary;
        GlobalUpdatedTradeBudgetCodeText: Text[20];
        GlobalStatusDialog: Dialog;
}