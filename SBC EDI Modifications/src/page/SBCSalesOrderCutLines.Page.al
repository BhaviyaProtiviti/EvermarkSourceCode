page 50100 "SBC Sales Order Cut Lines"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'SBC Sales Order Cut Lines';
    PageType = List;
    SourceTable = "SBC Sales Order Cut Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("SBC Entry No."; Rec."SBC Entry No.")
                {
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field.', Comment = '%';
                }
                field("SBC Order No."; Rec."SBC Order No.")
                {
                    ToolTip = 'Specifies the value of the Order No. field.', Comment = '%';
                }
                field("SBC Invoice No."; Rec."SBC Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Invoice No. field.', Comment = '%';
                }
                field("SBC Sell-to Customer No."; Rec."SBC Sell-to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Sell-to Customer No. field.', Comment = '%';
                }
                field("SBC Line No."; Rec."SBC Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("SBC No."; Rec."SBC No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("SBC Description"; Rec."SBC Description")
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("SBC Order Quantity"; Rec."SBC Order Quantity")
                {
                    ToolTip = 'Specifies the value of the Order Quantity field.', Comment = '%';
                }
                field("SBC Qty Shipped"; Rec."SBC Qty Shipped")
                {
                    ToolTip = 'Specifies the value of the Qty. to Ship field.', Comment = '%';
                }
                field("SBC Qty Invoiced"; Rec."SBC Qty Invoiced")
                {
                    ToolTip = 'Specifies the value of the Qty. to Invoice field.', Comment = '%';
                }

                field("SBC Cut Quantity"; Rec."SBC Cut Quantity")
                {
                    ToolTip = 'Specifies the value of the Order Quantity field.', Comment = '%';
                }
                field("SBC Unit of Measure"; Rec."SBC Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.', Comment = '%';
                }
                field("SBC Shipment Date"; Rec."SBC Shipment Date")
                {
                    ToolTip = 'Specifies the value of the Shipment Date field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
            }
        }
    }
}
