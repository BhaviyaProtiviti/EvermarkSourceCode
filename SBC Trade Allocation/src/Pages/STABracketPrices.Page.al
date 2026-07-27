/// <summary>
/// Page STA Bracket Prices (ID 50217).
/// </summary>
page 50217 "STA Bracket Prices"
{
    ApplicationArea = All;
    Caption = 'SBC Bracket Prices';
    PageType = List;
    SourceTable = "STA Bracket Price";
    UsageCategory = Lists;

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
                    Visible = true;

                    trigger OnValidate()
                    var
                        BracketPriceCode: Record "STA Bracket Price Code";
                    begin
                        if BracketPriceCode.Get(Rec."Bracket Price Code") then begin
                            Rec."Country Code" := BracketPriceCode."Country Code";

                        end;
                    end;
                }
                field("Promo Family"; Rec."Promo Family")
                {
                    ApplicationArea = All;
                    ToolTip = 'The promo family of the item.';
                    Visible = true;
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
                    Visible = true;
                }
                field("Case UPC"; Rec."Case UPC")
                {
                    ApplicationArea = All;
                    ToolTip = 'The UPC of the case.';
                    Visible = true;
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
                    ToolTip = 'The bracket list unit price of the item in the bracket.';
                    Visible = true;
                    BlankZero = true;
                }
                field("Bracket Case Price"; Rec."Bracket Case Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'The bracket case price of the item in the bracket.';
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
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field.', Comment = '%';
                    Visible = true;
                }

            }
        }
    }
}