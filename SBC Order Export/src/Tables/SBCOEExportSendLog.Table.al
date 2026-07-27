/// <summary>
///  This table is used to log the emails sent for the SBC PO Export.
/// </summary>
table 50061 "SBCOE Export Send Log"
{
    Caption = 'Order Export Send Log';
    DataClassification = EndUserIdentifiableInformation;
    Description = 'Log of the emails sent for the SBC PO Export.';
    DrillDownPageId = "SBCOE Export Send Log";
    LookupPageId = "SBCOE Export Send Log";
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            BlankZero = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Description = 'Unique Entry Number for the Log.';
        }
        field(2; "Export Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Export No.';
            DataClassification = CustomerContent;
            Description = 'Number associated with the export.';
            TableRelation = "SBCOE Export"."Export Entry No.";
        }
        field(3; "Email Message Id"; Guid)
        {
            Caption = 'Email Message Id';
            DataClassification = SystemMetadata;
            Description = 'The ID of the Email Message Associated with the Email Log Entry.';
        }
        field(30; "Export File Name"; Text[2048])
        {
            Caption = 'Export File Name';
            DataClassification = CustomerContent;
            Description = 'Name of the exported file.';
        }
        field(31; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'Number associated with the customer.';
        }
        field(32; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Description = 'Name of the customer.';
        }
        field(40; "Recipient Email Address"; Text[2048])
        {
            Caption = 'Recipient Email Address';
            DataClassification = EndUserPseudonymousIdentifiers;
            Description = 'Email address of the recipient.';
        }
        field(41; "CC EMail Address"; Text[2048])
        {
            Caption = 'CC Email Address';
            DataClassification = EndUserPseudonymousIdentifiers;
            Description = 'Email address of the CC recipient.';
        }
        field(50; "EMail Subject"; Text[2048])
        {
            Caption = 'EMail Subject';
            DataClassification = CustomerContent;
            Description = 'Subject of the email being sent.';
        }
        field(70; "Date/Time Sent"; DateTime)
        {
            Caption = 'Last Date/Time Sent';
            DataClassification = CustomerContent;
            Description = 'Date and time when the email was most recently sent.';
        }
        field(80; "Sender User ID"; Code[50])
        {
            Caption = 'Last Sender User ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            Description = 'ID of the user who most recently sent the email.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Export File Name", "Customer No.", "Customer Name", "Recipient Email Address", "EMail Subject")
        {
        }
    }
}
