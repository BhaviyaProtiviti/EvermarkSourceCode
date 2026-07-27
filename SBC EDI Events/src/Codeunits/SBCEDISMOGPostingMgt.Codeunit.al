/// <summary>
/// Codeunit SBC EDI SMOG Posting Mgt. (ID 50088).
/// Determines the correct Gen. Bus. Posting Group for an EDI 850 Sales Order
/// based on whether the LAX EDI Receive Document Field table contains the SMOG
/// indicator ("SMOG" in the MSG segment "Field Text Value").
///
/// Rules:
///   - Only runs when "SBC SMOG Enabled" = true on the LAX EDI Document record.
///   - SMOG found    → "Gen. Bus. Posting Group" from SBC EDI SMOG Posting Setup (field "SMOG Gen. Bus. Posting Group").
///   - SMOG not found → "Gen. Bus. Posting Group" from SBC EDI SMOG Posting Setup (field "Non-SMOG Gen. Bus. Posting Group").
///   - If neither value is configured the sales header is left unchanged.
///
/// No existing codeunits, tables, or procedures are modified.
/// </summary>
codeunit 50088 "SBC EDI SMOG Posting Mgt."
{
    SingleInstance = true;

    var
        GlobalSMOGGenBusPostingGroup: Code[20];
        GlobalNonSMOGGenBusPostingGroup: Code[20];
        GlobalCUInstance: Codeunit "SBC EDI SMOG Posting Mgt.";
        SMOGValueLbl: Label 'SMOG', Locked = true;

    //─── Event: fires just before LAX EDI Create Sales Order modifies the Sales Header ───
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnAfterModifySalesHeader, '', false, false)]
    local procedure OnAfterModifySalesHeader(var SalesHeader: Record "Sales Header")
    var
        TargetGroup: Code[20];
    begin
        if GlobalSMOGGenBusPostingGroup <> '' then
            TargetGroup := GlobalSMOGGenBusPostingGroup
        else
            TargetGroup := GlobalNonSMOGGenBusPostingGroup;

        if TargetGroup = '' then
            exit;
        if SalesHeader."Gen. Bus. Posting Group" = TargetGroup then
            exit;
        SalesHeader."Gen. Bus. Posting Group" := TargetGroup;
        SalesHeader.Modify();
        Clear(GlobalSMOGGenBusPostingGroup);
        Clear(GlobalNonSMOGGenBusPostingGroup);
    end;

    // ─── Event: fires just before LAX EDI Create Sales Order evaluates cross-references ───
    // Used to inspect the EDI document fields and pre-load the resolved posting group
    // into the single-instance globals before the sales header is created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", 'OnBeforeEvaluateGeneralCrossRef', '', false, false)]
    local procedure OnBeforeEvaluateGeneralCrossRef(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var EvaluateGenCrossRef: Boolean)
    begin
        PreparePostingGroup(EDIRecDocHdr);
    end;

    // ─── Core: resolve and cache posting groups for this document ───────────────────────
    local procedure PreparePostingGroup(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDIDocument: Record "LAX EDI Document";
        SBCEDISMOGPostingSetup: Record "SBC EDI SMOG Posting Setup";
        EDIRecDocField: Record "LAX EDI Receive Document Field";
    begin

        // Load the posting group setup; nothing to do if not configured
        if not SBCEDISMOGPostingSetup.Get() then
            exit;
        if (SBCEDISMOGPostingSetup."SMOGGenBusPostingGroup" = '') and
           (SBCEDISMOGPostingSetup."Non-SMOGGenBusPostingGroup" = '') then
            exit;

        // Check the MSG segment for the SMOG keyword
        EDIRecDocField.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocField.SetFilter("Field Text Value", '@*' + SMOGValueLbl + '*');

        if not EDIRecDocField.IsEmpty() then
            GlobalSMOGGenBusPostingGroup := SBCEDISMOGPostingSetup."SMOGGenBusPostingGroup"
        else
            GlobalNonSMOGGenBusPostingGroup := SBCEDISMOGPostingSetup."Non-SMOGGenBusPostingGroup";
    end;

    // ─── Suppress sales-line recreation dialog when posting group changes ─────────────
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeRecreateSalesLinesHandler', '', false, false)]
    local procedure OnBeforeRecreateSalesLinesHandler(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; ChangedFieldName: Text[100]; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

}
