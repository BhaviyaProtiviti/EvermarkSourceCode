/// <summary>
/// Codeunit SBC Document Attachment Mgmt (ID 50355).
/// </summary>
codeunit 50355 "SBC Document Attachment Mgmt"
{
    #region documentAttachment

    /// <summary>
    /// SetContractMgfRecRef.
    /// </summary>
    /// <param name="DocumentAttachment">Record "Document Attachment".</param>
    /// <param name="RecRef">VAR RecordRef.</param>
    procedure SetContractMgfRecRef(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
        PostedContractMfgHdr: Record "SBC Posted Contract Mfg Hdr";
    begin
        case DocumentAttachment."Table ID" of
            database::"SBC Contract Mfg. Header":
                begin
                    RecRef.Open(Database::"SBC Contract Mfg. Header");
                    ContractMfgHeader.SetRange("SBC Import Document No.", DocumentAttachment."No.");
                    ContractMfgHeader.SetRange("SBC Contract Type", DocumentAttachment."Document Type".AsInteger());
                    if ContractMfgHeader.FindFirst() then
                        RecRef.GetTable(ContractMfgHeader);
                end;
            database::"SBC Posted Contract Mfg Hdr":
                begin
                    RecRef.Open(Database::"SBC Contract Mfg. Header");
                    PostedContractMfgHdr.SetRange("SBC Import Document No.", DocumentAttachment."No.");
                    PostedContractMfgHdr.SetRange("SBC Contract Type", DocumentAttachment."Document Type".AsInteger());
                    if PostedContractMfgHdr.FindFirst() then
                    RecRef.GetTable(PostedContractMfgHdr);
                end;
        end;
    end;

    /// <summary>
    /// ImportDocumentAttachment.
    /// </summary>
    /// <param name="DocumentAttachment">VAR Record "Document Attachment".</param>
    /// <param name="RecRef">VAR RecordRef.</param>
    procedure ImportDocumentAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        DocNo: Code[20];
        DocTypeInt: Integer;
    begin
        FieldRef := RecRef.Field(1);
        if DocumentAttachment."No." <> format(FieldRef) then begin
            DocNo := FieldRef.Value;
            DocumentAttachment.Validate("No.", DocNo);
        end;
            

        FieldRef := RecRef.Field(2);
        DocTypeInt := FieldRef.Value;
        DocumentAttachment.Validate("Document Type", DocTypeInt);
    end;

    /// <summary>
    /// CopyAttachment.
    /// </summary>
    /// <param name="ContractMfgHeader">Record "SBC Contract Mfg. Header".</param>
    /// <param name="PostedContractMfgHdr">Record "SBC Posted Contract Mfg Hdr".</param>
    procedure CopyAttachment(ContractMfgHeader: Record "SBC Contract Mfg. Header"; PostedContractMfgHdr: Record "SBC Posted Contract Mfg Hdr")
    var
        TempBlob: Codeunit "Temp Blob";
        DocumentAttachment: Record "Document Attachment";
        OutStream: OutStream;
        InStream: InStream;
        RecordRef: RecordRef;
    begin
        // SaveAttachmentFromStream
        DocumentAttachment.SetRange("Table ID", Database::"SBC Contract Mfg. Header");
        DocumentAttachment.SetRange("No.", ContractMfgHeader."SBC Import Document No.");
        if DocumentAttachment.FindSet() then begin
            RecordRef.Open(Database::"SBC Posted Contract Mfg Hdr");
            RecordRef.GetTable(PostedContractMfgHdr);
            repeat
                if DocumentAttachment."Document Reference ID".HasValue then begin
                    OutStream := TempBlob.CreateOutStream();
                    DocumentAttachment."Document Reference ID".ExportStream(OutStream);
                    InStream := TempBlob.CreateInStream();

                    SaveAttachment(InStream, RecordRef, DocumentAttachment."File Name", DocumentAttachment."File Extension");
                end;
            until DocumentAttachment.Next() = 0;
        end;
    end;

    /// <summary>
    /// SaveAttachment.
    /// </summary>
    /// <param name="Instream">InStream.</param>
    /// <param name="RecRef">RecordRef.</param>
    /// <param name="FileName">Text.</param>
    /// <param name="FileExt">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure SaveAttachment(Instream: InStream; RecRef: RecordRef; FileName: Text; FileExt: Text): Boolean
    var
        DocumentAttachment: Record "Document Attachment";
        ReadTxtVar: Text;
    begin
        FileName := DelChr(FileName, '=', FileExt);
        FileName := DelChr(FileName, '=', '.');
        DocumentAttachment.Validate("File Name", FileName);
        DocumentAttachment.Validate("File Extension", FileExt);

        Instream.ReadText(ReadTxtVar);

        DocumentAttachment."Document Reference ID".ImportStream(Instream, '');
        if not DocumentAttachment."Document Reference ID".HasValue then
            exit(false);

        DocumentAttachment.InitFieldsFromRecRef(RecRef);
        exit(DocumentAttachment.Insert(true));
    end;


    #endregion documentAttachment
}
