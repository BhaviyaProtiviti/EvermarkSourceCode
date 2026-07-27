/// <summary>
/// Codeunit SBCSR Authentication (ID 50180).
/// </summary>
codeunit 50180 "SBCSR Authentication"
{
    TableNo = "SBCSR Settings";

    trigger OnRun()
    begin
        Authenticate(Rec);
    end;

    /// <summary>
    /// Refreshes Access and Refresh tokens.
    /// </summary>
    /// <param name="SBCSRSettings">Record "SBCSR Settings".</param>
    var
        PasswordNotSetErrorLabel: Label 'Password not set. Please set password in SpecRight Settings.';
        UserIDNotSetErrorLabel: Label 'API User ID not set in SpecRight Settings.';
        SpecRightAccessLabel: Label 'SpecRightAccess', Locked = true;
        SpecRightPasswordLabel: Label 'SpecRightPassword', Locked = true;
        SpecRightRefreshLabel: Label 'SpecRightRefresh', Locked = true;
        SpecRightAPIKeyLabel: Label 'SpecRightAPIKey', Locked = true;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure Authenticate(var SBCSRSettings: Record "SBCSR Settings")
    var
        Base64Convert: Codeunit "Base64 Convert";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        JSONManagement: Codeunit "JSON Management";
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        TimeAuthenticated: Duration;
        HttpClient: HttpClient;
        RequestHttpContent: HttpContent;
        ResponseHttpContent: HttpContent;
        ContentHttpHeaders: HttpHeaders;
        HttpRequestHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        JsonObject: JsonObject;
        AuthToken: JsonToken;
        RefreshToken: JsonToken;
        ExpiresInToken: JsonToken;
        // AuthTokenText: Text;
        BearerTokenText: Text;
        HttpContentText: Text;
        LastErrorText: Text;
        PassswordText: Text;
        RefreshTokenText: Text;
        AuthContent: TextBuilder;
        AuthGrantType: TextBuilder;
    begin
        // If currently authenticated, then exit
        if SBCSRSettings."Last Authenticated" <> 0DT then begin
            TimeAuthenticated := CurrentDateTime - SBCSRSettings."Last Authenticated";
            if SBCSRSettings."Expires In" - (TimeAuthenticated / 1000) > 60 then // 1 minute before expiry    
                exit;
        end;

        HttpRequestMessage.Method('POST');
        UriBuilder.Init(SBCSRSettings."API URI");
        UriBuilder.SetPath('token');
        UriBuilder.GetUri(Uri);

        HttpRequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);

        if IsolatedStorage.Get(SpecRightRefreshLabel, Datascope::Module, RefreshTokenText) then;

        // Create Authentication Payload
        AuthContent.AppendLine('{');

        if RefreshTokenText = '' then begin
            // Retrieve Password and record errors for User ID and Password
            if IsolatedStorage.Get(SpecRightPasswordLabel, Datascope::Module, PassswordText) then;
            if SBCSRSettings."API User ID" = '' then
                SetErrorMessage(SBCSRSettings.RecordId(), UserIDNotSetErrorLabel, true);
            if PassswordText = '' then
                SetErrorMessage(SBCSRSettings.RecordId(), PasswordNotSetErrorLabel, true);

            // Create and Append Basic Auth Header
            AuthGrantType.Append(SBCSRSettings."API User ID");
            AuthGrantType.Append(':');
            AuthGrantType.Append(PassswordText);
            HttpRequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64(AuthGrantType.ToText()));
            AuthContent.AppendLine('  "grant_type": "password"');
        end else begin
            // Create refresh token header
            AuthContent.AppendLine('  "grant_type": "refresh_token",');
            AuthContent.AppendLine(StrSubstNo('  "refresh_token": "%1"', RefreshTokenText));
        end;

        AuthContent.Append('}');

        // Write Authentication Content
        RequestHttpContent.WriteFrom(AuthContent.ToText());
        RequestHttpContent.GetHeaders(ContentHttpHeaders);
        ContentHttpHeaders.Remove('Content-Type');
        ContentHttpHeaders.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content(RequestHttpContent);
        
        // Send Authentication Request and handle response
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            // Handle failed authentication
            LastErrorText := HttpResponseMessage.ReasonPhrase();
            if LastErrorText = '' then
                LastErrorText := GetLastErrorText();
            SetErrorMessage(SBCSRSettings.RecordId(), LastErrorText, false);
            // Clear refresh token
            if IsolatedStorage.Delete(SpecRightRefreshLabel, Datascope::Module) then;
            if IsolatedStorage.Delete(SpecRightAccessLabel, Datascope::Module) then;
            SBCSRSettings.ClearLastAuthenticated();
            // Authenticate again
            if HttpResponseMessage.HttpStatusCode() = 401 then
                Authenticate(SBCSRSettings);
            exit;
        end else begin
            // Handle successful authentication
            ResponseHttpContent := HttpResponseMessage.Content;
            ResponseHttpContent.ReadAs(HttpContentText);
            JsonObject.ReadFrom(HttpContentText);
            JsonObject.Get('access_token', AuthToken);
            JsonObject.Get('refresh_token', RefreshToken);
            JsonObject.Get('expires_in', ExpiresInToken);
            SetAuthenticationValue(SpecRightAccessLabel, AuthToken.AsValue().AsText());
            SetAuthenticationValue(SpecRightRefreshLabel, RefreshToken.AsValue().AsText());
            SBCSRSettings.SetLastAuthenticated(ExpiresInToken.AsValue().AsInteger());
        end;
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    local procedure SetAuthenticationValue(KeyText: Text; ValueText: Text) ValueSet: Boolean
    var
        BlankRecordId: RecordId;
    begin
        if not EncryptionEnabled() then
            ValueSet := IsolatedStorage.Set(KeyText, ValueText, Datascope::Module)
        else
            ValueSet := IsolatedStorage.SetEncrypted(KeyText, ValueText, Datascope::Module);

        if ValueSet then
            exit;

        SetErrorMessage(BlankRecordId, GetLastErrorText(), true);
    end;

    local procedure SetErrorMessage(ErrorRecordId: RecordId; ErrorText: Text; ThrowError: Boolean)
    var
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, ErrorRecordId, 0, ErrorText);
        ErrorMessageHandler.RegisterErrorMessages(false);
        ErrorMessageManagement.PopContext(ErrorContextElement);
        if not ThrowError then
            exit;
        ErrorContextElement.GetErrorMessage(ErrorMessage);
        ErrorMessage.ThrowError();
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure SetPasswordValue(ValueText: Text) ValueSet: Boolean
    begin
        ValueSet := SetAuthenticationValue(SpecRightPasswordLabel, ValueText);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure SetAPIKeyValue(ValueText: Text) ValueSet: Boolean
    begin
        ValueSet := SetAuthenticationValue(SpecRightAPIKeyLabel, ValueText);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure GetAPIKeyValue() Value: Text
    begin
        IsolatedStorage.Get(SpecRightAPIKeyLabel, Datascope::Module, Value);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure GetBearerToken() Value: Text
    begin
        IsolatedStorage.Get(SpecRightAccessLabel, Datascope::Module, Value);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure APIPasswordSet() Result: Boolean
    begin
        Result := IsolatedStorage.Contains(SpecRightPasswordLabel, Datascope::Module);
    end;

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure APIKeySet() Result: Boolean
    begin
        Result := IsolatedStorage.Contains(SpecRightAPIKeyLabel, Datascope::Module);
    end;

}