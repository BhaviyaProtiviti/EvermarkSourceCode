codeunit 50702 SBCInboundCostManagement
{
    procedure ProcessReceiptLine(PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgerEntryNo: Integer)
    var
        Location: Record Location;
    begin
        if PurchRcptLine.Type <> PurchRcptLine.Type::Item then
            exit;
        if not GetSetupInformation() then
            exit;
        if not SBCInboundCostSetup."Enable Indirect Costs" then
            exit;
        if not GetItemInformation(PurchRcptLine."No.") then
            exit;
        if not Location.Get(PurchRcptLine."Location Code") then
            exit;
        if not Location."SBCCalcInboundCosts" then
            exit;
        CheckInboundAndCustomRates(Item, PurchRcptLine, ItemLedgerEntryNo);
    end;

    procedure ProcessCrMemoLine(PCrMemoLine: Record "Purch. Cr. Memo Line"; ItemLedgerEntryNo: Integer)
    var
        Location: Record Location;
    begin
        if PCrMemoLine.Type <> PCrMemoLine.Type::Item then
            exit;
        if not GetSetupInformation() then
            exit;
        if not SBCInboundCostSetup."Enable Indirect Costs" then
            exit;
        if not GetItemInformation(PCrMemoLine."No.") then
            exit;
        if not Location.Get(PCrMemoLine."Location Code") then
            exit;
        if not Location."SBCCalcInboundCosts" then
            exit;
        CheckInboundAndCustomRates(Item, PCrMemoLine, ItemLedgerEntryNo);
    end;

    procedure ProcessShipmentLine(ShipmentLine: Record "Sales Shipment Line"; ItemLedgerEntryNo: Integer)
    var
        Location: Record Location;
    begin
        if ShipmentLine.Type <> ShipmentLine.Type::Item then
            exit;
        if not GetSetupInformation() then
            exit;
        if not SBCInboundCostSetup."Enable Indirect Costs" then
            exit;
        if not CheckInboundJournalSetup() then
            exit;
        if not GetItemInformation(ShipmentLine."No.") then
            exit;
        if not Location.Get(ShipmentLine."Location Code") then
            exit;
        if not Location."SBCCalcInboundCosts" then
            exit;
        CheckInboundAndCustomRates(Item, ShipmentLine, ItemLedgerEntryNo);
    end;

    procedure ProcessInvoiceLine(InvoiceLine: Record "Sales Invoice Line"; ItemLedgerEntryNo: Integer)
    var
        Location: Record Location;
    begin
        if InvoiceLine.Type <> InvoiceLine.Type::Item then
            exit;
        if not GetSetupInformation() then
            exit;
        if not SBCInboundCostSetup."Enable Indirect Costs" then
            exit;
        if not CheckInboundJournalSetup() then
            exit;
        if not GetItemInformation(InvoiceLine."No.") then
            exit;
        if not Location.Get(InvoiceLine."Location Code") then
            exit;
        if not Location."SBCCalcInboundCosts" then
            exit;
        CheckInboundAndCustomRates(Item, InvoiceLine, ItemLedgerEntryNo);
    end;

    procedure ProcessCrMemoLine(CrMemoLine: Record "Sales Cr.Memo Line"; ItemLedgerEntryNo: Integer)
    var
        Location: Record Location;
    begin
        if CrMemoLine.Type <> CrMemoLine.Type::Item then
            exit;
        if not GetSetupInformation() then
            exit;
        if not SBCInboundCostSetup."Enable Indirect Costs" then
            exit;
        if not CheckInboundJournalSetup() then
            exit;
        if not GetItemInformation(CrMemoLine."No.") then
            exit;
        if not Location.Get(CrMemoLine."Location Code") then
            exit;
        if not Location."SBCCalcInboundCosts" then
            exit;
        CheckInboundAndCustomRates(Item, CrMemoLine, ItemLedgerEntryNo);
    end;

    procedure ProcessJournalBatch()
    begin
        if not GetSetupInformation() then
            exit;
        if not SBCInboundCostSetup."Enable Indirect Costs" then
            exit;
        if not SBCInboundCostSetup."Auto Post Indirect Costs" then
            exit;
        if not CheckInboundJournalSetup() then
            exit;
        PostJournalBatch();
    end;

    local procedure PostJournalBatch()
    var
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", SBCInboundCostSetup."Inbound Cost Journal Template");
        GenJnlLine.SetRange("Journal Batch Name", SBCInboundCostSetup."Inbound Cost Journal Batch");
        if GenJnlLine.FindFirst() then
            GenJnlPostBatch.Run(GenJnlLine);
    end;

    local procedure CheckInboundJournalSetup(): Boolean
    begin
        if SBCInboundCostSetup."Inbound Cost Journal Template" = '' then begin
            Error('Inbound Cost Journal Template is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."Inbound Cost Journal Batch" = '' then begin
            Error('Inbound Cost Journal Batch is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."Inbound Freight Acc. Account" = '' then begin
            Error('Inbound Freight Acc. Account is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."Accd Freight Inb. Acc." = '' then begin
            Error('Accd Freight Inb. Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."COGS Inb. Freight Acc." = '' then begin
            Error('COGS Inb. Freight Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."WH Inbound Acc." = '' then begin
            Error('WH Inbound Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."Accd WH Inbound Acc." = '' then begin
            Error('Accd WH Inbound Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."COGS WH Inbound Acc." = '' then begin
            Error('COGS WH Inbound Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."WH Overhead Acc." = '' then begin
            Error('WH Overhead Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."Accd WH Overhead Acc." = '' then begin
            Error('Accd WH Overhead Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."COGS WH Overhead Acc." = '' then begin
            Error('COGS WH Overhead Acc. is not set up.');
            exit(false);
        end;
        if SBCInboundCostSetup."SBC COGS Custom/Duty Acc." = '' then begin
            Error('COGS Custom/Duty Acc. is not set up.');
            exit(false);
        end;
        exit(true);
    end;

    local procedure CheckInboundAndCustomRates(Item: Record Item; PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgerEntryNo: Integer)
    var
        InboundDocumentTypes: Enum SBCInboundDocumentTypes;
        EntryType: Enum "SBCInboundCostEntryType";
    begin
        if Item."Inbound Freight Rate" <> 0 then
            CreateInboundCostLedgerEntry(Item, PurchRcptLine."Posting Date", PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."Location Code", PurchRcptLine."Quantity (Base)", PurchRcptLine."Unit Cost", PurchRcptLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"Inbound Freight");
        if Item."WB Inbound Variable" <> 0 then
            CreateInboundCostLedgerEntry(Item, PurchRcptLine."Posting Date", PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."Location Code", PurchRcptLine."Quantity (Base)", PurchRcptLine."Unit Cost", PurchRcptLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"WH Inbound Variable");
        if Item."WH Overhead - Fixed" <> 0 then
            CreateInboundCostLedgerEntry(Item, PurchRcptLine."Posting Date", PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."Location Code", PurchRcptLine."Quantity (Base)", PurchRcptLine."Unit Cost", PurchRcptLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"WH Overhead - Fixed");
        if Item."SBC Custom/Duty" <> 0 then
            CreateInboundCostLedgerEntry(Item, PurchRcptLine."Posting Date", PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."Location Code", PurchRcptLine."Quantity (Base)", PurchRcptLine."Unit Cost", PurchRcptLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"SBC Custom/Duty");

    end;

    local procedure CheckInboundAndCustomRates(Item: Record Item; PCrMemoLine: Record "Purch. Cr. Memo Line"; ItemLedgerEntryNo: Integer)
    var
        InboundDocumentTypes: Enum SBCInboundDocumentTypes;
        EntryType: Enum "SBCInboundCostEntryType";
    begin
        if Item."Inbound Freight Rate" <> 0 then
            CreateInboundCostLedgerEntry(Item, PCrMemoLine."Posting Date", PCrMemoLine."Document No.", PCrMemoLine."Line No.", PCrMemoLine."Location Code", -PCrMemoLine."Quantity (Base)", PCrMemoLine."Unit Cost", PCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"Inbound Freight");
        if Item."WB Inbound Variable" <> 0 then
            CreateInboundCostLedgerEntry(Item, PCrMemoLine."Posting Date", PCrMemoLine."Document No.", PCrMemoLine."Line No.", PCrMemoLine."Location Code", -PCrMemoLine."Quantity (Base)", PCrMemoLine."Unit Cost", PCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"WH Inbound Variable");
        if Item."WH Overhead - Fixed" <> 0 then
            CreateInboundCostLedgerEntry(Item, PCrMemoLine."Posting Date", PCrMemoLine."Document No.", PCrMemoLine."Line No.", PCrMemoLine."Location Code", -PCrMemoLine."Quantity (Base)", PCrMemoLine."Unit Cost", PCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"WH Overhead - Fixed");
        if Item."SBC Custom/Duty" <> 0 then
            CreateInboundCostLedgerEntry(Item, PCrMemoLine."Posting Date", PCrMemoLine."Document No.", PCrMemoLine."Line No.", PCrMemoLine."Location Code", -PCrMemoLine."Quantity (Base)", PCrMemoLine."Unit Cost", PCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Purchase, EntryType::"SBC Custom/Duty");

    end;

    local procedure CheckInboundAndCustomRates(Item: Record Item; ShipmentLine: Record "Sales Shipment Line"; ItemLedgerEntryNo: Integer)
    var
        InboundDocumentTypes: Enum SBCInboundDocumentTypes;
        EntryType: Enum "SBCInboundCostEntryType";
    begin
        if Item."Inbound Freight Rate" <> 0 then
            CreateInboundCostLedgerEntry(Item, ShipmentLine."Posting Date", ShipmentLine."Document No.", ShipmentLine."Line No.", ShipmentLine."Location Code", -ShipmentLine."Quantity (Base)", ShipmentLine."Unit Cost", ShipmentLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"Inbound Freight");
        if Item."WB Inbound Variable" <> 0 then
            CreateInboundCostLedgerEntry(Item, ShipmentLine."Posting Date", ShipmentLine."Document No.", ShipmentLine."Line No.", ShipmentLine."Location Code", -ShipmentLine."Quantity (Base)", ShipmentLine."Unit Cost", ShipmentLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"WH Inbound Variable");
        if Item."WH Overhead - Fixed" <> 0 then
            CreateInboundCostLedgerEntry(Item, ShipmentLine."Posting Date", ShipmentLine."Document No.", ShipmentLine."Line No.", ShipmentLine."Location Code", -ShipmentLine."Quantity (Base)", ShipmentLine."Unit Cost", ShipmentLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"WH Overhead - Fixed");
        if Item."SBC Custom/Duty" <> 0 then
            CreateInboundCostLedgerEntry(Item, ShipmentLine."Posting Date", ShipmentLine."Document No.", ShipmentLine."Line No.", ShipmentLine."Location Code", -ShipmentLine."Quantity (Base)", ShipmentLine."Unit Cost", ShipmentLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"SBC Custom/Duty");

    end;

    local procedure CheckInboundAndCustomRates(Item: Record Item; InvoiceLine: Record "Sales Invoice Line"; ItemLedgerEntryNo: Integer)
    var
        InboundDocumentTypes: Enum SBCInboundDocumentTypes;
        EntryType: Enum "SBCInboundCostEntryType";
    begin
        if Item."Inbound Freight Rate" <> 0 then
            CreateInboundCostLedgerEntry(Item, InvoiceLine."Posting Date", InvoiceLine."Document No.", InvoiceLine."Line No.", InvoiceLine."Location Code", -InvoiceLine."Quantity (Base)", InvoiceLine."Unit Cost", InvoiceLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"Inbound Freight");
        if Item."WB Inbound Variable" <> 0 then
            CreateInboundCostLedgerEntry(Item, InvoiceLine."Posting Date", InvoiceLine."Document No.", InvoiceLine."Line No.", InvoiceLine."Location Code", -InvoiceLine."Quantity (Base)", InvoiceLine."Unit Cost", InvoiceLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"WH Inbound Variable");
        if Item."WH Overhead - Fixed" <> 0 then
            CreateInboundCostLedgerEntry(Item, InvoiceLine."Posting Date", InvoiceLine."Document No.", InvoiceLine."Line No.", InvoiceLine."Location Code", -InvoiceLine."Quantity (Base)", InvoiceLine."Unit Cost", InvoiceLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"WH Overhead - Fixed");
        if Item."SBC Custom/Duty" <> 0 then
            CreateInboundCostLedgerEntry(Item, InvoiceLine."Posting Date", InvoiceLine."Document No.", InvoiceLine."Line No.", InvoiceLine."Location Code", -InvoiceLine."Quantity (Base)", InvoiceLine."Unit Cost", InvoiceLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"SBC Custom/Duty");

    end;

    local procedure CheckInboundAndCustomRates(Item: Record Item; SalesCrMemoLine: Record "Sales Cr.Memo Line"; ItemLedgerEntryNo: Integer)
    var
        InboundDocumentTypes: Enum SBCInboundDocumentTypes;
        EntryType: Enum "SBCInboundCostEntryType";
    begin
        if Item."Inbound Freight Rate" <> 0 then
            CreateInboundCostLedgerEntry(Item, SalesCrMemoLine."Posting Date", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.", SalesCrMemoLine."Location Code", SalesCrMemoLine."Quantity (Base)", SalesCrMemoLine."Unit Cost", SalesCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"Inbound Freight");
        if Item."WB Inbound Variable" <> 0 then
            CreateInboundCostLedgerEntry(Item, SalesCrMemoLine."Posting Date", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.", SalesCrMemoLine."Location Code", SalesCrMemoLine."Quantity (Base)", SalesCrMemoLine."Unit Cost", SalesCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"WH Inbound Variable");
        if Item."WH Overhead - Fixed" <> 0 then
            CreateInboundCostLedgerEntry(Item, SalesCrMemoLine."Posting Date", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.", SalesCrMemoLine."Location Code", SalesCrMemoLine."Quantity (Base)", SalesCrMemoLine."Unit Cost", SalesCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"WH Overhead - Fixed");
        if Item."SBC Custom/Duty" <> 0 then
            CreateInboundCostLedgerEntry(Item, SalesCrMemoLine."Posting Date", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.", SalesCrMemoLine."Location Code", SalesCrMemoLine."Quantity (Base)", SalesCrMemoLine."Unit Cost", SalesCrMemoLine."Dimension Set ID", ItemLedgerEntryNo, InboundDocumentTypes::Sales, EntryType::"SBC Custom/Duty");

    end;

    local procedure GetItemInformation(ItemNo: Code[20]): Boolean
    begin
        exit(Item.Get(ItemNo));
    end;

    local procedure GetSetupInformation(): Boolean
    begin
        exit(SBCInboundCostSetup.Get());
    end;

    local procedure GetInboundFreightRate(Item: Record Item): Decimal
    begin
        exit(Item."Inbound Freight Rate");
    end;

    local procedure GetWBInboundVariableRate(Item: Record Item): Decimal
    begin
        exit(Item."WB Inbound Variable");
    end;

    local procedure GetWHOverheadFixedRate(Item: Record Item): Decimal
    begin
        exit(Item."WH Overhead - Fixed");
    end;

    local procedure GetCustomDutyRate(Item: Record Item): Decimal
    begin
        exit(Item."SBC Custom/Duty");
    end;

    local procedure GetInboundFreightAmount(Rate: Decimal; Quantity: Decimal): Decimal
    begin
        exit(GetAmount(Rate, Quantity, SBCInboundCostSetup.CostCalcType));
    end;

    local procedure GetWHInboundVariableAmount(Rate: Decimal; Quantity: Decimal): Decimal
    begin
        exit(GetAmount(Rate, Quantity, SBCInboundCostSetup.CostCalcType));
    end;

    local procedure GetWHOverheadFixedAmount(Rate: Decimal; Quantity: Decimal): Decimal
    begin
        exit(GetAmount(Rate, Quantity, SBCInboundCostSetup.CostCalcType));
    end;

    local procedure GetCustomDutyAmount(Rate: Decimal; Quantity: Decimal): Decimal
    begin
        exit(GetAmount(Rate, Quantity, SBCInboundCostSetup.CostCalcType));
    end;

    local procedure GetAmount(Rate: Decimal; Quantity: Decimal; CostCalcType: Enum "SBCInboundCostCalcType"): Decimal
    begin
        if CostCalcType = SBCInboundCostSetup.CostCalcType::Percentage then
            exit(Rate * Quantity / 100);
        if CostCalcType = SBCInboundCostSetup.CostCalcType::"Per Unit" then
            exit(Rate * Quantity);
    end;

    local procedure GetRate(Item: Record Item; EntryType: Enum "SBCInboundCostEntryType"): Decimal
    begin
        case EntryType of
            EntryType::"Inbound Freight":
                exit(GetInboundFreightRate(Item));
            EntryType::"WH Inbound Variable":
                exit(GetWBInboundVariableRate(Item));
            EntryType::"WH Overhead - Fixed":
                exit(GetWHOverheadFixedRate(Item));
            EntryType::"SBC Custom/Duty":
                exit(GetCustomDutyRate(Item));
        end;
    end;

    local procedure GetInboundAmount(Quantity: Decimal; UnitCost: Decimal; EntryType: Enum "SBCInboundCostEntryType"; Rate: Decimal): Decimal
    begin
        case EntryType of
            EntryType::"Inbound Freight":
                exit(GetInboundFreightAmount(Rate, Quantity));
            EntryType::"WH Inbound Variable":
                exit(GetWHInboundVariableAmount(Rate, Quantity));
            EntryType::"WH Overhead - Fixed":
                exit(GetWHOverheadFixedAmount(Rate, Quantity));
            EntryType::"SBC Custom/Duty":
                exit(GetCustomDutyAmount(Rate, Quantity));
        end;
    end;

    local procedure CreateInboundCostLedgerEntry(Item: Record Item; PostingDate: Date; DocumentNo: Code[20]; LineNo: Integer; LocationCode: Code[10]; Quantity: Decimal; UnitCost: Decimal; DimSetID: Integer; ItemLedgerEntryNo: Integer; DocumentType: Enum SBCInboundDocumentTypes; EntryType: Enum "SBCInboundCostEntryType")
    var
        ShortcutDimensions: array[8] of Code[20];
        DimMgt: Codeunit DimensionManagement;
        SBCInboundCostLedgerEntry: Record "SBCInboundCostLedgerEntry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccrualAmount, AccrualRate : Decimal;
    begin
        GeneralLedgerSetup.Get();
        AccrualRate := GetRate(Item, EntryType);
        AccrualAmount := Round(GetInboundAmount(Quantity, UnitCost, EntryType, AccrualRate), GeneralLedgerSetup."Amount Rounding Precision");
        if AccrualAmount = 0 then
            exit;

        DimMgt.GetShortcutDimensions(DimSetID, ShortcutDimensions);
        SBCInboundCostLedgerEntry.Init();
        SBCInboundCostLedgerEntry."Posting Date" := PostingDate;
        SBCInboundCostLedgerEntry."Document Type" := DocumentType;
        SBCInboundCostLedgerEntry."Document No." := DocumentNo;
        SBCInboundCostLedgerEntry."Line No." := LineNo;
        SBCInboundCostLedgerEntry."Item No." := Item."No.";
        SBCInboundCostLedgerEntry."Location Code" := LocationCode;
        SBCInboundCostLedgerEntry.Quantity := Quantity;
        SBCInboundCostLedgerEntry."Entry Type" := EntryType;
        SBCInboundCostLedgerEntry."Accrual Rate" := AccrualRate;
        SBCInboundCostLedgerEntry."Accrual Amount" := AccrualAmount;
        SBCInboundCostLedgerEntry.GlobalDimension1 := ShortcutDimensions[1];
        SBCInboundCostLedgerEntry.GlobalDimension2 := ShortcutDimensions[2];
        SBCInboundCostLedgerEntry.GlobalDimension4 := ShortcutDimensions[4];
        SBCInboundCostLedgerEntry."Item Ledger Entry No." := ItemLedgerEntryNo;
        SBCInboundCostLedgerEntry.Insert();

        CreateInboundCostGenJournalLine(SBCInboundCostLedgerEntry, DimSetID);
    end;

    local procedure CreateInboundCostGenJournalLine(SBCInboundCostLedgerEntry: Record "SBCInboundCostLedgerEntry"; DimSetID: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
        CostEntryType: Enum SBCInboundCostEntryType;
    begin
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := SBCInboundCostSetup."Inbound Cost Journal Template";
        GenJournalLine."Journal Batch Name" := SBCInboundCostSetup."Inbound Cost Journal Batch";
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(SBCInboundCostSetup."Inbound Cost Journal Template", SBCInboundCostSetup."Inbound Cost Journal Batch");
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Posting Date" := SBCInboundCostLedgerEntry."Posting Date";
        GenJournalLine.Validate("Account No.", GetGLAccountNoFromEntryType(SBCInboundCostLedgerEntry."Document Type", SBCInboundCostLedgerEntry."Entry Type"));
        GenJournalLine.Validate("Document No.", SBCInboundCostLedgerEntry."Document No.");
        GenJournalLine.Validate(Amount, Abs(SBCInboundCostLedgerEntry."Accrual Amount"));
        GenJournalLine.Validate("Bal. Account No.", GetBalGLAccountFromEntryType(SBCInboundCostLedgerEntry."Document Type", SBCInboundCostLedgerEntry."Entry Type"));
        GenJournalLine.Validate("Dimension Set ID", DimSetID);
        GenJournalLine."SBC Inbound Cost Entry No." := SBCInboundCostLedgerEntry."Entry No.";
        GenJournalLine.Insert(true);
    end;

    local procedure GetGLAccountNoFromEntryType(DocumentType: Enum SBCInboundDocumentTypes; EntryType: Enum "SBCInboundCostEntryType"): Code[20]
    begin
        case DocumentType of
            SBCInboundDocumentTypes::Sales:
                case EntryType of
                    EntryType::"Inbound Freight":
                        exit(SBCInboundCostSetup."COGS Inb. Freight Acc.");
                    EntryType::"WH Inbound Variable":
                        exit(SBCInboundCostSetup."COGS WH Inbound Acc.");
                    EntryType::"WH Overhead - Fixed":
                        exit(SBCInboundCostSetup."COGS WH Overhead Acc.");
                    EntryType::"SBC Custom/Duty":
                        exit(SBCInboundCostSetup."SBC COGS Custom/Duty Acc.");
                end;
            SBCInboundDocumentTypes::Purchase:
                case EntryType of
                    EntryType::"Inbound Freight":
                        exit(SBCInboundCostSetup."Inbound Freight Acc. Account");
                    EntryType::"WH Inbound Variable":
                        exit(SBCInboundCostSetup."WH Inbound Acc.");
                    EntryType::"WH Overhead - Fixed":
                        exit(SBCInboundCostSetup."WH Overhead Acc.");
                    EntryType::"SBC Custom/Duty":
                        exit(SBCInboundCostSetup."SBC Custom/Duty Acc.");
                end;
        end;
    end;

    local procedure GetBalGLAccountFromEntryType(DocumentType: Enum SBCInboundDocumentTypes; EntryType: Enum "SBCInboundCostEntryType"): Code[20]
    begin
        case DocumentType of
            SBCInboundDocumentTypes::Sales:
                case EntryType of
                    EntryType::"Inbound Freight":
                        exit(SBCInboundCostSetup."Inbound Freight Acc. Account");
                    EntryType::"WH Inbound Variable":
                        exit(SBCInboundCostSetup."WH Inbound Acc.");
                    EntryType::"WH Overhead - Fixed":
                        exit(SBCInboundCostSetup."WH Overhead Acc.");
                    EntryType::"SBC Custom/Duty":
                        exit(SBCInboundCostSetup."SBC Custom/Duty Acc.");
                end;
            SBCInboundDocumentTypes::Purchase:
                case EntryType of
                    EntryType::"Inbound Freight":
                        exit(SBCInboundCostSetup."Accd Freight Inb. Acc.");
                    EntryType::"WH Inbound Variable":
                        exit(SBCInboundCostSetup."Accd WH Inbound Acc.");
                    EntryType::"WH Overhead - Fixed":
                        exit(SBCInboundCostSetup."Accd WH Overhead Acc.");
                    EntryType::"SBC Custom/Duty":
                        exit(SBCInboundCostSetup."SBC Accd Custom/Duty Acc.");
                end;
        end;
    end;

    var
        SBCInboundCostSetup: Record SBCInboundCostSetup;
        Item: Record Item;
}
