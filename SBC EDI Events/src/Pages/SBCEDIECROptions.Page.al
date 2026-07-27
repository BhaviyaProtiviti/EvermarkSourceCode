/// <summary>
/// Page SBCEDI ECR Options (ID 50080).
/// </summary>
page 50080 "SBCEDI ECR Settings"
{
    ApplicationArea = All;
    Caption = 'SBC EDI Remittance Settings';
    PageType = Card;
    SourceTable = "SBCEDI ECR Settings";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Emerson Trade Partner"; Rec."Emerson Trade Partner")
                {
                    ApplicationArea = All;
                    Caption = 'Emerson Trade Partner';
                    ToolTip = 'Emerson Trade Partner No.';
                    Importance = Promoted;
                }
            }

            group(PaymentAdvice)
            {
                Caption = 'Multi-Customer Payment Advice';
                field("Payment Advice Segment"; Rec."Payment Advice Segment")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Advice Segment';
                    ToolTip = 'This is the segment that defines the begining of a new multi-customer Payment Advice Entry.';
                    Importance = Additional;
                }
                field("Ignore Adjustment Flag"; Rec."Ignore Adjustment Flag")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this flag is set to true, then the system will create adjument remit advices, but not set the adjustment flag on the remit advice line.';
                    Importance = Additional;
                }
                field("Allow Different Bill-to/Pay-to"; Rec."Allow Different Bill-to/Pay-to")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this flag is set to true, then the system will allow the bill-to and pay-to to be different when create a journal without prompting the user.';
                    Importance = Additional;
                }
                group(RemittanceJournal)
                {
                    Caption = 'Remittance Journal';
                    field("Use Payer Account"; Rec."Use Payer Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Applys invoices to the Payer Account rather than the account set on the EDI 820.';
                        Importance = Standard;
                    }
                    field("Payment GL Account"; Rec."Payment GL Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This account will be used instead of the payer account when the sell-to customer account cannot be found.';
                    }
                    field("Bank Account No."; Rec."Bank Account No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is the bank account no. that will be used when creating the payment journal.';
                        Importance = Promoted;
                        ShowMandatory = true;
                    }
                    field("Payment Journal Batch Name"; Rec."Payment Journal Batch Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This is the journal batch that will be used for refunds.';
                        Importance = Promoted;
                        ShowMandatory = true;
                    }
                    field("Create Adjustment Entries"; Rec."Create Adjustment Entries")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If this flag is set to true, then the system will create adjument remit advices.';
                        Importance = Standard;
                    }
                    field("Default Trade Customer"; Rec."Default Trade Customer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'This Customer will be used for Trade Refunds when a Customer cannot be found.';
                        Importance = Standard;
                        ShowMandatory = true;
                    }
                    field("Summarize Default Trade"; Rec."Summarize Default Trade")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If this flag is set to true, then the system will summarize trade refunds based on the Default Trade Customer''s Customer Posting Group.';
                        Importance = Standard;
                    }
                    field("Set. Bal Account on Payments"; Rec."Set. Bal Account on Payments")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If this flag is set to true, then the system will set the Bal. Account on journal lines. This does not include the bank deposit line.';
                        Importance = Standard;
                    }
                    

                }

            }
        }
    }
}