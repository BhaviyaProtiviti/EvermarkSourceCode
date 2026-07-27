/// <summary>
/// Unknown SBC Contract Mfg (ID 50350).
/// </summary>
permissionset 50350 "SBC Contract Mfg"
{
    Assignable = true;
    Caption = 'SBC Contract Mfg', MaxLength = 30;
    Permissions =
        table "SBC Posted Contract Mfg Hdr" = X,
        tabledata "SBC Posted Contract Mfg Hdr" = RMID,
        table "SBC Posted Contract Mfg Line" = X,
        tabledata "SBC Posted Contract Mfg Line" = RMID,
        table "SBC Contract Mfg. Header" = X,
        tabledata "SBC Contract Mfg. Header" = RMID,
        table "SBC Contract Mfg. Line" = X,
        tabledata "SBC Contract Mfg. Line" = RMID,
        table "SBC Contract Mfg. Setup" = X,
        tabledata "SBC Contract Mfg. Setup" = RMID,
        codeunit "SBC Import Contract Inv Mgmt" = X,
        codeunit "SBC Import File Mgmt" = X,
        codeunit "SBC TblHdlr Contract Mfg. Hdr" = X,
        codeunit "SBC PgHdlr Contract Mfg Line" = X,
        codeunit "SBC Import Contract ProdMgmt." = X,
        codeunit "SBC Process - Contract Mfg." = X,
        codeunit "SBC Contract Mfg. Event Mgmt" = X,
        codeunit "SBC Document Attachment Mgmt" = X,
        page "SBC Posted Contract Subform" = X,
        page "SBC Posted Contracts" = X,
        page "SBC Posted Contract" = X,
        page "SBC Contract Mfg. Card" = X,
        page "SBC Contract Mfg Subform" = X,
        page "SBC Contract Mfg. List" = X,
        page "SBC Contract Mfg. Setup" = X,
        table "SBC Blind Receipt" = X,
        tabledata "SBC Blind Receipt" = RMID,
        codeunit "SBC Blind Receipt Import" = X,
        codeunit "SBC CA Sales Import" = X,
        page "SBC Blind Receipt Import" = X,
        page "SBC CA Sales Import Documents" = X,
        report "SBC Sales Invoice MCP" = X,
        query "SBC Posted Receipt" = X;
}
