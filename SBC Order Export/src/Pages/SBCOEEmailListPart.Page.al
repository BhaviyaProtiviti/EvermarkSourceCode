/// <summary>
/// Page SBCOE Email List Part (ID 50073).
/// </summary>
page 50073 "SBCOE Email List Part"
{
    ApplicationArea = All;
    Caption = 'Email List Part';
    PageType = ListPart;
    SourceTable = "SBCOE Export Email List";

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
                    DrillDown = true;
                    DrillDownPageId = "SBCOE Email Group";
                    ToolTip = 'Code for the Email group.';
                    Visible = false;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    Caption = 'Email Address';
                    ExtendedDatatype = EMail;
                    ToolTip = 'Email Address to CC on order exports.';
                }
                field("Email Type"; Rec."Email Type")
                {
                    ApplicationArea = All;
                    Caption = 'Email Type';
                    ToolTip = 'The address type of the email address.';
                }
                field("Email Placement Order"; Rec."Email Placement Order")
                {
                    ApplicationArea = All;
                    Caption = 'Email Placement Order';
                    ToolTip = 'The order in which the email address will be placed in the email.';
                    Visible = false;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Determines if the email address is enabled.';
                }
            }
        }
    }
}
