# SBC Main Modifications

## Overview

- Publisher: Tigunia, LLC
- Version: 1.0.0.160
- Runtime: 11.0
- Application: 22.0.0.0
- Platform: 1.0.0.0
- Target: Cloud
- Object ID Range: 50000-50149

SBC Main Modifications extends Microsoft Dynamics 365 Business Central for Suave Brands with core enhancements across EDI, purchasing, inventory, manufacturing, workflows, and reporting.

## Dependencies

- Lanham EDI by Lanham Associates (>= 22.2.3.1030)
- Lanham E-Ship and E-Receive by Lanham Associates (>= 21.1.12.10)

## Key Features

- EDI custom event handling for inbound/outbound document processing
- Purchase and sales process extensions for operational controls
- Inventory and item management enhancements, including lot parsing logic
- Manufacturing and subcontracting support
- Workflow and approval-related customizations
- Utility reports for posting, matching, and data correction

### Purchase Price by Location and Shipment Method

This branch includes custom purchase price enhancements that support location and shipment-method-specific costing:

- New table to store location and shipment method prices tied to purchase price keys
- New list page for maintaining location/shipment method direct unit costs
- Purchase Price extension field for item description display
- Purchase Prices page actions for updating open purchase orders and maintaining location/shipment method prices
- Prompt-based update of open purchase orders when costs are changed

## Project Structure

- src/codeunit: 7 codeunits
- src/table: 3 tables
- src/page: 3 pages
- src/tableextension: 29 table extensions
- src/pageextension: 39 page extensions
- src/report: 10 reports
- src/permissionset: 1 permission set
- Documentation: implementation notes

## Important Objects

### New Purchase Price Objects

- Table 50001 SBCPurchPriceLoc/ShipmMethod
- Page 50001 SBCPurchPriceLocs/ShipmMethods
- TableExtension 50000 SBC Purchase Price
- PageExtension 50000 SBC Purchase Prices

### Core Existing Objects

- Codeunit 50103 Custom Base Events
- Codeunit 50104 Custom EDI Events
- Codeunit 50105 SBC Lot Code Parsing Management
- Codeunit 50106 SBC Subcontracting
- Table 50000 SBC Vendor Group
- Table 50142 SBC Brand Capacity by Location
- PermissionSet SBCMainModification

## Reports Included

- SBC_AdjustCost
- SBC_CalculateSubcontracts
- SBC_ClearAvailableInventory
- SBC_CommercialInvoice
- SBC_EDIUpdateItemCrossReference
- SBC_MatchNAInventory
- SBC_PostEDIBatches
- SBC_TransferOrders
- SBC_UpdateBlankDimensions
- SBC_UpdateProductionPlant1

## Configuration Notes

- Configure setup fields introduced on Inventory, Manufacturing, Sales and Receivables, and Purchases and Payables setup pages.
- Validate Lanham EDI setup and trade partner mappings before document processing.
- Review purchase price maintenance flow before enabling automatic updates to open purchase orders.
- Assign permission set SBCMainModification to users requiring access.

## Additional Documentation

- See Documentation/BuyFromVendorPricing.md for buy-from vendor pricing behavior.

## Development Notes

- Enabled features: NoImplicitWith, TranslationFile
- Resource exposure policy allows debugging and source download
- Keep new objects and fields within the declared extension ID range
