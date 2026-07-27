/// <summary>
/// Allows job status updates to be retrieved from Vena.
/// </summary>
report 50257 "SBC Vena Job Status Update"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Job Status Update';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    dataset
    {
        dataitem(SBCVenaJobStatus; "SBC Vena Job Status")
        {
            trigger OnAfterGetRecord()
            var
                SBCGetVenaJobStatus: Codeunit "SBC Get Vena Job Status";
            begin
                SBCGetVenaJobStatus.Run(SBCVenaJobStatus);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    var
        SyncJobInitiatedLabel: Label 'Status Updated.';

    trigger OnPostReport()
    var
        CompletionNotifiction: Notification;
    begin
        if not GuiAllowed() then
            exit;
        CompletionNotifiction.Message := SyncJobInitiatedLabel;
        CompletionNotifiction.Scope := NotificationScope::LocalScope;
        CompletionNotifiction.Send();
    end;


}