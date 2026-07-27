codeunit 50146 "ELBLotCodeparsingManagement"
{

    procedure ProcessLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry");
    var
        Item: Record "Item";
    begin
        if not (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Purchase) then
            exit;
        if ItemLedgerEntry."Lot No." = '' then
            exit;
        if not ValidateSetup() then
            exit;
        if not Item.Get(ItemLedgerEntry."Item No.") then
            exit;
        if Item."SBC Shelf Life (Days)" = 0 then
            exit;
        UpdateExpirationDate(ItemLedgerEntry, Item."SBC Shelf Life (Days)");
    end;

    procedure ProcessTrackingSpecification(var ItemTrackingSpecification: Record "Tracking Specification");
    var
        Item: Record "Item";
    begin
        if ItemTrackingSpecification."Lot No." = '' then
            exit;
        if not ValidateSetup() then
            exit;
        if not Item.Get(ItemTrackingSpecification."Item No.") then
            exit;
        if Item."SBC Shelf Life (Days)" = 0 then
            exit;
        UpdateExpirationDate(ItemTrackingSpecification, Item."SBC Shelf Life (Days)");
    end;

    procedure ProcessTrackingSpecification(var ItemJournalLine: Record "Item Journal Line");
    var
        Item: Record "Item";
    begin
        if ItemJournalLine."Lot No." = '' then
            exit;
        if not ValidateSetup() then
            exit;
        if not Item.Get(ItemJournalLine."Item No.") then
            exit;
        if Item."SBC Shelf Life (Days)" = 0 then
            exit;
        UpdateExpirationDate(ItemJournalLine, Item."SBC Shelf Life (Days)");
    end;

    procedure ProcessAjustmentItemJournalLines(ItemNo: Code[20]; ShelfLife: Integer);
    var
        ConfirmMsg: label 'Shelf life has been updated. Do you want to adjust the existing inventory to reflect new expiration date?';
    begin
        if GuiAllowed() then
            if not Dialog.Confirm(ConfirmMsg) then
                exit;
        if not ValidateSetup() then
            exit;
        if not LedgerEntriesExist(ItemNo) then
            exit;

        PostJournalLines(BuildJournalLines(ShelfLife));
    end;

    procedure PostJournalLines(ItemJournalLine: Record "Item Journal Line");
    var
        ItemJournalPost: Codeunit "Item Jnl.-Post";
    begin
        if ItemJournalLine.IsEmpty then
            exit;
        if ItemJournalLine."Journal Template Name" = '' then
            exit;
        ItemJournalPost.Run(ItemJournalLine);
    end;

    procedure BuildJournalLines(ShelfLife: Integer): Record "Item Journal Line";
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLine2: Record "Item Journal Line";
        Item: Record "Item";
        LineNo: Integer;
        ItemJournalBatch: Record "Item Journal Batch";
        DocumentNo: Code[20];
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ReserveMgt: Codeunit "Reservation Management";
        DimMgt: Codeunit DimensionManagement;
    begin
        ItemJournalBatch := GetBatchInformation();
        DocumentNo := NoSeriesManagement.GetNextNo(ItemJournalBatch."No. Series", Today(), false);
        if ItemLedgerEntry.FindSet() then begin
            LineNo := 0;
            Item.Get(ItemLedgerEntry."Item No.");
            repeat
                if not (ParseLotCoding(ItemLedgerEntry."Lot No.") = 0D) then begin
                    LineNo += 10000;
                    ItemJournalLine.Init();
                    ItemJournalLine."Journal Template Name" := InventorySetup."SBC AdjmtItemJournalTemplate";
                    ItemJournalLine."Journal Batch Name" := InventorySetup."SBC Adjustment Batch";
                    ItemJournalLine."Document No." := DocumentNo;
                    ItemJournalLine.Validate("Item No.", ItemLedgerEntry."Item No.");
                    ItemJournalLine."Line No." := LineNo;
                    ItemJournalLine."Location Code" := ItemLedgerEntry."Location Code";
                    ItemJournalLine."Posting Date" := Today();
                    ItemJournalLine.Validate("Quantity", ItemLedgerEntry."Remaining Quantity");
                    ItemJournalLine."Lot No." := ItemLedgerEntry."Lot No.";
                    ItemJournalLine."Expiration Date" := ItemLedgerEntry."Expiration Date";
                    ItemJournalLine."New Item Expiration Date" := ParseLotCoding(ItemLedgerEntry."Lot No.") + ShelfLife;
                    ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::Transfer;
                    ItemJournalLine."Unit Amount" := 0;
                    ItemJournalLine.Amount := 0;
                    ItemJournalLine."Amount (ACY)" := 0;
                    ItemJournalLine."New Location Code" := ItemLedgerEntry."Location Code";
                    ItemJournalLine.Validate("Dimension Set ID", ItemLedgerEntry."Dimension Set ID");
                    ItemJournalLine.Validate("New Dimension Set ID", ItemLedgerEntry."Dimension Set ID");
                    ItemJournalLine.Validate("New Shortcut Dimension 1 Code", ItemLedgerEntry."Global Dimension 1 Code");
                    ItemJournalLine.Validate("New Shortcut Dimension 2 Code", ItemLedgerEntry."Global Dimension 2 Code");
                    ItemJournalLine.Insert(true);
                    CreateReservationEntry(ItemJournalLine, Item);
                end;
            until ItemLedgerEntry.Next() = 0;
            exit(ItemJournalLine);
        end;
    end;

    local procedure CreateReservationEntry(ItemJournalLine: Record "Item Journal Line"; Item: Record "Item");
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Init();
        ReservationEntry."Entry No." := NextEntryNo;
        ReservationEntry."Item No." := ItemJournalLine."Item No.";
        ReservationEntry."Location Code" := ItemJournalLine."Location Code";
        ReservationEntry."Variant Code" := ItemJournalLine."Variant Code";
        ReservationEntry.Validate("Quantity (Base)", -ItemJournalLine."Quantity (Base)");
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry."Source Type" := Database::"Item Journal Line";
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"4";
        ReservationEntry."Source ID" := ItemJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ItemJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ItemJournalLine."Line No.";
        ReservationEntry."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
        ReservationEntry.Validate("Lot No.", ItemJournalLine."Lot No.");
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Created By" := UserId;
        ReservationEntry.Positive := false;
        ReservationEntry."Creation Date" := WorkDate();
        ReservationEntry."New Expiration Date" := ItemJournalLine."New Item Expiration Date";
        ReservationEntry."New Lot No." := ItemJournalLine."Lot No.";
        ReservationEntry.Insert();
    end;

    local procedure NextEntryNo(): Integer
    var
        ReserveEntry: Record "Reservation Entry";
        LastEntryNo: Integer;
    begin
        ReserveEntry.Reset();
        if LastEntryNo = 0 then
            if ReserveEntry.FindLast() then
                LastEntryNo := ReserveEntry."Entry No.";
        LastEntryNo += 1;
        exit(LastEntryNo);
    end;

    local procedure GetBatchInformation(): Record "Item Journal Batch"
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalBatch.Get(InventorySetup."SBC AdjmtItemJournalTemplate", InventorySetup."SBC Adjustment Batch");
        exit(ItemJournalBatch);
    end;

    local procedure SetLedgerEntryFilters(ItemNo: Code[20]);
    begin
        ItemLedgerEntry.SetFilter("Item No.", ItemNo);
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>0');
        ItemLedgerEntry.SetFilter("Lot No.", '<> %1', ' ');
        ItemLedgerEntry.SetFilter("Expiration Date", '>= %1', Today());
    end;

    local procedure LedgerEntriesExist(ItemNo: Code[20]): Boolean;
    begin
        SetLedgerEntryFilters(ItemNo);
        exit(not ItemLedgerEntry.IsEmpty());
    end;

    local procedure UpdateExpirationDate(var ItemLedgerEntry: Record "Item Ledger Entry"; ShelfLife: Integer);
    begin
        if not (ParseLotCoding(ItemLedgerEntry."Lot No.") = 0D) then
            ItemLedgerEntry."Expiration Date" := ParseLotCoding(ItemLedgerEntry."Lot No.") + ShelfLife;
    end;

    local procedure UpdateExpirationDate(var ItemTrackingSpecification: Record "Tracking Specification"; ShelfLife: Integer);
    var
        ItemJournalLine: Record "Item Journal Line";
        ItmeJournal: Page "Item Journal";
    begin
        if not (ParseLotCoding(ItemTrackingSpecification."Lot No.") = 0D) then
            ItemTrackingSpecification."Expiration Date" := ParseLotCoding(ItemTrackingSpecification."Lot No.") + ShelfLife;
    end;

    local procedure UpdateExpirationDate(var ItemJournalLine: Record "Item Journal Line"; ShelfLife: Integer);
    begin
        if not (ParseLotCoding(ItemJournalLine."Lot No.") = 0D) then
            ItemJournalLine."Expiration Date" := ParseLotCoding(ItemJournalLine."Lot No.") + ShelfLife;
    end;

    local procedure IsLotCodingParsingEnabled(): Boolean;
    begin
        InventorySetup.Get();
        exit(InventorySetup."SBC Parse Lot Code");
    end;

    procedure ParseLotCoding(LotCoding: Text[10]): Date
    var
        InvalidLotCodeMsg: Label 'The lot code %1 is not valid.';
        ConfirmMsg: label 'This lot code %1 is not within the expected format. Do you want to continue?';
    begin
        if not ValidateLotCoding(LotCoding) then
            if GuiAllowed() then
                if Dialog.Confirm(ConfirmMsg, true, LotCoding) then
                    exit;
        exit(GetDateFromLotCoding(LotCoding, InventorySetup."SBC Lot Code Date Format"));
    end;

    local procedure CleanLotCoding(var LotCoding: Text[10]);
    begin
        if Text.StrLen(LotCoding) < 10 then
            LotCoding := CopyStr(LotCoding, 1, 4) + GetCurrentYearTenthDigit() + CopyStr(LotCoding, 5, 4);
    end;

    local procedure GetCurrentYearTenthDigit(): Text[1];
    var
        CurrentYear: Text[4];
    begin
        CurrentYear := Format(Today(), 0, '<Year4>');
        exit(CopyStr(CurrentYear, 3, 1));
    end;

    procedure GetDateFromLotCoding(LotCoding: Text[10]; LanguageID: Integer): Date;
    begin
        CleanLotCoding(LotCoding);
        exit(ProcessLotCoding(LotCoding, LanguageID));
    end;

    procedure ProcessLotCoding(LotCoding: Text[10]; LanguageID: Integer): Date;
    var
        DateTxt: Text[6];
    begin
        DateTxt := CopyStr(LotCoding, 1, 6);
        exit(createDateBasedOnLanguageID(DateTxt, LanguageID));
    end;

    procedure ValidateLotCoding(LotCoding: Text[10]): Boolean;
    begin
        if not isValidLotLength(LotCoding) then
            exit(false);
        if not isValidDateFormat(LotCoding) then
            exit(false);
        exit(true);
    end;

    local procedure isValidLotLength(LotCoding: Text[10]): Boolean;
    var
        StrLen: Integer;
    begin
        StrLen := Text.StrLen(LotCoding);
        if StrLen = 10 then
            exit(true);
        if StrLen = 9 then
            exit(true);
        exit(false);
    end;

    local procedure isValidDateFormat(LotCoding: Text[10]): Boolean;
    var
        DateTxt: Text[5];
    begin
        DateTxt := CopyStr(Lotcoding, 1, 5);
        exit(TypeHelper.IsNumeric(DateTxt));
    end;

    procedure createDateBasedOnLanguageID(DateTxt: Text[6]; LanguageID: Integer): Date
    var
        Date: Date;
        InvalidDateFormat: Label 'The date %1 is not valid. The current date format is for %2';
        Language: Record "Language";
    begin
        if not Evaluate(Date, DateTxt) then begin
            Language.SetRange("Windows Language ID", LanguageID);
            if not Language.FindFirst() then begin
                Language.SetRange("Windows Language ID", System.WindowsLanguage);
                Language.FindFirst();
                Error(InvalidDateFormat, DateTxt, Language.Name);
            end
            else
                Error(InvalidDateFormat, DateTxt, Language.Name);
        end;
        exit(Date);
    end;

    local procedure ValidateSetup(): Boolean;
    var
        ErrorMsg: label 'This users current region format is not the same as the one set in the Inventory Setup.';
    begin
        if not IsLotCodingParsingEnabled() then
            exit;
        if System.WindowsLanguage <> InventorySetup."SBC Lot Code Date Format" then
            Error(ErrorMsg);
        exit(true);
    end;

    var
        InventorySetup: Record "Inventory Setup";
        TypeHelper: Codeunit "Type Helper";

        ItemLedgerEntry: Record "Item Ledger Entry";

}