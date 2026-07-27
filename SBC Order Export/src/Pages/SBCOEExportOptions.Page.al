/// <summary>
/// This page is used to set the options for the Order Export.
/// </summary>
page 50062 "SBCOE Export Options"
{
    AdditionalSearchTerms = 'SBCOE Options';
    ApplicationArea = All;
    Caption = 'Export Options';
    Description = 'This page is used to set the options for the Order Export.';
    PageType = Card;
    SourceTable = "SBCOE Export Options";
    UsageCategory = Administration;

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
                    Caption = 'Default Export Definition Code';
                    Lookup = true;
                    LookupPageId = "SBCOE Export Definitions";
                    ShowMandatory = true;
                    ToolTip = 'The code of the Export Definition to use for this Export.';
                }
                field("Notification Definition Code"; Rec."Notification Definition Code")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    LookupPageId = "SBCOE Export Definitions";
                    ToolTip = 'The code of the default Notification Export Definition to use.';
                    Visible = true;
                }
                group(Email)
                {
                    Caption = 'Default Email Settings';
                    Description = 'The default settings to use for export emails.';
                    Visible = true;

                    field("Export Email Subject"; Rec."Export Email Subject")
                    {
                        ApplicationArea = All;
                        Caption = 'Default Email Subject';
                        ToolTip = 'The default subject to use for the email.';
                        Visible = true;
                    }
                    field("Export Email Body"; GlobalExportEmailBlobText)
                    {
                        ApplicationArea = All;
                        Caption = 'Default Email Body';
                        ColumnSpan = 4;
                        Editable = GlobalMultiLineControlEditable;
                        MultiLine = true;
                        ToolTip = 'The default body to use for the email.';
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
                        Visible = true;
                    }
                    field("Timestamp Format String"; Rec."Timestamp Format String")
                    {
                        ApplicationArea = All;
                        Caption = 'Timestamp Format String';
                        ToolTip = 'The format string to use for the timestamp in the email subject.';
                        Visible = false;
                    }
                }
            }
            group(Audit)
            {
                Caption = 'Audit';
                Editable = false;
                Visible = false;

                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'SystemId';
                    ToolTip = 'Specifies the value of the SystemId field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Caption = 'SystemCreatedAt';
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                    Caption = 'SystemCreatedBy';
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    Caption = 'SystemModifiedAt';
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                    Caption = 'SystemModifiedBy';
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GlobalExportEmailBlobText := Rec.GetBodyText();
        GlobalMultiLineControlEditable := CurrPage.Editable();
    end;

    var
        GlobalMultiLineControlEditable: Boolean;
        GlobalExportEmailBlobText: Text;

    local procedure SetQueryTextOnRecord()
    begin
        if (StrLen(GlobalExportEmailBlobText) > 0) and (GlobalExportEmailBlobText.Trim() = '') then
            GlobalExportEmailBlobText := '';

        Rec.SetBodyText(GlobalExportEmailBlobText);
    end;
}
