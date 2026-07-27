/// <summary>
/// Codeunit SBC Get Vena Job Status (ID 50257).
/// </summary>
codeunit 50257 "SBC Get Vena Job Status"
{
    TableNo = "SBC Vena Job Status";
    Permissions = tabledata "SBC Vena API Setup" = R,
                  tabledata "SBC Vena Job Status" = RIM;
    trigger OnRun()
    begin
        GetStatus(Rec, JobsAPIPathLabel);
    end;

    var
        JobsAPIPathLabel: Label 'jobs';
        JobStatusApiPathLabel: Label 'status';

#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure GetStatus(var SBCVenaJobStatus: Record "SBC Vena Job Status"; VenaAPIEndpointPath: Text[200])
    var
        SBCSyncVenaJob: Codeunit "SBC Sync Vena Job";
        SBCVenaHelper: Codeunit "SBC Vena Helper";
        ApiUri: Codeunit Uri;
        HttpMethod: enum "Http Request Type";
        HttpClient: HttpClient;
        HttpRequestHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        BaseAddressText: Text;
        EndpointText: Text;
        JobStatusText: Text;
        LastErrorText: Text;
    begin
        // Initialize the HTTP client
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);
        SBCSyncVenaJob.InitializeHttpClient(HttpClient, HttpRequestHeaders);
        BaseAddressText := format(HttpClient.GetBaseAddress());
        EndpointText := StrSubstNo('/%1/%2/%3', VenaAPIEndpointPath, SBCVenaJobStatus."Vena Job ID", JobStatusApiPathLabel);
        ApiUri.Init(StrSubstNo('%1%2', BaseAddressText, EndpointText));
        HttpRequestMessage.Method(Format(HttpMethod::GET));
        HttpRequestMessage.SetRequestUri(ApiUri.GetAbsoluteUri());
        // Send the request
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        // Handle the response
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content.ReadAs(LastErrorText);
            if LastErrorText = '' then
                LastErrorText := GetLastErrorText();
            SBCVenaHelper.SetErrorMessage(SBCVenaJobStatus.RecordId(), 0, LastErrorText, false);
            exit;
        end else begin
            HttpResponseMessage.Content.ReadAs(JobStatusText);
            Evaluate(SBCVenaJobStatus."Vena Status", JobStatusText.Replace('"', '')); // Vena passes back the status in double quotes.
            SBCVenaJobStatus.Modify();
        end;
    end;


}