/// <summary>
/// Unknown SBC Vena User (ID 50257).
/// </summary>
permissionset 50257 "SBC Vena User"
{
    Assignable = true;
    Caption = 'SBC Vena User', MaxLength = 30;
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
         tabledata "SBC Vena API Setup" = r,
         tabledata "SBC Vena DW Trade" = rim,
         tabledata "SBC Vena Item" = rim,
         tabledata "SBC Vena Job Setup" = rim,
         tabledata "SBC Vena Job Setup Line" = rim,
         tabledata "SBC Vena Job Status" = rim;
}