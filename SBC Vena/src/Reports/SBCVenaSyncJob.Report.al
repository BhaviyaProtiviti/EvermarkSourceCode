/// <summary>
/// Allows on demand running and scheduling of the SBC Vena Sync Job.
/// </summary>
report 50256 "SBC Vena Sync Job"
{
    ApplicationArea = All;
    Caption = 'SBC Vena Sync Job';
    Permissions =
                  tabledata "SBC Vena Job Setup" = R,
                  tabledata "SBC Vena Job Setup Line" = R;

    ProcessingOnly = true;
    UsageCategory = Tasks;
    dataset
    {
        dataitem(SBCVenaJobSetup; "SBC Vena Job Setup")
        {
            trigger OnAfterGetRecord()
            var
                SBCSyncVenaJob: Codeunit "SBC Sync Vena Job";
            begin
                SBCSyncVenaJob.Run(SBCVenaJobSetup);
            end;
        }

    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }

    }





}