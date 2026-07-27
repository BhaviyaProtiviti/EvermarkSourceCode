pageextension 50140 "SBC EDI PmtRemitAdvice Subpage" extends "LAX EDI PmtRemitAdvice Subpage"
{
    layout
    {
        addafter("Journal Account No.")
        {
            field("Customer No."; Rec."SBC Customer No.")
            {
                ApplicationArea = All;
                Caption = 'Customer No.';
                Editable = false;
                ToolTip = 'Specifies the value of the Customer No. field.';
                Visible = true;
            }
        }
    }

    actions
    {
    }
}