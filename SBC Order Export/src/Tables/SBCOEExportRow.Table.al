/// <summary>
///  This table contains the row definitions for the export.
/// </summary>
table 50063 "SBCOE Export Row"
{
    Caption = 'Export Row Definitions';
    DataClassification = CustomerContent;
    Description = 'This table contains the row definitions for the export.';
    DrillDownPageId = "SBCOE Export Row Part";
    LookupPageId = "SBCOE Export Row Part";

    fields
    {
        field(1; "Export Definition Code"; Code[20])
        {
            Caption = 'Export Definition Code';
            Description = 'The code of the export definition.';
        }
        field(2; "Row Definition Code"; Code[20])
        {
            Caption = 'Row Definition Code';
            Description = 'The code of the row definition.';
        }
        field(3; "Row Type"; Enum "SBCOE Row Type")
        {
            BlankZero = true;
            Caption = 'Row Type';
            Description = 'The type of row.';
        }
        field(4; "Row Description"; Text[200])
        {
            Caption = 'Row Description';
            Description = 'The description of the row.';
        }
        field(5; "Row Order"; Integer)
        {
            BlankZero = true;
            Caption = 'Row Order';
            Description = 'The order of the row in the export.';
        }
        field(6; "Info Sheet"; Boolean)
        {
            Caption = 'Info Sheet';
            Description = 'If checked, this row will be included in the Info Sheet.';
        }
        field(7; "Row Start"; Integer)
        {
            BlankZero = true;
            Caption = 'Row Start';
            Description = 'This row definition will be started from this row number or greater';
        }
        field(8; "Row Spacing"; Integer)
        {
            BlankZero = true;
            Caption = 'Row Spacing';
            Description = 'This number of rows that must be between this row definition and the last data written before it. Row spacing is applied before Row start.';
        }
        field(9; "Row End"; Integer)
        {
            BlankZero = true;
            Caption = 'Row End';
            Description = 'This row definition will be ended at this row number or less. If this is blank, the import will continue until a blank row is found.';
        }
        field(10; "Skip Blank Row Check"; Boolean)
        {
            Caption = 'Skip Blank Row Check';
            Description = 'If checked, the import process will not attempt to check if a key is completely blank before writing to a table. Zero is not considered blank.';
        }

    }
    keys
    {
        key(PK; "Export Definition Code", "Row Definition Code")
        {
            Clustered = true;
        }
        key(RowOrder; "Row Type", "Row Order")
        {
            Description = 'Filtering and Sorting key.';
        }
    }
    trigger OnDelete()
    begin
        DeleteColumns();
    end;

    trigger OnRename()
    begin
        RenameColumns();
    end;

    internal procedure SetColumnFilters(var SBCOEExportColumn: Record "SBCOE Export Column")
    begin
        SBCOEExportColumn.SetRange("Export Definition Code", Rec."Export Definition Code");
        SBCOEExportColumn.SetRange("Row Definition Code", Rec."Row Definition Code");
    end;

    local procedure DeleteColumns()
    var
        SBCOEExportColumn: Record "SBCOE Export Column";
    begin
        SetColumnFilters(SBCOEExportColumn);
        if SBCOEExportColumn.IsEmpty() then
            exit;
        SBCOEExportColumn.DeleteAll(true);
    end;

    local procedure RenameColumns()
    var
        SBCOEExportColumn: Record "SBCOE Export Column";
    begin
        SetColumnFilters(SBCOEExportColumn);
        if SBCOEExportColumn.IsEmpty() then
            exit;
        SBCOEExportColumn.FindSet(true);
        repeat
            SBCOEExportColumn.Rename(Rec."Export Definition Code", Rec."Row Definition Code", SBCOEExportColumn."Processing Order", SBCOEExportColumn."Export Column No.");
        until SBCOEExportColumn.Next() = 0;
    end;
}
