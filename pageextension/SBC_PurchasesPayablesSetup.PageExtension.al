pageextension 50133 "SBC Purchases Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("SBC Purch Appr % Margin"; Rec."SBC Purch Appr % Margin")
            {
                ApplicationArea = All;
                ToolTip = 'Enter the raw percentage value (e.g. 10 = 10%). A previously approved PO can be re-released without re-approval if the new amount does not exceed the approved amount by more than this percentage.';
            }
            field("SBC Require Purch. Price"; Rec."SBC Require Purch. Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if Purchase Prices by vendor are required for items on Purchase Lines.';
            }
            field("SBC Never Delete PO's"; Rec."SBC Never Delete PO's")
            {
                ApplicationArea = All;
                Caption = 'SBC Never Delete PO''s';
                ToolTip = 'Enable this toggle to prevent purchase orders from being deleted.';
            }
        }
    }
}
