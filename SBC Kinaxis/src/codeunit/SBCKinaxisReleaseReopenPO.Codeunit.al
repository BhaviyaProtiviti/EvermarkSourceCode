codeunit 50145 "SBC Kinaxis Release_Reopen PO"
{
    Permissions = tabledata "Purchase Header" = RIMD;

    tableno = "Job Queue Entry";

    trigger OnRun()
    var
        ParamList: List of [Text];
    begin
        ParamList := Uppercase(Rec."Parameter String").Split('|');
        ReleaseAllKinaxisOrders(ParamList);
    end;

    local procedure ReleaseAllKinaxisOrders(ParamList: List of [Text])
    var
        PurchaseHeader: Record "Purchase Header";
        TransferOrder: Record "Transfer Header";
        ReleaseTransferDocument: Codeunit "Release Transfer Document";
    begin
        if ParamList.Contains('PURCHASE') then begin
            PurchaseHeader.SetRange(Status, PurchaseHeader.Status::Open);
            PurchaseHeader.SetFilter("SBC Kinaxis Planner Name", '<>%1', '');
            if PurchaseHeader.FindSet() then
                repeat
                    PurchaseHeader.CalcFields(Amount);
                    if PurchaseHeader.Amount <> 0 then
                        ReleaseKinaxisOrder(PurchaseHeader);
                until PurchaseHeader.Next() = 0;
        end;

        if ParamList.Contains('TRANSFER') then begin
            TransferOrder.SetRange(Status, TransferOrder.Status::Open);
            TransferOrder.SetRange("SBC Kinaxis API Updated", true);
            if TransferOrder.FindSet() then
                repeat
                    TransferOrder."SBC Kinaxis API Updated" := false;
                    ReleaseTransferDocument.Run(TransferOrder);
                until TransferOrder.Next() = 0;
        end;
    end;

    #region purchaseOrder_release_reopen

    #region releasePurchaseOrder

    procedure ReleaseKinaxisOrder(var PurchaseHeader: Record "Purchase Header")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        PurchaseHeader."SBC Kinaxis API Updated" := false;
        if ApprovalsMgmt.IsPurchaseApprovalsWorkflowEnabled(PurchaseHeader) then
            if allowReReleaseAfterApproval(PurchaseHeader) then
                ReleasePurchaseDocument.ReleasePurchaseHeader(PurchaseHeader, true)
            else
                ApprovalsMgmt.OnSendPurchaseDocForApproval(PurchaseHeader)
        else
            ReleasePurchaseDocument.ReleasePurchaseHeader(PurchaseHeader, true);
    end;

    procedure ReleaseKinaxisOrder(PurchOrderNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if (PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchOrderNo)) and (PurchaseHeader.Status = PurchaseHeader.Status::Open) then
            ReleaseKinaxisOrder(PurchaseHeader);
    end;

    local procedure AllowReReleaseAfterApproval(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        ApprovedAmount: Decimal;
        MarginFactor: Decimal;
        AllowedAmount: Decimal;
    begin
        PurchasesPayablesSetup.Get();
        PurchaseHeader.CalcFields("Amount Including VAT");

        ApprovalEntry.SetRange("Record ID to Approve", PurchaseHeader.RecordId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
        if not ApprovalEntry.FindLast() then
            exit(false);

        ApprovedAmount := ApprovalEntry.Amount;
        MarginFactor := PurchasesPayablesSetup."SBC Purch Appr % Margin" / 100;
        AllowedAmount := ApprovedAmount * (1 + MarginFactor);

        exit(PurchaseHeader."Amount Including VAT" <= AllowedAmount);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", OnAfterReleasePurchaseDoc, '', false, false)]
    // local procedure ReleasePurchaseDocumentOnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var LinesWereModified: Boolean; PreviewMode: Boolean)
    // begin
    //     if PurchaseHeader."SBC Kinaxis Planner Name" = '' then
    //         exit;

    //     SendEmailNotification(PurchaseHeader."No.", PurchaseHeader."SBC Kinaxis Planner Name");
    // end;

    #endregion releasePurchaseOrder

    #region reopenPurchaseOrder

    procedure Kinaxis_ReopenPurchaseOrder(PurchOrderNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if (PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchOrderNo)) and (PurchaseHeader.Status <> PurchaseHeader.Status::Open) then
            Kinaxis_ReopenPurchaseOrder(PurchaseHeader);
    end;

    procedure Kinaxis_ReopenPurchaseOrder(PurchaseHeader: Record "Purchase Header")
    var
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        PurchaseHeader."SBC Kinaxis API Updated" := true; //update header that API updated
        if PurchaseHeader.Status = PurchaseHeader.Status::Released then
            ReleasePurchaseDocument.Reopen(PurchaseHeader)
        else begin
            ApprovalsMgmt.OnCancelPurchaseApprovalRequest(PurchaseHeader);
            WorkflowWebhookMgt.FindAndCancel(PurchaseHeader.RecordId);
        end;
    end;

    procedure Kinaxis_ReopenPurchaseOrder(Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then begin
            if PurchaseHeader.Status = PurchaseHeader.Status::Open then
                exit;

            Kinaxis_ReopenPurchaseOrder(PurchaseHeader);
        end;
    end;

    #endregion reopenPurchaseOrder

    #endregion purchaseOrder_release_reopen

    local procedure SendEmailNotification(OrderNo: Code[20]; PlannerName: Code[20])
    var
        UserSetup: Record "User Setup";
        PurchaseHeader: Record "Purchase Header";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        RecordRef: RecordRef;
        OutStr: OutStream;
        Instr: Instream;
        EmailScenario: Enum "Email Scenario";
        SubjectLbl: Label 'Purchase Order %1 Has Been Released', comment = '%1 = Order No';
        BodyLbl: Label 'Purchase Order %1 has been released.This is an automated notification.', comment = '%1 = Order No';
    begin
        UserSetup.SetRange("SBC Kinaxis Planner Name", PlannerName);
        if UserSetup.Findfirst() then
            if UserSetup."E-Mail" <> '' then begin
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                PurchaseHeader.SetRange("No.", OrderNo);
                RecordRef.GetTable(PurchaseHeader);
                TempBlob.CreateOutStream(OutStr);
                if Report.SaveAs(Report::"Purchase Order", '', ReportFormat::Pdf, OutStr, RecordRef) then begin
                    TempBlob.CreateInStream(Instr);
                    EmailMessage.Create(UserSetup."E-Mail", StrSubstNo(SubjectLbl, OrderNo), StrSubstNo(BodyLbl, OrderNo));
                    EmailMessage.AddAttachment('PurchaseOrder.pdf', 'application/pdf', Base64Convert.ToBase64(Instr, true));
                    Email.Send(EmailMessage, EmailScenario::Notification);
                end;
                RecordRef.Close();
            end;
    end;
}
