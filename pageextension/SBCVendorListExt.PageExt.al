pageextension 50002 "SBC Vendor List Ext" extends "Vendor List"
{
    layout
    {
        addlast(Control1)
        {
            field("SBC Vendor Group Code"; Rec."SBC Vendor Group Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Vendor Group Code field.';
            }
            field("SBC Sensitive Vendor"; Rec."SBC Sensitive Vendor")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Sensitive Vendor field.';
            }
        }
    }
}
