/// <summary>
/// PageExtension SBCEDI Payment Remit Advice (ID 50080) extends Record LAX EDI Payment Remit Advice.
/// </summary>
pageextension 50082 "SBCEDI Payment Remit Advice" extends "LAX EDI Payment Remit Advice"
{

    layout
    {
        addafter("Remittance Type")
        {

            field("Bank Account No."; Rec."Bank Account No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bank Account No. field.';
                Visible = true;
            }
            // #275
            field("Line Deduction Amount"; DeductionAmt)
            {
                ApplicationArea = All;
                Caption = 'Deduction Amount';
                Editable = false;
                ToolTip = 'Specifies the value of the Deduction Amount field.';
                Visible = true;
            }
            field("Line Payment Amount"; PaymentAmt)
            {
                ApplicationArea = All;
                Caption = 'Payment Amount';
                Editable = false;
                ToolTip = 'Specifies the value of the Payment Amount field.';
                Visible = true;
            }
            field("Line Discount Amount"; DiscountAmt)
            {
                ApplicationArea = All;
                Caption = 'Discount Amount';
                Editable = false;
                ToolTip = 'Specifies the value of the Discount Amount field.';
                Visible = true;
            }
            // #275
        }
    }
    actions
    {
        addafter("Create &Suggested Cash Receipt Journal")
        {
            action(SBCEDICreateSuggestedCashReceipt)
            {
                ApplicationArea = All;
                Caption = 'Create Suggested Cash Receipt Journal';
                Image = GetEntries;
                trigger OnAction()
                var
                    EDIDocument: Record "LAX EDI Document";
                    GenJournalTemplate: Record "Gen. Journal Template";
                    EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.";
                    LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
                    SBCEDIRemitAdviceHelper: Codeunit "SBCEDI 820 Remit Helper";
                begin
                    CurrPage.SetSelectionFilter(LAXEDIPaymentRemitAdvice);
                    if not LAXEDIPaymentRemitAdvice.HasFilter() then
                        if not SBCEDIRemitAdviceHelper.ConfirmSelectAll() then
                            exit;
                    LAXEDIPaymentRemitAdvice.SetFilter("Remittance Type", '%1', "LAX EDI Remittance Type"::Payment);
                    LAXEDIPaymentRemitAdvice.SetRange("Suggested Deposit Created", false);
                    if LAXEDIPaymentRemitAdvice.IsEmpty() then
                        exit;
                    LAXEDIPaymentRemitAdvice.FindSet();
                    EDIRecDocHdr.Get(LAXEDIPaymentRemitAdvice."Internal Doc. No.");
                    EDIDocument.Get(
                        EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.",
                        EDIRecDocHdr."EDI Version", EDIDocument.Type::Import);
                    GenJournalTemplate.Get(EDIDocument."Journal Template Name");
                    GenJournalTemplate.TestField(Type, GenJournalTemplate.Type::"Cash Receipts");
                    GlobalStartTimeStamp := CurrentDateTime;
                    repeat
                        SBCEDIRemitAdviceHelper.CreateCashReceiptJournal(EDIRecDocHdr, LAXEDIPaymentRemitAdvice, EDIDocument);
                    until LAXEDIPaymentRemitAdvice.Next() = 0;
                end;
            }

            // action(SBCReopenMulti)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Reopen Multiple Payment Advices';
            //     Image = ReOpen;


            //     trigger OnAction()
            //     var
            //         LAXEDICreatePmtRemitAdv: Codeunit "LAX EDI Create Pmt Remit Adv.";
            //         LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
            //         SBCEDIRemitAdviceHelper: Codeunit "SBCEDI Remit Advice Helper";
            //     begin
            //         CurrPage.SetSelectionFilter(LAXEDIPaymentRemitAdvice);
            //         if not LAXEDIPaymentRemitAdvice.HasFilter() then
            //             if not SBCEDIRemitAdviceHelper.ConfirmSelectAll() then
            //                 exit;
            //         LAXEDIPaymentRemitAdvice.SetRange(Released, true);
            //         if LAXEDIPaymentRemitAdvice.IsEmpty() then
            //             exit;
            //         LAXEDIPaymentRemitAdvice.FindSet(true);
            //         repeat
            //             LAXEDICreatePmtRemitAdv.ReopenPaymentAdvice(LAXEDIPaymentRemitAdvice);
            //         until LAXEDIPaymentRemitAdvice.Next() = 0;
            //         CurrPage.Update(false);
            //     end;
            // }

        }
        modify("Create &Suggested Cash Receipt Journal")
        {
            Visible = false;
            Enabled = false;
        }
        addfirst(Category_Process)
        {
            actionref(SBCEDICreateSuggestedCashReceipt_Promoted; SBCEDICreateSuggestedCashReceipt)
            {
            }
            // actionref(SBCReopenMulti_Promoted; SBCReopenMulti)
            // {
            // }
        }

    }

    trigger OnAfterGetCurrRecord()
    var
        LAXEDIPaymentRemitAdviceLine: Record "LAX EDI Pmt. Remit Advice Line";
    begin
        DeductionAmt := 0;
        PaymentAmt := 0;
        LAXEDIPaymentRemitAdviceLine.SetRange("Payment Advice No.", Rec."No.");
        if LAXEDIPaymentRemitAdviceLine.FindSet() then
            repeat
                if LAXEDIPaymentRemitAdviceLine."Journal Account Type" = LAXEDIPaymentRemitAdviceLine."Journal Account Type"::"Customer" then
                    PaymentAmt += LAXEDIPaymentRemitAdviceLine.Amount;
                if LAXEDIPaymentRemitAdviceLine."Journal Account Type" = LAXEDIPaymentRemitAdviceLine."Journal Account Type"::"G/L Account" then
                    DeductionAmt += LAXEDIPaymentRemitAdviceLine.Amount;
                DiscountAmt += LAXEDIPaymentRemitAdviceLine."Discount Amount";
            until LAXEDIPaymentRemitAdviceLine.Next() = 0;

    end;

    var

        GlobalStartTimeStamp: DateTime;
        DeductionAmt: Decimal;
        PaymentAmt: Decimal;
        DiscountAmt: Decimal;
}