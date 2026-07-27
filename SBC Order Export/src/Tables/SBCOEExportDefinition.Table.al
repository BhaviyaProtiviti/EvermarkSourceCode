/// <summary>
/// Table SBCOE Excel Export Definition (ID 50062). This table contains the definitions of the Excel exports that can be generated from the SBCOE
/// </summary>
table 50062 "SBCOE Export Definition"
{
    Caption = 'Excel Export Definition';
    DataClassification = CustomerContent;
    Description = 'This table contains the definitions of the Excel exports that can be generated from the SBCOE';
    DrillDownPageId = "SBCOE Export Definition";
    LookupPageId = "SBCOE Export Definitions";
    fields
    {
        field(1; "Export Definition Code"; Code[20])
        {
            Caption = 'Export Definition Code';
            Description = 'Excel Export Definition Identifier';
        }
        field(2; Description; Text[200])
        {
            Caption = 'Description';
            Description = 'The description of the export definition';
        }
        field(3; "Spreadsheet Template"; Blob)
        {
            Caption = 'Spreadsheet Template';
            Description = 'This template can be loaded and used to generate the Excel export.';
        }
        field(4; "Export Report Header"; Text[50])
        {
            Caption = 'Export Report Header';
            Description = 'The report header used in the Excel export';
        }
        field(5; "Export File Name"; Text[250])
        {
            Caption = 'Export File Name';
            Description = 'The name of the Excel export file';
        }

        field(6; "Export Server Path"; Text[2048])
        {
            Caption = 'Export Server Path';
            Description = 'The path on the server where the Excel export will be stored';
#if not OnPrem
            Enabled = false;
#else 
            Enabled = true;
#endif
        }
        field(7; "Export Overwrite"; Boolean)
        {
            Caption = 'Export Overwrite';
            Description = 'If true, the export file will be overwritten if it already exists';
#if not OnPrem
            Enabled = false;
#else 
            Enabled = true;
#endif
        }
        field(10; "Email Group Code"; Code[20])
        {
            Caption = 'Email Group Code';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'The list of emails associated with this export.';
            TableRelation = "SBCOE Export Email Group"."Email Group Code";
        }
        field(20; "Export Email Subject"; Text[2048])
        {
            Caption = 'Export Email Subject';
            Description = 'The value here will be used instead of the default subject when sending the email.';
        }
        field(21; "Export Email Body"; Blob)
        {
            Caption = 'Export Email Body';
            Description = 'The value here will be used instead of the default body when sending the email.';
        }
        field(22; "Email Body Is HTML"; Boolean)
        {
            Caption = 'Email Body Is HTML';
            Description = 'Indicates whether the email body is HTML when set or plaintext when not set.';
        }
        field(23; "Timestamp Format String"; Text[50])
        {
            Caption = 'Timestamp Format String';
            DataClassification = CustomerContent;
            Description = 'The value here will be used instead of the default timestamp format in the email subject.';
        }
        field(24; "Notification Only"; Boolean)
        {
            Caption = 'Notification Only';
            Description = 'If this is set, the export will not be attached to the email.';
        }

        field(25; "Import"; Boolean)
        {
            Caption = 'Import';
            Description = 'If this is set, this definition will be used to import an Excel file.';
        }


    }
    keys
    {
        key(PK; "Export Definition Code")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        DeleteRows();
    end;

    trigger OnRename()
    begin
        RenameRows();
    end;

    var
        DefaultTimeZoneFormatLabel: Label 'u', Comment = 'yyyy-MM-dd HH:mm:ssZ', Locked = true;
        DownloadTemplateConfirmLabel: Label 'Would you like to download the current template?';
        ExcelFileExtension: Label '.xlsx', Locked = true;
        ExportDialogTitleLabel: Label 'Export Template';
        OverwriteExistingTemplateWarningLabel: Label 'The current template will be overwritten. Do you want to continue?';
        RegexFilenamePoNumberTokenLabel: Label '(?i)%DocKey|%1', Comment = 'Add more tokens here to extend replacement values.', Locked = true;
        RegexFilenameTimestampTokenLabel: Label '(?i)%Timestamp|%2', Comment = 'Add more tokens here to extend replacement values.', Locked = true;
        RegexHTMLPatternLabel: Label '</*[a-zA-Z][a-zA-Z0-9\-_]+>', Locked = true;
        SpreadsheetFilterTextLabel: Label 'Spreadsheets (*.xlsx)|*.xlsx;*.xls', Locked = true;
        TemplateDownloadFailedErrorLabel: Label 'Template Download failed: %1';

    internal procedure CopyExportDefinition()
    var
        SBCOEExportDefinition: Record "SBCOE Export Definition";
        SBCOECopyExportDefinition: Report "SBCOE Copy Export Definition";
    begin
        SBCOEExportDefinition := Rec;
        SBCOEExportDefinition.SetRecFilter();
        SBCOECopyExportDefinition.SetTableView(SBCOEExportDefinition);
        SBCOECopyExportDefinition.RunModal();
    end;

    internal procedure GetBodyText() BodyText: Text
    var
        BlankString: Text;
    begin
        BodyText := GetBodyText(DefaultTimeZoneFormatLabel, BlankString);
    end;

    internal procedure GetBodyText(TimeFormatString: Text; DocumentKeyString: Text) BodyText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        IsHandled: Boolean;
        PONumberRegex: Codeunit Regex;
        TimeStampRegex: Codeunit Regex;
    begin
        OnBeforeGetBodyText(BodyText, IsHandled);
        if IsHandled then
            exit;
        GetStringReplaceRegex(PONumberRegex, TimeStampRegex);
        if TimeFormatString = '' then
            TimeFormatString := Rec.GetTimestampFormatString();

        BodyText := GetDefaultBodyText();
        BodyText := TimeStampRegex.Replace(BodyText, TypeHelper.GetFormattedCurrentDateTimeInUserTimeZone(TimeFormatString));
        BodyText := PONumberRegex.Replace(BodyText, DocumentKeyString);
        OnAfterSetBodyText(BodyText);
    end;

    internal procedure GetExportFileName() ExportFileName: Text
    var
        BlankString: Text;
    begin
        ExportFileName := GetExportFileName(DefaultTimeZoneFormatLabel, BlankString);
    end;

    internal procedure GetExportEmailSubject() ExportEmailSubject: Text
    var
        BlankString: Text;
    begin
        ExportEmailSubject := GetExportEmailSubject(DefaultTimeZoneFormatLabel, BlankString);
    end;

    internal procedure GetExportFileName(TimeFormatString: Text; DocumentKeyString: Text) ExportFileName: Text
    var
        FileManagement: Codeunit "File Management";
        PONumberRegex: Codeunit Regex;
        TimeStampRegex: Codeunit Regex;
        TypeHelper: Codeunit "Type Helper";
        IsHandled: Boolean;
    begin
        OnBeforeGetExportFileName(ExportFileName, IsHandled);
        if IsHandled then
            exit;
        GetStringReplaceRegex(PONumberRegex, TimeStampRegex);
        if TimeFormatString = '' then
            TimeFormatString := Rec.GetTimestampFormatString();

        ExportFileName := Rec."Export File Name";
        ExportFileName := TimeStampRegex.Replace(ExportFileName, TypeHelper.GetFormattedCurrentDateTimeInUserTimeZone(TimeFormatString));
        ExportFileName := PONumberRegex.Replace(ExportFileName, DocumentKeyString);
        if not ExportFileName.ToLower().EndsWith(ExcelFileExtension) then
            ExportFileName += ExcelFileExtension;
        ExportFileName := FileManagement.GetSafeFileName(ExportFileName);
        OnAfterSetExportFileName(ExportFileName);
    end;

    internal procedure GetExportEmailSubject(TimeFormatString: Text; DocumentKeyString: Text) ExportEmailSubject: Text
    var
        IsHandled: Boolean;
        PONumberRegex: Codeunit Regex;
        TimeStampRegex: Codeunit Regex;
        TypeHelper: Codeunit "Type Helper";
    begin
        OnBeforeGetExportEmailSubject(ExportEmailSubject, IsHandled);
        if IsHandled then
            exit;
        GetStringReplaceRegex(PONumberRegex, TimeStampRegex);
        if TimeFormatString = '' then
            TimeFormatString := Rec.GetTimestampFormatString();

        ExportEmailSubject := Rec."Export Email Subject";
        if ExportEmailSubject = '' then
            ExportEmailSubject := GetOptions()."Export Email Subject";
        ExportEmailSubject := TimeStampRegex.Replace(ExportEmailSubject, TypeHelper.GetFormattedCurrentDateTimeInUserTimeZone(TimeFormatString));
        ExportEmailSubject := PONumberRegex.Replace(ExportEmailSubject, DocumentKeyString);
        OnAfterSetExportEmailSubject(ExportEmailSubject);
    end;

    internal procedure GetOptions() SBCOEExportOptions: Record "SBCOE Export Options";
    begin
        if not SBCOEExportOptions.Get() then;
    end;

    internal procedure GetTimestampFormatString() TimestampFormatString: Text
    var
        SBCOEExportOptions: Record "SBCOE Export Options";
        IsHandled: Boolean;
    begin
        OnBeforeGetTimestampFormatString(TimestampFormatString, IsHandled);
        if IsHandled then
            exit;

        case true of
            Rec."Timestamp Format String" <> '':
                TimestampFormatString := Rec."Timestamp Format String";
            Rec.GetOptions()."Timestamp Format String" <> '':
                TimestampFormatString := Rec.GetOptions()."Timestamp Format String";
            else
                TimestampFormatString := DefaultTimeZoneFormatLabel;
        end;
    end;

    internal procedure HasDetail(var SBCOEExportRow: Record "SBCOE Export Row"): Boolean
    begin
        SetDetailRowFilters(SBCOEExportRow);
        exit(not SBCOEExportRow.IsEmpty());
    end;

    internal procedure HasFooter(var SBCOEExportRow: Record "SBCOE Export Row"): Boolean
    begin
        SetFooterRowFilters(SBCOEExportRow);
        exit(not SBCOEExportRow.IsEmpty());
    end;

    internal procedure HasHeader(var SBCOEExportRow: Record "SBCOE Export Row"): Boolean
    begin
        SetHeaderRowFilters(SBCOEExportRow);
        exit(not SBCOEExportRow.IsEmpty());
    end;

    internal procedure HasInfoRows(): Boolean
    var
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        SetRowFilters(SBCOEExportRow);
        SBCOEExportRow.SetRange("Info Sheet", true);
        exit(not SBCOEExportRow.IsEmpty());
    end;

    internal procedure SetBodyText(StreamText: Text)
    var
        OutStream: OutStream;
    begin
        SetFormattedHtmlFlag(StreamText);
        Clear(Rec."Export Email Body");
        Rec."Export Email Body".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(StreamText);
        if Rec.Modify(true) then;
    end;

    internal procedure SetDetailRowFilters(var SBCOEExportRow: Record "SBCOE Export Row")
    begin
        SetRowFilters(SBCOEExportRow);
        SBCOEExportRow.SetRange("Row Type", "SBCOE Row Type"::Detail);
    end;

    internal procedure SetFooterRowFilters(var SBCOEExportRow: Record "SBCOE Export Row")
    begin
        SetRowFilters(SBCOEExportRow);
        SBCOEExportRow.SetRange("Row Type", "SBCOE Row Type"::Footer);
    end;

    internal procedure SetHeaderRowFilters(var SBCOEExportRow: Record "SBCOE Export Row")
    begin
        SetRowFilters(SBCOEExportRow);
        SBCOEExportRow.SetRange("Row Type", "SBCOE Row Type"::Header);
    end;

    internal procedure SetRowFilters(var SBCOEExportRow: Record "SBCOE Export Row")
    begin
        SBCOEExportRow.SetRange("Export Definition Code", "Export Definition Code");
        SBCOEExportRow.SetCurrentKey("Row Type", "Row Order");
    end;

    internal procedure UploadFile() SelectedPath: Text
    var
        ConfirmManagement: Codeunit "Confirm Management";
        UploadedInStream: InStream;
        UploadOutStream: OutStream;
    begin
        Rec.CalcFields(Rec."Spreadsheet Template");

        if not Rec.Import then
            if Rec."Spreadsheet Template".HasValue() then begin
                if not ConfirmManagement.GetResponseOrDefault(OverwriteExistingTemplateWarningLabel, true) then
                    exit;
                if not DownloadExistingTemplate() and GuiAllowed then
                    Message(TemplateDownloadFailedErrorLabel, GetLastErrorText());
            end;
            
        Rec."Spreadsheet Template".CreateInStream(UploadedInStream);
        if not UploadIntoStream(ExportDialogTitleLabel, '', Format(SpreadsheetFilterTextLabel), SelectedPath, UploadedInStream) then
            exit;
        Rec."Spreadsheet Template".CreateOutStream(UploadOutStream);
        if not CopyStream(UploadOutStream, UploadedInStream) then
            exit;
        Rec.Modify(true);
    end;

    local procedure DeleteRows()
    var
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        SetRowFilters(SBCOEExportRow);
        if SBCOEExportRow.IsEmpty() then
            exit;
        SBCOEExportRow.DeleteAll(true);
    end;

    [TryFunction]
    local procedure DownloadExistingTemplate()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CurrentTemplateInStream: InStream;
        DownloadFileName: Text;
    begin
        if not GuiAllowed then
            exit;
        if not ConfirmManagement.GetResponseOrDefault(DownloadTemplateConfirmLabel, true) then
            exit;
        Rec.CalcFields(Rec."Spreadsheet Template");
        Rec."Spreadsheet Template".CreateInStream(CurrentTemplateInStream);
        DownloadFileName := Rec."Export Definition Code" + ExcelFileExtension;
        DownloadFromStream(CurrentTemplateInStream, ExportDialogTitleLabel, '', '', DownloadFileName);
    end;

    local procedure RenameRows()
    var
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        SetRowFilters(SBCOEExportRow);
        if SBCOEExportRow.IsEmpty() then
            exit;
        SBCOEExportRow.FindSet(true);
        repeat
            SBCOEExportRow.Rename(Rec."Export Definition Code", SBCOEExportRow."Row Definition Code");
        until SBCOEExportRow.Next() = 0;
    end;

    local procedure SetFormattedHtmlFlag(StreamText: Text)
    var
        Regex: Codeunit Regex;
        IsHtmlFormattedText: Boolean;
    begin
        Regex.Regex(RegexHTMLPatternLabel);
        IsHtmlFormattedText := Regex.IsMatch(StreamText.Trim());
        xRec.CalcFields("Export Email Body");
        case true of
            (xRec."Export Email Body".Length() <= 1) and IsHtmlFormattedText and not Rec."Email Body Is HTML":
                Rec."Email Body Is HTML" := true;
            xRec."Export Email Body".HasValue() and not IsHtmlFormattedText and Rec."Email Body Is HTML":
                Rec."Email Body Is HTML" := false;
        end;
    end;

    local procedure GetStringReplaceRegex(var PONumberRegex: Codeunit Regex; var TimeStampRegex: Codeunit Regex)
    begin
        PONumberRegex.Regex(RegexFilenamePoNumberTokenLabel);
        TimeStampRegex.Regex(RegexFilenameTimestampTokenLabel);
    end;

    internal procedure GetDefaultBodyText() BodyText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
    begin
        TempBlob.FromRecord(Rec, FieldNo(Rec."Export Email Body"));
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        BodyText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetExportFileName(var ExportFileName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetExportFileName(var ExportFileName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetTimestampFormatString(var TimestampFormatString: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetExportEmailSubject(var ExportEmailSubject: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetExportEmailSubject(var ExportEmailSubject: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetBodyText(var BodyText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBodyText(var BodyText: Text; var IsHandled: Boolean)
    begin
    end;

#if OnPrem
    /// <summary>
    /// Returns true if the export definition has a server export path set.
    /// </summary>
    /// <returns> True if the export definition has a server export path set. </returns>
    internal procedure HasExportServerPath(): Boolean
    begin
        exit(Rec."Export Server Path" <> '');
    end;
#endif

}
