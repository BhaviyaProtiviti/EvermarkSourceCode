pageextension 50106 "SBC EDI Trade Partner" extends "LAX EDI Trade Partner"

{
    layout
    {
        addafter("Vendor Name")
        {
            field("SBC Item Master Sync."; Rec."SBC Item Master Sync.")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}