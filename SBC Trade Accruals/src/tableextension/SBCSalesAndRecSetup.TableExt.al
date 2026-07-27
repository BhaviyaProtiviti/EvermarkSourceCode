tableextension 50700 SBCSalesAndRecSetup extends "Sales & Receivables Setup"
{
    fields
    {
        field(50700; "TradeAccrualsPostingTemplate"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Trade Accruals Posting Template';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(50701; "TradeAccrualsPostingBatch"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Trade Accruals Posting Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("TradeAccrualsPostingTemplate"));
        }
        field(50702; "TradeEnabled"; boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Trade Accruals';
        }
        field(50703; "TradeAccrualsAutoPostJourLines"; boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Auto Post Journal Lines';
        }
    }
}