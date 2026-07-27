pageextension 50142 "SBC Value Entries" extends "Value Entries"
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
