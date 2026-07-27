pageextension 50180 "SBC Sales Header" extends "Sales Order"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("SBC ODW Update Ship Date"; Rec."SBC ODW Update Ship Date")
            {
                ApplicationArea = All;
                ToolTip = 'Shipment Date was updated by ODW.';

            }
        }

    }



}
