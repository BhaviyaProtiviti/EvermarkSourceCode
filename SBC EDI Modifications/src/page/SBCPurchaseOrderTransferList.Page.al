page 50160 "SBC Purch Order Transfer List"
{
    ApplicationArea = All;
    Caption = 'Purchase Order Transfer List';
    PageType = List;
    SourceTable = "SBC Purch Order Transfer Link";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Transfer Order No."; Rec."Transfer Order No.")
                {
                    ToolTip = 'The Transfer Order created from this PO/Receipt.';
                    trigger OnDrillDown()
                    var
                        TransferHeader: Record "Transfer Header";
                    begin
                        if TransferHeader.Get(Rec."Transfer Order No.") then
                            Page.Run(Page::"Transfer Order", TransferHeader);
                    end;
                }
                field("Posted Transfer Shipment No."; Rec."Posted Transfer Shipment No.")
                {
                    ToolTip = 'The Transfer Shipment document created when the transfer order was shipped.';
                    trigger OnDrillDown()
                    var
                        TransferShipmentHeader: Record "Transfer Shipment Header";
                    begin
                        if TransferShipmentHeader.Get(Rec."Posted Transfer Shipment No.") then
                            Page.Run(Page::"Posted Transfer Shipment", TransferShipmentHeader);
                    end;
                }
                field("Posted Transfer Receipt No."; Rec."Posted Transfer Receipt No.")
                {
                    ToolTip = 'The Transfer Receipt document created when the transfer order was received.';
                    trigger OnDrillDown()
                    var
                        TransferReceiptHeader: Record "Transfer Receipt Header";
                    begin
                        if TransferReceiptHeader.Get(Rec."Posted Transfer Receipt No.") then
                            Page.Run(Page::"Posted Transfer Receipt", TransferReceiptHeader);
                    end;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ToolTip = 'The Purchase Order linked to the Transfer Order.';
                }
                field("Purchase Receipt No."; Rec."Purchase Receipt No.")
                {
                    ToolTip = 'The Purchase Receipt associated with this transfer order.';
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ToolTip = 'The date and time this Transfer Order was created.';
                }
            }
        }
    }

}