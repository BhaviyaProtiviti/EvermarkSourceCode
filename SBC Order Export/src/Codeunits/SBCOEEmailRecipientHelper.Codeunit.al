/// <summary>
/// This codeunit is used to add recipients to the SBCOE Emails.
/// </summary>
codeunit 50061 "SBCOE Email Recipient Helper"
{
    Description = 'Add recipients to the SBCOE Emails';

    var
        GlobalSBCOEEmailEvents: Codeunit "SBCOE Email Events";

    local procedure SetCCRecipients()
    var
        SBCOEExportCCList: Record "SBCOE Export Email List";
    begin
        SBCOEExportCCList.SetRange(Enabled, true);

        if not SBCOEExportCCList.FindSet() then
            exit;

        // Enable conditional event and add cc contacts.

        if not GlobalSBCOEEmailEvents.IsBound() then
            GlobalSBCOEEmailEvents.Bind();

        repeat
            GlobalSBCOEEmailEvents.AddCCRecipient(SBCOEExportCCList."Email Address");
        until SBCOEExportCCList.Next() = 0;
    end;

    local procedure SetRecipients(var Rec: Record "Sales Header")
    begin
        SetToRecipients(Rec);

        SetCCRecipients();
    end;

    local procedure SetToRecipients(var Rec: Record "Sales Header")
    var
        Contact: Record Contact;
        SubContact: Record Contact;
        Customer: Record Customer;
    begin
        Customer.SetFilter("No.", '%1', Rec."Sell-to Customer No.");
        Customer.SetLoadFields("Primary Contact No.");

        if not Customer.FindFirst() then
            exit;

        Contact.SetFilter("No.", '%1', Customer."Primary Contact No.");

        Contact.SetLoadFields("No.");

        if not Contact.FindFirst() then
            exit;

        SubContact.SetFilter("Company No.", '%1', Contact."Company No.");
        SubContact.SetFilter("E-Mail", '<>%1', '');
        // Cross Column Search. If any columns here are true, the record will be returned.
        SubContact.FilterGroup(-1);
        SubContact.SetFilter("SBCOE Export Recipient", '%1', true);
        // Return to default filter group.
        SubContact.FilterGroup(0);

        SubContact.SetLoadFields("Company No.", "SBCOE Export Recipient", "E-Mail", "E-Mail 2");

        if not SubContact.FindSet() then
            exit;

        // Enable conditional event and add to contacts.

        GlobalSBCOEEmailEvents.Bind();
        repeat
            GlobalSBCOEEmailEvents.AddToRecipient(SubContact."E-Mail");
            GlobalSBCOEEmailEvents.AddToRecipient(SubContact."E-Mail 2");
        until SubContact.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnBeforeActionEvent', 'DraftInvoice', false, false)]
    local procedure AddRecipientsOnDraft(var Rec: Record "Sales Header")
    begin
        SetRecipients(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnBeforeActionEvent', 'PostAndSend', false, false)]
    local procedure AddRecipientsOnPostAndSend(var Rec: Record "Sales Header")
    begin
        SetRecipients(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnBeforeActionEvent', 'ProformaInvoice', false, false)]
    local procedure AddRecipientsOnProforma(var Rec: Record "Sales Header")
    begin
        SetRecipients(Rec);
    end;
}
