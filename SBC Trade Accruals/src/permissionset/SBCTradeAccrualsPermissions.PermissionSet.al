permissionset 50700 SBCTradeAccrualsPermissions
{
    Permissions =
        TableData SBCTradeSetupHeader = RIMD,
        TableData SBCTradeSetupLines = RIMD,
        tabledata SBCTradeAccrualLedgerEntry = RI,
        Page SBCTradeSetup = X,
        Page SBCTradeSetupLines = X;
}