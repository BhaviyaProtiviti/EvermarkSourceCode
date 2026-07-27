/// <summary>
/// This codeunit is used to export data to Excel. It is used by the SBCOE Export Management codeunit.
/// </summary>
codeunit 50063 "SBCOE Export Management"
{
    TableNo = "SBCOE Export";

    var
        GlobalSBCOEExport: Record "SBCOE Export";
        GlobalSBCOEExportColumn: Record "SBCOE Export Column";
        GlobalSBCOEExportDefinition: Record "SBCOE Export Definition";
        GlobalSBCOEExportRow: Record "SBCOE Export Row";

        GlobalDataRecordRef: RecordRef;
        ColumnDataErrorLabel: Label 'Error setting column data.';
        ColumnDefaultValueErrorLabel: Label 'Error setting column default value.';
        ColumnPaddingErrorLabel: Label 'Error padding column data.';
        ColumnTransformationErrorLabel: Label 'Error transforming column data.';
        ExcelExportErrorTitleLabel: Label 'Excel Export Error';
        ExcelFileNameLabel: Label 'SBC-UL-PO ZOR.xlsx';
        InvalidEmailBlankGuidLabel: Label '00000000-0000-0000-0000-000000000000';
        ServerFileVariableNameLabel: Label 'ExcelFile';
        TrySetGlobalsErrorLabel: Label 'The Export Definition, Export Rows, and Export Columns must be setup before running this export job.';
        XlCurrentColVarLabel: Label 'CurrentCol', Locked = true;
        XlCurrentRowVarLabel: Label 'CurrentRow', Locked = true;

    trigger OnRun()
    begin
        if not TrySetGlobals(Rec) then begin
            ThrowError(Rec, TrySetGlobalsErrorLabel);
            exit;
        end;
        CreateExport();
        Rec := GlobalSBCOEExport;
    end;
    /// <summary>
    /// This procedure executes the steps of the export process.
    /// </summary>
    internal procedure CreateExport()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        DetailSBCOEExportRow: Record "SBCOE Export Row";
        FooterSBCOEExportRow: Record "SBCOE Export Row";
        ExportServerFile: Boolean;
        ResultOutStream: OutStream;
        CurrentSheetName: Text;
        ServerFileName: Variant;
    begin

        OnBeforeCreateExcelData();
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        if not TryOpenSpreadsheetTemplate(TempExcelBuffer, CurrentSheetName) then
            TempExcelBuffer.CreateNewBook(ExcelFileNameLabel);
        if GlobalSBCOEExportDefinition.HasInfoRows() then
            TempExcelBuffer.SetUseInfoSheet();

        // Header
        CreateHeader(TempExcelBuffer);
        CreateDetail(TempExcelBuffer);
        CreateFooter(TempExcelBuffer);

        // if on prem, then we are allowed to move the to a new location.
#if OnPrem
        ExportServerFile := GlobalSBCOEExportDefinition.HasExportServerPath();
#endif
        GlobalSBCOEExport."Export Data".CreateOutStream(ResultOutStream);
        TempExcelBuffer.WriteSheet(GlobalSBCOEExportDefinition."Export Report Header", CompanyName, UserId);
        TempExcelBuffer.UTgetGlobalValue(ServerFileVariableNameLabel, ServerFileName);
        TempExcelBuffer.QuitExcel();
        TempExcelBuffer.SaveToStream(ResultOutStream, not ExportServerFile);
        GlobalSBCOEExport.Modify(true);
#if OnPrem
        if not ExportServerFile then
            exit;
#pragma warning disable AL0296
        ExportFileToServerPath(format(ServerFileName));
#pragma warning restore AL0296
#endif
    end;

    internal procedure PadLeft(TextString: Text; PadLength: Integer; PadCharacter: Char) PaddedString: Text
    begin
        PaddedString := TextString.PadLeft(PadLength, PadCharacter);
    end;

    internal procedure PadRight(TextString: Text; PadLength: Integer; PadCharacter: Char) PaddedString: Text
    begin
        PaddedString := TextString.PadRight(PadLength, PadCharacter);
    end;

    /// <summary>
    /// The procedure adds column data and formatting to the Excel buffer based on the SBCOE Export Column.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    /// <param name="SBCOEExportRow">VAR Record "SBCOE Export Row".</param>
    /// <param name="SBCOEExportColumn">VAR Record "SBCOE Export Column".</param>
    /// <param name="SBCOEExportEntry">VAR Record "SBCOE Export Entry".</param>
    /// <param name="HasData">Boolean value indicating if there is data in the export.</param>
    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure AddColumnToExport(var TempExcelBuffer: Record "Excel Buffer" temporary; var SBCOEExportRow: Record "SBCOE Export Row"; var SBCOEExportColumn: Record "SBCOE Export Column"; var SBCOEExportEntry: Record "SBCOE Export Entry"; HasData: Boolean)
    var
        CurrentColumn: Integer;
        CurrentRow: Integer;
        CurrentColumnVariant: Variant;
        CurrentRowVariant: Variant;
        FieldValueVariant: Variant;
    begin
        case true of
            SBCOEExportColumn.Formula:
                FieldValueVariant := SBCOEExportColumn."Formula Text";
            HasData:
                begin
                    if not TrySetColumnData(SBCOEExportColumn, SBCOEExportEntry, FieldValueVariant) then
                        ThrowError(SBCOEExportColumn, ColumnDataErrorLabel);
                end;
            else
                if not TrySetColumnDefaultValue(SBCOEExportColumn, FieldValueVariant) then
                    ThrowError(SBCOEExportColumn, ColumnDefaultValueErrorLabel);
        end;
        if SBCOEExportColumn."Allow Substitution" then
            OnAfterSetFieldValue(SBCOEExportColumn, FieldValueVariant, CurrentRow, CurrentColumn);
        if not TryTransformColumnData(SBCOEExportColumn, FieldValueVariant) then
            ThrowError(SBCOEExportColumn, ColumnTransformationErrorLabel);
        if not TryPadColumnData(SBCOEExportColumn, FieldValueVariant) then
            ThrowError(SBCOEExportColumn, ColumnPaddingErrorLabel);
        TempExcelBuffer.UTgetGlobalValue(XlCurrentRowVarLabel, CurrentRowVariant);
        TempExcelBuffer.UTgetGlobalValue(XlCurrentColVarLabel, CurrentColumnVariant);
        CurrentRow := CurrentRowVariant;
        CurrentColumn := CurrentColumnVariant;
        if CurrentColumn <> SBCOEExportColumn."Export Column No." - 1 then
            TempExcelBuffer.SetCurrent(CurrentRow, SBCOEExportColumn."Export Column No." - 1);
        if not SBCOEExportRow."Info Sheet" then
            TempExcelBuffer.AddColumn(FieldValueVariant, SBCOEExportColumn.Formula, SBCOEExportColumn."Comment Text", SBCOEExportColumn.Bold, SBCOEExportColumn.Italics, SBCOEExportColumn.Underline, SBCOEExportColumn."Number Format", SBCOEExportColumn."Cell Type".AsInteger())
        else
            TempExcelBuffer.AddInfoColumn(FieldValueVariant, SBCOEExportColumn.Formula, SBCOEExportColumn.Bold, SBCOEExportColumn.Italics, SBCOEExportColumn.Underline, SBCOEExportColumn."Number Format", SBCOEExportColumn."Cell Type".AsInteger());

        if not SBCOEExportColumn."Double Underline" then
            exit;
        TempExcelBuffer."Double Underline" := true;
        TempExcelBuffer.Modify();
    end;

    /// <summary>
    /// The procedure will create detail rows in the Excel Buffer.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    local procedure CreateDetail(var TempExcelBuffer: Record "Excel Buffer" temporary)
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        if not GlobalSBCOEExportDefinition.HasDetail(SBCOEExportRow) then
            exit;
        GlobalSBCOEExport.HasDetail(SBCOEExportEntry);
        CreateRows(TempExcelBuffer, SBCOEExportRow, SBCOEExportEntry);
    end;
    /// <summary>
    /// This procedure will create footer rows in the Excel Buffer.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    local procedure CreateFooter(var TempExcelBuffer: Record "Excel Buffer" temporary)
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        if not GlobalSBCOEExportDefinition.HasFooter(SBCOEExportRow) then
            exit;
        GlobalSBCOEExport.HasFooter(SBCOEExportEntry);
        CreateRows(TempExcelBuffer, SBCOEExportRow, SBCOEExportEntry);
    end;

    /// <summary>
    /// This procedure will create header rows in the Excel Buffer.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>

    local procedure CreateHeader(var TempExcelBuffer: Record "Excel Buffer" temporary)
    var
        SBCOEExportEntry: Record "SBCOE Export Entry";
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        if not GlobalSBCOEExportDefinition.HasHeader(SBCOEExportRow) then
            exit;
        GlobalSBCOEExport.HasHeader(SBCOEExportEntry);
        // This should run create rows at least once even if no data is being fed in.
        CreateRows(TempExcelBuffer, SBCOEExportRow, SBCOEExportEntry);
    end;
    /// <summary>
    /// This procedure will iterate over data in the export, row definition, and column definition, to build the Excel Buffer.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    /// <param name="SBCOEExportRow">VAR Record "SBCOE Export Row".</param>
    /// <param name="SBCOEExportEntry">VAR Record "SBCOE Export Entry".</param>
    local procedure CreateRows(var TempExcelBuffer: Record "Excel Buffer" temporary; var SBCOEExportRow: Record "SBCOE Export Row"; var SBCOEExportEntry: Record "SBCOE Export Entry")
    var
        SBCOEExportColumn: Record "SBCOE Export Column";
        HasData: Boolean;
    begin
        SBCOEExportRow.FindSet();
        SBCOEExportRow.SetColumnFilters(SBCOEExportColumn);
        SetRowSpacing(TempExcelBuffer, SBCOEExportRow);
        SetRowStart(TempExcelBuffer, SBCOEExportRow);
        HasData := SBCOEExportEntry.FindSet();
        // this should run once even if no data is found.
        repeat
            repeat
                SBCOEExportColumn.FindSet();
                repeat
                    AddColumnToExport(TempExcelBuffer, SBCOEExportRow, SBCOEExportColumn, SBCOEExportEntry, HasData);
                until SBCOEExportColumn.Next() = 0;
            until SBCOEExportRow.Next() = 0;
            TempExcelBuffer.NewRow();
        until SBCOEExportEntry.Next() = 0;
    end;

    /// <summary>
    /// Generates an error for an invalid email address.
    /// </summary>
    local procedure GenerateExportError(ErrorRecordRef: RecordRef; MessageText: Text)
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        ExportErrorInfo: ErrorInfo;
    begin
        ExportErrorInfo := SBCOEErrorHelper.CreateCollectableErrorInfo(ErrorRecordRef, ErrorRecordRef.RecordId.TableNo(), MessageText, ExcelExportErrorTitleLabel);
        Error(ExportErrorInfo);
    end;

    /// <summary>
    /// This procedure will create rows in the Excel Buffer until the row number is equal to the "Row Spacing" field on the SBCOE Export Row.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    /// <param name="SBCOEExportRow">VAR Record "SBCOE Export Row".</param>
    /// <returns>False if an runtime error occurred. Otherwise true.</returns>
    local procedure SetRowSpacing(var TempExcelBuffer: Record "Excel Buffer" temporary; var SBCOEExportRow: Record "SBCOE Export Row")
    var
        RowStart: Integer;
    begin
        if SBCOEExportRow."Row Spacing" = 0 then
            exit;
        for RowStart := 0 to SBCOEExportRow."Row Spacing" do
            TempExcelBuffer.NewRow();
    end;

    /// <summary>
    /// This procedure will create rows in the Excel Buffer until the row number is equal to the "Row Start" field on the SBCOE Export Row.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    /// <param name="HeaderSBCOEExportRow">VAR Record "SBCOE Export Row".</param>

    local procedure SetRowStart(var TempExcelBuffer: Record "Excel Buffer" temporary; var HeaderSBCOEExportRow: Record "SBCOE Export Row")
    var
        RowEnd: Integer;
        RowStart: Integer;
    begin
        if not (TempExcelBuffer."Row No." < HeaderSBCOEExportRow."Row Start") then
            exit;
        RowEnd := HeaderSBCOEExportRow."Row Start" - TempExcelBuffer."Row No.";
        for RowStart := 1 to RowEnd do
            TempExcelBuffer.NewRow();
    end;

    local procedure ThrowError(ErrorRecordVariant: Variant; ErrorText: Text)
    begin
        ThrowError(ErrorRecordVariant, ErrorText, ExcelExportErrorTitleLabel);
    end;

    local procedure ThrowError(ErrorRecordVariant: Variant; ErrorText: Text; ErrorTitle: Text)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        ErrorRecordRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(ErrorRecordVariant, ErrorRecordRef) then
            exit;
        Error(SBCOEErrorHelper.CreateCollectableErrorInfo(ErrorRecordRef, ErrorText, ErrorTitle));
    end;

    /// <summary>
    /// This procedure will try and open the spreadsheet template if it exists on the export definition.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    [TryFunction]
    local procedure TryOpenSpreadsheetTemplate(var TempExcelBuffer: Record "Excel Buffer" temporary; var OpenedSheetName: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        OpenXMLManagement: Codeunit "OpenXML Management";
        SpreadsheetTemplateInStream: InStream;
        XLWrkSheetWriter: Variant;
    begin
        if not GlobalSBCOEExportDefinition."Spreadsheet Template".HasValue() then
            exit;
        GlobalSBCOEExportDefinition.CalcFields("Spreadsheet Template");
        GlobalSBCOEExportDefinition."Spreadsheet Template".CreateInStream(SpreadsheetTemplateInStream);
        TempExcelBuffer.GetSheetsNameListFromStream(SpreadsheetTemplateInStream, TempNameValueBuffer);
        TempNameValueBuffer.FindFirst();
        TempExcelBuffer.UpdateBookStream(SpreadsheetTemplateInStream, TempNameValueBuffer.Value, true);
        OpenedSheetName := TempNameValueBuffer.Value;
    end;

    [TryFunction]
    local procedure TryPadColumnData(var SBCOEExportColumn: Record "SBCOE Export Column"; var FieldValueVariant: Variant)
    var
        PadCharacter: Char;
        FormattedFieldValueVariant: Text;
    begin
        if SBCOEExportColumn.Formula then
            exit;
        if SBCOEExportColumn."Cell Type".AsInteger() <> Enum::"SBCOE Cell Types"::Text.AsInteger() then
            exit;
        if SBCOEExportColumn."Pad Length" <= 0 then
            exit;
        FormattedFieldValueVariant := Format(FieldValueVariant);
        if StrLen(FormattedFieldValueVariant) = SBCOEExportColumn."Pad Length" then
            exit;
        case SBCOEExportColumn."Pad Type" of
            "SBCOE Pad Type"::" ", "SBCOE Pad Type"::Space:
                PadCharacter := ' ';
            SBCOEExportColumn."Pad Type"::Zero:
                PadCharacter := '0';
            SBCOEExportColumn."Pad Type"::Custom:
                Evaluate(PadCharacter, SBCOEExportColumn."Pad Character");
        end;
        case SBCOEExportColumn."Pad Direction" of
            "SBCOE Pad Direction"::Left, "SBCOE Pad Direction"::" ":
                FieldValueVariant := PadLeft(FormattedFieldValueVariant, SBCOEExportColumn."Pad Length", PadCharacter);
            SBCOEExportColumn."Pad Direction"::Right:
                FieldValueVariant := PadRight(FormattedFieldValueVariant, SBCOEExportColumn."Pad Length", PadCharacter);
        end;
    end;
    /// <summary>
    /// This procedure will try and set the data for a column, if it exists. It will also try and set a default value if the value is blank and this option is selected on the column.
    /// </summary>
    /// <param name="SBCOEExportColumn">VAR Record "SBCOE Export Column".</param>
    /// <param name="SBCOEExportEntry">VAR Record "SBCOE Export Entry".</param>
    /// <param name="FieldValueVariant">VAR Variant.</param>
    /// <returns>False if an runtime error occurred. Otherwise true.</returns>
    [TryFunction]
    local procedure TrySetColumnData(var SBCOEExportColumn: Record "SBCOE Export Column"; var SBCOEExportEntry: Record "SBCOE Export Entry"; var FieldValueVariant: Variant)
    var
        DataRecordRef: RecordRef;
    begin
        DataRecordRef.Open(SBCOEExportEntry."Export Table No.");
        DataRecordRef.GetBySystemId(SBCOEExportEntry."Export System ID");
        FieldValueVariant := SBCOEExportColumn.GetFieldValue(DataRecordRef);
        if not TrySetColumnDefaultValue(SBCOEExportColumn, FieldValueVariant) then
            ThrowError(SBCOEExportColumn, ColumnDefaultValueErrorLabel);
    end;
    /// <summary>
    /// This procedure will try and set a default value for a column if the value is blank and this option is selected on the column.
    /// </summary>
    /// <param name="SBCOEExportColumn">VAR Record "SBCOE Export Column".</param>
    /// <param name="FieldValueVariant">VAR Variant.</param>
    /// <returns>False if an runtime error occurred. Otherwise true.</returns>
    [TryFunction]
    local procedure TrySetColumnDefaultValue(var SBCOEExportColumn: Record "SBCOE Export Column"; var FieldValueVariant: Variant)
    begin
        if not SBCOEExportColumn."Replace Blank with Default" then
            exit;
        if SBCOEExportColumn."Default Text".Trim() = '' then
            exit;
        if not (Format(FieldValueVariant).Trim() in ['0', '']) then
            exit;
        FieldValueVariant := SBCOEExportColumn."Default Text";
    end;

    [TryFunction]
    local procedure TrySetGlobals(var Rec: Record "SBCOE Export")
    begin
        GlobalSBCOEExport.Copy(Rec);
        GlobalSBCOEExport.SetExportDefinitionFilters(GlobalSBCOEExportDefinition);
        GlobalSBCOEExportDefinition.FindFirst();
        GlobalSBCOEExportDefinition.SetRowFilters(GlobalSBCOEExportRow);
        GlobalSBCOEExportRow.FindSet();
        GlobalSBCOEExportRow.SetColumnFilters(GlobalSBCOEExportColumn);
        GlobalSBCOEExportColumn.FindSet();
    end;

    [TryFunction]
    local procedure TryTransformColumnData(var SBCOEExportColumn: Record "SBCOE Export Column"; var FieldValueVariant: Variant)
    var
        TransformationRule: Record "Transformation Rule";
    begin
        if SBCOEExportColumn."Transformation Rule" = '' then
            exit;
        TransformationRule.Get(SBCOEExportColumn."Transformation Rule");
        FieldValueVariant := TransformationRule.TransformText(Format(FieldValueVariant));
    end;

    /// <summary>
    /// Called after before writing Excel data.
    /// </summary>

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateExcelData()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFieldValue(SBCOEExportColumn: Record "SBCOE Export Column"; var FieldValueVariant: Variant; var CurrentRow: Integer; var CurrentColumn: Integer)
    begin
    end;
#if OnPrem
    [Scope('OnPrem')]
    local procedure ExportFileToServerPath(ExportServerFileName: Text)
    var
        FileManagement: Codeunit "File Management";
        NewServerPathText: Text;
    begin
        NewServerPathText := FileManagement.CombinePath(GlobalSBCOEExportDefinition."Export Server Path", GlobalSBCOEExportDefinition.GetExportFileName());
#pragma warning disable AL0296
        FileManagement.CopyServerFile(ExportServerFileName, NewServerPathText, GlobalSBCOEExportDefinition."Export Overwrite");
#pragma warning restore AL0296
#pragma warning disable AL0296
        FileManagement.DeleteServerFile(ExportServerFileName);
#pragma warning restore AL0296
    end;
#endif
}
