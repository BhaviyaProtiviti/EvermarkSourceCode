/// <summary>
/// PageExtension SBCOE Purchase Order (ID 50067) extends Record Purchase Order.
/// </summary>
pageextension 50056 "SBCOE Purchase Order" extends "Purchase Order"
{

    layout {
        addlast(General)
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
        addlast(reporting)
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
        }
        addfirst(Category_Process)
        {
            actionref(SBCOEExportOrder_Promoted; SBCOEExportOrder)
            {
                Visible = true;
            }
            actionref(SBCOEViewExports_Promoted; SBCOEViewExports)
            {
                Visible = true;
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