/// <summary>
/// Page STA Bracket Price ListPart (ID 50218).
/// </summary>
page 50218 "STA Bracket Price ListPart"
{
    Caption = 'SBC Bracket Price ListPart';
    PageType = ListPart;
    SourceTable = "STA Bracket Price";

    layout
    {
        area(content)
        {
            repeater(Prices)
            {
                field("Bracket Price Code"; Rec."Bracket Price Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'A reference to the Bracket table.';
                    Visible = false;
                }
                field("Promo Family"; Rec."Promo Family")
                {
                    ApplicationArea = All;
                    ToolTip = 'The promo family of the item.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'A reference to the Item table.';
                    Visible = true;
                }
                field(UCC14; Rec.UCC14)
                {
                    ApplicationArea = All;
                    ToolTip = 'The UCC14 of the item.';
                    Visible = true;
                }
                field("Item UPC"; Rec."Item UPC")
                {
                    ApplicationArea = All;
                    ToolTip = 'The UPC of the item.';
                    Visible = false;
                }
                field("Case UPC"; Rec."Case UPC")
                {
                    ApplicationArea = All;
                    ToolTip = 'The UPC of the case.';
                    Visible = false;
                }
                field("Units per Case"; Rec."Units per Case")
                {
                    ApplicationArea = All;
                    ToolTip = 'The number of units per case.';
                    Visible = true;
                    BlankZero = true;
                }
                field("Bracket List Unit Price"; Rec."Item Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'The List Unit Price of the item in the bracket.';
                    Visible = true;
                    BlankZero = true;
                }
                field("Bracket Case Price"; Rec."Bracket Case Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Case Price of the item in the bracket.';
                    Visible = true;
                    BlankZero = true;
                }
                field("Bracket Unit Price"; Rec."Bracket Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'The bracket unit price of the item in the bracket.';
                    Visible = true;
                    BlankZero = true;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'A reference to the SBC Status field. True if Active, false if Do Not Sell.';
                    Visible = true;
                }
            }
        }
    }

    var
        GlobalSTABracketPriceCode: Record "STA Bracket Price Code";

    internal procedure SetTableViewOnSubform()
    begin
        Rec.SetFilter("Bracket Price Code", '%1', GlobalSTABracketPriceCode."Bracket Price Code");
        CurrPage.SetTableView(Rec);
        CurrPage.Update(false);
    end;

    internal procedure SetGlobalPageRecord(STABracketPriceCode: Record "STA Bracket Price Code")
    begin
        GlobalSTABracketPriceCode := STABracketPriceCode;
    end;

}