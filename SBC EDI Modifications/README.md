# SBC EDI Modification

Business Central AL extension for EDI inventory updates related to transaction sets 945, 846, and 810.

## Project Info

- Name: SBC EDI Modification
- Publisher: Tigunia,LLC
- Version: 22.0.0.36
- Brief: EDI inventory updates related to 945 846 810
- Description: EDI inventory updates related to 945 846 810
- Runtime: 11.0
- Platform: 1.0.0.0
- Application: 21.0.0.0
- Object ID Range: 50100-50425

## Dependencies

- Lanham EDI (Lanham Associates) >= 22.2.3.1030
- SBC - UI Modifications (Tigunia) >= 22.0.54157.112
- SBC_Main_Modifications (Tigunia) >= 1.0.0.154

## Objects

### Tables
| ID | Name |
|----|------|
| 50100 | SBC Purch Order Transfer Link |
| 50150 | SBC Sales Order Cut Lines |

### Table Extensions
| ID | Name | Extends |
|----|------|---------|
| 50150 | SBC LAX EDI Setup | LAX EDI Setup |
| 50151 | SBC Item Modification | Item |
| 50152 | SBC Customer Ext | Customer |
| 50153 | SBC Customer Templ. | Customer Templ. |
| 50154 | SBC LAX EDI Trade Partner | LAX EDI Trade Partner |
| 50155 | SBCSalesLineTable | Sales Line |
| 50156 | SBCLAXEDIInvAdviceLine | LAX EDI Inventory Advice Line |
| 50157 | SBCLAXEDIInvAdviceHDR | LAX EDI Inventory Advice Hdr. |
| 50158 | SBC EDI Purchase Line | Purchase Line |
| 50165 | SBC Purchase Hdr | Purchase Header |
| 50166 | SBC Transfer Header Ext | Transfer Header |
| 50168 | SBC Purch Recpt Ext | Purch. Rcpt. Header |
| 50169 | SBC Location Ext | Location |
| 50180 | SBC Sales Header | Sales Header |

### Codeunits
| ID | Name |
|----|------|
| 50148 | SBC SO Update ODW Ship Date |
| 50150 | SBCEDI 945 Helper |
| 50151 | SBC EDI 846 Helper |
| 50152 | SBC EDI 810 Helper |
| 50153 | SBC EDI Create Item Jnl Helper |
| 50154 | SBC EDI Modifcation Events |
| 50155 | SBC Cut Short Lines |
| 50156 | SBC EDI Cust Gen Cross Ref |
| 50157 | SBC EDI Single Instance |
| 50161 | SBC Create Transfer Order |
| 50162 | SBCEDI944Helper |
| 50163 | SBC EDI 856CM Helper |

### Pages
| ID | Name |
|----|------|
| 50100 | SBC Sales Order Cut Lines |
| 50160 | SBC Purch Order Transfer List |

### Page Extensions
| ID | Name | Extends |
|----|------|---------|
| 50150 | SBC LAX EDI Setup | LAX EDI Setup |
| 50151 | SBC Item List Mod | Item List |
| 50152 | SBC Item Card Mod | Item Card |
| 50153 | SBC EDI Received Document | LAX EDI Receive Document |
| 50154 | SBC LAX EDI Trade Partner | LAX EDI Trade Partner |
| 50155 | SBCSalesLine | Sales Order Subform |
| 50156 | SBCLAXEDIAdjInv | LAX EDI Adj Inventory Subform |
| 50157 | SBCLAXEDIInvAdjHdr | LAX EDI Inventory Advice |
| 50158 | SBC Purchase Order Subform Ext | Purchase Order Subform |
| 50159 | SBC Customer Templ. Card | Customer Templ. Card |
| 50163 | SBC Customer Card Ext | Customer Card |
| 50164 | SBC Posted Purch Receipt | Posted Purchase Receipt |
| 50165 | SBC Purchase Order Ext | Purchase Order |
| 50166 | SBC Transfer Order Ext | Transfer Order |
| 50167 | SBC Posted Purchase Receipts | Posted Purchase Receipts |
| 50169 | SBC Location Ext | Location Card |
| 50175 | SBC Planned Ship Date Update | Sales Order List |
| 50180 | SBC Sales Header | Sales Order |

### Reports
| ID | Name |
|----|------|
| 50107 | SBCEDI Load Document |

### Permission Sets
| ID | Name |
|----|------|
| 50150 | SBC EDI Modification |

## Purpose

This extension adds Suave-specific EDI behavior for inventory and document handling, including transfer and posting-related integration logic used by EDI workflows. It also enhances visibility on posted purchase receipts by surfacing EDI document references, vendor shipment numbers, and linked transfer order/shipment/receipt numbers.

## Build Notes

- Download symbols before compiling.
- Build from VS Code with AL: Package.
- Publish from VS Code with AL: Publish.

## Links

- Website: https://tigunia.com/
- Help: https://tigunia.com/
- Privacy Statement: https://tigunia.com/
- EULA: https://tigunia.com/
