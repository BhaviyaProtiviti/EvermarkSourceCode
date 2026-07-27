/// <summary>
/// Report SBCOE Export Orders (ID 50060).
/// </summary>
report 50060 "SBCOE Export Wrapper"
{
    AllowScheduling = true;
    Caption = 'Export Orders to Excel';
    Description = 'Exports orders to Excel based on the Export Definition Code set in the Export Options page.';
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPostReport()
    begin
        if not GlobalSBCOEExport.HasEntries() then
            NoEntriesExportedAlert()
        else
            RunExportJob();
    end;

    var
        GlobalTempErrorMessage: Record "Error Message" temporary;
        GlobalSBCOEExport: Record "SBCOE Export";
        GlobalSBCOEExportDefinition: Record "SBCOE Export Definition";
        GlobalSuppressErrorDisplay: Boolean;
        NoEntriesExportedLabel: Label 'No entries were exported.';
        NoExportDefinitionInOptionsErrorLabel: Label 'Please set a valid export definition in the Export Options table.';
        NoExportDefinitionSetErrorTitleLabel: Label 'No Export Definition Set.';
        OrderExportErrorTitleLabel: Label 'Order Export Errors';
        UnhandledExportCreationErrorTitleLabel: Label 'Unhandled Export Creation Error';
        GlobalContactEmailsList: List of [Text];

    /// <summary>
    /// Allows a contact email list to be passed into the export process
    /// </summary>
    /// <param name="ContactEmailsList">List of [Text].</param>
    procedure SetGlobalContactEmailList(ContactEmailsList: List of [Text])
    begin
        if ContactEmailsList.Count = 0 then
            exit;
        GlobalContactEmailsList := ContactEmailsList;
    end;

    /// <summary>
    /// Allows an export object to be passed into the export process.
    /// </summary>
    /// <param name="SBCOEExport">Record "SBCOE Export".</param>
    procedure SetGlobalSBCOEExport(SBCOEExport: Record "SBCOE Export")
    begin
        GlobalSBCOEExport := SBCOEExport;
    end;

    /// <summary>
    /// Prevents the errors popup from displaying after the export process has run.
    /// </summary>
    /// <param name="SuppressErrorDisplay">Boolean.</param>
    procedure SetSuppressErrorDisplay(SuppressErrorDisplay: Boolean)
    begin
        GlobalSuppressErrorDisplay := SuppressErrorDisplay;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateExcelExport()
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        SBCOEExportManagement: Codeunit "SBCOE Export Management";
        ExportOk: Boolean;
    begin
        Commit();
        ExportOk := SBCOEExportManagement.Run(GlobalSBCOEExport);

        if not ExportOk then
            LogUnhandledError();

        if HasCollectedErrors() then
            SBCOEErrorHelper.CreateTempErrorMessagesFromCollectedErrors(GetCollectedErrors(), GlobalTempErrorMessage);

        ClearCollectedErrors();
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateExportEmail()
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
    begin
        if GlobalSBCOEExport."Email Group Code" = '' then
            exit;
        if not GlobalSBCOEExport.TryEmailExportAsAttachment(GlobalContactEmailsList) then
            LogUnhandledError();

        if HasCollectedErrors() then
            SBCOEErrorHelper.CreateTempErrorMessagesFromCollectedErrors(GetCollectedErrors(), GlobalTempErrorMessage);

        ClearCollectedErrors();
    end;

    local procedure LogUnhandledError()
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        UnhandledErrorInfo: ErrorInfo;
        ErrorText: Text;
    begin
        ErrorText := CopyStr(GetLastErrorText(), 1, MaxStrLen(GlobalTempErrorMessage.Message));
        UnhandledErrorInfo := SBCOEErrorHelper.CreateCollectableErrorInfo(GlobalSBCOEExport.RecordId().GetRecord(), GlobalSBCOEExport.RecordId().TableNo(), ErrorText, UnhandledExportCreationErrorTitleLabel);
        SBCOEErrorHelper.CreateTempErrorEntry(ErrorText, UnhandledErrorInfo, GlobalTempErrorMessage);
    end;

    local procedure NoEntriesExportedAlert()
    begin
        GlobalSBCOEExport.Delete();
        if GuiAllowed then
            Message(NoEntriesExportedLabel);
    end;

    local procedure RunExportJob()
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
    begin
        if not GlobalSBCOEExport.GetExportDefinition()."Notification Only" then
            CreateExcelExport();
        CreateExportEmail();
        SBCOEErrorHelper.LogCollectedErrors(GlobalTempErrorMessage, GlobalSuppressErrorDisplay);
    end;
}
