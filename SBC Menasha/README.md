# SBC Contract Mgf. Import

**Publisher:** Tigunia, LLC  
**Version:** 1.0.0.77  
**Platform:** Business Central Cloud  
**AL Runtime:** 11.0

## Overview

Contract manufacturing import extension for Suave Brands. Imports Menasha contract data from Excel files, automatically detects contract type from the sheet name, and processes each contract through the appropriate Business Central workflow before archiving it to posted contract records.

## Features

- **Excel import** — Uploads contract files and auto-detects the contract type (Inventory, Finished Goods, Consumption) from the sheet name.
- **Inventory adjustments** — Posts item journal entries for inventory contract lines.
- **Finished Goods processing** — Creates and processes finished goods receipts from contract lines.
- **Consumption / production journal** — Posts production journal entries for consumption contract lines.
- **Blind receipt import** — Separate Excel upload flow for importing blind receipts.
- **CA Sales import** — Imports Canadian sales orders or invoices from Excel with currency conversion support.
- **Contract archiving** — Moves fully processed contracts to posted contract header/line records and removes the originals.
- **Document attachment management** — Attaches supporting documents to contract records.

## Dependencies

| Extension | Publisher | Minimum Version |
|-----------|-----------|-----------------|
| SBC_Main_Modifications | Tigunia, LLC | 1.0.0.156 |
| Lanham EDI | Lanham Associates | 22.2.3.1030 |
| SBC Trade Allocation & Accrual | Tigunia, LLC | 22.0.54157.99 |

## Object ID Range

50350–50425

## Build & Deployment

All dependencies must be installed in the Business Central environment before publishing this extension.

## License & Support

Privacy Policy: https://tigunia.com/  
EULA: https://tigunia.com/  
Support: https://tigunia.com/
