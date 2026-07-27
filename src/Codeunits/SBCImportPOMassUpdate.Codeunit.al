codeunit 50142 "SBC Import PO Mass Update"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnBeforeExecuteResponse, '', false, false)]
    local procedure WorkflowResponseHandlingOnBeforeExecuteResponse(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var Variant: Variant; xVariant: Variant; var IsHandled: Boolean)
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not Variant.IsRecord then
            exit;

        RecordRef.GetTable(Variant);
        if RecordRef.Number = Database::"Purchase Header" then begin
            FieldRef := RecordRef.Field(50036);
            IsHandled := FieldRef.Value();
        end
    end;

    #region importFile

    procedure ImportFile()
    var
        Instream: InStream;
        FromFile: Text;
        SheetName: Text;
        ChooseFileLbl: Label 'Please choose the Excel file';
    begin
        if UploadIntoStream(StrSubstNo(ChooseFileLbl), '', '', FromFile, Instream) then begin
            SheetName := TempExcelBuffer.SelectSheetsNameStream(Instream);
            TempExcelBuffer.Reset();
            TempExcelBuffer.DeleteAll();
            TempExcelBuffer.OpenBookStream(Instream, SheetName);
            TempExcelBuffer.ReadSheet();
            ReadExcel(Instream);
        end else
            Error('No file found');
    end;

    #endregion importFile

    #region readExcel

    local procedure ReadExcel(Instream: InStream)
    var
        DocNo, NewDocNo : Code[20];
        Status: enum "Purchase Document Status";
        RowNo: Integer;
        MaxRow: Integer;
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRow := TempExcelBuffer."Row No.";

        for RowNo := 2 to MaxRow do begin
            NewDocNo := GetValueAtCell(RowNo, 1);
            if NewDocNo <> DocNo then begin
                if DocNo <> '' then
                    ReleasePurchaseHdr(status, DocNo);
                DocNo := NewDocNo;
                ReopenPurchaseHdr(status, DocNo);
            end;
            UpdatePurchaseOrder(DocNo, EvaluateInt(RowNo, 2), GetValueAtCell(RowNo, 3), EvaluateDate(RowNo, 4), EvaluateDate(RowNo, 5), EvaluateDec(RowNo, 6));
        end;
        ReleasePurchaseHdr(status, DocNo);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text");
    end;

    local procedure EvaluateDec(RowNo: Integer; ColNo: Integer): Decimal
    var
        DecVar: Decimal;
    begin
        if Evaluate(DecVar, GetValueAtCell(RowNo, ColNo)) then
            exit(DecVar);
    end;

    local procedure EvaluateInt(RowNo: Integer; ColNo: Integer): Integer
    var
        IntVar: Integer;
    begin
        if Evaluate(IntVar, GetValueAtCell(RowNo, ColNo)) then
            exit(IntVar);
    end;

    local procedure EvaluateDate(RowNo: Integer; ColNo: Integer): Date
    var
        DateVar: Date;
    begin
        if Evaluate(DateVar, GetValueAtCell(RowNo, ColNo)) then
            exit(DateVar);
        exit(0D);
    end;

    #endregion readExcel

    #region updatePurchOrder

    local procedure UpdatePurchaseOrder(DocNo: Code[20]; LineNo: Integer; ProdPlant1: Text; RequestRecDate: Date; ExpectShipDate: Date; DirectUnitCost: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        ModifyLine: Boolean;
    begin
        if PurchaseLine.Get(PurchaseLine."Document Type"::Order, DocNo, LineNo) then begin
            if PurchaseLine."SBC Production Plant 1" <> ProdPlant1 then begin
                PurchaseLine.validate("SBC Production Plant 1", ProdPlant1);
                ModifyLine := true;
            end;
            if PurchaseLine."Requested Receipt Date" <> RequestRecDate then begin
                PurchaseLine.Validate("Requested Receipt Date", RequestRecDate);
                ModifyLine := true;
            end;
            if PurchaseLine."EVM Expected Ship Date" <> ExpectShipDate then begin
                PurchaseLine.Validate("EVM Expected Ship Date", ExpectShipDate);
                ModifyLine := true;
            end;
            if PurchaseLine."Direct Unit Cost" <> DirectUnitCost then begin
                PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
                ModifyLine := true;
            end;
            if ModifyLine then
                PurchaseLine.Modify(true);
        end;
    end;

    #endregion updatePurchOrder

    #region updateStatus

    local procedure ReopenPurchaseHdr(var Status: enum "Purchase Document Status"; DocNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        CDCApprovalsBridge: Codeunit "CDC Approvals Bridge";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocNo);
        Status := PurchaseHeader.Status;
        case Status of
            Status::Open:
                exit;
            Status::Released:
                begin
                    ReleasePurchaseDocument.Reopen(PurchaseHeader);
                    exit;
                end;
            else begin
                PurchaseHeader."SBC Mass Update" := true;
                CDCApprovalsBridge.CancelApprovalRequest(PurchaseHeader);
                exit;
            end;
        end;
    end;

    local procedure ReleasePurchaseHdr(Status: enum "Purchase Document Status"; DocNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocNo);
        if Status = Status::Open then
            exit;
        if Status = Status::Released then
            if not approvalsMgmt.IsPurchaseApprovalsWorkflowEnabled(PurchaseHeader) then begin
                ReleasePurchaseDocument.ReleasePurchaseHeader(PurchaseHeader, false);
                exit;
            end else
                if AllowReReleaseAfterApproval(PurchaseHeader) then begin
                    ReleasePurchaseDocument.ReleasePurchaseHeader(PurchaseHeader, false);
                    exit;
                end;

        ApprovalsMgmt.OnSendPurchaseDocForApproval(PurchaseHeader);
        PurchaseHeader."SBC Mass Update" := false;
        PurchaseHeader.Modify(false);
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

    #endregion updateStatus
}
