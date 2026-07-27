pageextension 50131 "SBC Report Sales Order List" extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(reporting)
        {

            action("SBC Commercial Invoice")
            {
                ApplicationArea = All;
                Caption = 'Commercial Invoice';
                Image = Print;
                ToolTip = 'Print the SBC Commercial Invoice for the selected sales orders.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    SBCCommercialInvoiceReport: Report "SBC Commercial Invoice";
                begin
                    CurrPage.SetSelectionFilter(SalesHeader);
                    SBCCommercialInvoiceReport.SetTableView(SalesHeader);
                    SBCCommercialInvoiceReport.RunModal();
                end;
            }
        }
        addlast(Category_Category8)
        {
            actionref(SBCCommercialInvoice_Promoted; "SBC Commercial Invoice") { }
        }
    }




    var
        myInt: Integer;
}