/// <summary>
/// PageExtension SBCOE Contact Card  (ID 50060) extends Record Contact Card.
/// </summary>
pageextension 50060 "SBCOE Contact Card" extends "Contact Card"
{
    layout
    {
        addlast(Communication)
        {
            group(SBCOEExport)
            {
                Caption = 'SBC Excel Order Export';
                field("SBCOE Export Recipient"; Rec."SBCOE Export Recipient")
                {
                    ApplicationArea = All;
                    Caption = 'Order Export Recipient';
                    ToolTip = 'If this field is set, a contact is allowed to receive order export spreadsheets via Email.';
                }
                field("SBCOE Email Group Code"; Rec."SBCOE Email Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'Email Group Code';
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'The list of emails associated with this export.';
                    Visible = false;
                }
            }
        }
    }
}
