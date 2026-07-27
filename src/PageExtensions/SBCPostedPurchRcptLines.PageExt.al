pageextension 50038 "SBC Posted Purch. Rcpt Lines" extends "Posted Purchase Receipt Lines"
{
     layout
    {
        addlast(Control1)
        {
            field("SBC Plant Code"; Rec."SBC Plant Code")
            {
                ApplicationArea = All;                
            }
        }
    }
}
