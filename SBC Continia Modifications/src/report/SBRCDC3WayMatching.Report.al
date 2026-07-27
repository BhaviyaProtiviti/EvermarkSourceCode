report 50140 "CDC 3 Way Matching"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPreReport()
    begin
        CDCDocument.SetFilter("Document Category Code", '%1', 'PURCHASE');
        CDCDocument.SetFilter("Match Status", '%1', CDCDocument."Match Status"::Unmatched);
        CDCDocument.SetFilter("SBC Matching Email Sent Flag", '%1', false);
        CDCDocument.SetFilter(Status, '%1', CDCDocument.Status::Open);

        if CDCDocument.FindFirst() then begin
            repeat
                CDCDocument.CalcFields("SBC Invoice No.");
                PurchaseHeader.SetFilter("Vendor Invoice No.", '%1', CDCDocument."SBC Invoice No.");
                if PurchaseHeader.FindFirst() then begin
                    SalespersonPurchaser.Get(PurchaseHeader."Purchaser Code");
                    PurchRecptHeader.Setfilter("Order No.", '%1', PurchaseHeader."No.");
                    if NOT PurchRecptHeader.FindFirst() then begin
                        "Send Email"(CDCDocument."No.", PurchaseHeader."No.", SalespersonPurchaser."E-Mail");
                        "Get Lot No."(PurchaseHeader, CDCDocument."No.");
                    end;
                end;
            until CDCDocument.Next() = 0;
        end

    end;

    local procedure "Send Email"("CDC Document No": Code[20]; "Purchase Order No.": Code[20]; PurchaserEmail: Text[80])
    var
        TxtDefaultCCMailList: List of [Text];
        TxtDefaultBCCMailList: List of [Text];
        TxtRecipientsList: List of [Text];
        SubjectText: Text[2048];
        BodyText: Text[2048];
    begin

        SubjectText := 'Document ' + Format("CDC Document No") + ' is missing with purchase receipt document';
        BodyText := 'Document ' + Format("CDC Document No") + ' (Purchase Order No ' + Format("Purchase Order No.") + ') ' + ' is missing with purchase receipt document';

        TxtRecipientsList.Add(PurchaserEmail);

        EmailMsg.Create(
            TxtRecipientsList,
            SubjectText,
            BodyText,
            false,
            TxtDefaultCCMailList,
            TxtDefaultBCCMailList
        );
        EmailObj.Send(EmailMsg, Enum::"Email Scenario"::Default);
        CDCDocument."SBC Matching Email Sent Flag" := true;
        CDCDocument.Modify();
    end;

    local procedure "Get Lot No."(PurchaseHeader: Record "Purchase Header"; DocumentNo: Code[20]);
    var
        PurchLine: Record "Purchase Line";
        ItemLedgerEntries: Record "Item Ledger Entry";
        ReservationEntry: Record "Reservation Entry";
        CDCTempDocumentLine: Record "CDC Temp. Document Line";
        DocumentLinesPage: Page "CDC Document Lines ListPart 2";
        LineNo: Integer;
        LotNo: Code[50];
    begin
        PurchLine.Reset();
        LineNo := 1;
        PurchLine.SetFilter("Document No.", '%1', PurchaseHeader."No.");
        if PurchLine.FindFirst() then begin
            repeat
                ReservationEntry.Reset();
                ReservationEntry.SetFilter("Source Type", '%1', 39);
                ReservationEntry.SetFilter("Source ID", '%1', PurchLine."Document No.");
                ReservationEntry.SetFilter("Source Ref. No.", '%1', PurchLine."Line No.");
                if NOT ReservationEntry.FindFirst() then begin
                    GetCaptions();
                    CDCTempDocumentLine."Field Value 1" := GetValueAsText(FieldCodes[1], LineNo);
                    CDCTempDocumentLine."Field Value 2" := GetValueAsText(FieldCodes[2], LineNo);
                    CDCTempDocumentLine."Field Value 3" := GetValueAsText(FieldCodes[3], LineNo);
                    CDCTempDocumentLine."Field Value 4" := GetValueAsText(FieldCodes[4], LineNo);
                    CDCTempDocumentLine."Field Value 5" := GetValueAsText(FieldCodes[5], LineNo);
                    CDCTempDocumentLine."Field Value 6" := GetValueAsText(FieldCodes[6], LineNo);
                    CDCTempDocumentLine."Field Value 7" := GetValueAsText(FieldCodes[7], LineNo);
                    CDCTempDocumentLine."Field Value 8" := GetValueAsText(FieldCodes[8], LineNo);
                    CDCTempDocumentLine."Field Value 9" := GetValueAsText(FieldCodes[9], LineNo);
                    CDCTempDocumentLine."Field Value 10" := GetValueAsText(FieldCodes[10], LineNo);
                    CDCTempDocumentLine."Field Value 11" := GetValueAsText(FieldCodes[11], LineNo);
                    CDCTempDocumentLine."Field Value 12" := GetValueAsText(FieldCodes[12], LineNo);
                    CDCTempDocumentLine."Field Value 13" := GetValueAsText(FieldCodes[13], LineNo);
                    CDCTempDocumentLine."Field Value 14" := GetValueAsText(FieldCodes[14], LineNo);
                    CDCTempDocumentLine."Field Value 15" := GetValueAsText(FieldCodes[15], LineNo);
                    CDCTempDocumentLine."Field Value 16" := GetValueAsText(FieldCodes[16], LineNo);
                    CDCTempDocumentLine."Field Value 17" := GetValueAsText(FieldCodes[17], LineNo);
                    CDCTempDocumentLine."Field Value 18" := GetValueAsText(FieldCodes[18], LineNo);
                    CDCTempDocumentLine."Field Value 19" := GetValueAsText(FieldCodes[19], LineNo);
                    CDCTempDocumentLine."Field Value 20" := GetValueAsText(FieldCodes[20], LineNo);
                    if (CDCTempDocumentLine."Field Value 5" <> '') AND (Format(PurchLine.Quantity) = CDCTempDocumentLine."Field Value 4") then begin
                        LotNo := CDCTempDocumentLine."Field Value 5";
                        "Insert Item Tracking Lines"(PurchLine, LotNo);
                    end
                    else begin
                        ItemLedgerEntries.SetFilter("Item No.", '%1', PurchLine."No.");
                        ItemLedgerEntries.SetFilter("Remaining Quantity", '>%1', 0);
                        if ItemLedgerEntries.FindFirst() then begin
                            LotNo := ItemLedgerEntries."Lot No.";
                            "Insert Item Tracking Lines"(PurchLine, LotNo);
                        end;
                    end;

                    LineNo += 1;
                end
                else begin
                    ReservationEntry.FindFirst();
                    ReservationEntry.Delete();
                end;
            until PurchLine.Next() = 0;
        end;
    end;

    local procedure "Insert Item Tracking Lines"(PurchLine: Record "Purchase Line"; MostRecentLot: Code[50])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        Clear(ReservationEntry);

        ReservationEntry.Validate("Item No.", PurchLine."No.");
        ReservationEntry."Location Code" := PurchLine."Location Code";
        ReservationEntry."Creation Date" := WorkDate();

        ReservationEntry."Source Type" := 39;
        ReservationEntry."Source Subtype" := 1;
        ReservationEntry."Source ID" := PurchLine."Document No.";
        ReservationEntry."Source Ref. No." := PurchLine."Line No.";
        ReservationEntry.Positive := false;
        ReservationEntry."Lot No." := MostRecentLot;

        ReservationEntry.Quantity := PurchLine.Quantity;
        ReservationEntry."Quantity (Base)" := PurchLine."Quantity (Base)";
        ReservationEntry."Qty. to Handle (Base)" := PurchLine."Quantity (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := PurchLine."Qty. to Invoice (Base)";
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;

        ReservationEntry.Insert(true);

    end;

    local procedure GetCaptions()
    var
        "Field": Record "CDC Template Field";
        Template: Record "CDC Template";
        I: Integer;
        AddField: Boolean;
    begin
        CLEAR(FieldCodes);
        CLEAR(FieldCaptions);
        NoOfColumns := 0;

        Field.SETCURRENTKEY("Template No.", Type, "Sort Order");
        Field.SETRANGE("Template No.", CDCDocument."Template No.");
        Field.SETRANGE(Type, Field.Type::Line);
        IF Field.FINDSET THEN
            REPEAT
                AddField := TRUE;
                IF CDCDocument."File Type" = CDCDocument."File Type"::XML THEN BEGIN
                    IF Field."Show Field" = Field."Show Field"::IfValue THEN
                        IF NOT CaptureMgt.LineFieldHasAnyValues(CDCDocument, Field.Code) THEN
                            AddField := FALSE;

                    IF Field."Show Field" = Field."Show Field"::Never THEN
                        AddField := FALSE;
                END;

                IF AddField THEN BEGIN
                    I := I + 1;
                    FieldCodes[I] := Field.Code;
                    FieldCaptions[I] := Field."Field Name";
                    NoOfColumns += 1;
                END;
            UNTIL (Field.NEXT = 0) OR (I = 20);

        FOR I := 1 TO 20 DO
            IF FieldCaptions[I] = '' THEN
                FieldCaptions[I] := '-';
    end;

    local procedure GetValueAsText(FieldCode: Code[20]; LineNo: Integer): Text[250]
    var
        "Field": Record "CDC Template Field";
    begin
        IF Field.GET(CDCDocument."Template No.", Field.Type::Line, FieldCode) THEN
            EXIT(CaptureMgt.GetValueAsText(CDCDocument."No.", LineNo, Field));
    end;


    var
        CDCDocument: Record "CDC Document";
        CDCDocumentValue: Record "CDC Document Value";
        PurchaseHeader: Record "Purchase Header";
        PurchRecptHeader: Record "Purch. Rcpt. Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        EmailObj: Codeunit "Email";
        EmailMsg: Codeunit "Email Message";
        CaptureMgt: Codeunit "CDC Capture Management";
        FieldCodes: array[20] of Code[20];
        FieldCaptions: array[20] of Text[250];
        NoOfColumns: Integer;
}