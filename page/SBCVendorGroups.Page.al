page 50000 "SBC Vendor Groups"
{
    ApplicationArea = All;
    Caption = 'Vendor Groups';
    Editable = true;
    PageType = List;
    SourceTable = "SBC Vendor Group";
    UsageCategory = Administration;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SBC Code"; Rec."SBC Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field("SBC Description"; Rec."SBC Description")
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}
