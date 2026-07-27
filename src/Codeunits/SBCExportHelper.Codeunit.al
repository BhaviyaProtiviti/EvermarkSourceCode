/// <summary>
/// Codeunit SBC Export Helper (ID 50042).
/// </summary>
codeunit 50042 "SBC Export Helper"
{
    var
        GlobalSBCExportValueHelper: Codeunit "SBC Export Value Helper";

    internal procedure ExportVendorOrders(var PurchaseHeader: Record "Purchase Header")
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        PurchaseLine: Record "Purchase Line";
        SBCPlant: Record "SBC Plant";
        PurchaseDocumentFilter: Text;
        PlantPurchaseOrders: Record "Purchase Header";
    begin
        if not PurchaseHeader.HasFilter() then
            PurchaseHeader.SetRecFilter();
        PurchaseDocumentFilter := SelectionFilterManagement.GetSelectionFilterForPurchaseHeader(PurchaseHeader);
        SendBlockOrders(PurchaseDocumentFilter);
        SBCPlant.SetRange(Enabled, true);
        PlantPurchaseOrders.SetFilter("No.", PurchaseDocumentFilter);
        PlantPurchaseOrders.SetRange("SBC Block Order", false);
        if not PlantPurchaseOrders.IsEmpty() then
            ExportPlantOrders(PlantPurchaseOrders, PurchaseLine, SBCPlant, PurchaseDocumentFilter);
        GlobalSBCExportValueHelper.Unbind(true);
    end;

    local procedure Export(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; SBCPlantCode: Code[20])
    var
        SBCOEExportVendorOrders: Report "SBC Export Vendor Orders";
        BlockOrderExport: Boolean;
        BlockOrderFilterText: Text;
    begin
        BlockOrderFilterText := PurchaseHeader.GetFilter("SBC Block Order");
        BlockOrderExport := false;
        if BlockOrderFilterText <> '' then
            Evaluate(BlockOrderExport, BlockOrderFilterText);
        SBCOEExportVendorOrders.SetGlobalBlockOrderExport(BlockOrderExport);
        SBCOEExportVendorOrders.SetTableView(PurchaseHeader);
        SBCOEExportVendorOrders.SetTableView(PurchaseLine);
        SBCOEExportVendorOrders.SetGlobalPlantCode(SBCPlantCode);
        // this was updated to never show the request page because the use of a plant code makes setting this awkward and unnecessary.
        SBCOEExportVendorOrders.UseRequestPage(false);
        SBCOEExportVendorOrders.Run();
    end;

    local procedure RebindExportValueHelper(SBCPlantCode: Code[20])
    begin
        GlobalSBCExportValueHelper.Unbind(true);
        GlobalSBCExportValueHelper.Bind();
        GlobalSBCExportValueHelper.SetGlobalPlantCode(SBCPlantCode);
    end;

    local procedure ExportPlantOrders(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var SBCPlant: Record "SBC Plant"; var PurchaseDocumentFilter: Text)
    begin

        if SBCPlant.IsEmpty() then
            exit;
        SBCPlant.FindSet();
        repeat
            RebindExportValueHelper(SBCPlant."Plant Code");
            PurchaseHeader.SetFilter("No.", PurchaseDocumentFilter);
            PurchaseLine.SetFilter("Document No.", PurchaseDocumentFilter);
            PurchaseLine.SetRange("SBC Plant Code", SBCPlant."Plant Code");
            if not PurchaseLine.IsEmpty() then
                Export(PurchaseHeader, PurchaseLine, SBCPlant."Plant Code");
        until SBCPlant.Next() = 0;
    end;

    local procedure SendBlockOrdersWithLines(var BlockPurchaseLine: Record "Purchase Line"; var BlockPurchaseOrders: Record "Purchase Header")
    var
        BlockSBCPlant: Record "SBC Plant";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        BlockPurchaseDocumentFilter: Text;
    begin
        BlockSBCPlant.SetRange(Enabled, true);
        BlockPurchaseOrders.FindSet();
        repeat
            BlockPurchaseOrders.Mark(BlockPurchaseOrders.PurchLinesExist());
        until BlockPurchaseOrders.Next() = 0;
        BlockPurchaseOrders.MarkedOnly(true);
        if not BlockPurchaseOrders.IsEmpty() then begin
            BlockPurchaseOrders.SetRange("SBC Block Order");
            BlockPurchaseDocumentFilter := SelectionFilterManagement.GetSelectionFilterForPurchaseHeader(BlockPurchaseOrders);
            ExportPlantOrders(BlockPurchaseOrders, BlockPurchaseLine, BlockSBCPlant, BlockPurchaseDocumentFilter);
            BlockPurchaseOrders.SetRange("SBC Block Order", true);
        end;
        BlockPurchaseOrders.ClearMarks();
        BlockPurchaseOrders.MarkedOnly(false);
    end;

    local procedure SendEmptyBlockOrders(var BlockPurchaseLine: Record "Purchase Line"; var BlockPurchaseOrders: Record "Purchase Header")
    begin
        BlockPurchaseOrders.FindSet();
        repeat
            BlockPurchaseOrders.Mark(not BlockPurchaseOrders.PurchLinesExist());
        until BlockPurchaseOrders.Next() = 0;
        BlockPurchaseOrders.MarkedOnly(true);
        if not BlockPurchaseOrders.IsEmpty() then
            Export(BlockPurchaseOrders, BlockPurchaseLine, '');
        BlockPurchaseOrders.ClearMarks();
        BlockPurchaseOrders.MarkedOnly(false);
    end;

    local procedure SendBlockOrders(var PurchaseDocumentFilter: Text)
    var
        BlockPurchaseLine: Record "Purchase Line";
        BlockPurchaseOrders: Record "Purchase Header";
    begin
        BlockPurchaseOrders.SetFilter("No.", PurchaseDocumentFilter);
        BlockPurchaseOrders.SetRange("SBC Block Order", true);
        if BlockPurchaseOrders.IsEmpty() then
            exit;
        SendEmptyBlockOrders(BlockPurchaseLine, BlockPurchaseOrders);
        SendBlockOrdersWithLines(BlockPurchaseLine, BlockPurchaseOrders);
    end;



}