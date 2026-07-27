/// <summary>
/// Unknown SBC Vena Setup Admin (ID 50256).
/// </summary>
permissionset 50256 "SBC Vena Setup Admin"
{
    Assignable = true;
    Caption = 'SBC Vena Setup Admin', MaxLength = 30;
    
        Permissions =
         codeunit "SBC Get Vena Job Status" = X,
         codeunit "SBC Resend Vena Job" = X,
         codeunit "SBC Sync Vena Job" = X,
         codeunit "SBC Vena Helper" = X,
         page "SBC Vena API Setup" = X,
         page "SBC Vena Item" = X,
         page "SBC Vena Job Lines" = X,
         page "SBC Vena Job Setup" = X,
         page "SBC Vena Job Setup Lines" = X,
         page "SBC Vena Job Status" = X,
         page "SBC Vena Jobs List" = X,
         page "SBC Vena Trade" = X,
         page "SBCAPI Vena Item" = X,
         page "SBCAPI Vena Trade" = X,
         report "SBC Vena Job Status Update" = X,
         report "SBC Vena Sync Job" = X,
         table "SBC Vena API Setup" = X,
         table "SBC Vena DW Trade" = X,
         table "SBC Vena Item" = X,
         table "SBC Vena Job Setup" = X,
         table "SBC Vena Job Setup Line" = X,
         table "SBC Vena Job Status" = X,
         tabledata "SBC Vena API Setup" = RIMD,
         tabledata "SBC Vena DW Trade" = RIMD,
         tabledata "SBC Vena Item" = RIMD,
         tabledata "SBC Vena Job Setup" = RIMD,
         tabledata "SBC Vena Job Setup Line" = RIMD,
         tabledata "SBC Vena Job Status" = RIMD;
}
