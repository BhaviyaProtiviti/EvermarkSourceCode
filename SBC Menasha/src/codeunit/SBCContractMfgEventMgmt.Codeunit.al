/// <summary>
/// Codeunit SBC Contract Mfg. Event Mgmt (ID 50255).
/// </summary>
codeunit 50354 "SBC Contract Mfg. Event Mgmt"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Planning-Get Parameters", OnAtSKUOnAfterCopyFromItem, '', false, false)]
    local procedure PlanningGetParametersOnAtSKUOnAfterCopyFromItem(var GlobalSKU: Record "Stockkeeping Unit"; var Item: Record Item; VariantCode: Code[10])
    var
        RoutingLine: Record "Routing Line";
        WorkCenter: Record "Work Center";
        IsHandled: Boolean;
    begin
        OnBeforePlanningGetParametersAtSKUOnAfterCopyFromItem(GlobalSKU, Item, VariantCode, IsHandled);
        if IsHandled then
            exit;

        RoutingLine.SetRange("Routing No.", Item."No.");
        RoutingLine.SetRange(Type, RoutingLine.Type::"Work Center");
        if RoutingLine.FindFirst() then
            if (WorkCenter.Get(RoutingLine."No.")) and (WorkCenter."SBC Vendor Location" <> '') then
                GlobalSKU."Components at Location" := WorkCenter."SBC Vendor Location";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePlanningGetParametersAtSKUOnAfterCopyFromItem(var GlobalSKU: Record "Stockkeeping Unit"; var Item: Record Item; VariantCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    #region postPurchReceipt

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeDeleteAfterPosting', '', false, false)]
    // local procedure PurchPostOnBeforeDeleteAfterPosting(var PurchaseHeader: Record "Purchase Header")
    // var
    //     PurchaseLine: Record "Purchase Line";
    //     ProductionOrder: Record "Production Order";
    //     ProdOrderStatusManagement: Codeunit "Prod. Order Status Management";
    // begin
    //     if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
    //         exit;

    //     ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
    //     ProductionOrder.SetRange("SBC Subcontracting Purch.Order", PurchaseHeader."No.");
    //     if ProductionOrder.FindFirst() then
    //         ProdOrderStatusManagement.ChangeProdOrderStatus(ProductionOrder, Enum::"Production Order Status"::Finished, Today, false);
    // end;

    #endregion postPurchReceipt

    #region postProdItemJnl

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure ItemJnlPostOnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean)
    var
        ContractMfgSetup: Record "SBC Contract Mfg. Setup";
    begin
        ContractMfgSetup.Get();
        if ((ItemJournalLine."Journal Template Name" = ContractMfgSetup."SBC Menasha Item Jnl. Template") and (ItemJournalLine."Journal Batch Name" = ContractMfgSetup."SBC Menasha Item Jnl. Batch")) or
                ((ItemJournalLine."Journal Template Name" = ContractMfgSetup."SBC Prod. Order Jnl Template") and (ItemJournalLine."Journal Batch Name" = ContractMfgSetup."SBC Prod. Order Jnl. Batch")) then
            HideDialog := true;
    end;

    #endregion postProdItemJnl

    #region documentAttachment

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure DocumentAttachmentFactboxOnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        SBCDocumentAttachmentMgmt: Codeunit "SBC Document Attachment Mgmt";
        IsHandled: Boolean;
    begin
        if (DocumentAttachment."Table ID" = Database::"SBC Contract Mfg. Header") or (DocumentAttachment."Table ID" = Database::"SBC Posted Contract Mfg Hdr") then begin
            OnBeforeOpenContractMfgDocAttachment(DocumentAttachment, RecRef, IsHandled);
            if IsHandled then
                exit;
            SBCDocumentAttachmentMgmt.SetContractMgfRecRef(DocumentAttachment, RecRef);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure DocumentAttachmentOnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        SBCDocumentAttachmentMgmt: Codeunit "SBC Document Attachment Mgmt";
    begin
        if (RecRef.Number = Database::"SBC Contract Mfg. Header") or (RecRef.Number = Database::"SBC Posted Contract Mfg Hdr") then
            SBCDocumentAttachmentMgmt.ImportDocumentAttachment(DocumentAttachment, RecRef);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure DocumentAttachmentDetailsOnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean)
    var
        FieldRef: FieldRef;
    begin
        if (RecRef.Number = Database::"SBC Contract Mfg. Header") or (RecRef.Number = Database::"SBC Posted Contract Mfg Hdr") then begin
            FieldRef := RecRef.Field(1);
            DocumentAttachment.SetRange("No.", FieldRef.Value());
            FieldRef := RecRef.Field(2);
            DocumentAttachment.SetRange("Document Type", FieldRef.Value());
        end;
    end;

    #endregion documentAttachment

    #region postContract

    [EventSubscriber(ObjectType::Table, Database::"SBC Posted Contract Mfg Hdr", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure SBCPostedContractMfgHdrOnBeforeDeleteEvent(var Rec: Record "SBC Posted Contract Mfg Hdr"; RunTrigger: Boolean)
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        UserSetup.TestField("SBC Allow delete Post Contract");
    end;

    #endregion postContract

    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenContractMfgDocAttachment(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var IsHandled: Boolean)
    begin
    end;

    #endregion eventIntegration
}
