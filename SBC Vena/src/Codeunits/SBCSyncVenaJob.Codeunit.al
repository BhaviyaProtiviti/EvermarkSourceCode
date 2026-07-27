/// <summary>
/// Sends a Vena Job to the Vena API.
/// </summary>
codeunit 50256 "SBC Sync Vena Job"
{
    TableNo = "SBC Vena Job Setup";
    Permissions = tabledata "SBC Vena API Setup" = R,
                  tabledata "SBC Vena Job Setup" = RM,
                  tabledata "SBC Vena Job Setup Line" = R,
                  tabledata "SBC Vena Job Status" = RIM;

    trigger OnRun()

    begin
        Code(Rec);
    end;



    local procedure Code(SBCVenaJobSetup: Record "SBC Vena Job Setup")
    begin
        // Check if the Vena Job Setup is valid
        if SBCVenaJobSetup."Vena API Endpoint Path" = '' then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobSetup.RecordId(), SBCVenaJobSetup.FieldNo("Vena API Endpoint Path"), VenaApiEndpointNotSetErrorLabel, true);
        if SBCVenaJobSetup."Vena Template ID" = '' then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobSetup.RecordId(), SBCVenaJobSetup.FieldNo("Vena Template ID"), VenaTemplateIDMissingErrorLabel, true);
        if SBCVenaJobSetup."ERP Table ID" = 0 then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobSetup.RecordId(), SBCVenaJobSetup.FieldNo("ERP Table ID"), ERPTableIdNotSetErrorLabel, true);
        // Load the CSV Template
        if CreateVenaCSVFromJob(SBCVenaJobSetup) = 0 then begin
            SendNoRecordsToSyncNotficiation();
            exit;
        end;
        SendSyncJobInitiatedNotification();
    end;


    local procedure SendSyncJobInitiatedNotification()
    var
        CompletionNotifiction: Notification;
    begin
        if not GuiAllowed() then
            exit;
        CompletionNotifiction.Message := SyncJobInitiatedLabel;
        CompletionNotifiction.Scope := NotificationScope::LocalScope;
        CompletionNotifiction.Send();
    end;

    local procedure SendNoRecordsToSyncNotficiation()
    var
        CompletionNotifiction: Notification;
    begin
        if not GuiAllowed() then
            exit;
        CompletionNotifiction.Message := NoRecordsToSyncNotificationLabel;
        CompletionNotifiction.Scope := NotificationScope::LocalScope;
        CompletionNotifiction.Send();
    end;

    local procedure CreateVenaCSVFromJob(SBCVenaJobSetup: Record "SBC Vena Job Setup") CSVLength: Integer;
    var
        TemporaryCSVBuffer: Record "CSV Buffer" temporary;
        SBCVenaJobSetupLine: Record "SBC Vena Job Setup Line";
        TableMetadata: Record "Table Metadata";
        CSVDataValueRecordRef: RecordRef;
        CSVExportRecordRef: RecordRef;
        CSVTemplateInstream: InStream;
        ERPTableFilterInstream: InStream;
        CurrentCSVLine: Integer;
        CurrentIteration: Integer;
        RecordLimit: Integer;
        ActiveConnectionName: Text;
        CurrentERPTableFilterLineText: Text;
        ERPTableFilterTextBuilder: TextBuilder;
    begin
        // Check if Vena Job Setup Lines exist
        SBCVenaJobSetupLine.SetRange("Vena Job Code", SBCVenaJobSetup."Vena Job Code");
        SBCVenaJobSetupLine.SetFilter("Column No.", '<>%1', 0);
        SBCVenaJobSetupLine.FilterGroup(-1);
        SBCVenaJobSetupLine.SetFilter("ERP Field ID", '<>%1', 0);
        SBCVenaJobSetupLine.SetFilter("Default Value", '<>%1', '');
        if SBCVenaJobSetupLine.IsEmpty() then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobSetup.RecordId(), 0, StrSubstNo(NoVenaJobLines, SBCVenaJobSetup."Vena Job Code"), true);
        //Check for External SQL Table
        TableMetadata.SetRange(ID, SBCVenaJobSetup."ERP Table ID");
        TableMetadata.SetRange(TableType, TableMetadata.TableType::ExternalSQL);
        TableMetadata.SetLoadFields(Id, Name, Caption, ExternalName, TableType);
        if TableMetadata.FindFirst() then begin
            if not SBCVenaJobSetup.ConnectionValueSet() then
                GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobSetup.RecordId(), SBCVenaJobSetup.FieldNo("Connection String"), StrSubstNo(ConnectionStringNotSetErrorLabel, SBCVenaJobSetup."Vena Job Code"), true);
            if not Database.HasTableConnection(TableConnectionType::ExternalSQL, TableMetadata.ExternalName) then
                RegisterTableConnection(TableConnectionType::ExternalSQL, TableMetadata.ExternalName, SBCVenaJobSetup.GetConnectionValue());
            ActiveConnectionName := GetDefaultTableConnection(TableConnectionType::ExternalSQL);
            if TableMetadata.ExternalName <> ActiveConnectionName then
                SetDefaultTableConnection(TableConnectionType::ExternalSQL, TableMetadata.ExternalName);
        end;
        // Initialize and Filter Export Record
        CSVExportRecordRef.Open(SBCVenaJobSetup."ERP Table ID");
        SBCVenaJobSetup.CalcFields("ERP Table Filter");
        SBCVenaJobSetup."ERP Table Filter".CreateInStream(ERPTableFilterInstream);
        while not ERPTableFilterInstream.EOS do begin
            ERPTableFilterInstream.ReadText(CurrentERPTableFilterLineText);
            ERPTableFilterTextBuilder.Append(CurrentERPTableFilterLineText);
        end;

        // if SBCVenaJobSetup."Last Entry No. Exported" <> '' then
        //     CSVCopyFilterRecordRef.KeyIndex(1).FieldIndex(1).SetFilter(StrSubstNo('>%1', SBCVenaJobSetup."Last Entry No. Exported"));
        if ERPTableFilterTextBuilder.Length <> 0 then // This is moved to allow override of the filter if the last entry no. is set.
            CSVExportRecordRef.SetView(ERPTableFilterTextBuilder.ToText().Trim());
        if (CSVExportRecordRef.KeyIndex(1).FieldIndex(1).GetFilter() = '') and (SBCVenaJobSetup."Last Entry No. Exported" <> '') then
            CSVExportRecordRef.KeyIndex(1).FieldIndex(1).SetFilter(StrSubstNo('>%1', SBCVenaJobSetup."Last Entry No. Exported"));
        if CSVExportRecordRef.IsEmpty() then //This may need to be handled with some feedback to the user if this process is run from a GUI.
            exit;
        // Check if the CSV Template is set
        SBCVenaJobSetup.CalcFields(SBCVenaJobSetup."CSV Template");
        if not SBCVenaJobSetup."CSV Template".HasValue() then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobSetup.RecordId(), SBCVenaJobSetup.FieldNo("CSV Template"), CSVTemplateNotSetError, true);
        // Set the Record Limit
        RecordLimit := SBCVenaJobSetup."Max Rows Per Export";
        // Create the CSV File   
        CSVExportRecordRef.FindSet();

        repeat
            if CurrentIteration = 0 then begin
                // Load the CSV Template
                SBCVenaJobSetup."CSV Template".CreateInStream(CSVTemplateInstream);
                TemporaryCSVBuffer.LoadDataFromStream(CSVTemplateInstream, CSVSeparatorLabel);
            end;
            CurrentIteration += 1;
            CurrentCSVLine := TemporaryCSVBuffer.GetNumberOfLines() + 1;
            SBCVenaJobSetupLine.FindSet();
            CSVDataValueRecordRef := CSVExportRecordRef.Duplicate();
            repeat
                if CSVDataValueRecordRef.Number() <> CSVExportRecordRef.Number() then
                    CSVDataValueRecordRef := CSVExportRecordRef.Duplicate();
                if (SBCVenaJobSetupLine."ERP Link Table ID" <> 0) and (SBCVenaJobSetupLine."ERP Link Field ID" <> 0) then
                    GetLinkTableRecordRef(SBCVenaJobSetupLine, CSVDataValueRecordRef);
                TemporaryCSVBuffer.InsertEntry(CurrentCSVLine, SBCVenaJobSetupLine."Column No.", StrSubstNo('"%1"', SBCVenaJobSetupLine.GetFieldValue(CSVDataValueRecordRef).Replace('"', '""')));
            until SBCVenaJobSetupLine.Next() = 0;

            if (RecordLimit <> 0) and (CurrentIteration >= RecordLimit) then begin
                // Save data and send request
                CSVLength += Sync(SBCVenaJobSetup, TemporaryCSVBuffer);
                // Reset Current Iteration
                CurrentIteration := 0;
                Clear(CSVTemplateInstream);
                TemporaryCSVBuffer.DeleteAll();
                // // Set the Last Entry No. Exported
                SBCVenaJobSetup."Last Entry No. Exported" := Format(CSVExportRecordRef.KeyIndex(1).FieldIndex(1).Value);
                if SBCVenaJobSetup.Modify() then
                    Commit();
            end;
        until CSVExportRecordRef.Next() = 0;
        // Send the remaing records
        if CurrentIteration <> 0 then
            CSVLength += Sync(SBCVenaJobSetup, TemporaryCSVBuffer);

        SBCVenaJobSetup."Last Entry No. Exported" := Format(CSVExportRecordRef.KeyIndex(1).FieldIndex(1).Value); // Entry No. is the first field in the primary key. Need to determine if this is sufficient for all table types.
        if SBCVenaJobSetup.Modify() then
            Commit();

        // Unregister External SQL Table Connection
        if TableMetadata.DataIsExternal then
            UnregisterTableConnection(TableConnectionType::ExternalSQL, TableMetadata.ExternalName);
    end;

    local procedure GetLinkTableRecordRef(var SBCVenaJobSetupLine: Record "SBC Vena Job Setup Line"; var CSVDataValueRecordRef: RecordRef)
    var
        Field: Record Field;
        CSVLinkTableRecordRef: RecordRef;
        ERPLinkTableFilterInstream: InStream;
        CurrentERPLinkTableFilterLineText: Text;
        ERPLinkTableFilterTextBuilder: TextBuilder;
    begin
        CSVLinkTableRecordRef.Open(SBCVenaJobSetupLine."ERP Link Table ID");
        SBCVenaJobSetupLine.CalcFields("ERP Field Name","ERP Link Table Filter");
        if SBCVenaJobSetupLine."ERP Link Table Filter".HasValue() then begin
            SBCVenaJobSetupLine."ERP Link Table Filter".CreateInStream(ERPLinkTableFilterInstream);
            while not ERPLinkTableFilterInstream.EOS do begin
                ERPLinkTableFilterInstream.ReadText(CurrentERPLinkTableFilterLineText);
                ERPLinkTableFilterTextBuilder.Append(CurrentERPLinkTableFilterLineText);
            end;

            Field.SetRange(TableNo, SBCVenaJobSetupLine."ERP Link Table ID");
            Field.SetRange(FieldName, SBCVenaJobSetupLine."ERP Field Name");
            CSVLinkTableRecordRef.SetView(ERPLinkTableFilterTextBuilder.ToText());
            case true of
                ERPLinkTableFilterTextBuilder.ToText().Contains('%1'):
                    CSVLinkTableRecordRef.SetView(ERPLinkTableFilterTextBuilder.ToText().Replace('%1', SBCVenaJobSetupLine.GetFieldValue(CSVDataValueRecordRef)));
                CSVLinkTableRecordRef.FieldExist(SBCVenaJobSetupLine."ERP Field ID"):
                    begin
                        if CSVLinkTableRecordRef.Field(SBCVenaJobSetupLine."ERP Field ID").Name() = SBCVenaJobSetupLine."ERP Field Name" then
                            CSVLinkTableRecordRef.Field(SBCVenaJobSetupLine."ERP Field ID").SetFilter(SBCVenaJobSetupLine.GetFieldValue(CSVDataValueRecordRef));
                    end;
                Field.FindFirst():
                    CSVLinkTableRecordRef.Field(Field."No.").SetFilter(SBCVenaJobSetupLine.GetFieldValue(CSVDataValueRecordRef));
            end;
        end;
        if CSVLinkTableRecordRef.IsEmpty() then
            exit;
        CSVLinkTableRecordRef.FindFirst();
        CSVDataValueRecordRef := CSVLinkTableRecordRef;
    end;

    local procedure Sync(SBCVenaJobSetup: Record "SBC Vena Job Setup"; var TemporaryCSVBuffer: Record "CSV Buffer" temporary) CSVLength: Integer
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TemporaryCSVBuffer.SaveDataToBlob(TempBlob, CSVSeparatorLabel);
        CSVLength := TempBlob.Length();
        SendVenaRequest(SBCVenaJobSetup."Vena Job Code", SBCVenaJobSetup."Vena Template ID", SBCVenaJobSetup."Vena API Endpoint Path", TempBlob);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure InitializeHttpClient(var HttpClient: HttpClient; var HttpRequestHeaders: HttpHeaders)
    var
        SBCVenaAPISetup: Record "SBC Vena API Setup";
        Base64Convert: Codeunit "Base64 Convert";
        // ApiUri: DotNet Uri;
        AuthGrantType: TextBuilder;
    begin
        // Check if the API User and API Key are set
        if not SBCVenaAPISetup.APIUserSet() then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaAPISetup.RecordId(), SBCVenaAPISetup.FieldNo("Vena API User"), UserIDNotSetErrorLabel, true);
        if not SBCVenaAPISetup.APIKeySet() then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaAPISetup.RecordId(), SBCVenaAPISetup.FieldNo("Vena API Key"), APIKeyNotSet, true);
        SBCVenaAPISetup.Get();
        if SBCVenaAPISetup."Vena Base API URI" = '' then
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaAPISetup.RecordId(), SBCVenaAPISetup.FieldNo("Vena Base API URI"), VenaApiSetupErrorLabel, true);
        // Build the HTTP Request
        HttpClient.SetBaseAddress(SBCVenaAPISetup."Vena Base API URI");
        AuthGrantType.Append(SBCVenaAPISetup.GetAPIUserValue());
        AuthGrantType.Append(':');
        AuthGrantType.Append(SBCVenaAPISetup.GetAPIKeyValue());
        HttpRequestHeaders := HttpClient.DefaultRequestHeaders;
        HttpRequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64(AuthGrantType.ToText()));
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure SendVenaRequest(VenaJobCode: Code[20]; VenaTemplateId: Text[20]; VenaAPIEndpointPath: Text[200]; var TempBlob: Codeunit "Temp Blob")
    var
        SBCVenaJobStatus: Record "SBC Vena Job Status";
        ApiUri: Codeunit Uri;
        HttpMethod: enum "Http Request Type";
        HttpClient: HttpClient;
        MultipartFormDataContent: HttpContent;
        HttpRequestHeaders: HttpHeaders;
        MultipartFormDataContentHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        CSVInstream: InStream;
        JsonResult: JsonObject;
        JobIdTextToken: JsonToken;
        JobStatusTextToken: JsonToken;
        ModelIdTextToken: JsonToken;
        CSVOutstream: OutStream;
        BaseAddressText: Text;
        CurrentCSVText: Text;
        EndpointText: Text;
        JobIdText: Text;
        JobStatusText: Text;
        JsonResultText: Text;
        LastErrorText: Text;
        MetaDataStringContentBodyText: Text;
        ModelIdText: Text;
        CSVTextBuilder: TextBuilder;
        MultiPartFormDataContentTextBuilder: TextBuilder;
    begin
        // Initialize the HTTP Client Headers and Base Address
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);
        InitializeHttpClient(HttpClient, HttpRequestHeaders);
        BaseAddressText := format(HttpClient.GetBaseAddress());
        if GlobalResentFromEntryNo <> 0 then // In this situation, the endpoint should already exist on the job status record.
            EndpointText := VenaAPIEndpointPath
        else
            EndpointText := StrSubstNo('%1/%2/%3', VenaAPIEndpointPath, VenaTemplateId, FileApiPathLabel);
        ApiUri.Init(StrSubstNo('%1%2', BaseAddressText, EndpointText));
        // ApiUri.Init('https://webhook.site/fbbca73a-6376-40fa-bf48-8d5254e97e48');
        // Create the Vena Job Status Record
        SBCVenaJobStatus."Vena Job Code" := VenaJobCode;
        SBCVenaJobStatus."Vena Template ID" := VenaTemplateId;
        SBCVenaJobStatus."Vena Send Date" := CurrentDateTime();
        SBCVenaJobStatus."Vena API Endpoint Path" := EndpointText;
        SBCVenaJobStatus."Resent from Entry No." := GlobalResentFromEntryNo;
        SBCVenaJobStatus.Insert();
        SBCVenaJobStatus.CalcFields("Vena CSV");
        TempBlob.CreateInStream(CSVInstream);
        SBCVenaJobStatus."Vena CSV".CreateOutStream(CSVOutstream);
        CopyStream(CSVOutstream, CSVInstream);

        SBCVenaJobStatus.Modify();
        // Create the Multipart Form Data Content
        SBCVenaJobStatus.CalcFields("Vena CSV");
        SBCVenaJobStatus."Vena CSV".CreateInStream(CSVInstream);
        while not CSVInstream.EOS() do begin
            CSVInstream.ReadText(CurrentCSVText);
            CSVTextBuilder.AppendLine(CurrentCSVText);
        end;

        MetaDataStringContentBodyText := '{   "input": {     "partName":"file",     "fileFormat":"CSV",     "fileEncoding":"UTF-8",     "fileName":"data.csv"   } }';
        MultiPartFormDataContentTextBuilder.AppendLine('--' + ContentBoundaryLabel);
        MultiPartFormDataContentTextBuilder.AppendLine('Content-Disposition: form-data; name="metadata"');
        MultiPartFormDataContentTextBuilder.AppendLine();
        MultiPartFormDataContentTextBuilder.AppendLine(MetaDataStringContentBodyText);
        MultiPartFormDataContentTextBuilder.AppendLine('--' + ContentBoundaryLabel);
        MultiPartFormDataContentTextBuilder.AppendLine('Content-Disposition: form-data; name="file"; filename="data.csv"');
        MultiPartFormDataContentTextBuilder.AppendLine('Content-Type: text/csv');
        MultiPartFormDataContentTextBuilder.AppendLine();
        MultiPartFormDataContentTextBuilder.Append(CSVTextBuilder.ToText());
        MultiPartFormDataContentTextBuilder.AppendLine('--' + ContentBoundaryLabel + '--');
        MultipartFormDataContent.WriteFrom(MultiPartFormDataContentTextBuilder.ToText());
        MultipartFormDataContent.GetHeaders(MultipartFormDataContentHeaders);
        MultipartFormDataContentHeaders.Remove('Content-Type');
        MultipartFormDataContentHeaders.Add('Content-Type', StrSubstNo('multipart/form-data; boundary=%1', ContentBoundaryLabel));

        // Create the HTTP Request
        HttpRequestMessage.Method(Format(HttpMethod::POST));
        HttpRequestMessage.SetRequestUri(ApiUri.GetAbsoluteUri());
        HttpRequestHeaders.Remove('Accept');
        HttpRequestHeaders.Add('Accept', 'application/json');
        HttpRequestMessage.Content(MultipartFormDataContent);


        // Send the request
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content.ReadAs(LastErrorText);
            if LastErrorText = '' then
                LastErrorText := GetLastErrorText();
            GlobalSBCVenaHelper.SetErrorMessage(SBCVenaJobStatus.RecordId(), 0, LastErrorText, false);
            exit;
        end else begin
            HttpResponseMessage.Content.ReadAs(JsonResultText);
            JsonResult.ReadFrom(JsonResultText);

            JsonResult.Get('id', JobIdTextToken);
            JobIdText := JobIdTextToken.AsValue().AsText();
            JsonResult.Get('status', JobStatusTextToken);
            JobStatusText := JobStatusTextToken.AsValue().AsText();

            JsonResult.Get('modelId', ModelIdTextToken);
            ModelIdText := ModelIdTextToken.AsValue().AsText();
            // Add to Job Status Page
            SBCVenaJobStatus."Vena Job ID" := JobIdText;
            SBCVenaJobStatus."Vena Model ID" := ModelIdText;
            Evaluate(SBCVenaJobStatus."Vena Status", JobStatusText);
            if SBCVenaJobStatus.Modify() then
                Commit();
        end;
    end;

    internal procedure SetResentFromEntryNo(ResentFromEntryNo: Integer)
    begin
        GlobalResentFromEntryNo := ResentFromEntryNo;
    end;


    var
        GlobalSBCVenaHelper: Codeunit "SBC Vena Helper";
        GlobalResentFromEntryNo: Integer;
        APIKeyNotSet: Label 'API Key not set. Please set password in Vena API Settings.';
        ConnectionStringNotSetErrorLabel: Label 'Connection String not set for Vena Job %1';

        ContentBoundaryLabel: Label '----011000010111000001101001';
        CSVSeparatorLabel: Label ',', Locked = true;
        CSVTemplateNotSetError: Label 'CSV Template not set.';
        ERPTableIdNotSetErrorLabel: Label 'ERP Table ID not set.';
        FileApiPathLabel: Label 'startWithFile', Locked = true;
        NoRecordsToSyncNotificationLabel: Label 'No Records to Sync';
        NoVenaJobLines: Label 'No Vena Job Lines found for Vena Job Code %1';
        SyncJobInitiatedLabel: Label 'Sync Job Initiated';
        UserIDNotSetErrorLabel: Label 'API User ID not set in Vena API Settings.';
        VenaApiEndpointNotSetErrorLabel: Label 'The Vena API Endpoint Path is not set for Vena Job Code %1';
        VenaApiSetupErrorLabel: Label 'The Vena Base API URI is not set in Vena API Setup.';
        VenaTemplateIDMissingErrorLabel: Label 'Vena Template ID not set for Vena Job Code %1';
}