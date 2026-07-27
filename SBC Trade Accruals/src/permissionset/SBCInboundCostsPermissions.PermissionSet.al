permissionset 50701 SBCInboundCostsPermissions
{
    Permissions =
        TableData SBCInboundCostLedgerEntry = RIMD,
        TableData SBCInboundCostSetup = RIMD,
        page SBCInboundCostSetupCard = X,
        page SBCInboundCostLedgerEntries = X;
}