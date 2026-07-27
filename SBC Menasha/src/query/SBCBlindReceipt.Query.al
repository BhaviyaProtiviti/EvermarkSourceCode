query 50351 "SBC Blind Receipt"
{
    Caption = 'SBC Blind Receipt';
    QueryType = Normal;
    OrderBy = descending(SBCPurchaseOrderNo);
    
    elements
    {
        dataitem(SBCBlindReceipt; "SBC Blind Receipt")
        {
            column(SBCPosted; "SBC Posted")
            {
            }
            column(SBCProcessed; "SBC Processed")
            {
            }
            column(SBCDoNotProcess; "SBC Do Not Process")
            {
            }
            column(SBCPurchaseOrderNo; "SBC Purchase Order No.")
            {
            }
            column(SBCBOLNo; "SBC BOL No.")
            {
            }
            column(SBCItemNo; "SBC Item No.")
            {
            }
            column(SBCLotNo; "SBC Lot No.")
            {
            }
            column(SBCQuantityBase; "SBC Quantity (Base)")
            {
            }
        }
    }    
}
