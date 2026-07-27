/// <summary>
/// Page SBCTA Trade Budgets (ID 50201).
/// </summary>
page 50216 "SBCTA Archived Budgets"
{
    ApplicationArea = All;
    Caption = 'Archived Trade Budgets';
    PageType = List;
    SourceTable = "SBCTA Trade Budget";
    UsageCategory = Lists;
    CardPageId = "SBCTA Trade Budget";
    SourceTableView = where(Archived=const(true));


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


        }

        area(Promoted)
        {
            actionref("Recalculate_Promoted"; Recalculate)
            {

            }
        }
    }

}