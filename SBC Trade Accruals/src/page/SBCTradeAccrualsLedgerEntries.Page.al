page 50702 SBCTradeAccrualsLedgerEntries
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = SBCTradeAccrualLedgerEntry;
    Caption = 'Trade Accruals Ledger Entries';
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(PostingDate; Rec.PostingDate)
                {
                    ApplicationArea = All;
                }
                field(documentNo; Rec.documentNo)
                {
                    ApplicationArea = All;
                }
                field(orderNo; Rec.orderNo)
                {
                    ApplicationArea = All;
                }
                field(OrderLineNo; Rec.OrderLineNo)
                {
                    ApplicationArea = All;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = All;
                }
                field(CustomerNo; Rec.CustomerNo)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Base; Rec.Base)
                {
                    ApplicationArea = All;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Derived From Amount"; Rec."Derived From Amount")
                {
                    ApplicationArea = All;
                }
                field(CustomerGroup; Rec.CustomerGroup)
                {
                    ApplicationArea = All;
                }
                field(GlobalDimension1; Rec.GlobalDimension1)
                {
                    ApplicationArea = All;
                }
                field(GlobalDimension2; Rec.GlobalDimension2)
                {
                    ApplicationArea = All;
                }
                field(GlobalDimension4; Rec.GlobalDimension4)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}