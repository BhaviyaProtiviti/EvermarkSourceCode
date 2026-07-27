/// <summary>
/// Report SBCOE Open Template (ID 50061).
/// </summary>
report 50061 "SBCOE Open Template"
{
    ApplicationArea = All;
    Caption = 'SBC Process Import Template';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SBCOEExportDefinition; "SBCOE Export Definition")
        {
            DataItemTableView = WHERE(Import=const(true));
            RequestFilterFields = "Export Definition Code";
            trigger OnAfterGetRecord()
            var
                SBCOEImportManagement: Codeunit "SBCOE Import Management";
            begin
                SBCOEImportManagement.Run(SBCOEExportDefinition);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
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
}