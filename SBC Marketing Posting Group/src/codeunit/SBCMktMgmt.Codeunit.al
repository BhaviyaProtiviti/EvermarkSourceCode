codeunit 50141 "SBC Mkt Mgmt"
{
    #region item

    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeValidateEvent, "SBC Has Marketing Display", false, false)]
    local procedure ItemOnBeforeValidateEventHasMarketingDisplay(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        RoutingLine: Record "Routing Line";
        UnitCostErrTxt: Text;
        MktAmountPerUOM: Decimal;
        UnitCostErrLbl: label 'Routing Unit Cost %1 is greater than Item Unit Cost %2', Comment = '%1 = Routing Unit Cost, %2 = Item Unit Cost';
    begin
        if not Rec."SBC Has Marketing Display" then
            exit;
        RoutingLine.SetRange("Routing No.", Rec."Routing No.");
        RoutingLine.SetRange(Type, RoutingLine.Type::"Work Center");
        if RoutingLine.FindFirst() then
            if RoutingLine."Unit Cost per" >= Rec."Unit Cost" then begin
                UnitCostErrTxt := StrSubstNo(UnitCostErrLbl, RoutingLine."Unit Cost per", Rec."Unit Cost");
                Error(UnitCostErrTxt);
            end;
    end;

    #endregion item

    #region salesLine

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnCopyFromItemOnAfterCheck, '', false, false)]
    local procedure SalesLineOnCopyFromItemOnAfterCheck(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        if Item."SBC Has Marketing Display" then
            SalesLine.validate("SBC Marketing Posting Group", Item."SBC Marketing Posting Group");
    end;

    #endregion salesLine

    #region salesPost

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterTestSalesLine, '', false, false)]
    local procedure SalesPostOnAfterTestSalesLine(SalesLine: Record "Sales Line")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        ForwardLinkMgt: Codeunit "Forward Link Mgt.";
        ErrorMessageMgt: Codeunit "Error Message Management";
        SetupBlockedErr: Label 'Setup is blocked in %1 for %2 %3 and %4 %5.', Comment = '%1 - General/VAT Posting Setup, %2 %3 %4 %5 - posting groups.';
    begin
        if SalesLine."SBC Marketing Posting Group" = '' then
            exit;

        if GeneralPostingSetup.Get(SalesLine."Gen. Bus. Posting Group", SalesLine."SBC Marketing Posting Group") then
            if GeneralPostingSetup.Blocked then
                ErrorMessageMgt.LogContextFieldError(
                SalesLine.FieldNo("SBC Marketing Posting Group"),
                StrSubstNo(
                    SetupBlockedErr, GeneralPostingSetup.TableCaption(),
                    GeneralPostingSetup.FieldCaption("Gen. Bus. Posting Group"), GeneralPostingSetup."Gen. Bus. Posting Group",
                    GeneralPostingSetup.FieldCaption("Gen. Prod. Posting Group"), GeneralPostingSetup."Gen. Prod. Posting Group"),
                GeneralPostingSetup.RecordId(), GeneralPostingSetup.FieldNo(Blocked),
                ForwardLinkMgt.GetHelpCodeForFinancePostingGroups());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostItemJnlLineOnBeforeIsJobContactLineCheck, '', false, false)]
    local procedure SalesPostOnPostItemJnlLineOnBeforeIsJobContactLineCheck(var ItemJnlLine: Record "Item Journal Line"; SalesLine: Record "Sales Line")
    var
        MktAmountPerUOM: Decimal;
    begin
        //populate the SBC Marketing Posting Group and SBC Marketing Amount fields in the Invoice Post Buffer
        if SalesLine."SBC Marketing Posting Group" = '' then
            exit;

        MktAmountPerUOM := SetMktAmountPerUOM(SalesLine."No.", SalesLine."Unit of Measure Code");
        if MktAmountPerUOM = 0 then
            exit;

        ItemJnlLine."SBC Marketing Posting Group" := SalesLine."SBC Marketing Posting Group";
        ItemJnlLine."SBC Marketing Amount" := MktAmountPerUOM;
        // ItemJnlLine."SBC Marketing Amount" := MktAmountPerUOM * SalesLine.Quantity;
    end;

    #endregion salesPost

    #region invPostingToGL

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting to G/L", OnAfterInitTempInvtPostBuf, '', false, false)]
    local procedure InventoryPostingtoGLOnAfterInitTempInvtPostBuf(var TempInvtPostBuf: array[20] of Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; sender: Codeunit "Inventory Posting To G/L"; PostBufDimNo: Integer)
    var
        TempInvtPostingBufferCOG: Record "Invt. Posting Buffer" temporary;
        TempInvtPostingBufferMkt: Record "Invt. Posting Buffer" temporary;
        i: Integer;
    begin
        if ValueEntry."SBC Marketing Posting Group" = '' then
            exit;

        for i := 1 to PostBufDimNo do
            if IsCOGSBuffer(TempInvtPostBuf[i]) then begin

                TempInvtPostingBufferCOG := TempInvtPostBuf[i];
                TempInvtPostingBufferMkt := TempInvtPostingBufferCOG;
                TempInvtPostingBufferCOG.Amount -= ValueEntry."SBC Marketing Amount";

                TempInvtPostBuf[i] := TempInvtPostingBufferCOG;

                TempInvtPostingBufferMkt."Account No." := GetGLAcct(ValueEntry."Gen. Bus. Posting Group", ValueEntry."SBC Marketing Posting Group");
                TempInvtPostingBufferMkt.Amount := ValueEntry."SBC Marketing Amount";
                TempInvtPostingBufferMkt."Gen. Prod. Posting Group" := ValueEntry."SBC Marketing Posting Group";

                TempInvtPostBuf[PostBufDimNo + 1] := TempInvtPostingBufferMkt;
                PostBufDimNo += 1;
                exit;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting to G/L", OnAfterBufferSalesPosting, '', false, false)]
    local procedure InventoryPostingToGLOnAfterBufferSalesPosting(var TempInvtPostingBuffer: array[20] of Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry"; var PostBufDimNo: Integer)
    var
        TempInvtPostingBufferCOG: Record "Invt. Posting Buffer" temporary;
        i: Integer;
    begin
        if ValueEntry."SBC Marketing Posting Group" = '' then
            exit;

        TempInvtPostingBufferCOG := TempInvtPostingBuffer[PostBufDimNo + 1];
        if TempInvtPostingBufferCOG."Posting Date" <> 0D then
            PostBufDimNo += 1;
    end;

    #endregion invPostingToGL

    #region itemJnlPostLine

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInsertValueEntry, '', false, false)]
    local procedure ItemJnlPostLineOnBeforeInsertValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry")
    begin
        ValueEntry."SBC Marketing Posting Group" := ItemJournalLine."SBC Marketing Posting Group";
        ValueEntry."SBC Marketing Amount" := ItemJournalLine."SBC Marketing Amount" * ABS(ValueEntry."Invoiced Quantity");
        // ValueEntry."SBC Marketing Amount" := ItemJournalLine."SBC Marketing Amount";
    end;

    #endregion itemJnlPostLine    

    #region getInfo

    local procedure GetGLAcct(GenBusPG: Code[20]; GenProdPG: Code[20]): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        GenPostingSetup.Get(GenBusPG, GenProdPG);
        exit(GenPostingSetup.GetCOGSAccount());
    end;

    local procedure SetMktAmountPerUOM(ItemNo: Code[20]; LineUOM: Code[20]): Decimal
    var
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        RoutingLine: Record "Routing Line";
        QtyPerUOM: Decimal;
    begin
        if Item.Get(ItemNo) then
            if not Item."SBC Has Marketing Display" then
                exit(0);
            // else
            //     if ItemUnitofMeasure.Get(ItemNo, LineUOM) then
            //         QtyPerUOM := ItemUnitofMeasure."Qty. per Unit of Measure";

        RoutingLine.SetRange("Routing No.", Item."Routing No.");
        RoutingLine.SetRange(Type, RoutingLine.Type::"Work Center");
        if RoutingLine.FindFirst() then
            // exit(RoutingLine."Unit Cost per" * QtyPerUOM);
            exit(RoutingLine."Unit Cost per");
        exit(0);
    end;

    local procedure IsCOGSBuffer(var TempInvtPostingBufferCOG: Record "Invt. Posting Buffer" temporary): Boolean
    begin
        if TempInvtPostingBufferCOG."Account Type" = TempInvtPostingBufferCOG."Account Type"::COGS then
            exit(true);
    end;

    #endregion getInfo
}
