/// <summary>
/// Codeunit SBCOE Import Management (ID 50066).
/// </summary>
codeunit 50066 "SBCOE Import Management"
{
    TableNo = "SBCOE Export Definition";
    trigger OnRun()
    var
        SpreadsheetOpeningErrorLabel: Label 'The spreadsheet template could not be opened.';
    begin
        // if not TrySetGlobals(Rec) then begin
        //     ThrowError(Rec, TrySetGlobalsErrorLabel);
        //     exit;
        // end;
        GlobalSBCOEExportDefinition := Rec;
        GlobalSBCOEExportDefinition.UploadFile();
        if not TryOpenSpreadsheetTemplate(GlobalTempExcelBuffer, '') then begin
            ThrowError(GlobalSBCOEExportDefinition, SpreadsheetOpeningErrorLabel);
            exit;
        end;
        ProcessImportDefinition(GlobalTempExcelBuffer); // Process Import Definition for Rows and Columns over Data Rows
        // CreateExport();
        // Rec := GlobalSBCOEExport;
    end;
    /// <summary>
    /// This procedure will try and open the spreadsheet template if it exists on the export definition.
    /// </summary>
    /// <param name="TempExcelBuffer">Temporary VAR Record "Excel Buffer".</param>
    [TryFunction]
    local procedure TryOpenSpreadsheetTemplate(var TempExcelBuffer: Record "Excel Buffer" temporary; OpenedSheetName: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        OpenXMLManagement: Codeunit "OpenXML Management";
        SpreadsheetTemplateInStream: InStream;
        FieldValueVariant: Variant;
        XLWrkSheetWriter: Variant;
    begin
        if not GlobalSBCOEExportDefinition."Spreadsheet Template".HasValue() then
            exit;
        GlobalSBCOEExportDefinition.CalcFields("Spreadsheet Template");
        GlobalSBCOEExportDefinition."Spreadsheet Template".CreateInStream(SpreadsheetTemplateInStream); //Make this an import definition with a sheet name.
        if OpenedSheetName = '' then
            OpenedSheetName := TempExcelBuffer.SelectSheetsNameStream(SpreadsheetTemplateInStream);
        if OpenedSheetName = '' then
            exit;
        TempExcelBuffer.OpenBookStream(SpreadsheetTemplateInStream, OpenedSheetName);

        TempExcelBuffer.ReadSheetContinous(OpenedSheetName, false);
        TempExcelBuffer.FindSet();
    end;

    local procedure ProcessRowDefinition(var TempExcelBuffer: Record "Excel Buffer" temporary; var SBCOEExportColumn: Record "SBCOE Export Column"; var SBCOEExportRow: Record "SBCOE Export Row")
    var
        ImportRecordRef: RecordRef;
        ImportFieldRef: FieldRef;
        ImportKeyRef: KeyRef;
        EndDataRowProcessing: Boolean;
        ExcelDataFound: Boolean;
        CurrentRowBlank: Boolean;
        SkipRowOnBlankValue: Boolean;
        NextRowDefinitionRowStart: Integer;
        CurrentRowDefinitionRowStart: Integer;
        KeyFieldCount: Integer;
    begin
        // Initialize column filters for row definition
        SBCOEExportColumn.SetRange("Export Definition Code", SBCOEExportRow."Export Definition Code");
        SBCOEExportColumn.SetRange("Row Definition Code", SBCOEExportRow."Row Definition Code");
        SBCOEExportColumn.SetFilter("From Table No.", '<>%1', 0);
        SBCOEExportColumn.SetFilter("Field ID", '<>%1', 0);
        // SBCOEExportColumn.SetFilter("Export Column No.", '<>%1', 0); // This is removed so that default text can be added for key fields.
        CurrentRowDefinitionRowStart := SBCOEExportRow."Row Start";

        if not TempExcelBuffer.GetAscending("Row No.") then
            TempExcelBuffer.SetAscending("Row No.", true);

        TempExcelBuffer.SetFilter("Row No.", '>=%1', CurrentRowDefinitionRowStart); // Each Row should be for one complete record so that we can assume the key is the same for all columns.                                                                         // Intialize 

        // if SBCOEExportRow.Next() <> 0 then begin
        //     NextRowDefinitionRowStart := SBCOEExportRow."Row Start";
        //     SBCOEExportRow.Next(-1);
        //     if (NextRowDefinitionRowStart - 1) > CurrentRowDefinitionRowStart then
        //         TempExcelBuffer.SetFilter("Row No.", '%1..%2', CurrentRowDefinitionRowStart, NextRowDefinitionRowStart - 1);
        // end;

        while not EndDataRowProcessing do begin
            if SBCOEExportColumn.FindSet() then begin
                ImportRecordRef.Open(SBCOEExportColumn."From Table No."); // Open Record (If the current )

                // Process (TODO: Separate in procedure)
                repeat // Iterate through the columns laterally
                    Clear(SkipRowOnBlankValue);
                    Clear(CurrentRowBlank);
                    // if TempExcelBuffer."Column No." <> SBCOEExportColumn."Export Column No." then

                    // if TempExcelBuffer."Row No." <= SBCOEExportRow."Row Start" then
                    TempExcelBuffer.SetRange("Column No.", SBCOEExportColumn."Export Column No.");
                    ExcelDataFound := TempExcelBuffer.FindFirst();
                    if not ExcelDataFound then begin
                        if SBCOEExportColumn."Export Column No." = 0 then
                            TempExcelBuffer."Column No." := 0;
                        TempExcelBuffer."Cell Value as Text" := SBCOEExportColumn."Default Text";
                        ExcelDataFound := (TempExcelBuffer."Cell Value as Text" <> '') or (not SBCOEExportColumn."Skip If Blank");
                        TempExcelBuffer.SetRange("Column No.");
                    end else begin
                        if SBCOEExportColumn."Blank Zero" and (TempExcelBuffer."Cell Value as Text" in ['0', '0.00']) then
                            TempExcelBuffer."Cell Value as Text" := '';
                        if SBCOEExportColumn."Blank Errors" and (TempExcelBuffer."Cell Value as Text" in ['#DIV/0!', '#N/A', '#NAME?', '#NULL!', '#NUM!', '#REF!', '#VALUE!', '#SPILL!', '#CALC!']) then
                            TempExcelBuffer."Cell Value as Text" := '';
                    end;


                    if ExcelDataFound then begin
                        SkipRowOnBlankValue := SBCOEExportColumn."Skip If Blank" and (TempExcelBuffer."Cell Value as Text" = '');
                        CurrentRowBlank := SkipRowOnBlankValue;
                        // Write Data to Field (TODO: Possibly apply number formatting rules)
                        ImportFieldRef := ImportRecordRef.Field(SBCOEExportColumn."Field ID");
                        if not TryEvaluate(TempExcelBuffer, ImportFieldRef) then;
                        if SBCOEExportColumn."Validate" then
                            if not TryValidate(ImportFieldRef) then;
                    end else
                        SkipRowOnBlankValue := SBCOEExportColumn."Skip If Blank";
                until (SBCOEExportColumn.Next() = 0) or SkipRowOnBlankValue;

                // Finalize
                if not SkipRowOnBlankValue then begin
                    ImportRecordRef.SetRecFilter();
                    if not SBCOEExportRow."Skip Blank Row Check" then begin
                        ImportKeyRef := ImportRecordRef.KeyIndex(ImportRecordRef.CurrentKeyIndex());
                        for KeyFieldCount := 1 to ImportKeyRef.FieldCount() do begin
                            CurrentRowBlank := CurrentRowBlank and (Format(ImportKeyRef.FieldIndex(KeyFieldCount).Value()).Trim() = '');
                            // KeyFieldCount += 1;
                        end;
                    end;

                    if not CurrentRowBlank then begin
                        if not ImportRecordRef.IsEmpty() then
                            ImportRecordRef.Modify()
                        else
                            ImportRecordRef.Insert();
                    end;
                end;

                ImportRecordRef.Close(); // The Excel Buffer can go until a blank row, which is the stop point for this particular row definition. It can also go a set number of rows until row-end. Another condition is it checks ahead a set number of rows for the next block of data, but this may not be needed.
            end else
                EndDataRowProcessing := true;

            // Determine if the definition is stil valid for the next row. 
            TempExcelBuffer.SetFilter("Row No.", '>=%1', TempExcelBuffer."Row No." + 1);
            if not EndDataRowProcessing then
                EndDataRowProcessing := not TempExcelBuffer.FindFirst(); // Iterate through the rows vertically
            if not EndDataRowProcessing and (SBCOEExportRow."Row End" <> 0) then
                EndDataRowProcessing := (TempExcelBuffer."Row No." >= SBCOEExportRow."Row End");
            // if not EndDataRowProcessing and (NextRowDefinitionRowStart <> 0) and (NextRowDefinitionRowStart <> SBCOEExportRow."Row Start") then // If the next row definition doesn't start on the same row as the current definition, then check if we are on or past the next row definition start.
            //     EndDataRowProcessing := (TempExcelBuffer."Row No." >= NextRowDefinitionRowStart);
            if not EndDataRowProcessing then
                CurrentRowDefinitionRowStart := TempExcelBuffer."Row No.";
        end;
    end;

    local procedure ProcessImportDefinition(var TempExcelBuffer: Record "Excel Buffer" temporary)
    var
        SBCOEExportColumn: Record "SBCOE Export Column";
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        SBCOEExportRow.SetRange("Export Definition Code", GlobalSBCOEExportDefinition."Export Definition Code");
        SBCOEExportRow.SetRange("Row Type", "SBCOE Row Type"::Detail);
        if SBCOEExportRow.IsEmpty() then
            exit;
        SBCOEExportRow.FindSet();
        repeat
            // Process Row Definition over Data Rows
            ProcessRowDefinition(TempExcelBuffer, SBCOEExportColumn, SBCOEExportRow);
        until SBCOEExportRow.Next() = 0;
    end;

    local procedure ThrowError(ErrorRecordVariant: Variant; ErrorText: Text)
    begin
        ThrowError(ErrorRecordVariant, ErrorText, ErrorTitleLabel);
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

    [TryFunction]
    local procedure TryValidate(var ImportFieldRef: FieldRef)
    begin
        ImportFieldRef.Validate();
    end;


    [TryFunction]
    local procedure TryEvaluate(var TempExcelBuffer: Record "Excel Buffer" temporary; var ImportFieldRef: FieldRef)
    begin
        Evaluate(ImportFieldRef, TempExcelBuffer."Cell Value as Text");
    end;

    var
        GlobalSBCOEExportDefinition: Record "SBCOE Export Definition";
        GlobalTempExcelBuffer: Record "Excel Buffer" temporary;
        ErrorTitleLabel: Label 'Excel Import Error';
}