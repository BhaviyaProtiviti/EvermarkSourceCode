/// <summary>
/// This is a page part that is used to display the fields of the SBCOE Export Column table.;
/// </summary>
page 50066 "SBCOE Export Column Part"
{
    ApplicationArea = All;
    Caption = 'Export Column';
    Description = 'This is a page part that is used to display the fields of the SBCOE Export Column table.';
    PageType = ListPart;
    SourceTable = "SBCOE Export Column";
    DelayedInsert = true;

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
                    Visible = false;
                }
                field("Processing Order"; Rec."Processing Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'The order that a column in an import document is processed.';
                    Visible = GlobalImportTemplate;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("Export Column No."; Rec."Export Column No.")
                {
                    ApplicationArea = All;
                    Caption = 'Export Column No.';
                    ToolTip = 'This is the number of the column in the exported file.';
                }
                field(Validate; Rec.Validate)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, the value imported for this definition will call validation logic set on the field being written to, if any.';
                    Visible = GlobalImportTemplate;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("From Table"; Rec."From Table")
                {
                    ApplicationArea = All;
                    Caption = 'From Table';
                    ToolTip = 'This is the table that the field is from.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupTable();
                    end;
                }
                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    Caption = 'Field ID';
                    ToolTip = 'This is the ID of the field that will be used for this column.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField();
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    ToolTip = 'Specifies the value of the Field Name field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the value of the Field Caption field.';
                }
                field("Skip If Blank"; Rec."Skip If Blank")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, the column will be skipped if the value is a blank string. Useful for imports to key fields.';
                    Visible = GlobalImportTemplate;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("Blank Errors"; Rec."Blank Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, Errors like NA and Value will be treated as blanks.';
                    Visible = GlobalImportTemplate;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("Blank Zero"; Rec."Blank Zero")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, zeros will be treated as blanks.';
                    Visible = GlobalImportTemplate;
                    Editable = GlobalImportTemplate;
                    Enabled = GlobalImportTemplate;
                }
                field("Formula Text"; Rec."Formula Text")
                {
                    ApplicationArea = All;
                    Caption = 'Formula Text';
                    ToolTip = 'This text will be used as the formula for this column.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Comment Text"; Rec."Comment Text")
                {
                    ApplicationArea = All;
                    Caption = 'Comment Text';
                    ToolTip = 'This text will be used as a comment in the exported file.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Default Text"; Rec."Default Text")
                {
                    ApplicationArea = All;
                    Caption = 'Default Text';
                    Editable = GlobalNonFormulaFieldsEditable;
                    ToolTip = 'This text will be used in place of a blank value.';
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = All;
                    Caption = 'Formula';
                    ToolTip = 'If this is checked, the value in the Formula Text field will be used as the formula for this column.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Replace Blank with Default"; Rec."Replace Blank with Default")
                {
                    ApplicationArea = All;
                    Caption = 'Replace Blank with Default';
                    Editable = GlobalNonFormulaFieldsEditable;
                    ToolTip = 'If this is checked, the value in the Default Text field will be used in place of a blank or zero value.';
                }
                field(Bold; Rec.Bold)
                {
                    ApplicationArea = All;
                    Caption = 'Bold';
                    ToolTip = 'This will make the text in this column bold.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field(Italics; Rec.Italics)
                {
                    ApplicationArea = All;
                    Caption = 'Italics';
                    ToolTip = 'This will make the text in this column italic.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Double Underline"; Rec."Double Underline")
                {
                    ApplicationArea = All;
                    Caption = 'Double Underline';
                    ToolTip = 'This will make the text in this column double underlined.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Cell Type"; Rec."Cell Type")
                {
                    ApplicationArea = All;
                    Caption = 'Cell Type';
                    ToolTip = 'This is the type of cell that will be used for this column.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field(Underline; Rec.Underline)
                {
                    ApplicationArea = All;
                    Caption = 'Underline';
                    ToolTip = 'This will make the text in this column underlined.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Number Format"; Rec."Number Format")
                {
                    ApplicationArea = All;
                    Caption = 'Number Format';
                    ToolTip = 'This is the format that will be used for this column.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }
                field("Pad Length"; Rec."Pad Length")
                {
                    ApplicationArea = All;
                    Caption = 'Pad Length';
                    Editable = GlobalPaddingFieldsEditable;
                    ToolTip = 'This is the length of the padding that will be used for this column.';
                    Enabled = GlobalPaddingFieldsEditable;
                }
                field("Pad Type"; Rec."Pad Type")
                {
                    ApplicationArea = All;
                    Caption = 'Pad Type';
                    Editable = GlobalPaddingFieldsEditable;
                    ToolTip = 'This is the type of padding that will be used for this column. Defaults to blank.';
                    Enabled = GlobalPaddingFieldsEditable;
                }
                field("Pad Direction"; Rec."Pad Direction")
                {
                    ApplicationArea = All;
                    Caption = 'Pad Direction';
                    Editable = GlobalPaddingFieldsEditable;
                    ToolTip = 'This is the side of the text string that the padding will be placed on. Defaults to left.';
                    Enabled = GlobalPaddingFieldsEditable;
                }
                field("Pad Character"; Rec."Pad Character")
                {
                    ApplicationArea = All;
                    Caption = 'Pad Character';
                    Editable = GlobalPaddingFieldsEditable;
                    ToolTip = 'This is the character that will be used for the padding that will be used for this column.';
                    Enabled = GlobalPaddingFieldsEditable;
                }
                field("Transformation Rule"; Rec."Transformation Rule")
                {
                    ApplicationArea = All;
                    Caption = 'Transformation Rule';
                    Editable = GlobalNonFormulaFieldsEditable;
                    ToolTip = 'This is the transformation rule that will be used for this column. It is applied before padding.';
                }
                field("Allow Substitution"; Rec."Allow Substitution")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is checked, substitution will be allowed for this column.';
                    Editable = not GlobalImportTemplate;
                    Enabled = not GlobalImportTemplate;
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GlobalNonFormulaFieldsEditable := not Rec.Formula;
        GlobalPaddingFieldsEditable := not (Rec.Formula or not (Rec."Cell Type".AsInteger() = Enum::"SBCOE Cell Types"::Text.AsInteger())) and not GlobalImportTemplate;
    end;

    var
        GlobalNonFormulaFieldsEditable: Boolean;
        GlobalImportTemplate: Boolean;
        GlobalPaddingFieldsEditable: Boolean;

    local procedure LookupField()
    var
        "Field": Record "Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldSelection: Codeunit "Field Selection";
    begin
        ConfigPackageMgt.SetFieldFilter(Field, Rec."From Table No.", 0);
        if not FieldSelection.Open(Field) then
            exit;
        Rec.Validate("Field ID", Field."No.");
        CurrPage.Update(true);
    end;

    local procedure LookupTable()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TableObjects: Page "Table Objects";

    begin
        TableObjects.LookupMode(true);
        if not (Action::LookupOK = TableObjects.RunModal()) then
            exit;
        TableObjects.SetSelectionFilter(AllObjWithCaption);
        TableObjects.GetRecord(AllObjWithCaption);
        Rec.Validate("From Table", AllObjWithCaption."Object Name");
        CurrPage.Update(true);
    end;

    internal procedure SetGlobalImportTemplate(ImportTemplate: Boolean)
    begin
        GlobalImportTemplate := ImportTemplate;
        CurrPage.Update(false);
    end;
}
