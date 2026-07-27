codeunit 50150 "SBCEDI 945 Helper"
{
    var
        LAXEDISetup: Record "LAX EDI Setup";

    #region getOrderLineInfo    

    procedure GetOrderLineInfo(InternalDocNo: Code[10])
    var
        TempItemJournalLine: Record "Item Journal Line" temporary;
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        SBCEDICreateItemJnlHelper: Codeunit "SBC EDI Create Item Jnl Helper";
        LineDesc: Text;
        LineNo: Integer;
        ItemNo: Code[20];
        LotNo: Code[50];
        UOMCode: Code[10];
        LineQty: Decimal;
    begin
        LAXEDISetup.Get();
        if (not LAXEDISetup."SBC 945 Adjust Inventory") or (LAXEDISetup."SBC 945 Journal Template Name" = '') or (LAXEDISetup."SBC 945 Journal Batch Name" = '') then
            exit;

        if SkipTransferOrder(LAXEDISetup."SBC Skip Trans Order 945", InternalDocNo) then
            exit;

        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", InternalDocNo);
        LAXEDIReceiveDocumentField.SetRange(Segment, 'W12');
        LAXEDIReceiveDocumentField.SetRange(Element, '08');
        if LAXEDIReceiveDocumentField.FindSet() then begin
            LineDesc := GetOrderNo(InternalDocNo);
            SBCEDICreateItemJnlHelper.GetLastLineUOM(LineNo, UOMCode, 945);
            repeat
                ItemNo := LAXEDIReceiveDocumentField."Field Text Value";
                GetLotNoQty(InternalDocNo, LAXEDIReceiveDocumentField."Segment Group", LotNo, LineQty);
                TempItemJournalLine.Reset();
                TempItemJournalLine.SetRange("Item No.", ItemNo);
                TempItemJournalLine.SetRange("Lot No.", LotNo);
                if TempItemJournalLine.Find() then begin
                    TempItemJournalLine.Quantity += LineQty;
                    TempItemJournalLine.Modify(false);
                end else
                    SBCEDICreateItemJnlHelper.CreateTempItemJnlLine(TempItemJournalLine, LAXEDISetup, LineNo, ItemNo, UOMCode, LotNo, LineQty, LAXEDISetup."SBC Journal Location Code", LineDesc, TempItemJournalLine."Entry Type"::"Positive Adjmt.");
            until LAXEDIReceiveDocumentField.Next() = 0;
            SBCEDICreateItemJnlHelper.CreateInventory(TempItemJournalLine, 945);
        end;
    end;

    local procedure GetOrderNo(InternalDocNo: Code[10]): Code[20]
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", InternalDocNo);
        LAXEDIReceiveDocumentField.SetRange(Segment, 'W06');
        LAXEDIReceiveDocumentField.SetRange(Element, '02');
        LAXEDIReceiveDocumentField.SetFilter("Field Text Value", '<>%1', '');
        if LAXEDIReceiveDocumentField.FindFirst() then;
        exit(LAXEDIReceiveDocumentField."Field Text Value");
    end;

    local procedure GetLotNoQty(InternalDocNo: Code[10]; SegmentGroup: Integer; var LotNo: Code[50]; var LineQty: Decimal)
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
    begin
        Clear(LotNo);
        Clear(LineQty);

        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", InternalDocNo);
        LAXEDIReceiveDocumentField.SetRange(Segment, 'W12');
        LAXEDIReceiveDocumentField.SetRange("Segment Group", SegmentGroup);
        LAXEDIReceiveDocumentField.SetFilter(Element, '%1|%2', '03', '09');
        if LAXEDIReceiveDocumentField.FindSet() then
            repeat
                case LAXEDIReceiveDocumentField.Element of
                    '03':
                        if LineQty = 0 then
                            Evaluate(LineQty, LAXEDIReceiveDocumentField."Field Text Value");
                    '09':
                        begin
                            LotNo := LAXEDIReceiveDocumentField."Field Text Value";
                        end;
                end;
            until LAXEDIReceiveDocumentField.Next() = 0;
    end;

    local procedure SkipTransferOrder(SkipTransOrder: Boolean; InternalDocNo: Code[10]): Boolean
    var
        TOVar: Text;
    begin
        if not SkipTransOrder then
        exit;

        TOVar := CopyStr(InternalDocNo, 1, 2);
        if TOVar = 'TO' then
            exit(true);
    end;

    #endregion getOrderLineInfo 

}
