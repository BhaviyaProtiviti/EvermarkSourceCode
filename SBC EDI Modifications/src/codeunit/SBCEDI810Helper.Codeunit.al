codeunit 50152 "SBC EDI 810 Helper"
{
    TableNo = "LAX EDI Receive Document Hdr.";

    trigger OnRun()
    begin
        Create810Shipment(Rec);
    end;

    #region createShipment

    local procedure Create810Shipment(LAXEDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDISetup: Record "LAX EDI Setup";
        SalesHeader: Record "Sales Header";
    begin
        LAXEDISetup.Get();
        if (not LAXEDISetup."SBC 810 Allow Create Shipment") or (not LAXEDISetup."SBC 945 Adjust Inventory") then
            exit
        else
            // if Has945(LAXEDIRecDocHdr."Customer Reference No.") then
            //     exit
            // else
            if NoLots(LAXEDIRecDocHdr."Internal Doc. No.") then
                exit;

        if SalesHeader.Get(SalesHeader."Document Type"::Order, GetOrderNo(LAXEDIRecDocHdr."Internal Doc. No.")) then
            CreateSalesShipment(LAXEDIRecDocHdr."Internal Doc. No.", SalesHeader."No.");
    end;

    local procedure CreateSalesShipment(InternalDocNo: Code[10]; SalesOrderNo: Code[20])
    var
        EDIReceiveDocField: Record "LAX EDI Receive Document Field";
        TempReservationEntry: Record "Reservation Entry" temporary;
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        TempItemJournalLine: Record "Item Journal Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        SBCEDICreateItemJnlHelper: Codeunit "SBC EDI Create Item Jnl Helper";
        ItemNo: Code[20];
        LotNo: Code[20];
        ReservQty: Decimal;
        ReservEntryNo: Integer;
        LineNo: Integer;
    begin
        //create tempreservations
        EDIReceiveDocField.SetRange("Internal Doc. No.", InternalDocNo);
        EDIReceiveDocField.SetRange(Segment, 'IT1');
        EDIReceiveDocField.SetRange(Element, '');
        if EDIReceiveDocField.FindSet() then
            repeat
                if GetReservationVariables(InternalDocNo, ItemNo, LotNo, ReservQty, SalesOrderNo, EDIReceiveDocField."Segment Group") then
                    // if CreateTempReservEntry(TempReservationEntry, TempItemJournalLine, ReservEntryNo, EDIReceiveDocField."Internal Doc. No.", SalesOrderNo, ItemNo, LotNo, ReservQty, LineNo) then
                     if CreateTempTrackSpecification(TempTrackingSpecification, TempItemJournalLine, ReservEntryNo, EDIReceiveDocField."Internal Doc. No.", SalesOrderNo, ItemNo, LotNo, ReservQty, LineNo) then
                        // CreateTempSalesLine(TempSalesLine, SalesOrderNo, ItemNo, ReservQty, TempReservationEntry."Source Ref. No."); //create temp Sales Lines to calculate qty to ship
                        CreateTempSalesLine(TempSalesLine, SalesOrderNo, ItemNo, ReservQty, TempTrackingSpecification."Source Ref. No."); //create temp Sales Lines to calculate qty to ship
            until EDIReceiveDocField.Next() = 0;

        //adjust inventory if needed
        SBCEDICreateItemJnlHelper.CreateInventory(TempItemJournalLine, 810);

        //create actual reservations and update sales lines qty to ship
        // CreateReservationEntries(TempSalesLine, TempReservationEntry);
        CreateReservationEntries(TempSalesLine, TempTrackingSpecification);
        //post shipment

    end;

    #endregion createShipment

    #region createTempEntries

    local procedure CreateTempTrackSpecification(var TempReservationEntry: Record "Tracking Specification" temporary; var TempItemJournalLine: Record "Item Journal Line" temporary; var ReservEntryNo: Integer; InternalDocNo: Code[10]; SalesOrderNo: Code[20]; ItemNo: Code[20]; LotNo: Code[20]; ReservQty: Decimal; var LineNo: Integer): Boolean
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        ReservEntryNo += 1;

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesOrderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        if SalesLine.FindFirst() then begin

            if Item.Get(ItemNo) then;
            Item.CalcFields("SBC Qty. per Sales UOM");

            TempReservationEntry.Init();
            TempReservationEntry."Entry No." := ReservEntryNo;
            TempReservationEntry."Source Type" := Database::"Sales Line";
            TempReservationEntry."Source Subtype" := SalesLine."Document Type".AsInteger();
            TempReservationEntry."Source ID" := SalesLine."Document No.";
            TempReservationEntry."Source Ref. No." := SalesLine."Line No.";
            TempReservationEntry."Item No." := SalesLine."No.";
            TempReservationEntry."Qty. per Unit of Measure" := Item."SBC Qty. per Sales UOM";
            TempReservationEntry."Quantity (Base)" := -(ReservQty * TempReservationEntry."Qty. per Unit of Measure");
            TempReservationEntry."Location Code" := SalesLine."Location Code";
            TempReservationEntry."Lot No." := LotNo;
            TempReservationEntry.Insert(false);

            CreateTempItemJnlLine(TempItemJournalLine, InternalDocNo, SalesOrderNo, ItemNo, LotNo, SalesLine."Location Code", SalesLine."Unit of Measure Code", ReservQty, LineNo);
            exit(true);
        end;
    end;

    // local procedure CreateTempReservEntry(var TempReservationEntry: Record "Reservation Entry" temporary; var TempItemJournalLine: Record "Item Journal Line" temporary; var ReservEntryNo: Integer; InternalDocNo: Code[10]; SalesOrderNo: Code[20]; ItemNo: Code[20]; LotNo: Code[20]; ReservQty: Decimal; var LineNo: Integer): Boolean
    // var
    //     SalesLine: Record "Sales Line";
    //     Item: Record Item;
    // begin
    //     if ReservEntryNo = 0 then
    //         ReservEntryNo := GetNextEntryNo();
    //     ReservEntryNo += 1;

    //     SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
    //     SalesLine.SetRange("Document No.", SalesOrderNo);
    //     SalesLine.SetRange(Type, SalesLine.Type::Item);
    //     SalesLine.SetRange("No.", ItemNo);
    //     if SalesLine.FindFirst() then begin

    //         if Item.Get(ItemNo) then;
    //         Item.CalcFields("SBC Qty. per Sales UOM");

    //         TempReservationEntry.Init();
    //         TempReservationEntry."Entry No." := ReservEntryNo;
    //         TempReservationEntry."Source Type" := Database::"Sales Line";
    //         TempReservationEntry."Source ID" := SalesLine."Document No.";
    //         TempReservationEntry."Source Ref. No." := SalesLine."Line No.";
    //         TempReservationEntry."Item No." := SalesLine."No.";
    //         TempReservationEntry."Qty. per Unit of Measure" := Item."SBC Qty. per Sales UOM";
    //         TempReservationEntry.Quantity := (ReservQty * TempReservationEntry."Qty. per Unit of Measure");
    //         TempReservationEntry."Location Code" := SalesLine."Location Code";
    //         TempReservationEntry.Insert(false);

    //         CreateTempItemJnlLine(TempItemJournalLine, InternalDocNo, SalesOrderNo, ItemNo, LotNo, SalesLine."Location Code", SalesLine."Unit of Measure Code", ReservQty, LineNo);
    //         exit(true);
    //     end;
    // end;

    // before create transaction check if inv. needs to be updated
    local procedure CreateTempItemJnlLine(var TempItemJournalLine: Record "Item Journal Line" temporary; InternalDocNo: Code[10]; SalesOrderNo: Code[20]; ItemNo: Code[20]; LotNo: Code[20]; LocationCode: Code[10]; UOMCode: Code[10]; ReservQty: Decimal; var LineNo: Integer)
    var
        LAXEDISetup: Record "LAX EDI Setup";
    begin
        LAXEDISetup.Get();

        LineNo += 10000;
        TempItemJournalLine.Reset();
        TempItemJournalLine.Init();
        TempItemJournalLine."Journal Template Name" := LAXEDISetup."SBC 810 Journal Template Name";
        TempItemJournalLine."Journal Batch Name" := LAXEDISetup."SBC 810 Journal Batch Name";
        TempItemJournalLine."Line No." := LineNo;
        TempItemJournalLine."Entry Type" := TempItemJournalLine."Entry Type"::"Positive Adjmt.";
        TempItemJournalLine."Document No." := LAXEDISetup."SBC 810 Document No.";
        TempItemJournalLine."Location Code" := LocationCode;
        TempItemJournalLine.Description := InternalDocNo;
        TempItemJournalLine."Item No." := ItemNo;
        TempItemJournalLine."Unit of Measure Code" := UOMCode;
        TempItemJournalLine.Quantity := ReservQty;
        TempItemJournalLine."Lot No." := LotNo;
        TempItemJournalLine.Insert(false);
    end;

    local procedure CreateTempSalesLine(var TempSalesLine: Record "Sales Line" temporary; SalesOrderNo: Code[20]; ItemNo: Code[20]; ReservQty: Decimal; LineNo: Integer)
    begin
        TempSalesLine.Reset();
        if TempSalesLine.Get(TempSalesLine."Document Type"::Order, SalesOrderNo, LineNo) then begin
            TempSalesLine.Quantity += ReservQty;
            TempSalesLine."Qty. to Ship" += ReservQty;
            TempSalesLine.Modify(false);
        end else begin
            TempSalesLine.Init();
            TempSalesLine."Document Type" := TempSalesLine."Document Type"::Order;
            TempSalesLine."Document No." := SalesOrderNo;
            TempSalesLine."Line No." := LineNo;
            TempSalesLine.Quantity := ReservQty;
            TempSalesLine."Qty. to Ship" := ReservQty;
            TempSalesLine.Insert(false);
        end;
    end;

    local procedure GetLastEntryNo(): Integer
    var
        // ReservationEntry: Record "Reservation Entry";
        TrackingSpecification: Record "Tracking Specification";
    begin
        // if ReservationEntry.FindLast() then;
        // exit(ReservationEntry."Entry No.");
        if TrackingSpecification.FindLast() then;
        exit(TrackingSpecification."Entry No.");
    end;

    #endregion createTempEntries

    #region createReservationEntries

    local procedure CreateReservationEntries(var TempSalesLine: Record "Sales Line" temporary; var TempReservationEntry: Record "Tracking Specification" temporary)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Tracking Specification";
        ReadyToShip: Boolean;
        TrackEntryNo: Integer;
    begin
        TrackEntryNo := GetLastEntryNo();

        TempSalesLine.Reset();
        if TempSalesLine.FindSet() then begin
            ClearSalesLineQtyToShip(TempSalesLine."Document No.");
            repeat

                TempReservationEntry.Reset();
                TempReservationEntry.SetRange("Source Type", Database::"Sales Line");
                TempReservationEntry.SetRange("Source ID", TempSalesLine."Document No.");
                TempReservationEntry.SetRange("Source Ref. No.", TempSalesLine."Line No.");
                if TempReservationEntry.FindSet() then begin
                    repeat
                        TrackEntryNo += 1;
                        ReservationEntry.Init();
                        ReservationEntry."Entry No." := TrackEntryNo;
                        ReservationEntry."Source Type" := TempReservationEntry."Source Type";
                        ReservationEntry."Source Subtype" := TempReservationEntry."Source Subtype";
                        ReservationEntry."Source ID" := TempReservationEntry."Source ID";
                        ReservationEntry."Source Ref. No." := TempReservationEntry."Source Ref. No.";
                        ReservationEntry.Validate("Item No.", TempReservationEntry."Item No.");
                        ReservationEntry.Validate("Qty. per Unit of Measure", TempReservationEntry."Qty. per Unit of Measure");
                        ReservationEntry.Validate("Quantity (Base)", TempReservationEntry."Quantity (Base)");
                        ReservationEntry.Validate("Location Code", TempReservationEntry."Location Code");
                        ReservationEntry.Validate("Lot No.", TempReservationEntry."Lot No.");
                        ReservationEntry.Insert(true);

                        SalesLine.Reset();
                        SalesLine.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.");
                        SalesLine.Validate("Qty. to Ship", TempSalesLine."Qty. to Ship");
                        SalesLine.Modify(true);

                        if not ReadyToShip then begin
                            SalesHeader.Get(SalesHeader."Document Type"::Order, TempSalesLine."Document No.");
                            SalesHeader.Ship := true;
                            SalesHeader.Modify();
                            ReadyToShip := true;
                        end;
                    until TempReservationEntry.Next() = 0;
                end;
            until TempSalesLine.Next() = 0;

            if ReadyToShip then
                Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
        end;
    end;

    // local procedure CreateReservationEntries(var TempSalesLine: Record "Sales Line" temporary; var TempReservationEntry: Record "Reservation Entry" temporary)
    // var
    //     SalesHeader: Record "Sales Header";
    //     SalesLine: Record "Sales Line";
    //     ReservationEntry: Record "Reservation Entry";
    //     ReadyToShip: Boolean;
    // begin
    //     TempSalesLine.Reset();
    //     if TempSalesLine.FindSet() then begin
    //         ClearSalesLineQtyToShip(TempSalesLine."Document No.");
    //         repeat

    //             TempReservationEntry.Reset();
    //             TempReservationEntry.SetRange("Source Type", Database::"Sales Line");
    //             TempReservationEntry.SetRange("Source ID", TempSalesLine."Document No.");
    //             TempReservationEntry.SetRange("Source Ref. No.", TempSalesLine."Line No.");
    //             if TempReservationEntry.FindSet() then begin
    //                 repeat
    //                     ReservationEntry.Init();
    //                     ReservationEntry.Validate("Source Type", TempReservationEntry."Source Type");
    //                     ReservationEntry.Validate("Source ID", TempReservationEntry."Source ID");
    //                     ReservationEntry.Validate("Source Ref. No.", TempReservationEntry."Source Ref. No.");
    //                     ReservationEntry.Validate("Item No.", TempReservationEntry."Item No.");
    //                     ReservationEntry.Validate("Qty. per Unit of Measure", TempReservationEntry."Qty. per Unit of Measure");
    //                     ReservationEntry.Validate(Quantity, TempReservationEntry.Quantity);
    //                     ReservationEntry.Validate("Location Code", TempReservationEntry."Location Code");
    //                     if ReservationEntry.Insert(true) then begin
    //                         SalesLine.Reset();
    //                         SalesLine.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.");
    //                         SalesLine.Validate("Qty. to Ship", TempSalesLine."Qty. to Ship");
    //                         SalesLine.Modify(true);

    //                         if not ReadyToShip then begin
    //                             SalesHeader.Get(SalesHeader."Document Type"::Order, TempSalesLine."Document No.");
    //                             SalesHeader.Ship := true;
    //                             SalesHeader.Modify();
    //                         end;
    //                     end;
    //                 until TempReservationEntry.Next() = 0;
    //             end;
    //         until TempSalesLine.Next() = 0;

    //         Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
    //     end;
    // end;

    local procedure ClearSalesLineQtyToShip(SalesOrderNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesOrderNo);
        SalesLine.ModifyAll("Qty. to Ship", 0);
    end;

    #endregion createReservationEntries  

    #region checkToContinue

    local procedure Has945(CustomerRefNo: Code[35]): Boolean
    var
        EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.";
    begin
        EDIRecDocHdr.SetRange("EDI Document No.", '945');
        EDIRecDocHdr.SetRange("Customer Reference No.", CustomerRefNo);
        exit(not EDIRecDocHdr.IsEmpty);
    end;

    local procedure NoLots(InternalDocNo: Code[10]): Boolean
    var
        EDIReceiveDocField: Record "LAX EDI Receive Document Field";
    begin
        EDIReceiveDocField.SetRange("Internal Doc. No.", InternalDocNo);
        EDIReceiveDocField.SetRange(Segment, 'REF');
        EDIReceiveDocField.SetRange(Element, '02');
        EDIReceiveDocField.SetFilter("Field Text Value", '<>%1', '');
        if EDIReceiveDocField.IsEmpty then
            exit(true);
    end;

    #endregion checkToContinue

    #region getEDIFieldVars

    local procedure GetReservationVariables(InternalDocNo: Code[10]; var ItemNo: Code[20]; var LotNo: Code[20]; var ReservQty: Decimal; SalesOrderNo: Code[20]; SegmentGroup: Integer): Boolean
    var
        EDIReceiveDocField: Record "LAX EDI Receive Document Field";
    begin
        Clear(ItemNo);
        Clear(LotNo);
        Clear(ReservQty);
        EDIReceiveDocField.SetRange("Internal Doc. No.", InternalDocNo);
        EDIReceiveDocField.SetRange(Segment, 'IT1');
        EDIReceiveDocField.SetRange("Segment Group", SegmentGroup);
        if EDIReceiveDocField.FindSet() then begin
            repeat
                case EDIReceiveDocField.Element of
                    '02':
                        if ReservQty = 0 then
                            if Evaluate(ReservQty, EDIReceiveDocField."Field Text Value") then;
                    '09':
                        ItemNo := EDIReceiveDocField."Field Text Value";
                end;
            until EDIReceiveDocField.Next() = 0;
            if GetLotNo(InternalDocNo, LotNo, SegmentGroup) then
                exit(true);
        end;
    end;

    local procedure GetLotNo(InternalDocNo: Code[10]; var LotNo: Code[20]; SegmentGroup: Integer): Boolean
    var
        EDIReceiveDocField: Record "LAX EDI Receive Document Field";
    begin
        EDIReceiveDocField.SetRange("Internal Doc. No.", InternalDocNo);
        EDIReceiveDocField.SetRange(Segment, 'REF');
        EDIReceiveDocField.SetRange(Element, '02');
        EDIReceiveDocField.SetRange("Segment Group", SegmentGroup);
        if EDIReceiveDocField.FindFirst() then begin
            LotNo := CopyStr(EDIReceiveDocField."Field Text Value", 1, 20);
            exit(LotNo <> '');
        end;
    end;

    local procedure GetOrderNo(InternalDocNo: Code[10]): Code[20]
    var
        EDIReceiveDocField: Record "LAX EDI Receive Document Field";
    begin
        EDIReceiveDocField.SetRange("Internal Doc. No.", InternalDocNo);
        EDIReceiveDocField.SetRange(Segment, 'BIG');
        EDIReceiveDocField.SetRange(Element, '02');
        if EDIReceiveDocField.FindFirst() then;
        exit(CopyStr(EDIReceiveDocField."Field Text Value", 1, 20));
    end;

    #endregion getEDIFieldVars

    #region process810withoutLotNumbers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Item Tracking", 'OnbeforeupdateTrackingSpecification', '', false, false)]
    procedure CreateItemTrackingOnBeforeUpdateTrackingSpecification(EDIRecDocFields: Record "LAX EDI Receive Document Field"; ReservEntryEDIRecDocField: Record "LAX EDI Receive Document Field"; var TableRef: RecordRef; var QtytoInvoiceBase: Decimal; LotNo: Code[50]; SerialNo: Code[50]; ExpirationDate: Date; WarrantyDate: Date; var IsHandled: Boolean; NewDoc: Boolean)
    var
        TrackingSpecification: Record "Tracking Specification";
        TrackingSpecification2: Record "Tracking Specification";
        TrackingSpecification3: Record "Tracking Specification";
        PurchaseLine: Record "Purchase Line";
        TrackingUpdated: Boolean;
        OrigQtytoInvoiceBase: Decimal;
        AvailableQtytoInvoiceBase: Decimal;
        RemainingQtytoInvoiceBase: Decimal;
        TrackingSpecificationFound: Boolean;
        LastSerialNo: Code[50];
        LastLotNo: Code[50];
        LastExpirationDate: Date;
        LastWarrantyDate: Date;
        Finished: Boolean;
        TrackingSpecificationNotFoundLbl: label 'SBC-Tracking Specification record not found for %1 Line %2 Lot No. %3 Serial No. %4.';
    begin
        if LotNo <> 'ABFLOT' then begin
            IsHandled := false;
            exit;
        end;

        TrackingSpecification.LockTable(true);
        case TableRef.Number of
            Database::"Purchase Line":
                begin
                    TableRef.SetTable(PurchaseLine);
                    TrackingSpecificationFound := false;
                    TrackingSpecification.Reset();
                    TrackingSpecification.SetRange("Source ID", PurchaseLine."Document No.");
                    TrackingSpecification.SetRange("Source Type", Database::"Purchase Line");
                    TrackingSpecification.SetRange("Source Subtype", PurchaseLine."Document Type".AsInteger());
                    TrackingSpecification.SetRange("Source Ref. No.", PurchaseLine."Line No.");
                    TrackingSpecification.SetRange("Item No.", PurchaseLine."No.");
                    TrackingSpecification.SetRange("Variant Code", PurchaseLine."Variant Code");
                    TrackingSpecification.SetRange("Location Code", PurchaseLine."Location Code");
                    TrackingSpecification.SetRange("Source Batch Name", '');
                    TrackingSpecification.SetRange("Source Prod. Order Line", 0);
                    TrackingSpecification.SetFilter("Quantity Handled (Base)", '<>%1', 0);
                    if TrackingSpecification.Find('-') then
                        TrackingSpecificationFound := true
                    else
                        Error(TrackingSpecificationNotFoundLbl, Format(PurchaseLine."Document Type"), PurchaseLine."Document No.", LastLotNo, LastSerialNo);
                end;
        end;
        OrigQtytoInvoiceBase := 0;
        RemainingQtytoInvoiceBase := 0;
        OrigQtytoInvoiceBase := QtytoInvoiceBase;
        AvailableQtytoInvoiceBase := QtytoInvoiceBase;
        repeat
            if TrackingSpecification."Quantity Handled (Base)" - TrackingSpecification."Quantity Invoiced (Base)" <> 0 then begin
                TrackingUpdated := false;
                RemainingQtytoInvoiceBase := TrackingSpecification."Quantity Handled (Base)" - TrackingSpecification."Quantity Invoiced (Base)";
                case true of
                    QtytoInvoiceBase = RemainingQtytoInvoiceBase:
                        begin
                            TrackingSpecification.Validate("Qty. to Invoice (Base)", QtytoInvoiceBase);
                            TrackingUpdated := true;
                            AvailableQtytoInvoiceBase := Abs(AvailableQtytoInvoiceBase) - Abs(QtytoInvoiceBase);
                        end;
                    Abs(QtytoInvoiceBase) > Abs(RemainingQtytoInvoiceBase):
                        begin
                            TrackingSpecification2.Copy(TrackingSpecification);
                            if TrackingSpecification2.Next() = 0 then begin
                                TrackingSpecification.Validate("Qty. to Invoice (Base)", QtytoInvoiceBase);
                                TrackingUpdated := true;
                            end else begin
                                TrackingSpecification.Validate("Qty. to Invoice (Base)", RemainingQtytoInvoiceBase);
                                QtytoInvoiceBase := QtytoInvoiceBase - RemainingQtytoInvoiceBase;
                                TrackingUpdated := true;
                            end;
                            AvailableQtytoInvoiceBase := Abs(AvailableQtytoInvoiceBase) - Abs(RemainingQtytoInvoiceBase);
                        end;
                    else begin
                        TrackingSpecification.Validate("Qty. to Invoice (Base)", QtytoInvoiceBase);
                        TrackingUpdated := true;
                        AvailableQtytoInvoiceBase := Abs(AvailableQtytoInvoiceBase) - Abs(QtytoInvoiceBase);
                    end;
                end;
                TrackingSpecification.Modify();
            end;
        //end;
        until (TrackingSpecification.Next() = 0) or (AvailableQtytoInvoiceBase = 0);
        IsHandled := true;
    end;

    #endregion process810withoutLotNumbers

}
