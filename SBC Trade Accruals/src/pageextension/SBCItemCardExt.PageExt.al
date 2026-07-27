pageextension 50701 "SBC Item Card Ext" extends "Item Card"
{
    layout
    {
        addlast("Costs & Posting")
        {
            group("Indirect Costs")
            {
                Caption = 'Indirect';
                field("Inbound Freight Rate"; Rec."Inbound Freight Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'The rate applied for inbound freight costs associated with this item.';
                }
                field("Custom Duty Rate"; Rec."WB Inbound Variable")
                {
                    ApplicationArea = All;
                    ToolTip = 'The rate applied for custom duties associated with this item.';
                }
                field("WH Overhead - Fixed"; Rec."WH Overhead - Fixed")
                {
                    ApplicationArea = All;
                    ToolTip = 'The rate applied for WH overhead costs associated with this item.';
                }
                field("SBC Custom/Duty"; Rec."SBC Custom/Duty")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}