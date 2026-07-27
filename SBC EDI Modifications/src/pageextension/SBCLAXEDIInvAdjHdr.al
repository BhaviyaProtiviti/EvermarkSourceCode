pageextension 50157 SBCLAXEDIInvAdjHdr extends "LAX EDI Inventory Advice"
{
    layout
    {
        addafter("Transaction Purpose Code")
        {
            field("ADJ Code"; Rec."ADJ Code")
            {
                ApplicationArea = All;
                Caption = 'Gen Business Posting Group';
                Editable = false;
            }
        }
    }
}
