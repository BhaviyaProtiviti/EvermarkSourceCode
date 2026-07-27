/// <summary>
/// Specright User (ID 50180).
/// </summary>
permissionset 50180 "Specright User"
{
    Assignable = true;
    Permissions = tabledata "SBCSR Query Header" = RIMD,
        tabledata "SBCSR Query Line" = RIMD,
        tabledata "SBCSR Settings" = RIMD,
        table "SBCSR Query Header" = X,
        table "SBCSR Query Line" = X,
        table "SBCSR Settings" = X,
        report "SBCSR Sync Item" = X,
        codeunit "SBCSR Authentication" = X,
        codeunit "SBCSR Sync" = X,
        page "SBCSR Queries" = X,
        page "SBCSR Query" = X,
        page "SBCSR Query Lines" = X,
        page "SBCSR Settings" = X,
        page "SBCSR Specright Interface" = X,
        tabledata "SBCSR Sub Query" = RIMD,
        table "SBCSR Sub Query" = X,
        page "SBC SR Item Tables" = X,
        page "SBCSR Sub Queries" = X;
}