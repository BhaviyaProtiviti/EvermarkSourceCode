/// <summary>
/// Table SBC Page Control (ID 50204).
/// </summary>
table 50250 "SBCPC Page Control"
{
    Caption = 'Table Filter';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Table Number"; Integer)
        {
            Caption = 'Table Number';
            Editable = false;
            MinValue = 0;
            BlankZero = true;
        }

        field(3; "Field Number"; Integer)
        {
            Caption = 'Field Number';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table Number"));
            MinValue = 0;
            BlankZero = true;

            trigger OnLookup()
            begin
                LookupField();
            end;
            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                if xRec."Field Number" = "Field Number" then
                    exit;

                Field.Get("Table Number", "Field Number");
                TypeHelper.TestFieldIsNotObsolete(Field);
                CheckDuplicateField(Field);

                "Field Caption" := Field."Field Caption";
                "Field Filter" := '';
            end;
        }
        field(4; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            TableRelation = AllObjWithCaption."Object Name" where("Object Type" = const(Table));
            trigger OnLookup()
            begin
                LookupTable();
            end;

            trigger OnValidate()
            begin
                SetTableNo();
            end;
        }
        field(6; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table Number"),
                                                        "No." = field("Field Number")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table Number"),
                                                              "No." = field("Field Number")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Field Filter"; Text[1024])
        {
            Caption = 'Field Filter';
            trigger OnValidate()
            begin
                ValidateFieldFilter(Rec."Table Number", Rec."Field Number", Rec."Field Filter");
            end;
        }
    }

    keys
    {
        key(Key1; "Table Number", "User ID", "Field Number")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'The filter for the field %1 %2 already exists.', Comment = 'The filter for the field <Field Number> <Field Name> already exists. Example: The filter for the field 15 Base Unit of Measure already exists.';

    /// <summary>
    /// CheckDuplicateField.
    /// </summary>
    /// <param name="Field">Record "Field".</param>
    local procedure CheckDuplicateField("Field": Record "Field")
    var
        SBCPageControl: Record "SBCPC Page Control";
    begin
        SBCPageControl.Copy(Rec);
        Reset();
        SetRange("Table Number", Field.TableNo);
        SetRange("Field Number", Field."No.");
        SetFilter("User ID", '%1', Rec."User ID");
        if not IsEmpty() then
            Error(Text001, Field."No.", Field."Field Caption");
        Copy(SBCPageControl);
    end;


    local procedure ValidateFieldFilter(TableNo: Integer; FieldNo: Integer; FieldFilter: Text[1024])
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open(TableNo);
        if FieldFilter <> '' then begin
            FieldRef := RecRef.Field(FieldNo);
            FieldRef.SetFilter(FieldFilter);
        end;
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
        Rec.Validate("Table Name", AllObjWithCaption."Object Name");
        // CurrPage.Update(true);
    end;

        local procedure LookupField()
    var
        "Field": Record "Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldSelection: Codeunit "Field Selection";
    begin
        ConfigPackageMgt.SetFieldFilter(Field, Rec."Table Number", 0);
        if not FieldSelection.Open(Field) then
            exit;
        Rec.Validate("Field Number", Field."No.");
        // CurrPage.Update(true);
    end;

    local procedure SetTableNo()
    var
        TableMetadata: Record "Table Metadata";
    begin
        Rec."Table Number" := 0;
        TableMetadata.SetLoadFields(ID);
        TableMetadata.SetFilter(Name, '%1', Rec."Table Name");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.FindFirst();
        Rec."Table Number" := TableMetadata.ID;
    end;
}

