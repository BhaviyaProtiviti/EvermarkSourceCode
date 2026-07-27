pageextension 50004 "SBC Main Post Purch. Inv Lines" extends "Posted Purchase Invoice Lines"
{
    layout
    {
        addafter("Buy-from Vendor No.")
        {
            field("SBC Buy-From Vendor Name";Rec."SBC Buy-From Vendor Name")
            {
                ApplicationArea = All;
                Caption = 'Buy-from Vendor Name';
                Editable = false;
            }
        }
    }
}
