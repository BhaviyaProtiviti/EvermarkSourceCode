codeunit 50358 "SBC CA Sales Import"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    #region importFile

    procedure ImportFile(DocType: Enum "Sales Document Type"; ConversionRate: Decimal)
    var
        FileManagement: Codeunit "File Management";
        // ContractSource: Enum "SBC Contract Source";
        Instream: InStream;
        FromFile: Text;
        SheetName: Text;
        ChooseFileLbl: Label 'Create %1. Please choose the Excel file';
    begin
        if UploadIntoStream(StrSubstNo(ChooseFileLbl, DocType), '', '', FromFile, Instream) then begin
            SheetName := TempExcelBuffer.SelectSheetsNameStream(Instream);
            TempExcelBuffer.Reset();
            TempExcelBuffer.DeleteAll();
            TempExcelBuffer.OpenBookStream(Instream, SheetName);
            TempExcelBuffer.ReadSheet();

            ReadExcel(Instream, DocType, ConversionRate);
        end else
            Error('No file found');
    end;

    #endregion importFile

    #region readExcel

    local procedure ReadExcel(Instream: InStream; DocType: Enum "Sales Document Type"; ConversionRate: Decimal)
    var
        FileMgmt: Codeunit "File Management";
        DocNo: Code[20];
        ExtDocNo: Text;
        RowNo: Integer;
        MaxRow: Integer;
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRow := TempExcelBuffer."Row No.";

        for RowNo := 2 to MaxRow do
            if GetValueAtCell(RowNo, 1) = '' then
                break
            else
                CreateSalesLine(DocType, DocNo, RowNo, ConversionRate);
    end;

    local procedure CreateSalesLine(DocType: Enum "Sales Document Type"; var DocNo: Code[20]; RowNo: Integer; ConversionRate: Decimal)
    var
        SalesLine: Record "Sales Line";
        BracketPrices: Record "STA Bracket Price";
        ImportQuantity: Decimal;
    begin
        if DocNo = '' then
            DocNo := CreateSalesHeader(DocType, RowNo);
        ImportQuantity := EvaluateDec(GetValueAtCell(RowNo, 8));
        if ImportQuantity = 0 then
            exit;

        SalesLine.Init();
        SalesLine."Document Type" := DocType;
        SalesLine."Document No." := DocNo;
        SalesLine."Line No." := (RowNo * 10000);
        SalesLine."Type" := SalesLine."Type"::Item;
        SalesLine.Validate("No.", GetValueAtCell(RowNo, 6));
        SalesLine.Validate("Unit of Measure Code", 'EA');
        SalesLine.Validate("Quantity", ImportQuantity);
        SalesLine.Validate("LAX EDI Unit Price", (EvaluateDec(GetValueAtCell(RowNo, 9)) * ConversionRate));
        SalesLine.Validate("Line Amount", (EvaluateDec(GetValueAtCell(RowNo, 12)) * ConversionRate));

        BracketPrices.SetFilter("Item No.", '%1', SalesLine."No.");
        BracketPrices.SetFilter("Country Code", '%1', 'CA');
        BracketPrices.SetFilter(Active, '%1', true);
        if BracketPrices.FindFirst() then begin
            if SalesLine."Unit of Measure Code" = 'CS' then
                SalesLine."Unit Price" := BracketPrices."Bracket Case Price";
            if SalesLine."Unit of Measure Code" = 'EA' then
                SalesLine."Unit Price" := BracketPrices."Bracket Unit Price";
        end;
        SalesLine.Insert(true);
        CreateReservationEntry(SalesLine, GetValueAtCell(RowNo, 13));
    end;

    local procedure CreateSalesHeader(DocType: Enum "Sales Document Type"; RowNo: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin
        Customer.SetRange("SBC CA Import Cust.", true);
        if not Customer.FindFirst() then
            Error('No default Canada Sales Import Customer found');

        SalesHeader.Init();
        SalesHeader."Document Type" := DocType;
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader."External Document No." := TestExtDocumentNo(RowNo);
        SalesHeader.Validate("Document Date", EvaluateDate(GetValueAtCell(RowNo, 2)));
        SalesHeader."SBC CA Sales Doc Import" := true;
        SalesHeader.Insert(true);
        exit(SalesHeader."No.");
    end;

    local procedure TestExtDocumentNo(RowNo: Integer): Code[35]
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ExtDocNo: Code[35];
        ExtDocLbl: Label 'External Document No. %1 already exists. Do you want to continue?';
    begin
        ExtDocNo := GetValueAtCell(RowNo, 1);

        SalesHeader.SetRange("External Document No.", ExtDocNo);
        if SalesHeader.IsEmpty then begin
            SalesInvHeader.SetRange("External Document No.", ExtDocNo);
            if SalesInvHeader.IsEmpty then
                exit(ExtDocNo);
        end;

        if confirm(StrSubstNo(ExtDocLbl, ExtDocNo)) then
            exit(ExtDocNo)
        else
            Error('');
    end;

    // local procedure InsertInvoiceLines(var SalesLine: Record "Sales Line"; RowNo: Integer)
    // begin
    //     SalesLine.Validate("No.", GetValueAtCell(RowNo, 6));
    //     SalesLine.Validate("Quantity", EvaluateDec(GetValueAtCell(RowNo, 7)));
    //     SalesLine.Validate("Unit Price", EvaluateDec(GetValueAtCell(RowNo, 8)));
    //     SalesLine.Insert(true);
    //     CreateReservationEntry(SalesLine, GetValueAtCell(RowNo, 13));
    // end;

    // local procedure InsertCrMemoLines(var SalesLine: Record "Sales Line"; RowNo: Integer)
    // begin
    //     SalesLine.Validate("No.", GetValueAtCell(RowNo, 6));
    //     SalesLine.Validate("Quantity", EvaluateDec(GetValueAtCell(RowNo, 8)));
    //     SalesLine.Validate("Unit Price", EvaluateDec(GetValueAtCell(RowNo, 9)));
    //     SalesLine.Insert(true);
    //     CreateReservationEntry(SalesLine, GetValueAtCell(RowNo, 13));
    // end;

    [TryFunction]
    local procedure CreateReservationEntry(SalesLine: Record "Sales Line"; LotNo: Code[50])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Reset();
        ReservationEntry.Init();
        ReservationEntry."Entry No." := GetLastEntryNo() + 1;
        ReservationEntry."Source Type" := Database::"Sales Line";
        ReservationEntry."Source ID" := SalesLine."Document No.";
        ReservationEntry."Source Ref. No." := SalesLine."Line No.";
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Creation Date" := Today;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Validate("Item No.", SalesLine."No.");
        ReservationEntry.Validate("Location Code", SalesLine."Location Code");
        ReservationEntry.Validate("Lot No.", LotNo);
        ReservationEntry.Validate("Qty. per Unit of Measure", QuantityPerUOM(SalesLine."No.", SalesLine."Unit of Measure Code"));

        // if SalesLine."Document Type" = SalesLine."Document Type"::Invoice then begin
        // ReservationEntry."Source Subtype" := 2;
        ReservationEntry."Source Subtype" := 1;
        ReservationEntry."Shipment Date" := SalesLine."Shipment Date";
        ReservationEntry.Validate("Quantity", -SalesLine."Quantity");
        ReservationEntry.Positive := false;
        // end else begin
        //     ReservationEntry."Source Subtype" := 3;
        //     ReservationEntry."Expected Receipt Date" := Today;
        //     ReservationEntry.Validate("Quantity", SalesLine."Quantity");
        //     ReservationEntry.Positive := true;
        // end;
        ReservationEntry.Validate("Quantity (Base)", (ReservationEntry.Quantity * ReservationEntry."Qty. per Unit of Measure"));
        ReservationEntry.Insert(true);
    end;

    local procedure QuantityPerUOM(ItemNo: Code[20]; UOM: Code[10]): Decimal
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        if ItemUnitofMeasure.Get(ItemNo, UOM) then
            exit(ItemUnitofMeasure."Qty. per Unit of Measure");
    end;

    local procedure GetLastEntryNo(): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        if ReservationEntry.FindLast() then
            exit(ReservationEntry."Entry No.");
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text");
    end;

    local procedure EvaluateDec(TextValue: Text): Decimal
    var
        DecVar: Decimal;
    begin
        Evaluate(DecVar, TextValue);
        // if DecVar < 0 then
        //     DecVar := DecVar * -1;
        exit(DecVar);
    end;

    local procedure EvaluateDate(TextValue: Text): Date
    var
        DateVar: Date;
    begin
        Evaluate(DateVar, TextValue);
        exit(DateVar);
    end;

    #endregion readExcel
}
