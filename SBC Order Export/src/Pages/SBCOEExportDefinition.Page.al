/// <summary>
/// This page is used to define the export definition. The export definition is used to define the Excel export.
/// </summary>
page 50064 "SBCOE Export Definition"
{
    AdditionalSearchTerms = 'SBCOE Export Definition, Excel Export Definition, Export, Excel Export';
    ApplicationArea = All;
    Caption = 'Export Definition';
    Description = 'This page is used to define the export definition. The export definition is used to define the Excel export.';
    PageType = Card;
    SourceTable = "SBCOE Export Definition";

    layout
    {
        area(Content)
        {
            group(General)
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
                field("Export File Name"; Rec."Export File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Export File Name';
                    ToolTip = 'The name of the Excel export file';
                    Visible = true;
                    Editable = not Rec.Import;
                    Enabled = not Rec.Import;
                }
                field("Export Report Header"; Rec."Export Report Header")
                {
                    ApplicationArea = All;
                    Caption = 'Export Report Header';
                    ToolTip = 'The report header used in the Excel export';
                    Visible = false;
                    Editable = not Rec.Import;
                    Enabled = not Rec.Import;
                }
                field("Spreadsheet Template"; GlobalUploadDownloadText)
                {
                    ApplicationArea = All;
                    Caption = 'Spreadsheet Template';
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'This template can be loaded and used to generate the Excel export.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        Rec.UploadFile();
                    end;
                }
                field(Import; Rec.Import)
                {
                    ApplicationArea = All;
                    ToolTip = 'If this is set, this definition will be used to import an Excel file.';
                    Visible = true;
                    Editable = true;
                }
                group(Email)
                {
                    Caption = 'Email Settings';
                    Description = 'Settings here will override any defaults.';
                    Visible = not Rec.Import;
                    Editable = not Rec.Import;
                    Enabled = not Rec.Import;
                    field("Email Group Code"; Rec."Email Group Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Email Group Code';
                        DrillDown = true;
                        DrillDownPageId = "SBCOE Email Group";
                        ToolTip = 'The email group code used to send the Excel export';
                        Visible = true;
                    }
                    field("Export Email Subject"; Rec."Export Email Subject")
                    {
                        ApplicationArea = All;
                        Caption = 'Export Email Subject';
                        ToolTip = 'The value here will be used instead of the default subject when sending the email.';
                    }
                    field("Export Email Body"; GlobalExportEmailBlobText)
                    {
                        ApplicationArea = All;
                        Caption = 'Export Email Body';
                        ColumnSpan = 4;
                        Editable = GlobalMultiLineControlEditable;
                        MultiLine = true;
                        ToolTip = 'The value here will be used instead of the default body when sending the email.';
                        Visible = true;
                        Width = 1000;
                        trigger OnValidate()
                        begin
                            SetQueryTextOnRecord();
                        end;
                    }
                    field("Email Body Is HTML"; Rec."Email Body Is HTML")
                    {
                        ApplicationArea = All;
                        Caption = 'Email Body Is HTML';
                        ToolTip = 'Indicates whether the email body is HTML when set or plaintext when not set.';
                    }
                    field("Timestamp Format String"; Rec."Timestamp Format String")
                    {
                        ApplicationArea = All;
                        Caption = 'Timestamp Format String';
                        ToolTip = 'The value here will be used instead of the default timestamp format in the email subject.';
                        Visible = false;
                    }
                    field("Notification Only"; Rec."Notification Only")
                    {
                        ApplicationArea = All;
                        ToolTip = 'If this is set, the export will not be attached to the email.';
                        Visible = true;
                    }
                }
            }

            part(Rows; "SBCOE Export Row Part")
            {
                ApplicationArea = All;
                Caption = 'Export Rows';
                SubPageLink = "Export Definition Code" = field("Export Definition Code");

            }
            part(Columns; "SBCOE Export Column Part")
            {
                ApplicationArea = All;
                Caption = 'Export Columns';
                Provider = Rows;
                SubPageLink = "Export Definition Code" = field("Export Definition Code"), "Row Definition Code" = field("Row Definition Code");
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

    var
        GlobalMultiLineControlEditable: Boolean;
        GlobalExportEmailBlobText: Text;
        GlobalUploadDownloadText: Text;

    trigger OnOpenPage()
    begin
        GlobalUploadDownloadText := 'Upload/Download...';
    end;

    trigger OnAfterGetRecord()
    begin
        GlobalExportEmailBlobText := Rec.GetDefaultBodyText();
        GlobalMultiLineControlEditable := CurrPage.Editable();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Rows.Page.SetGlobalImportTemplate(Rec.Import);
        CurrPage.Columns.Page.SetGlobalImportTemplate(Rec.Import);
    end;

    local procedure SetQueryTextOnRecord()
    begin
        if (StrLen(GlobalExportEmailBlobText) > 0) and (GlobalExportEmailBlobText.Trim() = '') then
            GlobalExportEmailBlobText := '';

        Rec.SetBodyText(GlobalExportEmailBlobText);
    end;

    local procedure UploadFile()
    begin
        Rec.UploadFile();
        CurrPage.Update(false);
    end;
}
