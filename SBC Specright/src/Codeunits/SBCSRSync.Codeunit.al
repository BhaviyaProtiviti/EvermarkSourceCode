/// <summary>
/// Codeunit SBCSR Sync (ID 50181).
/// </summary>
codeunit 50181 "SBCSR Sync"
{

    TableNo = "SBC SpecRight Interface";

    var
        GlobalSBCSRQueryHeader: Record "SBCSR Query Header";
        FieldEvaluationErrorLabel: Label 'Error setting field %1 with value %2';
        SpecrightQueryError: Label 'No data returned from SpecRight for Item No. %1 in query sent to SpecRight endpoint %2';
        NoQueryLinesFoundErrorLabel: Label 'No query lines found for query code %1';
        GlobalDateTime: DateTime;
    /// <summary>
    /// Refreshes Access and Refresh tokens.
    /// </summary>
    /// <param name="SBCSRSettings">Record "SBCSR Settings".</param>

    trigger onRun()
    begin
        GlobalDateTime := CurrentDateTime;
        RetrieveSRItem(Rec, GlobalSBCSRQueryHeader);
    end;

    internal procedure SetQueryHeader(SBCSRQueryHeader: Record "SBCSR Query Header")
    begin
        GlobalSBCSRQueryHeader := SBCSRQueryHeader;
    end;

    /// <summary>
    /// Refreshes Access and Refresh tokens.
    /// </summary>
    /// <param name="SBCSRSettings">Record "SBCSR Settings".</param>
#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure RetrieveSRItem(var SBCSpecRightInterface: Record "SBC SpecRight Interface"; SBCSRQueryHeader: Record "SBCSR Query Header")
    var
        CreatedItem: Record Item;
        SBCSRQueryLine: Record "SBCSR Query Line";
        SBCSRSettings: Record "SBCSR Settings";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        JSONManagement: Codeunit "JSON Management";
        SBCSRAuthentication: Codeunit "SBCSR Authentication";
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        HttpClient: HttpClient;
        RequestHttpContent: HttpContent;
        ResponseHttpContent: HttpContent;
        ContentHttpHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        JsonObject: JsonObject;
        AuthToken: JsonToken;
        FieldsJsonToken: JsonToken;
        FieldsJsonArray: JsonArray;
        RefreshToken: JsonToken;
        SuccessJsonToken: JsonToken;
        APIKeyText: Text;
        BearerTokenText: Text;
        HttpContentText: Text;
        LastErrorText: Text;
        AuthContent: TextBuilder;
        QueryFieldsTextBuilder: TextBuilder;
    begin
        HttpRequestMessage.Method('GET');
        SBCSRSettings.Get();
        UriBuilder.Init(SBCSRSettings."API URI");
        // UriBuilder.SetPath('v1/specs/' +SBCSpecRightInterface."Item No.");
        // UriBuilder.SetPath('v1/specfamilies/');
        // Build fields expression from query lines
        SBCSRQueryHeader.TestField("Query Object Name");
        SBCSRQueryLine.SetRange("Query Code", SBCSRQueryHeader."Query Code");
        SBCSRQueryLine.SetFilter("Query Field API Name", '<>%1', '');
        if SBCSRQueryLine.IsEmpty() then
            SetErrorMessage(SBCSRQueryHeader.RecordId(), StrSubstNo(NoQueryLinesFoundErrorLabel, SBCSRQueryHeader."Query Code"), true);
        SBCSRQueryLine.SetLoadFields("Query Field API Name");
        SBCSRQueryLine.FindSet();
        repeat
            QueryFieldsTextBuilder.Append(SBCSRQueryLine."Query Field API Name");
            QueryFieldsTextBuilder.Append(',');
        until SBCSRQueryLine.Next() = 0;

        UriBuilder.SetPath(StrSubstNo('v1/%1', SBCSRQueryHeader."Query Object Name"));
        UriBuilder.SetQuery(StrSubstNo('fields=%1&filter={"Name":"%2"%3}&limit=1&sort=specright__Version_Number__c:desc', QueryFieldsTextBuilder.ToText().TrimEnd(','), SBCSpecRightInterface."Item No.", GetLastUpdatedDateFilter(SBCSpecRightInterface)));
        UriBuilder.GetUri(Uri);
        OnAfterBuildUri(Uri);

        SBCSRAuthentication.Authenticate(SBCSRSettings);

        HttpRequestMessage.SetRequestUri(uri.GetAbsoluteUri());
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', 'Bearer ' + SBCSRAuthentication.GetBearerToken());
        HttpHeaders.Add('Accept', 'application/json');
        HttpHeaders.Add('x-user-id', SBCSRSettings."API User ID");
        HttpHeaders.Add('x-api-key', SBCSRAuthentication.GetAPIKeyValue());
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content.ReadAs(LastErrorText);
            if LastErrorText = '' then
                LastErrorText := GetLastErrorText();
            SetErrorMessage(SBCSRSettings.RecordId(), LastErrorText, false);
            if HttpResponseMessage.HttpStatusCode() = 401 then // The token is likely expired
                RetrieveSRItem(SBCSpecRightInterface, SBCSRQueryHeader);
            exit;
        end else begin
            ResponseHttpContent := HttpResponseMessage.Content;
            ResponseHttpContent.ReadAs(HttpContentText);
            JsonObject.ReadFrom(HttpContentText);
            JsonObject.Get('success', SuccessJsonToken);
            if SuccessJsonToken.AsValue().AsBoolean() and JsonObject.SelectToken('$.data[0].fields', FieldsJsonToken) then begin
                // JsonObject.SelectToken('$.data[0].fields', FieldsJsonToken);
                CreatedItem := SyncItem(SBCSRSettings."Item Template Code", FieldsJsonToken, SBCSRQueryHeader);
                UpdateSRInterface(SBCSpecRightInterface, CreatedItem, FieldsJsonToken);
            end else
                SetErrorMessage(SBCSpecRightInterface.RecordId(), StrSubstNo(SpecrightQueryError, SBCSpecRightInterface."Item No.", Uri.GetAbsoluteUri()), false);
        end;
    end;

    internal procedure SyncItem(ItemTemplateCode: Code[20]; FieldsJsonToken: JsonToken; SBCSRQueryHeader: Record "SBCSR Query Header") Item: Record Item
    var
        ItemTempl: Record "Item Templ.";
        SBCSRSubQueryHeader: Record "SBCSR Query Header";
        SBCSRQueryLine: Record "SBCSR Query Line";
        SBCSRSubQuery: Record "SBCSR Sub Query";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        QueryRecordRef: RecordRef;
        SubQueryRecordRef: RecordRef;
        SubQueryFieldRef: FieldRef;
    begin
        Item.Init();
        Item."SBCSR Sync Date" := GlobalDateTime;
        QueryRecordRef.GetTable(Item);

        // Parse Other Fields From JSON Object.
        SBCSRQueryLine.SetRange("Query Code", SBCSRQueryHeader."Query Code");
        SBCSRQueryLine.SetRange("Key Field", true);
        SBCSRQueryLine.SetFilter("Field ID", '<>%1', 0);
        SBCSRQueryLine.FindSet();

        // Key fields
        repeat
            ProcessQueryLine(FieldsJsonToken, QueryRecordRef, SBCSRQueryLine);
        until SBCSRQueryLine.Next() = 0;


        if QueryRecordRef.Find() then;  // Find existing record if one exists based on key fields

        // Non Key fields
        SBCSRQueryLine.SetRange("Key Field", false);
        SBCSRQueryLine.FindSet();
        repeat
            ProcessQueryLine(FieldsJsonToken, QueryRecordRef, SBCSRQueryLine);
        until SBCSRQueryLine.Next() = 0;

        // Write item
        QueryRecordRef.SetTable(Item);
        if not Item.Insert(SBCSRQueryHeader."Trigger on Write") then
            Item.Modify(SBCSRQueryHeader."Trigger on Write");

        // Apply Config Template (the template is applied BEFORE the existing record is searched for because the template may add additional key fields to the record.) 
        if ItemTempl.Get(ItemTemplateCode) then
            ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl, false);

        // Get Sub Queries
        SBCSRSubQuery.SetRange("Query Code", SBCSRQueryHeader."Query Code");
        if SBCSRSubQuery.IsEmpty() then
            exit;

        SBCSRSubQuery.FindSet();
        repeat
            SBCSRSubQueryHeader.Get(SBCSRSubQuery."Sub Query Code");
            if SBCSRQueryHeader."Query Object Name" = SBCSRSubQueryHeader."Query Object Name" then
                SyncSubQuery(FieldsJsonToken, SBCSRSubQueryHeader);
        until SBCSRSubQuery.Next() = 0;
    end;

    local procedure UpdateSRInterface(var SBCSpecRightInterface: Record "SBC SpecRight Interface"; var Item: Record Item; FieldsJsonToken: JsonToken)
    var
        JsonToken: JsonToken;
    begin
        FieldsJsonToken.SelectToken('$.[?(@.field==''Id'')].value', JsonToken);
        SBCSpecRightInterface."External Item ID" := JsonToken.AsValue().AsText();
        SBCSpecRightInterface."Item ID" := Item.SystemId;
        SBCSpecRightInterface."Processed Timestamp" := GlobalDateTime;
        SBCSpecRightInterface.Modify();
    end;


    local procedure SetErrorMessage(ErrorRecordId: RecordId; ErrorText: Text; ThrowError: Boolean)
    var
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, ErrorRecordId, 0, CopyStr(ErrorText, 1, 250));
        if StrLen(ErrorText) > 250 then
            ErrorMessageManagement.LogMessage(0, 0, ErrorText, ErrorRecordId, 0, '');
        ErrorMessageHandler.RegisterErrorMessages(false);
        ErrorMessageManagement.PopContext(ErrorContextElement);
        if not ThrowError then
            exit;
        ErrorContextElement.GetErrorMessage(ErrorMessage);
        ErrorMessage.ThrowError();
    end;

    local procedure ProcessQueryLine(FieldsJsonToken: JsonToken; var QueryRecordRef: RecordRef; SBCSRQueryLine: Record "SBCSR Query Line")
    var
        FieldJsonToken: JsonToken;
        QueryFieldRef: FieldRef;
        FieldTextValue: Text;
        JsonPathText: Text;
        TransformationRule: Record "Transformation Rule";
        BlankDate: Date;
        BlankDateTime: DateTime;
        BlankTime: Time;
        WriteValue: Boolean;
    begin
        // Clear(FieldTextValue);
        JsonPathText := StrSubstNo('$.[?(@.field==''%1'')].value', SBCSRQueryLine."Query Field API Name");
        if FieldsJsonToken.SelectToken(JsonPathText, FieldJsonToken) then;
        QueryFieldRef := QueryRecordRef.Field(SBCSRQueryLine."Field ID");

        if not FieldJsonToken.AsValue().IsNull() then
            FieldTextValue := FieldJsonToken.AsValue().AsText();
        // Replace Blank with Default
        if (FieldTextValue = '') and SBCSRQueryLine."Replace Blank with Default" then
            FieldTextValue := SBCSRQueryLine."Default Text";
        // Transform
        if SBCSRQueryLine."Transformation Rule" <> '' then begin
            if TransformationRule.Get(SBCSRQueryLine."Transformation Rule") then
                FieldTextValue := TransformationRule.TransformText(FieldTextValue);
        end;

        // Write to Field and Validate
        case true of
            SBCSRQueryLine."Overwrite Existing": // Always write
                WriteValue := true;
            (Format(QueryFieldRef.Value()) in ['', '0', Format(BlankDate), Format(BlankDateTime), Format(BlankTime)]): // Write if existing value is blank
                WriteValue := true;
            (QueryFieldRef.Type() in [FieldType::Boolean]): // Always write if boolean
                WriteValue := true;
            else
                exit;
        end;


        if not Evaluate(QueryFieldRef, FieldTextValue) then
            SetErrorMessage(SBCSRQueryLine.RecordId(), StrSubstNo(FieldEvaluationErrorLabel, QueryFieldRef.Name, FieldTextValue), false)
        else
            if SBCSRQueryLine.Validate then
                QueryFieldRef.Validate();
    end;

    local procedure SyncSubQuery(FieldsJsonToken: JsonToken; SBCSRSubQueryHeader: Record "SBCSR Query Header")
    var
        SBCSRQueryLine: Record "SBCSR Query Line";
        SubQueryRecordRef: RecordRef;
        AppliedSubQueryRecordRef: RecordRef;
        SubQueryFieldRef: FieldRef;
        TempField: Record Field temporary;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        TypeHelper: Codeunit "Type Helper";
    begin
        SubQueryRecordRef.Open(SBCSRSubQueryHeader."Table No.");
        SBCSRQueryLine.SetRange("Query Code", SBCSRSubQueryHeader."Query Code");
        SBCSRQueryLine.SetRange("Key Field", true);
        SBCSRQueryLine.SetFilter("Field ID", '<>%1', 0);
        SBCSRQueryLine.FindSet();

        // Key fields
        repeat
            ProcessQueryLine(FieldsJsonToken, SubQueryRecordRef, SBCSRQueryLine);
        until SBCSRQueryLine.Next() = 0;

        if not SubQueryRecordRef.Find() then; // Find existing record if one exists based on key fields

        // Non Key fields
        SBCSRQueryLine.SetRange("Key Field", false);
        SBCSRQueryLine.FindSet();
        repeat
            ProcessQueryLine(FieldsJsonToken, SubQueryRecordRef, SBCSRQueryLine);
        until SBCSRQueryLine.Next() = 0;

        // Write Record
        if not SubQueryRecordRef.Insert(SBCSRSubQueryHeader."Trigger on Write") then
            SubQueryRecordRef.Modify(SBCSRSubQueryHeader."Trigger on Write");

        // Apply Config Template (the template is applied BEFORE the existing record is searched for because the template may add additional key fields to the record.)
        if ConfigTemplateHeader.Get(SBCSRSubQueryHeader."Config Template Code") then begin
            CreateTempFieldRecord(SBCSRSubQueryHeader, SubQueryRecordRef, TempField);
            ConfigTemplateManagement.ApplyTemplate(SubQueryRecordRef, TempField, AppliedSubQueryRecordRef, ConfigTemplateHeader);
        end;
    end;

    local procedure CreateTempFieldRecord(SBCSRSubQueryHeader: Record "SBCSR Query Header"; var SubQueryRecordRef: RecordRef; var TempField: Record Field temporary)
    var
        Field: Record Field;
        BlankCheckRecordRef: RecordRef;
    begin
        Field.SetRange(TableNo, SBCSRSubQueryHeader."Table No.");
        Field.FindSet();
        BlankCheckRecordRef.Open(SBCSRSubQueryHeader."Table No.");
        BlankCheckRecordRef.Init();
        repeat
            if Format(SubQueryRecordRef.Field(Field."No.").Value) <> Format(BlankCheckRecordRef.Field(Field."No.").Value) then begin
                TempField.TransferFields(Field);
                TempField.Insert();
            end;
        until Field.Next() = 0;
    end;

    local procedure GetLastUpdatedDateFilter(SBCSpecRightInterface: Record "SBC SpecRight Interface") DateFilter: Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if SBCSpecRightInterface."Processed Timestamp" = 0DT then
            exit;
        DateFilter := StrSubstNo(',"LastModifiedDate":{"$gte":"%1%2"}}', CopyStr(Format(SBCSpecRightInterface."Processed Timestamp", 0, 9), 1, 19), 'Z'); //Specright does not use the standard XML date format.
    end;

    /// <summary>
    /// The uri can be modified before the request is sent.
    /// </summary>
    /// <param name="Uri">VAR Codeunit Uri.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildUri(var Uri: Codeunit Uri)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"SBC SpecRight Interface", 'OnAfterInsertEvent', '', false, false)]
    local procedure CallSpecrightOnWrite(var Rec: Record "SBC SpecRight Interface"; RunTrigger: Boolean)
    var
        SBCSRSyncItem: Report "SBCSR Sync Item";
        SBCSpecRightInterface : Record "SBC SpecRight Interface";
        SBCSRSettings: Record "SBCSR Settings";
    begin
        SBCSRSettings.SetRange("Disable Auto Sync",true); // Do not run if auto sync is disabled
        if not SBCSRSettings.IsEmpty() then
            exit;
        SBCSRSettings.Reset();
        SBCSRSettings.SetFilter("Default Query Code", '%1', ''); // Do not run if there is no default query code
        if not SBCSRSettings.IsEmpty() then
            exit;
        SBCSRSyncItem.UseRequestPage(false);
        SBCSpecRightInterface := Rec;
        SBCSpecRightInterface.SetRecFilter();
        SBCSRSyncItem.SetTableView(SBCSpecRightInterface);
        SBCSRSyncItem.Run();
    end;

}