/// <summary>
/// Page SBCTA Trade Budget Rates (ID 50203).
/// </summary>
page 50203 "SBCTA Trade Budget Rates"
{
    Caption = 'Trade Rates';
    PageType = ListPart;
    SourceTable = "SBCTA Trade Budget Rates";

    layout
    {
        area(content)
        {
            //todo(Add Customer Posting Group and Customer Here, too. So that we can more easily define the budget rates for each customer. Some customer posting groups may have different rates.)
            repeater(General)
            {
                field("Trade Budget Code"; Rec."Trade Budget Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the Trade Budget and set of rates associated with it.';
                    Visible = false;
                    Editable = false;
                }
                field("Trade Budget Rate Code"; Rec."Trade Budget Rate Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the particular Trade Budget Rate associated with the Trade Budget and further instructions on how it should be applied.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field allows for granular rates to be set for a particular Item.';
                    Visible = GlobalItemNoVisibility;
                }
                field("Trade Budget Rate"; Rec."Trade Budget Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the rate that will be applied to the Customer Price Group.';
                }
                field("Trade Budget Rate Type"; Rec."Trade Budget Rate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This code identifies the type of Trade Budget Rate.';
                }
                field("Trade Budget Actual"; Rec."Trade Budget Actual")
                {
                    ApplicationArea = All;
                    ToolTip = 'The actual dollar value allocated against this budget.';
                    Editable = false;
                    Visible = GlobalTargetsVisible;
                }
                field("Trade Budget Target"; Rec."Trade Budget Target")
                {
                    ApplicationArea = All;
                    ToolTip = 'The dollar amount that this budget is not to be allocated beyond.';
                    Visible = GlobalTargetsVisible;
                }
            }
        }
    }
    trigger OnOpenPage()
    var 
    SBCTATradeBudgetOptions : Record "SBCTA Trade Budget Options";
    begin
        SBCTATradeBudgetOptions.SetRange("Ignore Trade Target",true);
        GlobalTargetsVisible := SBCTATradeBudgetOptions.IsEmpty();
    end;
    var
        GlobalItemNoVisibility: Boolean;
        GlobalTargetsVisible: Boolean;

    internal procedure SetItemNoVisibility(ItemNoVisibility: Boolean)
    var 
        SBCTATradeBudgetRates: Record "SBCTA Trade Budget Rates";
    begin
        GlobalItemNoVisibility := ItemNoVisibility;
        // SBCTATradeBudgetRates.SetView(Rec.GetView());
        // if GlobalItemNoVisibility then 
        //     SBCTATradeBudgetRates.SetFilter("Item No.",'<>%1','')
        // else 
        //     SBCTATradeBudgetRates.SetFilter("Item No.",'%1','');
        // CurrPage.SetTableView(SBCTATradeBudgetRates);
        CurrPage.Update(false);
    end;

    
}