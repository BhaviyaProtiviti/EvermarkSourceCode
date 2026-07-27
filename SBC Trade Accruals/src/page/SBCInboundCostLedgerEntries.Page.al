page 50704 SBCInboundCostLedgerEntries
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = SBCInboundCostLedgerEntry;
    Caption = 'Inbound Cost Ledger Entries';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(PostingDate; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field(DocumentType; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field(DocumentNo; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(AccrualRate; Rec."Accrual Rate")
                {
                    ApplicationArea = All;
                }
                field(AccrualAmount; Rec."Accrual Amount")
                {
                    ApplicationArea = All;
                }
                field(EntryType; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
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