report 50120 "SBC Populate Employee ID"
{
    Caption = 'SBC Populate Concur Employee ID';
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPreReport()
    begin
        UpdateEmployeeIDs();
    end;

    local procedure UpdateEmployeeIDs()
    var
        ConcurImportEntry: Record "Concur Import Entry";
        PurchInvList: list of [Code[20]];
    begin
        ConcurImportEntry.SetFilter("Purchase Invoice No.", '<>%1', '');
        ConcurImportEntry.SetFilter("Payment Code", '%1|%2', 'IBCP', 'CBCP');
        if ConcurImportEntry.FindSet() then
            repeat
                if not PurchInvList.Contains(ConcurImportEntry."Purchase Invoice No.") then begin
                    PurchInvList.Add(ConcurImportEntry."Purchase Invoice No.");
                    UpdateEmployeeID(ConcurImportEntry."Purchase Invoice No.", ConcurImportEntry."Employee ID");
                end;
            until ConcurImportEntry.Next() = 0;
    end;

    local procedure UpdateEmployeeID(PurchInvDocNo: Code[20]; EmployeeID: Text[30])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        PurchInvHeader.Reset();
        if PurchInvHeader.Get(PurchInvDocNo) then
            if PurchInvHeader."SBC Employee ID" = '' then begin
                PurchInvHeader."SBC Employee ID" := EmployeeID;
                PurchInvHeader.Modify(true);
            end;

        VendorLedgerEntry.SetRange("Document No.", PurchInvDocNo);
        VendorLedgerEntry.SetRange("Vendor No.", PurchInvHeader."Buy-from Vendor No.");
        VendorLedgerEntry.SetRange("SBC Employee ID", '');
        VendorLedgerEntry.ModifyAll("SBC Employee ID", EmployeeID);
    end;

}
