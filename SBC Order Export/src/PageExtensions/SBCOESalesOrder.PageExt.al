/// <summary>
/// This page extension adds an action to the Sales Order page that allows the user to view the exports for the current sales order.
/// </summary>
pageextension 50064 "SBCOE Sales Order" extends "Sales Order"
{
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
                ToolTip = 'View Exports for the Sales Order';
                Visible = true;
                trigger OnAction()
                var
                    SBCOEExport: Record "SBCOE Export";
                begin
                    SBCOEExport.ViewExports(Rec.SystemId, Rec.RecordId().TableNo());
                end;
            }
        }
        addfirst(Category_Process)
        {
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
}