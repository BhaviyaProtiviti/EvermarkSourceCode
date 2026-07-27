pageextension 50166 "SBC Transfer Order Ext" extends "Transfer Order"
{
    layout
    {
        addlast(General)
        {
            group("EDI / 3PL")
            {
                field("Linked Purchase Order No."; Rec."SBC Linked Purchase Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Source Receipt No."; Rec."SBC Source Receipt No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("EDI 944 Processed"; Rec."SBC EDI 944 Processed")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}
