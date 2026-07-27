/// <summary>
/// Page SBCTA Trade Accrual (ID 50208).
/// </summary>
page 50208 "SBCTA Trade Accrual"
{
    Caption = 'Trade Accrual';
    PageType = Card;
    SourceTable = "SBCTA Trade Accrual Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;

                field("Trade Accrual No."; Rec."Trade Accrual No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is an autofill number that indicates the order in which trade accruals were created.';
                }
                field("Trade Accrual DateTime"; Rec."Trade Accrual DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the date and time that the Trade Accrual was created.';
                }
                field("Accrual Type"; Rec."Accrual Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is the type of accrual that was created.';
                }
            }

            part(Lines; "SBCTA Trade Accrual Lines")
            {
                SubPageLink = "Trade Accrual No." = field("Trade Accrual No.");
                UpdatePropagation = SubPart;
                ApplicationArea = All;
            }
        }
    }
}