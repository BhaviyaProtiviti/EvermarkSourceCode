/// <summary>
/// Page SBCTA Trade Budget (ID 50205).
/// </summary>
page 50205 "SBCTA Trade Budget"
{
    Caption = 'Trade Budget';
    PageType = Card;
    SourceTable = "SBCTA Trade Budget";


    layout
    {
        //Todo(Jump to Setup from here)
        //todo(Add Customer Posting Group and Customer Here, too. So that we can more easily define the budget rates for each customer. Some customer posting groups may have different rates.)
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = GlobalActiveBudget;

                field("Trade Budget Code"; Rec."Trade Budget Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Trade Budget and set of rates associated with it.';
                }
                field("Group Type"; Rec."Group Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the type of Group that the budget is for.';
                }
                field("Group Code"; Rec."Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Customer Posting Group that the Trade Budget applies to.';
                    Enabled = (Rec."Location Code" = '') or Rec."Use Item Category Matching";
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This dimension value can be used to match instead of the Group Code.';
                    Enabled = (Rec."Location Code" = '') or Rec."Use Item Category Matching";
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'A brief description of the purpose of the trade budget.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date that the budget is first active.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date that the budget is last allowed to be active.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, the budget can be used for the specified date range.';
                }
                group(ItemLedgerFiltering)
                {
                    Caption = 'Item Ledger Filtering';
                    Visible = GlobalItemLedgerEntryFieldsEnabled;
                    Enabled = GlobalItemLedgerEntryFieldsEnabled;
                    Editable = GlobalItemLedgerEntryFieldsEnabled;
                    Description = 'All of these fields must be set if they are to be used. " " is an acceptable value for enums.';
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, a specfic budget for a location can be used. If this is not set, then the budget can be used for all locations.';

                    }
                    field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is used to make the application of this budget more granular.';
                        Enabled = Rec."Location Code" <> '';
                        ShowMandatory = Rec."Location Code" <> '';
                    }
                    field("Item Ledger Document Type"; Rec."Item Ledger Document Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is used in combination with the Item Ledger Entry Type to make the application of this budget more granular.';
                        Enabled = Rec."Location Code" <> '';
                        ShowMandatory = Rec."Location Code" <> '';
                    }
                    field("Unit of Measure Code"; Rec."Unit of Measure Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is used in combination with the other Item Ledger Entry granularity fields to apply this budget only when the item ledger matches the values set in these fields.';
                        Enabled = Rec."Location Code" <> '';
                        ShowMandatory = Rec."Location Code" <> '';
                    }
                    field("Use Item Category Matching"; Rec."Use Item Category Matching")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, the Item Category will also be used with Dimension Matching, if enabled, to further narrow down budget usage.';
                        Enabled = Rec."Location Code" <> '';
                        trigger OnValidate()
                        begin
                            if not GlobalItemLedgerEntryFieldsEnabled then
                                exit;
                            // SetItemNoVisibility(not Rec."Use Item Category Matching");
                        end;
                    }
                }
            }


            part(Rates; "SBCTA Trade Budget Rates")
            {
                UpdatePropagation = SubPart;
                SubPageLink = "Trade Budget Code" = field("Trade Budget Code");
                ApplicationArea = All;
                Editable = GlobalActiveBudget;


            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {
                ApplicationArea = All;
                Caption = 'Recalculate';
                ToolTip = 'Recalculate the budget spend based on Accruals.';
                Enabled = GlobalActiveBudget;
                Visible = GlobalActiveBudget;
                Image = Recalculate;
                trigger OnAction()
                var
                    SBCTARecalculateBudgetSpend: Report "SBCTA Recalculate Budget Spend";
                    SBCTATradeBudget: Record "SBCTA Trade Budget";
                begin
                    SBCTATradeBudget := Rec;
                    SBCTATradeBudget.SetRecFilter();
                    SBCTARecalculateBudgetSpend.SetTableView(SBCTATradeBudget);
                    SBCTARecalculateBudgetSpend.UseRequestPage(false);
                    SBCTARecalculateBudgetSpend.RunModal();
                    CurrPage.Update(false);
                end;
            }

            action(CopyArchiveBudget)
            {
                ApplicationArea = All;
                Caption = 'Copy and Archive Budget';
                ToolTip = 'Copies an existing budget setup to a new budget and archive the old budget.';
                Enabled = GlobalActiveBudget;
                Visible = GlobalActiveBudget;
                Image = Archive;
                trigger OnAction()
                var
                    SBCTATradeBudget: Record "SBCTA Trade Budget";
                begin
                    if not GlobalActiveBudget then
                        exit;
                    CurrPage.SetSelectionFilter(SBCTATradeBudget);
                    if not (SBCTATradeBudget.HasFilter() or SBCTATradeBudget.MarkedOnly()) then begin
                        SBCTATradeBudget := Rec;
                        SBCTATradeBudget.SetRecFilter();
                    end;
                    Report.RunModal(Report::"SBCTA Copy & Archive Budget", true, false, SBCTATradeBudget);
                    CurrPage.Update(false);

                end;

            }


        }

        area(Promoted)
        {
            actionref("Recalculate_Promoted"; Recalculate)
            {

            }

            actionref("CopyArchiveBudget_Promoted"; CopyArchiveBudget)
            {

            }
        }
    }

    var
        GlobalActiveBudget: Boolean;
        GlobalItemLedgerEntryFieldsEnabled: Boolean;

    trigger OnAfterGetRecord()
    begin
        GlobalActiveBudget := not Rec.Archived;
        GlobalItemLedgerEntryFieldsEnabled := Rec."Group Type" = "SBCTA Budget Group Type"::Item;
        // SetItemNoVisibility(not Rec."Use Item Category Matching" and  GlobalItemLedgerEntryFieldsEnabled);
         SetItemNoVisibility(GlobalItemLedgerEntryFieldsEnabled);
    end;

    local procedure SetItemNoVisibility(ItemNoVisibile: boolean)
    begin
        CurrPage.Rates.Page.SetItemNoVisibility(ItemNoVisibile);
    end;

}