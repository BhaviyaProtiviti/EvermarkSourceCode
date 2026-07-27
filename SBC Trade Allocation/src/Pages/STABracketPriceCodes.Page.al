/// <summary>
/// Page STA Bracket Price Codes (ID 50219).
/// </summary>
page 50219 "STA Bracket Price Codes"
{
    Caption = 'SBC Bracket Price Codes';
    PageType = ListPlus;
    SourceTable = "STA Bracket Price Code";
    ApplicationArea = All;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(General)
            {

                field("Bracket Price Code"; Rec."Bracket Price Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bracket Code field.';
                }
                field("Bracket Description"; Rec."Bracket Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bracket Description field.';
                }
                field("Posting Account"; Rec."Posting Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Bracket Price Code will be posted to.';
                }
                field("Balance Account"; Rec."Balance Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the account that values related to the Bracket Price Code will be balanced against.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field.';
                }
                field("Bracket Dimension Code"; Rec."Bracket Dimension Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bracket Dimension Code field.', Comment = 'This is the dimension code that will be used to post Bracket Entries to the G/L.';
                }
                field("Bracket Dimension Value"; Rec."Bracket Dimension Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bracket Dimension Value field.', Comment = 'This is the dimension value that will be used to post Bracket Entries to the G/L.';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field.', Comment = '%';
                }
            }

            part(Prices; "STA Bracket Price ListPart")
            {
                UpdatePropagation = SubPart;
            }


        }


    }
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Prices.Page.SetGlobalPageRecord(Rec);
        CurrPage.Prices.Page.SetTableViewOnSubform();
    end;

}