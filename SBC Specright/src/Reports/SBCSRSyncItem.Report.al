/// <summary>
/// Report SBCSR Sync Item (ID 50180).
/// </summary>
report 50180 "SBCSR Sync Item"
{
    ApplicationArea = All;
    Caption = 'Specright Sync Item';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(SBCSRQueryHeader; "SBCSR Query Header")
        {
            MaxIteration = 1;
            RequestFilterFields = "Query Code";
            trigger OnPreDataItem()
            begin
                SetDefaultQuery();
            end;

        }
        dataitem(SBCSpecRightInterface; "SBC SpecRight Interface")
        {

            RequestFilterFields = "Item No.", "Processed Timestamp";

            trigger OnAfterGetRecord()
            begin
                ProcessInterfaceRecord();
            end;
        }

    }
    requestpage
    {
        SaveValues = true;
        SourceTable = "SBCSR Query Header";
        layout
        {
            area(content)
            {
                field(OptionAllowReprocess; GlobalOptionAllowReproces)
                {
                    ApplicationArea = All;
                    Caption = 'Allow Reprocess';
                    ToolTip = 'If this is set, interface records that have already been processed will be allowed to process again.';
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    var
        GlobalOptionAllowReproces: Boolean;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure ProcessInterfaceRecord()
    var
        SBCSRSync: Codeunit "SBCSR Sync";
    begin
        if (SBCSpecRightInterface."Processed Timestamp" <> 0DT) and not GlobalOptionAllowReproces then
            CurrReport.Skip();
        SBCSRSync.SetQueryHeader(SBCSRQueryHeader);
        SBCSRSync.Run(SBCSpecRightInterface);
    end;

    local procedure SetDefaultQuery()
    var
        SBCSRSettings: Record "SBCSR Settings";
    begin
        if SBCSRQueryHeader.HasFilter() then
            exit;
        SBCSRSettings.SetFilter("Default Query Code", '<>%1', ''); // Do not run if the default query code is empty
        SBCSRSettings.SetLoadFields("Default Query Code");
        if SBCSRSettings.IsEmpty() then
            exit;
        SBCSRSettings.FindFirst();
        SBCSRQueryHeader.SetFilter("Query Code", '%1', SBCSRSettings."Default Query Code");
        SBCSRQueryHeader.FindFirst();
    end;

}