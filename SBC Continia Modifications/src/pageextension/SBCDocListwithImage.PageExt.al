pageextension 50160 "SBC Doc List with Image" extends "CDC Document List With Image"
{
    layout
    {
        addlast(Group2)
        {            
            field("SBC Order No."; Rec."SBC Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Order No. field.';
            }
            field("SBC Invoice No."; Rec."SBC Invoice No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Invoice No. field.';
            }
            field("SBC Invoice Date"; Rec."SBC Invoice Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Invoice Date field.', Comment = '%';
            }
            field("SBC Amount Excl. Tax"; Rec."SBC Amount Excl. Tax")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the SBC Amount Excl. Tax field.', Comment = '%';
            }
        }
    }
}
