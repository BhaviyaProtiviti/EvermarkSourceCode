table 50182 "SBCSR Query Line"
{
    Caption = 'SBCSR Query Line';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Query Code"; Code[20])
        {
            Caption = 'Query Code';
        }
        field(2; "Query Field Order"; Integer)
        {
            Caption = 'Query Field Order';
        }
        field(3; "Query Field API Name"; Text[40])
        {
            Caption = 'Query Field API Name';
        }
        field(4; "Query Field Description"; Text[250])
        {
            Caption = 'Query Field Description';
        }

        field(10; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;
            Description = 'This is the table that the returned values in the query will write to.';
            // InitValue = 'Sales Line';
            // TableRelation = "Table Metadata".Name;


            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
            begin
                SetFromTableNo();
            end;
        }
        field(11; "Field ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Field ID';
            Description = 'This is the ID of the field that will be used for this column.';
            MinValue = 0;
            TableRelation = Field."No." where(TableNo = field("Table No."));
            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                if not Field.Get(Rec."Table No.", "Field ID") then
                    exit;
                TypeHelper.TestFieldIsNotObsolete(Field);
                Rec.CalcFields("Field Name", "Field Caption");
            end;
        }
        field(12; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."),
                                                        "No." = field("Field ID")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."),
                                                              "No." = field("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'From Table No.';
            Description = 'Helper field';
            Editable = false;
            // InitValue = 37;
            MinValue = 0;
        }
        field(15; "Key Field"; Boolean)
        {
            CalcFormula = lookup(Field.IsPartOfPrimaryKey where(TableNo = field("Table No."),
                                                              "No." = field("Field ID")));
            Caption = 'Key Field';
            Editable = false;
            FieldClass = FlowField;
        }

        field(20; "Validate"; Boolean)
        {
            Caption = 'Validate';
            Description = 'If this is checked, the value imported for this definition will call validation logic set on the field being written to, if any.';
        }
        field(21; "Transformation Rule"; Code[20])
        {
            Caption = 'Transformation Rule';
            Description = 'This is the transformation rule that will be used for this column. It is applied before padding.';
            TableRelation = "Transformation Rule";
        }
        field(22; "Default Text"; Text[250])
        {
            Caption = 'Default Text';
            Description = 'This text will be used in place of a blank value.';
        }
        field(23; "Replace Blank with Default"; Boolean)
        {
            Caption = 'Replace Blank with Default';
            Description = 'If this is checked, the value in the Default Text field will be used in place of a blank or zero value.';
        }
        field(24; "Overwrite Existing"; Boolean)
        {
            Caption = 'Overwrite Existing';
            Description = 'When this is set, a field that already has a value will be overwritten if a new value is received from Specright..';
        }
        // field(10; "Table No."; Integer)
        // {
        //     Caption = 'Table No.';
        // }
        // field(11; "Field No."; Integer)
        // {
        //     Caption = 'Field No.';
        // }
        // field(12; Validate; Boolean)
        // {
        //     Caption = 'Validate';
        // }
    }
    keys
    {
        key(PK; "Query Code", "Query Field Order")
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
        if ValueRecordRef.Number() <> Rec."Table No." then
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
        Rec."Table No." := 0;
        TableMetadata.SetLoadFields(ID);
        TableMetadata.SetFilter(Name, '%1', Rec."Table Name");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.FindFirst();
        Rec."Table No." := TableMetadata.ID;
    end;
}