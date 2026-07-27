/// <summary>
/// Table Vena Job Setup Line (ID 50258).
/// </summary>
table 50258 "SBC Vena Job Setup Line"
{
    Caption = 'Vena Job Setup Line';
    DataClassification = CustomerContent;
    DrillDownPageId = "SBC Vena Job Setup Lines";
    LookupPageId = "SBC Vena Job Setup Lines";

    fields
    {
        field(1; "Vena Job Code"; Code[20])
        {
            Caption = 'Vena Job Code';
        }
        field(2; "ERP Table ID"; Integer)
        {
            Caption = 'ERP Table ID';
        }
        field(3; "Column No."; Integer)
        {
            Caption = 'Column No.';
        }
        field(4; "ERP Field Name"; Text[30])
        {

            Caption = 'ERP Field Name';
            CalcFormula = lookup(Field.FieldName where(TableNo = field("ERP Table ID"),
                                                        "No." = field("ERP Field ID")));
            FieldClass = FlowField;

        }
        field(5; "ERP Field ID"; Integer)
        {
            BlankZero = true;
            Caption = 'ERP Field ID';
            MinValue = 0;
            TableRelation = Field."No." where(TableNo = field("ERP Table ID"));
            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                if not Field.Get(Rec."ERP Table ID", "ERP Field ID") then
                    exit;
                TypeHelper.TestFieldIsNotObsolete(Field);
                Rec.CalcFields("ERP Field Name");
            end;
        }
        field(6; "Default Value"; Text[200])
        {
            Caption = 'Default Value';
        }
        field(10; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(20; "ERP Link Table Name"; Text[30])
        {
            Caption = 'ERP Link Table Name';
            trigger OnValidate()
            begin
                SetERPLinkTableID();
            end;
        }
        field(21; "ERP Link Table ID"; Integer)
        {
            Caption = 'ERP Link Table ID';
        }
        field(22; "ERP Link Table Filter"; Blob)
        {
            Caption = 'ERP Link Table Filter';
        }
        field(23; "ERP Link Field ID"; Integer)
        {
            BlankZero = true;
            Caption = 'ERP Link Field ID';
            MinValue = 0;
            TableRelation = Field."No." where(TableNo = field("ERP Link Table ID"));
            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                if not Field.Get(Rec."ERP Link Table ID", "ERP Link Field ID") then
                    exit;
                TypeHelper.TestFieldIsNotObsolete(Field);
                Rec.CalcFields("ERP Link Field Name");
            end;
        }
        field(24; "ERP Link Field Name"; Text[30])
        {

            Caption = 'ERP Link Field Name';
            CalcFormula = lookup(Field.FieldName where(TableNo = field("ERP Link Table ID"),
                                                        "No." = field("ERP Link Field ID")));
            FieldClass = FlowField;

        }

    }
    keys
    {
        key(PK; "Vena Job Code", "ERP Table ID", "Column No.")
        {
            Clustered = true;
        }
    }
    var
        ErpLinkTableNameErrorLabel: Label 'ERP Link Table Name must be set before setting the filter.';
    /// <summary>
    /// Returns the default value if no ERP field is mapped or if a text field is empty.
    /// </summary>
    /// <param name="ValueRecordRef">RecordRef.</param>
    /// <returns>Return variable FieldValue of type Variant.</returns>
    internal procedure GetFieldValue(ValueRecordRef: RecordRef) FieldValue: Text
    var
        ValueFieldRef: FieldRef;
    begin
        FieldValue := Rec."Default Value";
        if Rec."ERP Field ID" = 0 then
            exit;
        case true of
            ValueRecordRef.Number() = REc."ERP Table ID":
                ValueFieldRef := ValueRecordRef.Field(Rec."ERP Field ID");
            ValueRecordRef.Number() = Rec."ERP Link Table ID":
                ValueFieldRef := ValueRecordRef.Field(Rec."ERP Link Field ID");
            else
                exit;
        end;
        if ValueFieldRef.Class = FieldClass::FlowField then
            ValueFieldRef.CalcField();
        if not TryEvaluateValue(ValueRecordRef, FieldValue) then
            FieldValue := Format(ValueFieldRef.Value);
        if not (ValueFieldRef.Type in [FieldType::Text, FieldType::Code]) then
            exit;
        if Format(FieldValue) = '' then
            FieldValue := Rec."Default Value";
    end;

    [TryFunction]

    local procedure TryEvaluateValue(var ValueRecordRef: RecordRef; var FieldValue: Text)
    begin
        Evaluate(FieldValue, ValueRecordRef.Field(Rec."ERP Field ID").Value);
    end;

    local procedure SetERPLinkTableID()
    var
        TableMetadata: Record "Table Metadata";
    begin
        Rec."ERP Link Table ID" := 0;
        TableMetadata.SetLoadFields(ID);
        TableMetadata.SetFilter(Name, '%1', Rec."ERP Link Table Name");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.FindFirst();
        Rec."ERP Link Table ID" := TableMetadata.ID;
    end;

    internal procedure UpdateERPTableFilter(ErpTableNo: Integer) NewErpTableFilter: Text
    var
        ErpTableRecordRef: RecordRef;
        VenaFilterPageBuilder: FilterPageBuilder;
        ERPFilterTextInStream: InStream;
        ErpTableFilterOutStream: OutStream;
        CurrentERPFilterText: Text;
        ExistingErpTableFilter: Text;
        CurrentERPFilterTextBuilder: TextBuilder;
    begin
        if Rec."ERP Link Table ID" = 0 then
            Error(ErrorInfo.Create(ErpLinkTableNameErrorLabel, false, Rec, Rec.FieldNo("ERP Link Table Name")));
        Rec.CalcFields("ERP Link Table Filter");
        if Rec."ERP Link Table Filter".HasValue() then begin
            Rec."ERP Link Table Filter".CreateInStream(ERPFilterTextInStream);
            while not ERPFilterTextInStream.EOS do begin
                ERPFilterTextInStream.ReadText(CurrentERPFilterText);
                CurrentERPFilterTextBuilder.Append(CurrentERPFilterText);
            end;
            ExistingErpTableFilter := CurrentERPFilterTextBuilder.ToText();
        end;
        ErpTableRecordRef.Open(ErpTableNo);
        VenaFilterPageBuilder.AddRecordRef(ErpTableRecordRef.Name(), ErpTableRecordRef);
        if ExistingErpTableFilter <> '' then
            VenaFilterPageBuilder.SetView(ErpTableRecordRef.Name(), ExistingErpTableFilter);
        if not VenaFilterPageBuilder.RunModal() then
            exit;
        NewErpTableFilter := VenaFilterPageBuilder.GetView(ErpTableRecordRef.Name());
        Clear(Rec."ERP Link Table Filter");
        Rec.CalcFields("ERP Link Table Filter");
        Rec."ERP Link Table Filter".CreateOutStream(ErpTableFilterOutStream);
        ErpTableFilterOutStream.WriteText(NewErpTableFilter);
        Rec.Modify(true);
    end;
}