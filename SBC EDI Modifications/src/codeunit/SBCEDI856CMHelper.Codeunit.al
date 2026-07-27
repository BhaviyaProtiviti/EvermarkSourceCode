codeunit 50163 "SBC EDI 856CM Helper"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeProcessingBegins', '', false, false)]

    procedure OnBeforeProcessingBegins(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    //procedure OnBeforeModifyPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        EDIRecDocField: Record "LAX EDI Receive Document Field";
        VendorShipmentNo: Code[35];
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if (EDIRecDocHdr.Document = 'U_PURWSA') and
           (EDIRecDocHdr."EDI Document No." = '856') and
           (EDIRecDocHdr."Trade Partner No." <> 'UNILEVER')
        then begin
            EDIRecDocField.Reset;
            EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocField.SetRange("Table No.", Database::"Purchase Header");
            EDIRecDocField.SetRange("Field No.", PurchHeader.FieldNo("No."));
            if not EDIRecDocField.Find('-') then
                exit;
            if not PurchHeader.Get(
                PurchHeader."Document Type"::Order,
                CopyStr(EDIRecDocField."Field Text Value", 1, MaxStrLen(PurchHeader."No.")))
            then
                exit;

            EDIRecDocField.Reset();
            EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocField.SetRange("Table No.", Database::"Purchase Header");
            EDIRecDocField.SetRange("Field No.", PurchHeader.FieldNo("Vendor Shipment No."));
            if not EDIRecDocField.FindFirst() then
                exit;

            VendorShipmentNo := EDIRecDocField."Field Text Value";

            if VendorShipmentNo = '' then
                exit;

            /*
                        PurchHeader.Reset();
                        PurchHeader.SetRange("Vendor Shipment No.", VendorShipmentNo);
                        PurchHeader.SetRange("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");

                        if PurchHeader.FindFirst() then
                            Error(
                                'Duplicate Vendor Shipment No. %1 already exists on Purchase Order %2.',
                                VendorShipmentNo,
                                PurchHeader."No.");
            */

            PurchRcptHeader.Reset();
            PurchRcptHeader.SetRange("Vendor Shipment No.", VendorShipmentNo);
            PurchRcptHeader.SetRange("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");

            if PurchRcptHeader.FindFirst() then
                Error(
                    'Duplicate Vendor Shipment No. %1 already exists on Purchase Receipt %2.',
                    VendorShipmentNo,
                    PurchRcptHeader."No.");
        end;
    end;

}