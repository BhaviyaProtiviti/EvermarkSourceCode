permissionset 50250 "SBC Page Control"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "SBC Page Control Handler" = X,
         page "SBCPC Page Control" = X,
         table "SBCPC Page Control" = X,
         tabledata "SBCPC Page Control" = RIMD;
}