report 50142 "SBC Mass Update Template"
{
    ApplicationArea = All;
    Caption = 'SBC Mass Update Template';
    DefaultLayout = Excel;
    ExcelLayout = 'Purchase Order Mass Update Template.xlsx';
    UsageCategory = None;

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            DataItemTableView = where("Document Type" = filter("Document Type"::Order));
            RequestFilterFields = "No.";
            dataitem(PurchaseLine; "Purchase Line")
            {
                DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");
                DataItemLinkReference = PurchaseHeader;
                DataItemTableView = where("No." = filter(<> ''), Type = filter(Item));
                column(DocumentNo; "Document No.")
                {
                }
                column(LineNo_PurchaseLine; "Line No.")
                {
                }
                column(Production_Plant_1; "SBC Production Plant 1")
                {
                }
                column(Requested_Receipt_Date_PurchaseLine; "Requested Receipt Date")
                {
                }
                column(Expected_Ship_Date_PurchaseLine; "EVM Expected Ship Date")
                {
                }
                column(Direct_Unit_Cost_PurchaseLine; "Direct Unit Cost")
                {
                }
            }
        }
    }
}
