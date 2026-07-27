/// <summary>
/// This codeunit is used to handle events related to the Email Editor page.
/// </summary>
codeunit 50060 "SBCOE Email Events"
{
    Description = 'This codeunit is used to handle events related to the Email Editor page.';
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        GlobalSBCOEEmailEvents: Codeunit "SBCOE Email Events";
        GlobalBound: Boolean;
        GlobalCCRecipientsList: List of [Text];
        GlobalToRecipientsList: List of [Text];

    internal procedure AddCCRecipient(Recipient: Text)
    begin
        if Recipient = '' then
            exit;

        if not GlobalCCRecipientsList.Contains(Recipient) then
            GlobalCCRecipientsList.Add(Recipient);
    end;

    internal procedure AddToRecipient(Recipient: Text)
    begin
        if Recipient = '' then
            exit;

        if not GlobalToRecipientsList.Contains(Recipient) then
            GlobalToRecipientsList.Add(Recipient);
    end;

    internal procedure Bind()
    begin
        if IsBound() then
            exit;
        GlobalBound := BindSubscription(GlobalSBCOEEmailEvents);
    end;

    internal procedure IsBound(): Boolean
    begin
        exit(GlobalBound);
    end;

    internal procedure Unbind()
    begin
        Unbind(false);
    end;

    internal procedure Unbind(Force: Boolean)
    begin
        if not Force then
            if not IsBound() then
                exit;

        if not UnbindSubscription(GlobalSBCOEEmailEvents) then
            if not Force then
                exit;

        ClearGlobals();
    end;

    internal procedure UpdateRecipients(var RecipientTextObject: Text; var ReceipientList: List of [Text])
    var
        AdditionalRecipient: Text;
        RecipientTextBuilder: TextBuilder;
    begin
        RecipientTextBuilder.Append(RecipientTextObject);

        foreach AdditionalRecipient in ReceipientList do begin

            RecipientTextBuilder.Append('; ');
            RecipientTextBuilder.Append(AdditionalRecipient);
        end;

        RecipientTextObject := RecipientTextBuilder.ToText().TrimStart(';').TrimStart(' ');
    end;

    local procedure ClearGlobals()
    begin
        Clear(GlobalBound);
        Clear(GlobalToRecipientsList);
        Clear(GlobalCCRecipientsList);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Email Editor", 'PassRecipientFields', '', false, false)]
    local procedure SetAdditionalRecipientsInEditor(var ToRecipient: Text; var CcRecipient: Text; var BccRecipient: Text; var Sender: Page "Email Editor")
    begin
        UpdateRecipients(ToRecipient, GlobalToRecipientsList);
        UpdateRecipients(CcRecipient, GlobalCCRecipientsList);
        Unbind();
    end;
}
