/// <summary>
/// PageExtension SBC Purchase Order Subform (ID 50055) extends Record Purchase Order Subform.
/// </summary>
pageextension 50055 "SBC Purchase_Order Subform" extends "Purchase Order Subform"
{

    layout
    {
        addafter("Item Reference No.")
        {

            field("SBC Plant Code"; Rec."SBC Plant Code")
            {
                ApplicationArea = All;
                ToolTip = 'The code that identifies the supplier plant for the item.';
                Visible = true;

            }
            field("SBC Plant Item No."; Rec."SBC Plant Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'The Plant-specific item number.';
                Visible = true;

            }
        }
    }
}