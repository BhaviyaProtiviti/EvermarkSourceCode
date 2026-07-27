/// <summary>
/// PageExtension SBCOE Email Editor (ID 50061) extends Record Email Editor.
/// </summary>
pageextension 50061 "SBCOE Email Editor" extends "Email Editor"
{
    trigger OnAfterGetRecord()
    begin
        if GlobalSBOEEmailEvents.IsBound() then
            PassRecipientFields(ToRecipient, CcRecipient, BccRecipient);
    end;

    var
        GlobalSBOEEmailEvents: Codeunit "SBCOE Email Events";

    [InternalEvent(true)]
    local procedure PassRecipientFields(var ToRecipient: Text; var CcRecipient: Text; var BccRecipient: Text)
    begin
    end;
}
