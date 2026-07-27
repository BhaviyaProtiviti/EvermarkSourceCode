pageextension 50118 "SBC Main Gen Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("SBC Approval Entry No."; Rec."SBC Approval Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'SBC Approval Entry No.';
            }
        }
        modify(IncomingDocAttachFactBox)
        {
            Visible = Rec."SBC Incoming Doc No." = 0;
        }
        addafter(IncomingDocAttachFactBox)
        {
            part(SBCIncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                SubPageLink = "Posting Date" = field("Posting Date"), "Incoming Document Entry No." = field("SBC Incoming Doc No.");
                Visible = Rec."SBC Incoming Doc No." <> 0;
            }
        }
    }
}