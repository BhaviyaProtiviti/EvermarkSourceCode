report 50122 "SBC Delete Concur Invoices"
{
    Caption = 'SBC Delete Concur Invoices';
    ProcessingOnly = true;

    dataset
    {
        dataitem(ConcurImportEntry_; "Concur Import Entry")
        {
            RequestFilterFields = "Entry No.";
            DataItemTableView = where("Purchase Invoice No." = filter(<> ''));

            trigger OnAfterGetRecord()
            var
                PurchaseHeader: Record "Purchase Header";
            begin
                PurchaseHeader.Reset();
                if PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, ConcurImportEntry_."Purchase Invoice No.") then begin
                    PurchaseHeader.Delete(true);
                    DeleteInvNo(ConcurImportEntry_."Purchase Invoice No.");
                end;
            end;
        }
    }

    trigger OnPreReport()
    begin
        if not Confirm('This report will delete Purchase Invoices and related Purchase Invoice Lines that have not been posted for Concur transactions. Do you want to continue?') then
            Error('');
    end;

    trigger OnPostReport()
    begin
        Message('Process completed');
    end;

    local procedure DeleteInvNo(PurchInvNo: Code[20])
    var
        ConcurImportEntry: Record "Concur Import Entry";
    begin
        ConcurImportEntry.SetRange("Purchase Invoice No.", PurchInvNo);
        if ConcurImportEntry.FindSet(true) then begin 
            ConcurImportEntry.ModifyAll("Purchase Invoice Line No.", 0);
            ConcurImportEntry.ModifyAll("Purchase Invoice No.", '');
        end
    end;
}
