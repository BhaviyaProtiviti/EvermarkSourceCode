codeunit 50161 "SBC Create Transfer Order"
{

    procedure CreateTransfer(PurchRcptHeader: Record "Purch. Rcpt. Header"): Code[20]
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        LocationRec: Record Location;
        NextLineNo: Integer;
        NextEntryNo: Integer;
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        TransShipmentHeader: Record "Transfer Shipment Header";
        TransReceiptHeader: Record "Transfer Receipt Header";
        PurchRcptHeaderLocal: Record "Purch. Rcpt. Header";
        LinkRec: Record "SBC Purch Order Transfer Link";
        Item: Record Item;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        TrackingSpec: Record "Tracking Specification";
        TempReservEntry: Record "Reservation Entry" temporary;
        NextTrackingEntryNo: Integer;
        QtyRemaining: Decimal;
        QtyToAssign: Decimal;
        ReservStatus: Enum "Reservation Status";
        CurrentSourceRowID: Text[250];
        SecondSourceRowID: Text[250];
        LocationToUse: Code[10];
        LocNotFoundErr: Label 'A location could not be found on the Purchase Receipt Lines.';
    begin
        PurchRcptLine.Reset();
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
        PurchRcptLine.SetFilter("Location Code", '<>''''');
        PurchRcptLine.SetFilter(Quantity, '>0');
        if PurchRcptLine.FindFirst() then
            LocationToUse := PurchRcptLine."Location Code"
        else
            Error(LocNotFoundErr);
        PurchRcptLine.Reset();

        TransferHeader.Init();
        TransferHeader."No." := '';
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", LocationToUse);

        if not LocationRec.Get(LocationToUse) then
            Error('Location %1 not found.', LocationToUse);
        if LocationRec."SBC Physical Warehouse" = '' then
            Error('Physical Warehouse is not defined for Location %1. Cannot create transfer order.', LocationToUse);

        TransferHeader.Validate("Transfer-to Code", LocationRec."SBC Physical Warehouse");
        TransferHeader.Validate("In-Transit Code", '');
        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader."SBC Linked Purchase Order No." := PurchRcptHeader."Order No.";
        TransferHeader."SBC Source Receipt No." := PurchRcptHeader."No.";
        TransferHeader.Modify();



        NextTrackingEntryNo := 0;
        TrackingSpec.LockTable();
        if TrackingSpec.FindLast() then
            NextTrackingEntryNo := TrackingSpec."Entry No." + 1
        else
            NextTrackingEntryNo := 1;

        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);

        if PurchRcptLine.FindSet() then
            repeat

                TransferLine.Reset();
                TransferLine.SetRange("Document No.", TransferHeader."No.");

                NextLineNo := 10000;
                if TransferLine.FindLast() then
                    NextLineNo := TransferLine."Line No." + 10000;

                TransferLine.Init();
                TransferLine."Document No." := TransferHeader."No.";
                TransferLine."Line No." := NextLineNo;

                TransferLine.Validate("Item No.", PurchRcptLine."No.");

                TransferLine.Validate("Unit of Measure Code", PurchRcptLine."Unit of Measure Code");
                TransferLine."Qty. per Unit of Measure" := PurchRcptLine."Qty. per Unit of Measure";
                TransferLine.Validate("Item No.", PurchRcptLine."No.");
                TransferLine.Validate("SBC Override Exact Qty.", true);
                TransferLine.Validate("Quantity", PurchRcptLine.Quantity);
                TransferLine.Insert();


                TransferLine.Validate("Qty. to Ship", TransferLine.Quantity);
                TransferLine.Modify();

                if Item.Get(TransferLine."Item No.") then
                    if Item."Item Tracking Code" = '' then begin
                        TransferLine.Validate("Qty. to Ship", TransferLine."Quantity");
                        TransferLine.Validate("Qty. to Receive", TransferLine."Quantity");
                        TransferLine.Modify();

                    end else begin

                        QtyRemaining := TransferLine."Quantity (Base)";

                        ItemLedgEntry.SetRange("Document No.", PurchRcptLine."Document No.");
                        ItemLedgEntry.SetRange("Item No.", PurchRcptLine."No.");
                        if ItemLedgEntry.FindSet() then begin
                            repeat
                                if QtyRemaining <= 0 then
                                    break;

                                if QtyRemaining < ItemLedgEntry."Remaining Quantity" then
                                    QtyToAssign := QtyRemaining
                                else
                                    QtyToAssign := ItemLedgEntry."Remaining Quantity";


                                TempReservEntry.Init();
                                TempReservEntry."Entry No." := NextTrackingEntryNo;
                                NextTrackingEntryNo += 1;

                                TempReservEntry."Lot No." := ItemLedgEntry."Lot No.";
                                TempReservEntry.Validate(Quantity, QtyToAssign / PurchRcptLine."Qty. per Unit of Measure");
                                TempReservEntry.Insert();

                                CreateReservEntry.CreateReservEntryFor(
                                  Database::"Transfer Line", 0,
                                  TransferLine."Document No.", '', 0, TransferLine."Line No.", PurchRcptLine."Qty. per Unit of Measure",
                                  QtyToAssign / PurchRcptLine."Qty. per Unit of Measure", QtyToAssign, TempReservEntry);
                                CreateReservEntry.CreateEntry(
                                  TransferLine."Item No.", TransferLine."Variant Code", TransferLine."Transfer-from Code", '', TransferLine."Receipt Date", 0D, 0, ReservStatus::Surplus);

                                CurrentSourceRowID := ItemTrackingMgt.ComposeRowID(Database::"Transfer Line", 0, TransferLine."Document No.", '', 0, TransferLine."Line No.");

                                SecondSourceRowID := ItemTrackingMgt.ComposeRowID(Database::"Transfer Line", 1, TransferLine."Document No.", '', 0, TransferLine."Line No.");


                                ItemTrackingMgt.SynchronizeItemTracking(CurrentSourceRowID, SecondSourceRowID, '');
                                QtyRemaining -= QtyToAssign;

                            until ItemLedgEntry.Next() = 0;
                        end;

                    end;

            until PurchRcptLine.Next() = 0;

        TransferPostShipment.Run(TransferHeader);
        TransferPostReceipt.Run(TransferHeader);

        TransShipmentHeader.Reset();
        TransShipmentHeader.SetRange("Transfer Order No.", TransferHeader."No.");
        if TransShipmentHeader.FindLast() then begin
            TransReceiptHeader.Reset();
            TransReceiptHeader.SetRange("Transfer Order No.", TransferHeader."No.");
            if TransReceiptHeader.FindLast() then begin
                if PurchRcptHeaderLocal.Get(PurchRcptHeader."No.") then begin
                    PurchRcptHeaderLocal."SBC Posted Trans Shipment No." := TransShipmentHeader."No.";
                    PurchRcptHeaderLocal."SBC Posted Trans Receipt No." := TransReceiptHeader."No.";
                    PurchRcptHeaderLocal."SBC Transfer Order No." := TransferHeader."No.";
                    PurchRcptHeaderLocal.Modify();
                end;

                NextEntryNo := 1;
                if LinkRec.FindLast() then
                    NextEntryNo := LinkRec."Entry No." + 1;

                LinkRec.Init();
                LinkRec."Entry No." := NextEntryNo;
                LinkRec."Purchase Order No." := PurchRcptHeader."Order No.";
                LinkRec."Purchase Receipt No." := PurchRcptHeader."No.";
                LinkRec."Transfer Order No." := TransferHeader."No.";
                LinkRec."Created Date-Time" := CurrentDateTime();
                LinkRec."Posted Transfer Shipment No." := TransShipmentHeader."No.";
                LinkRec."Posted Transfer Receipt No." := TransReceiptHeader."No.";
                LinkRec.Insert();
            end;
        end;

        exit(TransferHeader."No.");

    end;


}