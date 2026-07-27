pageextension 50164 "SBC Posted Purch Receipt" extends "Posted Purchase Receipt"
{

    layout
    {
        addlast(General)
        {
            field("SBC Transfer Order No."; Rec."SBC Transfer Order No.")
            {
                ApplicationArea = All;
                Caption = 'Transfer Order No.';
                Editable = false;

                trigger OnDrillDown()
                var
                    TransferHeader: Record "Transfer Header";
                begin
                    if TransferHeader.Get(Rec."SBC Transfer Order No.") then
                        Page.Run(Page::"Transfer Order", TransferHeader);
                end;
            }
            field("SBC Posted Trans Shipment No."; Rec."SBC Posted Trans Shipment No.")
            {
                ApplicationArea = All;
                Caption = 'Posted Transfer Shipment No.';
                Editable = false;

                trigger OnDrillDown()
                var
                    TransferShipmentHeader: Record "Transfer Shipment Header";
                begin
                    if TransferShipmentHeader.Get(Rec."SBC Posted Trans Shipment No.") then
                        Page.Run(Page::"Posted Transfer Shipment", TransferShipmentHeader);
                end;
            }
            field("SBC Posted Trans Receipt No."; Rec."SBC Posted Trans Receipt No.")
            {
                ApplicationArea = All;
                Caption = 'Posted Transfer Receipt No.';
                Editable = false;

                trigger OnDrillDown()
                var
                    TransferReceiptHeader: Record "Transfer Receipt Header";
                begin
                    if TransferReceiptHeader.Get(Rec."SBC Posted Trans Receipt No.") then
                        Page.Run(Page::"Posted Transfer Receipt", TransferReceiptHeader);
                end;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("Create Transfer Order")
            {
                Caption = 'Create Transfer Order';
                ApplicationArea = All;
                Image = CreateDocument;

                trigger OnAction()
                var
                    TransferCreator: Codeunit "SBC Create Transfer Order";
                    TransferNo: Code[20];
                    PurchHeader: Record "Purchase Header";

                begin

                    if Rec."SBC Transfer Order No." <> '' then
                        Error('A Transfer Order has already been created for this receipt.');

                    TransferNo := TransferCreator.CreateTransfer(Rec);
                    Rec.Get(Rec."No.");

                    if PurchHeader.Get(PurchHeader."Document Type"::Order, Rec."Order No.") then begin
                        PurchHeader.Validate("SBC Create Transfer Order", true);
                        PurchHeader.Validate("SBC Linked Transfer Order No.", TransferNo);
                        PurchHeader.Modify();
                    end;

                    CurrPage.Update(false);

                end;
            }
        }
    }
}