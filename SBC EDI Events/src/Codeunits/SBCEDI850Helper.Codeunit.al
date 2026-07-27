/// <summary>
/// Codeunit SBCEDI Record Helper (ID 50085).
/// </summary>
codeunit 50085 "SBCEDI 850 Helper"
{
    var
        ImportSalesOrderLabel: Label 'I_SLSORD', Locked = true;
        UpdateSalesOrderLabel: Label 'U_SLSORD', Locked = true;
        UpdatePurchaseOrderLabel: Label 'U_PURWSA', Locked = true;
        ImportUpdateOrderEDIDocLabel: Label '851', Locked = true;
        Create851QstLbl: Label 'Enabling this document requires a duplicate version of the 850 EDI document called the 851 to be creatred. Do you want to create this document now?';
        EDI851SuccessfulLbl: Label 'The EDI 851 was successfully created.';
        MSGSegmentLabel: Label 'MSG';
        LiquidationElementValueLabel: Label 'SMOG ORDER';
    #region "Record Creation"
    local procedure SBCCreateMissingShipTo(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.") Created: Boolean
    var
        LAXEDIDocument: Record "LAX EDI Document";
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        SalesHeader: Record "Sales Header";
        SBCCustomerNoText: Text;
        SBCShipToCodeText: Text;
        SBCShipToNameText: Text;
        SBCShipToAddress1Text: Text;
        SBCShipToAddress2Text: Text;
        SBCShipToCityText: Text;
        SBCShipToStateText: Text;
        SBCShipToZipText: Text;
        SBCShipToCountryText: Text;
        ShipToCountryBeforeCrossRef: Text;
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
        EDICustCrossRef: Record "LAX EDI Cust. Cross Reference";
        SBCEDIEventHelper: Codeunit "SBCEDI Event Helper";
    begin
        // LAXEDIDocument.Get(EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.", EDIRecDocHdr."EDI Version", LAXEDIDocument.Type::Import);
        LAXEDIDocument.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        LAXEDIDocument.SetRange("Document", EDIRecDocHdr.Document);
        LAXEDIDocument.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
        LAXEDIDocument.SetRange("Version", EDIRecDocHdr."EDI Version");
        LAXEDIDocument.SetRange("Type", LAXEDIDocument.Type::Import);
        LAXEDIDocument.SetRange("SBC Create Missing Ship-To", true);
        if LAXEDIDocument.IsEmpty() then
            exit;

        //Get lookup values
        SBCCustomerNoText := GetSellToCustomerNoFromEDIHeader(EDIRecDocHdr);
        SBCShipToCodeText := GetShipToNoFromEDIHeader(EDIRecDocHdr);
        if (SBCShipToCodeText = '') or (SBCCustomerNoText = '') then
            exit;
        // Check for existing cross reference
        EDICustCrossRef.SetCurrentKey("EDI Ship To Code");
        EDICustCrossRef.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        EDICustCrossRef.SetRange("EDI Sell To Code", CopyStr(SBCCustomerNoText, 1, 20));
        EDICustCrossRef.SetRange("EDI Ship To Code", CopyStr(SBCShipToCodeText, 1, 20));
        EDICustCrossRef.SetFilter("Sell To Code", '<>%1', '');
        EDICustCrossRef.SetFilter("Ship To Code", '<>%1', '');
        if not EDICustCrossRef.IsEmpty() then
            exit;
        // Check For Existing Customer and Ship-To
        Customer.SetRange("SBC Emerson Customer No.", SBCCustomerNoText);
        Customer.SetLoadFields("No.", "Location Code");
        if not Customer.FindFirst() then
            exit;
        ShiptoAddress.SetFilter("Customer No.", '%1', Customer."No.");
        ShiptoAddress.SetFilter("SBC Emerson Ship-to Code", '%1', SBCShipToCodeText);
        if ShiptoAddress.FindFirst() then begin
            SBCEDIEventHelper.CheckECR(ShiptoAddress);
            exit;
        end;
        // If the  ship-to does not exist, then collect values and create it and set the ECR.
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No."); // Set to correct document first

        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Code"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToCodeText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Name"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToNameText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Address"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToAddress1Text := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Address 2"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToAddress2Text := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to City"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToCityText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to County"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToStateText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Post Code"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCShipToZipText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Country/Region Code"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then begin
            ShipToCountryBeforeCrossRef := EDIRecDocFields."Field Text Value".Trim();
            SBCShipToCountryText := GetCrossRefVal(ShipToCountryBeforeCrossRef, 36, EDIRecDocHdr."Trade Partner No.");
        end;


        // if the code reaches this point, then the ship-to address does not exist for the customer.
        ShiptoAddress.Init();
        ShiptoAddress."Customer No." := Customer."No.";
        ShiptoAddress."Location Code" := Customer."Location Code";
        ShiptoAddress.Code := SBCShipToCodeText;
        ShiptoAddress."SBC Auto-Created Ship-To" := true;
        ShiptoAddress."SBC Emerson Ship-to Code" := SBCShipToCodeText;
        ShiptoAddress.Name := SBCShipToNameText;
        ShiptoAddress.Address := SBCShipToAddress1Text;
        ShiptoAddress."Address 2" := SBCShipToAddress2Text;
        ShiptoAddress.City := SBCShipToCityText;
        ShiptoAddress.County := SBCShipToStateText;
        ShiptoAddress."Post Code" := SBCShipToZipText;
        ShiptoAddress."Country/Region Code" := SBCShipToCountryText;
        Created := ShiptoAddress.Insert();
    end;

    local procedure GetCrossRefVal(BeforeValue: Text; CrossRefNo: Integer; TradePartnerNo: Code[20]): Text
    var
        LAXEDIGeneralCrossRef: Record "LAX EDI General Cross Ref.";
    begin
        LAXEDIGeneralCrossRef.Reset();
        LAXEDIGeneralCrossRef.SetRange("Trade Partner", TradePartnerNo);
        LAXEDIGeneralCrossRef.SetRange("Cross Reference", CrossRefNo);
        LAXEDIGeneralCrossRef.SetRange("EDI Value", BeforeValue);
        if LAXEDIGeneralCrossRef.FindFirst() then
            exit(LAXEDIGeneralCrossRef."Cross Reference Value");

        exit(BeforeValue);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeCopyShipToCustomerAddressFieldsFromShipToAddr, '', false, false)]
    local procedure SalesHeader_OnBeforeCopyShipToCustomerAddressFieldsFromShipToAddr(var SalesHeader: Record "Sales Header"; var ShipToAddress: Record "Ship-to Address")
    begin
        ShipToAddress."Country/Region Code" := GetCrossRefVal(ShipToAddress."Country/Region Code", 36, SalesHeader."LAX EDI Trade Partner");
    end;

    local procedure SBCCreateMissingCustomer(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.") Created: Boolean
    var
        LAXEDIDocument: Record "LAX EDI Document";
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        SalesHeader: Record "Sales Header";
        SBCCustomerNoText: Text;
        SBCSellToCustomerNameText: Text;
        SBCSellToAddress1Text: Text;
        SBCSellToAddress2Text: Text;
        SBCSellToCityText: Text;
        SBCSellToStateText: Text;
        SBCSellToZipText: Text;
        SBCSellToCountryText: Text;
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
        EDICustCrossRef: Record "LAX EDI Cust. Cross Reference";
        SBCEDIEventHelper: Codeunit "SBCEDI Event Helper";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustomerTempl: Record "Customer Templ.";
    begin
        // LAXEDIDocument.Get(EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.", EDIRecDocHdr."EDI Version", LAXEDIDocument.Type::Import);
        LAXEDIDocument.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        LAXEDIDocument.SetRange("Document", EDIRecDocHdr.Document);
        LAXEDIDocument.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
        LAXEDIDocument.SetRange("Version", EDIRecDocHdr."EDI Version");
        LAXEDIDocument.SetRange("Type", LAXEDIDocument.Type::Import);
        LAXEDIDocument.SetRange("SBC Create Missing Customer", true);
        if LAXEDIDocument.IsEmpty() then
            exit;

        //Get lookup values
        EDIRecDocFields.Reset;
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetRange("Table No.", DATABASE::"Sales Header");
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Customer No."));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCCustomerNoText := EDIRecDocFields."Field Text Value".Trim();

        if SBCCustomerNoText = '' then
            exit;
        // Check for existing cross reference
        EDICustCrossRef.SetCurrentKey("EDI Ship To Code");
        EDICustCrossRef.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        EDICustCrossRef.SetRange("EDI Sell To Code", CopyStr(SBCCustomerNoText, 1, 20));
        EDICustCrossRef.SetFilter("EDI Ship To Code", '<>%1', '');
        EDICustCrossRef.SetFilter("Sell To Code", '<>%1', '');
        EDICustCrossRef.SetFilter("Ship To Code", '<>%1', '');
        if not EDICustCrossRef.IsEmpty() then
            exit;
        // Check For Existing Customer and Ship-To
        Customer.SetRange("SBC Emerson Customer No.", SBCCustomerNoText);
        Customer.SetLoadFields("No.", "Location Code");
        if Customer.FindFirst() then
            exit;

        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Customer Name"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToCustomerNameText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Address"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToAddress1Text := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Address 2"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToAddress2Text := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to City"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToCityText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to County"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToStateText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Post Code"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToZipText := EDIRecDocFields."Field Text Value".Trim();
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Country/Region Code"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if EDIRecDocFields.FindFirst() then
            SBCSellToCountryText := EDIRecDocFields."Field Text Value".Trim();

        // if the code reaches this point, then the Customer does not exist and will be created.
        Customer.Init();
        Customer."No." := SBCCustomerNoText;
        Customer."SBC Emerson Customer No." := SBCCustomerNoText;
        Customer."SBC Auto-Created Customer" := true;
        Customer.Validate(Name, SBCSellToCustomerNameText);
        Customer.Address := SBCSellToAddress1Text;
        Customer."Address 2" := SBCSellToAddress2Text;
        Customer.City := SBCSellToCityText;
        Customer.County := SBCSellToStateText;
        Customer."Post Code" := SBCSellToZipText;
        Customer."Country/Region Code" := SBCSellToCountryText;
        Created := Customer.Insert(true);
        if not Created then
            exit;

        LAXEDIDocument.SetLoadFields("SBC Customer Template");
        LAXEDIDocument.FindFirst();
        if LAXEDIDocument."SBC Customer Template" = '' then
            exit;
        if not CustomerTempl.Get(LAXEDIDocument."SBC Customer Template") then
            exit;

        CustomerTemplMgt.ApplyCustomerTemplate(Customer, CustomerTempl);
    end;

    #endregion "Record Creation"

    #region "SO Update"
    internal procedure SBCSetSOUpdateDocType(var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.") Updated: Boolean
    var
        LAXEDISalesDocumentChange: Codeunit "LAX EDI Sales Document Change";
        LAXEDIDocument: Record "LAX EDI Document";
        SalesHeader: Record "Sales Header";
        QuoteSalesHeader: Record "Sales Header";
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        LineNotCopied: Integer;
        NextLineNo: Integer;
    begin
        if LAXEDIReceiveDocumentHdr.Document <> ImportSalesOrderLabel then
            exit;
        LAXEDIReceiveDocumentHdr."EDI Document No." := '851';
        Updated := LAXEDIReceiveDocumentHdr.Modify();
        if not Updated then
            exit;
        Commit();
    end;


    local procedure UpdateEDISalesOrder(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.") Updated: Boolean
    var
        LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
    begin
        LAXEDIReceiveDocumentHdr.CopyFilters(EDIRecDocHdr);
        if LAXEDIReceiveDocumentHdr.IsEmpty() then
            exit;

        LAXEDIReceiveDocumentHdr.SetLoadFields("Internal Doc. No.", "Trade Partner No.", "Document", "EDI Document No.", "EDI Version");
        LAXEDIReceiveDocumentHdr.FindFirst();
        // LAXEDIDocument.Get(LAXEDIReceiveDocumentHdr."Trade Partner No.", LAXEDIReceiveDocumentHdr.Document, LAXEDIReceiveDocumentHdr."EDI Document No.", LAXEDIReceiveDocumentHdr."EDI Version", LAXEDIDocument.Type::Import);
        if not AllowSalesOrderUpdate(LAXEDIReceiveDocumentHdr) then
            exit;

        LAXEDIReceiveDocumentHdr.Get(LAXEDIReceiveDocumentHdr."Internal Doc. No.");
        Updated := SBCSetSOUpdateDocType(LAXEDIReceiveDocumentHdr);
    end;

    local procedure AllowSalesOrderUpdate(var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.") AllowUpdate: Boolean
    var
        SalesHeader: Record "Sales Header";
        LAXEDIReceiveDocumentField: Record "LAX EDI Receive Document Field";
        LAXEDIDocument: Record "LAX EDI Document";
    begin
        LAXEDIDocument.SetRange("Trade Partner No.", LAXEDIReceiveDocumentHdr."Trade Partner No.");
        LAXEDIDocument.SetRange("Document", LAXEDIReceiveDocumentHdr.Document);
        LAXEDIDocument.SetRange("EDI Document No.", LAXEDIReceiveDocumentHdr."EDI Document No.");
        LAXEDIDocument.SetRange("Version", LAXEDIReceiveDocumentHdr."EDI Version");
        LAXEDIDocument.SetRange("Type", LAXEDIDocument.Type::Import);
        LAXEDIDocument.SetRange("SBC Allow SO Update from 850", true);
        if LAXEDIDocument.IsEmpty() then
            exit;

        LAXEDIReceiveDocumentField.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        LAXEDIReceiveDocumentField.SetRange("Internal Doc. No.", LAXEDIReceiveDocumentHdr."Internal Doc. No.");
        LAXEDIReceiveDocumentField.SetRange("Table No.", Database::"Sales Header");
        LAXEDIReceiveDocumentField.SetRange("Field No.", SalesHeader.FieldNo("No."));
        LAXEDIReceiveDocumentField.SetLoadFields("Field Text Value");
        if not LAXEDIReceiveDocumentField.FindFirst() then
            exit;
        // if not SalesHeader.Get(SalesHeader."Document Type"::Order, CopyStr(LAXEDIReceiveDocumentField."Field Text Value", 1, MaxStrLen(SalesHeader."No."))) then
        //     exit;
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", CopyStr(LAXEDIReceiveDocumentField."Field Text Value", 1, MaxStrLen(SalesHeader."No.")));
        SalesHeader.SetRange("LAX EDI WHSE Shp. Gen", false);
        SalesHeader.SetRange(Shipped, false);
        if SalesHeader.IsEmpty() then
            exit;

        AllowUpdate := true;
    end;

    local procedure ProcessSOUpdate(Batch: Boolean; var LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDICreateSalesOrder: Codeunit "LAX EDI Create Sales Order";
        LAXEDIReceiveDocumentHdr2: Record "LAX EDI Receive Document Hdr.";
    begin
        if LAXEDICreateSalesOrder.Run(LAXEDIReceiveDocumentHdr) then
            exit;
        LAXEDIReceiveDocumentHdr2.Get(LAXEDIReceiveDocumentHdr."Internal Doc. No.");
        LAXEDIReceiveDocumentHdr2."Error Message Text" := CopyStr(GetLastErrorText, 1, 250);
        LAXEDIReceiveDocumentHdr2.Modify;
        Commit;
        if Batch then
            exit;
        Error(GetLastErrorText);
    end;

    local procedure GetShipToNoFromEDIHeader(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.") SBCShipToCodeText: Text
    var
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        SalesHeader: Record "Sales Header";
    begin
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetRange("Table No.", DATABASE::"Sales Header");
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Code"));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if not EDIRecDocFields.FindFirst() then
            exit;
        SBCShipToCodeText := EDIRecDocFields."Field Text Value".Trim();
    end;

    local procedure ActivateSalesEvents(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        EDICustCrossRef: Record "LAX EDI Cust. Cross Reference";
        SBCEmersonCustomerNoText: Code[20];
        SBCSellToCustomerNoText: Code[20];
    begin
        SBCEmersonCustomerNoText := GetSellToCustomerNoFromEDIHeader(EDIRecDocHdr);
        if SBCEmersonCustomerNoText = '' then
            exit;
        EDICustCrossRef.SetCurrentKey("EDI Ship To Code");
        EDICustCrossRef.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        EDICustCrossRef.SetRange("EDI Sell To Code", CopyStr(SBCEmersonCustomerNoText, 1, 20));
        EDICustCrossRef.SetFilter("Sell To Code", '<>%1', '');
        EDICustCrossRef.SetLoadFields("Sell To Code");
        if EDICustCrossRef.FindFirst() then
            SBCEmersonCustomerNoText := EDICustCrossRef."Sell To Code";


        HandleSmogFlag(EDIRecDocHdr, SBCEmersonCustomerNoText);
    end;

    local procedure SBCProcessSMOGOrder(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    var
        LAXEDIDocument: Record "LAX EDI Document";
    begin
        LAXEDIDocument.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
        LAXEDIDocument.SetRange("Document", EDIRecDocHdr.Document);
        LAXEDIDocument.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
        LAXEDIDocument.SetRange("Version", EDIRecDocHdr."EDI Version");
        LAXEDIDocument.SetRange("SBC SMOG Enabled", true);
        if LAXEDIDocument.IsEmpty() then
            exit;
        ActivateSalesEvents(EDIRecDocHdr);
    end;

    local procedure HandleSmogFlag(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var SBCEmersonCustomerNoText: Code[20])
    var
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        SBCEDISMOGRates: Record "SBCEDI SMOG Rates";
        SellToCustomer: Record Customer;
        SBCEDISalesEventHandler: Codeunit "SBCEDI Sales Event Handler";
    begin
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetFilter(Segment, '%1', MSGSegmentLabel);
        EDIRecDocFields.SetFilter("Field Text Value", '%1', LiquidationElementValueLabel);
        if EDIRecDocFields.IsEmpty() then
            exit;

        SellToCustomer.SetFilter("No.", '%1', SBCEmersonCustomerNoText);
        if SellToCustomer.IsEmpty() then
            exit;
        SellToCustomer.SetLoadFields("Gen. Bus. Posting Group", "Customer Posting Group");
        SellToCustomer.FindFirst();

        // Find the default case of the smog rate
        SBCEDISMOGRates.SetFilter("Customer No.", '%1', '');
        SBCEDISMOGRates.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        SBCEDISMOGRates.SetFilter("Customer Posting Group", '<>%1', '');
        SBCEDISMOGRates.SetFilter("SMOG Rate", '<>%1', 0);
        if SBCEDISMOGRates.IsEmpty() then
            exit;

        SBCEDISMOGRates.FindFirst();
        SellToCustomer."Gen. Bus. Posting Group" := SBCEDISMOGRates."Gen. Bus. Posting Group";
        SellToCustomer."Customer Posting Group" := SBCEDISMOGRates."Customer Posting Group";

        // After a successful smog rate find, call the codeunit that sets the header values (with the swapped posting group values).
        SBCEDISalesEventHandler.SetSellToCustomer(SellToCustomer);
        SBCEDISalesEventHandler.Bind(true);
    end;

    internal procedure GetSellToCustomerNoFromEDIHeader(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.") SBCCustomerNoText: Text
    var
        EDIRecDocFields: Record "LAX EDI Receive Document Field";
        SalesHeader: Record "Sales Header";
    begin
        EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
        EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        EDIRecDocFields.SetRange("Table No.", DATABASE::"Sales Header");
        EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Customer No."));
        EDIRecDocFields.SetLoadFields("Field Text Value");
        if not EDIRecDocFields.FindFirst() then
            exit;
        SBCCustomerNoText := EDIRecDocFields."Field Text Value".Trim();
    end;

    internal procedure CreateEDI851(LAXEDIDocument: Record "LAX EDI Document")
    var
        LAXEDIDocument2: Record "LAX EDI Document";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not GuiAllowed() then
            exit;
        if not LAXEDIDocument."SBC Allow SO Update from 850" then
            exit;
        LAXEDIDocument2 := LAXEDIDocument;
        LAXEDIDocument2.SetRecFilter();
        LAXEDIDocument2.SetRange("EDI Document No.", ImportUpdateOrderEDIDocLabel);
        if not LAXEDIDocument2.IsEmpty() then
            exit;
        if not ConfirmManagement.GetResponseOrDefault(Create851QstLbl, false) then
            exit;
        LAXEDIDocument2."EDI Document No." := ImportUpdateOrderEDIDocLabel;
        LAXEDIDocument2."Enable PO Change" := true;
        LaxEDIDocument2."PO Change Code When Blank" := '04';
        LAXEDIDocument2.Insert();
        Message(EDI851SuccessfulLbl);
    end;
    #endregion "SO Update"
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", 'OnBeforeEvaluateGeneralCrossRef', '', false, false)]
    local procedure SBCOnBeforeEvaluateGeneralCrossRef(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var EvaluateGenCrossRef: Boolean)
    var
        SellToCustomer: Record Customer;
    begin
        SBCCreateMissingCustomer(EDIRecDocHdr);
        SBCCreateMissingShipTo(EDIRecDocHdr);
        SBCProcessSMOGOrder(EDIRecDocHdr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Process ReceiveDoc Job", 'OnBeforeFindReceiveDocument', '', false, false)]
    local procedure SBCOnBeforeFindReceiveDocument(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    begin
        UpdateEDISalesOrder(EDIRecDocHdr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LAX EDI Receive Document Hdr.", 'OnBeforeProcessReceiveDoc', '', false, false)]
    local procedure SBCOnBeforeProcessReceiveDoc(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; Batch: Boolean; var IsHandled: Boolean)
    var
        LAXEDIReceiveDocumentHdr: Record "LAX EDI Receive Document Hdr.";
    begin
        if IsHandled then
            exit;
        LAXEDIReceiveDocumentHdr := EDIRecDocHdr;
        LaxEDIReceiveDocumentHdr.SetRecFilter();
        IsHandled := UpdateEDISalesOrder(LAXEDIReceiveDocumentHdr);
        if not IsHandled then
            exit;
        LaxEDIReceiveDocumentHdr.FindFirst();
        ProcessSOUpdate(Batch, LAXEDIReceiveDocumentHdr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", 'OnAfterSalesLineModify', '', false, false)]
    local procedure SBCOnAfterSalesLineModify(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        BracketPrices: Record "STA Bracket Price";
    begin
        if not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit;
        BracketPrices.SetFilter("Item No.", '%1', SalesLine."No.");
        BracketPrices.SetFilter("Country Code", '%1', SalesHeader."Sell-to Country/Region Code");
        BracketPrices.SetFilter(Active, '%1', true);
        if not BracketPrices.FindFirst() then
            exit;
        if SalesLine."Unit of Measure Code" = 'CS' then
            SalesLine."Unit Price" := BracketPrices."Bracket Case Price";
        if SalesLine."Unit of Measure Code" = 'EA' then
            SalesLine."Unit Price" := BracketPrices."Bracket Unit Price";
        SalesLine.Modify();
    end;
}