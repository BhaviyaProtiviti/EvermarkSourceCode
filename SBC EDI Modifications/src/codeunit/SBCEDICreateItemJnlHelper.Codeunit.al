codeunit 50153 "SBC EDI Create Item Jnl Helper"
{
    //contains functions to create Item Jnl Lines used to adjust Inventory used with 945/846/810
    var
        OnHand: Decimal;

    #region hidePostDialog

    procedure ItemJnlHideDialog(TemplateName: Code[10]; BatchName: Code[10]; DocumentNo: Code[20]): Boolean
    var
        LAXEDISetup: Record "LAX EDI Setup";
    begin
        LAXEDISetup.Get();
        if (TemplateName = LAXEDISetup."SBC 945 Journal Template Name") and (BatchName = LAXEDISetup."SBC 945 Journal Batch Name") and (DocumentNo = LAXEDISetup."SBC 945 Document No.") then
            exit(LAXEDISetup."SBC 945 Adjust Inventory");

        if (TemplateName = LAXEDISetup."SBC 945 Journal Template Name") and (BatchName = LAXEDISetup."SBC 810 Journal Batch Name") and (DocumentNo = LAXEDISetup."SBC 810 Document No.") then
            exit(LAXEDISetup."SBC 810 Allow Create Shipment");
    end;

    #endregion hidePostDialog

    #region createTempJnlLine

    //used for 945 and 846
    procedure CreateTempItemJnlLine(var TempItemJournalLine: Record "Item Journal Line" temporary; LAXEDISetup: Record "LAX EDI Setup"; var LineNo: Integer; ItemNo: Code[20]; UOMCode: Code[10]; LotNo: Code[50]; LineQty: Decimal; LocationCode: Code[10]; LineDescription: Text; EntryType: Enum "Item Journal Entry Type")
    begin
        LineNo += 10000;
        TempItemJournalLine.Reset();
        TempItemJournalLine.Init();
        TempItemJournalLine."Journal Template Name" := LAXEDISetup."SBC 945 Journal Template Name";
        TempItemJournalLine."Journal Batch Name" := LAXEDISetup."SBC 945 Journal Batch Name";
        TempItemJournalLine."Line No." := LineNo;
        TempItemJournalLine."Entry Type" := EntryType;
        TempItemJournalLine."Document No." := LAXEDISetup."SBC 945 Document No.";
        TempItemJournalLine."Location Code" := LocationCode;
        TempItemJournalLine.Description := LineDescription;
        TempItemJournalLine."Item No." := ItemNo;
        TempItemJournalLine."Unit of Measure Code" := UOMCode;
        TempItemJournalLine.Quantity := LineQty;
        TempItemJournalLine."Lot No." := LotNo;
        TempItemJournalLine.Insert(false);
    end;

    #endregion createTempJnlLine

    #region createInventory

    procedure CreateInventory(var TempItemJournalLine: Record "Item Journal Line" temporary; EDIOption: Integer)
    var
        QtyAvailableByLot: Decimal;
        OrigQty: decimal;
        LineNo: Integer;
        HasJnlLines: Boolean;
    begin
        TempItemJournalLine.Reset();
        if TempItemJournalLine.FindSet() then begin
            LineNo := GetLastLineNo(EDIOption);
            repeat
                OrigQty := TempItemJournalLine.Quantity;
                QtyAvailableByLot := FindQuantityAvailableByLot(TempItemJournalLine);
                if TempItemJournalLine.Quantity <> 0 then
                    CreateItemJournal(TempItemJournalLine, LineNo, QtyAvailableByLot, OrigQty);
                if not HasJnlLines then
                    HasJnlLines := true;
            until TempItemJournalLine.Next() = 0;
            if HasJnlLines then
                PostItemJournal(EDIOption);
        end;
    end;

    procedure FindQuantityAvailableByLot(var TempItemJournalLine: Record "Item Journal Line" temporary): Decimal
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
    begin
        TempTrackingSpecification.Reset();
        TempTrackingSpecification.InitFromItemJnlLine(TempItemJournalLine);
        TempTrackingSpecification."Location Code" := TempItemJournalLine."Location Code";
        TempTrackingSpecification."Lot No." := TempItemJournalLine."Lot No.";
        exit(GetAvailableLotQty(TempTrackingSpecification, TempItemJournalLine))
    end;

    local procedure CreateItemJournal(var TempItemJournalLine: Record "Item Journal Line" temporary; var LineNo: Integer; AvailQty: Decimal; OrigQty: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LineNo += 10000;

        ItemJournalLine.Init();
        ItemJournalLine."Journal Template Name" := TempItemJournalLine."Journal Template Name";
        ItemJournalLine."Journal Batch Name" := TempItemJournalLine."Journal Batch Name";
        ItemJournalLine."Entry Type" := TempItemJournalLine."Entry Type";
        ItemJournalLine."Document No." := TempItemJournalLine."Document No.";
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine."Posting Date" := CalcDate('<-1D>', Today);
        ItemJournalLine.Validate("Item No.", TempItemJournalLine."Item No.");
        ItemJournalLine.Validate("Location Code", TempItemJournalLine."Location Code");
        ItemJournalLine.Validate("Unit of Measure Code", TempItemJournalLine."Unit of Measure Code");
        ItemJournalLine.Validate(Quantity, TempItemJournalLine.Quantity);
        ItemJournalLine.Validate("Lot No.", TempItemJournalLine."Lot No.");
        ItemJournalLine.Description := TempItemJournalLine.Description;
        ItemJournalLine.Insert(true);
    end;

    procedure GetLastLineUOM(var LastLineNo: Integer; var UOMCode: Code[10]; EDIOption: Integer)
    begin
        LastLineNo := GetLastLineNo(EDIOption);
        UOMCode := GetCaseUOMCode();
    end;

    local procedure GetLastLineNo(EDIOption: Integer): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
        LAXEDISetup: Record "LAX EDI Setup";
    begin
        LAXEDISetup.Get();
        ItemJournalLine.ReadIsolation := IsolationLevel::ReadUncommitted;
        if EDIOption = 945 then begin
            ItemJournalLine.SetRange("Journal Template Name", LAXEDISetup."SBC 945 Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", LAXEDISetup."SBC 945 Journal Batch Name");
        end else begin
            ItemJournalLine.SetRange("Journal Template Name", LAXEDISetup."SBC 810 Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", LAXEDISetup."SBC 810 Journal Batch Name");
        end;
        ItemJournalLine.SetLoadFields("Line No.");
        if ItemJournalLine.IsEmpty() then
            exit;
        ItemJournalLine.FindLast();
        exit(ItemJournalLine."Line No.");
    end;

    procedure GetAvailableLotQty(var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempItemJournalLine: Record "Item Journal Line" temporary): Decimal
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
        AvailableLotQty: Decimal;
        QtyOnHand: Decimal;
        ReservedSalesQty: Decimal;
        QtyBase: Decimal;
    begin
        if TempTrackingSpecification."Lot No." = '' then
            exit(0);

        QtyOnHand := QuantityOnHand(TempTrackingSpecification."Item No.", TempTrackingSpecification."Lot No.", TempTrackingSpecification."Location Code");
        getAvailableLotQty(TempTrackingSpecification, ReservedSalesQty);

        OnHand := QtyOnHand;

        ItemUnitofMeasure.Get(TempItemJournalLine."Item No.", TempItemJournalLine."Unit of Measure Code");
        AvailableLotQty := (QtyOnHand - ReservedSalesQty);
        if AvailableLotQty <> 0 then
        AvailableLotQty := (AvailableLotQty / ItemUnitofMeasure."Qty. per Unit of Measure");

        if AvailableLotQty >= QtyBase then
            TempItemJournalLine.Quantity := 0
        else
                TempItemJournalLine.Quantity := ABS(AvailableLotQty);
        exit(AvailableLotQty);
    end;

    local procedure GetAvailableLotQty(var TempTrackingSpecification: Record "Tracking Specification" temporary; var AvailableLotQty: Decimal)
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.Reset();
        ReservEntry.SetCurrentKey(
          "Item No.", "Variant Code", "Location Code", "Item Tracking", "Reservation Status", "Lot No.", "Serial No.");
        ReservEntry.SetRange("Item No.", TempTrackingSpecification."Item No.");
        ReservEntry.SetRange("Lot No.", TempTrackingSpecification."Lot No.");
        ReservEntry.SetRange("Location Code", TempTrackingSpecification."Location Code");
        ReservEntry.SetFilter("Item Tracking", '<>%1', ReservEntry."Item Tracking"::None);
        ReservEntry.SetRange("Source Type", Database::"Sales Line");
        if ReservEntry.FindSet() then
            repeat
                if CanIncludeReservEntryToTrackingSpec(ReservEntry) then
                    AvailableLotQty += ReservEntry."Quantity (Base)";
            until ReservEntry.Next() = 0;
        AvailableLotQty := -(AvailableLotQty);
    end;

    local procedure CanIncludeReservEntryToTrackingSpec(TempReservEntry: Record "Reservation Entry" temporary) Result: Boolean
    var
        SalesLine: Record "Sales Line";
    begin

        if (TempReservEntry."Reservation Status" = TempReservEntry."Reservation Status"::Prospect) and
        (TempReservEntry."Source Type" = DATABASE::"Sales Line") and (TempReservEntry."Source Subtype" = 2) then begin
            SalesLine.Get(TempReservEntry."Source Subtype", TempReservEntry."Source ID", TempReservEntry."Source Ref. No.");
            if SalesLine."Shipment No." <> '' then
                exit(false);
        end;

        exit(true);
    end;


    local procedure QuantityOnHand(ItemNo: Code[20]; LotNo: Code[50]; LocationCode: Code[10]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange("Lot No.", LotNo);
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        if ItemLedgerEntry.IsEmpty() then
            exit;
        ItemLedgerEntry.CalcSums("Remaining Quantity");
        exit(ItemLedgerEntry."Remaining Quantity");
    end;


    local procedure GetCaseUOMCode(): Code[10]
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.SetRange("SBC Case Unit", true);
        UnitofMeasure.SetLoadFields(Code, "SBC Case Unit");
        if UnitofMeasure.IsEmpty() then
            exit;
        UnitofMeasure.FindFirst();
        exit(UnitofMeasure.Code);
    end;

    #endregion createInventory

    #region postItemJournal

    procedure PostItemJournal(EDIOption: Integer)
    var
        ItemJournalLine: Record "Item Journal Line";
        LAXEDISetup: Record "LAX EDI Setup";
    begin
        LAXEDISetup.Get();

        if EDIOption = 945 then begin
            ItemJournalLine.SetRange("Journal Template Name", LAXEDISetup."SBC 945 Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", LAXEDISetup."SBC 945 Journal Batch Name");
        end else begin
            ItemJournalLine.SetRange("Journal Template Name", LAXEDISetup."SBC 810 Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", LAXEDISetup."SBC 810 Journal Batch Name");
        end;
        ItemJournalLine.SetFilter(Quantity, '<>%1', 0);
        if ItemJournalLine.IsEmpty() then
            exit;
        if Database.IsInWriteTransaction() then
            Commit();
        ItemJournalLine.FindFirst();
        if CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", ItemJournalLine) then
            exit;
    end;

    #endregion postItemJournal
}
