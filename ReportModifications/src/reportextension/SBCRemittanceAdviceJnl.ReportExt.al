reportextension 50141 "SBC Remittance Advice - Jnl" extends "Remittance Advice - Journal"
{
    dataset
    {
        add(VendLoop)
        {
            column(SBCVendBankAcctAddress_1; SBCVendBankAcctAddress[1])
            {
            }
            column(SBCVendBankAcctAddress_2; SBCVendBankAcctAddress[2])
            {
            }
            column(SBCVendBankAcctAddress_3; SBCVendBankAcctAddress[3])
            {
            }
            column(SBCVendBankAcctAddress_4; SBCVendBankAcctAddress[4])
            {
            }
            column(SBCVendBankAcctAddress_5; SBCVendBankAcctAddress[5])
            {
            }
        }
        modify("Vendor Ledger Entry")
        {
            trigger OnAfterAfterGetRecord()
            var
                VendBankAccount: Record "Vendor Bank Account";
                FormatAddress: Codeunit "Format Address";
            begin
                if VendBankAccount.Get("Vendor Ledger Entry"."Vendor No.", "Vendor Ledger Entry"."Recipient Bank Account") then;
                FormatAddress.FormatAddr(SBCVendBankAcctAddress, VendBankAccount.Name, VendBankAccount."Name 2", VendBankAccount.Contact, VendBankAccount.Address, VendBankAccount."Address 2", VendBankAccount.City, VendBankAccount."Post Code", VendBankAccount.County, VendBankAccount."Country/Region Code");
            end;
        }
        add(PrintLoop)
        {
            column(Description_VendLedgEntry; TempAppliedVendLedgEntry.Description)
            {
            }
        }
    }

    rendering
    {
        layout(SBCRemitAdvice_Journal)
        {
            type = RDLC;
            Caption = 'SBC Remit. Advice - Journal';
            LayoutFile = './src/reportextension/layout/SBCRemitAdviceJournal.rdl';
        }
        layout(SBCJournal_EmailBody)
        {
            type = Word;
            Caption = 'SBC Remit. Advice - Journal Email layout';
            LayoutFile = './src/reportextension/layout/SBCJournal_EmailBody.docx';
        }
    }

    var
        SBCVendBankAcctAddress: array[8] of Text[100];

}
