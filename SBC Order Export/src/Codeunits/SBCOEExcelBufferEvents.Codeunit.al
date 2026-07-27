/// <summary>
/// This codeunit is used to resize columns in the Excel Buffer based on the longest text value in each column. It is designed to be bound (toggled on) by actions from the SBCOE Export Management codeunit.
/// </summary>
codeunit 50062 "SBCOE Excel Buffer Events"
{
    Description = 'This codeunit is used to resize columns in the Excel Buffer based on the longest text value in each column. It is designed to be bound (toggled on) by actions from the SBCOE Export Management codeunit.';
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        GlobalSBCOEExcelBufferEvents: Codeunit "SBCOE Excel Buffer Events";
        GlobalBound: Boolean;
        GlobalMaxColumnWidthDictionary: Dictionary of [Text[10], Decimal];
        DefaultExcelColumnWidthLabel: Label '8', Locked = true;

    internal procedure Bind()
    begin
        if IsBound() then
            exit;

        GlobalBound := BindSubscription(GlobalSBCOEExcelBufferEvents);
    end;

    internal procedure IsBound(): Boolean
    begin
        exit(GlobalBound);
    end;

    /// <summary>
    /// Resizes Excel Columns in the workbook based on each column's longest text value. This procedure also unbinds the subscriber codeunit and clears the global variables in use.
    /// </summary>
    /// <param name="ExcelBuffer"></param>
    internal procedure ResizeColumns(var ExcelBuffer: Record "Excel Buffer")
    var
        ColumnID: Text;
    begin
        foreach ColumnID in GlobalMaxColumnWidthDictionary.Keys() do
            ExcelBuffer.SetColumnWidth(ColumnID, GlobalMaxColumnWidthDictionary.Get(ColumnID));

        Unbind();
    end;

    internal procedure Unbind()
    begin
        Unbind(false);
    end;

    /// <summary>
    /// Unbinding with force ignores the value of IsBound so that the binding of this codeunit can be disabled in the event that an error prevented IsBound from being properly unset.
    /// </summary>
    /// <param name="Force"></param>
    internal procedure Unbind(Force: Boolean)
    begin
        if not Force then
            if not IsBound() then
                exit;

        if not UnbindSubscription(GlobalSBCOEExcelBufferEvents) then
            if not Force then
                exit;

        ClearGlobals();
    end;

    local procedure ClearGlobals()
    begin
        Clear(GlobalBound);
        Clear(GlobalMaxColumnWidthDictionary);
    end;

    /// <summary>
    /// If the Cell being written has a text length that's longer than the previous longest value for the column, it is written to the dictionary.
    /// </summary>
    /// <param name="ExcelBuffer"></param>
    /// <param name="CellValueAsText"></param>
    local procedure UpdateMaxColumnWidthDictionary(var ExcelBuffer: Record "Excel Buffer"; CellValueAsText: Text)
    var
        CurrentColumnMaxWidth: Decimal;
        NewColumnTextWidth: Integer;
    begin
        Evaluate(CurrentColumnMaxWidth, DefaultExcelColumnWidthLabel);

        NewColumnTextWidth := StrLen(CellValueAsText);

        // Create the column if it does not exist with the default max width

        if not GlobalMaxColumnWidthDictionary.ContainsKey(ExcelBuffer.xlColID) then
            GlobalMaxColumnWidthDictionary.Add(ExcelBuffer.xlColID, CurrentColumnMaxWidth);

        GlobalMaxColumnWidthDictionary.Get(ExcelBuffer.xlColID, CurrentColumnMaxWidth);

        if NewColumnTextWidth > CurrentColumnMaxWidth then
            GlobalMaxColumnWidthDictionary.Set(ExcelBuffer.xlColID, NewColumnTextWidth);
    end;

    /// <summary>
    ///  This procedure will update the column width dictionary if a cell value is updated rather than written in with a column on a new row. Only the maxiumn text width is retained for use in resizing the column.
    /// </summary>
    /// <param name="ExcelBuffer"></param>
    /// <param name="CellTextValue"></param>
    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", 'OnWriteCellValueOnBeforeSetCellValue', '', false, false)]
    local procedure OnWriteCellValueOnBeforeSetCellValue(var ExcelBuffer: Record "Excel Buffer"; var CellTextValue: Text)
    begin
        UpdateMaxColumnWidthDictionary(ExcelBuffer, CellTextValue);
    end;

    /// <summary>
    /// This procedure will update the column width dictionary after each column is written. Only the maxiumn text width is retained for use in resizing the column.
    /// </summary>
    /// <param name="ExcelBuffer"></param>
    /// <param name="Value"></param>
    /// <param name="IsFormula"></param>
    /// <param name="CommentText"></param>
    /// <param name="IsBold"></param>
    /// <param name="IsItalics"></param>
    /// <param name="IsUnderline"></param>
    /// <param name="NumFormat"></param>
    /// <param name="CellType"></param>
    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", 'OnAfterAddColumnToBuffer', '', false, false)]
    local procedure UpdateColumnWidthDictionary(var ExcelBuffer: Record "Excel Buffer"; Value: Variant; IsFormula: Boolean; CommentText: Text; IsBold: Boolean; IsItalics: Boolean; IsUnderline: Boolean; NumFormat: Text[30]; CellType: Option)
    begin
        UpdateMaxColumnWidthDictionary(ExcelBuffer, ExcelBuffer."Cell Value as Text");
    end;

    /// <summary>
    /// Called after the first XML column is written.
    /// </summary>
    /// <param name="TempExcelBuffer"></param>
    [EventSubscriber(ObjectType::Table, Database::"Excel Buffer", 'OnWriteCellValueOnBeforeSetCellValue', '', false, false)]
    local procedure UpdateExcelColumnWidthsGeneric(var ExcelBuffer: Record "Excel Buffer"; var CellTextValue: Text)
    begin
        ResizeColumns(ExcelBuffer);
    end;
}
