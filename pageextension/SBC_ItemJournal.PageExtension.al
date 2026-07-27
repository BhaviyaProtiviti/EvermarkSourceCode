pageextension 50100 "SBC Item Journal" extends "Item Journal"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("SBC Processing Error Message"; Rec."SBC Processing Error Message")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    //Temp for dev
    actions
    {
        addlast("F&unctions")
        {
            action("Match ODW NA Inventory")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MatchNAInventory: Report "SBC Match NA Inventory";
                begin
                    MatchNAInventory.Run();
                end;
            }
            action("Clear Available Inventory")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ClearAvailableInventory: Report "SBC Clear Available Inventory";
                begin
                    ClearAvailableInventory.Run();
                end;
            }
        }
    }
    //Temp for dev
}