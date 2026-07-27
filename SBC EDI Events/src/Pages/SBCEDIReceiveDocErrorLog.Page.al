page 50140 "SBC EDI Receive Doc Error Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SBC EDI Receive Doc Error Logs";
    DeleteAllowed = true;
    Editable = false;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("SBC Internal Doc. No."; Rec."SBC Internal Doc. No.")
                {
                    ToolTip = 'Specifies the value of the Internal Doc. No. field.', Comment = '%';
                    Editable = false;
                }
                field("SBC Trade Partner No."; Rec."SBC Trade Partner No.")
                {
                    ToolTip = 'Specifies the value of the Trade Partner No. field.', Comment = '%';
                    Editable = false;
                }
                field("SBC EDI Document No."; Rec."SBC EDI Document No.")
                {
                    ToolTip = 'Specifies the value of the EDI Document No. field.', Comment = '%';
                    Editable = false;
                }
                field("SBC Error Message Text"; Rec."SBC Error Message Text")
                {
                    ToolTip = 'Specifies the value of the Error Message Text field.', Comment = '%';
                    Editable = false;
                }
                field("SBC Error Occured At"; Rec."SBC Error Occured At")
                {
                    ToolTip = 'Specifies the value of the Error Occured At field.', Comment = '%';
                    Editable = false;
                }
                field("SBC Error Resolved At"; Rec."SBC Error Resolved At")
                {
                    ToolTip = 'Specifies the value of the Error Message At field.', Comment = '%';
                    Editable = false;
                }
            }
        }
    }
}