pageextension 50113 "SBC EDI Receive Document List" extends "LAX EDI Receive Document List"
{
    layout
    {
        addafter("EDI Document No.")
        {
            field("SBC Sales Order No."; Rec."SBC Sales Order No.")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = false;
                TableRelation = "Sales Header"."No." where("Document Type" = Filter('Order'));
            }
            field("SBC Purchase Order No."; Rec."SBC Purchase Order No.")
            {
                ApplicationArea = All;
                Visible = true;
                Editable = false;
                TableRelation = "Purchase Header"."No." where("Document Type" = Filter('Order'));
            }
            field("SBC Vendor Invoice No."; Rec."SBC Vendor Invoice No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Vendor Invoice No. field.', Comment = '%';
                Visible = true;
                Editable = false;
            }
            field("SBC Total Invoice Amount"; Rec."SBC Total Invoice Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Total Invoice Amount field.', Comment = '%';
                Visible = true;
                Editable = false;
            }
        }
    }
}