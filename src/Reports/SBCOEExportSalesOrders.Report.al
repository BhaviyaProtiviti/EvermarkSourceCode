/// <summary>
/// Report SBCOE Export Orders (ID 50060).
/// </summary>
report 50041 "SBC Export Sales Orders"
{
    AdditionalSearchTerms = 'Export Sales Orders';
    AllowScheduling = true;
    ApplicationArea = All;
    Caption = 'Export Sales Orders to Excel';
    Description = 'Exports Sales Orders to Excel based on the Export Definition Code set in the Export Options page.';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            RequestFilterFields = "No.";

            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");
                DataItemLinkReference = SalesHeader;
                DataItemTableView = where(Type = const(Item));

                trigger OnAfterGetRecord()
                begin
                    GlobalSBCOEExport.AddExportEntry(SalesLine."Document No.", SalesLine.SystemId, Database::"Sales Line", "SBCOE Row Type"::Detail);
                end;
            }
            trigger OnPreDataItem()
            begin
                InitializeExportRecord();
            end;

            trigger OnAfterGetRecord()
            begin
                GlobalSBCOEExport.AddExportEntry(SalesHeader."No.", SalesHeader.SystemId, Database::"Sales Header", "SBCOE Row Type"::Header);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }

    trigger OnInitReport()
    begin
        InitializeExportDefinition(GlobalExportDefinitionCode);
    end;

    trigger OnPostReport()
    var
        SBCOEExportWrapper: Report "SBCOE Export Wrapper";
    begin
        SBCOEExportWrapper.SetSuppressErrorDisplay(GlobalSuppressErrorDisplay);
        SBCOEExportWrapper.SetGlobalSBCOEExport(GlobalSBCOEExport);
        SBCOEExportWrapper.Run();
    end;

    var

        GlobalSBCOEExport: Record "SBCOE Export";
        GlobalSBCOEExportDefinition: Record "SBCOE Export Definition";
        GlobalSuppressErrorDisplay: Boolean;
        GlobalExportDefinitionCode: Code[20];
        NoExportDefinitionInOptionsErrorLabel: Label 'Please set a valid export definition in the Export Options table.';
        NoExportDefinitionSetErrorTitleLabel: Label 'No Export Definition Set.';

    internal procedure SetExportDefinitionCode(ExportDefinitionCode: Code[20])
    begin
        GlobalExportDefinitionCode := ExportDefinitionCode;
    end;

    internal procedure SetSuppressErrorDisplay(SuppressErrorDisplay: Boolean)
    begin
        GlobalSuppressErrorDisplay := SuppressErrorDisplay;
    end;

    /// <summary>
    /// This procedure initializes the export definition and throws an error if the export definition is not set.
    /// </summary>
    /// <param name=" ExportDefinitionCode">Code[20].</param>
    local procedure InitializeExportDefinition(var ExportDefinitionCode: Code[20])
    var
        SBCOEExportOptions: Record "SBCOE Export Options";
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
        NoExportDefinitionSetErrorInfo: ErrorInfo;
    begin
        if ExportDefinitionCode = '' then begin
            SBCOEExportOptions.Get();
            ExportDefinitionCode := SBCOEExportOptions."Export Definition Code";
        end;
        if TryGetExportDefinition(ExportDefinitionCode) then
            exit;
        NoExportDefinitionSetErrorInfo := SBCOEErrorHelper.CreateCollectableErrorInfo(SBCOEExportOptions.RecordId().GetRecord(), SBCOEExportOptions.RecordId().TableNo(), NoExportDefinitionInOptionsErrorLabel, NoExportDefinitionSetErrorTitleLabel);
        Error(NoExportDefinitionSetErrorInfo);
    end;
    /// <summary>
    /// This procedure initializes the export record with default values.
    /// </summary>
    local procedure InitializeExportRecord()
    begin
        GlobalSBCOEExport."Creation Date" := Today();
        GlobalSBCOEExport."Export Definition Code" := GlobalExportDefinitionCode;
        GlobalSBCOEExport."Email Group Code" := GlobalSBCOEExport.GetExportDefinition()."Email Group Code";
        GlobalSBCOEExport.Insert(true);
    end;

    /// <summary>
    /// This function tries to get the export definition and returns true if the export definition is set without errors.
    /// </summary>
    /// <param name="ExportDefinitionCode">Code[20].</param>
    [TryFunction()]
    local procedure TryGetExportDefinition(ExportDefinitionCode: Code[20])
    begin
        OnBeforeGetExportDefinitionRecord(ExportDefinitionCode);
        GlobalSBCOEExportDefinition.Get(ExportDefinitionCode);
        GlobalSBCOEExport.Init();
    end;

    /// <summary>
    /// This event is called before the export definition code is used to get the export definition.
    /// </summary>
    /// <param name="ExportDefinitionCode">VAR Code[20].</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetExportDefinitionRecord(var ExportDefinitionCode: Code[20])
    begin
    end;
}
