/// <summary>
/// Page SIQ Item API (ID 50040).
/// </summary>
page 50040 "SBC SIQ Item API"
{
    APIGroup = 'SIQ';
    APIPublisher = 'StockIQ';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'siqItemAPI';
    DelayedInsert = true;
    EntityName = 'siqitem';
    EntitySetName = 'siqitems';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Item;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(itemNo; Rec."No.")
                {
                    Caption = 'Item No.';
                }
                field(sbcCreatedDate; Rec."SBC Created Date")
                {
                    Caption = 'SBC Created Date';
                }
                field(sbcObsoleteDate; Rec."SBC Obsolete Date")
                {
                    Caption = 'SBC Obsolete Date';
                }
                field(sbcRunStrategy; Rec."SBC Run Strategy")
                {
                    Caption = 'SBC Run Strategy';
                }
                field(sbcSafetyStockDays; Rec."SBC Safety Stock Days")
                {
                    Caption = 'SBC Safety Stock Days';
                }
                field(sbcProductionLine; Rec."SBC Production Line")
                {
                    Caption = 'SBC Production Line';
                }
                field(sbcExpirationOnLabel; Rec."SBC Expiration on Label")
                {
                    Caption = 'SBC Expiration on Label';
                }
                field(orderMultiple; Rec."Order Multiple")
                {
                    Caption = 'Order Multiple';
                }
            }
        }
    }
}
