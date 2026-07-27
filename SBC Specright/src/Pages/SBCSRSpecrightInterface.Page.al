/// <summary>
/// Page SBCSR Specright Interface (ID 50180).
/// </summary>
page 50180 "SBCSR Specright Interface"
{
    ApplicationArea = All;
    Caption = 'Specright Interface';
    PageType = List;
    SourceTable = "SBC SpecRight Interface";
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is an update queue that notifies SBC that an update to the item identified by the written key has been updated.';
                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        if not Item.Get(Rec."Item No.") then
                            exit;
                        Page.Run(Page::"Item Card",Item);
                    end;
                }
                field("Item ID"; Rec."Item ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The unique identifier of the item that was updated.';
                }
                field("External Item ID"; Rec."External Item ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The external identifier of the item that was updated.';
                }
                field("Processed Timestamp"; Rec."Processed Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'The last sync time of the item from SpecRight.';
                }
            }
        }
    }
}