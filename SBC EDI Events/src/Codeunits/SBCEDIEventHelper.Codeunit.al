/// <summary>
/// This codeunit is used as an observer for EDI-related events.
/// </summary>
codeunit 50080 "SBCEDI Event Helper"
{
    Permissions = tabledata "LAX EDI Cust. Cross Reference" = rimd;

    var

        GloblaConfirm: Boolean;
        DateTimeTypeLabel: Label 'DateTime';
        DateTypeLabel: Label 'Date';
        ECRCustomerDeleteQST: Label 'Would you like to delete the EDI Cross Reference records for Customer No. ''%1''?';
        ECRShiptoAddressDeleteQST: Label 'Would you like to delete the EDI Cross Reference records for Customer No. ''%1'' and Ship-to Address ''%2''?';
        SBCEmersonCustomerUpdateQstLabel: Label 'Would you like to update the SBC Emerson Customer No. on the Customer record from ''%1'' to ''%2''?';

    internal procedure CheckCustomerECR(var Customer: Record Customer) Created: Boolean
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        FourCharacterECR: Text[4];
    begin
        FourCharacterECR := CopyStr(Customer."SBC Emerson Customer No.", 1, 4);
        if FourCharacterECR = '' then
            exit;
        SetECRKeyFilterForCustomer(Customer."No.", LAXEDICustCrossReference);
        LAXEDICustCrossReference.SetRange("EDI Sell To Code", FourCharacterECR);
        if not LAXEDICustCrossReference.IsEmpty() then
            exit;

        LAXEDICustCrossReference.Init();
        LAXEDICustCrossReference."Trade Partner No." := GetSBCEDISettings()."Emerson Trade Partner";
        LAXEDICustCrossReference."Line No." := GetLastLineNo();
        LAXEDICustCrossReference."EDI Sell To Code" := FourCharacterECR;
        LAXEDICustCrossReference."Sell To Code" := Customer."No.";
        LAXEDICustCrossReference."EDI Ship To Code" := '';
        LAXEDICustCrossReference."Ship To Code" := '';
        LAXEDICustCrossReference."Ship-to Type" := Enum::"LAX EDI Ship-to Type"::Store;
        Created := LAXEDICustCrossReference.Insert(true);
    end;

    internal procedure CheckECR(CustomerNo: Code[20])
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        ShiptoAddress.SetFilter("Customer No.", '%1', CustomerNo);
        ShiptoAddress.SetFilter("SBC Emerson Ship-to Code", '<>%1', '');
        if ShiptoAddress.IsEmpty() then
            exit;
        repeat
            CheckECR(ShiptoAddress);
        until ShiptoAddress.Next() = 0;
    end;

    internal procedure CheckECR(ShiptoAddress: Record "Ship-to Address")
    begin
        if ShiptoAddress."SBC Emerson Ship-to Code" = '' then
            exit;
        CheckEmersonCustomerNo(ShiptoAddress);
        if UpdateEmersonEDICrossReference(ShiptoAddress) then
            exit;
        CreateNewECR(ShiptoAddress);
        // UpdateEmersonEDICrossReference(ShiptoAddress);
    end;

    internal procedure DeleteShipToECRs(Rec: Record "Ship-to Address")
    begin
        DeleteShipToECRs(Rec.Code, Rec."Customer No.");
    end;

    internal procedure DeleteShipToECRs(ShiptoAddressCode: Code[20]; CustomerNo: Code[20])
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if ShiptoAddressCode = '' then
            exit;
        if GloblaConfirm then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ECRShiptoAddressDeleteQST, CustomerNo, ShiptoAddressCode), true) then
                exit;
        SetECRKeyFiltersForShipTo(CustomerNo, ShiptoAddressCode, LAXEDICustCrossReference);
        if LAXEDICustCrossReference.IsEmpty() then
            exit;
        LAXEDICustCrossReference.FindSet(true);
        repeat
            ClearSellToCodesOnDelete(LAXEDICustCrossReference);
        until LAXEDICustCrossReference.Next() = 0;
    end;

    internal procedure GetSBCEDISettings() SBCEDIECRSettings: Record "SBCEDI ECR Settings"
    begin
        SBCEDIECRSettings.Get();
        SBCEDIECRSettings.TestField("Emerson Trade Partner");
    end;

    internal procedure SetGloblConfirm(Confirm: Boolean)
    begin
        GloblaConfirm := Confirm;
    end;

    local procedure CheckEmersonCustomerNo(ShipToAddress: Record "Ship-to Address")
    begin

        if EmersonCustomerAndShipToMatch(ShipToAddress) then
            exit;
        UpdateEmersonCustomerNoFromShipTo(ShipToAddress);
    end;

    local procedure ClearSellToCodesOnDelete(var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference")
    begin
        LAXEDICustCrossReference.Unassigned := true;
        LAXEDICustCrossReference.Validate("Sell To Code", '');
        LAXEDICustCrossReference.Modify(true);
    end;

    local procedure CreateEDIShipToCrossReference(var Rec: Record "Ship-to Address"; var TradePartnerNo: Code[20]; LineNo: Integer) Created: Boolean
    var
        NewLAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    begin
        NewLAXEDICustCrossReference.Init();
        NewLAXEDICustCrossReference."Trade Partner No." := TradePartnerNo;
        NewLAXEDICustCrossReference."Line No." := LineNo;
        NewLAXEDICustCrossReference."EDI Sell To Code" := GetEmersonCustomerNoFromShipTo(Rec);
        NewLAXEDICustCrossReference."Sell To Code" := Rec."Customer No.";
        NewLAXEDICustCrossReference."EDI Ship To Code" := Rec."SBC Emerson Ship-to Code";
        NewLAXEDICustCrossReference."Ship To Code" := Rec.Code;
        NewLAXEDICustCrossReference."Ship-to Type" := Enum::"LAX EDI Ship-to Type"::Store;
        Created := NewLAXEDICustCrossReference.Insert(true);
    end;

    local procedure CreateNewECR(var ShiptoAddress: Record "Ship-to Address") Created: Boolean
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        LineNo: Integer;
    begin
        LAXEDICustCrossReference.SetFilter("Trade Partner No.", '%1', GetSBCEDISettings()."Emerson Trade Partner");
        LAXEDICustCrossReference.SetFilter("Sell To Code", '%1', ShiptoAddress."Customer No.");
        LAXEDICustCrossReference.SetFilter("EDI Sell To Code", '%1', GetEmersonCustomerNoFromShipTo(ShiptoAddress));
        LAXEDICustCrossReference.SetFilter("Ship To Code", '%1', ShiptoAddress.Code);

        if not LAXEDICustCrossReference.IsEmpty() then
            exit;

        Created := CreateEDIShipToCrossReference(ShiptoAddress, GetSBCEDISettings()."Emerson Trade Partner", GetLastLineNo());
    end;

    local procedure DeleteECRsForCustomer(var Rec: Record Customer)
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if Rec."No." = '' then
            exit;
        if GloblaConfirm then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ECRCustomerDeleteQST, Rec."No."), true) then
                exit;
        SetECRKeyFilterForCustomer(Rec."No.", LAXEDICustCrossReference);
        if LAXEDICustCrossReference.IsEmpty() then
            exit;
        LAXEDICustCrossReference.FindSet(true);
        repeat
            ClearSellToCodesOnDelete(LAXEDICustCrossReference);
        until LAXEDICustCrossReference.Next() = 0;
    end;

    local procedure ECRFilterAndFind(ShiptoAddress: Record "Ship-to Address"; var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference") Found: Boolean
    begin
        Found := ECRFilterAndFind(ShiptoAddress."Customer No.", GetEmersonCustomerNoFromShipTo(ShiptoAddress), ShiptoAddress.Code, LAXEDICustCrossReference);
    end;

    local procedure ECRFilterAndFind(CustomerNo: Code[20]; EmersonCustomerNo: Code[20]; ShipToAddress: Code[20]; var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference") Found: Boolean
    begin
        SetECRKeyFiltersForShipTo(CustomerNo, ShipToAddress, LAXEDICustCrossReference);
        LAXEDICustCrossReference.SetFilter("EDI Sell To Code", '%1', EmersonCustomerNo);
        Found := not LAXEDICustCrossReference.IsEmpty();
    end;

    /// <summary>
    /// This function checks if the first four digits Emerson Customer No. on the Customer record matches the first four digits of the Emerson Ship-to Code on the Ship-to Address record.
    /// </summary>
    /// <param name="ShipToAddress"></param>
    /// <returns></returns>
    local procedure EmersonCustomerAndShipToMatch(ShipToAddress: Record "Ship-to Address"): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("No.", '%1', ShipToAddress."Customer No.");
        Customer.SetLoadFields("SBC Emerson Customer No.");
        Customer.FindFirst();
        exit(CopyStr(Customer."SBC Emerson Customer No.", 1, 4) = CopyStr(ShipToAddress."SBC Emerson Ship-to Code", 1, 4));
    end;

    local procedure FieldValueIsUpdated(xRecordVariant: Variant; RecordVariant: Variant; FieldNo: Integer): Boolean;
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FieldRef: FieldRef;
        xFieldRef: FieldRef;
    begin
        if not DataTypeManagement.GetRecordRefAndFieldRef(xRecordVariant, FieldNo, xRecRef, xFieldRef) then
            exit;
        if not DataTypeManagement.GetRecordRefAndFieldRef(RecordVariant, FieldNo, RecRef, FieldRef) then
            exit;

        exit(FieldRef.Value <> xFieldRef.Value);
    end;

    local procedure GetDefaultEmersonCustomerNo(ShipToAddress: Record "Ship-to Address"): Code[7]
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(ShipToAddress."SBC Emerson Ship-to Code", 1, 4) + '000');
    end;

    local procedure GetEmersonCustomerNoFromShipTo(ShipToAddress: Record "Ship-to Address"): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("No.", '%1', ShipToAddress."Customer No.");
        Customer.SetLoadFields("SBC Emerson Customer No.");
        Customer.FindFirst();
        exit(Customer."SBC Emerson Customer No.");
    end;

    local procedure GetLastLineNo() LineNo: Integer
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    begin
        LineNo := 10000;
        LAXEDICustCrossReference.SetFilter("Trade Partner No.", '%1', GetSBCEDISettings()."Emerson Trade Partner");
        if LAXEDICustCrossReference.FindLast() then
            LineNo := LAXEDICustCrossReference."Line No." + LineNo;
    end;

    local procedure LAXUpdateEDIShipToCode(var Rec: Record "Ship-to Address"; var xRec: Record "Ship-to Address")
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    begin
        if Rec."SBC Emerson Ship-to Code" = '' then
            exit;
        if not FieldValueIsUpdated(xRec, Rec, Rec.FieldNo(Rec."SBC Emerson Ship-to Code")) then
            exit;
        CheckECR(Rec);
    end;

    local procedure LAXUpdateSellToCodeOnRename(Rec: Record Customer; xRec: Record Customer)
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    begin
        LAXEDICustCrossReference.SetFilter("Sell To Code", '%1', xRec."No.");
        if LAXEDICustCrossReference.IsEmpty() then
            exit;

        LAXEDICustCrossReference.FindSet(true);
        repeat
            LAXEDICustCrossReference."Sell To Code" := Rec."No.";
            LAXEDICustCrossReference.Modify(true);
        until LAXEDICustCrossReference.Next() = 0;
    end;

    local procedure LAXUpdateShipToCodeOnRename(var Rec: Record "Ship-to Address"; var xRec: Record "Ship-to Address")
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
    begin
        SetECRKeyFiltersForShipTo(xRec."Customer No.", xRec.Code, LAXEDICustCrossReference);
        if LAXEDICustCrossReference.IsEmpty() then
            exit;

        LAXEDICustCrossReference.FindSet(true);
        repeat
            LAXEDICustCrossReference."Sell To Code" := Rec."Customer No.";
            LAXEDICustCrossReference."Ship To Code" := Rec.Code;
            LAXEDICustCrossReference.Modify(true);
        until LAXEDICustCrossReference.Next() = 0;
    end;

    local procedure SetECRKeyFilterForCustomer(var CustomerNo: Code[20]; var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference")
    begin
        LAXEDICustCrossReference.SetFilter("Trade Partner No.", '%1', GetSBCEDISettings()."Emerson Trade Partner");
        LAXEDICustCrossReference.SetFilter("Sell To Code", '%1', CustomerNo);
    end;

    local procedure SetECRKeyFiltersForShipTo(var CustomerNo: Code[20]; var ShipToAddress: Code[20]; var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference")
    begin
        SetECRKeyFilterForCustomer(CustomerNo, LAXEDICustCrossReference);
        LAXEDICustCrossReference.SetFilter("Ship To Code", '%1', ShipToAddress);
    end;

    local procedure UpdateECRFromCustomer(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec."SBC Emerson Customer No." = '' then
            exit;
        if not FieldValueIsUpdated(xRec, Rec, Rec.FieldNo(Rec."SBC Emerson Customer No.")) then
            exit;
        CheckCustomerECR(Rec);
        CheckECR(Rec."No.");
    end;

    local procedure UpdateEmersonCustomerNoFromShipTo(ShipToAddress: Record "Ship-to Address")
    var
        Customer: Record Customer;
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if GloblaConfirm then
            if not ConfirmManagement.GetResponse(StrSubstNo(SBCEmersonCustomerUpdateQstLabel, GetEmersonCustomerNoFromShipTo(ShipToAddress), GetDefaultEmersonCustomerNo(ShipToAddress)), true) then
                exit;

        Customer.Get(ShipToAddress."Customer No.");
        Customer.LockTable(true);
        Customer."SBC Emerson Customer No." := GetDefaultEmersonCustomerNo(ShipToAddress);
        Customer.Modify();
    end;

    local procedure UpdateEmersonEDICrossReference(ShiptoAddress: Record "Ship-to Address") Updated: Boolean
    var
        LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference";
        EmersonCustomerNo: Code[20];
        TradePartnerNo: Code[20];
        UniqueEDITradePartnerDictionary: Dictionary of [Code[20], Code[20]];
        LineNo: Integer;
    begin
        if ShiptoAddress."SBC Emerson Ship-to Code" = '' then
            exit;

        TradePartnerNo := GetSBCEDISettings()."Emerson Trade Partner";
        EmersonCustomerNo := GetEmersonCustomerNoFromShipTo(ShiptoAddress);
        if not FindECRForUpdate(ShiptoAddress, EmersonCustomerNo, TradePartnerNo, LAXEDICustCrossReference) then
            exit;

        LAXEDICustCrossReference.FindSet(true);
        repeat
            LAXEDICustCrossReference."Sell To Code" := ShiptoAddress."Customer No.";
            LAXEDICustCrossReference."Ship To Code" := ShiptoAddress.Code;
            LAXEDICustCrossReference."EDI Sell To Code" := EmersonCustomerNo;
            LAXEDICustCrossReference."EDI Ship To Code" := ShiptoAddress."SBC Emerson Ship-to Code";
            LAXEDICustCrossReference.Unassigned := false;
            LAXEDICustCrossReference.Modify(true);
        until LAXEDICustCrossReference.Next() = 0;
        Updated := true;
    end;


    local procedure DiscrepancyUnderThreshold(ERPAmount: Decimal; EDIAmount: Decimal; VarianceThreshold: Decimal) Result: Boolean
    begin
        Result := VarianceThreshold > abs(ERPAmount - EDIAmount);
    end;

    local procedure BypassSalesLineDiscrepancy(LastEDIUnitPrice: Decimal; SalesLine: Record "Sales Line"; EDIDocument: Record "LAX EDI Document") Result: Boolean
    var
        EDIPrice: Decimal;
        ERPPrice: Decimal;
    begin
        if EDIDocument."SBC Variance Threshold" = 0 then
            exit;
        EDIPrice := LastEDIUnitPrice;
        ERPPrice := SalesLine."Unit Price";

        if (EDIDocument."Price Discrepancy Calculation" = EDIDocument."Price Discrepancy Calculation"::"Include Discount") then
            ERPPrice := Round(SalesLine."Unit Price" - (SalesLine."Unit Price" * (SalesLine."Line Discount %" / 100)), 0.0001);

        if EDIPrice = ERPPrice then
            exit;

        if EDIDocument."SBC Threshold Type" = "SBC Threshold Type"::"Line Amount" then begin
            ERPPrice := Round(ERPPrice * SalesLine.Quantity, 0.01);
            EDIPrice := Round(EDIPrice * SalesLine.Quantity, 0.01);
        end;

        Result := DiscrepancyUnderThreshold(ERPPrice, EDIPrice, EDIDocument."SBC Variance Threshold");
    end;

    local procedure AcceptLowerEDIUnitPrice(var SalesLine: Record "Sales Line"; var EDIDocument: Record "LAX EDI Document"): Boolean
    var
        Item: Record Item;
    begin
        Item.SetRange("No.", SalesLine."No.");
        Item.SetFilter("Unit Price", '<>%1', 0);
        if Item.IsEmpty() then
            exit;
        if not SalesLine."LAX EDI Price Discrepancy" then
            exit;
        if not EDIDocument."SBC Accept Lower Unit Price" then
            exit;
        if SalesLine."Unit Price" < SalesLine."LAX EDI Unit Price" then
            exit;
        if SalesLine."Line Discount %" <> 0 then
            exit;
        exit(true);
    end;

    local procedure CheckDiscrepancyBypass(var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
    begin
        if not SalesLine."LAX EDI Price Discrepancy" then
            exit;
        Customer.SetRange("No.", SalesLine.GetSalesHeader()."Sell-to Customer No.");
        Customer.SetRange("SBC Ignore Price Discrepancy", true);
        if Customer.IsEmpty() then
            exit;
        SalesLine."LAX EDI Price Discrepancy" := false;
    end;

    local procedure FindBlankShipTo(EmersonShipToCode: Code[20]; var EmersonCustomerNo: Code[20]; var TradePartnerNo: Code[20]; var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference") Found: Boolean
    begin
        LAXEDICustCrossReference.Reset();
        LAXEDICustCrossReference.SetRange("Trade Partner No.", TradePartnerNo);
        LAXEDICustCrossReference.SetRange("EDI Sell To Code", EmersonCustomerNo);
        LAXEDICustCrossReference.SetRange("EDI Ship To Code", EmersonShipToCode);
        LAXEDICustCrossReference.FilterGroup(-1);
        LAXEDICustCrossReference.SetFilter("Sell To Code", '%1', '');
        LAXEDICustCrossReference.SetFilter("Ship To Code", '%1', '');
        Found := not LAXEDICustCrossReference.IsEmpty();
    end;

    local procedure FindECRForUpdate(ShiptoAddress: Record "Ship-to Address"; EmersonCustomerNo: Code[20]; TradePartnerNo: Code[20]; var LAXEDICustCrossReference: Record "LAX EDI Cust. Cross Reference") Found: Boolean
    begin
        Found := ECRFilterAndFind(ShiptoAddress, LAXEDICustCrossReference);
        if not Found then
            Found := FindBlankShipTo(ShiptoAddress."SBC Emerson Ship-to Code", EmersonCustomerNo, TradePartnerNo, LAXEDICustCrossReference);
    end;



    local procedure ValidateEDIDate(var EDIRecDocFields: Record "LAX EDI Receive Document Field"; DateFormatText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        BlankDate: Date;
        DateVariant: Variant;
    begin
        DateVariant := BlankDate;
        if TypeHelper.Evaluate(DateVariant, EDIRecDocFields."Field Text Value", DateFormatText, '') then
            exit;
        EDIRecDocFields."Field Text Value" := '';
        // EDIRecDocFields."Table No." := 0;
        // EDIRecDocFields."Field No." := 0;
        // EDIRecDocFields.Modify();
    end;

    local procedure ValidateEDIDateTime(var EDIRecDocFields: Record "LAX EDI Receive Document Field"; DateFormatText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        BlankDateTime: DateTime;
        DateVariant: Variant;
    begin
        DateVariant := BlankDateTime;
        if TypeHelper.Evaluate(DateVariant, EDIRecDocFields."Field Text Value", DateFormatText, '') then
            exit;
        EDIRecDocFields."Field Text Value" := '';
        // EDIRecDocFields."Table No." := 0;
        // EDIRecDocFields."Field No." := 0;
        // EDIRecDocFields.Modify();
    end;

    local procedure EvaluateDateFields(var EDIRecDocFields: Record "LAX EDI Receive Document Field"; DataType: Enum "LAX EDI Data Type")

    begin
        if not DateFieldTypeValidated(EDIRecDocFields) then
            exit;

        case DataType of
            EDIRecDocFields."Data Type"::"Date YYYYMMDD":
                ValidateEDIDate(EDIRecDocFields, 'yyyyMMdd');
            EDIRecDocFields."Data Type"::"Date YYMMDD":
                ValidateEDIDate(EDIRecDocFields, 'yyMMdd');
            EDIRecDocFields."Data Type"::"Date MMDDYY":
                ValidateEDIDate(EDIRecDocFields, 'MMddyy');
            EDIRecDocFields."Data Type"::"Date MMDDYYYY":
                ValidateEDIDate(EDIRecDocFields, 'MMddyyyy');
            EDIRecDocFields."Data Type"::"Date YYYYDDMM":
                ValidateEDIDate(EDIRecDocFields, 'yyyyddMM');
            EDIRecDocFields."Data Type"::"Date DDMMYYYY":
                ValidateEDIDate(EDIRecDocFields, 'ddMMyyyy');
            EDIRecDocFields."Data Type"::"Date DDMMYY":
                ValidateEDIDate(EDIRecDocFields, 'ddMMyy');
            EDIRecDocFields."Data Type"::"DateTime YYYYMMDDHHMM":
                ValidateEDIDateTime(EDIRecDocFields, 'yyyyMMddHHmm');
            EDIRecDocFields."Data Type"::"DateTime XML":
                ValidateEDIDateTime(EDIRecDocFields, 'yyyy-MM-ddTHH:mm:ss');
            EDIRecDocFields."Data Type"::"Date XML DateTime":
                ValidateEDIDateTime(EDIRecDocFields, 'yyyy-MM-dd');
            EDIRecDocFields."Data Type"::"Date UTC":
                ValidateEDIDate(EDIRecDocFields, 'yyyyMMdd');
        end;
    end;

    local procedure DateFieldTypeValidated(var EDIRecDocFields: Record "LAX EDI Receive Document Field") Valid: Boolean
    var
        Field: Record Field;
    begin
        Valid := true;
        if (EDIRecDocFields."Table No." = 0) or (EDIRecDocFields."Field No." = 0) then
            exit;
        Field.SetRange(TableNo, EDIRecDocFields."Table No.");
        Field.SetRange("No.", EDIRecDocFields."Field No.");
        Field.SetFilter("Type Name", '%1|%2', DateTypeLabel, DateTimeTypeLabel);
        Valid := not Field.IsEmpty();
    end;

    local procedure UpdateLineDiscountPercentFromEDI810(var SalesLine: Record "Sales Line")
    var
        UpdatedLineDiscountPercent: Decimal;
    begin
        if SalesLine."Unit Price" = 0 then
            exit;
        if SalesLine."LAX EDI Unit Price" = 0 then
            exit;
        UpdatedLineDiscountPercent := Round(100 * (1 - (SalesLine."LAX EDI Unit Price" / SalesLine."Unit Price")), GetCurrency(SalesLine.GetSalesHeader()."Currency Code")."Unit-Amount Rounding Precision");
        if SalesLine."Line Discount %" = UpdatedLineDiscountPercent then
            exit;
        SalesLine.Validate("Line Discount %", UpdatedLineDiscountPercent);
    end;

    // local procedure SBCCreateMissingShipTo(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.") Created: Boolean
    // var
    //     LAXEDIDocument: Record "LAX EDI Document";
    //     EDIRecDocFields: Record "LAX EDI Receive Document Field";
    //     SalesHeader: Record "Sales Header";
    //     SBCCustomerNoText: Text;
    //     SBCShipToCodeText: Text;
    //     SBCShipToNameText: Text;
    //     SBCShipToAddress1Text: Text;
    //     SBCShipToAddress2Text: Text;
    //     SBCShipToCityText: Text;
    //     SBCShipToStateText: Text;
    //     SBCShipToZipText: Text;
    //     SBCShipToCountryText: Text;
    //     Customer: Record Customer;
    //     ShiptoAddress: Record "Ship-to Address";
    //     EDICustCrossRef: Record "LAX EDI Cust. Cross Reference";
    // begin
    //     // LAXEDIDocument.Get(EDIRecDocHdr."Trade Partner No.", EDIRecDocHdr.Document, EDIRecDocHdr."EDI Document No.", EDIRecDocHdr."EDI Version", LAXEDIDocument.Type::Import);
    //     LAXEDIDocument.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
    //     LAXEDIDocument.SetRange("Document", EDIRecDocHdr.Document);
    //     LAXEDIDocument.SetRange("EDI Document No.", EDIRecDocHdr."EDI Document No.");
    //     LAXEDIDocument.SetRange("Version", EDIRecDocHdr."EDI Version");
    //     LAXEDIDocument.SetRange("Type", LAXEDIDocument.Type::Import);
    //     LAXEDIDocument.SetRange("SBC Create Missing Ship-To", true);
    //     if LAXEDIDocument.IsEmpty() then
    //         exit;

    //     //Get lookup values
    //     EDIRecDocFields.Reset;
    //     EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
    //     EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
    //     EDIRecDocFields.SetRange("Table No.", DATABASE::"Sales Header");
    //     // EDIRecDocFields.SetFilter("Segment Group", '>%1', 0);
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Sell-to Customer No."));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCCustomerNoText := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Code"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToCodeText := EDIRecDocFields."Field Text Value".Trim();
    //     if (SBCShipToCodeText = '') or (SBCCustomerNoText = '') then
    //         exit;
    //     // Check for existing cross reference
    //     EDICustCrossRef.SetCurrentKey("EDI Ship To Code");
    //     EDICustCrossRef.SetRange("Trade Partner No.", EDIRecDocHdr."Trade Partner No.");
    //     EDICustCrossRef.SetRange("EDI Sell To Code", CopyStr(SBCCustomerNoText, 1, 20));
    //     EDICustCrossRef.SetRange("EDI Ship To Code", CopyStr(SBCShipToCodeText, 1, 20));
    //     EDICustCrossRef.SetFilter("Sell To Code", '<>%1', '');
    //     EDICustCrossRef.SetFilter("Ship To Code", '<>%1', '');
    //     if not EDICustCrossRef.IsEmpty() then
    //         exit;
    //     // Check For Existing Customer and Ship-To
    //     Customer.SetRange("SBC Emerson Customer No.", SBCCustomerNoText);
    //     Customer.SetLoadFields("No.", "Location Code");
    //     if not Customer.FindFirst() then
    //         exit;
    //     ShiptoAddress.SetFilter("Customer No.", '%1', Customer."No.");
    //     ShiptoAddress.SetFilter("SBC Emerson Ship-to Code", '%1', SBCShipToCodeText);
    //     if ShiptoAddress.FindFirst() then begin
    //         CreateNewECR(ShiptoAddress);
    //         exit;
    //     end;
    //     // If the  ship-to does not exist, then collect values and create it and set the ECR.
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Code"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToCodeText := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Name"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToNameText := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Address"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToAddress1Text := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Address 2"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToAddress2Text := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to City"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToCityText := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to County"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToStateText := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Post Code"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToZipText := EDIRecDocFields."Field Text Value".Trim();
    //     EDIRecDocFields.SetRange("Field No.", SalesHeader.FieldNo("Ship-to Country/Region Code"));
    //     EDIRecDocFields.SetLoadFields("Field Text Value");
    //     if EDIRecDocFields.FindFirst() then
    //         SBCShipToCountryText := EDIRecDocFields."Field Text Value".Trim();


    //     // if the code reaches this point, then the ship-to address does not exist for the customer.
    //     ShiptoAddress.Init();
    //     ShiptoAddress."Customer No." := Customer."No.";
    //     ShiptoAddress."Location Code" := Customer."Location Code";
    //     ShiptoAddress.Code := SBCShipToCodeText;
    //     ShiptoAddress."SBC Auto-Created Ship-To" := true;
    //     ShiptoAddress."SBC Emerson Ship-to Code" := SBCShipToCodeText;
    //     ShiptoAddress.Name := SBCShipToNameText;
    //     ShiptoAddress.Address := SBCShipToAddress1Text;
    //     ShiptoAddress."Address 2" := SBCShipToAddress2Text;
    //     ShiptoAddress.City := SBCShipToCityText;
    //     ShiptoAddress.County := SBCShipToStateText;
    //     ShiptoAddress."Post Code" := SBCShipToZipText;
    //     ShiptoAddress."Country/Region Code" := SBCShipToCountryText;
    //     Created := ShiptoAddress.Insert();
    // end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterOnDeleteCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        DeleteECRsForCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterOnDeleteShipTo(var Rec: Record "Ship-to Address"; RunTrigger: Boolean)
    begin
        DeleteShipToECRs(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterOnInsertShipTo(var Rec: Record "Ship-to Address"; RunTrigger: Boolean)
    begin
        CheckECR(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterOnInsertCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        CheckCustomerECR(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterOnModifyCustomer(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    begin
        UpdateECRFromCustomer(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterOnModifyShipTo(var Rec: Record "Ship-to Address"; var xRec: Record "Ship-to Address"; RunTrigger: Boolean)
    begin
        LAXUpdateEDIShipToCode(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterRenameEvent, '', false, false)]
    local procedure OnAfterOnRenameCustomer(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    begin
        LAXUpdateSellToCodeOnRename(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", OnAfterRenameEvent, '', false, false)]
    local procedure OnAfterOnRenameShipTo(var Rec: Record "Ship-to Address"; var xRec: Record "Ship-to Address"; RunTrigger: Boolean)
    begin
        LAXUpdateShipToCodeOnRename(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnBeforeCheckPriceDiscrepancy, '', false, false)]
    local procedure OnBeforeCheckPriceDiscrepancyCreate(var LastEDIUnitPrice: Decimal; EDIRecDocField: Record "LAX EDI Receive Document Field"; var SalesLine: Record "Sales Line"; EDIDocument: Record "LAX EDI Document"; var IsHandled: Boolean)
    begin
        if CustomerAlwaysAcceptEDIPrice(SalesLine) then begin
            SalesLine.Validate("Unit Price", LastEDIUnitPrice);
            exit;
        end;
        IsHandled := BypassSalesLineDiscrepancy(LastEDIUnitPrice, SalesLine, EDIDocument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Sales Order", OnBeforeCheckPriceDiscrepancy, '', false, false)]
    local procedure OnBeforeCheckPriceDiscrepancyUpdate(var LastEDIUnitPrice: Decimal; EDIRecDocField: Record "LAX EDI Receive Document Field"; var SalesLine: Record "Sales Line"; EDIDocument: Record "LAX EDI Document"; var IsHandled: Boolean)

    begin
        IsHandled := BypassSalesLineDiscrepancy(LastEDIUnitPrice, SalesLine, EDIDocument);
        UpdateLineDiscountPercentFromEDI810(SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Line Discount %", false, false)]
    local procedure OnValidateLAXEDIUnitPrice(CurrFieldNo: Integer; var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    begin
        if (Rec."Line Discount %" = xRec."Line Discount %") and (Rec."SBC Previous Line Discount" <> 0) and (Rec."SBC Previous EDI Unit Price" <> 0) and (Rec."SBC Current EDI Unit Price" <> 0) then
            exit;

        Rec."SBC Previous Line Discount" := xRec."Line Discount %"; //This field value can be used in reporting to determine if there is a delta between the initial EDI Unit Price and the final EDI Unit Price.
        Rec."SBC Previous EDI Unit Price" := Round(Rec."Unit Price" * (1 - (xRec."Line Discount %" / 100)), 0.0001);
        Rec."SBC Current EDI Unit Price" := Round(Rec."Unit Price" * (1 - (Rec."Line Discount %" / 100)), 0.0001);
    end;

    /// <summary>
    /// Before the line discount percent is validate, this event is used to check the value of the discount percent against the SMOG rates table and set the smog logic for the sales order if a relevant record is found.
    /// </summary>
    /// <param name="CurrFieldNo"></param>
    /// <param name="Rec"></param>
    /// <param name="xRec"></param>

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Line Discount %", false, false)]

    local procedure OnAfterValidateLineDiscount(CurrFieldNo: Integer; var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SBCEDISMOGRates: Record "SBCEDI SMOG Rates";
        TempSBCEDISMOGRates: Record "SBCEDI SMOG Rates" temporary;
        SBCEDISalesEventHandler: Codeunit "SBCEDI Sales Event Handler";
        SmogRatesFound: Boolean;
    begin
        if Rec."Line Discount %" = 0 then
            exit;

        Customer.SetFilter("No.", '%1', Rec."Sell-to Customer No.");
        if Customer.IsEmpty() then
            exit;

        Customer.SetLoadFields("Gen. Bus. Posting Group", "Customer Posting Group");
        Customer.FindSet();

        // Return any record that matches the criteria.
        SBCEDISMOGRates.FilterGroup(-1);
        SBCEDISMOGRates.SetRange("Customer No.", Rec."Sell-to Customer No.");
        SBCEDISMOGRates.SetFilter("Start Date", '>=%1', Rec."Posting Date");
        SBCEDISMOGRates.SetFilter("End Date", '<=%1', Rec."Posting Date");
        SmogRatesFound := SBCEDISMOGRates.FindSet();
        if not SmogRatesFound then begin
            SBCEDISMOGRates.Reset();
            SBCEDISMOGRates.SetFilter("SMOG Rate",'<=%1', Rec."Line Discount %");
        end;

        if SBCEDISMOGRates.IsEmpty() then
            exit;

        // Build Smog Rates Buffer
        SBCEDISMOGRates.FindSet();
        repeat
            TempSBCEDISMOGRates.Init();
            TempSBCEDISMOGRates := SBCEDISMOGRates;
            TempSBCEDISMOGRates.Insert();
        until SBCEDISMOGRates.Next() = 0;
        
        TempSBCEDISMOGRates.SetCurrentKey("SMOG Rate","Start Date","End Date");

        // For all smog rates matching the initial criteria, check for one that matches the line discount percent.
        TempSBCEDISMOGRates.SetFilter("SMOG Rate",'<=%1', Rec."Line Discount %");
        if TempSBCEDISMOGRates.IsEmpty() then
            exit;

        // This is needed for the Posting Date Check
        SalesHeader := Rec.GetSalesHeader();

        // Ensures that at least one returned record is not before the start date.
        TempSBCEDISMOGRates.SetFilter("Start Date", '>=%1|%2', SalesHeader."Posting Date", 0D);
        if TempSBCEDISMOGRates.IsEmpty() then
            exit;

        // Ensures that at least one returned record is not beyond the end date.
        TempSBCEDISMOGRates.SetFilter("End Date", '<=%1|%2', SalesHeader."Posting Date", 0D);
        if TempSBCEDISMOGRates.IsEmpty() then
            exit;

        // Ensures that the returned smog rate is either a specific customer or blank
        TempSBCEDISMOGRates.SetFilter("Customer No.", '%1|%2', Rec."Sell-to Customer No.", '');
        if TempSBCEDISMOGRates.IsEmpty() then
            exit;

        // Should sort by the closest applicable rate and the most contemporary start date.
        TempSBCEDISMOGRates.FindFirst();
        if TempSBCEDISMOGRates."Gen. Bus. Posting Group" = '' then 
            TempSBCEDISMOGRates."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
        if TempSBCEDISMOGRates."Customer Posting Group" = '' then 
            TempSBCEDISMOGRates."Customer Posting Group" := Customer."Customer Posting Group";
        // Re-Set these values but do not write.
        Customer."Gen. Bus. Posting Group" := TempSBCEDISMOGRates."Gen. Bus. Posting Group";
        Customer."Customer Posting Group" := TempSBCEDISMOGRates."Customer Posting Group";
        // After a successful smog rate find, call the codeunit that sets the header values (with the swapped posting group values).
        SBCEDISalesEventHandler.SetSellToCustomer(Customer);
        SBCEDISalesEventHandler.SetSellToPostingGroups(SalesHeader);
        SalesHeader.Modify();
        // Set the line gen. business posting group to the customer gen. business posting group.
        Rec.Validate("Gen. Bus. Posting Group",  Customer."Gen. Bus. Posting Group");
        //Set other Item sales lines that are not the current line to the customer gen. business posting group.
        SalesLine.SetRange("Document No.", Rec."Document No.");
        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange(Type, Rec.Type);
        SalesLine.SetFilter("Gen. Bus. Posting Group", '<>%1',  Customer."Gen. Bus. Posting Group");
        if SalesLine.IsEmpty() then
            exit;
        SalesLine.ModifyAll("Gen. Bus. Posting Group", Customer."Gen. Bus. Posting Group");
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeModifyEvent, '', false, false)]
    // local procedure OnBeforeModify(RunTrigger: Boolean;var Rec: Record "Sales Line";var xRec: Record "Sales Line")
    // begin
    //     //   Rec."SBC Previous Line Discount" := xRec."Line Discount %"
    // end;
    internal procedure GetCurrency(CurrencyCode: Code[10]) Currency: Record Currency
    begin
        // if CurrencyCode = '' then
        //     Currency.InitRoundingPrecision()
        // else begin
        //     Currency.SetRange("Code", CurrencyCode);
        //     Currency.SetLoadFields("Unit-Amount Rounding Precision");
        //     if not Currency.FindFirst() then
        //         Currency.InitRoundingPrecision();
        // end;
        case true of
            CurrencyCode = '':
                Currency.InitRoundingPrecision();
            CurrencyCode <> '':
                begin
                    Currency.SetRange("Code", CurrencyCode);
                    Currency.SetLoadFields("Unit-Amount Rounding Precision");
                    if not Currency.FindFirst() then
                        Currency.InitRoundingPrecision();
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Integration", OnAfterSetPriceDiscrepancy, '', false, false)]
    local procedure OnAfterSetPriceDiscrepancy(var SalesLine: Record "Sales Line"; EDIDocument: Record "LAX EDI Document")
    var
        LAXEDIIntegration: Codeunit "LAX EDI Integration";
        SBCBillToCustomerEvents: Codeunit "SBC BillTo Customer Events";
    begin
        CheckDiscrepancyBypass(SalesLine);
        if not AcceptLowerEDIUnitPrice(SalesLine, EDIDocument) then
            exit;
        SalesLine.Validate("Unit Price", SalesLine."LAX EDI Unit Price");
        SBCBillToCustomerEvents.SetListPriceDiscount(SalesLine);
        SalesLine."LAX EDI Price Discrepancy" := false;
        SalesLine.Modify();
        if BypassSalesLineDiscrepancy(SalesLine."LAX EDI Unit Price", SalesLine, EDIDocument) then
            exit;
        LAXEDIIntegration.SetPriceDiscrepancy(SalesLine, EDIDocument);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeGetPurchaseOrder', '', false, false)]
    local procedure OnBeforeGetPurchaseOrder(var PurchaseHeader: Record "Purchase Header"; EDIRecDocFld: Record "LAX EDI Receive Document Field"; var PurchaseOrderFound: Boolean);
    var
        CheckPurchaseHeader: Record "Purchase Header";
        SBCEDI856InsertPOLines: Codeunit "SBCEDI 856 Purch Events";
    begin
        if EDIRecDocFld."EDI Document No." <> '856' then
            exit;
        EDIRecDocFld.SetRange("Internal Doc. No.", EDIRecDocFld."Internal Doc. No.");
        EDIRecDocFld.SetRange("Table No.", Database::"Purchase Header");
        EDIRecDocFld.SetRange("Field No.", PurchaseHeader.FieldNo(PurchaseHeader."No."));
        if not EDIRecDocFld.FindFirst() then
            exit;
        CheckPurchaseHeader.SetFilter("Document Type", '%1', PurchaseHeader."Document Type"::Order);
        CheckPurchaseHeader.SetFilter("No.", '%1', CopyStr(EDIRecDocFld."Field Text Value", 1, MaxStrLen(PurchaseHeader."No.")));
        CheckPurchaseHeader.SetRange("SBC Block Order", true);

        if CheckPurchaseHeader.IsEmpty() then
            exit;

        SBCEDI856InsertPOLines.Bind(true);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Update Purchase Order", 'OnBeforeRunMapPurchaseLine', '', false, false)]
    // local procedure SBCOnBeforeRunMapPurchaseLine(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var ExitProcess: Boolean)
    // var
    //     EDIRecDocFields: Record "LAX EDI Receive Document Field";
    //     DateFieldTypeText: Text;
    //     DateTimeTypeText: Text;
    //     DateValueText: Text;
    //     TypeHelper: Codeunit "Type Helper";
    // begin
    //     EDIRecDocFields.SetCurrentKey("Internal Doc. No.", "Table No.", "Field No.");
    //     EDIRecDocFields.SetRange("Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
    //     EDIRecDocFields.SetFilter("Table No.", '<>%1', 0);
    //     EDIRecDocFields.SetFilter("Field No.", '<>%1', 0);

    //     if EDIRecDocFields.IsEmpty() then
    //         exit;
    //     // EDIRecDocFields.SetLoadFields("Field No.", "Table No.", "Field Text Value", "Field Date Value", "Data Type");
    //     EDIRecDocFields.FindSet(true);


    //     repeat
    //         EvaluateDateFields(EDIRecDocFields, EDIRecDocFields."Data Type");
    //     until EDIRecDocFields.Next() = 0;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI WS Document Import", 'OnBeforeFormatFields', '', false, false)]
    local procedure OnBeforeFormatFields(var EDIRecDocField: Record "LAX EDI Receive Document Field"; EDIDocument: Record "LAX EDI Document"; EDIElement: Record "LAX EDI Element"; EDITemplate: Record "LAX EDI Template"; var IsHandled: Boolean)
    begin
        if not (EDIElement."Data Type" in [EDIElement."Data Type"::"Date YYYYMMDD", EDIElement."Data Type"::"Date YYMMDD", EDIElement."Data Type"::"Date MMDDYY", EDIElement."Data Type"::"Date MMDDYYYY", EDIElement."Data Type"::"Date YYYYDDMM", EDIElement."Data Type"::"Date DDMMYYYY", EDIElement."Data Type"::"Date DDMMYY", EDIElement."Data Type"::"DateTime YYYYMMDDHHMM", EDIElement."Data Type"::"DateTime XML", EDIElement."Data Type"::"Date XML DateTime", EDIElement."Data Type"::"Date UTC"]) then
            exit;
        if EDIElement."Table No." <> 0 then
            exit;
        if EDIElement."Field No." <> 0 then
            exit;
        if EDIRecDocField."Field Text Value" in ['', 'WORKDATE', 'TODAY'] then
            exit;
        EvaluateDateFields(EDIRecDocField, EDIElement."Data Type");
    end;

    /// <summary>
    /// Save first error message from processing EDI receive document
    /// </summary>
    [EventSubscriber(ObjectType::Page, Page::"LAX EDI Receive Document List", 'OnBeforeActionEvent', '&Process Receive Document', false, false)]
    local procedure LAXEDIRecieveDocumentOnBeforAction(var Rec: Record "LAX EDI Receive Document Hdr.")
    var
        SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
    begin

        // Skip if error is already logged
        if SBCEDIRecDocErrorLog.Get(Rec."Internal Doc. No.") then
            exit;

        if Rec."Data Error" = true then begin
            "SBC Save First Error Message"(Rec);
        end;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"LAX EDI Receive Document Hdr.", OnAfterProcessReceiveDoc, '', false, false)]
    // local procedure "LAX EDI Receive Document Hdr._OnAfterProcessReceiveDoc"(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.")
    // var
    //     SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
    // begin
    //     if SBCEDIRecDocErrorLog.Get(EDIRecDocHdr."Internal Doc. No.") then begin
    //         if EDIRecDocHdr."Data Error" = false then begin
    //             SBCEDIRecDocErrorLog."SBC Error Resolved At" := CurrentDateTime();
    //             SBCEDIRecDocErrorLog.Modify(true);
    //             Commit();
    //         end;
    //     end
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"LAX EDI Receive Document Hdr.", OnAfterProcessAllReceiveDoc, '', false, false)]
    // local procedure "LAX EDI Receive Document Hdr._OnAfterProcessAllReceiveDoc"(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; Errors: Integer)
    // var
    //     SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
    // begin
    //     if SBCEDIRecDocErrorLog.Get(EDIRecDocHdr."Internal Doc. No.") then begin
    //         if EDIRecDocHdr."Data Error" = false then begin
    //             SBCEDIRecDocErrorLog."SBC Error Resolved At" := CurrentDateTime();
    //             SBCEDIRecDocErrorLog.Modify(true);
    //             Commit();
    //         end;
    //     end
    // end;


    procedure "SBC Save First Error Message"(var LAXEDIRecDoc: Record "LAX EDI Receive Document Hdr.")
    var
        SBCEDIRecDocErrorLog: Record "SBC EDI Receive Doc Error Logs";
    begin
        SBCEDIRecDocErrorLog.Init();
        SBCEDIRecDocErrorLog."SBC Internal Doc. No." := LAXEDIRecDoc."Internal Doc. No.";
        SBCEDIRecDocErrorLog."SBC Trade Partner No." := LAXEDIRecDoc."Trade Partner No.";
        SBCEDIRecDocErrorLog."SBC EDI Document No." := LAXEDIRecDoc."EDI Document No.";
        SBCEDIRecDocErrorLog."SBC Error Message Text" := LAXEDIRecDoc."Error Message Text";
        SBCEDIRecDocErrorLog."SBC Error Occured At" := CurrentDateTime();

        SBCEDIRecDocErrorLog.Insert();
        Commit();
    end;

    /// <summary>
    /// Checks the customer record for the value of the SBC Always Accept EDI Price field to be set and return true if it is.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    /// <returns>Return variable AlwaysAccept of type Boolean.</returns>
    local procedure CustomerAlwaysAcceptEDIPrice(SalesLine: Record "Sales Line") AlwaysAccept: Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("No.", SalesLine."Sell-to Customer No.");
        Customer.SetRange("SBC Always Accept EDI Price", true);
        AlwaysAccept := not Customer.IsEmpty();
    end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", 'OnBeforeEvaluateGeneralCrossRef', '', false, false)]
    // local procedure SBCOnBeforeEvaluateGeneralCrossRef(EDIRecDocHdr: Record "LAX EDI Receive Document Hdr."; var EvaluateGenCrossRef: Boolean)
    // begin
    //     SBCCreateMissingShipTo(EDIRecDocHdr);
    // end;



}