page 50701 SBCTradeSetupLines
{
    PageType = List;
    UsageCategory = Administration;
    SourceTable = SBCTradeSetupLines;
    Caption = 'Trade Setup Lines';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer Group"; Rec."Customer Group")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    ApplicationArea = All;
                }
                field(Customer; Rec.CustomerNo)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
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
                field("Expense Account"; Rec."Expense Account")
                {
                    ApplicationArea = All;
                }
                field("Balancing Account"; Rec."Balancing Account")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}