/// <summary>
/// Report SBCOE Copy Export Definition (ID 50064).
/// </summary>
report 50064 "SBCOE Copy Export Definition"
{
    Caption = 'SBCOE Copy Export Definition';
    ProcessingOnly = true;
    dataset
    {
        dataitem(SBCOEExportDefinitionDataItem; "SBCOE Export Definition")
        {
            CalcFields = "Spreadsheet Template";
            MaxIteration = 1;

            dataitem(SBCOEExportRowDataItem; "SBCOE Export Row")
            {
                DataItemLink = "Export Definition Code" = field("Export Definition Code");
                DataItemLinkReference = SBCOEExportDefinitionDataItem;
                dataitem(SBCOEExportColumnDataItem; "SBCOE Export Column")
                {
                    DataItemLink = "Export Definition Code" = field("Export Definition Code"), "Row Definition Code" = field("Row Definition Code");
                    DataItemLinkReference = SBCOEExportRowDataItem;
                    trigger OnAfterGetRecord()
                    begin
                        TempSBCOEExportColumn := SBCOEExportColumnDataItem;
                        TempSBCOEExportColumn."Export Definition Code" := GlobalSBCOEExportDefinitionCode;
                        TempSBCOEExportColumn.Insert();
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    TempSBCOEExportRow := SBCOEExportRowDataItem;
                    TempSBCOEExportRow."Export Definition Code" := GlobalSBCOEExportDefinitionCode;
                    TempSBCOEExportRow.Insert();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                TempSBCOEExportDefinition := SBCOEExportDefinitionDataItem;
                TempSBCOEExportDefinition."Export Definition Code" := GlobalSBCOEExportDefinitionCode;
                TempSBCOEExportDefinition.Insert();
                CopyTemplate(SBCOEExportDefinitionDataItem, TempSBCOEExportDefinition);
            end;
        }
    }

    requestpage
    {
        ShowFilter = false;
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Set New Export Definition Code';
                    field(GlobalSBCOEExportDefinitionCode; GlobalSBCOEExportDefinitionCode)
                    {
                        ApplicationArea = All;
                        Caption = 'New Export Definition Code';
                        ToolTip = 'The Export Definition Code to be used for the new Export Definition.';
                    }
                    field(GlobalCopyTemplate; GlobalCopyTemplate)
                    {
                        ApplicationArea = All;
                        Caption = 'Copy Excel Template';
                        ToolTip = 'Copy the Excel Template associated with the record, if one exists.';
                        Visible = false;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            GlobalCopyTemplate := true;
        end;
    }
    trigger OnPostReport()

    begin
        CreateNewExport();
    end;

    var
        TempSBCOEExportColumn: Record "SBCOE Export Column" temporary;
        TempSBCOEExportDefinition: Record "SBCOE Export Definition" temporary;
        TempSBCOEExportRow: Record "SBCOE Export Row" temporary;
        GlobalCopyTemplate: Boolean;
        GlobalSBCOEExportDefinitionCode: Code[20];
        ViewNewExportDefinitionLabel: Label 'Would you like to view the new Export Definition?';

    local procedure CopyColumn()
    var
        SBCOEExportColumn: Record "SBCOE Export Column";
    begin
        if not TempSBCOEExportColumn.FindSet() then
            exit;
        repeat
            SBCOEExportColumn := TempSBCOEExportColumn;
            SBCOEExportColumn.Insert();
        until TempSBCOEExportColumn.Next() = 0;
    end;

    local procedure CopyRows()
    var
        SBCOEExportRow: Record "SBCOE Export Row";
    begin
        if not TempSBCOEExportRow.FindSet() then
            exit;
        repeat
            SBCOEExportRow := TempSBCOEExportRow;
            SBCOEExportRow.Insert();
        until TempSBCOEExportRow.Next() = 0;
    end;

    local procedure CopyTemplate(var FromExportDefinition: Record "SBCOE Export Definition"; var ToExportDefinition: Record "SBCOE Export Definition")
    var
        ExcelTemplateInStream: InStream;
        ExcelTemplateOutStream: OutStream;
    begin
        if not GlobalCopyTemplate then
            exit;
        if not FromExportDefinition."Spreadsheet Template".HasValue() then
            exit;
        FromExportDefinition."Spreadsheet Template".CreateInStream(ExcelTemplateInStream);
        ToExportDefinition."Spreadsheet Template".CreateOutStream(ExcelTemplateOutStream);
        CopyStream(ExcelTemplateOutStream, ExcelTemplateInStream);
        ToExportDefinition.Modify();
    end;

    local procedure CreateNewExport()
    var
        SBCOEExportDefinition: Record "SBCOE Export Definition";
        ConfirmManagement: Codeunit "Confirm Management";
        PageManagement: Codeunit "Page Management";
    begin
        if not TempSBCOEExportDefinition.FindSet() then
            exit;
        repeat
            SBCOEExportDefinition := TempSBCOEExportDefinition;
            SBCOEExportDefinition.Insert();
            CopyTemplate(TempSBCOEExportDefinition, SBCOEExportDefinition);
        until TempSBCOEExportDefinition.Next() = 0;
        CopyRows();
        CopyColumn();
        Commit();
        if not GuiAllowed then
            exit;
        if not ConfirmManagement.GetResponseOrDefault(ViewNewExportDefinitionLabel, true) then
            exit;
        PageManagement.PageRun(SBCOEExportDefinition);
    end;
}