/// <summary>
/// This report is a wrapper for the Export Purchase Orders report. It facilitates per-vendor export templates rather than a single template for all vendors.
/// </summary>
report 50042 "SBC Export Vendor Orders"
{
    AdditionalSearchTerms = 'Export Vendor Orders';
    AllowScheduling = true;
    ApplicationArea = All;
    Caption = 'Export Vendor Orders to Excel';
    Description = 'Exports Vendor Orders to Excel based on the Export Definition Code set in the Export Options page.';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = true;
    dataset
    {
        dataitem(PurchaseHeaderDataItem; "Purchase Header")
        {
            RequestFilterFields = "No.";
            dataitem(PurchaseLineData; "Purchase Line")
            {
                DataItemLinkReference = PurchaseHeaderDataItem;
                DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");
                DataItemTableView = where(Type = const(Item));
                dataitem(ItemData; Item)
                {
                    DataItemLinkReference = PurchaseLineData;
                    DataItemLink = "No." = field("No.");

                }
            }
            trigger OnPreDataItem()
            var
                SelectionFilterManagement: Codeunit SelectionFilterManagement;
            begin
                // InitializeExportRecord();
                GlobalSelectedPOFilter := SelectionFilterManagement.GetSelectionFilterForPurchaseHeader(PurchaseHeaderDataItem);
            end;

            trigger OnAfterGetRecord()
            begin
                if not GlobalUniqueVendorDictionary.Add(PurchaseHeaderDataItem."Buy-from Vendor No.", PurchaseHeaderDataItem."Buy-from Vendor No.") then;
            end;


        }


    }
    requestpage
    {
        SaveValues = true;
        SourceTable = "Purchase Header";
    }

    trigger OnInitReport()
    begin
        InitializeExportDefinition(GlobalExportDefinitionCode);
    end;

    trigger OnPostReport()
    var
        Vendor: Record Vendor;
        VendorNo: Code[20];
    begin
        foreach VendorNo in GlobalUniqueVendorDictionary.Keys() do
            ExportPerVendorReports(VendorNo);
    end;

    var
        GlobalPlantCode: Code[20];
        GlobalBlockOrderExport: Boolean;
        GlobalSBCOEExport: Record "SBCOE Export";
        GlobalSBCOEExportDefinition: Record "SBCOE Export Definition";
        GlobalSuppressErrorDisplay: Boolean;
        GlobalExportDefinitionCode: Code[20];
        GlobalUniqueVendorDictionary: Dictionary of [Code[20], Code[20]];
        NoExportDefinitionInOptionsErrorLabel: Label 'Please set a valid export definition in the Export Options table.';
        NoExportDefinitionSetErrorTitleLabel: Label 'No Export Definition Set.';
        GlobalSelectedPOFilter: Text;

    internal procedure SetGlobalExportDefinitionCode(ExportDefinitionCode: Code[20])
    begin
        GlobalExportDefinitionCode := ExportDefinitionCode;
    end;

    internal procedure SetGlobalBlockOrderExport(BlockOrderExport: Boolean)
    begin
        GlobalBlockOrderExport := BlockOrderExport;
    end;

    internal procedure SetSuppressErrorDisplay(SuppressErrorDisplay: Boolean)
    begin
        GlobalSuppressErrorDisplay := SuppressErrorDisplay;
    end;

    local procedure ExportPerVendorReports(var VendorNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SBCOEExportEmailGroup: Record "SBCOE Export Email Group";
        SBCOEExportPurchaseOrders: Report "SBC Export Purchase Orders";
    begin
        // PurchaseHeader.SetFilter("No.", GlobalSelectedPOFilter);
        PurchaseHeader.Copy(PurchaseHeaderDataItem);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        if GlobalBlockOrderExport or (not PurchaseHeader.MarkedOnly()) then
            PurchaseHeader.SetRange("SBC Block Order", GlobalBlockOrderExport);
        PurchaseLine.SetFilter("Document No.", GlobalSelectedPOFilter);
        if GlobalPlantCode <> '' then
            PurchaseLine.SetRange("SBC Plant Code", GlobalPlantCode);
        PurchaseLine.SetRange("Buy-from Vendor No.", VendorNo);
        if PurchaseLine.IsEmpty() and not GlobalBlockOrderExport then
            exit;
        SBCOEExportPurchaseOrders.UseRequestPage(false);
        if GlobalBlockOrderExport then 
            SBCOEExportPurchaseOrders.SetExportDefinitionCode(GetExportOptions()."Notification Definition Code")
        else
            SBCOEExportPurchaseOrders.SetExportDefinitionCode(GetExportDefinitionFromVendor(VendorNo));
        SBCOEExportPurchaseOrders.SetExportMailGroupCode(GetMailGroupCodeFromVendor(VendorNo));
        SBCOEExportPurchaseOrders.SetContactEmailList(SBCOEExportEmailGroup.GetExportContactEmailList(VendorNo, "Contact Business Relation Link To Table"::Vendor));
        SBCOEExportPurchaseOrders.SetSuppressErrorDisplay(GlobalSuppressErrorDisplay);
        SBCOEExportPurchaseOrders.SetTableView(PurchaseHeader);
        SBCOEExportPurchaseOrders.SetTableView(PurchaseLine);
        SBCOEExportPurchaseOrders.Run();
    end;

    internal procedure SetGlobalPlantCode(PlantCode: Code[20])
    begin
        GlobalPlantCode := PlantCode;
    end;

    local procedure GetExportDefinitionFromVendor(VendorNo: Code[20]) ExportDefinition: Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetFilter("No.", VendorNo);
        Vendor.SetLoadFields("SBCOE Export Definition");
        Vendor.FindFirst();
        ExportDefinition := Vendor."SBCOE Export Definition";
    end;

    local procedure GetMailGroupCodeFromVendor(VendorNo: Code[20]) MailGroupCode: Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetFilter("No.", VendorNo);
        Vendor.SetLoadFields("SBCOE Export Definition");
        Vendor.FindFirst();
        MailGroupCode := Vendor."SBCOE Email Group";
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
        SBCOEExportOptions := GetExportOptions();
        if ExportDefinitionCode = '' then
            ExportDefinitionCode := SBCOEExportOptions ."Export Definition Code";
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

    local procedure GetExportOptions()  SBCOEExportOptions: Record "SBCOE Export Options";
    begin
        SBCOEExportOptions.Get();
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
