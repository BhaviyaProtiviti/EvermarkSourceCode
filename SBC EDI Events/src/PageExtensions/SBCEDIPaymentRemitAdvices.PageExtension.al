/// <summary>
/// PageExtension SBCEDI Payment Remit Advice (ID 50080) extends Record LAX EDI Payment Remit Advice.
/// </summary>
pageextension 50080 "SBCEDI Payment Remit Advices" extends "LAX EDI Payment Remit Advices"
{

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

            action(SBCReopenMulti)
            {
                ApplicationArea = All;
                Caption = 'Reopen Multiple Payment Advices';
                Image = ReOpen;


                trigger OnAction()
                var
                    LAXEDICreatePmtRemitAdv: Codeunit "LAX EDI Create Pmt Remit Adv.";
                    LAXEDIPaymentRemitAdvice: Record "LAX EDI Payment Remit Advice";
                    SBCEDIRemitAdviceHelper: Codeunit "SBCEDI 820 Remit Helper";
                begin
                    CurrPage.SetSelectionFilter(LAXEDIPaymentRemitAdvice);
                    if not LAXEDIPaymentRemitAdvice.HasFilter() then
                        if not SBCEDIRemitAdviceHelper.ConfirmSelectAll() then
                            exit;
                    LAXEDIPaymentRemitAdvice.SetRange(Released, true);
                    if LAXEDIPaymentRemitAdvice.IsEmpty() then
                        exit;
                    LAXEDIPaymentRemitAdvice.FindSet(true);
                    repeat
                        LAXEDICreatePmtRemitAdv.ReopenPaymentAdvice(LAXEDIPaymentRemitAdvice);
                    until LAXEDIPaymentRemitAdvice.Next() = 0;
                    CurrPage.Update(false);
                end;
            }

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
            actionref(SBCReopenMulti_Promoted; SBCReopenMulti)
            {
            }
        }

    }

    var

        GlobalStartTimeStamp: DateTime;
}