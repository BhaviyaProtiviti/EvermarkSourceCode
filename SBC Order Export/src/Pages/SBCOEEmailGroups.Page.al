/// <summary>
/// Page SBCOE Email Groups (ID 50071).
/// </summary>
page 50071 "SBCOE Email Groups"
{
    AdditionalSearchTerms = 'SBCOE Email Groups';
    ApplicationArea = All;
    Caption = 'Email Groups';
    CardPageId = "SBCOE Email Group";
    PageType = List;
    SourceTable = "SBCOE Export Email Group";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Email Group Code"; Rec."Email Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'Email Group Code';
                    ToolTip = 'The identifier of the mail group.';
                }
                field("Email Group Description"; Rec."Email Group Description")
                {
                    ApplicationArea = All;
                    Caption = 'Mail Group Description';
                    ToolTip = 'Specifies the value of the Mail Group Description field.';
                }
            }
        }
    }
}
