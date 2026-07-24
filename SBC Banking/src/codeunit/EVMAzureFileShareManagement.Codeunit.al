codeunit 50607 "EVMAzureFileShareManagement"
{
    procedure WriteFileToShare(FilePath: Text; var FileContent: InStream)
    var
        MemoryStream: Codeunit "MemoryStream Wrapper";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        Request: HttpRequestMessage;
        Len: Integer;
        ResponseContentErr: Text;
        ResponseFailErr: Label 'Failed to write to AFS: Code: %1, Message: %2';
    begin
        InitStorageAccountDetails();

        if not AzureFileShareSetup.Get() then
            exit;

        // Load the memory stream and get the size
        MemoryStream.Create(0);
        MemoryStream.ReadFrom(FileContent);
        Len := MemoryStream.Length();
        MemoryStream.SetPosition(0);
        MemoryStream.GetInStream(FileContent);

        // Write the Stream into HTTP Content and change the needed Header Information 
        Content.WriteFrom(FileContent);
        Content.GetHeaders(Headers);
        Headers.Add('x-ms-type', 'file');
        Headers.Add('x-ms-content-length', StrSubstNo('%1', Len));

        Client.Put(StrSubstNo('https://%1.file.core.windows.net/%2/%3?%4', AzureFileShareSetup."Storage Account", AzureFileShareSetup."File Share", FilePath, SASToken), Content, Response);

        if not Response.IsSuccessStatusCode then begin
            Response.Content.ReadAs(ResponseContentErr);

            Error(ResponseFailErr, Response.HttpStatusCode, ResponseContentErr);
        end;
    end;

    [NonDebuggable]
    local procedure InitStorageAccountDetails()
    begin
        AzureFileShareSetup.Get();
        AzureFileShareSetup.TestField("Storage Account");
        AzureFileShareSetup.TestField("File Share");
        SetSecretKey();
    end;

    [NonDebuggable]
    local procedure SetSecretKey()
    var
        SASTokenErr: Label 'The SAS Token does not exist.';
    begin
        if not IsolatedStorage.Get('EVMBankAFSSASToken', SASToken) then
            Error(SASTokenErr);
    end;

    var
        AzureFileShareSetup: Record EVMAzureFileShareSetup;
        StorageAccountAuthorization: Codeunit "Storage Service Authorization";
        [NonDebuggable]
        SASToken: Text;
}