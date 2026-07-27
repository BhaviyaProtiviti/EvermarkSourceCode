/// <summary>
/// This page is used to list Excel export definitions.
/// </summary>
page 50063 "SBCOE Export Definitions"
{
    AdditionalSearchTerms = 'SBCOE Export Definitions,Export Definitions,Excel Exports,PO Exports,Order Exports';
    ApplicationArea = All;
    Caption = 'Order Export Definitions';
    CardPageId = "SBCOE Export Definition";
    Description = 'This page is used to list Excel export definitions.';
    PageType = List;
    SourceTable = "SBCOE Export Definition";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Export Definition Code"; Rec."Export Definition Code")
                {
                    ApplicationArea = All;
                    Caption = 'Export Definition Code';
                    ToolTip = 'Excel Export Definition Identifier';
                    Visible = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'The description of the export definition';
                    Visible = true;
                }
                field(Import; Rec.Import)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, this definition will be used to import an Excel file.';
                    Visible = true;
                }
                field("Export File Name"; Rec."Export File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Export File Name';
                    ToolTip = 'The name of the Excel export file';
                    Visible = true;
                    Editable = not Rec.Import;
                }
                field("Export Report Header"; Rec."Export Report Header")
                {
                    ApplicationArea = All;
                    Caption = 'Export Report Header';
                    ToolTip = 'The report header used in the Excel export';
                    Visible = false;
                    Editable = not Rec.Import;
                }
                field("Email Group Code"; Rec."Email Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'Email Group Code';
                    DrillDown = true;
                    DrillDownPageId = "SBCOE Email Group";
                    ToolTip = 'The email group code used to send the Excel export';
                    Visible = true;
                    Editable = not Rec.Import;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Copy)
            {
                ApplicationArea = All;
                Caption = 'Copy';
                Image = Copy;
                ToolTip = 'Executes the Copy action.';
                Visible = true;
                trigger OnAction()
                begin
                    Rec.CopyExportDefinition();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Category_Process';
                actionref(Copy_Promoted; Copy)
                {
                    Visible = true;
                }
            }
        }
    }
}
