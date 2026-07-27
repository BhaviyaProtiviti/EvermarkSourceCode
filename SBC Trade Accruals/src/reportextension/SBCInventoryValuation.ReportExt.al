reportextension 50700 "SBC Inventory Valuation" extends "Inventory Valuation"
{
    dataset
    {
        add(Item)
        {
            column(IncludeInboundFreight; IncludeInboundFreight)
            {
            }
        }
        addafter(BufferLoop)
        {
            dataitem(SBCInboundCostLedgerEntry; SBCInboundCostLedgerEntry)
            {
                DataItemTableView = sorting("Entry No.");

                column(SBCInboundCostValue; "Accrual Amount")
                {
                }
                column(SBCInboundFreightCostValue; GetCostValue("Entry Type", "Entry Type"::"Inbound Freight", "Accrual Amount"))
                {
                }
                column(SBCWHInboundVariableCostValue; GetCostValue("Entry Type", "Entry Type"::"WH Inbound Variable", "Accrual Amount"))
                {
                }
                column(SBCInboundOverheadFixedCostValue; GetCostValue("Entry Type", "Entry Type"::"WH Overhead - Fixed", "Accrual Amount"))
                {
                }
                column(SBCCustomDutyValue; GetCostValue("Entry Type", "Entry Type"::"SBC Custom/Duty", "Accrual Amount"))
                {
                }


                trigger OnPreDataItem()
                begin
                    SetFilters();
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(CheckIncludeInboundFreight; IncludeInboundFreight)
                {
                    ApplicationArea = All;
                    Caption = 'Include Inbound Freight';
                    ToolTip = 'Specifies if you want to include Inbound Freight Data';
                }
            }
        }
    }

    rendering
    {
        layout(SBCInventoryValuationWithInboundFreight)
        {
            Caption = 'SBC Inventory Valuation With Inbound Freight';
            Type = RDLC;
            LayoutFile = './src/reportextension/layout/SBCInventoryValuationWithInboundFreight.rdlc';
        }
    }

    labels
    {
        InboundFreightValLbl = 'Inbound Freight Cost Value';
        WHInboundVariableValLbl = 'WH Inbound Variable';
        TotalInvValLbl = 'Total Inventory Value';
        UnitCostInclInbCostsLbl = 'Unit Cost Incl. Inb. Costs';
        WHFixedValLbl = 'WH Overhead - Fixed';
    }

    var
        IncludeInboundFreight: Boolean;

    local procedure SetFilters()
    begin
        SBCInboundCostLedgerEntry.Reset();
        SBCInboundCostLedgerEntry.SetRange("Item No.", Item."No.");
        //SBCInboundCostLedgerEntry.SetRange("Posting Date", 0D, EndDate);
        if Item.GetFilter("Location Filter") <> '' then
            SBCInboundCostLedgerEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
        if Item.GetFilter("Global Dimension 1 Filter") <> '' then
            SBCInboundCostLedgerEntry.SetFilter(GlobalDimension1, Item.GetFilter("Global Dimension 1 Filter"));
        if Item.GetFilter("Global Dimension 2 Filter") <> '' then
            SBCInboundCostLedgerEntry.SetFilter(GlobalDimension2, Item.GetFilter("Global Dimension 2 Filter"));
    end;

    local procedure GetCostValue(DataItemEntryType: Enum SBCInboundCostEntryType; CurrEntryType: Enum SBCInboundCostEntryType; Amount: Decimal): Decimal
    begin
        if CurrEntryType = DataItemEntryType then
            exit(Amount)
        else
            exit(0);
    end;
}