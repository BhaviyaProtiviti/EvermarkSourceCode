/// <summary>
/// The SpecRight permission set is used to grant access to the SpecRight item queue.
/// </summary>
permissionset 50035 SpecRight
{
    Caption= 'SpecRight External';
    Assignable = true;
    Permissions = tabledata "SBC SpecRight Interface"=RIMD,
        page "SBC SpecRight Interface"=X;
}