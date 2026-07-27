pageextension 50123 "Vendor Card-Ext" extends "Vendor Card"
{
    layout
    {
        addafter(Contact)
        {
            field("Employee ID"; rec."Employee ID")
            {
                Caption = 'Employee ID';
                ToolTip = 'Employee ID';
                ApplicationArea = All;
            }
        }
    }
}