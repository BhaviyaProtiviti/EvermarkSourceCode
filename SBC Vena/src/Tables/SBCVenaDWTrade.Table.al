table 50261 "SBC Vena DW Trade"
{
    Caption = 'SBC Vena DW Trade';
    DataClassification = CustomerContent;
    // TableType = ExternalSQL;
    // ExternalName = 'Fact Sales Posted Transactions';
    // ExternalSchema = 'dbo';
    fields
    {
        field(1; DW_Id; BigInteger)
        {
            Caption = 'DW_Id';
        }
        field(2; "Company Id"; Text[30])
        {
            Caption = 'Company Id';
        }
        field(3; "Sales Document Id"; Code[20])
        {
            Caption = 'Sales Document Id';
        }
        field(4; "Document Line Number"; Integer)
        {
            Caption = 'Document Line Number';
        }
        field(5; "Item Id"; Code[20])
        {
            Caption = 'Item Id';
        }
        field(6; "Order Date"; DateTime)
        {
            Caption = 'Order Date';
        }
        field(7; "Posting Date"; DateTime)
        {
            Caption = 'Posting Date';
        }
        field(8; LastDayOfMonth; DateTime)
        {
            Caption = 'LastDayOfMonth';
        }
        field(9; LastDayOfMonth_ShipmentDate; DateTime)
        {
            Caption = 'LastDayOfMonth_ShipmentDate';
        }
        field(10; "Case Qty"; Decimal)
        {
            Caption = 'Case Qty';
        }
        field(11; "Customer Posting Group ID"; Code[20])
        {
            Caption = 'Customer Posting Group ID';
        }
        field(12; "Sell to Customer Id"; Code[20])
        {
            Caption = 'Sell to Customer Id';
        }
        field(13; "Bill to Customer Id"; Code[20])
        {
            Caption = 'Bill to Customer Id';
        }
        field(14; "Entry Number"; Integer)
        {
            Caption = 'Entry Number';
        }
        field(15; "Business Posting Group Id"; Code[10])
        {
            Caption = 'Business Posting Group Id';
        }
        field(16; "Document Type Code"; Integer)
        {
            Caption = 'Document Type Code';
        }
        field(17; "Document Type"; Text[80])
        {
            Caption = 'Document Type';
        }
        field(18; "Global Dimension 1 Id"; Code[20])
        {
            Caption = 'Global Dimension 1 Id';
        }
        field(19; "Global Dimension 2 Id"; Code[20])
        {
            Caption = 'Global Dimension 2 Id';
        }
        field(20; "Line Type Id"; Integer)
        {
            Caption = 'Line Type Id';
        }
        field(21; "Inventory Posting Group Id"; Code[10])
        {
            Caption = 'Inventory Posting Group Id';
        }
        field(22; "Location Id"; Code[10])
        {
            Caption = 'Location Id';
        }
        field(23; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
        }
        field(24; "Emerson Ship to Code"; Text[50])
        {
            Caption = 'Emerson Ship to Code';
        }
        field(25; "Product Posting Group Id"; Code[10])
        {
            Caption = 'Product Posting Group Id';
        }
        field(26; "Salesperson Id"; Code[10])
        {
            Caption = 'Salesperson Id';
        }
        field(27; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(28; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
        }
        field(29; "Quantity Shipped Cases"; Decimal)
        {
            Caption = 'Quantity Shipped Cases';
        }
        field(30; "Case Weight"; Decimal)
        {
            Caption = 'Case Weight';
        }
        field(31; "Gross Sales at Value"; Decimal)
        {
            Caption = 'Gross Sales at Value';
        }
        field(32; "Gross Sales"; Decimal)
        {
            Caption = 'Gross Sales';
        }
        field(33; Sales; Decimal)
        {
            Caption = 'Sales';
        }
        field(34; Discount; Decimal)
        {
            Caption = 'Discount';
        }
        field(35; "Accrued Promotion"; Decimal)
        {
            Caption = 'Accrued Promotion';
        }
        field(36; "Cash Discount"; Decimal)
        {
            Caption = 'Cash Discount';
        }
        field(37; "Cash Discount Post Exit"; Decimal)
        {
            Caption = 'Cash Discount Post Exit';
        }
        field(38; "Fixed Funding"; Decimal)
        {
            Caption = 'Fixed Funding';
        }
        field(39; Markdowns; Decimal)
        {
            Caption = 'Markdowns';
        }
        field(40; "National Coupon"; Decimal)
        {
            Caption = 'National Coupon';
        }
        field(41; "OI Bracket"; Decimal)
        {
            Caption = 'OI Bracket';
        }
        field(42; "OI EDLP"; Decimal)
        {
            Caption = 'OI EDLP';
        }
        field(43; "Penalty Fines"; Decimal)
        {
            Caption = 'Penalty Fines';
        }
        field(44; "Retailer Coupon"; Decimal)
        {
            Caption = 'Retailer Coupon';
        }
        field(45; Returns; Decimal)
        {
            Caption = 'Returns';
        }
        field(46; "Shipment Date"; DateTime)
        {
            Caption = 'Shipment Date';
        }
        field(47; Slotting; Decimal)
        {
            Caption = 'Slotting';
        }
        field(48; "Trade Other"; Decimal)
        {
            Caption = 'Trade Other';
        }
        field(49; "Trade Warehouse"; Decimal)
        {
            Caption = 'Trade Warehouse';
        }
        field(50; Unsalable; Decimal)
        {
            Caption = 'Unsalable';
        }
        field(51; "Total Trade Amount"; Decimal)
        {
            Caption = 'Total Trade Amount';
        }
        field(52; "Sales Net Trade"; Decimal)
        {
            Caption = 'Sales Net Trade';
        }
        field(53; Cost; Decimal)
        {
            Caption = 'Cost';
        }
        field(54; "Inbound Freight"; Decimal)
        {
            Caption = 'Inbound Freight';
        }
        field(55; "WH Inbound Variable"; Decimal)
        {
            Caption = 'WH Inbound Variable';
        }
        field(56; "WH Overhead - Fixed"; Decimal)
        {
            Caption = 'WH Overhead - Fixed';
        }
        field(57; "Total Indirect Cost"; Decimal)
        {
            Caption = 'Total Indirect Cost';
        }
        field(58; "Gross Profit"; Decimal)
        {
            Caption = 'Gross Profit';
        }
        field(59; "Incremental Load Time Stamp"; DateTime)
        {
            Caption = 'Incremental Load Time Stamp';
        }
        field(60; DW_Batch; BigInteger)
        {
            Caption = 'DW_Batch';

        }
        field(61; DW_SourceCode; Text[15])
        {
            Caption = 'DW_SourceCode';
        }
        field(62; DW_TimeStamp; DateTime)
        {
            Caption = 'DW_TimeStamp';
        }

    }
    keys
    {
        key(PK; DW_Id)
        {
            Clustered = true;
        }
    }
}