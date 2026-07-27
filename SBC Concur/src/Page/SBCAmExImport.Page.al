page 50101 "SBC AmEx Import"
{
    Caption = 'AmEx Remittance Import';
    InsertAllowed = false;
    PageType = List;
    ModifyAllowed = false;
    SourceTable = "SBC AmEx Remittance Import";
    SourceTableView = where("SBC Payment Created" = const(false));
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Import)
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
                field("SBC AmEx Report Date"; Rec."SBC AmEx Report Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SBC AmEx Report Date field.', Comment = '%';
                }
                // field("SBC Payment Created";Rec."SBC Payment Created")
                // {
                //     ApplicationArea = All;
                //     toolTip = 'Specifies if the payment has been created';
                // }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportFile)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import the AmEx remittance file';

                trigger OnAction()
                var
                    SBCAmExRemittanceImport: Codeunit "SBC AmEx Remittance Import";
                begin
                    SBCAmExRemittanceImport.ImportAmExRemittance();
                    CurrPage.Update();
                end;
            }
            action(CreatePmt)
            {
                ApplicationArea = All;
                Caption = 'Create Payment';
                Image = Payment;
                ToolTip = 'Create the payment for the selected record';

                trigger OnAction()
                var
                    SBCCreatePayment: Report "SBC Create Payment";
                begin
                    SBCCreatePayment.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(ImportFile_Ref; ImportFile)
            {
            }
            actionref(CreatePmt_Ref; CreatePmt)
            {
            }

        }
    }
}