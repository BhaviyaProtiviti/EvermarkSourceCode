# Suave Brands Company — Business Central Extensions

This workspace contains all per-tenant AL extensions for Suave Brands Company (Evermark), built on Microsoft Dynamics 365 Business Central. Each folder is an independent extension managed by **Tigunia, LLC**.

---

## Contents

| Project | Description | Object Range | Version |
|---------|-------------|--------------|---------|
| [ReportModifications](ReportModifications/) | Customizes BC reports including an electronic payment export, with a dependency on Microsoft's "Send remittance advice by email" extension. | 50140–50159 | 22.0.0.11 |
| [SBC Bracket Pricing Lanham](SBC%20Bracket%20Pricing%20Lanham/) | Adds a Lanham E-Ship/E-Receive dependency layer to support bracket pricing within the SBC Trade Allocation & Accrual extension. | 50200–50249 | 22.0.54157.66 |
| [SBC Concur](SBC%20Concur/) | Imports Concur Expense and American Express payment/remittance data into Business Central journals. | 50100–50299 | 1.0.1.90 |
| [SBC Continia Modifications](SBC%20Continia%20Modifications/) | Extends Continia Document Capture, Business Foundation, and Core with Suave-specific customizations to document processing workflows. | 50140–50140, 50160–50165 | 1.0.0.5 |
| [SBC EDI Events](SBC%20EDI%20Events/) | Subscribes to Lanham EDI events to handle 820 (remittance), 850 (purchase orders), and 856 (ship notices) transaction processing. | 50080–50147 | 22.0.54157.192 |
| [SBC EDI Modifications](SBC%20EDI%20Modifications/) | Extends Lanham EDI processing for 945 (warehouse shipping advice), 846 (inventory inquiry), and 810 (invoice) transactions. | 50100–50425 | 22.0.0.30 |
| [SBC Kinaxis](SBC%20Kinaxis/) | Integrates with Kinaxis RapidResponse for purchase order release and reopen workflows via REST API calls. | 50143–50147, 50359–50364 | 1.0.0.12 |
| [SBC Marketing Posting Group](SBC%20Marketing%20Posting%20Group/) | Adds a Marketing Posting Group field to sales documents and customer records for revenue segmentation reporting. | 50141–50150 | 1.0.0.4 |
| [SBC Menasha](SBC%20Menasha/) | Handles contract manufacturer (Menasha) import data and integrates with trade allocation and accrual workflows. | 50350–50425 | 1.0.0.74 |
| [SBC Order Export](SBC%20Order%20Export/) | Provides configurable Excel/OpenXML mappings for exporting and importing sales order and related data. | 50060–50079 | 22.0.54157.29 |
| [SBC Page Control](SBC%20Page%20Control/) | Controls the visibility and enabled state of pages and fields in Business Central based on configurable rules. | 50250–50255 | 22.0.54157.6 |
| [SBC Specright](SBC%20Specright/) | Synchronizes product specification data with the SpecRight platform via authenticated REST API calls. | 50180–50199 | 22.0.54157.3 |
| [SBC Trade Accruals](SBC%20Trade%20Accruals/) | Accumulates and tracks trade expense accruals for Elida Beauty customer accounts. | 50700–50750 | 22.0.0.8 |
| [SBC Trade Allocation](SBC%20Trade%20Allocation/) | Manages accrual and allocation logic for trade spend across customer programs. | 50200–50249 | 22.0.54157.99 |
| [SBC Vena](SBC%20Vena/) | Integrates with Vena Solutions for financial reporting data synchronization and job status management. | 50256–50265 | 22.0.54157.11 |
| [SUA_Main_Modifications](SUA_Main_Modifications/) | Core extension providing base tables, enumerations, and codeunits shared across the suite; depends on Lanham EDI, E-Ship/E-Receive, and StockIQ. | 50000–50149 | 1.0.0.147 |
| [YWP - UI Modifications](YWP%20-%20UI%20Modifications/) | General UI page extensions, API pages, and reports for Business Central; serves as a shared UI foundation for several other extensions. | 50030–50059, 50142–50142 | 22.0.54157.114 |

> Folders without an `app.json` (`Data To API Page`, `SBC AR Pmt Handling`, `SBC EDI Parse`, `SBC Item Indirect Cost`, `SBC TempProcess`, `Project_2`, `Supporting-Files`) are excluded from this table.

---

## Dependencies

### Cross-Extension Dependencies (within this workspace)

- **YWP - UI Modifications** depends on **SBC Order Export** (≥ 22.0.54157.0) and **SUA_Main_Modifications** (≥ 1.0.0.96).
- **SBC EDI Modifications** depends on **YWP - UI Modifications** (≥ 22.0.54157.112).
- **SBC EDI Events** depends on **YWP - UI Modifications** (≥ 22.0.54157.92) and **SUA_Main_Modifications** (≥ 1.0.0.115).
- **SBC Specright** depends on **YWP - UI Modifications** (≥ 22.0.54157.107) and **SUA_Main_Modifications** (≥ 1.0.0.96).
- **SBC Kinaxis** depends on **SUA_Main_Modifications** (≥ 1.0.0.0).
- **SBC Menasha** depends on **SUA_Main_Modifications** (≥ 1.0.0.0) and **SBC Trade Allocation** (≥ 22.0.54157.91).
- **SBC Bracket Pricing Lanham** depends on **SBC Trade Allocation** (≥ 22.0.54157.86).

### External Dependencies

| Extension | Depends On | Min. Version |
|-----------|-----------|--------------|
| **SUA_Main_Modifications** | Lanham **Lanham EDI** | ≥ 22.2.3.1030 |
| **SUA_Main_Modifications** | Lanham **E-Ship and E-Receive** | ≥ 21.1.12.10 |
| **SUA_Main_Modifications** | **StockIQ Integration** | ≥ 21.0.0.14 |
| **SBC EDI Modifications** | Lanham **Lanham EDI** | ≥ 22.2.3.1030 |
| **SBC EDI Events** | Lanham **Lanham EDI** | ≥ 22.2.3.1030 |
| **SBC EDI Events** | Microsoft **_Exclude Bank Deposits** | ≥ 22.0.54157.55195 |
| **SBC Menasha** | Lanham **Lanham EDI** | ≥ 22.2.3.1030 |
| **SBC Kinaxis** | Lanham **Lanham EDI** | ≥ 22.2.3.1030 |
| **SBC Kinaxis** | **StockIQ Integration** | ≥ 1.0.0.0 |
| **SBC Bracket Pricing Lanham** | Lanham **E-Ship and E-Receive** | ≥ 21.0.0.0 |
| **SBC Continia Modifications** | Continia **Business Foundation** | ≥ 24.0.0.568456 |
| **SBC Continia Modifications** | Continia **Core** | ≥ 24.0.0.194493 |
| **SBC Continia Modifications** | Continia **Document Capture** | ≥ 24.0.0.190414 |
| **YWP - UI Modifications** | Continia **Document Capture** | ≥ 24.0.0.190414 |
| **ReportModifications** | Microsoft **Send remittance advice by email** | ≥ 1.0.0.0 |

