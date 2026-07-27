/// <summary>
/// Page SBCTA Trade Budget Options (ID 50200).
/// </summary>
page 50200 "SBCTA Trade Budget Options"
{
    Caption = 'Trade Options';
    PageType = Card;
    SourceTable = "SBCTA Trade Budget Options";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(TradeLedgerEntries)
                {
                    Caption = 'Ledger Entries';
                    field("Disable Solution"; Rec."Disable Solution")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, all event hooks will be disabled and the solution will not run. This is useful for testing and troubleshooting.';
                    }
                    field("Auto-Post Trade Accrual"; Rec."Auto-Post Trade Accrual")
                    {
                        Caption = 'Auto-Create Ledger Entries';
                        ApplicationArea = All;
                        ToolTip = 'When this is set, Trade Ledger Entries will be created during Sales transaction posting.';
                        Importance = Promoted;
                    }
                    field("Auto-Post Sales Credits"; Rec."Auto-Post Sales Credits")
                    {
                        ApplicationArea = All;
                        Visible = false;
                        ToolTip = 'When this is set, Trade Budget Ledger Entries will be created after each successful Sales Credit Memo Posting.';
                    }
                    field("Customer Type"; Rec."Customer Type")
                    {
                        ApplicationArea = All;
                        Visible = false;
                        ToolTip = 'Setting this will accrue trade spend from the selected customer type.';
                    }
                    field("Use Dimension Matching"; Rec."Use Dimension Matching")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, Indirect COGs will be matched based on the dimension value rather than the item category code.';
                        Visible = true;
                        Importance = Additional;
                    }

                    group(IndirectCOGs)
                    {
                        Caption = 'Indirect COGs';
                        field("Auto-Post Indirect Cost"; Rec."Auto-Post Indirect Cost")
                        {
                            ApplicationArea = All;
                            ToolTip = 'When this is set, Indirect Costs Ledger Entries will be created during the posting of transactions that affect net global inventory value--all transactions except standard Transfers.';
                            Visible = true;
                            Importance = Promoted;
                        }

                        field("Burden Purchase Receipts"; Rec."Burden Purchase Receipts")
                        {
                            ApplicationArea = All;
                            ToolTip = 'When this is set, Indirect COGs will be based on Purchase Receipts and Purchase Return Shipments rather than Invoices and Credits.';
                            Visible = true;
                            Importance = Additional;
                        }
                        field("Skip Inbound IC Check"; Rec."Skip Inbound IC Check")
                        {
                            ApplicationArea = All;
                            ToolTip = 'When this is set, a check for an appropriate inbound Indirect Cost Value Entry will not be checked for.';
                            Visible = true;
                            Importance = Additional;
                        }
                        group(AdjustCost)
                        {
                            Caption = 'Adjust Cost';
                            field("Skip During Adjust Cost"; Rec."Skip During Adjust Cost")
                            {
                                ApplicationArea = All;
                                ToolTip = 'When this is set, Indirect Cost Value Entries created by this solution will be skipped during the Adjust Cost process.';
                                Visible = true;
                                Importance = Additional;
                            }
                            field("Exclude Sales Indirect Cost"; Rec."Exclude Sales Indirect Cost")
                            {
                                ApplicationArea = All;
                                ToolTip = 'When this is set, Sales Indirect Costs are excluded from Actual Cost during Adjust Cost.';
                            }
                            field("Exclude Purchase Indirect Cost"; Rec."Exclude Purchase Indirect Cost")
                            {
                                ApplicationArea = All;
                                ToolTip = 'When this is set, Purchase Indirect Costs are excluded from Actual Cost during Adjust Cost.';
                            }
                        }
                    }
                    group(BracketPricing)
                    {
                        Caption = 'Bracket Pricing';

                        field("Post Bracket Entries to GL"; Rec."Post Bracket Entries to GL")
                        {
                            ApplicationArea = All;
                            ToolTip = 'When this is set, Bracket Entries will be posted to the G/L.';
                            Importance = Promoted;
                        }
                        field("Bracket Dimension Code"; Rec."Bracket Dimension Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'This is the dimension code that will be used to post Bracket Entries to the G/L.';
                        }
                    }

                }
                group(Accruals)
                {

                    field("Calculation Basis"; Rec."Calculation Basis")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is the basis of the calculation that this Trade Accrual Line was produced for.';
                        Visible = false;
                    }
                    field("Accrual Journal Template"; Rec."Accrual Journal Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'The Journal Template to use when creating Accrual Journal Lines.';
                    }
                    field("Summarize Accrual Postings"; Rec."Summarize Accrual Postings")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, Trade Budget Ledger Entries will be Budget Rate Code.';
                        Visible = false;
                    }
                    field("Allow Direct Posting"; Rec."Allow Direct Posting")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, direct posting is allowed in the General Journal for Trade Ledger Journal Entries.';
                        Visible = false;
                    }
                    field("Swap Receivables Account"; Rec."Swap Receivables Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, the Receivables Account will be swapped for the Posting Account when posting a trade accrual credit.';
                        Visible = false;
                    }
                    field("Ignore Trade Target"; Rec."Ignore Trade Target")
                    {
                        ApplicationArea = All;
                        ToolTip = 'When this is set, the Trade Target will be ignored when calculating Trade Accruals.';
                        Visible = false;
                    }
                    group(DirectTrade_Accruals)
                    {
                        Caption = 'Direct Trade Accruals';
                        field("Credit Type"; Rec."Credit Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'This options determines if accrual credits are created against the Posting Account in the Trade Posting Setup and Indirect Cost Posting Setup or against the Customer the trade spend was generated for.';
                            Visible = false;
                        }
                        field("Create Indirect Credit"; Rec."Create Indirect Credit")
                        {
                            ApplicationArea = All;
                            ToolTip = 'When this is set, Credits for Direct and Indirect Spend will be created. When this is not set, only Direct Spend credits will be created.';
                            Visible = false;
                        }
                        field("Accrual Batch Name"; Rec."Accrual Batch Name")
                        {
                            ApplicationArea = All;
                            ToolTip = 'The Batch Name to use when creating Accrual Journal Lines.';
                        }
                    }

                    group(IndirectCogs_Accrual)
                    {
                        Caption = 'Indirect COGS Accrual';
                        field("Indirect COGs Template"; Rec."Indirect COGs Batch")
                        {
                            ApplicationArea = All;
                            ToolTip = 'The Journal Template to use when creating Indirect COGs Journals.';
                        }
                    }

                }

            }
        }
    }
}