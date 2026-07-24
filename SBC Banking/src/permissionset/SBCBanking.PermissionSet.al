permissionset 50600 "SBC Banking"
{
    Assignable = true;
    Permissions =
    codeunit "SBC AMC Bank Exp. CT Hndl" = X,
    codeunit "SBC AMC Bank Exp. CT Launcher" = X,
    codeunit "SBC AMC Bank Exp. CT Pre-Map" = X,
    codeunit "SBC AMC Banking Mgt." = X,
    codeunit "SBC Exp. External Data EFT" = X,
    codeunit "SBC Exp. Mapping Gen. Jnl." = X,
    codeunit SBCSandboxCleanup = X,
    page "EVM Payment Purposes" = X,
    tabledata "EVM Payment Purpose" = RIMD,
    table "EVM Payment Purpose" = X,
    tabledata EVMAzureFileShareSetup = RIMD,
    table EVMAzureFileShareSetup = X,
    codeunit EVMAzureFileShareManagement = X,
    page EVMAzureFileShareSetup = X;
}