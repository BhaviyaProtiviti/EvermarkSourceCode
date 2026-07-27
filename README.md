# SBC - UI Modifications

## Overview
SBC - UI Modifications is a Microsoft Dynamics 365 Business Central AL extension that delivers UI-focused customizations, reports, and API pages used across Suave Brands Company workflows.

## App Metadata
- Name: SBC - UI Modifications
- Publisher: Tigunia
- Version: 22.0.54157.118
- Runtime: 11.0
- Application: 22.0.0.0
- Brief: General Modifications, Reports and API Pages for SBC.

## Object ID Ranges
- 50030-50059
- 50142

## Dependencies
- SBCOE Order Export (Tigunia) >= 22.0.54157.0
- SBC_Main_Modifications (Tigunia, LLC) >= 1.0.0.96
- Continia Document Capture (Continia Software) >= 24.0.0.190414

## Internals Visible To
- SBCEDI Events (Tigunia, LLC)
- SBCOE Order Export (Tigunia)

## Source Layout
- src/APIPages: 3 AL files
- src/Codeunits: 6 AL files
- src/PageExtensions: 28 AL files
- src/Pages: 1 AL file
- src/permissionset: 1 AL file
- src/PermissionSets: 1 AL file
- src/report: 1 AL file
- src/ReportExtension: 1 AL file
- src/Reports: 4 AL files
- src/TableExtensions: 15 AL files
- src/Tables: 3 AL files
- src/Upgrade: 1 AL file

## Notes
- The extension uses `NoImplicitWith` and `TranslationFile` features.
- Translations are maintained in the `Translations/` folder.
