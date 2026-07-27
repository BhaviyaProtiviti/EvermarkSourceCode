/// <summary>
/// Page SBCTA Indirect Posting Subform (ID 50213).
/// </summary>
page 50213 "SBCTA Indirect Posting Subform"
{
    Caption = 'Indirect Posting Subform';
    PageType = ListPart;
    SourceTable = "SBCTA Indirect Posting Setup";

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
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Item Category Code that the Trade Budget Rate applies to.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field allows for granular posting settings for a particular customer within a Customer Posting Group.';
                    Visible = false;
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Customer Posting Group that the Trade Budget Rate applies to.';
                    TableRelation = "Customer Posting Group"."Code";
                }
                field("Posting Account"; Rec."Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to for Purchase Transactions.';
                    Editable = GlobalPostingAccountEditable;
                    // Enabled = GlobalPostingAccountEditable;
                    Visible = GlobalPostingAccountEditable;
                }
                field("Sales Posting Account"; Rec."Sales Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be posted to for Sales Transactions.';
                    Visible = GlobalPostingAccountEditable;
                    Editable = GlobalPostingAccountEditable;

                }
                field("Balance Account"; Rec."Balance Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Trade Budget Rate Code in the setup will be balanced against.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AddCItemCategories)
            {
                ApplicationArea = All;
                Caption = 'Add Item Categories';
                Image = ItemGroup;

                trigger OnAction()
                var
                    ItemCategory: Record "Item Category";
                    SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
                begin
                    if GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code" = '' then
                        exit;
                    // SetItemCategoryFilter(ItemCategory);
                    ItemCategory.SetLoadFields("Code");
                    if ItemCategory.IsEmpty() then
                        exit;
                    ItemCategory.FindSet();
                    repeat
                        SBCTAIndirectPostingSetup."Trade Budget Rate Code" := GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code";
                        SBCTAIndirectPostingSetup."Item Category Code" := ItemCategory.Code;
                        if not SBCTAIndirectPostingSetup.Find() then
                            SBCTAIndirectPostingSetup.Insert(true);
                    until ItemCategory.Next() = 0;
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




    // local procedure SetItemCategoryFilter(var ItemCategory: Record "Item Category")
    // var
    //     SelectionFilterManagement: Codeunit SelectionFilterManagement;
    //     SBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup";
    //     TempSBCTAIndirectPostingSetup: Record "SBCTA Indirect Posting Setup" temporary;
    //     SelectionFilterText: Text;
    //     RecRefIndirectPostingSetup: RecordRef;
    //     FilterTokens: Codeunit "Filter Tokens";
    // begin
    //     SBCTAIndirectPostingSetup.SetFilter("Trade Budget Rate Code", GlobalSBCTATradeBudgetRateCodes."Trade Budget Rate Code");
    //     if SBCTAIndirectPostingSetup.IsEmpty() then
    //         exit;
    //     SBCTAIndirectPostingSetup.FindSet();
    //     repeat
    //         TempSBCTAIndirectPostingSetup := SBCTAIndirectPostingSetup;
    //         TempSBCTAIndirectPostingSetup.Insert(true);
    //     until SBCTAIndirectPostingSetup.Next() = 0;
    //     RecRefIndirectPostingSetup.GetTable(TempSBCTAIndirectPostingSetup);
    //     SelectionFilterText := SelectionFilterManagement.GetSelectionFilter(RecRefIndirectPostingSetup, SBCTAIndirectPostingSetup.FieldNo("Item Category Code"));

    //     SelectionFilterText := SelectionFilterText.Replace('|', '&<>');
    //     SelectionFilterText := '<>' + SelectionFilterText;
    //     ItemCategory.SetFilter(Code, SelectionFilterText);
    // end;
}