pageextension 50003 "SBC Main Purchase Lines" extends "Purchase Lines"
{
    layout
    {
        addafter("Buy-from Vendor No.")
        {
            field("SBC Buy-From Vendor Name"; Rec."SBC Buy-From Vendor Name")
            {
                ApplicationArea = All;
                Caption = 'Buy-from Vendor Name';
                Editable = false;
            }
        }
        addafter("Expected Receipt Date")
        {
            field("EVM Expected Ship Date"; Rec."EVM Expected Ship Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Expected Ship Date field.';
            }
            field("SBC Planned Receipt Date"; Rec."Planned Receipt Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Planned Receipt Date field.', Comment = '%';
            }
            field("Order Date"; Rec."Order Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date when the order was created.';
            }
        }
        addlast(Control1)
        {
            field("SBC Production Plant 1"; Rec."SBC Production Plant 1")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Production Plant 1 field.', Comment = '%';
            }
            field("SBC LAX EDI PO Generated"; Rec."SBC LAX EDI PO Generated")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the LAX EDI PO Generated field.', Comment = '%';
            }
            field("SBC EDI PO Gen. Date"; Rec."SBC EDI PO Gen. Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the EDI PO Gen. Date field.', Comment = '%';
            }
            field("SBC LAX EDI PO Change Gen"; Rec."SBC LAX EDI PO Change Gen")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the LAX EDI PO Change Generated field.', Comment = '%';
            }
            field("SBC EDI PO Change Gen. Date"; Rec."SBC EDI PO Change Gen. Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the LAX EDI PO Change Gen. Date field.', Comment = '%';
            }
        }
    }

}