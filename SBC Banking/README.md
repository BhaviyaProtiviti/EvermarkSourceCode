# SBC Banking

**Publisher:** Tigunia, LLC  
**Version:** 22.0.0.0  
**Object ID Range:** 50600–50749  
**Target:** Cloud (Runtime 11.0)

## Overview

SBC Banking extends the Business Central payment export workflow with support for the ISO 20022 PAIN.001.001.03 (Credit Transfer) format via the **AMC Banking 365 Fundamentals** integration. It adds payment type classification (ACH, USD Wire, Check, Foreign Currency Wire), remit-to vendor details on payment export data, country-specific payment purpose codes, and flexible file output to either Azure File Share or a local download.

## Features

### Payment Export Pipeline

- Exports payment journal entries as ISO 20022 PAIN.001 XML files through the AMC Banking webservice.
- Supports domestic and international payment types: ACH, MTS (USD Wire), Check, and IWI (Foreign Currency Wire).
- Pre-maps general journal lines — including vendor, customer, and employee payments — into the payment export data buffer with extended remit-to recipient fields (address, city, postal code, country, email, bank account, clearing standard).
- Validation errors returned by AMC Banking are parsed and attached to journal lines for user review.

### Payment Types

An extensible `TIG Payment Type` enum (ID 50600) maps payment methods to specific export handling:

| Value | Description |
|-------|-------------|
| ACH | Automated Clearing House |
| MTS | USD Wire Transfer |
| Check | Paper check |
| IWI | Foreign Currency Wire |

### Payment Purpose Codes

A new `EVM Payment Purpose` table (ID 50600) stores regulatory payment purpose codes by country. Codes are selected directly on Payment Journal lines and included in the export XML.

### File Output Options

| Option | Description |
|--------|-------------|
| Azure File Share | Uploads the exported XML file to a configured Azure File Share using SAS token authentication. Credentials are stored in isolated storage. |
| Local Download | Downloads the file to the client using a timestamp-based file name (`suve.HHMMSSMSYYYYMMDD.xml`). |

Export behaviour per bank account is controlled by the **WF Export** settings on the Bank Account Card.

### Azure File Share Setup

A dedicated setup page (Page 50601) allows administrators to configure:

- **Storage Account** – Azure storage account name.
- **File Share** – Target file share name.
- **SAS Token** – Shared Access Signature token (masked; stored in isolated storage).

### Bank Account Configuration

Additional fields on the Bank Account Card (in the **WF Export** group):

| Field | Description |
|-------|-------------|
| WF Export File Path | Server directory path for the export file |
| Download Payment to Client | Toggle between Azure upload and local download |
| Payment Export No. Series | Number series for exported payment files |
| Last File Name | Read-only display of the most recently generated file |
| ACH Co ID | ACH company identifier for domestic payments |
| Check Marketing Message | Optional message printed on checks |
| Reconciliation File Path | Path for bank reconciliation file imports |

### Bank Clearing Standards

The Bank Clearing Standards list is extended with a **Clearing System ID Code** field (e.g., `USABA`, `CACPA`) used for cross-border payment routing in the export XML.

### Sandbox Environment Cleanup

A `SBCSandboxCleanup` codeunit (ID 50606) subscribes to Business Central environment copy and production-to-sandbox events to automatically clear sensitive banking data (e.g., `Last File Name`) and prevent data leakage between environments. A **Sandbox Cleanup** action is also available on the Company Information card for manual execution.

## Dependencies

| Extension | Publisher | Minimum Version |
|-----------|-----------|-----------------|
| AMC Banking 365 Fundamentals | Microsoft | 22.0.54157.55195 |

> **Note:** This extension requires a valid AMC Banking license. Payments are converted to ISO 20022 format through AMC's SOAP webservice. Without an AMC Banking subscription, the export pipeline will not function.

## Permission Set

| Permission Set | ID | Description |
|----------------|----|-------------|
| `SBC Banking` | 50600 | Grants execute access to all banking codeunits and full RIMD access to the Payment Purpose and Azure File Share Setup tables. Assign to users who process or configure payment exports. |

## Object Inventory

| Type | ID | Name |
|------|----|------|
| Table | 50600 | EVM Payment Purpose |
| Table | 50601 | EVMAzureFileShareSetup |
| TableExt | 50600 | TIG Bank Account |
| TableExt | 50601 | TIG Bank Clearing Standard |
| TableExt | 50602 | EVM Gen. Journal Line |
| TableExt | 50607 | TIG Payment Buffer |
| TableExt | 50608 | TIG Payment Export Data |
| Page | 50600 | EVM Payment Purposes |
| Page | 50601 | EVMAzureFileShareSetup |
| PageExt | 50600 | SBCCompanyInfoCardExt |
| PageExt | 50601 | SBC Bank Clearing Standards |
| PageExt | 50602 | TIG Bank Account Card |
| PageExt | 50603 | EVM Payment Journal |
| PageExt | 50609 | TIG Payment Methods Ext |
| Enum | 50600 | TIG Payment Type |
| Codeunit | 50600 | SBC AMC Bank Exp. CT Hndl |
| Codeunit | 50601 | SBC AMC Bank Exp. CT Launcher |
| Codeunit | 50602 | SBC AMC Bank Exp. CT Pre-Map |
| Codeunit | 50603 | SBC AMC Banking Mgt. |
| Codeunit | 50604 | SBC Exp. External Data EFT |
| Codeunit | 50605 | SBC Exp. Mapping Gen. Jnl. |
| Codeunit | 50606 | SBCSandboxCleanup |
| Codeunit | 50607 | EVMAzureFileShareManagement |
| XmlPort | 50600 | SBC AMC Bank Export CT |
| PermissionSet | 50600 | SBC Banking |
