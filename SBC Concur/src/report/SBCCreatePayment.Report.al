report 50121 "SBC Create Payment"
{
    Caption = 'Create Payment';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    caption = 'Select Posting Date to be used on Payment Journal Lines';

                    field(PostingDate_; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Posting Date';
                    }
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        PostingDate := Today;
    end;

    trigger OnPostReport()
    begin
        SBCAmExPaymentMgmt.CreatePayments(PostingDate);
    end;

    var
        SBCAmExPaymentMgmt: Codeunit "SBC AmEx Payment Mgmt";
        PostingDate: Date;
}
