codeunit 50151 "SBC EDI 846 Helper"
{
    procedure NotAllowCreateJnlLine(EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line"; var Quantity: Decimal; Location: Code[10]; PositiveAdj: Boolean): Boolean
    var
        LAXEDISetup: Record "LAX EDI Setup";
        TempItemJournalLine: Record "Item Journal Line" temporary;
        SBCEDICreateItemJnlHelper: Codeunit "SBC EDI Create Item Jnl Helper";
        QtyAvailableByLot: Decimal;
        LineNo: Integer;
    begin
        LAXEDISetup.Get();
        if (PositiveAdj) or (not LAXEDISetup."SBC 846 Positive Adj. Only") then
            exit;

        SBCEDICreateItemJnlHelper.CreateTempItemJnlLine(TempItemJournalLine, LAXEDISetup, LineNo, EDIInventoryAdviceLine."No.", EDIInventoryAdviceLine."Unit of Measure Code", EDIInventoryAdviceLine."Lot No.", Quantity, Location, 'Neg Adjust Review', TempItemJournalLine."Entry Type"::"Negative Adjmt.");

        // QtyAvailableByLot := SBCEDICreateItemJnlHelper.FindQuantityAvailableByLot(TempItemJournalLine);

        // if QtyAvailableByLot = 0 then
        //     Quantity := 0
        // else
        SBCEDICreateItemJnlHelper.FindQuantityAvailableByLot(TempItemJournalLine);
        if TempItemJournalLine.Quantity <> 0 then
            SetQuantity(Quantity, QtyAvailableByLot, EDIInventoryAdviceLine."No.");

        if Quantity = 0 then
            exit(true);
    end;

    local procedure SetQuantity(var Quantity: Decimal; QtyAvailableByLot: Decimal; ItemNo: Code[20])
    var
        Item: Record Item;
        QtyUOM: Decimal;
    begin
        if Item.Get(ItemNo) then begin
            Item.CalcFields("SBC Qty. per Sales UOM");
            QtyUOM := Item."SBC Qty. per Sales UOM";
            if QtyUOM = 0 then
                exit;

            QtyAvailableByLot := (QtyAvailableByLot / QtyUOM);
            if Quantity > QtyAvailableByLot then
                Quantity := QtyAvailableByLot;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeInsertInventoryAdviceLine', '', false, false)]
    procedure OnBeforeInsertInventoryAdviceLine(EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line"; Location: Record Location; AdjustmentAdvice: Boolean; LastQtyOnHold: Decimal; OnHoldLocation: Code[50]; LastDamagedQty: Decimal; DamagedLocation: Code[50]; var IsHandled: Boolean)
    var
        Item: Record Item;
    begin
        If not Item.Get(EDIInventoryAdviceLine."No.") then begin
            IsHandled := true;
            exit;
        end;
        If Item.Type = Item.Type::"Non-Inventory" then
            IsHandled := true
        else
            if Item."Purchasing Blocked" then begin
                IsHandled := true;
            end
            else
                IsHandled := false;
    end;

}