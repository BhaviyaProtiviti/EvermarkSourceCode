pageextension 50034 "SBC UI Posted Purch Cr Memos" extends "Posted Purchase Credit Memos"
{
    layout
    {
        addlast(Control1)
        {
            field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
            {
                ApplicationArea = All;
                Caption = 'Applies-to Doc. No.';
                Editable = false;
                ToolTip = 'The document number that the credit memo applies to.';
            }
        }
    }
}
