/// <summary>
/// This page extension adds an action to the Posted Sales Invoice page that allows the user to view the exports for the sales order associated with the invoice.
/// </summary>
pageextension 50065 "SBCOE Posted Sales Invoice" extends "Posted Sales Invoice"
{
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
                ToolTip = 'View Exports for the Sales Order associated with this Invoice';
                Visible = true;
                trigger OnAction()
                var
                    SBCOEExport: Record "SBCOE Export";
                begin
                    SBCOEExport.ViewExports(Rec."Order No.", Database::"Sales Header");
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
        GlobalSBCOEActionsEnabled := SBCOEExport.HasExports(Rec."Order No.", Database::"Sales Header");
    end;

    var
        GlobalSBCOEActionsEnabled: Boolean;
}