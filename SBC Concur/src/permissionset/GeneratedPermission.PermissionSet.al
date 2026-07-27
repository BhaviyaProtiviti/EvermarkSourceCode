
permissionset 50120 GeneratedPermission
{
    Assignable = true;
    Permissions =
        table "SBC AmEx Remittance Import" = X,
        tabledata "SBC AmEx Remittance Import" = RMID,
        table "Concur Import Entry" = X,
        tabledata "Concur Import Entry" = RMID,
        codeunit "SBC AmEx Remittance Import" = X,
        codeunit "SBC AmEx Payment Mgmt" = X,
        codeunit "Concur Interface Management" = X,
        page "SBC Processed AmEx Payments" = X,
        page "SBC AmEx Import" = X,
        page "Concur Interface Processed" = X,
        page "Concur Interface" = X,
        report "SBC Populate Employee ID" = X,
        xmlport "Import Concur Entries" = X;
}
