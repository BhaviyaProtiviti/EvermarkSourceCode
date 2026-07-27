/// <summary>
/// Page SBCTA Trade Budgets (ID 50201).
/// </summary>
page 50201 "SBCTA Trade Budgets"
{
    ApplicationArea = All;
    Caption = 'Trade Budgets';
    PageType = List;
    SourceTable = "SBCTA Trade Budget";
    UsageCategory = Lists;
    CardPageId = "SBCTA Trade Budget";
    SourceTableView = sorting("Group Type", "Shortcut Dimension 1 Code") where(Archived = const(false));


    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                    ToolTip = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This dimension value can be used to match instead of the Group Code.';
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'A brief description of the purpose of the trade budget.';
                }
                field(Archived; Rec.Archived)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, the budget is no longer active and cannot be used.';
                }
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
                Image = Recalculate;
                trigger OnAction()
                var
                    SBCTARecalculateBudgetSpend: Report "SBCTA Recalculate Budget Spend";
                begin
                    SBCTARecalculateBudgetSpend.Run();
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

            action(CreateTradeLedgers)
            {
                Caption = 'Create Trade Ledgers';
                trigger OnAction()
                var
                    SBCTACreateTradeLedgers: Codeunit "SBCTA Create Trade Ledgers";
                begin
                    SBCTACreateTradeLedgers.Run();
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

    trigger OnAfterGetCurrRecord()
    begin
        GlobalActiveBudget := not Rec.Archived;
    end;

}