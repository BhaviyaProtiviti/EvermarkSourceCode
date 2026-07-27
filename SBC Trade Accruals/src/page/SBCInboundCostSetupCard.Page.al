page 50703 "SBCInboundCostSetupCard"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = SBCInboundCostSetup;
    Caption = 'Inbound Cost Setup';
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Inbound Cost Setup';
                field("Enable Indirect Costs"; Rec."Enable Indirect Costs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable or disable the indirect costs functionality.';
                }
                field("Auto Post Indirect Costs"; Rec."Auto Post Indirect Costs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable automatic posting of Indirect Costs journal lines.';
                }
                field("Inbound Cost Journal Template"; Rec."Inbound Cost Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'The journal template used for inbound cost entries.';
                }
                field("Inbound Cost Journal Batch"; Rec."Inbound Cost Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'The journal batch used for inbound cost entries.';
                }
                field("Inbound Freight Acc. Account"; Rec."Inbound Freight Acc. Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for accruing inbound freight costs.';
                }
                field("Accd Freight Inb. Acc."; Rec."Accd Freight Inb. Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for accruing freight costs that have been recognized.';
                }
                field("COGS Inb. Freight Acc."; Rec."COGS Inb. Freight Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for recording cost of goods sold related to inbound freight.';
                }
                field("WH Inbound Acc."; Rec."WH Inbound Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for accruing warehouse inbound costs.';
                }
                field("Accd WH Inbound Acc."; Rec."Accd WH Inbound Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for accruing warehouse inbound costs that have been recognized.';
                }
                field("COGS WH Inbound Acc."; Rec."COGS WH Inbound Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for recording cost of goods sold related to warehouse inbound costs.';
                }
                field("WH Overhead Acc."; Rec."WH Overhead Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for accruing fixed warehouse overhead costs.';
                }
                field("Accd WH Overhead Acc."; Rec."Accd WH Overhead Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for accruing fixed warehouse overhead costs that have been recognized.';
                }
                field("COGS WH Overhead Acc."; Rec."COGS WH Overhead Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The account used for recording cost of goods sold related to fixed warehouse overhead costs.';
                }
                field("SBC Custom/Duty Acc."; Rec."SBC Custom/Duty Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the COGS Custom/Duty Acc. field.', Comment = '%';
                }
                field("SBC Accd Custom/Duty Acc."; Rec."SBC Accd Custom/Duty Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accd Custom/Duty Acc. field.', Comment = '%';
                }
                field("SBC COGS Custom/Duty Acc."; Rec."SBC COGS Custom/Duty Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the COGS Custom/Duty Acc. field.', Comment = '%';
                }
                field(CostCalcType; Rec.CostCalcType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the method for calculating indirect costs, either per unit or as a percentage.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}