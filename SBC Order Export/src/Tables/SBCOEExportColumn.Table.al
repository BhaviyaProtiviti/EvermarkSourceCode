/// <summary>
/// Table SBCOE Column Definition (ID 50064). This table contains the column definitions for the SBCOE Export Definition.
/// </summary>
table 50064 "SBCOE Export Column"
{
    Caption = 'SBCOE Column Definition';
    DataClassification = CustomerContent;
    Description = 'This table contains the column definitions for the SBCOE Export Definition.';
    DrillDownPageId = "SBCOE Export Column Part";
    LookupPageId = "SBCOE Export Column Part";

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
        field(3; "Export Column No."; Integer)
        {
            BlankZero = false;
            Caption = 'Export Column No.';
            Description = 'This is the number of the column in the exported file.';
        }
        field(4; Formula; Boolean)
        {
            Caption = 'Formula';
            Description = 'If this is checked, the value in the Formula Text field will be used as the formula for this column.';
        }
        field(5; "Comment Text"; Text[250])
        {
            Caption = 'Comment Text';
            Description = 'This text will be used as a comment in the exported file.';
        }
        field(6; "Default Text"; Text[250])
        {
            Caption = 'Default Text';
            Description = 'This text will be used in place of a blank value.';
        }
        field(7; "Replace Blank with Default"; Boolean)
        {
            Caption = 'Replace Blank with Default';
            Description = 'If this is checked, the value in the Default Text field will be used in place of a blank or zero value.';
        }
        field(8; "Formula Text"; Text[1000])
        {
            Caption = 'Formula Text';
            Description = 'This text will be used as the formula for this column.';
            trigger OnValidate()
            begin
                ToggleFormula();
            end;
        }
        field(9; "Cell Type"; Enum "SBCOE Cell Types")
        {
            Caption = 'Cell Type';
            Description = 'This is the type of cell that will be used for this column.';
            InitValue = Text;
        }
        field(10; "Number Format"; Text[30])
        {
            Caption = 'Number Format';
            Description = 'This is the format that will be used for this column.';
        }
        field(11; Bold; Boolean)
        {
            Caption = 'Bold';
            Description = 'This will make the text in this column bold.';
        }
        field(12; Italics; Boolean)
        {
            Caption = 'Italics';
            Description = 'This will make the text in this column italic.';
        }
        field(13; Underline; Boolean)
        {
            Caption = 'Underline';
            Description = 'This will make the text in this column underlined.';
        }
        field(14; "Double Underline"; Boolean)
        {
            Caption = 'Double Underline';
            Description = 'This will make the text in this column double underlined.';
        }
        field(15; "From Table"; Text[30])
        {
            Caption = 'From Table';
            DataClassification = CustomerContent;
            Description = 'This is the table that the field is from.';
            InitValue = 'Sales Line';
            // TableRelation = "Table Metadata".Name;


            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
            begin
                SetFromTableNo();
            end;
        }
        field(16; "Field ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Field ID';
            Description = 'This is the ID of the field that will be used for this column.';
            MinValue = 0;
            TableRelation = Field."No." where(TableNo = field("From Table No."));
            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                if not Field.Get(Rec."From Table No.", "Field ID") then
                    exit;
                TypeHelper.TestFieldIsNotObsolete(Field);
                Rec.CalcFields("Field Name", "Field Caption");
            end;
        }
        field(17; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("From Table No."),
                                                        "No." = field("Field ID")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; "Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("From Table No."),
                                                              "No." = field("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "From Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'From Table No.';
            Description = 'Helper field';
            Editable = false;
            InitValue = 37;
            MinValue = 0;
        }
        field(30; "Pad Type"; Enum "SBCOE Pad Type")
        {
            Caption = 'Pad Type';
            Description = 'This is the type of padding that will be used for this column.';
            InitValue = " ";
        }
        field(31; "Pad Direction"; Enum "SBCOE Pad Direction")
        {
            Caption = 'Pad Direction';
            Description = 'This is the direction of the padding that will be used for this column.';
            InitValue = " ";
        }
        field(32; "Pad Length"; Integer)
        {
            BlankZero = true;
            Caption = 'Pad Length';
            Description = 'This is the length of the padding that will be used for this column.';
            MinValue = 0;
        }
        field(33; "Pad Character"; Text[1])
        {
            Caption = 'Pad Character';
            Description = 'This is the character that will be used for the padding that will be used for this column.';
        }
        field(40; "Transformation Rule"; Code[20])
        {
            Caption = 'Transformation Rule';
            Description = 'This is the transformation rule that will be used for this column. It is applied before padding.';
            TableRelation = "Transformation Rule";
        }
        field(50; "Allow Substitution"; Boolean)
        {
            Caption = 'Allow Substitution';
            Description = 'If this is checked, substitution will be allowed for this column.';
        }
        field(60; "Skip If Blank"; Boolean)
        {
            Caption = 'Skip If Blank';
            Description = 'If this is checked, the column will be skipped if the value is a blank string. Useful for imports to key fields.';
        }

        field(61; "Processing Order"; Integer)
        {
            BlankZero = false;
            Caption = 'Processing Order';
            Description = 'The order that a column in an import document is processed.';
        }
        field(62; "Validate"; Boolean)
        {
            Caption = 'Validate';
            Description = 'If this is checked, the value imported for this definition will call validation logic set on the field being written to, if any.';
        }
        field(63; "Blank Zero"; Boolean)
        {
            Caption = 'Blank Zero';
            Description = 'If this is checked, zeros will be treated as blanks.';
        }
        field(64; "Blank Errors"; Boolean)
        {
            Caption = 'Blank Errors';
            Description = 'If this is checked, Errors like NA and Value will be treated as blanks.';
        }
    }
    keys
    {
        key(PK; "Export Definition Code", "Row Definition Code", "Processing Order", "Export Column No.")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// GetFieldValue. This function will return the value of the field in the record.
    /// </summary>
    /// <param name="ValueRecordRef">RecordRef.</param>
    /// <returns>Return variable FieldValue of type Variant.</returns>
    internal procedure GetFieldValue(ValueRecordRef: RecordRef) FieldValue: Variant
    begin
        FieldValue := '';
        if Rec."Field ID" = 0 then
            exit;
        if ValueRecordRef.Number() <> Rec."From Table No." then
            exit;
        FieldValue := ValueRecordRef.Field(Rec."Field ID").Value;
    end;

    /// <summary>
    /// This trigger will set the From Table No. field based on the value in the From Table field.
    /// </summary>
    local procedure SetFromTableNo()
    var
        TableMetadata: Record "Table Metadata";
    begin
        Rec."From Table No." := 0;
        TableMetadata.SetLoadFields(ID);
        TableMetadata.SetFilter(Name, '%1', Rec."From Table");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.FindFirst();
        Rec."From Table No." := TableMetadata.ID;
    end;

    /// <summary>
    /// This trigger will toggle the Formula field based on the value in the Formula Text field.
    /// </summary>
    local procedure ToggleFormula()
    begin
        if xRec."Formula Text" = Rec."Formula Text" then
            exit;
        Rec.Formula := Rec."Formula Text" <> '';
    end;
}
