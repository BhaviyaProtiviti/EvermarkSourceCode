permissionset 50359 "SBC Kinaxis"
{
    Assignable = true;
    Caption = 'SBC Kinaxis', MaxLength = 30;
    Permissions =
        table "SBC Vendor Region" = X,
        tabledata "SBC Vendor Region" = RMID,
        page "SBC Vendor Region List" = X,
        page "SBC Kinaxis Transfer Order" = X,
        page "SBC Kinaxis Trans Order Lines" = X,
        page "SBC Kinaxis Release Prod Order" = X,
        page "SBC Kinaxis Purchase Order" = X,
        page "SBC Kinaxis Purch Order Line" = X,
        codeunit "SBC Kinaxis Internal Hdlr" = X,
        codeunit "SBC Kinaxis Release_Reopen PO" = X;
}
