pageextension 50143 "SBC Value Entries Preview" extends "Value Entries Preview"
{
    layout
    {
        addafter("Gen. Prod. Posting Group")
        {            
            field("SBC Marketing Posting Group"; Rec."SBC Marketing Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Marketing Posting Group field.', Comment = '%';
            }
            field("SBC Marketing Amount"; Rec."SBC Marketing Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Marketing Amount field.', Comment = '%';
            }
        }
    }
}
