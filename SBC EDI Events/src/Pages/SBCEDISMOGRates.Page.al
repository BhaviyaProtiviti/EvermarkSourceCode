page 50083 "SBCEDI SMOG Rates"
{
    ApplicationArea = All;
    Caption = 'SBCEDI SMOG Rates';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "SBCEDI SMOG Rates";
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer the SMOG rate applies to.';

                }
                field("SMOG Rate"; Rec."SMOG Rate")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'SMOG rate to be applied to the Customer.';

                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field.', Comment = '%';
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Posting Group field.', Comment = '%';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Start date for the SMOG rate.';
                    Enabled = true;
                    Visible = false;

                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'End date for the SMOG rate.';
                    Enabled = true;
                    Visible = false;

                }
            }
        }
    }
}