pageextension 50175 "SBC Planned Ship Date Update" extends "Sales Order List"
{

    actions
    {
        addafter("Pla&nning")
        {
            action(UpdatePlannedShipDate)
            {
                ApplicationArea = All;
                Caption = 'ODW Planned Ship Date';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ImportExcel;
                ToolTip = 'Import ODW Planned Shipment Date Report';

                trigger OnAction()

                var
                    ImportODWShipReport: Codeunit "SBC SO Update ODW Ship Date";
                begin
                    ImportODWShipReport.ImportODWfile();
                end;


            }
        }
    }

}

