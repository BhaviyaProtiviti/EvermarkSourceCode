pageextension 50130 "SBC Report Sales Order" extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(processing)
        {
            action("SBC Commercial Invoice")
            {
                ApplicationArea = All;
                Caption = 'Commercial Invoice';
                Image = Print;
                ToolTip = 'Print the SBC Commercial Invoice for this sales order.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    SBCCommercialInvoiceReport: Report "SBC Commercial Invoice";
                begin
                    SalesHeader.SetRange("Document Type", Rec."Document Type");
                    SalesHeader.SetRange("No.", Rec."No.");
                    SBCCommercialInvoiceReport.SetTableView(SalesHeader);
                    SBCCommercialInvoiceReport.RunModal();
                end;
            }
        }
        addlast(Category_Category11)
        {
            actionref(SBCCommercialInvoice_Promoted; "SBC Commercial Invoice") { }
        }
    }


    var
        myInt: Integer;
}