/// <summary>
/// PageExtension SBC Posted Purchase Rcpt. Subf (ID 50058) extends Record Posted Purchase Rcpt. Subform.
/// </summary>
pageextension 50059 "SBC Posted Purchase Rcpt. Subf" extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        addafter("Item Reference No.")
        {

            field("SBC Plant Code"; Rec."SBC Plant Code")
            {
                ApplicationArea = All;
                ToolTip = 'The code that identifies the supplier plant for the item.';
                Visible = false;
                Editable = false;
            }
            field("SBC Plant Item No."; Rec."SBC Plant Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'The Plant-specific item number.';
                Visible = false;
                Editable = false;
            }
        }
    }
}