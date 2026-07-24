xmlport 50600 "SBC AMC Bank Export CT"
{
    Caption = 'AMC Banking Export CreditTransfer';
    Namespaces = ns1 = 'xmlns = urn:iso:std:iso:20022:tech:xsd:pain.001.001.03';


    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = TableData "Data Exch." = r,
                  TableData "Payment Export Data" = r;
    UseDefaultNamespace = false;
    UseRequestPage = false;


    schema
    {
        textelement(Document) //paymentExportBank
        {
            NamespacePrefix = '';//'ns1';
            textelement(CstmrCdtTrfInitn) //paymentExportBank//1
            {
                NamespacePrefix = '';//'ns1';

                textelement(GrpHdr) //paymentExportBank//2
                {
                    NamespacePrefix = '';//'ns1';
                    textelement(MsgId)//3
                    {
                        MinOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            MsgId := GetMessageID(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Account Code")));
                        end;
                    }
                    textelement(CreDtTm)//4
                    {
                        MinOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            CreDtTm := Format(CreateDateTime(WorkDate(), Time()), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');//GetLanguage();
                        end;
                    }
                    ///
                    textelement(NbOfTxs)//5
                    {
                        MinOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            NbOfTxs := format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGNbOfTxs)));
                        end;
                    }
                    textelement(CtrlSum)//6
                    {
                        MinOccurs = Once;

                        trigger OnBeforePassVariable();
                        var
                            TempAmt: Decimal;
                        begin
                            Evaluate(TempAmt, GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                            CtrlSum := format(TempAmt, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                        end;
                    }
                    textelement(InitgPty)//7
                    {
                        MinOccurs = Once;
                        textelement(Nm)//8
                        {
                            MinOccurs = Once;

                            trigger OnBeforePassVariable();
                            begin
                                Nm := Format(CompanyInformation.Name);//GetLanguage();
                            end;
                        }
                        textelement(Id_1)//9
                        {
                            MinOccurs = Once;
                            XmlName = 'Id';
                            textelement(OrgId_1)//10
                            {
                                MaxOccurs = Once;
                                XmlName = 'OrgId';
                                textelement(BICOrBEI)//11
                                {

                                    trigger OnBeforePassVariable();
                                    begin
                                        if GetPaymentTerm() in [4, 5, 7, 8, 12] then
                                            CurrXMLPort.skip();
                                        // BICOrBEI := PaymentExportData."Sender Bank BIC";    //'BIC';// Format(COMPANYNAME);//GetLanguage();
                                        BICOrBEI := CompanyInformation."SWIFT Code";
                                        // currXMLport.Skip();
                                    end;
                                }
                                textelement(Othr_1)//12
                                {
                                    XmlName = 'Othr';
                                    textelement(Id_2)//13 //TODO figure out code.
                                    {
                                        XmlName = 'Id';

                                        trigger OnBeforePassVariable();
                                        begin
                                            Id_2 := 'COID';// Format(COMPANYNAME);//GetLanguage();//EB ID for JPM
                                        end;

                                    }
                                    textelement(SchmeNm)//14
                                    {

                                        textelement(Cd_2)//15
                                        {
                                            XmlName = 'Cd';

                                            trigger OnBeforePassVariable();
                                            begin
                                                if GetPaymentTerm() in [4, 5, 7, 8] then
                                                    CurrXMLPort.skip();
                                                Cd_2 := 'COID';// Format(COMPANYNAME);//GetLanguage();//Bank?
                                            end;

                                        }
                                        trigger OnBeforePassVariable();
                                        begin
                                            if GetPaymentTerm() in [4, 5, 7, 8] then
                                                CurrXMLPort.skip();
                                        end;
                                    }
                                    trigger OnBeforePassVariable()
                                    begin
                                        currXMLport.Skip();
                                    end;
                                }
                            }
                        }
                    }
                }
                //16..20 are constant
                tableelement("Payment Export Data"; "Payment Export Data")
                {
                    XmlName = 'PmtInf';//21
                    NamespacePrefix = '';

                    textelement(PmtInfId)//22
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            PmtInfId := format(GetValue(RecordRef, PaymentExportData.FieldNo("General Journal Batch Name")));//'BATCH REF1';//AMCBankingMgt.ApiVersion();
                        end;
                    }
                    textelement(PmtMtd)//23
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            if GetPaymentTerm() in [3] then
                                PmtMtd := 'CHK' //format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Payment Method Code")));//'CHK';//AMCBankingMgt.GetAMCClientCode();//Alwauys TRF?
                            else
                                PmtMtd := 'TRF';
                        end;
                    }
                    //24..25 are constant
                    textelement(BtchBookg)//26
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            BtchBookg := '';//format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Payment Method Code")));//'CHK';//AMCBankingMgt.GetAMCClientCode();
                            currXMLport.skip();//forced
                        end;
                    }

                    // textelement(NbOfTxs2)//27
                    // {
                    //     MaxOccurs = Once;
                    //     XmlName = 'NbOfTxs';

                    //     trigger OnBeforePassVariable();
                    //     begin
                    //         NbOfTxs2 := format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGNbOfTxs)));
                    //     end;
                    // }
                    // textelement(CtrlSum2)//28
                    // {
                    //     MaxOccurs = Once;
                    //     XmlName = 'CtrlSum';

                    //     trigger OnBeforePassVariable()
                    //     var
                    //         TempAmt: Decimal;
                    //     begin
                    //         Evaluate(TempAmt, GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                    //         CtrlSum2 := format(TempAmt, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                    //     end;
                    // }

                    textelement(PmtTpInf)//29
                    {
                        textelement(InstrPrty)//30//Is This Needed?
                        {
                            MaxOccurs = Once;
                            XmlName = 'InstrPrty';

                            trigger OnBeforePassVariable();
                            begin
                                // InstrPrty := 'NORM';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));                              
                                // if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                currXMLport.skip();
                            end;
                        }
                        textelement(SvcLvl)//33
                        {
                            textelement(Cd_5)//34
                            {
                                MaxOccurs = Once;
                                XmlName = 'Cd';

                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [1, 4, 12] then
                                        Cd_5 := 'NURG'//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                    else if GetPaymentTerm() in [2, 5, 6, 7, 8, 10] then
                                        Cd_5 := 'URGP';
                                    if GetPaymentTerm() in [9] then
                                        Cd_5 := 'SEPA';
                                    if GetPaymentTerm() in [11] then
                                        Cd_5 := 'URNS';
                                    if GetPaymentTerm() in [3] then
                                        currXMLport.skip();
                                end;
                            }
                        }

                        textelement(LclInstrm)//40
                        {
                            textelement(Cd_4)//41
                            {
                                MaxOccurs = Once;
                                XmlName = 'Cd';

                                trigger OnBeforePassVariable();
                                begin
                                    Cd_4 := 'CCD'; //PPD//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));// TODO - Needs to be ARC, BOC, CCD, CCP, CTX, IAT, PPD, PPP, TEL, WEB depending on payment method
                                    if GetPaymentTerm() in [2, 3, 4, 5, 6, 7, 8] then
                                        currXMLport.skip();

                                end;
                            }
                            textelement(Prtry_1)//46
                            {
                                MaxOccurs = Once;
                                XmlName = 'Prtry';

                                trigger OnBeforePassVariable();
                                begin
                                    Prtry_1 := '';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                    if GetPaymentTerm() in [1, 2] then
                                        currXMLport.skip();
                                    currXMLport.skip();//forced
                                end;
                            }
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [2, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.skip();
                            end;
                        }
                        textelement(CtgyPurp)//47
                        {
                            textelement(Cd_3)//48
                            {
                                MaxOccurs = Once;
                                XmlName = 'Cd';

                                trigger OnBeforePassVariable();
                                begin
                                    Cd_3 := 'SALA';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                end;
                            }
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.skip();
                            end;
                        }
                        trigger OnBeforePassVariable();
                        begin
                            if GetPaymentTerm() in [1, 2, 3, 6] then
                                currXMLport.skip();
                        end;
                    }
                    textelement(ReqdExctnDt)//71
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable();
                        begin
                            ReqdExctnDt := format(workDATE(), 0, '<Year4>-<Month,2>-<Day,2>');//AMCBankingMgt.GetAMCClientCode();
                        end;
                    }

                    textelement(Dbtr)//72
                    {
                        textelement(Nm2)//73
                        {
                            MaxOccurs = Once;
                            XmlName = 'Nm';

                            trigger OnBeforePassVariable();
                            begin
                                Nm2 := CompanyInformation.Name;//AMCBankingMgt.GetAMCClientCode();
                            end;
                        }
                        textelement(PstlAdr)//74 //TODO Required for checks if debtor address will be used as return address, check if needed for DAC (ACH?)-required for transactions with SEC code of IAT
                        {
                            textelement(PstCd_1)//77
                            {
                                MaxOccurs = Once;
                                XmlName = 'PstCd';

                                trigger OnBeforePassVariable();
                                begin
                                    PstCd_1 := CompanyInformation."Post Code";//AMCBankingMgt.GetAMCClientCode();
                                    // if GetPaymentTerm() in [2, 6] then
                                    //     currXMLport.skip();
                                end;
                            }
                            textelement(TwnNm_1)//78
                            {
                                MaxOccurs = Once;
                                XmlName = 'TwnNm';

                                trigger OnBeforePassVariable();
                                begin
                                    TwnNm_1 := CompanyInformation.City;//AMCBankingMgt.GetAMCClientCode();
                                    // if GetPaymentTerm() in [2, 6] then
                                    //     currXMLport.skip();
                                    if TwnNm_1 = '' then
                                        currXMLPort.skip();
                                end;
                            }
                            textelement(CtrySubDvsn_1)//79
                            {
                                MaxOccurs = Once;
                                XmlName = 'CtrySubDvsn';

                                trigger OnBeforePassVariable();
                                begin
                                    CtrySubDvsn_1 := CompanyInformation.County;//AMCBankingMgt.GetAMCClientCode();
                                    // if GetPaymentTerm() in [2, 6] then
                                    //     currXMLport.skip();
                                    if CtrySubDvsn_1 = '' then
                                        currXMLPort.skip();
                                end;
                            }
                            textelement(Ctry)//80
                            {
                                MaxOccurs = Once;

                                trigger OnBeforePassVariable();
                                begin
                                    Ctry := CompanyInformation."Country/Region Code";//AMCBankingMgt.GetAMCClientCode();
                                end;
                            }
                            textelement(StrtNm_1)//75
                            {
                                MaxOccurs = Once;
                                XmlName = 'StrtNm';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();

                                    StrtNm_1 := CompanyInformation.Address;//AMCBankingMgt.GetAMCClientCode();

                                    if GetPaymentTerm() in [2, 6] then
                                        currXMLport.skip();

                                end;
                            }
                            textelement(BldgNb_1)//76
                            {
                                MaxOccurs = Once;
                                XmlName = 'BldgNb';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();

                                    BldgNb_1 := CompanyInformation."Address 2";//AMCBankingMgt.GetAMCClientCode();
                                    if GetPaymentTerm() in [2, 6] then
                                        currXMLport.skip();
                                    if BldgNb_1 = '' then
                                        currXMLPort.skip();
                                end;
                            }
                            textelement(AdrLine)//81
                            {
                                MaxOccurs = Once;

                                trigger OnBeforePassVariable();
                                begin
                                    AdrLine := MakeAdrLine(CompanyInformation.Address, CompanyInformation."Address 2");

                                    if AdrLine = '' then
                                        currXMLport.Skip();
                                    // AdrLine := ;//AMCBankingMgt.GetAMCClientCode();
                                    // currXMLport.skip();//forced
                                end;
                            }
                            textelement(AdrLine2)
                            {
                                MaxOccurs = Once;
                                XmlName = 'AdrLine';

                                trigger OnBeforePassVariable()
                                begin
                                    if AddAdrLine then begin
                                        AdrLine2 := CompanyInformation."Address 2";
                                        AddAdrLine := false;
                                    end;

                                    if AdrLine2 = '' then
                                        currXMLport.Skip();
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                // if GetPaymentTerm() in [3] then
                                //     currXMLport.Skip();
                            end;
                        }
                        ////////.....
                        textelement(Id_3)//82
                        {
                            MaxOccurs = Once;
                            XmlName = 'Id';
                            textelement(OrgId_3)//83
                            {
                                MaxOccurs = Once;
                                XmlName = 'OrgId';
                                textelement(BICOrBEI3)//84
                                {
                                    XmlName = 'BICOrBEI';

                                    trigger OnBeforePassVariable();
                                    begin
                                        // BICOrBEI3 := 'BIC';// Format(COMPANYNAME);//GetLanguage();
                                        // if GetPaymentTerm() in [1, 4, 11, 12] then
                                        currXMLport.skip();
                                    end;
                                }
                                textelement(Othr_4)//85
                                {
                                    XmlName = 'Othr';
                                    textelement(Id_6)//86
                                    {
                                        XmlName = 'Id';

                                        trigger OnBeforePassVariable();//Should be Routing //TODO find out what ID goes here
                                        begin
                                            // if GetPaymentTerm() in [1] then
                                            //     currXMLport.skip();
                                            //ACH Company ID
                                            // Id_6 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Bank Branch No.")));// Format(COMPANYNAME);//GetLanguage();
                                            Id_6 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Sender ACH Co ID")));
                                        end;

                                    }
                                    textelement(SchmeNm2)//87
                                    {
                                        xmlname = 'SchmeNm';

                                        textelement(Cd_7)//88
                                        {
                                            XmlName = 'Cd';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Cd_7 := '';
                                                case GetPaymentTerm() of
                                                    1:
                                                        Cd_7 := 'CHID';// Format(COMPANYNAME);//GetLanguage();                                                
                                                    2:
                                                        Cd_7 := '';
                                                    3:
                                                        Cd_7 := '';
                                                end;
                                                if cd_7 = '' then
                                                    currXMLport.skip();//forced
                                                if GetPaymentTerm() in [1] then
                                                    currXMLport.skip();
                                            end;
                                        }
                                        textelement(Prtry6)//96
                                        {
                                            XmlName = 'Prtry';

                                            trigger OnBeforePassVariable();//Should be Routing
                                            begin
                                                //Should be Company ID
                                                Prtry6 := 'ACH' //listed options are ACH, VEN, WFCEO
                                            end;

                                        }
                                    }
                                }
                            }
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [2, 3, 5, 6, 7, 8, 9, 10] then
                                    currXMLport.skip();
                            end;
                        }
                        //////.....
                        textelement(CtctDtls) //TODO may be needed for MTS/IWI
                        {
                            textelement(Nm1)
                            {
                                XmlName = 'Nm';

                                trigger OnBeforePassVariable()
                                begin
                                    Nm1 := CompInf.Name;

                                    if Nm1 = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(PhneNb)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    PhneNb := CompInf."Phone No.";

                                    if PhneNb = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(EmailAdr)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    EmailAdr := CompInf."E-Mail";

                                    if EmailAdr = '' then
                                        currXMLport.Skip();
                                end;
                            }
                            trigger OnBeforePassVariable()
                            begin
                                if GetPaymentTerm() in [1, 3, 4, 5, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.Skip();

                                CompInf.Get();
                            end;
                        }
                    }
                    //////////////////////////////
                    // if GetPaymentTerm() in [3] then
                    //     currXMLport.skip();
                    textelement(DbtrAcct)//97
                    {

                        textelement(Id3)//98
                        {

                            XmlName = 'Id';
                            textelement(IBAN1)
                            {
                                MaxOccurs = Once;
                                XmlName = 'IBAN';

                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [9, 10, 11, 12] then
                                        IBAN1 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Sender IBAN")))
                                    else
                                        currXMLport.skip();
                                end;

                            }
                            textelement(Othr)//100
                            {
                                textelement(Id)//101
                                {
                                    MaxOccurs = Once;

                                    trigger OnBeforePassVariable();//This is the ABA
                                    begin
                                        Id := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Bank Account No.")));//AMCBankingMgt.GetAMCClientCode();
                                    end;
                                }
                                // textelement(SchmeNm3)//102
                                // {
                                //     xmlname = 'SchmeNm';

                                //     textelement(Cd_8)//103
                                //     {
                                //         XmlName = 'Cd';

                                //         trigger OnBeforePassVariable();
                                //         begin
                                //             Cd_8 := 'CUST';// Format(COMPANYNAME);//GetLanguage();
                                //         end;

                                //     }

                                // }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [9, 10, 11, 12] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(Tp_1)//107 //TODO find out if this is needed
                            {
                                XmlName = 'Tp';
                                textelement(Cd_10)//108
                                {
                                    XmlName = 'Cd';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Cd_10 := 'CACC';// Format(COMPANYNAME);//GetLanguage();
                                        // currXMLport.skip();//forced
                                    end;

                                }
                                textelement(Prtry_5)//125
                                {
                                    XmlName = 'Prtry';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Prtry_5 := '';// Format(COMPANYNAME);//GetLanguage();
                                        currXMLport.skip();//forced
                                    end;

                                }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [3, 4, 5, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.skip();
                                end;
                            }
                        }
                        textelement(Ccy4)//126
                        {
                            MaxOccurs = Once;
                            XmlName = 'Ccy';

                            trigger OnBeforePassVariable();
                            begin
                                // if GetPaymentTerm() in [4, 5, 7, 8] then
                                //     Ccy4 := 'CAD'
                                // else
                                //     Ccy4 := 'USD';//format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'US';//AMCBankingMgt.GetAMCClientCode();//This should be the recipient currency code
                                Ccy4 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Account Currency")));//'USD';//"Credit Transfer Entry"."Currency Code";
                                if GetPaymentTerm() in [3] then
                                    currXMLport.Skip();
                            end;
                        }
                    }

                    ///////////////////////////
                    textelement(DbtrAgt)//127 //TODO BIC vs mmbid?
                    {

                        textelement(FinInstnId)//128
                        {
                            textelement(BIC)//129
                            {
                                MaxOccurs = Once;

                                trigger OnBeforePassVariable();
                                begin
                                    // if GetPaymentTerm() in [4, 5, 7, 8] then
                                    //     BIC := 'CHASCATT' else
                                    //     BIC := 'CHASUS33';//AMCBankingMgt.GetAMCClientCode();
                                    // if GetPaymentTerm() in [9, 10, 11, 12] then
                                    BIC := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank BIC")));

                                    // if GetPaymentTerm() in [3] then
                                    currXMLport.skip();
                                end;
                            }
                            textelement(ClrSysMmbId)//130 //TODO FX Wire BIC or ClrSysId/MmbId?
                            {
                                textelement(ClrSysId)//131
                                {
                                    textelement(Cd_11)//132 //TODO this vs BIC, check to know what field to use for Cd
                                    {
                                        XmlName = 'Cd';

                                        trigger OnBeforePassVariable();
                                        begin
                                            Cd_11 := '';
                                            if GetPaymentTerm() in [1, 2, 3, 6] then
                                                Cd_11 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Sender ClrSysID Code"));

                                            if Cd_11 = '' then
                                                currXMLport.skip();//forced

                                        end;

                                    }
                                    textelement(Prtry_6)//158
                                    {
                                        XmlName = 'Prtry';

                                        trigger OnBeforePassVariable();
                                        begin
                                            Prtry_6 := '';// Format(COMPANYNAME);//GetLanguage();
                                            currXMLport.skip();//forced
                                        end;

                                    }
                                    trigger OnBeforePassVariable();
                                    begin
                                        if GetPaymentTerm() in [4, 5, 7, 8] then
                                            currXMLport.skip();
                                    end;
                                }
                                textelement(MmbId)//159
                                {
                                    MaxOccurs = Once;

                                    trigger OnBeforePassVariable();
                                    begin
                                        MmbId := format(GetValue(RecordRef, PaymentExportData.FieldNo("Transit No.")));//'021000021';//AMCBankingMgt.GetAMCClientCode(); //TODO may need to be bank branch no.
                                        // MmbId := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Clearing Code")));
                                    end;
                                }
                                // trigger OnBeforePassVariable();
                                // begin
                                //     if GetPaymentTerm() in [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                //         currXMLport.skip();
                                // end;
                            }
                            textelement(Nm_1)//160
                            {
                                MaxOccurs = Once;
                                XmlName = 'Nm';

                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.skip();
                                    Nm_1 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Name")));

                                end;
                            }

                            textelement(PstlAdr2)//161
                            {
                                XmlName = 'PstlAdr';
                                textelement(Ctry5)//162
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Ctry';

                                    trigger OnBeforePassVariable();
                                    begin
                                        if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                            currXMLport.Skip();
                                        //     Ctry5 := 'CA'
                                        // else
                                        //     Ctry5 := 'US';//AMCBankingMgt.GetAMCClientCode();
                                        Ctry5 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Country/Region")));
                                    end;
                                }
                                trigger OnBeforePassVariable()
                                begin
                                    if GetPaymentTerm() in [1, 2, 3, 6] then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(Othr_8)//163
                            {
                                XmlName = 'Othr';
                                textelement(Id_164)//164
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Id';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Id_164 := '';//AMCBankingMgt.GetAMCClientCode();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.skip();
                                end;
                            }

                        }
                        textelement(BrnchId)//165
                        {
                            textelement(Id_166)//166
                            {
                                MaxOccurs = Once;
                                XmlName = 'Id';

                                trigger OnBeforePassVariable();
                                begin
                                    Id_166 := '';//AMCBankingMgt.GetAMCClientCode();
                                    currXMLport.skip();//forced
                                end;
                            }
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.skip();
                            end;
                        }

                    }
                    textelement(UltmtDbtr)
                    {
                        textelement(Nm5)
                        {
                            XmlName = 'Nm';
                            trigger OnBeforePassVariable();
                            begin
                                Nm5 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Name")));
                            end;
                        }
                        textelement(PstlAdr_301)//300
                        {
                            XmlName = 'PstlAdr';
                            textelement(StrtNm_302)//301
                            {
                                MaxOccurs = Once;
                                XmlName = 'StrtNm';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();

                                    StrtNm_302 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Address")));
                                end;
                            }
                            textelement(BldgNb_303)//302
                            {
                                MaxOccurs = Once;
                                XmlName = 'BldgNb';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.skip();//forced
                                    BldgNb_303 := '';//AMCBankingMgt.GetAMCClientCode();
                                end;
                            }
                            textelement(PstCd_304)//303
                            {
                                MaxOccurs = Once;
                                XmlName = 'PstCd';

                                trigger OnBeforePassVariable();
                                begin
                                    PstCd_304 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Post Code")));
                                end;
                            }


                            textelement(TwnNm_305)//304
                            {
                                MaxOccurs = Once;
                                XmlName = 'TwnNm';

                                trigger OnBeforePassVariable();
                                begin
                                    TwnNm_305 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank City")));
                                end;
                            }
                            textelement(CtrySubDvsn_306)//305
                            {
                                MaxOccurs = Once;
                                XmlName = 'CtrySubDvsn';

                                trigger OnBeforePassVariable();
                                begin
                                    CtrySubDvsn_306 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank County")));
                                end;
                            }
                            textelement(Ctry_307)//306
                            {
                                MaxOccurs = Once;
                                XmlName = 'Ctry';

                                trigger OnBeforePassVariable();
                                begin
                                    Ctry_307 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Country/Region")));
                                end;
                            }
                            textelement(AdrLine3)
                            {
                                MaxOccurs = Once;
                                XmlName = 'AdrLine';

                                trigger OnBeforePassVariable()
                                begin
                                    AdrLine3 := '';
                                    AdrLine3 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Address")));
                                    if AdrLine3 = '' then
                                        currXMLport.Skip();
                                end;
                            }
                        }
                        trigger OnBeforePassVariable();
                        begin
                            if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] then
                                currXMLport.skip();
                        end;
                    }
                    textelement(ChrgBr)//191
                    {
                        trigger OnBeforePassVariable();
                        begin
                            ChrgBr := 'DEBT';// Format(COMPANYNAME);//GetLanguage();
                            if GetPaymentTerm() in [1, 2, 3, 4, 6, 9, 10, 11, 12] then
                                currXMLport.skip();
                        end;
                    }

                    textelement(CdtTrfTxInf)
                    {
                        XmlName = 'CdtTrfTxInf';//196

                        textelement(PmtId)//197
                        {
                            textelement(InstrId) //198
                            {

                                trigger OnBeforePassVariable();//'YOUR SYSTEM INSTRUCTION ID PMT1';//
                                begin
                                    InstrId := GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));
                                    currXMLport.Skip();
                                end;
                            }
                            textelement(EndToEndId)//199
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    EndToEndId := GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));//'YOUR PAYMENT REFERENCE NBR1';//GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                                end;
                            }
                            //<InstrId>YOUR SYSTEM INSTRUCTION ID PMT1</InstrId>
                            //<EndToEndId>YOUR PAYMENT REFERENCE NBR1</EndToEndId>
                            //</PmtId>
                        }
                        /////////--------------------
                        textelement(PmtTpInf_200)//200
                        {
                            XmlName = 'PmtTpInf';
                            textelement(InstrPrty_201)//201
                            {
                                MaxOccurs = Once;
                                XmlName = 'InstrPrty';

                                trigger OnBeforePassVariable();
                                begin
                                    currXMLport.Skip();
                                    // InstrPrty_201 := 'NORM';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                    // if GetPaymentTerm() in [3] then
                                    //     currXMLport.skip();
                                end;
                            }
                            textelement(SvcLvl_204)//204
                            {
                                XmlName = 'SvcLvl';
                                textelement(Cd_205)//205
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Cd';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Cd_205 := '';
                                        if GetPaymentTerm() in [1] then
                                            Cd_205 := 'NURG'//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                        else
                                            Cd_205 := 'URGP';
                                        if GetPaymentTerm() in [3] then
                                            currXMLport.skip();
                                    end;
                                }
                            }
                            textelement(LclInstrm_211)//211
                            {
                                xmlname = 'LclInstrm';
                                textelement(Cd_212)//212
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Cd';

                                    trigger OnBeforePassVariable(); //TODO SEC Code for ACH Payments (example uses CCD)
                                    begin
                                        Cd_212 := 'CCD';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                        if GetPaymentTerm() in [2, 3, 6] then
                                            currXMLport.skip();
                                    end;
                                }
                                textelement(Prtry_217)//217
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Prtry';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Prtry_217 := '';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                        if GetPaymentTerm() in [1, 2, 6] then
                                            currXMLport.skip();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                trigger OnBeforePassVariable()
                                begin
                                    if GetPaymentTerm() in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(CtgyPurp_218)//218
                            {
                                xmlname = 'CtgyPurp';
                                textelement(Cd_219)//219
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Cd';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Cd_219 := '';//format(GetValue(RecordRef, PaymentExportData.FieldNo(TIGCtrlSum)));
                                        if GetPaymentTerm() in [3] then
                                            currXMLport.skip();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                trigger OnBeforePassVariable();
                                begin
                                    // if GetPaymentTerm() in [3] then
                                    currXMLport.skip();
                                end;
                            }
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [3, 4, 5, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.skip();
                            end;
                        }
                        /////////////-----------------
                        textelement(Amt)//242
                        {
                            //<Amt>
                            textelement(InstdAmt)//243
                            {
                                textattribute(Ccy10)
                                {
                                    //MinOccurs = Zero;
                                    XmlName = 'Ccy';

                                    trigger OnBeforePassVariable();
                                    begin
                                        // if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                        //     Ccy := CVLedgerEntryBuffer."Currency Code"
                                        // else
                                        Ccy10 := GetValue(RecordRef, PaymentExportData.FieldNo("Currency Code"));
                                        // Ccy10 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Account Currency")));
                                        // Ccy10 := format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'USD';//"Credit Transfer Entry"."Currency Code";
                                    end;
                                }

                                trigger OnBeforePassVariable();
                                var
                                    TempAmt: Decimal;
                                begin
                                    Evaluate(TempAmt, GetValue(RecordRef, PaymentExportData.FieldNo("Amount")));
                                    InstdAmt := format(TempAmt, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                end;
                            }
                            //<InstdAmt Ccy="USD">1250.00</InstdAmt>
                            //</Amt>
                            textelement(EqvtAmt)//244
                            {
                                textelement(Amt_245)//245
                                {
                                    XmlName = 'Amt';
                                    textattribute(Ccy_245)
                                    {
                                        //MinOccurs = Zero;
                                        XmlName = 'Ccy';


                                        trigger OnBeforePassVariable();
                                        begin
                                            // if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                            //     Ccy := CVLedgerEntryBuffer."Currency Code"
                                            // else
                                            Ccy_245 := format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'USD';//"Credit Transfer Entry"."Currency Code";
                                        end;
                                    }

                                    trigger OnBeforePassVariable();
                                    begin
                                        Amt_245 := GetValue(RecordRef, PaymentExportData.FieldNo("Amount"));
                                    end;
                                }
                                textelement(CcyOfTrf)//246
                                {
                                    XmlName = 'CcyOfTrf';

                                    trigger OnBeforePassVariable();
                                    begin
                                        CcyOfTrf := '';//GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));
                                        currXMLport.skip();//forced

                                    end;
                                }

                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.skip();
                                end;

                            }
                        }
                        textelement(ChrgBr_247)//247
                        {
                            XmlName = 'ChrgBr';

                            trigger OnBeforePassVariable();
                            begin
                                ChrgBr_247 := '';//GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));
                                if GetPaymentTerm() in [3] then
                                    currXMLport.skip();
                                currXMLport.skip();//forced
                            end;
                        }
                        //check start//////
                        textelement(ChqInstr)//252
                        {
                            //<ChqInstr>
                            textelement(ChqTp)//253
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    ChqTp := 'CCHQ';//GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));
                                    if GetPaymentTerm() in [1, 2, 6] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(ChqNb)//258
                            {

                                trigger OnBeforePassVariable();
                                begin
                                    ChqNb := GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));
                                    if GetPaymentTerm() in [1, 2, 6] then
                                        currXMLport.skip();
                                end;
                            }
                            //<ChqNb>1000022</ChqNb>
                            textelement(ChqFr)//259 //TODO CHECK MAY BE NEEDED - USE IF ADDRESS IS RETURN ADDRESS
                            {
                                textelement(Nm_260)//260
                                {
                                    XmlName = 'Nm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Nm_260 := CompanyInformation.Name;//GetValue(RecordRef, PaymentExportData.FieldNo("Document No."));
                                        if GetPaymentTerm() in [1, 2, 6] then
                                            currXMLport.skip();
                                    end;
                                }
                                textelement(Adr)//261
                                {

                                    textelement(StrtNm_262)//262
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'StrtNm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                            StrtNm_262 := CompanyInformation.Address;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(BldgNb_263)//263
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'BldgNb';

                                        trigger OnBeforePassVariable();
                                        begin
                                            // if GetPaymentTerm() in [1, 2, 6] then
                                            //     currXMLport.skip();
                                            // if CompanyInformation."Address 2" = '' then
                                            //     currXMLport.skip();
                                            // BldgNb_263 := CompanyInformation."Address 2";//AMCBankingMgt.GetAMCClientCode();
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(PstCd_264)//264
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'PstCd';
                                        trigger OnBeforePassVariable();
                                        begin
                                            PstCd_264 := CompanyInformation."Post Code";//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }


                                    textelement(TwnNm_265)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'TwnNm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            TwnNm_265 := CompanyInformation.City;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(CtrySubDvsn_266)//266
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'CtrySubDvsn';

                                        trigger OnBeforePassVariable();
                                        begin
                                            CtrySubDvsn_266 := CompanyInformation.County;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }


                                    textelement(Ctry_267)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'Ctry';
                                        trigger OnBeforePassVariable();
                                        begin
                                            Ctry_267 := CompanyInformation."Country/Region Code";//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(AdrLine_268)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'AdrLine';

                                        trigger OnBeforePassVariable();
                                        begin
                                            AdrLine_268 := '';
                                            AdrLine_268 := MakeAdrLine(CompanyInformation.Address, CompanyInformation."Address 2");//AMCBankingMgt.GetAMCClientCode();
                                            if AdrLine_268 = '' then
                                                currXMLport.Skip();
                                            // if GetPaymentTerm() in [1, 2, 6] then
                                            //     currXMLport.skip();
                                            // currXMLport.skip();//forced
                                        end;
                                    }
                                    textelement(AdrLine4)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'AdrLine';

                                        trigger OnBeforePassVariable();
                                        begin
                                            AdrLine4 := '';
                                            if AddAdrLine then begin
                                                AdrLine4 := CompanyInformation."Address 2";//AMCBankingMgt.GetAMCClientCode();
                                                AddAdrLine := false;
                                            end;

                                            if AdrLine4 = '' then
                                                currXMLport.Skip();
                                            // if GetPaymentTerm() in [1, 2, 6] then
                                            //     currXMLport.skip();
                                            // currXMLport.skip();//forced
                                        end;
                                    }

                                }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [3] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(DlvryMtd)//269 //TODO needs to be set if different from default method
                            {
                                //<DlvryMtd>
                                textelement(Cd_270)//270
                                {
                                    XmlName = 'Cd';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Cd_270 := '';//GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                                        if GetPaymentTerm() in [1, 2, 6] then
                                            currXMLport.skip();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                textelement(Prtry)//283 //TODO find out if necessary and what the code is APPENDIX B? Only needed if different from default that was set up
                                {

                                    trigger OnBeforePassVariable();
                                    begin
                                        //TODO - Check default to 00000
                                        Prtry := '100';//GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                                        if GetPaymentTerm() in [1, 2, 6] then
                                            currXMLport.skip();
                                        //currXMLport.skip();//forced

                                    end;
                                }
                                //<Prtry>00HQ1</Prtry>
                                //</DlvryMtd>
                                // trigger OnBeforePassVariable();
                                // begin
                                //     if GetPaymentTerm() in [3] then
                                //         currXMLport.skip();
                                // end;
                            }
                            textelement(FrmsCd)//284 //TODO only necessary if different from default template, need to know code
                            {
                                trigger OnBeforePassVariable();
                                begin
                                    //This needs to be the acount template on the account. Chase is currently A2
                                    FrmsCd := 'A2';//format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Name")));
                                    if GetPaymentTerm() in [1, 2, 3, 6] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(DlvrTo)//284
                            {
                                textelement(Nm_285)//285
                                {
                                    XmlName = 'Nm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Nm_285 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Name")));
                                        if GetPaymentTerm() in [1, 2, 6] then
                                            currXMLport.skip();
                                    end;
                                }
                                textelement(Adr_286)//286
                                {
                                    XmlName = 'Adr';
                                    textelement(StrtNm_287)//287
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'StrtNm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.Skip();
                                            StrtNm_287 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address")));
                                            ;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(BldgNb_288)//288
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'BldgNb';

                                        trigger OnBeforePassVariable();
                                        begin
                                            // BldgNb_288 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2")));
                                            // ;//AMCBankingMgt.GetAMCClientCode();
                                            // if GetPaymentTerm() in [1, 2, 6] then
                                            //     currXMLport.skip();
                                            // if BldgNb_288 = '' then
                                            //     currXMLport.skip();
                                            currXMLport.Skip();
                                        end;
                                    }
                                    textelement(PstCd_289)//289
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'PstCd';
                                        trigger OnBeforePassVariable();
                                        begin
                                            PstCd_289 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Post Code")));
                                            ;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }


                                    textelement(TwnNm_290)//290
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'TwnNm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            TwnNm_290 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to City")));
                                            ;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(CtrySubDvsn_291)//291
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'CtrySubDvsn';

                                        trigger OnBeforePassVariable();
                                        begin
                                            CtrySubDvsn_291 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to County")));
                                            ;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }


                                    textelement(Ctry_292)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'Ctry';
                                        trigger OnBeforePassVariable();
                                        begin
                                            Ctry_292 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Country Code")));
                                            ;//AMCBankingMgt.GetAMCClientCode();
                                            if GetPaymentTerm() in [1, 2, 6] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(AdrLine_293)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'AdrLine';

                                        trigger OnBeforePassVariable();
                                        begin
                                            AdrLine_293 := '';
                                            AdrLine_293 := MakeAdrLine(format(GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address"))), format(GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2"))));
                                            if AdrLine_293 = '' then
                                                currXMLport.Skip();
                                            // AdrLine_293 := '';//AMCBankingMgt.GetAMCClientCode();
                                            // if GetPaymentTerm() in [1, 2, 6] then
                                            //     currXMLport.skip();
                                            // currXMLport.skip();//forced
                                        end;
                                    }
                                    textelement(AdrLine5)
                                    {
                                        MaxOccurs = Once;
                                        xmlname = 'AdrLine';

                                        trigger OnBeforePassVariable();
                                        begin
                                            AdrLine5 := '';
                                            if AddAdrLine then begin
                                                AdrLine5 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2")));
                                                AddAdrLine := false;
                                            end;

                                            if AdrLine5 = '' then
                                                currXMLport.Skip();
                                            // AdrLine_293 := '';//AMCBankingMgt.GetAMCClientCode();
                                            // if GetPaymentTerm() in [1, 2, 6] then
                                            //     currXMLport.skip();
                                            // currXMLport.skip();//forced
                                        end;
                                    }


                                }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [3] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(MemoFld)//295 //TODO find out if needed: Check memo field information. Print on check face.
                            {
                                XmlName = 'MemoFld';

                                trigger OnBeforePassVariable();
                                begin
                                    MemoFld := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Description")));
                                    //GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                                    if GetPaymentTerm() in [1, 2, 3, 6] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(RgnlClrZone)//296
                            {
                                XmlName = 'RgnlClrZone';

                                trigger OnBeforePassVariable();
                                begin
                                    RgnlClrZone := '';//GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                                    if GetPaymentTerm() in [1, 2, 6] then
                                        currXMLport.skip();
                                    currXMLport.skip();//forced
                                end;
                            }
                            textelement(PrtLctn)//297
                            {
                                XmlName = 'PrtLctn';

                                trigger OnBeforePassVariable();
                                begin
                                    PrtLctn := '';//GetValue(RecordRef, PaymentExportData.FieldNo("Message ID"));
                                    if GetPaymentTerm() in [1, 2, 6] then
                                        currXMLport.skip();
                                    currXMLport.skip();//forced

                                end;
                            }
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.skip();
                            end;
                        }
                        //check -- end

                        textelement(UltmtDbtr_298)//298
                        {
                            XmlName = 'UltmtDbtr';
                            ////////////////+++++++++++++++++++++
                            textelement(Nm_299)//299
                            {
                                MaxOccurs = Once;
                                XmlName = 'Nm';

                                trigger OnBeforePassVariable();
                                begin
                                    Nm_299 := CompanyInformation.Name;//AMCBankingMgt.GetAMCClientCode();
                                end;
                            }
                            textelement(PstlAdr_300)//300
                            {
                                XmlName = 'PstlAdr';
                                textelement(StrtNm_301)//301
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'StrtNm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        StrtNm_301 := '';//AMCBankingMgt.GetAMCClientCode();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                textelement(BldgNb_302)//302
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'BldgNb';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BldgNb_302 := '';//AMCBankingMgt.GetAMCClientCode();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                textelement(PstCd_303)//303
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'PstCd';

                                    trigger OnBeforePassVariable();
                                    begin
                                        PstCd_303 := '';//AMCBankingMgt.GetAMCClientCode();
                                        currXMLport.skip();//forced
                                    end;
                                }


                                textelement(TwnNm_304)//304
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'TwnNm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        TwnNm_304 := '';//AMCBankingMgt.GetAMCClientCode();
                                        currXMLport.skip();//forced
                                    end;
                                }
                                textelement(CtrySubDvsn_305)//305
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'CtrySubDvsn';

                                    trigger OnBeforePassVariable();
                                    begin
                                        CtrySubDvsn_305 := '';//AMCBankingMgt.GetAMCClientCode();
                                        currXMLport.skip();//forced
                                    end;
                                }



                                textelement(Ctry_306)//306
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Ctry';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Ctry := 'US';//AMCBankingMgt.GetAMCClientCode();
                                    end;
                                }
                                textelement(AdrLine_307)//307
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'AdrLine';

                                    trigger OnBeforePassVariable();
                                    begin
                                        AdrLine := 'US';//AMCBankingMgt.GetAMCClientCode();
                                    end;
                                }
                            }
                            ////////.....
                            textelement(Id_308)//308
                            {
                                MaxOccurs = Once;
                                XmlName = 'Id';
                                textelement(OrgId_309)//309
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'OrgId';
                                    textelement(BICOrBEI_310)//310
                                    {
                                        XmlName = 'BICOrBEI';

                                        trigger OnBeforePassVariable();
                                        begin
                                            BICOrBEI3 := 'BIC';// Format(COMPANYNAME);//GetLanguage();
                                        end;
                                    }
                                    textelement(Othr_311)//311
                                    {
                                        XmlName = 'Othr';
                                        textelement(Id_312)//312
                                        {
                                            XmlName = 'Id';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Id_312 := GetValue(RecordRef, PaymentExportData.FieldNo("Recipient ID"));// Format(COMPANYNAME);//GetLanguage();
                                            end;

                                        }
                                        textelement(SchmeNm_313)//313
                                        {
                                            xmlname = 'SchmeNm';

                                            textelement(Cd_314)//314
                                            {
                                                XmlName = 'Cd';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Cd_314 := 'SchmeNm-Cd';// Format(COMPANYNAME);//GetLanguage();//TODO - Make this a field on bank account card.
                                                end;

                                            }
                                            textelement(Prtry_321)//321
                                            {
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Prtry_321 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                        }
                                    }
                                    textelement(PrvtId)
                                    {
                                        textelement(Othr_323)//323
                                        {
                                            XmlName = 'Othr';
                                            textelement(Id_324)//324
                                            {
                                                XmlName = 'Id';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Id_324 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                            textelement(SchmeNm_325)//325
                                            {
                                                XmlName = 'SchmeNm';
                                                textelement(Cd_326)//326
                                                {
                                                    XmlName = 'Cd';

                                                    trigger OnBeforePassVariable();
                                                    begin
                                                        Cd_326 := '';// Format(COMPANYNAME);//GetLanguage();
                                                        currXMLport.skip();//forced
                                                    end;

                                                }

                                            }
                                        }

                                    }

                                }
                                textelement(CtryOfRes_335)//335
                                {
                                    XmlName = 'CtryOfRes';

                                    trigger OnBeforePassVariable();
                                    begin
                                        CtryOfRes_335 := '';// Format(COMPANYNAME);//GetLanguage();
                                        currXMLport.skip();//forced
                                    end;

                                }
                            }
                            textelement(IntrmyAgt1)//336
                            {
                                Textelement(FinInstnId_337)//337
                                {
                                    XmlName = 'FinInstnId';
                                    textelement(BIC_338)//338
                                    {
                                        XmlName = 'BIC';

                                        trigger OnBeforePassVariable();
                                        begin
                                            BIC_338 := '';// Format(COMPANYNAME);//GetLanguage();
                                            if GetPaymentTerm() in [3] then
                                                currXMLport.skip();
                                            currXMLport.skip();//forced
                                        end;

                                    }
                                    textelement(ClrSysMmbId_339)//339
                                    {
                                        XmlName = 'ClrSysMmbId';
                                        textelement(ClrSysId_340)//340
                                        {
                                            XmlName = 'ClrSysId';
                                            textelement(Cd_341)//341
                                            {
                                                XmlName = 'Cd';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Cd_341 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    if GetPaymentTerm() in [3] then
                                                        currXMLport.skip();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                            textelement(Prtry_342)//342
                                            {
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Prtry_342 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    if GetPaymentTerm() in [3] then
                                                        currXMLport.skip();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                        }
                                        textelement(MmbId_343)//343
                                        {
                                            XmlName = 'MmbId';

                                            trigger OnBeforePassVariable();
                                            begin
                                                MmbId_343 := '';// Format(COMPANYNAME);//GetLanguage();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;

                                        }
                                    }
                                    textelement(Nm_344)//344
                                    {
                                        XmlName = 'Nm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            Nm_344 := '';// Format(COMPANYNAME);//GetLanguage();
                                            if GetPaymentTerm() in [3] then
                                                currXMLport.skip();
                                            currXMLport.skip();//forced
                                        end;

                                    }
                                    textelement(PstlAdr_345)//345
                                    {
                                        xmlname = 'PstlAdr';
                                        textelement(PstCd_346)//346
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'PstCd';

                                            trigger OnBeforePassVariable();
                                            begin
                                                PstCd_346 := '';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;
                                        }


                                        textelement(TwnNm_347)//347
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'TwnNm';

                                            trigger OnBeforePassVariable();
                                            begin
                                                TwnNm_347 := '';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;
                                        }
                                        textelement(CtrySubDvsn_348)//348
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'CtrySubDvsn';

                                            trigger OnBeforePassVariable();
                                            begin
                                                CtrySubDvsn_348 := '';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;
                                        }



                                        textelement(Ctry_349)//80
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'Ctry';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Ctry_349 := 'US';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                            end;
                                        }
                                    }
                                    textelement(Othr_350)//350
                                    {
                                        XmlName = 'Othr';
                                        textelement(Id_351)//80
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'Id';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Id_351 := '';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;
                                        }
                                    }

                                }
                                trigger OnBeforePassVariable();
                                begin

                                    if GetPaymentTerm() in [3] then
                                        currXMLport.skip();
                                end;
                            }
                            ///////////22
                            textelement(IntrmyAgt2)//352
                            {
                                Textelement(FinInstnId_353)//353
                                {
                                    XmlName = 'FinInstnId';
                                    textelement(BIC_354)//354
                                    {
                                        XmlName = 'BIC';

                                        trigger OnBeforePassVariable();
                                        begin
                                            BIC_354 := '';// Format(COMPANYNAME);//GetLanguage();
                                            if GetPaymentTerm() in [2, 3, 6] then
                                                currXMLport.skip();
                                            currXMLport.skip();//forced
                                        end;

                                    }
                                    textelement(ClrSysMmbId_355)//355
                                    {
                                        XmlName = 'ClrSysMmbId';
                                        textelement(ClrSysId_356)//356
                                        {
                                            XmlName = 'ClrSysId';
                                            textelement(Cd_357)//357
                                            {
                                                XmlName = 'Cd';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Cd_357 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    if GetPaymentTerm() in [2, 3, 6] then
                                                        currXMLport.skip();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                            textelement(Prtry_358)//358
                                            {
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Prtry_358 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    if GetPaymentTerm() in [2, 3, 6] then
                                                        currXMLport.skip();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                        }
                                        textelement(MmbId_359)//359
                                        {
                                            XmlName = 'MmbId';

                                            trigger OnBeforePassVariable();
                                            begin
                                                MmbId_359 := '';// Format(COMPANYNAME);//GetLanguage();
                                                if GetPaymentTerm() in [2, 3, 6] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;

                                        }
                                    }
                                    textelement(Nm_360)//360
                                    {
                                        XmlName = 'Nm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            Nm_360 := '';// Format(COMPANYNAME);//GetLanguage();
                                            if GetPaymentTerm() in [2, 3, 6] then
                                                currXMLport.skip();
                                            currXMLport.skip();//forced
                                        end;

                                    }
                                    textelement(PstlAdr_361)//361
                                    {
                                        xmlname = 'PstlAdr';


                                        textelement(Ctry_362)//362
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'Ctry';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Ctry_362 := 'US';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [2, 3, 6] then
                                                    currXMLport.skip();
                                            end;
                                        }
                                    }
                                    textelement(Othr_363)//363
                                    {
                                        XmlName = 'Othr';
                                        textelement(Id_364)//364
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'Id';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Id_364 := '';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [2, 3, 6] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;
                                        }
                                    }

                                }
                                trigger OnBeforePassVariable();
                                begin

                                    if GetPaymentTerm() in [2, 3, 6] then
                                        currXMLport.skip();
                                end;

                            }
                            ////////////2
                            textelement(IntrmyAgt3)//365
                            {
                                Textelement(FinInstnId_366)//366
                                {
                                    XmlName = 'FinInstnId';
                                    textelement(BIC_367)//367
                                    {
                                        XmlName = 'BIC';

                                        trigger OnBeforePassVariable();
                                        begin
                                            BIC_367 := '';// Format(COMPANYNAME);//GetLanguage();
                                            if GetPaymentTerm() in [2, 3, 6] then
                                                currXMLport.skip();
                                            currXMLport.skip();//forced
                                        end;

                                    }
                                    textelement(ClrSysMmbId_368)//368
                                    {
                                        XmlName = 'ClrSysMmbId';
                                        textelement(ClrSysId_369)//369
                                        {
                                            XmlName = 'ClrSysId';
                                            textelement(Cd_370)//370
                                            {
                                                XmlName = 'Cd';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Cd_370 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    if GetPaymentTerm() in [2, 3, 6] then
                                                        currXMLport.skip();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                            textelement(Prtry_371)//371
                                            {
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Prtry_371 := '';// Format(COMPANYNAME);//GetLanguage();
                                                    if GetPaymentTerm() in [2, 3, 6] then
                                                        currXMLport.skip();
                                                    currXMLport.skip();//forced
                                                end;

                                            }
                                        }
                                        textelement(MmbId_372)//372
                                        {
                                            XmlName = 'MmbId';

                                            trigger OnBeforePassVariable();
                                            begin
                                                MmbId_372 := '';// Format(COMPANYNAME);//GetLanguage();
                                                if GetPaymentTerm() in [2, 3, 6] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;

                                        }
                                    }

                                    textelement(PstlAdr_373)//373
                                    {
                                        xmlname = 'PstlAdr';


                                        textelement(Ctry_374)//374
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'Ctry';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Ctry_374 := 'US';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [2, 3, 6] then
                                                    currXMLport.skip();
                                            end;
                                        }
                                    }
                                    textelement(Othr_375)//375
                                    {
                                        XmlName = 'Othr';
                                        textelement(Id_376)//376
                                        {
                                            MaxOccurs = Once;
                                            XmlName = 'Id';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Id_376 := '';//AMCBankingMgt.GetAMCClientCode();
                                                if GetPaymentTerm() in [2, 3, 6] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;
                                        }
                                    }

                                }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [2, 3, 6] then
                                        currXMLport.skip();
                                end;

                            }
                            ///++++++++++++++++
                            trigger OnBeforePassVariable();
                            begin
                                if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.skip();
                            end;
                        }
                        textelement(CdtrAgt)//377//ACH-WIRE-CHECK = R-R-B
                        {
                            textelement(FinInstnId_378)////ACH-WIRE-CHECK = R-R-B
                            {
                                XmlName = 'FinInstnId';
                                textelement(BIC_379)//379//ACH-WIRE-CHECK = O-O-B
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'BIC';
                                    trigger OnBeforePassVariable();
                                    begin
                                        // if GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Country/Region Code")) = 'CA' then
                                        //     BIC_379 := 'CHASCATT' else
                                        //     BIC_379 := 'CHASUS33';//AMCBankingMgt.GetAMCClientCode();
                                        // if GetPaymentTerm() in [5, 8] then
                                        //     BIC_379 := 'CITIGB2L';
                                        // if GetPaymentTerm() in [12] then begin
                                        //     if format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Transit No."))) <> '' then
                                        //         currXMLport.skip();
                                        // end;
                                        BIC_379 := '';
                                        if GetPaymentTerm() in [1, 3, 4] then
                                            currXMLport.skip();
                                        if GetPaymentTerm() in [2, 5, 6, 7, 8] then begin
                                            if GetPaymentTerm() in [2] then
                                                if not CrossBorder() then
                                                    currXMLport.Skip();
                                            BIC_379 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank BIC"));
                                        end;
                                        // if GetPaymentTerm() in [9] then
                                        BIC_379 := GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Bank BIC"));
                                        if GetPaymentTerm() in [10, 11] then
                                            currXMLport.skip();

                                        if BIC_379 = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(ClrSysMmbId_380)//380//ACH-WIRE-CHECK = O-O-B
                                {
                                    XmlName = 'ClrSysMmbId';
                                    textelement(ClrSysId_381)//381//ACH-WIRE-CHECK = O-O-B
                                    {
                                        XmlName = 'ClrSysId';
                                        textelement(Cd_382)//382//ACH-WIRE-CHECK = XOR-XOR-B //TODO check for DAC-ACH
                                        {
                                            XmlName = 'Cd';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Cd_382 := '';// Format(COMPANYNAME);//GetLanguage();
                                                // if GetPaymentTerm() in [3] then
                                                //     currXMLport.skip();
                                                if GetPaymentTerm() in [1, 2, 3, 6] then
                                                    Cd_382 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to ClrSysID Code"));

                                                // if Cd_382 = '' then
                                                //     currXMLport.Skip();
                                            end;
                                        }
                                        textelement(Prtry_383)//383//ACH-WIRE-CHECK = XOR-XOR-B
                                        {
                                            XmlName = 'Prtry';

                                            trigger OnBeforePassVariable();
                                            begin
                                                Prtry_383 := '';// Format(COMPANYNAME);//GetLanguage();
                                                if GetPaymentTerm() in [3] then
                                                    currXMLport.skip();
                                                currXMLport.skip();//forced
                                            end;

                                        }
                                        trigger OnBeforePassVariable();
                                        begin
                                            if GetPaymentTerm() in [5, 7, 8, 10, 11, 12] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(MmbId_384)//384//ACH-WIRE-CHECK = R-R-B
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'MmbId';

                                        trigger OnBeforePassVariable();
                                        begin
                                            MmbId_384 := '';
                                            MmbId_384 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Transit No.")));
                                            //'021000021';//AMCBankingMgt.GetAMCClientCode();//TODO - This needs to be the recipient ABA/Routing
                                            if GetPaymentTerm() in [3] then
                                                currXMLport.skip();
                                            if GetPaymentTerm() in [10, 11] then
                                                MmbId_384 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Bank Clearing Code")));
                                            if MmbId_384 = '' then
                                                currXMLport.skip();
                                        end;
                                    }
                                    trigger OnBeforePassVariable()
                                    begin
                                        if GetPaymentTerm() in [12] then
                                            if Format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Transit No."))) = '' then
                                                currXMLport.skip();
                                        //For AutoFx, skip this. Need to get Autofix payment term integer.
                                        if GetPaymentTerm() in [5, 9] then
                                            currXMLport.skip();
                                        if GetPaymentTerm() in [6] then
                                            if VendorBankAccount.IBAN <> '' then
                                                currXMLport.Skip();
                                        // if format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Transit No."))) = '' then
                                        if GetPaymentTerm() in [2] then
                                            if CrossBorder() then
                                                if VendorBankAccount.IBAN <> '' then
                                                    currXMLport.Skip();
                                    end;
                                }
                                textelement(Nm_385)//385//ACH-WIRE-CHECK = C-C-B
                                {
                                    MaxOccurs = Once;
                                    XmlName = 'Nm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        Nm_385 := '';//AMCBankingMgt.GetAMCClientCode();
                                                     //TODO This should be set on recipient bank account?
                                        Nm_385 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Name")));
                                        if GetPaymentTerm() in [3, 9, 11] then
                                            currXMLport.skip();

                                    end;
                                }

                                textelement(PstlAdr_386)//386//ACH-WIRE-CHECK = R-R-B //TODO DAC- Required for transactions with SEC Code of IAT
                                {
                                    XmlName = 'PstlAdr';

                                    textelement(PstCd1)
                                    {
                                        XmlName = 'PstCd';

                                        trigger OnBeforePassVariable()
                                        begin
                                            PstCd1 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Post Code")));
                                        end;
                                    }
                                    textelement(TwnNm1)
                                    {
                                        XmlName = 'TwnNm';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TwnNm1 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank City")));
                                        end;
                                    }
                                    textelement(StrtNm_387)//387//ACH-WIRE-CHECK = O-O-B
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'StrtNm';

                                        trigger OnBeforePassVariable();
                                        begin
                                            currXMLport.skip();
                                            StrtNm_387 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Address")));
                                            // if GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Country/Region Code")) = 'CA' then
                                            //     StrtNm_387 := 'CA'
                                            // else
                                            //     StrtNm_387 := 'US';
                                            if GetPaymentTerm() in [1, 3] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(CtrySubDvsn_388)//388//ACH-WIRE-CHECK = O-O-B
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'CtrySubDvsn';

                                        trigger OnBeforePassVariable();
                                        begin
                                            CtrySubDvsn_388 := format(GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Bank County")));
                                            if GetPaymentTerm() in [3] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(Ctry_389)//389//ACH-WIRE-CHECK = R-R-B
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'Ctry';

                                        trigger OnBeforePassVariable();
                                        begin
                                            Ctry_389 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Country")));
                                            // if GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Country/Region Code")) = 'CA' then
                                            //     Ctry_389 := 'CA'
                                            // else
                                            //     Ctry_389 := 'US';
                                            // if GetPaymentTerm() in [5, 8] then
                                            //     Ctry_389 := 'GB';
                                            if GetPaymentTerm() in [3] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    textelement(AdrLine_390)//390//ACH-WIRE-CHECK = O-O-B
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'AdrLine';

                                        trigger OnBeforePassVariable();
                                        begin
                                            AdrLine_390 := '';
                                            AdrLine_390 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Address")));
                                            if AdrLine_390 = '' then
                                                currXMLport.Skip();
                                            // if GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Country/Region Code")) = 'CA' then
                                            //     AdrLine_390 := 'CA'
                                            // else
                                            //     AdrLine_390 := 'US';
                                            // if GetPaymentTerm() in [3] then
                                            // currXMLport.skip();
                                        end;
                                    }
                                    trigger OnBeforePassVariable();
                                    begin
                                        if GetPaymentTerm() in [9] then
                                            currXMLport.skip();
                                    end;
                                }

                            }
                            trigger OnBeforePassVariable();
                            var
                                VendorBankCode: Code[20];
                                VendorNo: Code[20];
                            begin
                                if GetPaymentTerm() in [3] then
                                    currXMLport.skip();

                                if GetPaymentTerm() in [2, 6, 12] then begin
                                    VendorBankAccount.Reset();
                                    VendorBankCode := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Code")));
                                    VendorNo := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No.")));
                                    if VendorBankAccount.Get(VendorNo, VendorBankCode) then;
                                end
                            end;
                        }
                        textelement(Cdtr)//397//ACH-WIRE-CHECK = R-R-R
                        {
                            //<Cdtr>
                            textelement(Nm4)//398//ACH-WIRE-CHECK = R-R-R
                            {
                                XmlName = 'Nm';

                                trigger OnBeforePassVariable();
                                begin
                                    Nm4 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Name"));

                                end;
                            }
                            //<Nm>STUART CORPORATION</Nm>


                            textelement(PstlAdr6)//ACH-WIRE-CHECK = R-R-R //TODO Required if creditor address will be used as delivery address, DAC required if SEC code of IAT
                            {
                                xmlName = 'PstlAdr';
                                //<PstlAdr>
                                textelement(PstCd)//ACH-WIRE-CHECK = O-O-O
                                {
                                    trigger OnBeforePassVariable();
                                    begin
                                        PstCd := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Post Code"));
                                    end;
                                }
                                textelement(TwnNm)//ACH-WIRE-CHECK = O-O-O
                                {
                                    trigger OnBeforePassVariable();
                                    begin
                                        TwnNm := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to City"));
                                    end;
                                }
                                textelement(CtrySubDvsn)//ACH-WIRE-CHECK = C-C-C
                                {
                                    trigger OnBeforePassVariable();
                                    begin
                                        CtrySubDvsn := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to County"));
                                    end;
                                }
                                textelement(Ctry7)//ACH-WIRE-CHECK = R-R-R
                                {
                                    xmlName = 'Ctry';
                                    trigger OnBeforePassVariable();
                                    begin
                                        Ctry7 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Country Code"));

                                        // If GetPaymentTerm() in [4, 5, 7, 8] then
                                        //     Ctry7 := 'CA'
                                        // else
                                        //     Ctry7 := 'US';//GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Country Code"));
                                    end;
                                }
                                textelement(StrtNm)//ACH-WIRE-CHECK = O-O-O
                                {
                                    //XmlName = 'Nm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        currXMLport.Skip();
                                        StrtNm := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address"));

                                        // if GetPaymentTerm() in [3] then
                                        //     currXMLport.skip();

                                    end;
                                }
                                // <StrtNm>100 KING STREET</StrtNm>
                                textelement(BldgNb)//ACH-WIRE-CHECK = O-O-O
                                {
                                    //XmlName = 'Nm';

                                    trigger OnBeforePassVariable();
                                    begin
                                        BldgNb := '';
                                        currXMLport.skip();
                                        BldgNb := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2"));
                                        if BldgNb = '' then
                                            currXMLport.skip();
                                        // currXMLport.Skip();
                                    end;
                                }
                                // <PstCd>91801</PstCd>

                                // <TwnNm>LOS ANGELES</TwnNm>

                                // <CtrySubDvsn>CA</CtrySubDvsn>

                                // <Ctry>US</Ctry>
                                //</PstlAdr>
                                textelement(AdrLine_406)//406//ACH-WIRE-CHECK = O-O-O
                                {
                                    xmlName = 'AdrLine';
                                    trigger OnBeforePassVariable();
                                    begin
                                        AdrLine_406 := '';
                                        AdrLine_406 := MakeAdrLine(GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address")), GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2")));

                                        if AdrLine_406 = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(AdrLine7)//406//ACH-WIRE-CHECK = O-O-O
                                {
                                    xmlName = 'AdrLine';
                                    trigger OnBeforePassVariable();
                                    begin
                                        AdrLine7 := '';
                                        if AddAdrLine then begin
                                            AdrLine7 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2"));
                                            AddAdrLine := false;
                                        end;

                                        if AdrLine7 = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                            }

                            textelement(Id8)//ACH-WIRE-CHECK = O-O-O
                            {
                                xmlName = 'Id';
                                //<Id>
                                textelement(OrgId)//ACH-WIRE-CHECK = XOR-XOR-XOR
                                {
                                    //<OrgId>
                                    textelement(BICOrBEI_409)//ACH-WIRE-CHECK = O-O-O
                                    {
                                        xmlName = 'BICOrBEI';
                                        trigger OnBeforePassVariable();
                                        begin
                                            BICOrBEI_409 := 'BIC';//GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No.")); //'UP TO 20 CHAR VEND NO';//
                                            currXMLport.skip();
                                        end;
                                    }
                                    textelement(Othr8)//ACH-WIRE-CHECK = C-C-C
                                    {
                                        xmlName = 'Othr';

                                        //	<Othr>
                                        textelement(Id9)//ACH-WIRE-CHECK = R-R-R //TODO If used for Tax Identification, enter receiving party tax id
                                        {
                                            xmlName = 'Id';
                                            trigger OnBeforePassVariable();
                                            var
                                                Vendor: Record Vendor;
                                            begin
                                                UsesTxId := false;
                                                Id9 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No.")); //'UP TO 20 CHAR VEND NO';//

                                                if GetPaymentTerm() in [2, 6] then begin
                                                    Vendor.Reset();

                                                    if Vendor.Get(Id9) then
                                                        if Vendor."VAT Registration No." <> '' then begin
                                                            Id9 := Vendor."VAT Registration No.";
                                                            UsesTxId := true;
                                                        end
                                                        else if Vendor."Federal ID No." <> '' then begin
                                                            Id9 := Vendor."Federal ID No.";
                                                            UsesTxId := true;
                                                        end;
                                                end;
                                            end;
                                        }
                                        textelement(SchmeNm1) //TODO TXID? - IWI and MTS
                                        {
                                            XmlName = 'SchmeNm';
                                            textelement(Cd1)
                                            {
                                                XmlName = 'Cd';

                                                trigger OnBeforePassVariable()
                                                begin
                                                    if not UsesTxId then
                                                        currXMLport.Skip();

                                                    Cd1 := 'TXID';
                                                end;
                                            }
                                            textelement(Prtry2)
                                            {
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable()
                                                begin
                                                    if UsesTxId then
                                                        currXMLport.Skip();

                                                    Prtry2 := 'VN';
                                                end;
                                            }
                                        }
                                    }
                                    textelement(Othr9)//ACH-WIRE-CHECK = C-C-C
                                    {
                                        xmlName = 'Othr';

                                        //	<Othr>
                                        textelement(Id11)//ACH-WIRE-CHECK = R-R-R //TODO If used for Tax Identification, enter receiving party tax id
                                        {
                                            xmlName = 'Id';
                                            trigger OnBeforePassVariable();
                                            begin
                                                Id11 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No.")); //'UP TO 20 CHAR VEND NO';//
                                            end;
                                        }
                                        textelement(SchmeNm3) //TODO TXID? - IWI and MTS
                                        {
                                            XmlName = 'SchmeNm';
                                            textelement(Prtry3)
                                            {
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable()
                                                begin
                                                    Prtry3 := 'VN';
                                                end;
                                            }
                                        }
                                        trigger OnBeforePassVariable()
                                        begin
                                            if not UsesTxId then
                                                currXMLport.Skip();
                                        end;
                                    }
                                }
                                trigger OnBeforePassVariable()
                                begin
                                    if GetPaymentTerm() in [4, 5, 7, 8, 9, 10, 11, 12] then
                                        CurrXMLPort.skip();
                                end;
                            }
                            textelement(CtctDtls1)
                            {
                                XmlName = 'CtctDtls';
                                textelement(Nm3)
                                {
                                    XmlName = 'Nm';

                                    trigger OnBeforePassVariable()
                                    begin
                                        Nm3 := '';
                                        Nm3 := Vendor.Name;

                                        if Nm3 = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(PhneNb1)
                                {
                                    XmlName = 'PhneNb';

                                    trigger OnBeforePassVariable()
                                    begin
                                        PhneNb1 := '';
                                        PhneNb1 := Vendor."Phone No.";

                                        if PhneNb1 = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(MobNb)
                                {
                                    trigger OnBeforePassVariable()
                                    begin
                                        MobNb := '';
                                        MobNb := Vendor."Mobile Phone No.";

                                        if MobNb = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(EmailAdr1)
                                {
                                    XmlName = 'EmailAdr';

                                    trigger OnBeforePassVariable()
                                    begin
                                        EmailAdr1 := '';
                                        EmailAdr1 := Vendor."E-Mail";

                                        if EmailAdr1 = '' then
                                            currXMLport.Skip();
                                    end;
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    if GetPaymentTerm() in [1, 3, 4, 5, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.Skip();

                                    Vendor.Reset();
                                    if not Vendor.Get(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No."))) then
                                        currXMLport.Skip();
                                end;
                            }
                            //</Cdtr>
                        }
                        textelement(CdtrAcct)//ACH-WIRE-CHECK = R-R-N
                        {
                            MinOccurs = Zero;
                            textelement(Id_437)//ACH-WIRE-CHECK = R-R-N
                            {
                                xmlname = 'Id';
                                MinOccurs = Zero;
                                textelement(Othr_438)//ACH-WIRE-CHECK = O-R-N
                                {
                                    xmlname = 'Othr';
                                    MinOccurs = Zero;
                                    textelement(Id_440)////ACH-WIRE-CHECK = R-R-N
                                    {
                                        XmlName = 'Id';
                                        MinOccurs = Zero;

                                        trigger OnBeforePassVariable();
                                        begin
                                            // 'REMITTANCE - UP TO 140 CHARACTERS PER PAYMENT ALLOWED';//
                                            Id_440 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Acc. No.")));
                                            if GetPaymentTerm() in [3] then
                                                currXMLport.skip();
                                        end;
                                    }
                                    trigger OnBeforePassVariable();
                                    var
                                        VendorBankCode, VendorNo : Code[20];
                                    begin

                                        if GetPaymentTerm() in [5, 9] then
                                            currXMLport.skip();

                                        if GetPaymentTerm() in [1] then
                                            VendorNo := VendorNo;

                                        if GetPaymentTerm() in [2, 6, 12] then begin
                                            VendorBankAccount.Reset();
                                            VendorBankCode := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Code")));
                                            VendorNo := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No.")));
                                            if VendorBankAccount.Get(VendorNo, VendorBankCode) then
                                                if VendorBankAccount.IBAN <> '' then
                                                    currXMLport.Skip();
                                        end
                                    end;
                                }
                                textelement(IBAN)
                                {
                                    XmlName = 'IBAN';
                                    trigger OnBeforePassVariable()
                                    begin
                                        IBAN := '';

                                        if GetPaymentTerm() in [2, 6, 12] then
                                            if VendorBankAccount.IBAN = '' then
                                                currXMLport.Skip();

                                        if GetPaymentTerm() in [2, 5, 6, 9, 12] then
                                            IBAN := format(GetValue(RecordRef, PaymentExportData.FieldNo("Recipient Bank Acc. No.")));

                                        if GetPaymentTerm() in [2] then
                                            if not CrossBorder() then
                                                currXMLport.Skip();

                                        if IBAN = '' then
                                            currXMLport.skip();
                                    end;
                                }
                            }
                            textelement(Tp_446)//ACH-WIRE-CHECK = C-C-N
                            {
                                xmlname = 'Tp';
                                MinOccurs = Zero;
                                textelement(Cd_447)////ACH-WIRE-CHECK = XOR-XOR-N
                                {
                                    XmlName = 'Cd';
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        // 'REMITTANCE - UP TO 140 CHARACTERS PER PAYMENT ALLOWED';//
                                        Cd_447 := 'CACC';//Should be CACC or SVGS

                                    end;
                                }
                                textelement(Prtry_464)////ACH-WIRE-CHECK = XOR-XOR-N
                                {
                                    XmlName = 'Prtry';
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable();
                                    begin
                                        //'REMITTANCE - UP TO 140 CHARACTERS PER PAYMENT ALLOWED';//
                                        Prtry_464 := '';
                                        currXMLport.skip();//forced
                                    end;
                                }
                                trigger OnBeforePassVariable();
                                begin
                                    if GetPaymentTerm() in [1, 3, 4, 5, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.skip();
                                end;
                            }
                            textelement(Nm_465)////ACH-WIRE-CHECK = O-O-N
                            {
                                XmlName = 'Nm';
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable();
                                begin
                                    //'REMITTANCE - UP TO 140 CHARACTERS PER PAYMENT ALLOWED';//
                                    Nm_465 := format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Vendor No.")));
                                    if GetPaymentTerm() in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                        currXMLport.skip();
                                end;
                            }
                            trigger OnBeforePassVariable();
                            begin
                                //'REMITTANCE - UP TO 140 CHARACTERS PER PAYMENT ALLOWED';//

                                if GetPaymentTerm() in [3] then
                                    currXMLport.skip();

                            end;
                        }
                        textelement(InstrForDbtrAgt)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                InstrForDbtrAgt := '';

                                if GetPaymentTerm() in [1] then
                                    InstrForDbtrAgt := 'PMP|U|PMPADVICE|Y|EDDBL|10000SUVE';

                                if InstrForDbtrAgt = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(Purp)
                        {
                            textelement(Prtry1)
                            {
                                XmlName = 'Prtry';

                                trigger OnBeforePassVariable()
                                var
                                    PaymentPurposeCode: Code[20];
                                begin
                                    PaymentPurposeCode := GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Payment Purpose Code"));
                                    if PaymentPurposeCode <> '' then
                                        Prtry1 := PaymentPurposeCode
                                    else
                                        Prtry1 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Description"));
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if not (GetPaymentTerm() in [2, 6]) then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(RltdRmtInf)
                        {
                            textelement(RmtId)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                        RmtId := CVLedgerEntryBuffer."External Document No."
                                    else
                                        currXMLport.Skip();
                                end;
                            }
                            textelement(RmtLctnMtd)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    RmtLctnMtd := 'EMAL';
                                end;
                            }
                            textelement(RmtLctnElctrncAdr)
                            {
                                trigger OnBeforePassVariable()
                                var
                                    EmailAdr: Text;
                                begin
                                    EmailAdr := '';
                                    EmailAdr := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Email Address"));

                                    if EmailAdr = '' then
                                        currXMLport.Skip();

                                    RmtLctnElctrncAdr := StrSubstNo('EMAIL|%1|SECTY|ACCOUNT', EmailAdr);
                                end;
                            }
                            textelement(RmtLctnPstlAdr)
                            {
                                textelement(Nm6)
                                {
                                    XmlName = 'Nm';

                                    trigger OnBeforePassVariable()
                                    begin
                                        Nm6 := '';
                                        Nm6 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Name"));

                                        if Nm6 = '' then
                                            currXMLport.Skip();
                                    end;
                                }
                                textelement(Adr2)
                                {
                                    XmlName = 'Adr';

                                    textelement(PstCd2)
                                    {
                                        XmlName = 'PstCd';

                                        trigger OnBeforePassVariable()
                                        begin
                                            PstCd2 := '';
                                            PstCd2 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Post Code"));

                                            if PstCd2 = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(TwnNm2)
                                    {
                                        XmlName = 'TwnNm';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TwnNm2 := '';
                                            TwnNm2 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to City"));

                                            if TwnNm2 = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(CtrySubDvsn2)
                                    {
                                        XmlName = 'CtrySubDvsn';

                                        trigger OnBeforePassVariable()
                                        begin
                                            CtrySubDvsn2 := '';
                                            CtrySubDvsn2 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to County"));

                                            if CtrySubDvsn2 = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(Ctry2)
                                    {
                                        XmlName = 'Ctry';

                                        trigger OnBeforePassVariable()
                                        begin
                                            Ctry2 := '';
                                            Ctry2 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Country Code"));

                                            if Ctry2 = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(AdrLine6)//81
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'AdrLine';

                                        trigger OnBeforePassVariable();
                                        begin
                                            AdrLine6 := '';
                                            AdrLine6 := MakeAdrLine(GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address")), GetValueDontSkip(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2")));

                                            if AdrLine6 = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                    textelement(AdrLine8)
                                    {
                                        MaxOccurs = Once;
                                        XmlName = 'AdrLine';

                                        trigger OnBeforePassVariable()
                                        begin
                                            AdrLine8 := '';
                                            if AddAdrLine then begin
                                                AdrLine8 := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Address 2"));
                                                AddAdrLine := false;
                                            end;

                                            if AdrLine8 = '' then
                                                currXMLport.Skip();
                                        end;
                                    }
                                }
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if GetPaymentTerm() in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(RmtInf)//ACH-WIRE-CHECK = O-O-O
                        {
                            MinOccurs = once;
                            textelement(Ustrd)////ACH-WIRE-CHECK = O-O-O
                            {
                                XmlName = 'Ustrd';
                                MinOccurs = once;

                                trigger OnBeforePassVariable();
                                begin
                                    //'REMITTANCE - UP TO 140 CHARACTERS PER PAYMENT ALLOWED';//
                                    // currXMLport.Skip();
                                    if GetPaymentTerm() in [3] then
                                        Ustrd := StrSubstNo('CEPM|%1', format(GetValue(RecordRef, PaymentExportData.FieldNo("TIG Check Marketing Message"))))
                                    else if GetPaymentTerm() in [2, 6] then begin
                                        if GetValue(RecordRef, PaymentExportData.FieldNo("TIG Remit-to Bank Country")) in ['IN', 'India'] then
                                            Ustrd := StrSubstNo('OBI*As per agreement between remitter and beneficiary pertains to invoice number %1/%2/Customer-Vendor', CVLedgerEntryBuffer."External Document No.", CompanyInformation."Country/Region Code")
                                        else
                                            currXMLport.Skip();
                                    end
                                    else
                                        currXMLport.Skip();
                                end;
                            }
                            tableelement("Credit Transfer Entry"; "Credit Transfer Entry")
                            {
                                MinOccurs = Zero;
                                XmlName = 'Strd';//559//ACH-WIRE-CHECK = O-O-O


                                textelement(RfrdDocInf) //paymentExportBank//560//ACH-WIRE-CHECK = O-O-O
                                {
                                    NamespacePrefix = '';//'ns1';
                                    MinOccurs = Once;
                                    textelement(Tp) //paymentExportBank//561//ACH-WIRE-CHECK = O-O-O
                                    {

                                        NamespacePrefix = '';//'ns1';
                                        MinOccurs = Once;
                                        textelement(CdOrPrtry) //paymentExportBank//562//ACH-WIRE-CHECK = R-R-R
                                        {
                                            NamespacePrefix = '';//'ns1';
                                            MinOccurs = Once;

                                            textelement(Cd)//563//ACH-WIRE-CHECK = XOR-XOR-XOR
                                            {
                                                MinOccurs = Once;

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Cd := '';//'CINV';//GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Name - Data Conv."));
                                                    if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                        if CVLedgerEntryBuffer."Document Type" = CVLedgerEntryBuffer."Document Type"::Invoice then
                                                            Cd := 'CINV'
                                                        else if CVLedgerEntryBuffer."Document Type" = CVLedgerEntryBuffer."Document Type"::"Credit Memo" then
                                                            Cd := 'CREN';
                                                    IF CD = '' THEN
                                                        currXMLport.skip();//forced
                                                end;
                                            }
                                            textelement(Prtry_581)//581//ACH-WIRE-CHECK = XOR-XOR-XOR
                                            {
                                                MaxOccurs = Once;
                                                XmlName = 'Prtry';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    Prtry_581 := '';//'CINV';//GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Name - Data Conv."));                                                    
                                                    currXMLport.skip();//forced
                                                end;
                                            }
                                        }
                                    }
                                    textelement(Nb)//584//ACH-WIRE-CHECK = R-R-R
                                    {
                                        MinOccurs = Once;
                                        trigger OnBeforePassVariable();
                                        begin
                                            Nb := '';//Format('INV100001');//GetLanguage();
                                            if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                Nb := FORMAT(CVLedgerEntryBuffer."Document No.");
                                        end;
                                    }
                                    ///
                                    textelement(RltdDt)//585//ACH-WIRE-CHECK = O-O-O
                                    {
                                        MinOccurs = Once;

                                        trigger OnBeforePassVariable();
                                        begin
                                            RltdDt := '';//format(WorkDate());//GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Name - Data Conv."));
                                            if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                RltdDt := FORMAT(CVLedgerEntryBuffer."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>');
                                        end;
                                    }
                                }
                                textelement(RfrdDocAmt)//586///ACH-WIRE-CHECK = O-O-O
                                {
                                    textelement(DuePyblAmt)//587//ACH-WIRE-CHECK = O-O-O
                                    {
                                        textattribute(Ccy)
                                        {
                                            //MinOccurs = Zero;


                                            trigger OnBeforePassVariable();
                                            begin
                                                // if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                //     Ccy := CVLedgerEntryBuffer."Currency Code"
                                                // else
                                                Ccy := format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'USD';//"Credit Transfer Entry"."Currency Code";
                                            end;
                                        }

                                        trigger OnBeforePassVariable();
                                        begin
                                            clear(DuePyblAmt);
                                            if (CVLedgerEntryBuffer."Entry No." <> 0) then begin
                                                DuePyblAmt := FORMAT(abs(CVLedgerEntryBuffer."Remaining Amount"), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());

                                            end;
                                            //else
                                            //DuePyblAmt := FORMAT(abs("Credit Transfer Entry".Rem), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                        end;
                                    }
                                    textelement(DscntApldAmt)
                                    {
                                        MaxOccurs = Once;
                                        MinOccurs = Once;
                                        textattribute(Ccy2)
                                        {
                                            //MinOccurs = Zero;
                                            XmlName = 'Ccy';


                                            trigger OnBeforePassVariable();
                                            begin
                                                // if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                //     Ccy2 := CVLedgerEntryBuffer."Currency Code"
                                                // else
                                                Ccy2 := format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'USD';//Ccy2 := "Credit Transfer Entry"."Currency Code";
                                            end;
                                        }

                                        trigger OnBeforePassVariable();
                                        begin
                                            DscntApldAmt := '';
                                            DscntApldAmt := FORMAT(abs("Credit Transfer Entry"."Pmt. Disc. Possible"), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                            if "Credit Transfer Entry"."Pmt. Disc. Possible" = 0 then
                                                DscntApldAmt := '0.00';

                                        end;
                                    }
                                    textelement(CdtNoteAmt)//589//ACH-WIRE-CHECK = O-O-O
                                    {
                                        MinOccurs = Zero;
                                        textattribute(Ccy_589)
                                        {
                                            //MinOccurs = Zero;
                                            XmlName = 'Ccy';


                                            trigger OnBeforePassVariable();
                                            begin
                                                // if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                //     Ccy2 := CVLedgerEntryBuffer."Currency Code"
                                                // else
                                                Ccy_589 := format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'USD';//Ccy2 := "Credit Transfer Entry"."Currency Code";
                                            end;
                                        }

                                        trigger OnBeforePassVariable();
                                        begin

                                            if (CVLedgerEntryBuffer."Entry No." <> 0) then begin
                                                CdtNoteAmt := FORMAT(abs(CVLedgerEntryBuffer."Remaining Amount"), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                                if CVLedgerEntryBuffer."Document Type" <> CVLedgerEntryBuffer."Document Type"::"Credit Memo" then
                                                    currXMLport.Skip();
                                            end
                                            else begin
                                                CdtNoteAmt := FORMAT(abs("Credit Transfer Entry"."Transfer Amount"), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                                currXMLport.Skip();
                                            end;
                                        end;
                                    }
                                    textelement(RmtdAmt)//598//ACH-WIRE-CHECK = O-O-O
                                    {
                                        MinOccurs = Zero;

                                        textattribute(Ccy3)
                                        {
                                            XmlName = 'Ccy';

                                            trigger OnBeforePassVariable();
                                            begin
                                                // if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                //     Ccy3 := CVLedgerEntryBuffer."Currency Code"
                                                // else
                                                Ccy3 := format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency")));//'USD';//"Credit Transfer Entry"."Currency Code";

                                                //
                                            end;
                                        }

                                        trigger OnBeforePassVariable();
                                        begin
                                            if (CVLedgerEntryBuffer."Entry No." <> 0) then begin
                                                RmtdAmt := FORMAT(abs("Credit Transfer Entry"."Transfer Amount"), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                                if CVLedgerEntryBuffer."Document Type" = CVLedgerEntryBuffer."Document Type"::"Credit Memo" then
                                                    currXMLport.Skip();
                                            end
                                            else begin
                                                RmtdAmt := FORMAT(abs("Credit Transfer Entry"."Transfer Amount"), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
                                                currXMLport.Skip();
                                            end;
                                        end;
                                    }
                                }
                                textelement(CdtrRefInf)//599//ACH-WIRE-CHECK = O-O-O
                                {
                                    MinOccurs = Once;
                                    textelement(Tp_600)//600//ACH-WIRE-CHECK = O-O-O
                                    {
                                        XmlName = 'Tp';
                                        MinOccurs = Once;
                                        textelement(CdOrPrtry_601)//601//ACH-WIRE-CHECK = R-R-R
                                        {
                                            XmlName = 'CdOrPrtry';
                                            MinOccurs = Once;

                                            textelement(Cd_602)//602//ACH-WIRE-CHECK = O-O-O
                                            {
                                                MinOccurs = Once;
                                                xmlname = 'Cd';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    //Ref := 'PO REFERENCE 3';                                                    
                                                    Cd_602 := 'PUOR';//CVLedgerEntryBuffer."External Document No.";
                                                                     //else
                                                                     //AddtlRmtInf := "Credit Transfer Entry".ex;
                                                end;
                                            }
                                            textelement(Prtry_609)//609//ACH-WIRE-CHECK = O-O-O
                                            {
                                                MinOccurs = once;
                                                xmlname = 'Prtry';

                                                trigger OnBeforePassVariable();
                                                begin
                                                    //Ref := 'PO REFERENCE 3';                                                    
                                                    Prtry_609 := '';//CVLedgerEntryBuffer."External Document No.";

                                                    //else
                                                    //AddtlRmtInf := "Credit Transfer Entry".ex;
                                                    currXMLport.skip();//forced
                                                end;
                                            }
                                        }
                                        // trigger OnBeforePassVariable();
                                        // begin
                                        //     if GetPaymentTerm() in [3] then
                                        //         currXMLport.skip();
                                        // end;
                                    }

                                    textelement(Ref)//610/ACH-WIRE-CHECK = R-R-R
                                    {
                                        MinOccurs = Once;

                                        trigger OnBeforePassVariable();
                                        begin
                                            //Ref := 'PO REFERENCE 3';
                                            if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                                Ref := CVLedgerEntryBuffer."External Document No.";
                                            //else
                                            //AddtlRmtInf := "Credit Transfer Entry".ex;
                                        end;
                                    }
                                    trigger OnBeforePassVariable();
                                    begin
                                        // if GetPaymentTerm() in [1] then
                                        //     currXMLport.skip();
                                        if GetPaymentTerm() in [2, 6] then
                                            currXMLport.skip();
                                    end;

                                }
                                textelement(AddtlRmtInf)//662/ACH-WIRE-CHECK = O-O-O
                                {
                                    MinOccurs = Once;

                                    trigger OnBeforePassVariable();
                                    begin
                                        //AddtlRmtInf := 'DESCRIPTION';
                                        if (CVLedgerEntryBuffer."Entry No." <> 0) then
                                            AddtlRmtInf := copystr(CVLedgerEntryBuffer.Description, 1, 140);
                                        // else
                                        //     AddtlRmtInf := "Credit Transfer Entry".Desc;
                                    end;
                                }

                                trigger OnAfterGetRecord();
                                begin
                                    if GetPaymentTerm() in [9, 10, 11, 12] then
                                        currXMLport.skip();
                                    GetCVLedgerEntryBuffer(CVLedgerEntryBuffer, "Credit Transfer Entry"); // Populate CVLedgerEntryBuffer from the current Credit Transfer Entry
                                end;

                                trigger OnPreXmlItem();
                                var
                                begin
                                    ManualMessage := false;
                                    "Credit Transfer Entry".SETRANGE("Credit Transfer Entry"."Data Exch. Entry No.", "Payment Export Data"."Data Exch Entry No.");
                                    "Credit Transfer Entry".SETRANGE("Credit Transfer Entry"."Transaction ID", vTransThemUniqueId);
                                    if ("Credit Transfer Entry".Count() = 0) then begin
                                        ManualMessage := true;
                                        currXMLport.skip();
                                    end;
                                    if GetPaymentTerm() in [9, 10, 11] then
                                        currXMLport.skip();
                                end;

                            }
                            trigger OnBeforePassVariable()
                            begin
                                // if GetPaymentTerm() in [6] then
                                //     currXMLport.skip();
                                // if format(GetValue(RecordRef, PaymentExportData.FieldNo("AMC Recip. Bank Acc. Currency"))) = 'GBP' then
                                //     currXMLport.skip();
                            end;
                        }

                        trigger OnBeforePassVariable();
                        begin
                            // vTransThemUniqueId := "Payment Export Data"."Payment Information ID";
                            // if "Payment Export Data"."Line No." <> CurrentLineNo then begin
                            //     RecordRef.GetTable("Payment Export Data");
                            //     CurrentLineNo := "Payment Export Data"."Line No.";

                            // end
                            // else
                            //     currXMLport.SKIP();
                        end;

                    }

                    trigger OnAfterGetRecord();
                    begin
                        vTransThemUniqueId := "Payment Export Data"."Payment Information ID";
                        if "Payment Export Data"."Line No." <> CurrentLineNo then begin
                            RecordRef.GetTable("Payment Export Data");
                            CurrentLineNo := "Payment Export Data"."Line No.";
                        end
                        else
                            currXMLport.SKIP();
                    end;
                }
                trigger OnBeforePassVariable();
                begin
                    PaymentExportData.COPYFILTERS("Payment Export Data");
                    if PaymentExportData.FINDFIRST() then;
                    RecordRef.GetTable(PaymentExportData);
                end;
            }//CstmrCdtTrfInitn
        }//Document
    }

    trigger OnPreXmlPort();
    begin
        InitializeGlobals();
        CompanyInformation.get;
        PurchasesSetup.Get();
    end;

    var
        PaymentExportData: Record "Payment Export Data";
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        VATEntry: Record "VAT Entry"; //V17.5
        //AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankingMgt: Codeunit "SBC AMC Banking Mgt.";
        TypeHelper: Codeunit "Type Helper";
        RecordRef: RecordRef;
        CurrentLineNo: Integer;
        ManualMessage: Boolean;
        vTransThemUniqueId: text[50];
        CompanyInformation: record "Company Information";
        VendorBankAccount: Record "Vendor Bank Account";
        AddAdrLine: Boolean;
        Vendor: Record Vendor;
        CompInf: Record "Company Information";
        UsesTxId: Boolean;
        PurchasesSetup: Record "Purchases & Payables Setup";


    local procedure InitializeGlobals();
    begin
        CurrentLineNo := 0;
    end;

    local procedure GetLanguage(): Text[3];
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.GET(GLOBALLANGUAGE());
        exit(WindowsLanguage."Abbreviated Name");
    end;

    local procedure GetCVLedgerEntryBuffer(var CopyCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; CreditTransferEntry: Record "Credit Transfer Entry");
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000H4K', 'AMC Banking 365 Fundamentals', Enum::"Feature Uptake Status"::Used);
        Clear(CopyCVLedgerEntryBuffer);
        clear(VATEntry);
        if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Vendor) then begin
            VendorLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
            if (VendorLedgerEntry.get(CreditTransferEntry."Applies-to Entry No.")) then begin
                CopyCVLedgerEntryBuffer.CopyFromVendLedgEntry(VendorLedgerEntry);
                if (VendorLedgerEntry."External Document No." <> '') then
                    CopyCVLedgerEntryBuffer.Description := VendorLedgerEntry."External Document No." //1. Prio
                else
                    CopyCVLedgerEntryBuffer.Description := VendorLedgerEntry.Description; //2. Prio

                //Get sum of vat entries
            end
        end
        else
            if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Customer) then begin
                CustLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                if (CustLedgerEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                    CopyCVLedgerEntryBuffer.CopyFromCustLedgEntry(CustLedgerEntry);
                    if (CustLedgerEntry."Document Date" <> 0D) then
                        CopyCVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Document Date"
                    else
                        CopyCVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Posting Date";
                end
            end
            else
                if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Employee) then begin
                    EmployeeLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                    if (EmployeeLedgerEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                        CopyCVLedgerEntryBuffer.CopyFromEmplLedgEntry(EmployeeLedgerEntry);
                        CopyCVLedgerEntryBuffer."Document Date" := EmployeeLedgerEntry."Posting Date";
                    end;
                end;

        //-> V17.5
        if (not CopyCVLedgerEntryBuffer.IsEmpty) then begin
            VATEntry.SetCurrentKey("Posting Date", "Document Date");
            VATEntry.SetRange("Posting Date", CopyCVLedgerEntryBuffer."Posting Date");
            VATEntry.SetRange("Document Date", CopyCVLedgerEntryBuffer."Document Date");
            VATEntry.SetRange("Document No.", CopyCVLedgerEntryBuffer."Document No.");
            VATEntry.SetRange("Document Type", CopyCVLedgerEntryBuffer."Document Type");
            VATEntry.CalcSums(VATEntry.Amount);
        end;
        //<- V17.5
        FeatureTelemetry.LogUsage('0000H4L', 'AMC Banking 365 Fundamentals', 'Export CT applied');
    end;

    procedure GetMessageID(BankCode: code[20]): code[20]
    var
        BankAccount: Record "Bank Account";
        NoSeries: code[20];
        xRecNoSeries: code[20];
        NewID: code[20];
        NoSeriesMgt: codeunit NoSeriesManagement;
    begin
        if not BankAccount.get(BankCode) then
            exit('');
        if BankAccount."TIG Payment Export Nos" = '' then
            exit('');
        NoSeriesMgt.InitSeries(BankAccount."TIG Payment Export Nos", xRecNoSeries, 0D, NewID, NoSeries);
        exit(NewID);
    end;

    procedure GetPaymentTerm(): integer
    var
        PaymentMethod: Record "Payment Method";
        PayMethodCode: code[20];
        Num: Integer;
    begin
        PayMethodCode := GetValue(RecordRef, PaymentExportData.FieldNo("TIG Payment Method Code"));
        //This is where the payment method payment type is pulled. Need to add Payment Types GACH, AutoFX, and
        //6 = Autofx, 5 = CGWire, 4 = GACH, 3 = Check, 2 = Wire, 1 = ACH
        if PaymentMethod.get(PayMethodCode) then begin
            Num := paymentMethod."TIG Payment Type";
            exit(paymentMethod."TIG Payment Type");
        end;

    end;

    local procedure GetValue(RecordRef: RecordRef; FieldNo: Integer): Text;
    var
        TransformedValue: Text;
    begin

        TransformedValue := AMCBankingMgt.GetFieldValue(RecordRef, FieldNo);

        if (TransformedValue <> '') then
            exit(TransformedValue)
        else
            currXMLport.Skip();

    end;

    local procedure GetValueDontSkip(RecordRef: RecordRef; FieldNo: Integer): Text;
    var
        TransformedValue: Text;
    begin

        TransformedValue := AMCBankingMgt.GetFieldValue(RecordRef, FieldNo);

        exit(TransformedValue)
    end;

    local procedure MakeAdrLine(Adr1: Text; Adr2: Text): Text
    var
        CombinedAdr: Text;
    begin
        if Adr2 = '' then
            exit(Adr1);

        CombinedAdr := StrSubstNo('%1, %2', Adr1, Adr2);

        if StrLen(CombinedAdr) >= 35 then begin
            AddAdrLine := true;
            exit(Adr1);
        end;

        exit(CombinedAdr);
    end;

    local procedure CrossBorder(): Boolean
    var
        BankAccount: Record "Bank Account";
        CompanyInformationRec: Record "Company Information";
        CompanyBankCountryCode: Code[10];
        VendorBankCountryCode: Code[10];
    begin
        CompanyInformationRec.Get();

        VendorBankCountryCode := VendorBankAccount."Country/Region Code";
        if VendorBankCountryCode = '' then
            VendorBankCountryCode := CompanyInformationRec."Country/Region Code";

        BankAccount.Get(GetValue(RecordRef, PaymentExportData.FieldNo("Sender Bank Account Code")));
        CompanyBankCountryCode := BankAccount."Country/Region Code";
        if CompanyBankCountryCode = '' then
            CompanyBankCountryCode := CompanyInformationRec."Country/Region Code";

        if VendorBankCountryCode = CompanyBankCountryCode then
            exit(false);

        exit(true);
    end;
}