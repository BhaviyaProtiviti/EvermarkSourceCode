# SBC Report Modifications

**Publisher:** Tigunia, LLC  
**Version:** 22.0.0.12  
**Object ID Range:** 50140–50159

## Overview

Extends and customizes standard Business Central reports for Suave Brands Company. Covers vendor remittance advices, electronic payment export, and purchase order layout enhancements.

## Objects

### Report Extensions

| ID | Object | Extends | Description |
|----|--------|---------|-------------|
| 50140 | `SBC Remittance Advice Entries` | Remittance Advice - Entries | Adds vendor bank account address columns, posting date, applied entry description, and document number to the entries-based remittance advice. Provides custom RDLC and Word email-body layouts. |
| 50141 | `SBC Remittance Advice - Jnl` | Remittance Advice - Journal | Adds vendor bank account address columns and applied entry description to the journal-based remittance advice. Provides custom RDLC and Word email-body layouts. |
| 50142 | `EVM Purchase Order` | Standard Purchase - Order | Adds `EVM Expected Ship Date` and `Expected Receipt Date` columns to purchase lines. Provides a custom Word layout with terms & conditions. |

### Reports

| ID | Object | Description |
|----|--------|-------------|
| 50145 | `SBC Export Electronic Payments` | Exports general journal payment and refund lines with vendor bank account address and company address details. Provides both RDLC and Word layouts. |

### Permission Sets

| ID | Object | Description |
|----|--------|-------------|
| 50140 | `SBC Report Mods` | Grants execute permission on the `SBC Export Electronic Payments` report. |

## Layouts

| Report | Layout Name | Type | File |
|--------|-------------|------|------|
| Remittance Advice - Entries | SBC Remit. Advice - Entries | RDLC | `SBCRemitAdviceEntries.rdl` |
| Remittance Advice - Entries | SBC Remit. Advice - Entries Email layout | Word | `SBCEntries_EmailBody.docx` |
| Remittance Advice - Journal | SBC Remit. Advice - Journal | RDLC | `SBCRemitAdviceJournal.rdl` |
| Remittance Advice - Journal | SBC Remit. Advice - Journal Email layout | Word | `SBCJournal_EmailBody.docx` |
| Standard Purchase - Order | EVM Layout with T&C | Word | `EVM Layout with T&C.docx` |
| SBC Export Electronic Payments | *(default)* | RDLC & Word | `SBCExportElectronicPayment.rdl` / `.docx` |

## Dependencies

| Dependency | Publisher | Min. Version |
|------------|-----------|-------------|
| Send remittance advice by email | Microsoft | ≥ 1.0.0.0 |
| SBC_Main_Modifications | Tigunia, LLC | ≥ 1.0.0.0 |
