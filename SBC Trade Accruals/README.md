# SBC Trade Accruals

## Overview
SBC Trade Accruals is a Business Central AL extension for Elida Beauty that automates trade accrual calculations on sales activity and indirect inbound cost accruals on purchase and sales posting.

## App Info
- Name: SBC Trade Accruals
- Publisher: Tigunia, LLC
- Version: 22.0.0.11
- Runtime: 11.0
- Application: 22.0.0.0
- Platform: 1.0.0.0
- Object range: 50700-50750

## Dependencies
- None

## Key Behavior
- Calculates trade accrual amounts from configured setup lines based on customer group, customer, item, dimension, effective dates, and configured base/rate.
- Supports trade setup types Percent and Per Unit, with base options Gross Sales or Net Sales.
- Creates trade accrual ledger entries and related G/L journal lines during sales posting flows.
- Updates journal document references from sales order number to posted invoice number before optional auto-post.
- Calculates inbound indirect costs for item transactions using item-level rates (inbound freight, warehouse inbound variable, warehouse overhead fixed, custom duty).
- Creates inbound cost ledger entries across purchase receipt, purchase credit memo, sales shipment, sales invoice, and sales credit memo scenarios (based on active subscribers).
- Validates inbound cost journal and account setup before creating or posting journal entries.
- Supports optional auto-post for both trade accrual journal lines and inbound indirect cost journal lines.
- Extends Inventory Valuation with optional inbound freight/cost inclusion columns and an additional RDLC layout.

## Setup Areas
- Sales & Receivables Setup extension fields for trade enablement, journal template, journal batch, and auto-post.
- Inbound Cost Setup card for journal mapping, cost accounts, calculation type, and feature toggles.
- Item Card extension fields for inbound and custom duty rates.
- Location Card extension field to enable/disable inbound-cost calculations by location.

## Main Objects
### Codeunits
- 50700 SBCTradeEventSubscribers
- 50701 SBC Trade Accrual Management
- 50702 SBCInboundCostManagement

### Tables
- 50700 SBCTradeSetupHeader
- 50701 SBCTradeSetupLines
- 50702 SBCTradeAccrualLedgerEntry
- 50703 SBCInboundCostSetup
- SBCInboundCostLedgerEntry

### Pages
- 50700 SBCTradeSetup
- 50701 SBCTradeSetupLines
- 50702 SBCTradeAccrualsLedgerEntries
- 50703 SBCInboundCostSetupCard
- SBCInboundCostLedgerEntries

### Enums
- 50700 SBCTradeSetupType
- 50701 SBCTradeSetupBase
- 50702 SBCInboundDocumentTypes
- 50703 SBCInboundCostEntryType
- 50704 SBCInboundCostCalcType

### Extensions and security
- Table extensions on Sales & Receivables Setup, Item, Gen. Journal Line, and Location
- Page extensions on Sales & Receivables Setup, Item Card, and Location Card
- Report extension: 50700 SBC Inventory Valuation
- Permission sets: SBCTradeAccrualsPermissions, SBCInboundCostsPermissions

## Notes
This app is designed for environments that need trade-expense accrual visibility and configurable inbound indirect cost capture integrated into standard Business Central posting events.
