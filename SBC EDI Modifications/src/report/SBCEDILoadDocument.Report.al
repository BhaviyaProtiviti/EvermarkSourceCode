/// <summary>
/// Report SBCEDI Load Document (ID 50083).
/// </summary>
report 50107 "SBCEDI Load Document"
{
    Caption = 'SBCEDI Load Document';
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem("LAX EDI Template"; "LAX EDI Template")
        {
            RequestFilterFields = Code;



            dataitem(UploadIntegerLoop; Integer)
            {
                trigger OnPreDataItem()
                begin
                    UploadIntegerLoop.SetRange(Number, 1);
                end;

                trigger OnAfterGetRecord()
                var
                    FileLengthText: Text[12];
                    ZeroFileLengthText: Text[12];
                    File: File;
                    FileLength: Integer;
                    FileLengthBase64: Integer;
                    CommonReceiveNo: Text;
                    FileNameTextBuilder: TextBuilder;
                    FileManagement: Codeunit "File Management";
                    DocumentGuid: Guid;
                    Base64Convert: Codeunit "Base64 Convert";
                    Base64BigText: BigText;
                    EDIDocumentBase64Instream: InStream;
                    EDIDocumentBase64Outstream: OutStream;
                    EDIDocument: Text;
                    EDIDocumentBase64: Text;
                    TempBlob: Codeunit "Temp Blob";
                    EDIBigText: BigText;
                    LAXEDIWSFileSplit: Codeunit "LAX EDI WS File Split";
                begin
                    EDIBigText.Read(GlobalDocumentInStream);
                    FileLength := EDIBigText.GetSubText(EDIDocument, 1);
                    ZeroFileLengthText := ZeroFileLengthText.PadLeft(12, '0');
                    FileLengthText := Format(FileLength).PadLeft(12, '0');
                    EDIDocumentBase64 := Base64Convert.ToBase64(EDIDocument);
                    TempBlob.CreateOutStream(EDIDocumentBase64Outstream);
                    EDIDocumentBase64Outstream.WriteText(EDIDocumentBase64);
                    TempBlob.CreateInStream(EDIDocumentBase64Instream);
                    Base64BigText.Read(EDIDocumentBase64Instream);
                    FileNameTextBuilder.Append("LAX EDI Template"."WS Interface File Path");
                    FileNameTextBuilder.Append('\');
                    FileNameTextBuilder.Append(FileManagement.GetFileName(GlobalFilePath));
                    DocumentGuid := CreateGuid();
                    CommonReceiveNo := GlobalLAXEDIWSCommWebService.PutDocument(Format(DocumentGuid).Substring(2, 36).ToLower(), FileLengthText, ZeroFileLengthText, FileNameTextBuilder.ToText(), Base64BigText);
                end;
            }

            trigger OnPreDataItem()
            begin
                UploadIntoStream(DocumentUploadTitleLabel, '', DocumentUploadFilterLabel, GlobalFilePath, GlobalDocumentInStream);
            end;

        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    var
        GlobalLAXEDIWSCommWebService: Codeunit "LAX EDI WS Comm. Web Service";
        GlobalLAXEDIWSDocMgmt: Codeunit "LAX EDI  WS Doc. Mgmt.";
        DocumentUploadFilterLabel: Label 'All Files (*.*)|*.*', Locked = true;
        DocumentUploadTitleLabel: Label 'Upload EDI File';


        GlobalDocumentInStream: InStream;
        GlobalFilePath: Text;

}