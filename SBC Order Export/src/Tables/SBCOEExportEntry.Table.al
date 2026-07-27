/// <summary>
/// This table contains the list of all the entries that are exported to the SBCOE system.
/// </summary>
table 50066 "SBCOE Export Entry"
{
    Caption = 'SBCOE Export Entry';
    DataClassification = SystemMetadata;
    Description = 'This table contains the list of all the entries that are exported to the SBCOE system.';
    DrillDownPageId = "SBCOE Export Entries Part";
    LookupPageId = "SBCOE Export Entries Part";
    fields
    {
        field(1; "Export Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Export Entry No.';
        }
        field(3; "Export Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Export Table No.';
            trigger OnValidate()
            begin
                SetTableName();
            end;
        }
        field(4; "Export System ID"; Guid)
        {
            Caption = 'Export System ID';
        }
        field(2; "Export Document Key"; Code[20])
        {
            Caption = 'Export Document No.';
            DataClassification = OrganizationIdentifiableInformation;
            Description = 'The document number of the record that is included in the export.';
        }
        field(5; "Export Table Name"; Text[30])
        {
            Caption = 'Export Table Name';
            DataClassification = CustomerContent;
        }
        field(6; "Row Type"; Enum "SBCOE Row Type")
        {
            BlankZero = true;
            Caption = 'Export Row Type';
            Description = 'The row type the data in the export record is used for.';
        }
    }
    keys
    {
        key(PK; "Export Entry No.", "Export Table No.", "Export System ID")
        {
            Clustered = true;
        }
    }

    var
        RecordNotFoundBySysIdErrorLabel: Label 'Record could not be located by system ID.';
        RecordNotFoundErrorTitleLabel: Label 'Record not found';

    internal procedure GetRecordIDFromSystemID() ExportRecordId: RecordId
    var
        ExportRecordRef: RecordRef;
    begin
        if not TryGetRecordRefFromSystemId(ExportRecordRef) then
            exit;
        ExportRecordId := ExportRecordRef.RecordId();
    end;

    internal procedure ViewRecord()
    var
        PageManagement: Codeunit "Page Management";
        ExportRecordRef: RecordRef;
        IsHandled: Boolean;
        PageId: Integer;
    begin
        OnBeforeOpenPage(Rec, IsHandled);
        if IsHandled then
            exit;
        if not TryGetRecordRefFromSystemId(ExportRecordRef) then
            exit;
        PageManagement.PageRun(ExportRecordRef);
    end;

    local procedure SetTableName()
    var
        TableMetadata: Record "Table Metadata";
    begin
        Rec."Export Table Name" := '';
        TableMetadata.SetRange(ID, Rec."Export Table No.");
        if TableMetadata.IsEmpty() then
            exit;
        TableMetadata.SetLoadFields(Name);
        TableMetadata.FindFirst();
        Rec."Export Table Name" := TableMetadata.Name
    end;

    [TryFunction]
    local procedure TryGetRecordRefFromSystemId(var ExportRecordRef: RecordRef)
    var
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        CouldNotLocateRecordErrorInfo: ErrorInfo;
    begin
        ExportRecordRef.Open(Rec."Export Table No.");
        if ExportRecordRef.GetBySystemId(Rec."Export System ID") then
            exit;
        CouldNotLocateRecordErrorInfo := SBCOEErrorHelper.CreateCollectableErrorInfo(Rec.RecordId().GetRecord(), RecordNotFoundBySysIdErrorLabel, RecordNotFoundErrorTitleLabel);
        Error(CouldNotLocateRecordErrorInfo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenPage(SBCOEExportEntry: Record "SBCOE Export Entry"; var IsHandled: Boolean)
    begin
    end;
}
