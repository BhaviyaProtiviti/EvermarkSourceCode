// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50604 "SBC Exp. External Data EFT"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    begin
        CreateExportFile(Rec, true);
    end;

    var
        ExternalContentErr: Label '%1 is empty.', Comment = '%1=File Content field caption.';
        DownloadFromStreamErr: Label 'The file has not been saved.';

    procedure CreateExportFile(DataExch: Record "Data Exch."; ShowDialog: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        ExportFileName: Text;
        CreditTransferRegister: Record "Credit Transfer Register";
        BankAccount: record "Bank Account";
        DownLoadFileName: text;
        DownloadPaymentToClient: Boolean;
        BankAccNotFoundErr: Label 'The Bank Account was not found.';
    begin
        DataExch.CalcFields("File Content");
        if not DataExch."File Content".HasValue() then
            Error(ExternalContentErr, DataExch.FieldCaption("File Content"));

        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));
        ExportFileName := '';
        DownLoadFileName := '';
        DownloadPaymentToClient := false;
        CreditTransferRegister.SetRange("Data Exch. Entry No.", DataExch."Entry No.");
        if (CreditTransferRegister.FindFirst()) then begin
            if BankAccount.get(CreditTransferRegister."From Bank Account No.") then begin
                BankAccount.TestField("WF Export File Path");
                ExportFileName := BankAccount."WF Export File Path" + SetFileName();
                DownLoadFileName := ExportFileName;
                DownloadPaymentToClient := BankAccount."TIG Download Payment to client";
            end
            else
                Error(BankAccNotFoundErr);
        end;

        if DownLoadFileName = '' then
            DownLoadFileName := SetFileName(); //'C:\BANK\BOA\File_' + 
        if ExportFileName <> '' then begin
            BLOBExportToServerFile(TempBlob, ExportFileName, true);
        end;
        if DownloadPaymentToClient then
            if FileMgt.BLOBExport(TempBlob, DownLoadFileName, ShowDialog) = '' then
                Error(DownloadFromStreamErr);
    end;

    procedure BLOBExportToServerFile(var TempBlob: Codeunit "Temp Blob"; FilePath: Text; XMLHeaderSpecial: Boolean)
    var
        AFSManagement: Codeunit EVMAzureFileShareManagement;
        FinalTempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        Btext: BigText;
        XMLString: Text;
    begin
        TempBlob.CreateInStream(InStream);
        InStream.ReadText(XMLString);
        InStream.ReadText(XMLString);

        FinalTempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('<?xml version="1.0" encoding="UTF-8"?>');
        OutStream.WriteText();
        OutStream.WriteText('<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03">');
        OutStream.WriteText();

        Btext.Read(InStream);
        Btext.Write(OutStream);

        FinalTempBlob.CreateInStream(InStream);

        AFSManagement.WriteFileToShare(FilePath, InStream);
    end;

    var
        AlreadyExistsErr: Label 'The file already exists. Check the "Last Export File Name" field in the bank account.';
        Text013: Label 'The file name %1 already exists.';

    local procedure SetFileName(): Text
    var
        FileName: Text;
        TimeStamp: Text;
        Ms: Integer;
    begin
        FileName := 'suve.';
        Ms := (Time() - 000000T) MOD 1000 DIV 10;
        TimeStamp := Format(CurrentDateTime, 0, '<Hours24,2><Minutes,2><Seconds,2>') +
                     CopyStr(Format(100 + Ms), 2) +
                     Format(CurrentDateTime, 0, '<Year,2><Month,2><Day,2>');
        exit(FileName + TimeStamp + '.xml');
    end;
}