/// <summary>
/// Helper methods for the SBC Vena extension.
/// </summary>
codeunit 50259 "SBC Vena Helper"
{
#if not DEBUG
    [NonDebuggable]
#endif
    internal procedure SetAuthenticationValue(KeyText: Text; ValueText: Text) ValueSet: Boolean
    var
        BlankRecordId: RecordId;
    begin
        if not EncryptionEnabled() then
            ValueSet := IsolatedStorage.Set(KeyText, ValueText, DataScope::Module)
        else
            ValueSet := IsolatedStorage.SetEncrypted(KeyText, ValueText, DataScope::Module);

        if ValueSet then
            exit;

        SetErrorMessage(BlankRecordId, GetLastErrorText(), true);
    end;


    local procedure SetErrorMessage(ErrorRecordId: RecordId; ErrorText: Text; ThrowError: Boolean)
    var
        ErrorMessage: Record "Error Message";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
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

    internal procedure SetErrorMessage(ErrorRecordId: RecordId; ContextFieldNo: Integer; ErrorText: Text; ThrowError: Boolean)
    var
        ErrorMessage: Record "Error Message";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, ErrorRecordId, ContextFieldNo, CopyStr(ErrorText, 1, 250));
        if StrLen(ErrorText) > 250 then
            ErrorMessageManagement.LogMessage(0, 0, ErrorText, ErrorRecordId, ContextFieldNo, '');
        ErrorMessageHandler.RegisterErrorMessages(false);
        ErrorMessageManagement.PopContext(ErrorContextElement);
        if not ThrowError then
            exit;
        ErrorContextElement.GetErrorMessage(ErrorMessage);
        ErrorMessage.ThrowError();
    end;
}