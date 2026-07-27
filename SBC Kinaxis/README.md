# SBC Kinaxis Integration

## Overview
SBC Kinaxis Integration is a Business Central AL extension that exposes custom API endpoints and supporting logic for integrating Kinaxis planning data with Purchase Orders, Released Production Orders, and Transfer Orders.

## App Info
- Name: SBC Kinaxis Integration
- Publisher: Tigunia,LLC
- Version: 1.0.0.18
- Runtime: 11.0
- Application: 22.0.0.0
- Platform: 1.0.0.0
- Object ranges: 50143-50147, 50359-50364

## Dependencies
- SBC_Main_Modifications (Tigunia, LLC) >= 1.0.0.0
- Lanham EDI (Lanham Associates) >= 22.2.3.1030

## API Surface
All APIs are published under:
- Publisher: tigunia
- Group: kinaxis
- Version: v2.0

Main entities:
- tigPurchaseOrders with child tigPurchOrderLines
- tigTransferOrders with child tigTransferLines
- tigReleasedProdOrders

## Key Behavior
- Purchase Order API page supports delayed insert and custom location handling through toSite.
- Transfer Order API page maps transfer/in-transit codes into standard Transfer Header fields and resolves location address metadata.
- Released Production Order API page allows quantity/date/location updates and coordinates PO reopen/release flow when needed.
- Internal event subscribers hook into requisition and subcontracting workflows to keep Kinaxis-related purchase and production data synchronized.

## Main Objects
### Codeunits
- 50143 SBC Kinaxis Internal Hdlr
- 50145 SBC Kinaxis Release_Reopen PO

### API Pages
- 50143 SBC Kinaxis Transfer Order
- 50144 SBC Kinaxis Trans Order Lines
- 50145 SBC Kinaxis Release Prod Order
- 50146 SBC Kinaxis Purchase Order
- 50147 SBC Kinaxis Purch Order Line
- 50359 SBC Vendor Region List

### Tables and Table Extensions
- Table 50359 SBC Vendor Region
- TableExtension 50359 SBC Kinaxis Vendor
- TableExtension 50360 SBC Kinaxis Purchase Header
- TableExtension 50361 SBC Kinaxis User Setup
- TableExtension 50362 SBC Kinaxis Production Order
- TableExtension 50363 SBC Kinaxis Purchase Line
- TableExtension 50364 SBR Kinaxis Transfer Header

### Page Extensions
- 50359 SBC Kinaxis Vendor Card
- 50360 SBC Kinaxis User Setup
- 50361 SBC Kinaxis Purchase Order
- 50362 SBC Kinaxis RPO
- 50363 SBCKinaxis Purch Order Subform

### Permission Set
- 50359 SBC Kinaxis

## Example Endpoint Pattern
Base path pattern:

```text
{{baseUrl}}/tigunia/kinaxis/v2.0/companies({{companyId}})
```

Examples:
- GET tigPurchaseOrders
- POST tigPurchaseOrders
- POST tigPurchaseOrders({id})/tigPurchOrderLines
- GET tigReleasedProdOrders
- POST tigTransferOrders

Reference request samples are included in:
- src/rest/Kinaxis_Integration_PurchOrder.rest
- src/rest/Kinaxis_Integration_RProdOrder.rest
- src/rest/Kinaxis_Integration_TransOrder.rest

## Development Notes
- This app depends on Manufacturing Setup default location behavior when a Released Production Order is created without a location.
- API records are flagged with Kinaxis-specific fields to distinguish integration-driven updates from user-driven edits.
- If API changes are made, update the REST sample files in src/rest to keep test scenarios current.
