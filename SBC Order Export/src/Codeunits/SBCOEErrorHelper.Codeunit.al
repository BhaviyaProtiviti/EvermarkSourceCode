/// <summary>
/// This codeunit contains helper functions for handling errors.
/// </summary>
codeunit 50064 "SBCOE Error Helper"
{
    var
        InvalidEmailBlankGuidLabel: Label '00000000-0000-0000-0000-000000000000';

    /// <summary>
    /// Returns a collectable error info object based on the input parameters passed into the procedure.
    /// </summary>
    /// <param name="ErrorRecordRef">RecordRef.</param>
    /// <param name="MessageText">Text.</param>
    /// <param name="TitleText">Text.</param>
    /// <returns>Return variable CollectableErrorInfo of type ErrorInfo.</returns>
    procedure CreateCollectableErrorInfo(ErrorRecordRef: RecordRef; MessageText: Text; TitleText: Text) CollectableErrorInfo: ErrorInfo
    var
        PageManagement: Codeunit "Page Management";
        ErrorDataClassification: DataClassification;
        ErrorVerbosity: Verbosity;
    begin
        CollectableErrorInfo := CreateCollectableErrorInfo(ErrorRecordRef, '', 0, PageManagement.GetPageID(ErrorRecordRef), ErrorRecordRef.Number(), MessageText, TitleText, ErrorDataClassification, ErrorVerbosity);
    end;

    /// <summary>
    /// Returns a collectable error info object based on the input parameters passed into the procedure.
    /// </summary>
    /// <param name="ErrorRecordRef">RecordRef.</param>
    /// <param name="TableId">Integer.</param>
    /// <param name="MessageText">Text.</param>
    /// <param name="TitleText">Text.</param>
    /// <returns>Return variable CollectableErrorInfo of type ErrorInfo.</returns>
    procedure CreateCollectableErrorInfo(ErrorRecordRef: RecordRef; TableId: Integer; MessageText: Text; TitleText: Text) CollectableErrorInfo: ErrorInfo
    var
        ErrorDataClassification: DataClassification;
        ErrorVerbosity: Verbosity;
    begin
        CollectableErrorInfo := CreateCollectableErrorInfo(ErrorRecordRef, '', 0, 0, TableId, MessageText, TitleText, ErrorDataClassification, ErrorVerbosity);
    end;

    /// <summary>
    /// Returns a collectable error info object based on the input parameters passed into the procedure.
    /// </summary>
    /// <param name="ErrorRecordRef">RecordRef.</param>
    /// <param name="ControlName">Text.</param>
    /// <param name="FieldID">Integer.</param>
    /// <param name="PageId">Integer.</param>
    /// <param name="TableId">Integer.</param>
    /// <param name="MessageText">Text.</param>
    /// <param name="TitleText">Text.</param>
    /// <param name="ErrorDataClassification">DataClassification.</param>
    /// <param name="ErrorVerbosity">Verbosity.</param>
    /// <returns>Return variable CollectableErrorInfo of type ErrorInfo.</returns>
    procedure CreateCollectableErrorInfo(ErrorRecordRef: RecordRef; ControlName: Text; FieldID: Integer; PageId: Integer; TableId: Integer; MessageText: Text; TitleText: Text) CollectableErrorInfo: ErrorInfo
    var
        ErrorDataClassification: DataClassification;
        ErrorVerbosity: Verbosity;
    begin
        CollectableErrorInfo := CreateCollectableErrorInfo(ErrorRecordRef, ControlName, FieldID, PageId, TableId, MessageText, TitleText, ErrorDataClassification, ErrorVerbosity);
    end;

    /// <summary>
    /// Returns a collectable error info object based on the input parameters passed into the procedure.
    /// </summary>
    /// <param name="ErrorRecordRef">RecordRef.</param>
    /// <param name="ControlName">Text.</param>
    /// <param name="FieldID">Integer.</param>
    /// <param name="PageId">Integer.</param>
    /// <param name="TableId">Integer.</param>
    /// <param name="MessageText">Text.</param>
    /// <param name="TitleText">Text.</param>
    /// <param name="ErrorDataClassification">DataClassification.</param>
    /// <param name="ErrorVerbosity">Verbosity.</param>
    /// <returns>Return variable CollectableErrorInfo of type ErrorInfo.</returns>
    procedure CreateCollectableErrorInfo(ErrorRecordRef: RecordRef; ControlName: Text; FieldID: Integer; PageId: Integer; TableId: Integer; MessageText: Text; TitleText: Text; ErrorDataClassification: DataClassification; ErrorVerbosity: Verbosity) CollectableErrorInfo: ErrorInfo
    var
        ErrorSystemId: Guid;
    begin
        if Format(ErrorDataClassification) = '' then
            ErrorDataClassification := DataClassification::EndUserIdentifiableInformation;

        if Format(ErrorVerbosity) = '' then
            ErrorVerbosity := Verbosity::Warning;
        CollectableErrorInfo.ErrorType(ErrorType::Client);
        CollectableErrorInfo.ControlName(ControlName);
        CollectableErrorInfo.FieldNo(FieldID);
        CollectableErrorInfo.DataClassification(ErrorDataClassification);
        CollectableErrorInfo.PageNo(PageId);
        CollectableErrorInfo.TableId(TableId);
        CollectableErrorInfo.Message(MessageText);
        CollectableErrorInfo.DetailedMessage(GetLastErrorText());
        ErrorSystemId := ErrorRecordRef.Field(ErrorRecordRef.SystemIdNo()).Value;

        if Format(ErrorRecordRef.RecordId()) <> '' then
            CollectableErrorInfo.RecordId(ErrorRecordRef.RecordId());

        if Format(ErrorSystemId) <> InvalidEmailBlankGuidLabel then
            CollectableErrorInfo.SystemId(ErrorSystemId);

        CollectableErrorInfo.Title(TitleText);
        CollectableErrorInfo.Verbosity(ErrorVerbosity);
        CollectableErrorInfo.Collectible(true);
    end;

    internal procedure CreateTempErrorEntry(var ErrorText: Text; var UnhandledErrorInfo: ErrorInfo; var TempErrorMessage: Record "Error Message" temporary)
    var
        ErrorCallStackOutStream: OutStream;
    begin
        TempErrorMessage.ID := TempErrorMessage.ID + 1;
        TempErrorMessage."Record ID" := UnhandledErrorInfo.RecordId();
        TempErrorMessage."Field Number" := UnhandledErrorInfo.FieldNo();
        TempErrorMessage."Message Type" := TempErrorMessage."Message Type"::Error;
        TempErrorMessage.Message := ErrorText;
        TempErrorMessage."Table Number" := UnhandledErrorInfo.TableId();
        TempErrorMessage."Error Call Stack".CreateOutStream(ErrorCallStackOutStream);
        ErrorCallStackOutStream.WriteText(GetLastErrorCallStack());
        TempErrorMessage.Insert(true);
    end;

    internal procedure CreateTempErrorMessagesFromCollectedErrors(CollectedErrors: List of [ErrorInfo]; var TempErrorMessage: Record "Error Message" temporary)
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        NullRecordID: RecordId;
        CollectedErrorInfo: ErrorInfo;
        ErrorText: Text;
    begin
        foreach CollectedErrorInfo in CollectedErrors do begin
            ErrorText := CopyStr(CollectedErrorInfo.Message, 1, MaxStrLen(TempErrorMessage.Message));
            SBCOEErrorHelper.CreateTempErrorEntry(ErrorText, CollectedErrorInfo, TempErrorMessage);
        end;
    end;

    internal procedure LogCollectedErrors(var TempErrorMessage: Record "Error Message" temporary; SuppressDisplay: Boolean)
    var
        ErrorMessage: Record "Error Message";
    begin
        if TempErrorMessage.IsEmpty() then
            exit;
        ErrorMessage.CopyFromTemp(TempErrorMessage);
        Commit();
        if not GuiAllowed then
            exit;
        if SuppressDisplay then
            exit;
        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;
}
