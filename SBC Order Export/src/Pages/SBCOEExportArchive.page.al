/// <summary>
/// This page shows the list of all exports.
/// </summary>
page 50067 "SBCOE Export Archive"
{
    AdditionalSearchTerms = 'SBCOE Export Archive';
    ApplicationArea = All;
    Caption = 'Export Archive';
    CardPageId = "SBCOE Export";
    Description = 'This page displays a list of all export attempts.';
    PageType = List;
    SourceTable = "SBCOE Export";
    SourceTableView = order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'Exports';
                Editable = false;
                field("Export Entry No."; Rec."Export Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'The entry number of the export data.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    Caption = 'Creation Date';
                    ToolTip = 'The date when the export data was created.';
                }
                field("Export Definition Code"; Rec."Export Definition Code")
                {
                    ApplicationArea = All;
                    Caption = 'Export Definition Code';
                    DrillDown = true;
                    DrillDownPageId = "SBCOE Export Definition";
                    ToolTip = 'The code of the export definition.';
                }
                field("Export Data"; GlobalUploadDownloadText)
                {
                    ApplicationArea = All;
                    Caption = 'Export Data';
                    DrillDown = true;
                    Editable = false;
                    Enabled = GlobalExportDataExists;
                    ToolTip = 'The export data.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        if GlobalExportDataExists then
                            Rec.TryDownloadExportData();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DownloadExportDataAction)
            {
                ApplicationArea = All;
                Caption = 'Download Export Data';
                Enabled = GlobalExportDataExists;
                Image = Export;
                ToolTip = 'Download the export data.';
                Visible = true;
                trigger OnAction()
                begin
                    if not Rec.TryDownloadExportData() then
                        exit;
                    CurrPage.Update(false);
                end;
            }
            action(EmailExportDataAsAttachment)
            {
                ApplicationArea = All;
                Caption = 'Email Export Data as Attachment';
                Enabled = GlobalExportDataExists;
                Image = MailAttachment;
                ToolTip = 'Email the export data as an attachment.';
                Visible = true;
                trigger OnAction()
                begin
                    if not Rec.TryEmailExportAsAttachment() then
                        exit;
                    CurrPage.Update();
                end;
            }
            action(OpenSentEmails)
            {
                ApplicationArea = All;
                Caption = 'Open Sent Emails';
                Enabled = GlobalExportDataExists;
                Image = Email;
                ToolTip = 'Open a list of sent emails for the current export.';
                Visible = true;
                trigger OnAction()
                begin
                    if not Rec.TryOpenSentEmails() then
                        exit;
                    CurrPage.Update();
                end;
            }
            action(OpenUnsentEmails)
            {
                ApplicationArea = All;
                Caption = 'Open Outbox';
                Enabled = GlobalExportDataExists;
                Image = MailSetup;
                ToolTip = 'Open a list of sent and unsent emails for the current export.';
                Visible = true;
                trigger OnAction()
                begin
                    if not Rec.TryOpenEmailOutbox() then
                        exit;
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Category_Process';
                actionref(DownloadExportDataAction_Promoted; DownloadExportDataAction)
                {
                    Visible = true;
                }
                actionref(EmailExportDataAsAttachment_Promoted; EmailExportDataAsAttachment)
                {
                    Visible = true;
                }
                actionref(OpenSentEmails_Promoted; OpenSentEmails)
                {
                    Visible = true;
                }
                actionref(OpenUnsentEmails_Promoted; OpenUnsentEmails)
                {
                }
            }
        }
    }

    var
        GlobalExportDataExists: Boolean;
        GlobalUploadDownloadText: Text;

    trigger OnAfterGetRecord()
    begin
        SetExportDataStatus();
    end;

    local procedure SetExportDataStatus()
    begin
        GlobalUploadDownloadText := '';
        GlobalExportDataExists := Rec."Export Data".HasValue();
        if GlobalExportDataExists then
            GlobalUploadDownloadText := 'Download...';
    end;
}
