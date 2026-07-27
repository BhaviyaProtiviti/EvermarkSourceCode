page 50265 "SBC Vena Trade"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Trade';
    PageType = List;
    SourceTable = "SBC Vena DW Trade";
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(DW_Id; Rec.DW_Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DW_Id field.', Comment = '%';
                }
                field("Company Id"; Rec."Company Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Id field.', Comment = '%';
                }
                field("Sales Document Id"; Rec."Sales Document Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Document Id field.', Comment = '%';
                }
                field("Document Line Number"; Rec."Document Line Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Line Number field.', Comment = '%';
                }
                field("Item Id"; Rec."Item Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Id field.', Comment = '%';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Date field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field(LastDayOfMonth; Rec.LastDayOfMonth)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LastDayOfMonth field.', Comment = '%';
                }
                field(LastDayOfMonth_ShipmentDate; Rec.LastDayOfMonth_ShipmentDate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LastDayOfMonth_ShipmentDate field.', Comment = '%';
                }
                field("Case Qty"; Rec."Case Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Case Qty field.', Comment = '%';
                }
                field("Customer Posting Group ID"; Rec."Customer Posting Group ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Posting Group ID field.', Comment = '%';
                }
                field("Sell to Customer Id"; Rec."Sell to Customer Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell to Customer Id field.', Comment = '%';
                }
                field("Bill to Customer Id"; Rec."Bill to Customer Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill to Customer Id field.', Comment = '%';
                }
                field("Entry Number"; Rec."Entry Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Number field.', Comment = '%';
                }
                field("Business Posting Group Id"; Rec."Business Posting Group Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Business Posting Group Id field.', Comment = '%';
                }
                field("Document Type Code"; Rec."Document Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type Code field.', Comment = '%';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Global Dimension 1 Id"; Rec."Global Dimension 1 Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Id field.', Comment = '%';
                }
                field("Global Dimension 2 Id"; Rec."Global Dimension 2 Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Id field.', Comment = '%';
                }
                field("Line Type Id"; Rec."Line Type Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Type Id field.', Comment = '%';
                }
                field("Inventory Posting Group Id"; Rec."Inventory Posting Group Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Posting Group Id field.', Comment = '%';
                }
                field("Location Id"; Rec."Location Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Id field.', Comment = '%';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field.', Comment = '%';
                }
                field("Emerson Ship to Code"; Rec."Emerson Ship to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Emerson Ship to Code field.', Comment = '%';
                }
                field("Product Posting Group Id"; Rec."Product Posting Group Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Product Posting Group Id field.', Comment = '%';
                }
                field("Salesperson Id"; Rec."Salesperson Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Id field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Shipped field.', Comment = '%';
                }
                field("Quantity Shipped Cases"; Rec."Quantity Shipped Cases")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Shipped Cases field.', Comment = '%';
                }
                field("Case Weight"; Rec."Case Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Case Weight field.', Comment = '%';
                }
                field("Gross Sales at Value"; Rec."Gross Sales at Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Sales at Value field.', Comment = '%';
                }
                field("Gross Sales"; Rec."Gross Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Sales field.', Comment = '%';
                }
                field(Sales; Rec.Sales)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales field.', Comment = '%';
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount field.', Comment = '%';
                }
                field("Accrued Promotion"; Rec."Accrued Promotion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accrued Promotion field.', Comment = '%';
                }
                field("Cash Discount"; Rec."Cash Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Discount field.', Comment = '%';
                }
                field("Cash Discount Post Exit"; Rec."Cash Discount Post Exit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Discount Post Exit field.', Comment = '%';
                }
                field("Fixed Funding"; Rec."Fixed Funding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Funding field.', Comment = '%';
                }
                field(Markdowns; Rec.Markdowns)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Markdowns field.', Comment = '%';
                }
                field("National Coupon"; Rec."National Coupon")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the National Coupon field.', Comment = '%';
                }
                field("OI Bracket"; Rec."OI Bracket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OI Bracket field.', Comment = '%';
                }
                field("OI EDLP"; Rec."OI EDLP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OI EDLP field.', Comment = '%';
                }
                field("Penalty Fines"; Rec."Penalty Fines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Penalty Fines field.', Comment = '%';
                }
                field("Retailer Coupon"; Rec."Retailer Coupon")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retailer Coupon field.', Comment = '%';
                }
                field(Returns; Rec.Returns)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Returns field.', Comment = '%';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Date field.', Comment = '%';
                }
                field(Slotting; Rec.Slotting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Slotting field.', Comment = '%';
                }
                field("Trade Other"; Rec."Trade Other")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Other field.', Comment = '%';
                }
                field("Trade Warehouse"; Rec."Trade Warehouse")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Warehouse field.', Comment = '%';
                }
                field(Unsalable; Rec.Unsalable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unsalable field.', Comment = '%';
                }
                field("Total Trade Amount"; Rec."Total Trade Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Trade Amount field.', Comment = '%';
                }
                field("Sales Net Trade"; Rec."Sales Net Trade")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Net Trade field.', Comment = '%';
                }
                field(Cost; Rec.Cost)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost field.', Comment = '%';
                }
                field("Inbound Freight"; Rec."Inbound Freight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inbound Freight field.', Comment = '%';
                }
                field("WH Inbound Variable"; Rec."WH Inbound Variable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WH Inbound Variable field.', Comment = '%';
                }
                field("WH Overhead - Fixed"; Rec."WH Overhead - Fixed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WH Overhead - Fixed field.', Comment = '%';
                }
                field("Total Indirect Cost"; Rec."Total Indirect Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Indirect Cost field.', Comment = '%';
                }
                field("Gross Profit"; Rec."Gross Profit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Profit field.', Comment = '%';
                }
                field("Incremental Load Time Stamp"; Rec."Incremental Load Time Stamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Incremental Load Time Stamp field.', Comment = '%';
                }
                field(DW_Batch; Rec.DW_Batch)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DW_Batch field.', Comment = '%';
                }
                field(DW_SourceCode; Rec.DW_SourceCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DW_SourceCode field.', Comment = '%';
                }
                field(DW_TimeStamp; Rec.DW_TimeStamp)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DW_TimeStamp field.', Comment = '%';
                }
            }
        }
    }
}