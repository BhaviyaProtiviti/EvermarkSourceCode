page 50262 "SBCAPI Vena Trade"
{
    APIGroup = 'vena';
    APIPublisher = 'tigunia';
    APIVersion = 'v2.0';
    Caption = 'sbcapiVenaTrade';
    DelayedInsert = true;
        InsertAllowed = true;
    ApplicationArea = All;
    ModifyAllowed = true;
    DeleteAllowed = true;
    Editable = true;
    EntityName = 'sbcApiVenaTrade';
    EntitySetName = 'sbcApiVenaTradeLines';
    ODataKeyFields = DW_Id;
    PageType = API;
    SourceTable = "SBC Vena DW Trade";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                  field(dwId; Rec.DW_Id)
                {
                    Caption = 'DW_Id';
                }
                field(companyId; Rec."Company Id")
                {
                    Caption = 'Company Id';
                }
                field(salesDocumentId; Rec."Sales Document Id")
                {
                    Caption = 'Sales Document Id';
                }
                field(documentLineNumber; Rec."Document Line Number")
                {
                    Caption = 'Document Line Number';
                }
                field(itemId; Rec."Item Id")
                {
                    Caption = 'Item Id';
                }
                field(orderDate; Rec."Order Date")
                {
                    Caption = 'Order Date';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(lastDayOfMonth; Rec.LastDayOfMonth)
                {
                    Caption = 'LastDayOfMonth';
                }
                field(lastDayOfMonthShipmentDate; Rec.LastDayOfMonth_ShipmentDate)
                {
                    Caption = 'LastDayOfMonth_ShipmentDate';
                }
                field(caseQty; Rec."Case Qty")
                {
                    Caption = 'Case Qty';
                }
                field(customerPostingGroupID; Rec."Customer Posting Group ID")
                {
                    Caption = 'Customer Posting Group ID';
                }
                field(sellToCustomerId; Rec."Sell to Customer Id")
                {
                    Caption = 'Sell to Customer Id';
                }
                field(billToCustomerId; Rec."Bill to Customer Id")
                {
                    Caption = 'Bill to Customer Id';
                }
                field(entryNumber; Rec."Entry Number")
                {
                    Caption = 'Entry Number';
                }
                field(businessPostingGroupId; Rec."Business Posting Group Id")
                {
                    Caption = 'Business Posting Group Id';
                }
                field(documentTypeCode; Rec."Document Type Code")
                {
                    Caption = 'Document Type Code';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(globalDimension1Id; Rec."Global Dimension 1 Id")
                {
                    Caption = 'Global Dimension 1 Id';
                }
                field(globalDimension2Id; Rec."Global Dimension 2 Id")
                {
                    Caption = 'Global Dimension 2 Id';
                }
                field(lineTypeId; Rec."Line Type Id")
                {
                    Caption = 'Line Type Id';
                }
                field(inventoryPostingGroupId; Rec."Inventory Posting Group Id")
                {
                    Caption = 'Inventory Posting Group Id';
                }
                field(locationId; Rec."Location Id")
                {
                    Caption = 'Location Id';
                }
                field(shipToCode; Rec."Ship-to Code")
                {
                    Caption = 'Ship-to Code';
                }
                field(emersonShipToCode; Rec."Emerson Ship to Code")
                {
                    Caption = 'Emerson Ship to Code';
                }
                field(productPostingGroupId; Rec."Product Posting Group Id")
                {
                    Caption = 'Product Posting Group Id';
                }
                field(salespersonId; Rec."Salesperson Id")
                {
                    Caption = 'Salesperson Id';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(quantityShipped; Rec."Quantity Shipped")
                {
                    Caption = 'Quantity Shipped';
                }
                field(quantityShippedCases; Rec."Quantity Shipped Cases")
                {
                    Caption = 'Quantity Shipped Cases';
                }
                field(caseWeight; Rec."Case Weight")
                {
                    Caption = 'Case Weight';
                }
                field(grossSalesAtValue; Rec."Gross Sales at Value")
                {
                    Caption = 'Gross Sales at Value';
                }
                field(grossSales; Rec."Gross Sales")
                {
                    Caption = 'Gross Sales';
                }
                field(sales; Rec.Sales)
                {
                    Caption = 'Sales';
                }
                field(discount; Rec.Discount)
                {
                    Caption = 'Discount';
                }
                field(accruedPromotion; Rec."Accrued Promotion")
                {
                    Caption = 'Accrued Promotion';
                }
                field(cashDiscount; Rec."Cash Discount")
                {
                    Caption = 'Cash Discount';
                }
                field(cashDiscountPostExit; Rec."Cash Discount Post Exit")
                {
                    Caption = 'Cash Discount Post Exit';
                }
                field(fixedFunding; Rec."Fixed Funding")
                {
                    Caption = 'Fixed Funding';
                }
                field(markdowns; Rec.Markdowns)
                {
                    Caption = 'Markdowns';
                }
                field(nationalCoupon; Rec."National Coupon")
                {
                    Caption = 'National Coupon';
                }
                field(oiBracket; Rec."OI Bracket")
                {
                    Caption = 'OI Bracket';
                }
                field(oiEDLP; Rec."OI EDLP")
                {
                    Caption = 'OI EDLP';
                }
                field(penaltyFines; Rec."Penalty Fines")
                {
                    Caption = 'Penalty Fines';
                }
                field(retailerCoupon; Rec."Retailer Coupon")
                {
                    Caption = 'Retailer Coupon';
                }
                field(returns; Rec.Returns)
                {
                    Caption = 'Returns';
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    Caption = 'Shipment Date';
                }
                field(slotting; Rec.Slotting)
                {
                    Caption = 'Slotting';
                }
                field(tradeOther; Rec."Trade Other")
                {
                    Caption = 'Trade Other';
                }
                field(tradeWarehouse; Rec."Trade Warehouse")
                {
                    Caption = 'Trade Warehouse';
                }
                field(unsalable; Rec.Unsalable)
                {
                    Caption = 'Unsalable';
                }
                field(totalTradeAmount; Rec."Total Trade Amount")
                {
                    Caption = 'Total Trade Amount';
                }
                field(salesNetTrade; Rec."Sales Net Trade")
                {
                    Caption = 'Sales Net Trade';
                }
                field(cost; Rec.Cost)
                {
                    Caption = 'Cost';
                }
                field(inboundFreight; Rec."Inbound Freight")
                {
                    Caption = 'Inbound Freight';
                }
                field(whInboundVariable; Rec."WH Inbound Variable")
                {
                    Caption = 'WH Inbound Variable';
                }
                field(whOverheadFixed; Rec."WH Overhead - Fixed")
                {
                    Caption = 'WH Overhead - Fixed';
                }
                field(totalIndirectCost; Rec."Total Indirect Cost")
                {
                    Caption = 'Total Indirect Cost';
                }
                field(grossProfit; Rec."Gross Profit")
                {
                    Caption = 'Gross Profit';
                }
                field(incrementalLoadTimeStamp; Rec."Incremental Load Time Stamp")
                {
                    Caption = 'Incremental Load Time Stamp';
                }
                field(dwBatch; Rec.DW_Batch)
                {
                    Caption = 'DW_Batch';
                }
                field(dwSourceCode; Rec.DW_SourceCode)
                {
                    Caption = 'DW_SourceCode';
                }
                field(dwTimeStamp; Rec.DW_TimeStamp)
                {
                    Caption = 'DW_TimeStamp';
                }
            }
        }
    }
}