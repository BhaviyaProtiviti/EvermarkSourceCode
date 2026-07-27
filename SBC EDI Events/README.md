# SBCEDI Events

## Overview
SBCEDI Events is a Business Central AL extension that adds custom event-driven behavior on top of Lanham EDI for Suave, including 850 sales-order enhancements, 820 remittance processing, and Emerson cross-reference automation.

## App Info
- Name: SBCEDI Events
- Publisher: Tigunia, LLC
- Version: 22.0.54157.199
- Runtime: 11.0
- Application: 22.0.0.0
- Platform: 1.0.0.0
- Object range: 50080-50148

## Dependencies
- SBC - UI Modifications (Tigunia) >= 22.0.54157.92
- Lanham EDI (Lanham Associates) >= 22.2.3.1030
- SBC_Main_Modifications (Tigunia, LLC) >= 1.0.0.115
- _Exclude Bank Deposits (Microsoft) >= 22.0.54157.55195
- SBC Trade Allocation & Accrual (Tigunia, LLC) >= 22.0.54157.99

## Key Behavior
- Extends EDI document setup with controls for lower-price acceptance, variance thresholds, SMOG handling, 850 sales-order updates, and automatic customer/ship-to creation.
- Auto-creates missing customers and ship-to addresses from incoming 850 content when enabled on the EDI document.
- Applies customer templates during auto-created customer flow when a template is configured.
- Supports EDI 851 handling to update eligible open sales orders from 850 update flows.
- Builds and posts multi-customer 820 remittance data into payment advice and journal lines with configurable payer/balance-account behavior.
- Maintains Emerson customer and ship-to EDI cross references and provides utilities to refresh or clean orphaned references.
- Adds SMOG-rate driven posting-group behavior for supported sales order processing scenarios.
- Logs EDI receive document errors in a dedicated list for troubleshooting.

## Main Objects
### Core codeunits
- 50080 SBCEDI Event Helper
- 50081 SBCEDI 820 Helper
- 50082 SBCEDI 820 Remit Helper
- 50083 SBCEDI 820 Journal Events
- 50084 SBCEDI 856 Purch Events
- 50085 SBCEDI 850 Helper
- 50086 SBCEDI Correct Invoice Events
- 50087 SBCEDI Sales Event Handler
- 50088 SBC EDI SMOG Posting Mgt.
- 50144 SBC Cash Receipt Events
- 50147 SBC LAXEDICreatePmtRemitAdv

### Configuration and operational pages
- 50080 SBCEDI ECR Settings
- 50083 SBCEDI SMOG Rates
- 50140 SBC EDI Receive Doc Error Logs
- 50148 SBC EDI SMOG Posting Setup

### Utility reports
- 50080 SBCEDI Refresh ECRs
- 50081 SBCEDI Update Doc Type
- 50081 SBC - Update PO Lines
- 50082 SBCEDI Update Discrepancy Flag
- 50083 SBCEDI Load Document
- 50084 SBCEDI Delete Tracking Spec
- 50085 SBCEDI Correct Invoices

### Table extensions
- 50080 SBC LAX EDI Document
- 50081 SBCEDI Customer
- 50082 SBCEDI Ship-to Address
- 50083 SBCEDI Sales Line
- 50084 SBCEDI Sales Line Archive
- 50085 SBCEDI Sales Invoice Line
- 50086 SBC EDI Pmt. Remit Advice Line
- 50087 SBC Sales&Receivables Setup

### Page extensions
- 50080 SBCEDI Payment Remit Advices
- 50081 SBC LAX EDI Document
- 50082 SBCEDI Payment Remit Advice
- 50083 SBCEDI Sales Lines
- 50084 SBCEDI Customer Card
- 50085 SBCEDI Ship-to Address
- 50086 SBCEDI Ship-to Address List
- 50087 SBCEDI Receive Document List
- 50088 SBCEDI Receive Document
- 50089 SBC EDI Template List
- 50090 SBC EDI WS Document
- 50091 SBC Sales&Receivables Setup
- 50140 SBC EDI PmtRemitAdvice Subpage

### Enums
- 50080 SBC Threshold Type

## Notes
This extension is designed to work in environments where Lanham EDI is already configured and where trade-partner cross-reference governance is required for customer, ship-to, and remittance workflows.
