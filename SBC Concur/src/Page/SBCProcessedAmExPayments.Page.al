page 50126 "SBC Processed AmEx Payments"
{
    ApplicationArea = All;
    Caption = 'Processed AmEx Payments';
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "SBC AmEx Remittance Import";
    SourceTableView = where("SBC Payment Created" = const(true));
    UsageCategory = History;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("SBC Entry No."; Rec."SBC Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Import Entry No. field.', Comment = '%';
                }
                field("SBC Import Date"; Rec."SBC Import Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date the report was Imported';
                }
                field("SBC AmEx Report Date"; Rec."SBC AmEx Report Date")
                {
                    ToolTip = 'Specifies the value of the SBC AmEx Report Date field.', Comment = '%';
                }
                field("SBC AmEx Employee Name"; Rec."SBC AmEx Employee Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The employee name';
                }
                field("SBC AmEx Employee ID"; Rec."SBC AmEx Employee ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The employee ID';
                }
                field("SBC AmEx Balance Due"; Rec."SBC AmEx Balance Due")
                {
                    ApplicationArea = All;
                    ToolTip = 'The balance due';
                }
                field("SBC AmEx Payment Due"; Rec."SBC AmEx Payment Due")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Payment due';
                }
                field("SBC AmEx Card Member Status"; Rec."SBC AmEx Card Member Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC AmEx Card Member Status field.', Comment = '%';
                }
                field("SBC AmEx Control Acct Name"; Rec."SBC AmEx Control Acct Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC AmEx Basic Control Acct Name field.', Comment = '%';
                }
                field("SBC AmEx Control Acct No."; Rec."SBC AmEx Control Acct No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC AmEx Basic Control Acct. No. field.', Comment = '%';
                }
                field("SBC AmEx Billed Currency"; Rec."SBC AmEx Billed Currency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC AmEx Billed Currency field.', Comment = '%';
                }
                field("SBC Amex Cost Center"; Rec."SBC Amex Cost Center")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC Amex Cost Center field.', Comment = '%';
                }
            }
        }
    }
}
