/// <summary>
/// Unknown SBC MainModification (ID 50100).
/// </summary>
permissionset 50100 "SBC MainModification"
{
    Assignable = true;
    Caption = 'SBC Main Modification', MaxLength = 30;
    Permissions = table "SBC Vendor Group" = X,
        tabledata "SBC Vendor Group" = RMID,
        tabledata "SBCPurchPriceLoc/ShipmMethod" = RIMD,
        table "SBCPurchPriceLoc/ShipmMethod" = X,
        codeunit "SBC Subcontracting" = X,
        codeunit "SBC Post One Batch" = X,
        codeunit "Custom EDI Events" = X,
        codeunit "Custom Base Events" = X,
        codeunit "SBC Gen Journal Import Mgmt" = X,
        page "SBC Vendor Groups" = X,
        page "SBCPurchPriceLocs/ShipmMethods" = X,
        report "SBC Update Blank Dimensions" = X,
        report "SBC Transfer Orders" = X,
        report "SBC Post EDI Batches" = X,
        report "SBC Update EDI Item References" = X,
        report "SBC Calculate Subcontracts" = X,
        report "SBC Match NA Inventory" = X,
        report "SBC Clear Available Inventory" = X,
        codeunit "SBC Workflow" = X,
        table "SBC Brand Capacity by Location" = X,
        tabledata "SBC Brand Capacity by Location" = RMID,
        page "SBC Brand Capacity by Location" = X;
}