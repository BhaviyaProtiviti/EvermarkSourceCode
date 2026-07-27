page 50359 "SBC Vendor Region List"
{
    ApplicationArea = All;
    Caption = 'SBC Vendor Region List';
    PageType = List;
    SourceTable = "SBC Vendor Region";
    UsageCategory = Lists;    
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("SBC Region Code"; Rec."SBC Region Code")
                {
                    ToolTip = 'Specifies the value of the SBC Region Code field.', Comment = '%';
                }
                field("SBC Name"; Rec."SBC Name")
                {
                    ToolTip = 'Specifies the value of the SBC Name field.', Comment = '%';
                }
            }
        }
    }
}
