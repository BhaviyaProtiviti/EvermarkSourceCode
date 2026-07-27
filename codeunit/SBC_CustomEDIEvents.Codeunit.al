Codeunit 50100 "Custom EDI Events"
{

    /*     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Item Tracking", 'OnBeforeCreateReservationEntry', '', false, false)]
        procedure OnBeforeCreateReservationEntry(EDIRecDocFields: Record "LAX EDI Receive Document Field"; ReservEntryEDIRecDocField: Record "LAX EDI Receive Document Field"; var TableRef: RecordRef; var QtyBase: Decimal; LotNo: Code[50]; SerialNo: Code[50]; ExpirationDate: Date; WarrantyDate: Date; var IsHandled: Boolean; NewDoc: Boolean)
        var
            EDIRecDocField: Record "LAX EDI Receive Document Field";
            TradePartnerUnitofMeasure: Record "LAX EDI Trade Partner UOM";
            SalesLine: Record "Sales Line";
            PurchaseLine: Record "Purchase Line";
            TransferLine: Record "Transfer Line";
            ItemUnitOfMeasure: Record "Item Unit of Measure";
            ItemNo: Code[20];
            VariantCode: Code[10];
            LastEDIVariant: Code[40];
            LastEDIUOMCode: Code[10];
            ItemBaseQty: Decimal;
            OrderBaseQty: Decimal;
            MultiplierQty: Decimal;
            TableFound: Boolean;
            Text021: Label 'Unit of Measure %1 can not be found for item %2.';
            Text022: Label 'Order Unit of Measure %1 can not be found for item %2.';
            Text042: Label 'EDI Trade Partner UOM cross reference not found for Item No. %1, EDI Unit of Measure %2 and Variant Code %3.';
        begin
            LastEDIUOMCode := '';
            LastEDIVariant := '';
            VariantCode := '';
            ItemNo := '';
            TableFound := false;

            EDIRecDocField.Reset;
            EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocFields."Internal Doc. No.");
            EDIRecDocField.SetRange("Table No.", Database::"LAX EDI Trade Partner UOM");
            EDIRecDocField.SetRange("Segment Group", EDIRecDocFields."Segment Group");
            repeat
                case EDIRecDocField."Field No." of
                    TradePartnerUnitofMeasure.FieldNo("EDI Unit of Measure"):
                        LastEDIUOMCode := EDIRecDocField."Field Text Value";
                    TradePartnerUnitofMeasure.FieldNo("EDI Variant Code"):
                        LastEDIVariant := EDIRecDocField."Field Text Value";
                end;
            until EDIRecDocField.Next() = 0;

            if LastEDIUOMCode = '' then
                exit;
            case TableRef.Number of
                Database::"Sales Line":
                    begin
                        TableRef.SetTable(SalesLine);
                        ItemNo := SalesLine."No.";
                        VariantCode := Salesline."Variant Code";
                        TableFound := True;
                    end;
                Database::"Purchase Line":
                    begin
                        TableRef.SetTable(PurchaseLine);
                        ItemNo := PurchaseLine."No.";
                        VariantCode := PurchaseLine."Variant Code";
                        TableFound := True;
                    end;
                Database::"Transfer Line":
                    begin
                        TableRef.SetTable(TransferLine);
                        ItemNo := TransferLine."Item No.";
                        VariantCode := TransferLine."Variant Code";
                        TableFound := True;
                    end;
            end;
            if not TableFound then
                exit;

            TradePartnerUnitofMeasure.Reset;
            TradePartnerUnitofMeasure.SetRange("Trade Partner No.", EDIRecDocFields."Trade Partner No.");
            TradePartnerUnitofMeasure.SetRange("EDI Unit of Measure", LastEDIUOMCode);
            TradePartnerUnitofMeasure.SetRange("Item No.", ItemNo);
            if LastEDIVariant = '' then
                TradePartnerUnitofMeasure.SetRange("Variant Code", VariantCode)
            else
                TradePartnerUnitofMeasure.SetRange("EDI Variant Code", LastEDIVariant);
            if not TradePartnerUnitofMeasure.Find('-') then begin
                TradePartnerUnitofMeasure.SetRange("Item No.", '');
                TradePartnerUnitofMeasure.SetRange("Variant Code", '');
            end;
            if TradePartnerUnitofMeasure.Find('-') then begin
                if not ItemUnitOfMeasure.Get(
                         ItemNo, TradePartnerUnitofMeasure."Unit of Measure")
                then
                    Error(
                      Text021,
                      TradePartnerUnitofMeasure."Unit of Measure", ItemNo)
                else
                    ItemBaseQty := ItemUnitOfMeasure."Qty. per Unit of Measure";
                if not ItemUnitOfMeasure.Get(ItemNo, TradePartnerUnitofMeasure."Order Unit of Measure") then
                    Error(
                      Text022,
                      TradePartnerUnitofMeasure."Order Unit of Measure", ItemNo)
                else
                    OrderBaseQty := ItemUnitOfMeasure."Qty. per Unit of Measure";
                MultiplierQty := OrderBaseQty / ItemBaseQty;
                QtyBase := (QtyBase / MultiplierQty);
            end else
                Error(Text042, ItemNo, LastEDIUOMCode, VariantCode);
        end; */

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'GetLedgerQuantityOnAfterGetLedgerQty', '', false, false)]
    procedure GetLedgerQuantityOnAfterGetLedgerQty(ItemNo: Code[20]; LocationCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; VariantCode: Code[10]; var LedgerQty: Decimal)

    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        QtyPerUOM: Decimal;
    begin
        // QtyPerUOM := 1;
        // ItemLedgerEntry.Reset();
        // ItemLedgerEntry.SetRange("Item No.", ItemNo);
        // ItemLedgerEntry.SetRange("Location Code", LocationCode);
        // ItemLedgerEntry.SetRange("Lot No.", LotNo);
        // ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        // ItemLedgerEntry.SetRange("Variant Code", VariantCode);
        // ItemLedgerEntry.SetRange("Unit of Measure Code", 'CS');
        // if ItemLedgerEntry.Find('-') then begin
        //     QtyPerUOM := ItemLedgerEntry."Qty. per Unit of Measure";
        //     LedgerQty := LedgerQty / QtyPerUOM;
        // end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Receive Invt. Advice", 'OnBeforeCreateJournalLine', '', false, false)]
    procedure OnBeforeCreateJournalLine(EDIInventoryAdviceLine: Record "LAX EDI Inventory Advice Line"; var ItemJnlLine: Record "Item Journal Line"; var Quantity: Decimal; var PositiveAdj: Boolean; var Location: Code[10]; var IsHandled: Boolean)
    begin
        // if Quantity = 0 then
        //     IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Inventory Adv.", OnAfterInsertInventoryAdviceLine, '', false, false)]
    local procedure SBC_OnAfterInsertInventoryAdviceLine(var InventoryAdviceLine: Record "LAX EDI Inventory Advice Line")
    var
        InvSetup: Record "Inventory Setup";
        ItemUOM: Record "Item Unit of Measure";
        ItemUomSales: Record "Item Unit of Measure";
        Item: Record Item;
    begin
        if InventoryAdviceLine.Type = InventoryAdviceLine.Type::"Price Catalog" then begin
            if item.get(InventoryAdviceLine."No.") then begin
                InvSetup.Get();
                InvSetup.TestField("SBC Layer Unit of Measure");
                InvSetup.TestField("SBC Pallet Unit of Measure");

                ItemUomSales.get(InventoryAdviceLine."No.", Item."Sales Unit of Measure");

                ItemUOM.SetRange("Item No.", InventoryAdviceLine."No.");
                ItemUOM.SetFilter(Code, '%1|%2', InvSetup."SBC Layer Unit of Measure", InvSetup."SBC Pallet Unit of Measure");
                if ItemUOM.FindSet() then begin
                    repeat
                        if ItemUOM.Code = InvSetup."SBC Layer Unit of Measure" then begin
                            InventoryAdviceLine."SBC Layer Qty. per Sales UOM" := Round(ItemUOM."Qty. per Unit of Measure" / ItemUomSales."Qty. per Unit of Measure", 0.00001, '=');
                            InventoryAdviceLine."SBC Layer Qty. per Sales UOM" := Round(ItemUOM."Qty. per Unit of Measure" / ItemUomSales."Qty. per Unit of Measure", 0.00001, '=');
                            InventoryAdviceLine."SBC Layer Height" := ItemUOM.Height;
                            InventoryAdviceLine."SBC Layer Length" := ItemUOM.Length;
                            InventoryAdviceLine."SBC Layer Width" := ItemUOM.Width;
                            InventoryAdviceLine."SBC Layer Weight" := ItemUOM.Weight;
                            InventoryAdviceLine."SBC Layer UPC Code" := ItemUOM."LAX Std. Pack UPC/EAN Number";
                        end;
                        if ItemUOM.Code = InvSetup."SBC Pallet Unit of Measure" then begin
                            InventoryAdviceLine."SBC Pallet Qty. per Sales UOM" := Round(ItemUOM."Qty. per Unit of Measure" / ItemUomSales."Qty. per Unit of Measure", 0.00001, '=');
                            InventoryAdviceLine."SBC Pallet Height" := ItemUOM.Height;
                            InventoryAdviceLine."SBC Pallet Length" := ItemUOM.Length;
                            InventoryAdviceLine."SBC Pallet Width" := ItemUOM.Width;
                            InventoryAdviceLine."SBC Pallet Weight" := ItemUOM.Weight;
                            InventoryAdviceLine."SBC Pallet UPC Code" := ItemUOM."LAX Std. Pack UPC/EAN Number";
                        end;
                    until ItemUOM.next() = 0;
                    InventoryAdviceLine.Modify(false);
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'SBC Shelf Life (Days)', false, false)]
    local procedure SBC_OnAfterValidateShelfLifeDays(var xRec: Record Item; var Rec: Record Item; CurrFieldNo: Integer)
    begin
        if (xRec."SBC Shelf Life (Days)" <> Rec."SBC Shelf Life (Days)") and (CurrFieldNo = 50000) then begin
            if not Rec."SBC Needs EDI 832 Update" then begin
                rec."SBC Needs EDI 832 Update" := true;
                rec.modify(false);
            end;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Item Tracking Code', false, false)]
    local procedure SBC_OnAfterValidateItemTrackingCode(var xRec: Record Item; var Rec: Record Item; CurrFieldNo: Integer)
    begin
        if (xRec."Item Tracking Code" <> Rec."Item Tracking Code") and (CurrFieldNo = 6500) then begin
            if not Rec."SBC Needs EDI 832 Update" then begin
                rec."SBC Needs EDI 832 Update" := true;
                rec.modify(false);
            end;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'Tariff No.', false, false)]
    local procedure SBC_OnAfterValidateTariffNo(var xRec: Record Item; var Rec: Record Item; CurrFieldNo: Integer)
    begin
        if (xRec."Tariff No." <> Rec."Tariff No.") and (CurrFieldNo = 47) then begin
            if not Rec."SBC Needs EDI 832 Update" then begin
                rec."SBC Needs EDI 832 Update" := true;
                rec.modify(false);
            end;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateEvent', 'SBC Hazardous Material Code', false, false)]
    local procedure SBC_OnAfterValidateHazardousMaterialCode(var xRec: Record Item; var Rec: Record Item; CurrFieldNo: Integer)
    begin
        if (xRec."SBC Hazardous Material Code" <> Rec."SBC Hazardous Material Code") and (CurrFieldNo = 50001) then begin
            if not Rec."SBC Needs EDI 832 Update" then begin
                rec."SBC Needs EDI 832 Update" := true;
                rec.modify(false);
            end;
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterValidateEvent', 'Weight', false, false)]
    local procedure SBC_OnAfterValidateItemUOMWeight(var xRec: Record "Item Unit of Measure"; var Rec: Record "Item Unit of Measure"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
    begin
        if Item.get(Rec."Item No.") then begin
            Item.TestField("Sales Unit of Measure");
            InvSetup.get();
            InvSetup.TestField("SBC Layer Unit of Measure");
            InvSetup.TestField("SBC Pallet Unit of Measure");
            if Rec.Code in [Item."Sales Unit of Measure", InvSetup."SBC Layer Unit of Measure", InvSetup."SBC Pallet Unit of Measure"] then begin
                if (xRec.Weight <> Rec.Weight) and (CurrFieldNo = 7304) then begin
                    if not Item."SBC Needs EDI 832 Update" then begin
                        Item."SBC Needs EDI 832 Update" := true;
                        Item.modify(false);
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterValidateEvent', 'LAX Std. Pack UPC/EAN Number', false, false)]
    local procedure SBC_OnAfterValidateItemUOMUPCCode(var xRec: Record "Item Unit of Measure"; var Rec: Record "Item Unit of Measure"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
    begin
        if Item.get(Rec."Item No.") then begin
            Item.TestField("Sales Unit of Measure");
            InvSetup.get();
            InvSetup.TestField("SBC Layer Unit of Measure");
            InvSetup.TestField("SBC Pallet Unit of Measure");
            if Rec.Code in [Item."Sales Unit of Measure", InvSetup."SBC Layer Unit of Measure", InvSetup."SBC Pallet Unit of Measure"] then begin
                if (xRec."LAX Std. Pack UPC/EAN Number" <> Rec."LAX Std. Pack UPC/EAN Number") and (CurrFieldNo = 14000701) then begin
                    if not Item."SBC Needs EDI 832 Update" then begin
                        Item."SBC Needs EDI 832 Update" := true;
                        Item.modify(false);
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterValidateEvent', 'Width', false, false)]
    local procedure SBC_OnAfterValidateItemUOMWidth(var xRec: Record "Item Unit of Measure"; var Rec: Record "Item Unit of Measure"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
    begin
        if Item.get(Rec."Item No.") then begin
            Item.TestField("Sales Unit of Measure");
            InvSetup.get();
            InvSetup.TestField("SBC Layer Unit of Measure");
            InvSetup.TestField("SBC Pallet Unit of Measure");
            if Rec.Code in [Item."Sales Unit of Measure", InvSetup."SBC Layer Unit of Measure", InvSetup."SBC Pallet Unit of Measure"] then begin
                if (xRec.Width <> Rec.Width) and (CurrFieldNo = 7301) then begin
                    if not Item."SBC Needs EDI 832 Update" then begin
                        Item."SBC Needs EDI 832 Update" := true;
                        Item.modify(false);
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterValidateEvent', 'Height', false, false)]
    local procedure SBC_OnAfterValidateItemUOMHeight(var xRec: Record "Item Unit of Measure"; var Rec: Record "Item Unit of Measure"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
    begin
        if Item.get(Rec."Item No.") then begin
            Item.TestField("Sales Unit of Measure");
            InvSetup.get();
            InvSetup.TestField("SBC Layer Unit of Measure");
            InvSetup.TestField("SBC Pallet Unit of Measure");
            if Rec.Code in [Item."Sales Unit of Measure", InvSetup."SBC Layer Unit of Measure", InvSetup."SBC Pallet Unit of Measure"] then begin
                if (xRec.Height <> Rec.Height) and (CurrFieldNo = 7302) then begin
                    if not Item."SBC Needs EDI 832 Update" then begin
                        Item."SBC Needs EDI 832 Update" := true;
                        Item.modify(false);
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterValidateEvent', 'Length', false, false)]
    local procedure SBC_OnAfterValidateItemUOMLength(var xRec: Record "Item Unit of Measure"; var Rec: Record "Item Unit of Measure"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
    begin
        if Item.get(Rec."Item No.") then begin
            Item.TestField("Sales Unit of Measure");
            InvSetup.get();
            InvSetup.TestField("SBC Layer Unit of Measure");
            InvSetup.TestField("SBC Pallet Unit of Measure");
            if Rec.Code in [Item."Sales Unit of Measure", InvSetup."SBC Layer Unit of Measure", InvSetup."SBC Pallet Unit of Measure"] then begin
                if (xRec.Length <> Rec.Length) and (CurrFieldNo = 7300) then begin
                    if not Item."SBC Needs EDI 832 Update" then begin
                        Item."SBC Needs EDI 832 Update" := true;
                        Item.modify(false);
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Sales Order", OnRunCodeunit, '', false, false)]
    local procedure SBC_CheckDuplicateUpdateSalesOrder(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var ExitCodeunit: Boolean)
    var
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        EDIRecDocFields2: Record "LAX EDI Receive Document Field";
        DuplicateFound: Boolean;
        OrderNo: Code[20];
        SalesHeader: Record "Sales Header";
        EDI850RecDocHdr: Record "LAX EDI Receive Document Hdr.";
        EDITemplate: Record "LAX EDI Template";
        EDIDocument: Record "LAX EDI Document";
    begin
        if (EDIRecDocHdr.Document <> 'U_SLSORD') and
           (EDIRecDocHdr.Document <> 'U_SLSWSA')
        then
            exit;

        DuplicateFound := false;
        OrderNo := '';
        if (EDIRecDocHdr.Document = 'U_SLSWSA') and (EDIRecDocHdr."EDI Document No." = '945') then begin
            EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocFields.SetRange(Segment, 'W06');
            EDIRecDocFields.SetRange(Element, '02');
            EDIRecDocFields.SetRange("Field Name", 'No.');
            if EDIRecDocFields.findfirst() then begin
                OrderNo := EDIRecDocFields."Field Text Value";
                EDIRecDocHdr."SBC Sales Order No." := OrderNo;

                EDIRecDocFields2.Setfilter("Internal Doc. No.", '<%1', EDIRecDocHdr."Internal Doc. No.");
                EDIRecDocFields2.SetRange(Document, EDIRecDocHdr.Document);
                EDIRecDocFields2.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
                EDIRecDocFields2.SetRange(Segment, 'W06');
                EDIRecDocFields2.SetRange(Element, '02');
                EDIRecDocFields2.SetRange("Field Name", 'No.');
                EDIRecDocFields2.SetRange("Field Text Value", OrderNo);
                if EDIRecDocFields2.findfirst() then
                    DuplicateFound := true;

                if not DuplicateFound then begin
                    SalesHeader.ReadIsolation := IsolationLevel::ReadUncommitted;
                    SalesHeader.SetRange("Document Type", "Sales Document Type"::Order);
                    SalesHeader.SetRange("No.", OrderNo);
                    SalesHeader.SetLoadFields("LAX EDI Internal Doc. No.");
                    if SalesHeader.FindFirst() then begin
                        if EDI850RecDocHdr.get(SalesHeader."LAX EDI Internal Doc. No.") then begin
                            EDI850RecDocHdr."Price Discrepancy Check Req." := false;
                            EDI850RecDocHdr.modify();
                        end;
                    end;
                end;
            end;
        end;

        if (EDIRecDocHdr.Document = 'U_SLSORD') and (EDIRecDocHdr."EDI Document No." = '810') then begin
            EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocFields.SetRange(Segment, 'BIG');
            EDIRecDocFields.SetRange(Element, '02');
            EDIRecDocFields.SetRange("Field Name", 'No.');
            if EDIRecDocFields.findfirst() then begin
                OrderNo := EDIRecDocFields."Field Text Value";
                EDIRecDocHdr."SBC Sales Order No." := OrderNo;

                EDIRecDocFields2.Setfilter("Internal Doc. No.", '<%1', EDIRecDocHdr."Internal Doc. No.");
                EDIRecDocFields2.SetRange(Document, EDIRecDocHdr.Document);
                EDIRecDocFields2.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
                EDIRecDocFields2.SetRange(Segment, 'BIG');
                EDIRecDocFields2.SetRange(Element, '02');
                EDIRecDocFields2.SetRange("Field Name", 'No.');
                EDIRecDocFields2.SetRange("Field Text Value", OrderNo);
                if EDIRecDocFields2.findfirst() then
                    DuplicateFound := true;

                if not DuplicateFound then begin
                    SalesHeader.ReadIsolation := IsolationLevel::ReadUncommitted;
                    SalesHeader.SetRange("Document Type", "Sales Document Type"::Order);
                    SalesHeader.SetRange("No.", OrderNo);
                    SalesHeader.SetLoadFields("LAX EDI Internal Doc. No.");
                    if SalesHeader.FindFirst() then begin
                        if EDI850RecDocHdr.get(SalesHeader."LAX EDI Internal Doc. No.") then begin
                            EDITemplate.Get(EDI850RecDocHdr."EDI Template Code");
                            EDIDocument.Get(
                              EDI850RecDocHdr."Trade Partner No.", EDI850RecDocHdr.Document,
                              EDI850RecDocHdr."EDI Document No.", EDI850RecDocHdr."EDI Version",
                              EDIDocument.Type::Import);
                            if EDITemplate."Price Discrepancy Rel. Block" and (Not EDIDocument."Skip Release Restriction Check") then begin
                                EDI850RecDocHdr."Price Discrepancy Check Req." := true;
                                EDI850RecDocHdr.modify();
                            end;
                        end;
                    end;
                end;
            end;
        end;

        if DuplicateFound then begin
            EDIRecDocHdr."Sales Order Updated" := true;
            EDIRecDocHdr."Data Error" := false;
            EDIRecDocHdr."Error Message Text" := 'Duplicate Receive Document for Order ' + OrderNo;
            EDIRecDocHdr."SBC Sales Order No." := OrderNo;
            EDIRecDocHdr.modify();
            EDIRecDocHdr.get(EDIRecDocHdr."Internal Doc. No.");
            ExitCodeunit := true;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", OnRunCodeunit, '', false, false)]
    local procedure SBC_CheckDuplicateUpdatePurchOrder(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var ExitCodeunit: Boolean)
    var
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        EDIRecDocFields2: Record "LAX EDI Receive Document Field";
        DuplicateFound: Boolean;
        OrderNo: Code[20];
    begin
        if (EDIRecDocHdr.Document <> 'U_PURWSA') and
           (EDIRecDocHdr.Document <> 'I_PURINV') and
           (EDIRecDocHdr.Document <> 'U_PURORD') and
           (EDIRecDocHdr.Document <> 'I_PURORD')
        then
            exit;

        DuplicateFound := false;
        OrderNo := '';
        if (EDIRecDocHdr.Document = 'U_PURWSA') and (EDIRecDocHdr."EDI Document No." = '810') then begin
            EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocFields.SetRange(Segment, 'BIG');
            EDIRecDocFields.SetRange(Element, '04');
            EDIRecDocFields.SetRange("Field Name", 'No.');
            if EDIRecDocFields.findfirst() then begin
                OrderNo := EDIRecDocFields."Field Text Value";
                EDIRecDocHdr."SBC Purchase Order No." := OrderNo;
            end;

            EDIRecDocFields2.Setfilter("Internal Doc. No.", '<%1', EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocFields2.SetRange(Document, EDIRecDocHdr.Document);
            EDIRecDocFields2.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
            EDIRecDocFields2.SetRange(Segment, 'BIG');
            EDIRecDocFields2.SetRange(Element, '04');
            EDIRecDocFields2.SetRange("Field Name", 'No.');
            EDIRecDocFields2.SetRange("Field Text Value", OrderNo);
            if EDIRecDocFields2.findfirst() then
                DuplicateFound := true;
        end;

        if (EDIRecDocHdr.Document = 'U_PURWSA') and (EDIRecDocHdr."EDI Document No." = '856') and (EDIRecDocHdr."Trade Partner No." = 'UNILEVER') then begin // Unilever 856 creates PO Lines 
            EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocFields.SetRange(Segment, 'PRF');
            EDIRecDocFields.SetRange(Element, '01');
            EDIRecDocFields.SetRange("Field Name", 'No.');
            if EDIRecDocFields.findfirst() then begin
                OrderNo := EDIRecDocFields."Field Text Value";
                EDIRecDocHdr."SBC Purchase Order No." := OrderNo;
            end;

            EDIRecDocFields2.Setfilter("Internal Doc. No.", '<%1', EDIRecDocHdr."Internal Doc. No.");
            EDIRecDocFields2.SetRange(Document, EDIRecDocHdr.Document);
            EDIRecDocFields2.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
            EDIRecDocFields2.SetRange(Segment, 'PRF');
            EDIRecDocFields2.SetRange(Element, '01');
            EDIRecDocFields2.SetRange("Field Name", 'No.');
            EDIRecDocFields2.SetRange("Field Text Value", OrderNo);
            if EDIRecDocFields2.findfirst() then
                DuplicateFound := true;
        end;

        if DuplicateFound then begin
            EDIRecDocHdr."Purchase Order Updated" := true;
            EDIRecDocHdr."Data Error" := false;
            EDIRecDocHdr."Error Message Text" := 'Duplicate Receive Document for Order ' + OrderNo;
            EDIRecDocHdr."SBC Purchase Order No." := OrderNo;
            EDIRecDocHdr.modify();
            EDIRecDocHdr.get(EDIRecDocHdr."Internal Doc. No.");
            ExitCodeunit := true;
        end else begin
            if (EDIRecDocHdr."Receipt Posting Error" or EDIRecDocHdr."Invoice Posting Error") then begin
                EDIRecDocHdr."Purchase Order Updated" := false;
                EDIRecDocHdr.modify();
                EDIRecDocHdr.get(EDIRecDocHdr."Internal Doc. No.");
            end;
            if EDIRecDocHdr."Purchase Order Posted" then begin
                EDIRecDocHdr."Purchase Order Updated" := true;
                EDIRecDocHdr.modify();
                EDIRecDocHdr.get(EDIRecDocHdr."Internal Doc. No.");
                ExitCodeunit := true;
            end
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Sales Order", OnBeforeCommitSalesUpdates, '', false, false)]
    local procedure SBC_UpdateSalesOrderNo(var SalesHeader: Record "Sales Header"; var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var AllowCommit: Boolean)
    begin
        EDIRecDocHdr."SBC Sales Order No." := SalesHeader."No.";
        //EDIRecDocHdr.modify;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", OnBeforeCommit, '', false, false)]
    local procedure SBC_UpdatePurchaseOrderNo(var PurchaseHeader: Record "Purchase Header"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; NoOfDocs: Integer; OrderCount: Integer; var AllowCommit: Boolean)
    begin
        if OrderCount = 1 then begin
            EDIRecDocHdr."SBC Purchase Order No." := PurchaseHeader."No.";
            //EDIRecDocHdr.modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Sales Order", OnAfterPostSalesDocument, '', false, false)]
    local procedure SBC_OnAfterPostSalesDoc(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var SalesHeader: Record "Sales Header")
    var
        EDI850RecDocHdr: Record "LAX EDI Receive Document Hdr.";
        EDITemplate: Record "LAX EDI Template";
        EDIDocument: Record "LAX EDI Document";
    begin
        if EDI850RecDocHdr.get(SalesHeader."LAX EDI Internal Doc. No.") then begin
            EDITemplate.Get(EDI850RecDocHdr."EDI Template Code");
            EDIDocument.Get(
              EDI850RecDocHdr."Trade Partner No.", EDI850RecDocHdr.Document,
              EDI850RecDocHdr."EDI Document No.", EDI850RecDocHdr."EDI Version",
              EDIDocument.Type::Import);
            if EDITemplate."Price Discrepancy Rel. Block" and (Not EDIDocument."Skip Release Restriction Check") then begin
                EDI850RecDocHdr."Price Discrepancy Check Req." := true;
                EDI850RecDocHdr.modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnAfterMapSalesHdrFields, '', false, false)]
    local procedure SBC_CreateSOOnAfterMapSalesHdrFields(var SalesHeader: Record "Sales Header"; EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    begin
        EDIRecDocHdr."SBC Sales Order No." := SalesHeader."No.";
        EDIRecDocHdr.modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", PostDocumentOnBeforeCommit, '', false, false)]
    local procedure SBC_POPostDocumentOnBeforeCommit(var PurchaseHeader: Record "Purchase Header"; var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var AllowCommit: Boolean)
    begin
        if AllowCommit and (EDIRecDocHdr."Receipt Posting Error" or EDIRecDocHdr."Invoice Posting Error") then begin
            EDIRecDocHdr."Purchase Order Updated" := false;
            EDIRecDocHdr.modify();
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", OnAfterPostPurchaseDocument, '', false, false)]
    local procedure SBC_OnAfterPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    begin
        EDIRecDocHdr."Purchase Order Updated" := true;
    end;

}