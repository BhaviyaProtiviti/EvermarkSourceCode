/// <summary>
/// Page SBCTA Trade Posting Subform (ID 50212).
/// </summary>
page 50212 "SBCTA Trade Posting Subform"
{
    Caption = 'Trade Posting Subform';
    PageType = ListPart;
    SourceTable = "SBCTA Trade Budget Setup";

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
                    Visible = false;
                    Editable = false;
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
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This identifies the dimension value that can be used to match this setup along with the Customer Posting Group.';
                    Visible = true;
                    Editable = true;
                }
                field("Posting Account"; Rec."Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to.';
                    Editable = GlobalPostingAccountEditable;
                    // Enabled = GlobalPostingAccountEditable;
                    Visible = GlobalPostingAccountEditable;
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
    actions
    {
        area(Processing)
        {
            action(AddCustomerPostingGroups)
            {
                ApplicationArea = All;
                Caption = 'Add Customer Posting Groups';
                Image = CustomerGroup;
                trigger OnAction()
                var
                    CustomerPostingGroup: Record "Customer Posting Group";
                    SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
                begin
                    if GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code" = '' then
                        exit;
                    // SetCustomerPostingGroupFilter(CustomerPostingGroup);
                    CustomerPostingGroup.SetLoadFields("Code");
                    if CustomerPostingGroup.IsEmpty() then
                        exit;
                    CustomerPostingGroup.FindSet();
                    repeat
                        SBCTATradeBudgetSetup."Trade Budget Rate Code" := GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code";
                        SBCTATradeBudgetSetup."Customer Posting Group" := CustomerPostingGroup.Code;
                        if not SBCTATradeBudgetSetup.Find() then
                            SBCTATradeBudgetSetup.Insert(true);
                    until CustomerPostingGroup.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
        }

    }
    var
        GlobalPostingAccountEditable: Boolean;
        GlobalSBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes";

    trigger OnInit()
    var
        SBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions := SBCTATradeBudgetOptions.GetOptions();
        GlobalPostingAccountEditable := SBCTATradeBudgetOptions."Swap Receivables Account" or (SBCTATradeBudgetOptions."Credit Type" = SBCTATradeBudgetOptions."Credit Type"::GL);
    end;

    // trigger OnOpenPage() 
    // begin
    //     Rec.SetFilter("Trade Budget Rate Code",'%1',GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code");
    //     CurrPage.SetTableView(Rec);
    // end;
    internal procedure SetTableViewOnSubform()
    begin
        Rec.SetFilter("Trade Budget Rate Code", '%1', GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code");
        CurrPage.SetTableView(Rec);
        CurrPage.Update(false);
    end;

    internal procedure SetGlobalRateCode(SBCTATradeBudgetRateCodes: Record "SBCTA Trade Budget Rate Codes")
    begin
        GlobalSBCTATradeBudgetRateCodes := SBCTATradeBudgetRateCodes;
    end;

    // local procedure SetCustomerPostingGroupFilter(var CustomerPostingGroup: Record "Customer Posting Group")
    // var
    //     SelectionFilterManagement: Codeunit SelectionFilterManagement;
    //     SBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup";
    //     TempSBCTATradeBudgetSetup: Record "SBCTA Trade Budget Setup" temporary;
    //     SelectionFilterText: Text;
    //     RecRefSBCTATradeBudgetSetup: RecordRef;
    // begin
    //     SBCTATradeBudgetSetup.SetFilter("Trade Budget Rate Code", GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code");
    //     if SBCTATradeBudgetSetup.IsEmpty() then
    //         exit;
    //     SBCTATradeBudgetSetup.FindSet(false);
    //     repeat
    //         TempSBCTATradeBudgetSetup := SBCTATradeBudgetSetup;
    //         TempSBCTATradeBudgetSetup.Insert(true);
    //     until SBCTATradeBudgetSetup.Next() = 0;
    //     RecRefSBCTATradeBudgetSetup.GetTable(TempSBCTATradeBudgetSetup);
    //     SelectionFilterText := SelectionFilterManagement.GetSelectionFilter(RecRefSBCTATradeBudgetSetup, SBCTATradeBudgetSetup.FieldNo("Customer Posting Group"));
    //     SelectionFilterText := SelectionFilterText.Replace('|', '&<>');
    //     SelectionFilterText := '<>' + SelectionFilterText;
    //     CustomerPostingGroup.SetFilter(Code, SelectionFilterText);
    // end;
}