/// <summary>
/// Codeunit SBCOE Email Log Events (ID 50065).
/// </summary>
codeunit 50065 "SBCOE Email Log Events"
{
    local procedure UpdateLastSentTime(var SentEmail: Record "Sent Email")
    var
        SBCOEExportSendLog: Record "SBCOE Export Send Log";
    begin
        SBCOEExportSendLog.SetFilter("Email Message Id", '%1', SentEmail.GetMessageId());
        if SBCOEExportSendLog.IsEmpty() then
            exit;
        SBCOEExportSendLog.FindFirst();
        SBCOEExportSendLog."Date/Time Sent" := SentEmail.SystemCreatedAt;
        SBCOEExportSendLog.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, OnAfterEmailSent, '', false, false)]
    local procedure UpdateEmailLog(SentEmail: Record "Sent Email")
    begin
        UpdateLastSentTime(SentEmail);
    end;
}
