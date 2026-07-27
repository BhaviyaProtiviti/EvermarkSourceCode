report 50002 "SBC Commercial Invoice"
{
    DefaultLayout = RDLC;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './src/report/layout/SBCCommercialInvoice.rdlc';
    Caption = 'SBC Commercial Invoice';

    dataset
    {
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'SBC Commercial Invoice';
            column(DocumentDate; Format("Document Date", 0, 4))
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyEMail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyHomePage; CompanyInformation."Home Page")
            {
            }
            column(CompanyPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyVATRegNo; CompanyInformation.GetVATRegistrationNumber())
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress4; CompanyAddress[4])
            {
            }
            column(CompanyAddress5; CompanyAddress[5])
            {
            }
            column(CompanyAddress6; CompanyAddress[6])
            {
            }
            column(CompanyAddress7; CompanyAddress[7])
            {
            }
            column(CompanyAddress8; CompanyAddress[8])
            {
            }
            column(CustomerAddress1; CustomerAddress[1])
            {
            }
            column(CustomerAddress2; CustomerAddress[2])
            {
            }
            column(CustomerAddress3; CustomerAddress[3])
            {
            }
            column(CustomerAddress4; CustomerAddress[4])
            {
            }
            column(CustomerAddress5; CustomerAddress[5])
            {
            }
            column(CustomerAddress6; CustomerAddress[6])
            {
            }
            column(CustomerAddress7; CustomerAddress[7])
            {
            }
            column(CustomerAddress8; CustomerAddress[8])
            {
            }
            column(SellToContactPhoneNoLbl; SellToContactPhoneNoLbl)
            {
            }
            column(SellToContactMobilePhoneNoLbl; SellToContactMobilePhoneNoLbl)
            {
            }
            column(SellToContactEmailLbl; SellToContactEmailLbl)
            {
            }
            column(BillToContactPhoneNoLbl; BillToContactPhoneNoLbl)
            {
            }
            column(BillToContactMobilePhoneNoLbl; BillToContactMobilePhoneNoLbl)
            {
            }
            column(BillToContactEmailLbl; BillToContactEmailLbl)
            {
            }
            column(SellToContactPhoneNo; SellToContact."Phone No.")
            {
            }
            column(SellToContactMobilePhoneNo; SellToContact."Mobile Phone No.")
            {
            }
            column(SellToContactEmail; SellToContact."E-Mail")
            {
            }
            column(BillToContactPhoneNo; BillToContact."Phone No.")
            {
            }
            column(BillToContactMobilePhoneNo; BillToContact."Mobile Phone No.")
            {
            }
            column(BillToContactEmail; BillToContact."E-Mail")
            {
            }
            column(YourReference; "Your Reference")
            {
            }
            column(ExternalDocumentNo; "External Document No.")
            {
            }
            column(DocumentNo; "No.")
            {
            }
            column(CompanyLegalOffice; CompanyInformation.GetLegalOffice())
            {
            }
            column(SalesPersonName; SalespersonPurchaserName)
            {
            }
            column(ShipmentMethodDescription; ShipmentMethodDescription)
            {
            }
            column(Currency; CurrencyCode)
            {
            }
            column(CustomerVATRegNo; GetCustomerVATRegistrationNumber())
            {
            }
            column(CustomerVATRegistrationNoLbl; GetCustomerVATRegistrationNumberLbl())
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(DocumentTitleLbl; DocumentCaption())
            {
            }
            column(YourReferenceLbl; FieldCaption("Your Reference"))
            {
            }
            column(ExternalDocumentNoLbl; FieldCaption("External Document No."))
            {
            }
            column(CompanyLegalOfficeLbl; CompanyInformation.GetLegalOfficeLbl())
            {
            }
            column(SalesPersonLbl; SalesPersonLblText)
            {
            }
            column(EMailLbl; CompanyInformation.FieldCaption("E-Mail"))
            {
            }
            column(HomePageLbl; CompanyInformation.FieldCaption("Home Page"))
            {
            }
            column(CompanyPhoneNoLbl; CompanyInformation.FieldCaption("Phone No."))
            {
            }
            column(ShipmentMethodDescriptionLbl; DummyShipmentMethod.TableCaption())
            {
            }
            column(CurrencyLbl; DummyCurrency.TableCaption())
            {
            }
            column(ItemLbl; Item.TableCaption())
            {
            }
            column(TariffLbl; Item.FieldCaption("Tariff No."))
            {
            }
            column(UnitPriceLbl; Item.FieldCaption("Unit Price"))
            {
            }
            column(CountryOfManufactuctureLbl; CountryOfManufactuctureLbl)
            {
            }
            column(AmountLbl; Line.FieldCaption(Amount))
            {
            }
            column(VATPctLbl; Line.FieldCaption("VAT %"))
            {
            }
            column(VATAmountLbl; DummyVATAmountLine.VATAmountText())
            {
            }
            column(TotalWeightLbl; TotalWeightLbl)
            {
            }
            column(TotalAmountLbl; TotalAmountLbl)
            {
            }
            column(TotalAmountInclVATLbl; TotalAmountInclVATLbl)
            {
            }
            column(QuantityLbl; Line.FieldCaption(Quantity))
            {
            }
            column(NetWeightLbl; Line.FieldCaption("Net Weight"))
            {
            }
            column(DeclartionLbl; DeclartionLbl)
            {
            }
            column(SignatureLbl; SignatureLbl)
            {
            }
            column(SignatureNameLbl; SignatureNameLbl)
            {
            }
            column(SignaturePositionLbl; SignaturePositionLbl)
            {
            }
            column(VATRegNoLbl; CompanyInformation.GetVATRegistrationNumberLbl())
            {
            }
            column(SBCShipToAddress1; SBCShipToAddress[1]) { }
            column(SBCShipToAddress2; SBCShipToAddress[2]) { }
            column(SBCShipToAddress3; SBCShipToAddress[3]) { }
            column(SBCShipToAddress4; SBCShipToAddress[4]) { }
            column(SBCShipToAddress5; SBCShipToAddress[5]) { }
            column(SBCShipToAddress6; SBCShipToAddress[6]) { }
            column(SBCShipToAddress7; SBCShipToAddress[7]) { }
            column(SBCShipToAddress8; SBCShipToAddress[8]) { }
            column(ELBLocationAddress1; ELBLocationAddress[1]) { }
            column(ELBLocationAddress2; ELBLocationAddress[2]) { }
            column(ELBLocationAddress3; ELBLocationAddress[3]) { }
            column(ELBLocationAddress4; ELBLocationAddress[4]) { }
            column(ELBLocationAddress5; ELBLocationAddress[5]) { }
            column(ELBLocationAddress6; ELBLocationAddress[6]) { }
            column(ELBLocationAddress7; ELBLocationAddress[7]) { }
            column(ELBLocationAddress8; ELBLocationAddress[8]) { }
            column(ELBTIGIDelieveryNumber; Header."No.") { }
            column(ELBPoNo; Header."External Document No.") { }
            column(ELBPostingDate; Header."Posting Date") { }
            column(ELBCustomerNo; Header."Bill-to Customer No.") { }
            column(ELBFreightCarrier; Header."Shipping Agent Code") { }
            column(ELBFreightTerm; Header."Shipping Agent Service Code") { }
            column(ELBPaymentTerms; Header."Payment Terms Code") { }
            column(ShowWorkDescription; ShowWorkDescription) { }
            column(ELBTIGIDelieveryNumberLbl; ELBTIGIDelieveryNumberLbl) { }
            column(ELBPoNoLbl; ELBPoNoLbl) { }
            column(ELBInvoiceDateLbl; ELBInvoiceDateLbl) { }
            column(ELBCustomerNoLbl; ELBCustomerNoLbl) { }
            column(ELBWayBillLbl; ELBWayBillLbl) { }
            column(ELBFreightCarrierLbl; ELBFreightCarrierLbl) { }
            column(ELBTrailerNoLbl; ELBTrailerNoLbl) { }
            column(ELBFreightTermLbl; ELBFreightTermLbl) { }
            column(ELBPaymentTermsLbl; ELBPaymentTermsLbl) { }
            column(ELBCPCLbl; ELBCPCLbl) { }
            column(ELBTiGiIntGBEORILbl; ELBTiGiIntGBEORILbl) { }
            column(ELBEBVatNoLbl; ELBEBVatNoLbl) { }
            column(ELBCustomerEORILbl; ELBCustomerEORILbl) { }
            column(ELBCustomerVATNoLbl; ELBCustomerVATNoLbl) { }
            column(ELBItemCodeLbl; ELBItemCodeLbl) { }
            column(ELBQuantityLbl; ELBQuantityLbl) { }
            column(ELBDescriptionLbl; ELBDescriptionLbl) { }
            column(ELBHTSCodeLbl; ELBHTSCodeLbl) { }
            column(ELBOrderNoLbl; ELBOrderNoLbl) { }
            column(ELBCasesLbl; ELBCasesLbl) { }
            column(ELBOriginLbl; ELBOriginLbl) { }
            column(ELBUNLbl; ELBUNLbl) { }
            column(ELBNetWeightLbl; ELBNetWeightLbl) { }
            column(ELBGrossWeightLbl; ELBGrossWeightLbl) { }
            column(ELBPriceLbl; ELBPriceLbl) { }
            column(ELBExtendedValueLbl; ELBExtendedValueLbl) { }
            column(ELBTotalCasesLbl; ELBTotalCasesLbl) { }
            column(ELBTotalGrossWeightWPalletLbl; ELBTotalGrossWeightWPalletLbl) { }
            column(ELBTotalNetWeightLbl; ELBTotalNetWeightLbl) { }
            column(ELBTotalGrossWeightLbl; ELBTotalGrossWeightLbl) { }
            column(ELBTotalValueLbl; ELBTotalValueLbl) { }
            column(ELBShipFromLbl; ELBShipFromLbl) { }
            column(ELBBillToLbl; ELBBillToLbl) { }
            column(ELBIndirectRepresentativeLbl; ELBIndirectRepresentativeLbl) { }
            column(ELBShipToLbl; ELBShipToLbl) { }
            column(SBCCommercialInvoiceNote; SalesReceivablesSetup."SBC Commercial Invoice Note") { }
            dataitem(Line; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(ItemDescription; Description)
                {
                }
                // column(CountryOfManufacturing; Item."Country/Region of Origin Code")
                // {
                // }
                column(CountryOfManufacturing; SBCOrigin)
                {
                }
                column(Tariff; TariffCodeLast4Removed)
                {
                }
                column(Quantity; "Qty. to Invoice")
                {
                }
                column(Price; FormattedLinePrice)
                {
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 2;
                }
                column(NetWeight; "Net Weight")
                {
                }
                column(LineAmount; FormattedLineAmount)
                {
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                }
                column(VATPct; "VAT %")
                {
                }
                column(VATAmount; FormattedVATAmount)
                {
                }
                column(ELBItemCode; Line."No.") { }
                column(ELBUNNumber; ELBUNNumber) { }
                column(ELBNetWeight; ELBNetWeight) { }
                column(ELBGrossWeight; ELBGrossWeight) { }
                column(ELBOrderNumber; Line."Document No.") { }
                column(ELBCases; ELBCases) { }
                column(ELBLineAmount; Line."Line Amount") { }
                column(TariffCodeLast4Removed; TariffCodeLast4Removed) { }
                trigger OnAfterGetRecord()
                var
                    Location: Record Location;
                    AutoFormatType: Enum "Auto Format";
                    ELBItemAttribute: Record "Item Attribute";
                    ELBItemAttributeValueMapping: Record "Item Attribute Value Mapping";
                    ELBItemAttributeValue: Record "Item Attribute Value";
                    ELBItemUOM: Record "Item Unit of Measure";
                    PurchaseHeader: Record "Purchase Header";
                    LocalSalesLine: Record "Sales Line";

                begin
                    GetItemForRec("No.");
                    OnBeforeLineOnAfterGetRecord(Header, Line);

                    // Get first 7 characters from Tariff No.
                    if StrLen(Item."Tariff No.") >= 7 then
                        TariffCodeLast4Removed := CopyStr(Item."Tariff No.", 1, 7)
                    else
                        TariffCodeLast4Removed := Item."Tariff No.";

                    // Get UN Number from Item attribute
                    ELBItemAttribute.Reset();
                    ELBItemAttributeValue.Reset();
                    ELBItemAttributeValueMapping.Reset();
                    ELBItemAttribute.SetRange(Name, 'UN NUMBER');
                    if ELBItemAttribute.FindSet() then begin
                        ELBItemAttributeValueMapping.SetRange("Item Attribute ID", ELBItemAttribute.ID);
                        ELBItemAttributeValueMapping.SetRange("No.", Line."No.");
                        if ELBItemAttributeValueMapping.FindSet() then begin
                            ELBItemAttributeValue.SetRange("Attribute ID", ELBItemAttributeValueMapping."Item Attribute ID");
                            ELBItemAttributeValue.SetRange("ID", ELBItemAttributeValueMapping."Item Attribute Value ID");
                            if ELBItemAttributeValue.FindSet() then begin
                                ELBUNNumber := ELBItemAttributeValue."Value";
                            end;
                        end;
                    end;
                    // Get UN Number from Item attribute

                    ELBItemUOM.Reset();
                    if ELBItemUOM.Get(Line."No.", Line."Unit of Measure Code") then begin
                        ELBNetWeight := ELBItemUOM.Weight * Line.Quantity;
                        if Item."SBC Gross Weight Percentage" = 0 then begin
                            ELBGrossWeight := ELBNetWeight * 1.05;
                        end
                        else begin
                            ELBGrossWeight := ELBNetWeight * (1 + Item."SBC Gross Weight Percentage");
                        end;

                        ELBCases := ELBItemUOM."Qty. per Unit of Measure" * Line.Quantity;
                    end;

                    LocalSalesLine.SetRange("Document Type", Line."Document Type");
                    LocalSalesLine.SetRange("Document No.", Line."Document No.");
                    LocalSalesLine.SetRange("Line No.", Line."Line No.");
                    LocalSalesLine.SetRange("Drop Shipment", true);
                    if LocalSalesLine.FindFirst() then begin
                        if PurchaseHeader.Get(Enum::"Purchase Document Type"::Order, LocalSalesLine."Purchase Order No.") then
                            SBCOrigin := PurchaseHeader."Buy-from Country/Region Code";
                    end;

                    if IsShipment() then
                        if Location.RequireShipment("Location Code") and ("Quantity Shipped" = 0) then
                            "Qty. to Invoice" := Quantity;

                    if Quantity = 0 then begin
                        LinePrice := "Unit Price";
                        LineAmount := 0;
                        VATAmount := 0;
                    end else begin
                        LinePrice := Round(Amount / Quantity, Currency."Unit-Amount Rounding Precision");
                        LineAmount := Round(Amount * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");
                        if Currency.Code = '' then
                            VATAmount := "Amount Including VAT" - Amount
                        else
                            VATAmount := Round(
                                Amount * "VAT %" / 100 * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");

                        TotalAmount += LineAmount;
                        TotalWeight += Round("Qty. to Invoice" * "Net Weight");
                        TotalVATAmount += VATAmount;
                        TotalAmountInclVAT += Round("Amount Including VAT" * "Qty. to Invoice" / Quantity, Currency."Amount Rounding Precision");

                        ELBTotalCases += ELBCases;
                        ELBTotalNetWeight += ELBNetWeight;
                        ELBTotalGrossWeight += ELBGrossWeight;
                    end;

                    FormattedLinePrice := Format(LinePrice, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::UnitAmountFormat, CurrencyCode));
                    FormattedLineAmount := Format(LineAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    FormattedVATAmount := Format(VATAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                end;

                trigger OnPreDataItem()
                begin
                    TotalWeight := 0;
                    TotalAmount := 0;
                    TotalVATAmount := 0;
                    TotalAmountInclVAT := 0;
                    SetRange(Type, Type::Item);

                    ELBTotalCases := 0;
                    ELBTotalGrossWeightWPallet := 0;
                    ELBTotalNetWeight := 0;
                    ELBTotalGrossWeight := 0;

                    OnAfterLineOnPreDataItem(Header, Line);
                end;
            }
            dataitem(WorkDescriptionLines; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 .. 99999));
                column(WorkDescriptionLineNumber; Number) { }
                column(WorkDescriptionLine; WorkDescriptionLine) { }

                trigger OnAfterGetRecord()
                var
                    TypeHelper: Codeunit "Type Helper";
                begin
                    if WorkDescriptionInStream.EOS() then
                        CurrReport.Break();
                    WorkDescriptionLine := TypeHelper.ReadAsTextWithSeparator(WorkDescriptionInStream, TypeHelper.LFSeparator());
                end;

                trigger OnPostDataItem()
                begin
                    Clear(WorkDescriptionInStream)
                end;

                trigger OnPreDataItem()
                begin
                    if not ShowWorkDescription then
                        CurrReport.Break();
                    Header."Work Description".CreateInStream(WorkDescriptionInStream, TextEncoding::UTF8);
                end;
            }
            dataitem(Totals; "Integer")
            {
                MaxIteration = 1;
                column(TotalWeight; TotalWeight)
                {
                }
                column(TotalValue; FormattedTotalAmount)
                {
                }
                column(TotalVATAmount; FormattedTotalVATAmount)
                {
                }
                column(TotalAmountInclVAT; FormattedTotalAmountInclVAT)
                {
                }
                column(ELBTotalCases; ELBTotalCases) { }
                column(ELBTotalNetWeight; ELBTotalNetWeight) { }
                column(ELBTotalGrossWeight; ELBTotalGrossWeight) { }

                trigger OnPreDataItem()
                var
                    AutoFormatType: Enum "Auto Format";
                begin
                    FormattedTotalAmount := Format(TotalAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    FormattedTotalVATAmount := Format(TotalVATAmount, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                    FormattedTotalAmountInclVAT := Format(TotalAmountInclVAT, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, CurrencyCode));
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");
                FormatDocumentFields(Header);
                if SellToContact.Get("Sell-to Contact No.") then;
                if BillToContact.Get("Bill-to Contact No.") then;

                CalcFields("Work Description");
                ShowWorkDescription := "Work Description".HasValue();
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        SalesReceivablesSetup.Get();
    end;

    var
        DummyVATAmountLine: Record "VAT Amount Line";
        DummyShipmentMethod: Record "Shipment Method";
        DummyCurrency: Record Currency;
        AutoFormat: Codeunit "Auto Format";
        Language: Codeunit Language;
        CountryOfManufactuctureLbl: Label 'Country';
        TotalWeightLbl: Label 'Total Weight';
        SalespersonPurchaserName: Text;
        ShipmentMethodDescription: Text;
        ELBUNNumber, TariffCodeLast4Removed : Text;
        ELBCases, ELBNetWeight, ELBGrossWeight : Decimal;
        DocumentTitleLbl: Label 'Commercial Invoice';
        PageLbl: Label 'Page';
        DeclartionLbl: Label 'For customs purposes only.';
        SignatureLbl: Label 'For and on behalf of the above named company:';
        SignatureNameLbl: Label 'Name (in print) Signature';
        SignaturePositionLbl: Label 'Position in company';
        SellToContactPhoneNoLbl: Label 'Sell-to Contact Phone No.';
        SellToContactMobilePhoneNoLbl: Label 'Sell-to Contact Mobile Phone No.';
        SellToContactEmailLbl: Label 'Sell-to Contact E-Mail';
        BillToContactPhoneNoLbl: Label 'Bill-to Contact Phone No.';
        BillToContactMobilePhoneNoLbl: Label 'Bill-to Contact Mobile Phone No.';
        BillToContactEmailLbl: Label 'Bill-to Contact E-Mail';
        ELBTIGIDelieveryNumberLbl: Label 'DELIVERY #';
        ELBPoNoLbl: Label 'PO #';
        ELBInvoiceDateLbl: Label 'INVOICE DATE';
        ELBCustomerNoLbl: Label 'CUSTOMER #';
        ELBWayBillLbl: Label 'WAYBILL';
        ELBFreightCarrierLbl: Label 'FREIGHT CARRIER';
        ELBTrailerNoLbl: Label 'TRAILER NUMBER';
        ELBFreightTermLbl: Label 'FREIGHT/SHIPING TERMS';
        ELBPaymentTermsLbl: Label 'PAYMENT TERMS';
        ELBCPCLbl: Label 'CPC';
        ELBTiGiIntGBEORILbl: Label 'International GB EORI';
        ELBEBVatNoLbl: Label 'VAT NUMBER';
        ELBCustomerEORILbl: Label 'CUSTOMER EORI';
        ELBCustomerVATNoLbl: Label 'CUSTOMER VAT NUMBER';
        ELBItemCodeLbl: Label 'ITEM CODE';
        ELBQuantityLbl: Label 'QUNATITY';
        ELBDescriptionLbl: Label 'DESCRIPTION';
        ELBHTSCodeLbl: Label 'HTS CODE';
        ELBOrderNoLbl: Label 'ORDER NUMBER';
        ELBCasesLbl: Label 'EACH';
        ELBOriginLbl: Label 'ORIGIN';
        ELBUNLbl: Label 'UN NUMBER';
        ELBNetWeightLbl: Label 'NET WEIGHT (LB)';
        ELBGrossWeightLbl: Label 'GROSS WEIGHT (LB)';
        ELBPriceLbl: Label 'PRICE (USD)';
        ELBExtendedValueLbl: Label 'EXTENDED VALUE (USD)';
        ELBTotalCasesLbl: Label 'TOTAL:';
        ELBTotalGrossWeightWPalletLbl: Label 'TOTAL GROSS WIGHT (WITH PALLETS)';
        ELBTotalNetWeightLbl: Label 'TOTAL NET WEIGHT';
        ELBTotalGrossWeightLbl: Label 'TOTAL GROSS WEIGHT';
        ELBTotalValueLbl: Label 'TOTAL VALUE:';
        ELBShipFromLbl: Label 'Ship From:';
        ELBBillToLbl: Label 'Bill To:';
        ELBIndirectRepresentativeLbl: Label 'Indirect Representative:';
        ELBShipToLbl: Label 'Ship To:';

    protected var
        CompanyInformation: Record "Company Information";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        Currency: Record Currency;
        SellToContact: Record Contact;
        BillToContact: Record Contact;
        CompanyAddress: array[8] of Text[100];
        CustomerAddress: array[8] of Text[100];
        SBCShipToAddress: array[8] of Text[100];
        CustAddress: array[8] of Text[100];
        ELBLocationAddress: array[8] of Text[100];
        WorkDescriptionInStream: InStream;
        SalesPersonLblText: Text[50];
        TotalAmountLbl: Text[50];
        TotalAmountInclVATLbl: Text[50];
        FormattedLinePrice: Text;
        FormattedLineAmount: Text;
        FormattedVATAmount: Text;
        FormattedTotalAmount: Text;
        FormattedTotalVATAmount: Text;
        FormattedTotalAmountInclVAT: Text;
        WorkDescriptionLine: Text;
        CurrencyCode: Code[10];
        SBCOrigin: Code[10];
        TotalWeight: Decimal;
        TotalAmount: Decimal;
        TotalVATAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        ELBTotalCases, ELBTotalGrossWeightWPallet, ELBTotalNetWeight, ELBTotalGrossWeight : Decimal;
        LinePrice: Decimal;
        LineAmount: Decimal;
        VATAmount: Decimal;
        ShowWorkDescription: Boolean;

    local procedure FormatDocumentFields(SalesHeader: Record "Sales Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ShipmentMethod: Record "Shipment Method";
        ResponsibilityCenter: Record "Responsibility Center";
        Customer: Record Customer;
        FormatDocument: Codeunit "Format Document";
        FormatAddress: Codeunit "Format Address";
        TotalAmounExclVATLbl: Text[50];
        Location: Record Location;
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
    begin
        with SalesHeader do begin

            Customer.Get("Sell-to Customer No.");
            Location.Get(SalesHeader."Location Code"); // jyoon
            FormatDocument.SetSalesPerson(SalespersonPurchaser, "Salesperson Code", SalesPersonLblText);
            SalespersonPurchaserName := SalespersonPurchaser.Name;

            FormatDocument.SetShipmentMethod(ShipmentMethod, "Shipment Method Code", "Language Code");
            ShipmentMethodDescription := ShipmentMethod.Description;

            FormatAddress.GetCompanyAddr("Responsibility Center", ResponsibilityCenter, CompanyInformation, CompanyAddress);
            FormatAddress.Customer(CustomerAddress, Customer);
            FormatAddress.SalesHeaderShipTo(SBCShipToAddress, CustAddress, SalesHeader); // jyoon

            SalesLine.Setfilter("Document No.", SalesHeader."No.");
            SalesLine.Setfilter("Drop Shipment", '%1', true);
            if SalesLine.FindFirst() then begin
                if PurchaseHeader.Get(Enum::"Purchase Document Type"::Order, SalesLine."Purchase Order No.") then
                    FormatAddress.FormatAddr(ELBLocationAddress, PurchaseHeader."Buy-from Vendor Name", PurchaseHeader."Buy-from Vendor Name 2", PurchaseHeader."Buy-from Contact",
                    PurchaseHeader."Buy-from Address", PurchaseHeader."Buy-from Address 2", PurchaseHeader."Buy-from City", PurchaseHeader."Buy-from Post Code", PurchaseHeader."Buy-from County", PurchaseHeader."Buy-from Country/Region Code"); // jyoon
                SBCOrigin := PurchaseHeader."Buy-from Country/Region Code";
            end
            else begin
                FormatAddress.FormatAddr(ELBLocationAddress, Location.Name, Location."Name 2", Location.Contact, Location.Address, Location."Address 2", Location.City, Location."Post Code", Location.County, Location."Country/Region Code"); // jyoon
                SBCOrigin := Location."Country/Region Code";
            end;

            if "Currency Code" = '' then begin
                GeneralLedgerSetup.Get();
                GeneralLedgerSetup.TestField("LCY Code");
                CurrencyCode := GeneralLedgerSetup."LCY Code";
                Currency.InitRoundingPrecision();
            end else begin
                CurrencyCode := "Currency Code";
                Currency.Get("Currency Code");
            end;

            FormatDocument.SetTotalLabels("Currency Code", TotalAmountLbl, TotalAmountInclVATLbl, TotalAmounExclVATLbl);
        end;
    end;

    local procedure DocumentCaption(): Text
    var
        DocCaption: Text;
    begin
        OnBeforeGetDocumentCaption(Header, DocCaption);
        if DocCaption <> '' then
            exit(DocCaption);
        exit(DocumentTitleLbl);
    end;

    local procedure GetItemForRec(ItemNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetItemForRec(ItemNo, IsHandled);
        if IsHandled then
            exit;

        Item.Get(ItemNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLineOnPreDataItem(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDocumentCaption(SalesHeader: Record "Sales Header"; var DocCaption: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetItemForRec(ItemNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLineOnAfterGetRecord(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;
}

