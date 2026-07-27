page 50141 "SBC Brand Capacity by Location"
{
    ApplicationArea = All;
    Caption = 'SBC Brand Capacity by Location';
    PageType = List;
    SourceTable = "SBC Brand Capacity by Location";
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("SBC Location"; Rec."SBC Location")
                {
                    ToolTip = 'Specifies the value of the SBC Location field.', Comment = '%';
                }
                field("SBC Shortcut Dimension 1 Code"; Rec."SBC Shortcut Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Brand field.', Comment = '%';
                }
                field("SBC Max Pallet Count"; Rec."SBC Max Pallet Count")
                {
                    ToolTip = 'Specifies the value of the SBC Max Pallet Count field.', Comment = '%';
                }
                field("SBC Max Cubage Allowed";Rec."SBC Max Cubage Allowed")
                {
                    ToolTip = 'Specifies the value of the SBC Max Cubage field.', Comment = '%';
                }
                field("SBC Allow Double Stack"; Rec."SBC Allow Double Stack")
                {
                    ToolTip = 'Specifies the value of the SBC Allow Double Stack field.', Comment = '%';
                }
            }
        }
    }
}
