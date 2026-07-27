/// <summary>
/// Page SBCTA Trade Budget Setup (ID 50204).
/// </summary>
page 50204 "SBCTA Trade Budget Setup"
{
    ApplicationArea = All;
    Caption = 'Trade Posting Setup';
    PageType = List;
    SourceTable = "SBCTA Trade Budget Setup";
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
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field allows for granular posting settings for a particular customer within a Customer Posting Group.';
                    Visible = false;
                }
                field("Posting Account"; Rec."Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to.';
                    Editable = PostingAccountEditable;
                }
                field("Balance Account"; Rec."Balance Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be balanced against.';
                }
                field("Grouping Customer No."; Rec."Grouping Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Credits will be created using this grouping customer.';
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