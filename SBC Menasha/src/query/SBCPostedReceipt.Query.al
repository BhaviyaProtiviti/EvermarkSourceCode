query 50350 "SBC Posted Receipt"
{
    Caption = 'SBC Posted Receipt';
    QueryType = Normal;
    
    elements
    {
        dataitem(PurchRcptHeader; "Purch. Rcpt. Header")
        {
            column(VendorShipmentNo; "Vendor Shipment No.")
            {
            }
            column(OrderNo; "Order No.")
            {
            }
            dataitem(Item_Ledger_Entry;"Item Ledger Entry")
            {
                DataItemLink = "Document No." = PurchRcptHeader."No.", "External Document No." = PurchRcptHeader."Vendor Shipment No.";
                DataItemTableFilter = "Entry Type" = const("Purchase");

                column(ItemNo; "Item No.")
                {
                }
                column(Lot_No_;"Lot No.")
                {
                }
                column(Quantity; "Quantity")
                {
                }
            }
        }
    }
    
}
