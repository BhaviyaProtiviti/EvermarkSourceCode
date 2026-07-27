/// <summary>
/// PageExtension SBCOE Purchase Orders (ID 50066) extends Record Purchase Orders.
/// </summary>
pageextension 50057 "SBCOE Purchase Orders" extends "Purchase Order List"
{
    layout
    {
        addlast(Control1)
        {

            field("SBC Block Order"; Rec."SBC Block Order")
            {
                ApplicationArea = All;
                ToolTip = 'This field is set when an order is created from the Multi-Order creation process.';
                Visible = true;
                Editable = false;
                Importance = Additional;
            }
        }
    }

    actions
    {
        addlast(Reporting)
        {
            action(SBCOEViewExports)
            {
                ApplicationArea = All;
                Caption = 'View Exports';
                Enabled = GlobalSBCOEActionsEnabled;
                Image = ViewJob;
                ToolTip = 'View Exports for the Purchase Order';
                Visible = true;
                trigger OnAction()
                var
                    SBCOEExport: Record "SBCOE Export";
                begin
                    SBCOEExport.ViewExports(Rec.SystemId, Rec.RecordId().TableNo());
                end;
            }
            action(SBCOEExportOrder)
            {
                ApplicationArea = All;
                Caption = 'Export Order';
                Enabled = true;
                Image = Export;
                ToolTip = 'Export the Purchase Order';
                Visible = true;
                trigger OnAction()
                begin
                    ExportOrders();
                end;
            }
            action(SBC_ExportMassUpdateTemp)
            {
                Applicationarea = All;
                Caption = 'Export Mass Update Temp';
                Image = Export;
                ToolTip = 'Export Mass Update Temp';
                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                    SelectionFilterManagement: Codeunit SelectionFilterManagement;
                begin
                    CurrPage.SetSelectionFilter(PurchaseHeader);
                    PurchaseHeader.SetFilter("No.", SelectionFilterManagement.GetSelectionFilterForPurchaseHeader(PurchaseHeader));
                    Report.RunModal(Report::"SBC Mass Update Template", true, false, PurchaseHeader);
                end;
            }
            action(SBC_ImportMassUpdate)
            {
                ApplicationArea = All;
                Caption = 'Import Mass Update';
                Image = Import;
                ToolTip = 'Import Mass Update';
                trigger OnAction()
                var
                    SBCImportPOMassUpdate: Codeunit "SBC Import PO Mass Update";
                begin
                    SBCImportPOMassUpdate.ImportFile();
                end;
            }
        }
        addfirst(Category_Process)
        {
            actionref(SBCOEViewExports_Promoted; SBCOEViewExports)
            {
                Visible = true;
            }
            actionref(SBCOEExportOrder_Promoted; SBCOEExportOrder)
            {
                Visible = true;
            }            
        }
        addlast(Category_Process)
        {
            group(PO_MassUpdate)
            {
                Caption = 'PO Mass Update';
                actionref(SBC_ExportMassUpdateTemp_Promoted; SBC_ExportMassUpdateTemp)
                {
                }
                actionref(SBC_ImportMassUpdate_Promoted; SBC_ImportMassUpdate)
                {
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        SBCOEExport: Record "SBCOE Export";
    begin
        GlobalSBCOEActionsEnabled := SBCOEExport.HasExports(Rec.SystemId, Rec.RecordId().TableNo());
    end;

    var
        GlobalSBCOEActionsEnabled: Boolean;

    local procedure ExportOrders()
    var
        PurchaseHeader: Record "Purchase Header";
        SBCExportHelper: Codeunit "SBC Export Helper";
    begin
        CurrPage.SetSelectionFilter(PurchaseHeader);
        SBCExportHelper.ExportVendorOrders(PurchaseHeader);
    end;
}