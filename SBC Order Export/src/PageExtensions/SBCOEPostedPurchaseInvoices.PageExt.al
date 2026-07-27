/// <summary>
/// PageExtension SBCOE Posted Purchase Invoices (ID 50068) extends Record Posted Purchase Invoices.
/// </summary>
pageextension 50068 "SBCOE Posted Purchase Invoices" extends "Posted Purchase Invoices"
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
                ToolTip = 'View Exports for the Purchase Order associated with this Invoice';
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