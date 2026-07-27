codeunit 50160 "SBC CDC Event Mgmt"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CDC Purch. - Register", OnBeforePurchHeaderInsert, '', false, false)]
    local procedure CDCPurchRegisterOnBeforePurchHeaderInsert(var PurchHeader: Record "Purchase Header"; Document: Record "CDC Document")
    var
        CDCPurchDocManagement: Codeunit "CDC Purch. Doc. - Management";
    begin
        if PurchHeader."Document Type" = PurchHeader."Document Type"::Invoice then
            PurchHeader."SBC CDC Our Order No." := CDCPurchDocManagement.GetOurDocumentNo(Document);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePurchInvHeaderInsert, '', false, false)]
    local procedure PurchPostOnBeforePurchInvHeaderInsert(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; CommitIsSupressed: Boolean)
    begin
        if (PurchHeader."Document Type" = PurchHeader."Document Type"::Invoice) and (PurchHeader."SBC CDC Our Order No." <> '') then begin
            PurchInvHeader."Order No." := PurchHeader."SBC CDC Our Order No.";

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure PurchPostOnAfterPostPurchDoc(var PurchaseHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20])
    var
        PurchaseOrderHdr: Record "Purchase Header";
        RecordLink: Record "Record Link";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        RecordRef: RecordRef;
        PurchInvRecordID: RecordId;
    begin
        if (PurchaseHeader.IsTemporary) or (PurchaseHeader."SBC CDC Our Order No." = '') then
            exit;

        if PurchaseOrderHdr.Get(PurchaseOrderHdr."Document Type"::Order, PurchaseHeader."SBC CDC Our Order No.") then begin
            RecordRef.Open(Database::"Purchase Header");
            RecordRef.Get(PurchaseOrderHdr.RecordId);

            if DocumentAttachmentMgmt.AttachedDocumentsExist(RecordRef) then begin
                RecordRef.Close();
                TransferAttachmentsNotes(PurchInvHdrNo, PurchaseOrderHdr);
            end;
        end;
    end;

    local procedure TransferAttachmentsNotes(PurchInvHdrNo: Code[20]; PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        LinkManagement: Codeunit "Record Link Management";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        RecordRef: RecordRef;
    begin
        if PurchInvHeader.Get(PurchInvHdrNo) then begin
            RecordRef.Open(Database::"Purch. Inv. Header");
            RecordRef.Get(PurchInvHeader.RecordId);
            DocumentAttachment.SetRange("Table ID", Database::"Purchase Header");
            DocumentAttachment.SetRange("No.", PurchaseHeader."No.");
            DocumentAttachment.SetRange("Document Type", DocumentAttachment."Document Type"::Order);
            if DocumentAttachment.FindSet() then
                repeat
                    Clear(TempBlob);
                    OutStream := TempBlob.CreateOutStream();
                    DocumentAttachment."Document Reference ID".ExportStream(OutStream);
                    AttachDoc(RecordRef, (DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension"), TempBlob);
                until DocumentAttachment.Next() = 0;

            LinkManagement.CopyLinks(PurchaseHeader, PurchInvHeader);
        end;
    end;

    local procedure AttachDoc(RecordRef: RecordRef; FileName: Text; TempBlob: Codeunit "Temp Blob")
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
    begin
        DocumentAttachment.Init();
        DocumentAttachment.SaveAttachment(RecordRef, FileName, TempBlob);
    end;
}