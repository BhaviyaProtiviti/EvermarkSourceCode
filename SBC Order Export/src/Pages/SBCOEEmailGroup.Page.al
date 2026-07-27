/// <summary>
/// Page SBCOE Email Group (ID 50072).
/// </summary>
page 50072 "SBCOE Email Group"
{
    AdditionalSearchTerms = 'SBCOE Email Group';
    ApplicationArea = All;
    Caption = 'Email Group';
    PageType = Card;
    SourceTable = "SBCOE Export Email Group";

    layout
    {
        area(Content)
        {
            group(General)
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

            part(EmailList; "SBCOE Email List Part")
            {
                ApplicationArea = All;
                Caption = 'Email List';
                SubPageLink = "Email Group Code" = field("Email Group Code");
            }
        }
    }
}
