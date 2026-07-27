/// <summary>
/// PageExtension SBC Posted Purch. Invoice Subf (ID 50059) extends Record Posted Purch. Invoice Subform.
/// </summary>
pageextension 50035 "SBC Posted Purch. Invoice Subf" extends "Posted Purch. Invoice Subform"
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