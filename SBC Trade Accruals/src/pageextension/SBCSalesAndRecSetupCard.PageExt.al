pageextension 50700 SBCSalesAndRecSetupCard extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(content)
        {
            group(SBCTradeAccruals)
            {
                Caption = 'Trade Accruals';
                field(Enabled; Rec.TradeEnabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable Trade Accruals functionality for Sales and Receivables.';
                }
                field(AutoPostJourLines; Rec.TradeAccrualsAutoPostJourLines)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable automatic posting of Trade Accruals journal lines.';
                }
                field("TradeAccrualsPostingTemplate"; Rec."TradeAccrualsPostingTemplate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the journal template used for posting trade accruals.';
                }
                field("TradeAccrualsPostingBatch"; Rec."TradeAccrualsPostingBatch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the journal batch used for posting trade accruals.';
                }
            }
        }
    }
}