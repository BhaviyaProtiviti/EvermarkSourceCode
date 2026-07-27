permissionset 50150 "SBC EDI Modification"
{
    Assignable = true;
    Caption = 'SBC EDI Modification', MaxLength = 30;
    Permissions =
        table "SBC Sales Order Cut Lines" = X,
        table "SBC Purch Order Transfer Link" = X,
        tabledata "SBC Purch Order Transfer Link" = RIMD,
        tabledata "SBC Sales Order Cut Lines" = RMID,
        report "SBCEDI Load Document" = X,
        codeunit "SBC EDI Modifcation Events" = X,
        codeunit "SBC EDI Create Item Jnl Helper" = X,
        codeunit "SBCEDI 945 Helper" = X,
        codeunit "SBC EDI 846 Helper" = X,
        codeunit "SBC EDI 810 Helper" = X,
        codeunit "SBC Cut Short Lines" = X,
        codeunit "SBC EDI Cust Gen Cross Ref" = X,
        codeunit "SBC EDI Single Instance" = X,
        codeunit "SBC SO Update ODW Ship Date" = X,
        codeunit "SBC EDI 856CM Helper" = X;
}
