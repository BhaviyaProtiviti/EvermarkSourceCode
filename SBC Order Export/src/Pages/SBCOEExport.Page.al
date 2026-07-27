/// <summary>
/// This Page is used to display Export Data.
/// </summary>
page 50070 "SBCOE Export"
{
    AdditionalSearchTerms = 'SBCOE Export';
    ApplicationArea = All;
    Caption = 'Export';
    Description = 'This Page is used to display Export Data.';
    PageType = Card;
    SourceTable = "SBCOE Export";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("Email Group Code"; Rec."Email Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'Email Group Code';
                    DrillDown = true;
                    DrillDownPageId = "SBCOE Email Group";
                    ToolTip = 'The list of emails associated with this export.';
                }
                field("Export Data"; GlobalUploadDownloadText)
                {
                    ApplicationArea = All;
                    Caption = 'Export Data';
                    Editable = false;
                    Enabled = GlobalExportDataExists;
                    Lookup = true;
                    ToolTip = 'The export data.';
                    Visible = true;
                    trigger OnDrillDown()
                    begin
                        Rec.TryDownloadExportData();
                    end;
                }
            }
            part(Entries; "SBCOE Export Entries Part")
            {
                ApplicationArea = All;
                Caption = 'Export Entries';
                Editable = false;
                SubPageLink = "Export Entry No." = field("Export Entry No.");
            }

            part(Sends; "SBCOE Export Sends Part")
            {
                ApplicationArea = All;
                Caption = 'Exports Sends';
                Editable = false;
                SubPageLink = "Export Entry No." = field("Export Entry No.");
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
                }
                actionref(EmailExportDataAsAttachment_Promoted; EmailExportDataAsAttachment)
                {
                }
                actionref(OpenSentEmails_Promoted; OpenSentEmails)
                {
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
