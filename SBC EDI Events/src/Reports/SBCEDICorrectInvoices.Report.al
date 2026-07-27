/// <summary>
/// Report SBCEDI Correct Invoices (ID 50085).
/// </summary>
report 50085 "SBCEDI Correct Invoices"
{
    Caption = 'SBC Utility - Correct Invoices';
    Permissions = tabledata "Sales Invoice Header" = RIMD, tabledata "Sales Invoice Line" = RIMD, tabledata "Sales Header Archive" = RIMD, tabledata "Sales Line Archive" = RIMD, tabledata "Sales Invoice Entity Aggregate" = RIMD, tabledata "Cust. Ledger Entry" = RIMD, tabledata "Detailed Cust. Ledg. Entry" = RIMD, tabledata "G/L Entry" = RIMD, tabledata "Item Entry Relation" = RIMD, tabledata "Sales Shipment Header" = RIMD, tabledata "Sales Shipment Line" = RIMD, tabledata "Value Entry Relation" = RIMD, tabledata "Value Entry" = RIMD, tabledata "Apply Unapply Parameters" = RIMD, tabledata "Sales & Receivables Setup" = RIMD, tabledata "Item" = RIMD, tabledata "Sales Header" = RIMD;
    ProcessingOnly = true;
    UsageCategory = Administration;
    UseRequestPage = true;
    ApplicationArea = All;

    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", SystemCreatedAt;
            CalcFields = "Amount", "Remaining Amount";
            trigger OnAfterGetRecord()
            begin
                if (SalesInvoiceHeader.Amount <> 0) or GlobalOptionAllowReverseZeroDollarAmmounts then
                    ProcessInvoiceHeader(SalesInvoiceHeader);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    Caption = 'Correction Options';
                    // field(Option_CreatedDateTime; GlobalOptionCreatedDateTime)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Created Date Time';
                    //     ToolTip = 'Created Date Time';
                    // }
                    field(Option_ForceCopyDocument; GlobalOptionForceCopyDocument)
                    {
                        ApplicationArea = All;
                        Caption = 'Force Copy Document';
                        ToolTip = 'This setting will delete an existing copied document and create a new one.';
                    }
                    field(Option_ForceUpdate; GlobalForceUpdateOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Force Update Option';
                        ToolTip = 'This setting will force the update of the document regardless of the unit price status.';
                    }
                    field(Option_UseOriginalPostingDate; GlobalOptionUseOriginalPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Original Posting Date';
                        ToolTip = 'When this is selected, the Document Posting Date below will be ignored and the original posting date on the document being corrected will be used for the correction document and the replacement document.';
                    }
                    field(Option_UseCustomerCPGandBillToOnSalesDoc; GlobalOptionUseCustomerCPGandBillToOnSalesDoc)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Current Bill-to and CPG on Sales Document';
                        ToolTip = 'This setting will use the current Customer Posting Group and Bill-to Customer on the Sales Document rather than the one from the copied original document.';
                    }
                    field(Option_AllowReverseZeroDollarAmmounts; GlobalOptionAllowReverseZeroDollarAmmounts)
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Reverse Zero Dollar Amounts';
                        ToolTip = 'This setting will allow the reversal of zero dollar amounts on the corrected document.';
                    }
                    field(Option_SetUnitPriceToZero; GlobalOptionSetUnitPriceToZero)
                    {
                        ApplicationArea = All;
                        Caption = 'Set Unit Price to Zero';
                        ToolTip = 'This setting will set the unit price to zero on the corrected document.';
                    }
                    field(Option_ReplacementSuffix; GlobalOptionReplacementSuffix)
                    {
                        ApplicationArea = All;
                        Caption = 'Replacement Suffix';
                        ToolTip = 'This setting will add a suffix to the document number of the replacement document.';
                    }
                    field(Option_SkipCopyDocument; GlobalSkipCopyDocument)
                    {
                        ApplicationArea = All;
                        Caption = 'Skip Copy Document';
                        ToolTip = 'This setting will skip the copy document process.';
                    }
                    field(Option_DocumentPostingDate; GlobalOptionDocumentPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Document Posting Date';
                        ToolTip = 'Setting this date will override the date of the corrected document and the replacement document. Do not use this if you would like the correction document and the replacement document to use the original document dates.';
                        Enabled = not GlobalOptionUseOriginalPostingDate;
                        ShowMandatory = not GlobalOptionUseOriginalPostingDate;
                        trigger OnValidate()
                        begin
                            // if GlobalOptionDocumentPostingDate = 0D then
                            //     exit;
                            // GlobalOptionDocumentPostingDate := CalcDate(Format(GlobalOptionDocumentPostingDate));
                        end;
                    }
                }
            }
        }


        actions
        {
            area(processing)
            {
            }
        }
    }
    var
        GlobalForceUpdateOption: Boolean;
        GlobalOptionForceCopyDocument: Boolean;
        GlobalSkipCopyDocument: Boolean;
        GlobalOptionUseOriginalPostingDate: Boolean;
        GlobalOptionUseCustomerCPGandBillToOnSalesDoc: Boolean;
        GlobalOptionAllowReverseZeroDollarAmmounts: Boolean;
        GlobalOptionSetUnitPriceToZero: Boolean;
        GlobalOptionDocumentPostingDate: Date;
        TradePartnerCustomerNo: Code[20];
        ReplacedDocumentLabel: Label '-X', Locked = true;
        GlobalOptionReplacementSuffix: Text;
        PostingDateErrorMessageLabel: Label 'If Use Original Posting Date is not set, then you must enter a Document Posting Date.';
        GlobalOrderUpdateList: List of [Code[20]];

    trigger OnPreReport()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        ValidatePostingDateSettings();

        SalesSetup.Get();
        TradePartnerCustomerNo := SalesSetup."EVM Trade Partner Customer No.";
    end;

    trigger OnPostReport()
    begin
        if GlobalOrderUpdateList.Count() = 0 then
            exit;
        CorrectDocuments();
    end;

    internal procedure CorrectDocuments()
    var
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        UpdateSalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeaderArchive: Record "Sales Header Archive";
        ItemList: List of [Code[20]];
        CurrentOrderNo: Code[20];
        FormattedOrderNoText: Text[20];
        UpdateOrderNo: Code[20];
        WriteTransaction: Boolean;
        CancelledDocument: Record "Cancelled Document";
        StatusDialog: Dialog;
        CorrectedSalesInvoiceHeader: Record "Sales Invoice Header";
        CancelledSalesInvoiceHeader: Record "Sales Invoice Header";
        AlreadyProcessed: Boolean;
    begin
        CheckEmersonCustomer();
        // // SalesInvoiceLine.SetFilter(SystemCreatedAt, '%1..', GlobalOptionCreatedDateTime);
        // SalesInvoiceHeader.SetFilter(SystemCreatedAt, '%1..', GlobalOptionCreatedDateTime);
        // if SalesInvoiceHeader.IsEmpty() then
        //     exit;
        // SalesInvoiceHeader.FindSet();
        // repeat
        //     ProcessInvoiceHeader(SalesInvoiceHeader);
        // until SalesInvoiceHeader.Next() = 0;

        if GuiAllowed() then
            StatusDialog.Open('Correcting Document: #1#####', CurrentOrderNo);
        foreach CurrentOrderNo in GlobalOrderUpdateList do begin
            if GuiAllowed() then
                StatusDialog.Update();

            FormattedOrderNoText := Format(CurrentOrderNo);
            case true of
                not FormattedOrderNoText.Contains(ReplacedDocumentLabel + GlobalOptionReplacementSuffix):
                    UpdateOrderNo := CurrentOrderNo + ReplacedDocumentLabel + GlobalOptionReplacementSuffix;
                FormattedOrderNoText.EndsWith(ReplacedDocumentLabel + GlobalOptionReplacementSuffix):
                    begin
                        UpdateOrderNo := CurrentOrderNo;
                        CurrentOrderNo := FormattedOrderNoText.Replace(ReplacedDocumentLabel + GlobalOptionReplacementSuffix, '');
                    end;
            end;

            CorrectedSalesInvoiceHeader.SetFilter("No.", '%1', CurrentOrderNo);
            AlreadyProcessed := not CorrectedSalesInvoiceHeader.IsEmpty() and CancelledDocument.FindSalesCancelledInvoice(UpdateOrderNo);
            if not AlreadyProcessed then begin // This is added so that documents that have already been corrected can be ignored.
                // WriteTransaction := Database.IsInWriteTransaction();
                if UpdateDocumentName(CurrentOrderNo, UpdateOrderNo) then
                    Commit();
                //  WriteTransaction := Database.IsInWriteTransaction();


                // UpdateOrderNo := CurrentOrderNo;

                if UpdateSalesInvoiceHeader.Get(UpdateOrderNo) then begin
                    if not CancelledDocument.FindSalesCancelledInvoice(UpdateSalesInvoiceHeader."No.") then begin
                        UnapplyInvoice(UpdateSalesInvoiceHeader);
                        CorrectInvoice(UpdateSalesInvoiceHeader);
                    end;
                    if not GlobalSkipCopyDocument then
                        ProcessCopyDocument(UpdateSalesInvoiceHeader, CurrentOrderNo);
                    // UpdateDocumentLines();
                end;
            end;
            // SalesHeaderArchive.SetRange("Document Type", SalesHeaderArchive."Document Type"::Order);
            // SalesHeaderArchive.SetRange("No.", SalesInvoiceHeader."Order No.");
            // if SalesHeaderArchive.IsEmpty() then
            //     exit;
        end;

        if GuiAllowed() then
            StatusDialog.Close();
    end;


    internal procedure UpdateDocumentName(SalesInvoiceHeaderNo: Code[20]; UpdatedDocumentNo: Code[20]) Updated: Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLineArchive: Record "Sales Line Archive";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        ValueEntryRelation: Record "Value Entry Relation";
        ValueEntry: Record "Value Entry";
        LockTables: Boolean;
    begin
        LockTables := False;
        Database.LockTimeout(true);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not CustLedgerEntry.IsEmpty() then
            CustLedgerEntry.ModifyAll("Document No.", UpdatedDocumentNo);

        DetailedCustLedgEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not DetailedCustLedgEntry.IsEmpty() then
            DetailedCustLedgEntry.ModifyAll("Document No.", UpdatedDocumentNo);

        GLEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not GlEntry.IsEmpty() then
            GLEntry.ModifyAll("Document No.", UpdatedDocumentNo);

        ItemEntryRelation.SetRange("Order No.", SalesInvoiceHeaderNo);
        if not ItemEntryRelation.IsEmpty() then
            ItemEntryRelation.ModifyAll("Order No.", UpdatedDocumentNo);

        SalesHeaderArchive.SetRange("No.", SalesInvoiceHeaderNo);
        if not SalesHeaderArchive.IsEmpty() then begin
            // SalesHeaderArchive.ModifyAll("Last Posting No.", UpdatedDocumentNo);
            SalesHeaderArchive.FindSet(LockTables);
            repeat
                SalesHeaderArchive.Rename(SalesHeaderArchive."Document Type", UpdatedDocumentNo, SalesHeaderArchive."Doc. No. Occurrence", SalesHeaderArchive."Version No.");
                SalesHeaderArchive."Last Posting No." := UpdatedDocumentNo;
                SalesHeaderArchive.Modify();
            until SalesHeaderArchive.Next() = 0;
        end;

        SalesLineArchive.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not SalesLineArchive.IsEmpty() then begin

            // SalesLineArchive.ModifyAll("Document No.", UpdatedDocumentNo);
            SalesLineArchive.FindSet(LockTables);
            repeat
                SalesLineArchive.Rename(SalesLineArchive."Document Type", UpdatedDocumentNo, SalesLineArchive."Doc. No. Occurrence", SalesLineArchive."Version No.", SalesLineArchive."Line No.");
            until SalesLineArchive.Next() = 0;
        end;

        SalesInvoiceEntityAggregate.SetRange("No.", SalesInvoiceHeaderNo);
        if not SalesInvoiceEntityAggregate.IsEmpty() then begin
            // SalesInvoiceEntityAggregate.ModifyAll("Order No.", UpdatedDocumentNo);
            // SalesInvoiceEntityAggregate.ModifyAll("No.", UpdatedDocumentNo);
            SalesInvoiceEntityAggregate.FindSet(LockTables);
            repeat
                SalesInvoiceEntityAggregate.SetIsRenameAllowed(true);
                SalesInvoiceEntityAggregate.Rename(UpdatedDocumentNo, SalesInvoiceEntityAggregate.Posted);
                SalesInvoiceEntityAggregate."Order No." := UpdatedDocumentNo;
                SalesInvoiceEntityAggregate.Modify();
            until SalesInvoiceEntityAggregate.Next() = 0;
        end;

        SalesInvoiceHeader.SetRange("No.", SalesInvoiceHeaderNo);
        if not SalesInvoiceHeader.IsEmpty() then begin
            // SalesInvoiceHeader.ModifyAll("Order No.", UpdatedDocumentNo);
            // SalesInvoiceHeader.ModifyAll("No.", UpdatedDocumentNo);
            SalesInvoiceHeader.FindSet(LockTables);
            repeat
                SalesInvoiceHeader.Rename(UpdatedDocumentNo);
                SalesInvoiceHeader."Order No." := UpdatedDocumentNo;
                SalesInvoiceHeader.Modify();
            until SalesInvoiceHeader.Next() = 0;
        end;

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not SalesInvoiceLine.IsEmpty() then begin
            // SalesInvoiceLine.ModifyAll("Order No.", UpdatedDocumentNo);
            // SalesInvoiceLine.ModifyAll("Document No.", UpdatedDocumentNo);
            SalesInvoiceLine.FindSet(LockTables);
            repeat
                SalesInvoiceLine.Rename(UpdatedDocumentNo, SalesInvoiceLine."Line No.");
                SalesInvoiceLine."Order No." := UpdatedDocumentNo;
                SalesInvoiceLine.Modify();
            until SalesInvoiceLine.Next() = 0;
        end;

        SalesShipmentHeader.SetRange("Order No.", SalesInvoiceHeaderNo);
        if not SalesShipmentHeader.IsEmpty() then
            SalesShipmentHeader.ModifyAll("Order No.", UpdatedDocumentNo);

        SalesShipmentLine.SetRange("Order No.", SalesInvoiceHeaderNo);
        if not SalesShipmentLine.IsEmpty() then
            SalesShipmentLine.ModifyAll("Order No.", UpdatedDocumentNo);

        ValueEntryRelation.SetFilter("Source RowId", '%1&<>%2', '*' + SalesInvoiceHeaderNo + '*', '*' + SalesInvoiceHeaderNo + ReplacedDocumentLabel + GlobalOptionReplacementSuffix + '*');
        if ValueEntryRelation.FindSet(LockTables) then
            repeat
                ValueEntryRelation."Source RowId" := ValueEntryRelation."Source RowId".Replace(SalesInvoiceHeaderNo, UpdatedDocumentNo);
                ValueEntryRelation.Modify();
            until ValueEntryRelation.Next() = 0;

        ValueEntry.SetRange("Document No.", SalesInvoiceHeaderNo);
        if not ValueEntry.IsEmpty() then
            ValueEntry.ModifyAll("Document No.", UpdatedDocumentNo);

        Updated := Database.IsInWriteTransaction();
        // Database.LockTimeout(LockTables);
    end;

    internal procedure UnapplyInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        SBCEDICorrectInvoiceEvents: Codeunit "SBCEDI Correct Invoice Events";

        ApplicationEntryNo: Integer;
    begin
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        if CustLedgerEntry.IsEmpty() then
            exit;
        CustLedgerEntry.SetLoadFields("Entry No.");
        CustLedgerEntry.FindFirst();
        ApplicationEntryNo := CustEntryApplyPostedEntries.FindLastApplEntry(CustLedgerEntry."Entry No.");
        if ApplicationEntryNo = 0 then
            exit;
        DetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
        DetailedCustLedgEntry.SetRange(Unapplied, false);
        DetailedCustLedgEntry.SetRange("Entry No.", ApplicationEntryNo);
        if DetailedCustLedgEntry.IsEmpty() then
            exit;
        // DetailedCustLedgEntry.SetLoadFields("Document No.", "Posting Date");
        DetailedCustLedgEntry.FindFirst();
        // CustEntryApplyPostedEntries.CheckCustLedgEntryToUnapply(CustLedgerEntry."Entry No.", DetailedCustLedgEntry);
        ApplyUnapplyParameters."Document No." := DetailedCustLedgEntry."Document No.";
        if GlobalOptionDocumentPostingDate <> 0D then
            ApplyUnapplyParameters."Posting Date" := GlobalOptionDocumentPostingDate
        else
            ApplyUnapplyParameters."Posting Date" := DetailedCustLedgEntry."Posting Date";
        SBCEDICorrectInvoiceEvents.Bind(true);
        CustEntryApplyPostedEntries.PostUnApplyCustomer(DetailedCustLedgEntry, ApplyUnapplyParameters);
    end;

    internal procedure CorrectInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        SBCEDICorrectInvoiceEvents: Codeunit "SBCEDI Correct Invoice Events";
    begin
        SBCEDICorrectInvoiceEvents.Bind(true);
        SBCEDICorrectInvoiceEvents.SetFromCorrection(true);
        SBCEDICorrectInvoiceEvents.SetAllowZeroDollarAmount(GlobalOptionAllowReverseZeroDollarAmmounts);
        if not GlobalOptionUseOriginalPostingDate then
            SBCEDICorrectInvoiceEvents.SetDocumentPostingDate(GlobalOptionDocumentPostingDate);
        CorrectPostedSalesInvoice.TestCorrectInvoiceIsAllowed(SalesInvoiceHeader, false);
        CorrectPostedSalesInvoice.CancelPostedInvoice(SalesInvoiceHeader);
        SBCEDICorrectInvoiceEvents.Unbind(true);
    end;

    internal procedure CopyDocument(SalesInvoiceHeader: Record "Sales Invoice Header"; NewDocumentNo: Code[20])
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesHeader: Record "Sales Header";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
    begin
        SalesReceivablesSetup.SetLoadFields("Exact Cost Reversing Mandatory");
        SalesReceivablesSetup.FindFirst();

        // SalesHeaderArchive.Get(CopyDocumentMgt.GetSalesDocumentType(Enum::"Sales Document Type From"::"Arch. Order"), SalesInvoiceHeader."No.", 1, 1);


        CopyDocumentMgt.SetProperties(true, false, false, false, true, SalesReceivablesSetup."Exact Cost Reversing Mandatory", false);
        // CopyDocumentMgt.SetArchDocVal(SalesHeaderArchive."Doc. No. Occurrence", SalesHeaderArchive."Version No.");
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := NewDocumentNo;
        SalesHeader.Insert();
        // CopyDocMgt.CopySalesDoc(FromDocType, FromDocNo, SalesHeader);
        CopyDocumentMgt.CopySalesDoc(Enum::"Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", SalesHeader);
        if SalesHeader."Bill-to Customer No." <> TradePartnerCustomerNo then
            SalesHeader."Bill-to Customer No." := TradePartnerCustomerNo;
        SalesHeader."Posting No." := SalesHeader."No.";
        if not GlobalOptionUseOriginalPostingDate then
            SalesHeader."Posting Date" := GlobalOptionDocumentPostingDate;
        if GlobalOptionUseCustomerCPGandBillToOnSalesDoc then begin
            Customer.SetRange("No.", SalesInvoiceHeader."Sell-to Customer No.");
            Customer.SetFilter("Customer Posting Group", '<>%1', '');
            Customer.SetLoadFields("No.", "Customer Posting Group", "Bill-to Customer No.", "Gen. Bus. Posting Group");
            if Customer.FindFirst() then begin
                SalesHeader."Customer Posting Group" := Customer."Customer Posting Group";
                if (SalesHeader."Bill-to Customer No." <> Customer."Bill-to Customer No.") then // this is here to allow for a bill-to customer other than Emerson to be added in the event that one is set on the customer record.
                    SalesHeader."Bill-to Customer No." := Customer."Bill-to Customer No.";
                if SalesHeader."Bill-to Customer No." = '' then  // this checks the bill-to customer and sets it to the sell-to customer if it is blank.
                    SalesHeader."Bill-to Customer No." := Customer."No.";
                if SalesHeader."Gen. Bus. Posting Group" <> Customer."Gen. Bus. Posting Group" then
                    SalesHeader."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";

            end;
        end;
        SalesHeader.Modify();
        if GlobalOptionSetUnitPriceToZero then begin
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, Enum::"Sales Line Type"::Item);
            // SalesLine.SetFilter("Unit Price", '<>%1', 0);
            if SalesLine.IsEmpty() then
                exit;
            SalesLine.FindFirst();
            repeat
                SalesLine.Validate("Line Discount %", 0);
                SalesLine.Validate("Unit Price", 0);
                if GlobalOptionUseCustomerCPGandBillToOnSalesDoc then
                    SalesLine."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
                SalesLine.Modify();
            until SalesLine.Next() = 0;
        end;
    end;



    internal procedure UpdateDocumentLines()
    begin

    end;

    local procedure CheckSalesInvoiceUpdateStatus(var SalesInvoiceLine: Record "Sales Invoice Line") NeedsUpdate: Boolean
    var
        SBCEDICorrectInvoiceEvents: Codeunit "SBCEDI Correct Invoice Events";
        NewUnitPrice: Decimal;
    begin
        NeedsUpdate := GlobalForceUpdateOption;
        if NeedsUpdate then
            exit;
        NewUnitPrice := SBCEDICorrectInvoiceEvents.GetUoMUnitPrice(SalesInvoiceHeader."Currency Code", SalesInvoiceLine."No.", SalesInvoiceLine."Unit of Measure Code");
        if NewUnitPrice = 0 then
            exit;
        NeedsUpdate := SalesInvoiceLine."Unit Price" <> NewUnitPrice;
    end;

    local procedure PopulateOrderUpdateList(var SalesInvoiceLine: Record "Sales Invoice Line"; var OrderUpdateList: List of [Code[20]])
    var
        NeedsUpdate: Boolean;
    begin
        if SalesInvoiceLine.IsEmpty() then
            exit;
        SalesInvoiceLine.SetLoadFields("No.", "Unit Price", "Unit of Measure Code");
        SalesInvoiceLine.FindSet();
        repeat
            NeedsUpdate := CheckSalesInvoiceUpdateStatus(SalesInvoiceLine);
            if NeedsUpdate then
                OrderUpdateList.Add(SalesInvoiceLine."Document No.");
        until NeedsUpdate Or (SalesInvoiceLine.Next() = 0);
    end;

    local procedure ProcessInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        // SalesInvoiceHeader.CalcFields("Amount", "Remaining Amount");
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        PopulateOrderUpdateList(SalesInvoiceLine, GlobalOrderUpdateList);
    end;

    local procedure ProcessCopyDocument(var UpdateSalesInvoiceHeader: Record "Sales Invoice Header"; var CurrentOrderNo: Code[20])
    var
        CorrectedSalesOrderHeader: Record "Sales Header";
        SBCEDICorrectInvoiceEvents: Codeunit "SBCEDI Correct Invoice Events";
    begin
        if CorrectedSalesOrderHeader.Get(CorrectedSalesOrderHeader."Document Type"::Order, CurrentOrderNo) then begin
            if not GlobalOptionForceCopyDocument then
                exit;
            CorrectedSalesOrderHeader.SetHideValidationDialog(true);
            CorrectedSalesOrderHeader.DeleteAllSalesLines();
            CorrectedSalesOrderHeader.Delete();
        end;
        SBCEDICorrectInvoiceEvents.Bind(true);
        CopyDocument(UpdateSalesInvoiceHeader, CurrentOrderNo);
        SBCEDICorrectInvoiceEvents.Unbind(true);
    end;

    local procedure CheckEmersonCustomer()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("No.", TradePartnerCustomerNo);
        Customer.SetRange("Allow Multiple Posting Groups", true);
        if not Customer.IsEmpty() then
            exit;
        Customer.Get(TradePartnerCustomerNo);
        Customer."Allow Multiple Posting Groups" := true;
        Customer.Modify();
        Commit();
    end;

    local procedure ValidatePostingDateSettings()
    begin
        if (GlobalOptionDocumentPostingDate <> 0D) then
            exit;

        if GlobalOptionUseOriginalPostingDate then
            exit;

        Error(PostingDateErrorMessageLabel);
    end;
}