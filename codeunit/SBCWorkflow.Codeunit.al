codeunit 50140 "SBC Workflow"
{
    Permissions = tabledata "Posted Approval Entry" = RM, tabledata "G/L Entry" = RM, tabledata "Approval Entry" = RM;

    #region generalJournalPg

    [EventSubscriber(ObjectType::Page, Page::"General Journal", OnBeforeActionEvent, SendApprovalRequestJournalBatch, false, false)]
    local procedure GeneralJournalSendApprovalRequestJournalBatch(var Rec: Record "Gen. Journal Line")
    begin
        PreviewPost(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"General Journal", OnBeforeActionEvent, SendApprovalRequestJournalLine, false, false)]
    local procedure GeneralJournalSendApprovalRequestJournalLine(var Rec: Record "Gen. Journal Line")
    begin
        PreviewPost(Rec);
    end;

    local procedure PreviewPost(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
    begin
        if confirm('Do you want to Preview Post the journal?') then
            GenJnlPost.Preview(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Approval Entry", OnAfterInsertEvent, '', false, false)]
    local procedure PostedApprovalEntryOnAfterInsertEvent(var Rec: Record "Posted Approval Entry"; RunTrigger: Boolean)
    var
        GLEntry: Record "G/L Entry";
        RecordRef: RecordRef;
        FromRef: FieldRef;
        ToRef: FieldRef;
    begin
        if Rec."Posted Record ID".TableNo <> 45 then
            exit;

        RecordRef.Get(Rec."Posted Record ID");
        FromRef := RecordRef.Field(2);
        ToRef := RecordRef.Field(3);

        GLEntry.SetRange("SBC Approval Entry No.", 0);
        GLEntry.SetFilter("Entry No.", '%1..%2', FromRef.Value, ToRef.Value);
        GLEntry.ModifyAll("SBC Approval Entry No.", Rec."Entry No.");
        RecordRef.Close();
    end;

    #endregion generalJournalPg

    #region workflow

    #region workflowEvents

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnAfterPopulateApprovalEntryArgument, '', false, false)]
    local procedure ApprovalsMgmOnAfterPopulateApprovalEntryArgument(WorkflowStepInstance: Record "Workflow Step Instance"; var ApprovalEntryArgument: Record "Approval Entry"; var RecRef: RecordRef; var IsHandled: Boolean)
    var
        Workflow: Record Workflow;
        WorkflowStepArgument: Record "Workflow Step Argument";
        SenderUserSetup: Record "User Setup";
        ErrorLbl: Label '%1 creator cannot be the approver. %2 to appropriate approver.';
    begin
        //populate custom fields
        //test if sender is approver

        WorkflowStepArgument.Get(WorkflowStepInstance.Argument);
        ApprovalEntryArgument."SBC ApprRequester not Approver" := WorkflowStepArgument."SBC ApprRequester not Approver";

        Workflow.Get(WorkflowStepInstance."Workflow Code");
        ApprovalEntryArgument."SBC Use Final Approver" := Workflow."SBC Custom Purch Workflow";

        if (ApprovalEntryArgument."Sender ID" = '') and (WorkflowStepInstance."Created By User ID" <> '') then
            ApprovalEntryArgument."Sender ID" := WorkflowStepInstance."Created By User ID";

        if (ApprovalEntryArgument."Table ID" = Database::"Gen. Journal Batch") and (ApprovalEntryArgument."Limit Type" = ApprovalEntryArgument."Limit Type"::"Approval Limits") then begin
            GetBatchApprovalAmt(ApprovalEntryArgument);
            exit;
        end;

        if WorkflowStepArgument."SBC ApprRequester not Approver" then begin
            SenderUserSetup.Get(ApprovalEntryArgument."Sender ID");
            if SenderUserSetup."Salespers./Purch. Code" = ApprovalEntryArgument."Salespers./Purch. Code" then
                error(CreateCreatorApproverErr(RecRef.Name, ApprovalEntryArgument."Document Type"));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnAfterIsSufficientApprover, '', false, false)]
    local procedure ApprovalsMgmtOnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean; var IsHandled: Boolean)
    var
        SenderUserSetup: Record "User Setup";
        CustomEventIsHandled: Boolean;
    begin
        //logic allows gen journal batch posting for approval limits
        if (ApprovalEntryArgument."Table ID" = Database::"Gen. Journal Batch") and (ApprovalEntryArgument."Limit Type" = ApprovalEntryArgument."Limit Type"::"Approval Limits") then begin
            OnBeforeOnApprovalsMgmtOnAfterIsSufficientApprover(UserSetup, ApprovalEntryArgument, IsSufficient, CustomEventIsHandled);
            if CustomEventIsHandled then
                exit;

            IsHandled := true;
            if (ApprovalEntryArgument."SBC ApprRequester not Approver") and (ApprovalEntryArgument."Sender ID" = UserSetup."User ID") then begin
                isSufficient := false;
                exit;
            end;

            if UserSetup."Approval Administrator" then
                IsSufficient := true
            else
                IsSufficient := IsSufficientGenJnlBatchApprover(UserSetup, ApprovalEntryArgument);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnBeforeCreateApprovalRequestForUser, '', false, false)]
    local procedure ApprovalsMgmtOnBeforeCreateApprovalRequestForUser(ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepArgument: Record "Workflow Step Argument"; var IsHandled: Boolean)
    begin
        //prevent sender approval created
        if WorkflowStepArgument."SBC ApprRequester not Approver" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnCreateApprovalRequestsOnAfterCreateRequests, '', false, false)]
    local procedure ApprovalsMgmtOnCreateApprovalRequestsOnAfterCreateRequests(WorkflowStepArgument: Record "Workflow Step Argument"; ApprovalEntryArgument: Record "Approval Entry"; RecRef: RecordRef)
    var
        PurchPayableSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        WorkFlow: Record Workflow;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        SequenceNo: Integer;
        PurchaserUserNotFoundErr: Label 'The salesperson/purchaser user ID %1 does not exist in the Approval User Setup window for %2 %3.', Comment = 'Example: The salesperson/purchaser user ID NAVUser does not exist in the Approval User Setup window for Salesperson/Purchaser code AB.';
    begin
        if not ApprovalEntryArgument."SBC Use Final Approver" then
            exit;

        WorkFlow.Get(ApprovalEntryArgument."Approval Code");
        WorkFlow.TestField("SBC Purchase Final Approver");

        UserSetup.Get(WorkFlow."SBC Purchase Final Approver");
        if UserSetup."Salespers./Purch. Code" = '' then
            Error(
              PurchaserUserNotFoundErr, UserSetup."User ID", UserSetup.FieldCaption("Salespers./Purch. Code"),
              UserSetup."Salespers./Purch. Code");

        if FinalUserEntryExists(ApprovalEntryArgument, WorkFlow."SBC Purchase Final Approver") then
            exit;

        SequenceNo := ApprovalsMgmt.GetLastSequenceNo(ApprovalEntryArgument) + 1;
        ApprovalEntryArgument."SBC Final Approval Entry" := true;
        ApprovalsMgmt.MakeApprovalEntry(ApprovalEntryArgument, SequenceNo, WorkFlow."SBC Purchase Final Approver", WorkflowStepArgument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnBeforeApprovalEntryInsert, '', false, false)]
    local procedure ApprovalsMgmtOnBeforeApprovalEntryInsert(var ApprovalEntry: Record "Approval Entry"; WorkflowStepArgument: Record "Workflow Step Argument"; ApprovalEntryArgument: Record "Approval Entry"; ApproverId: Code[50]; var IsHandled: Boolean)
    begin
        //specify final approval entry to update status incase value is not created due to another process
        //to ensure final approver gets notification
        if ApprovalEntryArgument."SBC Final Approval Entry" then
            ApprovalEntry.Status := ApprovalEntry.Status::Created;
    end;

    #endregion workflowEvents    

    local procedure CreateCreatorApproverErr(TableName: Text; DocType: Enum "Approval Document Type"): text
    var
        VarTxt: Text;
        i: Integer;
        TableNameList: List of [Text];
        ErrorLbl: Label '%1 creator cannot be the approver. %2 to appropriate approver.';
    begin
        TableNameList := TableName.Split(' ');

        VarTxt := TableNameList.Get(1);
        if VarTxt = 'Gen.' then
            exit(StrSubstNo(ErrorLbl, 'Document', 'Set Approval User Setup'))
        else
            exit(StrSubstNo(ErrorLbl, VarTxt + ' ' + Format(DocType), 'Direct Salesperson/Purchaser Code '));
    end;

    local procedure IsSufficientGenJnlBatchApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry") Result: Boolean
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        RecRef: RecordRef;
        IsHandled: Boolean;
    begin
        RecRef.Get(ApprovalEntryArgument."Record ID to Approve");
        RecRef.SetTable(GenJournalBatch);

        IsHandled := false;
        OnIsSufficientGenJournalBatchApproverOnAfterRecRefSetTable(UserSetup, ApprovalEntryArgument, GenJournalBatch, Result, IsHandled);
        if IsHandled then
            exit;

        exit(IsSufficientGenJournalBatchApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)"));
    end;

    local procedure IsSufficientGenJournalBatchApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean
    var
        IsHandled: Boolean;
        IsSufficient: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsSufficientGenJournalBatchApprover(UserSetup, ApprovalAmountLCY, IsSufficient, IsHandled);
        if IsHandled then
            exit(IsSufficient);

        if UserSetup."SBC JnlBatch Unlimited Approv" or
           ((ApprovalAmountLCY <= UserSetup."SBC JnlBatch AmtApproval Limit") and (UserSetup."SBC JnlBatch AmtApproval Limit" <> 0))
        then
            exit(true);
        exit(false);
    end;

    local procedure GetBatchApprovalAmt(var ApprovalEntryArgument: Record "Approval Entry")
    var
        GenJournalLine: Record "Gen. Journal Line";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        TempName: Code[20];
        BatchName: Code[20];
        Amount: Decimal;
    begin
        //populates batch amount on approval entry
        //standard logic does not populate amount for gen. journal batch
        RecordRef.Get(ApprovalEntryArgument."Record ID to Approve");
        FieldRef := RecordRef.Field(1);
        TempName := FieldRef.Value;
        FieldRef := RecordRef.Field(2);
        BatchName := FieldRef.Value;

        GenJournalLine.SetRange("Journal Template Name", TempName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        if GenJournalLine.findset() then begin
            GenJournalLine.CalcSums("Debit Amount");

            if GenJournalLine."Debit Amount" <> 0 then
                ApprovalEntryArgument.Amount := Abs(GenJournalLine."Debit Amount")
            else begin
                GenJournalLine.CalcSums("Credit Amount");
                ApprovalEntryArgument.Amount := Abs(GenJournalLine."Credit Amount");
            end;
            ApprovalEntryArgument."Amount (LCY)" := ApprovalEntryArgument.Amount;
            ApprovalEntryArgument."Sender ID" := UserId;
        end;
    end;

    local procedure FinalUserEntryExists(ApprovalEntryArgument: Record "Approval Entry"; FinalUserApprovID: Code[50]): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetCurrentKey("Record ID to Approve", "Workflow Step Instance ID", "Sequence No.", "Approver ID", Status);
        ApprovalEntry.SetRange("Table ID", ApprovalEntryArgument."Table ID");
        ApprovalEntry.SetRange("Record ID to Approve", ApprovalEntryArgument."Record ID to Approve");
        ApprovalEntry.SetRange("Workflow Step Instance ID", ApprovalEntryArgument."Workflow Step Instance ID");
        ApprovalEntry.SetRange("Approver ID", FinalUserApprovID);
        ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open);
        exit(not ApprovalEntry.IsEmpty);
    end;

    #endregion workflow

    #region releasedPurchaseDocument

    #region releasePurchaseDocumentEvents

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", OnBeforeCheckPurchaseHeaderPendingApproval, '', false, false)]
    local procedure ReleasedPurchaseDocumentOnBeforeCheckPurchaseHeaderPendingApproval(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        if PurchaseHeader.Status = PurchaseHeader.Status::Open then
            IsHandled := AllowReReleaseAfterApproval(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnBeforePrePostApprovalCheckPurch, '', false, false)]
    local procedure ApprovalsMgmtOnBeforePrePostApprovalCheckPurch(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean; var Result: Boolean)
    begin
        if PurchaseHeader.Status = PurchaseHeader.Status::Open then
            IsHandled := AllowReReleaseAfterApproval(PurchaseHeader);
    end;

    #endregion releasePurchaseDocumentEvents

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

    #endregion releasedPurchaseDocument

    #region eventIntegration

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnApprovalsMgmtOnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean; var CustomEventIsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsSufficientGenJournalBatchApproverOnAfterRecRefSetTable(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; GenJournalBatch: Record "Gen. Journal Batch"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsSufficientGenJournalBatchApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    #endregion eventIntegration

    // var
    //     LastSequenceUsed: Integer;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnAfterCreateApprReqForApprTypeSalespersPurchaser, '', false, false)]
    // local procedure "Approvals Mgmt._OnAfterCreateApprReqForApprTypeSalespersPurchaser"(WorkflowStepArgument: Record "Workflow Step Argument"; ApprovalEntryArgument: Record "Approval Entry")
    // var
    //     ApprovalEntryTemp: Record "Approval Entry";
    //     ApprovalEntryLastApprover: Record "Approval Entry";
    //     WorkFlow: Record Workflow;
    //     PurchPayableSetup: Record "Purchases & Payables Setup";
    // begin
    //     if ApprovalEntryArgument."Table ID" = 38 then begin
    //         PurchPayableSetup.Get();
    //         PurchPayableSetup.TestField("SBC Purchase Final Approver");
    //         if WorkFlow.Get(ApprovalEntryArgument."Approval Code") then begin
    //             if WorkFlow."SBC Custom Purch Workflow" = true then begin
    //                 ApprovalEntryTemp.SetFilter("Document No.", '%1', ApprovalEntryArgument."Document No.");
    //                 if ApprovalEntryTemp.FindLast() then begin
    //                     ApprovalEntryLastApprover.SetFilter("Document No.", '%1', ApprovalEntryArgument."Document No.");
    //                     ApprovalEntryLastApprover.SetFilter("Approver ID", '%1', PurchPayableSetup."SBC Purchase Final Approver");
    //                     ApprovalEntryLastApprover.SetFilter(Status, '<>%1&<>%2', ApprovalEntryLastApprover.Status::Canceled, ApprovalEntryLastApprover.Status::Rejected);
    //                     if ApprovalEntryLastApprover.FindSet() then begin
    //                         if ApprovalEntryLastApprover."Sequence No." < ApprovalEntryTemp."Sequence No." then begin
    //                             ApprovalEntryLastApprover."Sequence No." := ApprovalEntryTemp."Sequence No." + 1;
    //                             ApprovalEntryLastApprover.Modify();
    //                         end;
    //                     end
    //                     else begin
    //                         ApprovalEntryLastApprover."Table ID" := ApprovalEntryArgument."Table ID";
    //                         ApprovalEntryLastApprover."Document Type" := ApprovalEntryArgument."Document Type";
    //                         ApprovalEntryLastApprover."Document No." := ApprovalEntryArgument."Document No.";
    //                         ApprovalEntryLastApprover."Salespers./Purch. Code" := ApprovalEntryArgument."Salespers./Purch. Code";
    //                         ApprovalEntryLastApprover."Sequence No." := ApprovalEntryTemp."Sequence No." + 1;
    //                         ApprovalEntryLastApprover."Sender ID" := UserId;
    //                         ApprovalEntryLastApprover.Amount := ApprovalEntryArgument.Amount;
    //                         ApprovalEntryLastApprover."Amount (LCY)" := ApprovalEntryArgument."Amount (LCY)";
    //                         ApprovalEntryLastApprover."Currency Code" := ApprovalEntryArgument."Currency Code";
    //                         ApprovalEntryLastApprover."Approver ID" := PurchPayableSetup."SBC Purchase Final Approver";
    //                         ApprovalEntryLastApprover."Workflow Step Instance ID" := ApprovalEntryArgument."Workflow Step Instance ID";
    //                         ApprovalEntryLastApprover.Status := ApprovalEntryTemp.Status::Created;
    //                         ApprovalEntryLastApprover."Date-Time Sent for Approval" := CreateDateTime(Today, Time);
    //                         ApprovalEntryLastApprover."Last Date-Time Modified" := CreateDateTime(Today, Time);
    //                         ApprovalEntryLastApprover."Last Modified By User ID" := UserId;
    //                         ApprovalEntryLastApprover."Due Date" := CalcDate(WorkflowStepArgument."Due Date Formula", Today);

    //                         case WorkflowStepArgument."Delegate After" of
    //                             WorkflowStepArgument."Delegate After"::Never:
    //                                 Evaluate(ApprovalEntryLastApprover."Delegation Date Formula", '');
    //                             WorkflowStepArgument."Delegate After"::"1 day":
    //                                 Evaluate(ApprovalEntryLastApprover."Delegation Date Formula", '<1D>');
    //                             WorkflowStepArgument."Delegate After"::"2 days":
    //                                 Evaluate(ApprovalEntryLastApprover."Delegation Date Formula", '<2D>');
    //                             WorkflowStepArgument."Delegate After"::"5 days":
    //                                 Evaluate(ApprovalEntryLastApprover."Delegation Date Formula", '<5D>');
    //                             else
    //                                 Evaluate(ApprovalEntryLastApprover."Delegation Date Formula", '');
    //                         end;
    //                         ApprovalEntryLastApprover."Available Credit Limit (LCY)" := ApprovalEntryArgument."Available Credit Limit (LCY)";
    //                         // ApprovalMgmt.SetApproverType(WorkflowStepArgument, ApprovalEntry);
    //                         // ApprovalEntryTemp.SetLimitType(WorkflowStepArgument, ApprovalEntry);
    //                         ApprovalEntryLastApprover."Record ID to Approve" := ApprovalEntryArgument."Record ID to Approve";
    //                         ApprovalEntryLastApprover."Approval Code" := ApprovalEntryArgument."Approval Code";
    //                         ApprovalEntryLastApprover.Insert(true);
    //                     end;
    //                 end;
    //             end;
    //         end;
    //     end;
    // end;
}
