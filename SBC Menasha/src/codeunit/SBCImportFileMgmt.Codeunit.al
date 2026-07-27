/// <summary>
/// Codeunit SBC Import File Mgmt (ID 50353).
/// </summary>
codeunit 50353 "SBC Import File Mgmt"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    trigger OnRun()
    begin
    end;

    #region importManually

    procedure ImportExcelSheet()
    var
        FileManagement: Codeunit "File Management";
        Instream: InStream;
        FromFile: Text;
    begin
        UploadIntoStream('Please choose the Excel file', '', '', FromFile, Instream);
        if FromFile <> '' then
            ReadExcel(Instream, FileManagement.GetFileName(FromFile), FileManagement.GetExtension(FromFile))
        else
            Error('No file found');
    end;

    #endregion importManually

    #region readExcel    

    local procedure ReadExcel(Instream: InStream; FileName: Text; FileExt: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        ContractType: Enum "SBC Contract Type";
        ImportDocNo: Code[20];
        SheetName: Text;
        MaxRowNo: Integer;
        HasLineErrors: Boolean;
    begin
        //Read import and automatically determine the contract type
        TempExcelBuffer.GetSheetsNameListFromStream(Instream, TempNameValueBuffer);

        TempNameValueBuffer.Reset();
        TempNameValueBuffer.Ascending(false);
        if TempNameValueBuffer.FindSet() then
            repeat
                SheetName := TempNameValueBuffer.Value;
                SetFileType(ContractType, SheetName);
                if ContractType <> ContractType::" " then
                    ReadExcel(Enum::"SBC Contract Source"::"SBC Menasha", ContractType, SheetName, Instream, FileName, FileExt);
            until TempNameValueBuffer.Next() = 0;
    end;

    local procedure ReadExcel(ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; SheetName: Text; Instream: InStream; FileName: Text; FileExt: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        ImportDocNo: Code[20];
        MaxRowNo: Integer;
        HasLineErrors: Boolean;
    begin
        if ReadSheet(MaxRowNo, Instream, SheetName) then begin
            ImportDocNo := CreateImportHeader(ContractSource, ContractType, FileName);
            HasLineErrors := ImportData(ContractSource, ContractType, Instream, ImportDocNo, SheetName, MaxRowNo);
            AttachDocument(ImportDocNo, ContractSource, ContractType, Instream, FileName, FileExt, HasLineErrors);
        end;
    end;

    local procedure ReadSheet(var MaxRowNo: Integer; Instream: InStream; SheetName: Text): Boolean
    begin
        TempExcelBuffer.OpenBookStream(Instream, SheetName);
        TempExcelBuffer.ReadSheet();

        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";

        if MaxRowNo <> 0 then
            exit(true);
    end;

    local procedure SetFileType(var ContractType: Enum "SBC Contract Type"; SheetName: Text)
    begin
        if SheetName.Contains('Inventory') then
            ContractType := ContractType::"SBC Inventory"
        else
            if SheetName.Contains('Consumption') then
                ContractType := ContractType::"SBC Consumption"
            else
                if SheetName.Contains('FG') then
                    ContractType := ContractType::"SBC Finished Goods"
                else
                    ContractType := ContractType::" "
    end;

    #endregion readExcel

    #region createHeader

    local procedure CreateImportHeader(ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; FileName: Text): Code[20]
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
    begin
        ContractMfgHeader.Reset();
        ContractMfgHeader.Init();
        ContractMfgHeader."SBC Contract Source" := ContractSource;
        ContractMfgHeader."SBC Contract Type" := ContractType;
        ContractMfgHeader.Validate("SBC Import Name", FileName);
        ContractMfgHeader.Validate("SBC Import Receive Date", Today);
        ContractMfgHeader.Insert(true);
        exit(ContractMfgHeader."SBC Import Document No.");
    end;

    local procedure AttachDocument(ImportDocNo: Code[20]; ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; InStream: InStream; FileName: Text; FileExt: Text; HasLineErrors: Boolean)
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
        DocumentAttachmentMgmt: Codeunit "SBC Document Attachment Mgmt";
        RecordRef: RecordRef;
    begin
        ContractMfgHeader.Get(ImportDocNo, ContractSource, ContractType);
        RecordRef.Open(Database::"SBC Contract Mfg. Header");
        RecordRef.GetTable(ContractMfgHeader);
        DocumentAttachmentMgmt.SaveAttachment(InStream, RecordRef, FileName, FileExt);

        if HasLineErrors then begin
            ContractMfgHeader."SBC Has Line Errors" := true;
            ContractMfgHeader.Modify(true);
        end;
    end;

    #endregion createHeader

    #region importData

    local procedure ImportData(ContractSource: Enum "SBC Contract Source"; ContractType: Enum "SBC Contract Type"; Instream: InStream; ImportDocNo: Code[20]; SheetName: Text; MaxRowNo: Integer): Boolean
    var
        ImportContractInvMgmt: Codeunit "SBC Import Contract Inv Mgmt";
        ImportContractProdMgmt: Codeunit "SBC Import Contract ProdMgmt.";
        HasLineErrors: Boolean;
        UpdateHeaderLineErrors: Boolean;
    begin
        TempExcelBuffer.Reset();

        if ContractType = ContractType::"SBC Inventory" then
            HasLineErrors := ImportContractInvMgmt.ImportInventorySummary(TempExcelBuffer, ContractSource, ImportDocNo, MaxRowNo)
        else
            HasLineErrors := ImportContractProdMgmt.ImportProductionConsumption(TempExcelBuffer, ContractSource, ContractType, ImportDocNo, SheetName, MaxRowNo);

        if HasLineErrors then
            UpdateHeaderLineErrors := true;
        exit(UpdateHeaderLineErrors);
    end;

    // local procedure ImportMenashaData(ContractType: Enum "SBC Contract Type"; Instream: InStream; ImportDocNo: Code[20]; SheetName: Text; MaxRowNo: Integer): Boolean
    // var
    //     MenashaImportProdMgmt: Codeunit "SBC Menasha Import Prod. Mgmt.";
    //     MenashaImportInvMgmt: Codeunit "SBC Menasha Import Inv. Mgmt";
    //     HasLineErrors: Boolean;
    //     UpdateHeaderLineErrors: Boolean;
    // begin
    //     TempExcelBuffer.Reset();

    //     if ContractType = ContractType::"SBC Inventory" then
    //         HasLineErrors := MenashaImportInvMgmt.ImportInventorySummary(TempExcelBuffer, Enum::"SBC Contract Source"::"SBC Menasha" ,ImportDocNo, MaxRowNo)
    //     else
    //         HasLineErrors := MenashaImportProdMgmt.ImportProductionConsumption(TempExcelBuffer, ContractType, ImportDocNo, SheetName, MaxRowNo);

    //     if HasLineErrors then
    //         UpdateHeaderLineErrors := true;
    //     exit(UpdateHeaderLineErrors);
    // end;

    #endregion importData

    #region logImportError

    /// <summary>
    /// LogImportError.
    /// </summary>
    /// <param name="ImportDocNo">Code[20].</param>
    /// <param name="ContractType">Enum "SBC Contract Type".</param>
    /// <param name="ErrorTxt">Text.</param>
    procedure LogImportError(ImportDocNo: Code[20]; ContractType: Enum "SBC Contract Type"; ErrorTxt: Text)
    var
        ContractMfgHeader: Record "SBC Contract Mfg. Header";
    begin
        if ContractMfgHeader.Get(ImportDocNo, ContractType) then begin
            ContractMfgHeader.Validate("SBC Error Message", CopyStr(ErrorTxt, 1, 250));
            ContractMfgHeader.Modify(true);
        end;
    end;

    #endregion logImportError

}
