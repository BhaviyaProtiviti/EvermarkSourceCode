/// <summary>
/// Page SBCTA Trade Budget Rate Codes (ID 50202).
/// </summary>
page 50202 "SBCTA Trade Budget Rate Codes"
{
    ApplicationArea = All;
    Caption = 'Trade Rate Codes';
    PageType = List;
    SourceTable = "SBCTA Trade Budget Rate Codes";
    SourceTableView = sorting("Rate Type") order(ascending);
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            //Todo(Jump to Setup from here)
            repeater(General)
            {
                
                field("Trade Budget Rate Code"; Rec."Trade Budget Rate Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is an organizational and tracking code that is used to organize budget rates on Trade Budgets.';
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The budget group type the rate is used for.';
                }
                field("Calculation Method"; Rec."Calculation Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'The calculation method used to calculate the COGs for the trade budget rate code.';
                    Editable = GlobalCalculationMethodEditable;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'This is a brief description of the Trade Budget Rate Code.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'When this field is set, the trade budget rate code is blocked and cannot be used for new trade budgets.';
                }
            }


            part(TradePostingSetup; "SBCTA Trade Posting Subform")
            {
                Visible = Rec."Rate Type" = "SBCTA Budget Group Type"::Customer;
                // SubPageLink = "Trade Budget Rate Code" = field("Trade Budget Rate Code");
                UpdatePropagation = SubPart;
            }

            part(IndirectPostingSetup; "SBCTA Indirect Posting Subform")
            {
                Visible = Rec."Rate Type" = "SBCTA Budget Group Type"::Item;

                // SubPageLink = "Trade Budget Rate Code" = field("Trade Budget Rate Code");
                UpdatePropagation = SubPart;

            }

        }
    }
    trigger OnOpenPage()
    begin
        // GlobalSBCTATradeBudgetOptions := GlobalSBCTATradeBudgetOptions.GetOptions();
        GlobalCogsBasis := GlobalSBCTATradeBudgetOptions.GetOptions()."Calculation Basis" = "SBCTA Calc. Basis Type"::COGS;
    end;

    trigger OnAfterGetRecord()
    begin
        SetCalculationMethodEditable();

    end;

    trigger OnAfterGetCurrRecord()
    begin
        case Rec."Rate Type" of
            "SBCTA Budget Group Type"::Customer:
                begin
                    CurrPage.TradePostingSetup.Page.SetGlobalRateCode(Rec);
                    CurrPage.TradePostingSetup.Page.SetTableViewOnSubform();
                end;
            "SBCTA Budget Group Type"::Item:
                begin
                    CurrPage.IndirectPostingSetup.Page.SetGlobalRateCode(Rec);
                    CurrPage.IndirectPostingSetup.Page.SetTableViewOnSubform();
                end;
        end;
    end;

    local procedure SetCalculationMethodEditable()
    begin
        if not GlobalCogsBasis then
            exit;
        GlobalCalculationMethodEditable := (Rec."Rate Type" = "SBCTA Budget Group Type"::Customer);
    end;

    var
        GlobalCalculationMethodEditable: Boolean;
        GlobalCogsBasis: Boolean;
        GlobalSBCTATradeBudgetOptions: Record "SBCTA Trade Budget Options";
}