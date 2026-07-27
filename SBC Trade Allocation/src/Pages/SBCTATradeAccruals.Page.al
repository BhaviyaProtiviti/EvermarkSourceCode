/// <summary>
/// Page SBCTA Trade Accruals (ID 50206).
/// </summary>
page 50206 "SBCTA Trade Accruals"
{
    ApplicationArea = All;
    Caption = 'Trade Accruals';
    PageType = List;
    SourceTable = "SBCTA Trade Accrual Header";
    UsageCategory = History;
    CardPageId = "SBCTA Trade Accrual";
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
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
        }
    }
}