codeunit 50162 SBCEDI944Helper
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeExit', '', false, false)]
    procedure OnBeforeExit(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")

    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        OrderNo: Code[20];

    begin
        if EDIRecDocHdr."EDI Document No." <> '944' then
            exit;

        OrderNo := GetOrderNo(EDIRecDocHdr."Internal Doc. No.");
        if OrderNo = '' then
            Error('Purchase Order number not found in 944 (W17-04).');



        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo) then
            Error('Purchase Order %1 not found in Business Central.', OrderNo);


        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");


        CreateTransferFromPO(PurchaseHeader, PurchaseLine, OrderNo);
    end;

    local procedure GetOrderNo(InternalDocNo: Code[10]): Code[20]
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";

    begin

        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", InternalDocNo);
        LAXEDIReceiveDocumentField.SetRange(Segment, 'W17');
        LAXEDIReceiveDocumentField.SetRange(Element, '04');
        LAXEDIReceiveDocumentField.SetFilter("Field Text Value", '<>%1', '');

        if LAXEDIReceiveDocumentField.FindFirst() then
            exit(LAXEDIReceiveDocumentField."Field Text Value")
        else
            exit('');
    end;

    procedure CreateTransferFromPO(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; OrderNo: Code[20])
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        SBCCreateTransfer: Codeunit "SBC Create Transfer Order";
    begin


        PurchRcptHeader.Reset();
        PurchRcptHeader.SetRange("Order No.", OrderNo);
        PurchRcptHeader.SetRange("SBC Transfer Order No.", '');
        if PurchRcptHeader.FindSet() then
            repeat

                if PurchRcptHeader."SBC Transfer Order No." = '' then begin

                    SBCCreateTransfer.CreateTransfer(PurchRcptHeader);

                end else begin


                end;

            until PurchRcptHeader.Next() = 0;
    end;
}

