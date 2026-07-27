pageextension 50359 "SBC Kinaxis Vendor Card" extends "Vendor Card"
{
    layout
    {
        addlast(content)
        {
            group(SBC_Kinaxis)
            {
                Caption = 'Kinaxis';

                field("SBC Kinaxis Vendor Region"; Rec."SBC Kinaxis Vendor Region")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Vendor Region field.', Comment = '%';
                }
                field("SBC Kinaxis Supplier Grouping"; Rec."SBC Kinaxis Supplier Grouping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Supplier Grouping field.', Comment = '%';
                }
                field("SBC Kinaxis Send to Kinaxis"; Rec."SBC Kinaxis Send to Kinaxis")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Send to Kinaxis field.', Comment = '%';
                }
                field("SBC Kinaxis Vendor UOM"; Rec."SBC Kinaxis Vendor UOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Kinaxis Vendor UOM.', Comment = '%';
                }
            }
        }
    }
}
