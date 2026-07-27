/// <summary>
/// This page part is used to define the rows of the export.
/// </summary>
page 50065 "SBCOE Export Row Part"
{
    ApplicationArea = All;
    Caption = 'Export Row';
    Description = 'This page part is used to define the rows of the export.';
    PageType = ListPart;
    SourceTable = "SBCOE Export Row";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Export Definition Code"; Rec."Export Definition Code")
                {
                    ApplicationArea = All;
                    Caption = 'Export Definition Code';
                    ToolTip = 'The code of the export definition.';
                    Visible = false;
                }
                field("Row Definition Code"; Rec."Row Definition Code")
                {
                    ApplicationArea = All;
                    Caption = 'Row Definition Code';
                    ToolTip = 'The code of the row definition.';
                }
                field("Row Type"; Rec."Row Type")
                {
                    ApplicationArea = All;
                    Caption = 'Row Type';
                    ToolTip = 'The type of row.';
                }
                field("Row Order"; Rec."Row Order")
                {
                    ApplicationArea = All;
                    Caption = 'Row Order';
                    ToolTip = 'The order of the row in the export.';
                    Visible = true;
                }
                field("Row Start"; Rec."Row Start")
                {
                    ApplicationArea = All;
                    Caption = 'Row Start';
                    ToolTip = 'This row definition will be started from this row number or greater';
                    Visible = true;
                }
                field("Row End"; Rec."Row End")
                {
                    ApplicationArea = All;
                    Caption = 'Row End';
                    ToolTip = 'This row definition will be ended at this row number or less. If this is blank, the import will continue until a blank row is found. Leave this blank for imports if you want row spacing applied after a block of data .';
                    Visible = true;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("Skip Blank Row Check"; Rec."Skip Blank Row Check")
                {
                    ApplicationArea = All;
                    ToolTip = 'If checked, the import process will not attempt to check if a key is completely blank before writing to a table. Zero is not considered blank.';
                    Visible = true;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("Row Spacing"; Rec."Row Spacing") // This may be useable for imports that have a set number of spaces between sections.
                {
                    ApplicationArea = All;
                    Caption = 'Row Spacing';
                    ToolTip = 'This number of rows that must be between this row definition and the last data written before it. Row spacing is applied before Row start.';
                    Visible = true;
                }
                field("Row Description"; Rec."Row Description")
                {
                    ApplicationArea = All;
                    Caption = 'Row Description';
                    ToolTip = 'The description of the row.';
                    Visible = true;
                }
                field("Info Sheet"; Rec."Info Sheet")
                {
                    ApplicationArea = All;
                    Caption = 'Info Sheet';
                    ToolTip = 'If checked, this row will be included in the Info Sheet.';
                    Visible = false;
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
            }
        }
    }

    var
        GlobalImportTemplate: Boolean;

    internal procedure SetGlobalImportTemplate(ImportTemplate: Boolean)
    begin
        GlobalImportTemplate := ImportTemplate;
        CurrPage.Update(false);
    end;
}
