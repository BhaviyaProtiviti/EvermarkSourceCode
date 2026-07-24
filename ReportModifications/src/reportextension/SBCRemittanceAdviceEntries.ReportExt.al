reportextension 50140 "SBC Remittance Advice Entries" extends "Remittance Advice - Entries"
{
    dataset
    {
        add("Vendor Ledger Entry")
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
            column(SBCPostingDate; "Vendor Ledger Entry"."Posting Date")
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
                FormatAddress.FormatAddr(SBCVendBankAcctAddress, "Vendor Name", VendBankAccount.Name, VendBankAccount.Contact, VendBankAccount.Address, VendBankAccount."Address 2", VendBankAccount.City, VendBankAccount."Post Code", VendBankAccount.County, VendBankAccount."Country/Region Code");
            end;

        }
        add(VendLedgEntry2)
        {
            column(Description_VendLedgEntry; Description)
            {
            }
        }
        add("Detailed Vendor Ledg. Entry")
        {
            column(Document_No_DtlVendLedgEntry; "Document No.")
            {
            }
        }
        add(Integer)
        {
            column(TotalAmount; TotalAmount)
            {
            }
        }
    }

    rendering
    {
        layout(SBCRemitAdvice_Entries)
        {
            type = RDLC;
            Caption = 'SBC Remit. Advice - Entries';
            LayoutFile = './src/reportextension/layout/SBCRemitAdviceEntries.rdl';
        }
        layout(SBCEntries_EmailBody)
        {
            type = Word;
            Caption = 'SBC Remit. Advice - Entries Email layout';
            LayoutFile = './src/reportextension/layout/SBCEntries_EmailBody.docx';
        }
    }

    var
        TotalAmount: Decimal;
        SBCVendBankAcctAddress: array[8] of Text[100];
}
