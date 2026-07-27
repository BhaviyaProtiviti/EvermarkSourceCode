/// <summary>
/// This page part is used to display the log of the emails sent by the SBCOE Export.
/// </summary>
page 50069 "SBCOE Export Sends Part"
{
    ApplicationArea = All;
    Caption = 'Export Sends Part';
    Description = 'This page part is used to display the log of the emails sent by the SBCOE Export.';
    PageType = ListPart;
    SourceTable = "SBCOE Export Send Log";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                Editable = false;
                field("CC EMail Address"; Rec."CC EMail Address")
                {
                    ApplicationArea = All;
                    Caption = 'CC EMail Address';
                    ToolTip = 'Email address of the CC recipient.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Unique Entry Number for the Log.';
                    Visible = false;
                }
                field("Export Entry No."; Rec."Export Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Export No.';
                    DrillDown = true;
                    DrillDownPageId = "SBCOE Export";
                    ToolTip = 'Number associated with the export.';
                    Visible = false;
                }
                field("Email Message Id"; Rec."Email Message Id")
                {
                    ApplicationArea = All;
                    Caption = 'Email Message Id';
                    ToolTip = 'The ID of the Email Message Associated with the Email Log Entry.';
                    Visible = false;
                }
                field("File Name"; Rec."Export File Name")
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'Name of the exported file.';
                    Visible = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Number associated with the customer.';
                    Visible = false;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Name of the customer.';
                    Visible = false;
                }
                field("Recipient EMail Address"; Rec."Recipient Email Address")
                {
                    ApplicationArea = All;
                    Caption = 'Recipient EMail Address';
                    ToolTip = 'Email address of the recipient.';
                    Visible = false;
                }
                field("EMail Subject"; Rec."EMail Subject")
                {
                    ApplicationArea = All;
                    Caption = 'EMail Subject';
                    ToolTip = 'Subject of the email being sent.';
                }
                field("Date/Time Created"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Caption = 'Date/Time Created';
                    ToolTip = 'Date and time when the email was created.';
                }
                field("Date/Time Sent"; Rec."Date/Time Sent")
                {
                    ApplicationArea = All;
                    Caption = 'Date/Time Sent';
                    ToolTip = 'Date and time when the email was sent.';
                }
                field("Sender User ID"; Rec."Sender User ID")
                {
                    ApplicationArea = All;
                    Caption = 'Sender User ID';
                    ToolTip = 'ID of the user who sent the email.';
                }
            }
        }
    }
}
