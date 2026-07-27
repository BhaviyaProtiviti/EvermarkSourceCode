pageextension 50156 SBCLAXEDIAdjInv extends "LAX EDI Adj Inventory  Subform"
{
    layout
    {
        addafter("Adjustment Quantity")
        {
            field("ADJ Code"; Rec."ADJ Code")
            {
                ApplicationArea = All;
                Caption = 'Gen Business Posting Group';
                Editable = true;
            }
        }
    }
}
