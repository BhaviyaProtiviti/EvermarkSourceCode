/// <summary>
/// Page SBCTA Indirect Posting Setup (ID 50211).
/// </summary>
page 50211 "SBCTA Indirect Posting Setup"
{
    ApplicationArea = All;
    Caption = 'Indirect Cost Posting Setup';
    PageType = List;
    SourceTable = "SBCTA Indirect Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Trade Budget Rate Code"; Rec."Trade Budget Rate Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Item Category Code that the Trade Budget Rate applies to.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field allows for granular posting settings for a particular customer within a Customer Posting Group.';
                }
                field("Posting Account"; Rec."Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to for Purchase Transactions.';
                    Editable = PostingAccountEditable;
                }
                field("Sales Posting Account"; Rec."Sales Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to for Sales Transactions.';
                    Editable = PostingAccountEditable;
                }
                field("Balance Account"; Rec."Balance Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be balanced against.';
                }
            }
        }
    }
    var
        PostingAccountEditable: Boolean;

    trigger OnInit()
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        PostingAccountEditable := SBCTATradeBudgetOptions.GetOptions()."Credit Type" = SBCTATradeBudgetOptions."Credit Type"::GL;
    end;
}