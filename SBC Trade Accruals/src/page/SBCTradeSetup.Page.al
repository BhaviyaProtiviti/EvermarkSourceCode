page 50700 SBCTradeSetup
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = SBCTradeSetupHeader;
    Caption = 'Trade Setup';

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
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(LineSetup)
            {
                Caption = 'Trade Setup Lines';
                ApplicationArea = All;
                ToolTip = 'Open the Trade Setup Lines page to manage trade setup details.';
                Image = Setup;
                RunObject = Page SBCTradeSetupLines;
                RunPageLink = "Customer Group" = field("Customer Group"), "Global Dimension 1" = field("Global Dimension 1");
            }
        }
    }
}