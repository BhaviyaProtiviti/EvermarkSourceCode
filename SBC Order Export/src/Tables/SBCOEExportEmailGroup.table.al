/// <summary>
/// This table contains the list of email groups that can be used to send emails to.
/// </summary>
table 50068 "SBCOE Export Email Group"
{
    Caption = 'Export Email Group';
    DataClassification = EndUserPseudonymousIdentifiers;
    Description = 'This table contains the list of email groups that can be used to send emails to.';
    DrillDownPageId = "SBCOE Email Group";
    LookupPageId = "SBCOE Email Groups";

    fields
    {
        field(1; "Email Group Code"; Code[20])
        {
            Caption = 'Email Group Code';
            DataClassification = CustomerContent;
            Description = 'The identifier of the mail group.';
        }
        field(2; "Email Group Description"; Text[200])
        {
            Caption = 'Mail Group Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Email Group Code")
        {
            Clustered = true;
        }
    }

    var
        NoEmailAddressesDefinedErrorLabel: Label 'This Email Group does not have any email addresses defined.';
        NoEmailsDefinedErrorTitleLabel: Label 'No Emails Defined';

    var

    internal procedure CreateEmailMessage() EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage := Rec.CreateEmailMessage('', '', false);
    end;

    internal procedure CreateEmailMessage(EmailSubject: Text; EmailBody: Text; HTMLFormatted: Boolean) EmailMessage: Codeunit "Email Message";
    var
        SBCOEExportEMailList: Record "SBCOE Export Email List";
        SBCOEErrorHelper: Codeunit "SBCOE Error Helper";
    begin
        if not Rec.HasEmails(true) then
            Error(SBCOEErrorHelper.CreateCollectableErrorInfo(Rec.RecordId().GetRecord(), NoEmailAddressesDefinedErrorLabel, NoEmailsDefinedErrorTitleLabel));

        EmailMessage.Create(Rec.GetEmailList("Email Recipient Type"::"To"), EmailSubject, EmailBody, HTMLFormatted, Rec.GetEmailList("Email Recipient Type"::Cc), Rec.GetEmailList("Email Recipient Type"::Bcc));
    end;

    internal procedure GetEmailList(EmailAddressType: Enum "Email Recipient Type") EmailList: List of [Text]
    var
        SBCOEExportEMailList: Record "SBCOE Export Email List";
        CurrentEmail: Text[256];
    begin
        if not Rec.HasEmails(SBCOEExportEMailList, EmailAddressType) then
            exit;
        SBCOEExportEMailList.FindSet();
        repeat
            if not EmailList.Contains(SBCOEExportEMailList."Email Address") then
                EmailList.Add(SBCOEExportEMailList."Email Address");
        until SBCOEExportEMailList.Next() = 0;
    end;
    /// <summary>
    /// Returns a contact email list related to link relation passed into the procedure.
    /// </summary>
    /// <param name="LinkNo">Code[20].</param>
    /// <param name="LinkType">Enum "Contact Business Relation Link To Table".</param>
    /// <returns>Return variable ContactEmailList of type List of [Text].</returns>
    procedure GetExportContactEmailList(LinkNo: Code[20]; LinkType: Enum "Contact Business Relation Link To Table") ContactEmailList: List of [Text]
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        UniqueEmails: Dictionary of [Text, Text];
    begin
        Contact.SetRange("SBCOE Export Recipient", true);
        if not ContactBusinessRelation.FindContactsByRelation(Contact, LinkType, LinkNo) then
            exit;
        repeat
            if UniqueEmails.Add(Contact."E-Mail".ToLower().Trim(), Contact."E-Mail") then;
        until Contact.Next() = 0;
        ContactEmailList := UniqueEmails.Keys();
    end;

    internal procedure HasEmails(EnabledOnly: Boolean): Boolean
    var
        SBCOEExportEMailList: Record "SBCOE Export Email List";
    begin
        exit(Rec.HasEmails(SBCOEExportEMailList, EnabledOnly));
    end;

    internal procedure HasEmails(EmailAddressType: Enum "Email Recipient Type"): Boolean
    var
        SBCOEExportEMailList: Record "SBCOE Export Email List";
    begin
        exit(Rec.HasEmails(SBCOEExportEMailList, EmailAddressType));
    end;

    internal procedure HasEmails(var SBCOEExportEMailList: Record "SBCOE Export Email List"; EnabledOnly: Boolean): Boolean
    begin
        Rec.SetEmailListFilter(SBCOEExportEMailList, EnabledOnly);
        exit(not SBCOEExportEMailList.IsEmpty());
    end;

    internal procedure HasEmails(var SBCOEExportEMailList: Record "SBCOE Export Email List"; EmailAddressType: Enum "Email Recipient Type"): Boolean
    begin
        Rec.SetEmailListFilter(SBCOEExportEMailList, EmailAddressType);
        exit(not SBCOEExportEMailList.IsEmpty());
    end;

    internal procedure SetEmailListFilter(var SBCOEExportEMailList: Record "SBCOE Export Email List"; EnabledOnly: Boolean)
    begin
        SBCOEExportEMailList.SetCurrentKey(Enabled, "Email Type", "Email Placement Order");
        if EnabledOnly then
            SBCOEExportEMailList.SetRange(Enabled, EnabledOnly);
        SBCOEExportEMailList.SetRange("Email Group Code", Rec."Email Group Code");
    end;

    internal procedure SetEmailListFilter(var SBCOEExportEMailList: Record "SBCOE Export Email List"; EmailAddressType: Enum "Email Recipient Type")
    begin
        Rec.SetEmailListFilter(SBCOEExportEMailList, true);
        SBCOEExportEMailList.SetRange("Email Type", EmailAddressType);
    end;
}
