codeunit 50157 "SBC EDI Single Instance"
{
    SingleInstance = true;

    var
        GenBusPostingGroup: Code[20];
        GenBusPostingGroupMapped: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeInsertInventoryAdviceHdr', '', false, false)]
    procedure OnBeforeInsertInventoryAdviceHdr(var EDIInventoryAdviceHdr: Record "LAX EDI Inventory Advice Hdr."; Location: Record Location)
    begin
        Clear(GenBusPostingGroup);
        Clear(GenBusPostingGroupMapped);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnAfterMapInventoryAdviceHdrFields', '', false, false)]
    procedure OnAfterMapInventoryAdviceHdrFields(EDIRecDocField: Record "LAX EDI Receive Document Field"; var EDIInventoryAdviceHdr: Record "LAX EDI Inventory Advice Hdr.")
    begin

        case EDIRecDocField."Table No." of
            Database::"LAX EDI Inventory Advice Hdr.":
                case EDIRecDocField."Field No." of
                    EDIInventoryAdviceHdr.FieldNo("Adj Code"):
                        begin
                            GenBusPostingGroupMapped := true;
                            if EDIRecDocField."Cross Ref. Value-1" <> '' then
                                GenBusPostingGroup := EDIRecDocField."Cross Ref. Value-1"
                            else
                                GenBusPostingGroup := EDIRecDocField."Field Text Value";
                            EDIInventoryAdviceHdr.Validate("ADJ Code", GenBusPostingGroup);
                        end;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeInsertInventoryAdviceLine', '', false, false)]
    procedure OnBeforeInsertInventoryAdviceLine(EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line"; Location: Record Location; AdjustmentAdvice: Boolean; LastQtyOnHold: Decimal; OnHoldLocation: Code[50]; LastDamagedQty: Decimal; DamagedLocation: Code[50]; var IsHandled: Boolean)
    begin
        if GenBusPostingGroupMapped then
            EDIInventoryAdviceLine.Validate("Adj Code", GenBusPostingGroup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeExit', '', false, false)]
    procedure ReceiveInventoryAdviceOnBeforeExit(var EDIInventoryAdviceHdr: Record "LAX EDI Inventory Advice Hdr.")
    var
        EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line";
    begin

        EDIInventoryAdviceLine.Reset();
        EDIInventoryAdviceLine.SetRange("Inventory Advice No.", EDIInventoryAdviceHdr."No.");
        EDIInventoryAdviceLine.SetRange(Type, EDIInventoryAdviceHdr.Type);
        if EDIInventoryAdviceLine.Find('-') then
            repeat
                EDIInventoryAdviceLine.Validate("ADJ Code", GenBusPostingGroup);
                EDIInventoryAdviceLine.Modify();
            until EDIInventoryAdviceLine.Next() = 0;
        Clear(GenBusPostingGroup);
        Clear(GenBusPostingGroupMapped);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeFinalizeItemJnlLine', '', false, false)]
    local procedure OnBeforeFinalizeItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line"; EDIDocument: Record "LAX EDI Document"; EDIStatusCode: Record "LAX EDI Status Code"; ItemJnlBatch: Record "Item Journal Batch")
    begin
        if GenBusPostingGroupMapped then
            ItemJnlLine.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeReleasePurchaseOrder', '', false, false)]
    procedure OnBeforeReleasePurchaseOrder(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        if PurchaseHeader.Status = PurchaseHeader.Status::Released then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeValidateQtyToReceive', '', false, false)]
    procedure OnBeforeValidateQtyToReceive(var PurchaseLine: Record "Purchase Line"; EDIRecDocFields: Record "LAX EDI Receive Document Field"; var LastReceiveQty: Decimal; var IsHandled: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        EDISetGlobalVariable: Codeunit "LAX EDI Set Global Variable";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
        OverReceipt: Boolean;
        OverReceiptCode: Code[20];
    begin
        OverReceipt := false;
        if OverReceiptMgt.IsOverReceiptAllowed() then begin
            if (Abs(LastReceiveQty) > Abs(PurchaseLine."Outstanding Quantity")) then
                OverReceipt := true
            else
                OverReceipt := false;
        end else
            OverReceipt := false;

        if OverReceipt then begin
            PurchaseHeader.Get(Purchaseline."Document Type", PurchaseLine."Document No.");
            if PurchaseHeader.Status = PurchaseHeader.Status::Open then begin
                EDISetGlobalVariable."ReleasePurchDoc-SetRunFromEDI"(false);
                EDISetGlobalVariable."ReleasePurchDoc-SetRunFromEDI"(true);
                ReleasePurchDoc.SetSkipCheckReleaseRestrictions();
                ReleasePurchDoc.Run(PurchaseHeader);
                EDISetGlobalVariable."ReleasePurchDoc-SetRunFromEDI"(false);
            end;
        end;

        PurchaseLine.Validate("Qty. to Receive", LastReceiveQty);
        IsHandled := true;
    end;

}

