/// <summary>
/// Codeunit SBC TblHdlr Contract Mfg. Hdr (ID 50350).
/// </summary>
codeunit 50350 "SBC TblHdlr Contract Mfg. Hdr"
{
    var
        ContractMfgSetup: Record "SBC Contract Mfg. Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    procedure OnValidateImportName(var Rec: Record "SBC Contract Mfg. Header"; xRec: Record "SBC Contract Mfg. Header")
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
        PostedContractMfgHdr: Record "SBC Posted Contract Mfg Hdr";
        IsHandled: Boolean;
    begin
        OnBeforeOnValidateImportName(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        ContractMfgHeader.SetRange("SBC Import Name", Rec."SBC Import Name");
        ContractMfgHeader.SetRange("SBC Contract Source", Rec."SBC Contract Source");
        ContractMfgHeader.SetRange("SBC Contract Type", Rec."SBC Contract Type");
        ContractMfgHeader.SetFilter(SystemId, '<>%1', Rec.SystemId);
        if not ContractMfgHeader.IsEmpty then
            Error('File has already been imported.');

        PostedContractMfgHdr.SetRange("SBC Import Name", Rec."SBC Import Name");
        PostedContractMfgHdr.SetRange("SBC Contract Source", Rec."SBC Contract Source");
        PostedContractMfgHdr.SetRange("SBC Contract Type", Rec."SBC Contract Type");
        if not PostedContractMfgHdr.IsEmpty then
            Error('File has already been imported.');
    end;

    ////Archive ran from Config. Mfg pages only
    procedure ArchivePartialProcessedContract(Rec: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
        ProcessContractMfg: Codeunit "SBC Process - Contract Mfg.";
    begin
        ContractMfgLine.SetRange("SBC Import Document No.", Rec."SBC Import Document No.");
        ContractMfgLine.SetRange("SBC Contract Source", Rec."SBC Contract Source");
        ContractMfgLine.SetRange("SBC Contract Type", Rec."SBC Contract Type");
        ContractMfgLine.SetRange("SBC Line Processed", true);
        if not ContractMfgLine.IsEmpty then
            if ContractMfgLine.FindSet() then begin
                ProcessContractMfg.CreatePostedContractHdr(Rec);
                repeat
                    ProcessContractMfg.CreatePostedContractLine(ContractMfgLine);
                until ContractMfgLine.Next() = 0;
            end;
        Rec.Delete(true);
    end;

    /// <summary>
    /// OnDeleteContractMfgHeader.
    /// </summary>
    /// <param name="Rec">Record "SBC Contract Mfg. Header".</param>
    procedure OnDeleteContractMfgHeader(Rec: Record "SBC Contract Mfg. Header")
    begin
        if Rec."SBC Contract Source" = Rec."SBC Contract Source"::"SBC Menasha" then
            DeleteMenashaLines(Rec);

        DeleteDocumentAttachment(Rec);
    end;

    /// <summary>
    /// OnDeleteContractMfgHeader.
    /// </summary>
    /// <param name="Rec">Record "SBC Posted Contract Mfg Hdr".</param>
    procedure OnDeleteContractMfgHeader(Rec: Record "SBC Posted Contract Mfg Hdr")
    begin
        if Rec."SBC Contract Source" = Rec."SBC Contract Source"::"SBC Menasha" then
            DeleteMenashaLines(Rec);

        DeleteDocumentAttachment(Rec);
    end;

    #region delete

    local procedure DeleteMenashaLines(Rec: Record "SBC Contract Mfg. Header")
    var
        ContractMfgLine: Record "SBC Contract Mfg. Line";
    begin
        ContractMfgLine.SetRange("SBC Import Document No.", Rec."SBC Import Document No.");
        ContractMfgLine.SetRange("SBC Contract Type", Rec."SBC Contract Type");
        ContractMfgLine.DeleteAll();
    end;

    local procedure DeleteDocumentAttachment(Rec: Record "SBC Contract Mfg. Header")
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"SBC Contract Mfg. Header");
        DocumentAttachment.SetRange("No.", Rec."SBC Import Document No.");
        DocumentAttachment.SetRange("Document Type", Rec."SBC Contract Type".AsInteger());
        DocumentAttachment.DeleteAll();
    end;

    local procedure DeleteMenashaLines(Rec: Record "SBC Posted Contract Mfg Hdr")
    var
        ContractMfgLine: Record "SBC Posted Contract Mfg Line";
    begin
        ContractMfgLine.SetRange("SBC Import Document No.", Rec."SBC Import Document No.");
        ContractMfgLine.SetRange("SBC Contract Type", Rec."SBC Contract Type");
        ContractMfgLine.DeleteAll();
    end;

    local procedure DeleteDocumentAttachment(Rec: Record "SBC Posted Contract Mfg Hdr")
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"SBC Posted Contract Mfg Hdr");
        DocumentAttachment.SetRange("No.", Rec."SBC Import Document No.");
        DocumentAttachment.SetRange("Document Type", Rec."SBC Contract Type".AsInteger());
        DocumentAttachment.DeleteAll();
    end;

    #endregion delete

    #region setNoSeries

    /// <summary>
    /// InitInsert.
    /// </summary>
    /// <param name="ContractMfgHeader">VAR Record "SBC Contract Mfg. Header".</param>
    /// <param name="xContractMfgHeader">Record "SBC Contract Mfg. Header".</param>
    procedure InitInsert(var ContractMfgHeader: Record "SBC Contract Mfg. Header"; xContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitInsert(ContractMfgHeader, xContractMfgHeader, IsHandled);
        if not IsHandled then
            if ContractMfgHeader."SBC Import Document No." = '' then begin
                TestNoSeries(ContractMfgHeader);
                NoSeriesMgt.InitSeries(ContractMfgSetup."SBC No. Series", xContractMfgHeader."SBC No. Series", ContractMfgHeader."SBC Import Receive Date", ContractMfgHeader."SBC Import Document No.", ContractMfgHeader."SBC No. Series");
            end;

        OnInitInsertOnBeforeInitRecord(ContractMfgHeader, xContractMfgHeader);
    end;

    /// <summary>
    /// TestNoSeries.
    /// </summary>
    /// <param name="ContractMfgHeader">VAR Record "SBC Contract Mfg. Header".</param>
    procedure TestNoSeries(var ContractMfgHeader: Record "SBC Contract Mfg. Header")
    var
        NoSeries: Record "No. Series";
        IsHandled: Boolean;
    begin
        GetContractMfgSetup(ContractMfgHeader);
        IsHandled := false;

        OnBeforeTestNoSeries(ContractMfgHeader, IsHandled);
        ContractMfgSetup.TestField("SBC No. Series");

        ContractMfgSetup.GetRecordOnce();
        NoSeries.Get(ContractMfgSetup."SBC No. Series");
        NoSeries.TestField("Default Nos.", true);

        OnAfterTestNoSeries(ContractMfgHeader, ContractMfgSetup);
    end;

    local procedure GetContractMfgSetup(var ContractMfgHeader: Record "SBC Contract Mfg. Header")
    begin
        ContractMfgSetup.Get();
        OnAfterGetContractMfgSetup(ContractMfgHeader, ContractMfgSetup);
    end;

    #endregion setNoSeries    

    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnValidateImportName(var Rec: Record "SBC Contract Mfg. Header"; xRec: Record "SBC Contract Mfg. Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitInsert(var SBCContractMfgHeader: record "SBC Contract Mfg. Header"; xSBCContractMfgHeader: record "SBC Contract Mfg. Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitInsertOnBeforeInitRecord(var SBCContractMfgHeader: record "SBC Contract Mfg. Header"; xSBCContractMfgHeader: record "SBC Contract Mfg. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestNoSeries(var SBCContractMfgHeader: record "SBC Contract Mfg. Header"; var SBCContractMfgSetup: Record "SBC Contract Mfg. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetContractMfgSetup(SBCContractMfgImportHeader: record "SBC Contract Mfg. Header"; var SBCContractMfgSetup: Record "SBC Contract Mfg. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(var SBCContractMfgImportHeader: record "SBC Contract Mfg. Header"; var IsHandled: Boolean)
    begin
    end;

    #endregion eventIntegration
}
